################################################################################
# \file recipe.mk
#
# \brief
# Primary interface for ModusToolbox "core-make" build recipe for simple / 
# generic / single core ARM MCUs.
#
################################################################################
# \copyright
# Copyright 2018-2024 Cypress Semiconductor Corporation
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

ifeq ($(WHICHFILE),true)
$(info Processing $(lastword $(MAKEFILE_LIST)))
endif


################################################################################
# Inputs to all build recipes
################################################################################

# 
# TOOLCHAIN
#   - The type of TOOLCHAIN used by the application.
#   - May be set by user in Makefile or by a BSP.
#   - If not set, use the first TOOLCHAIN in CY_RECIPE_SUPPORTED_TOOLCHAINS
#
TOOLCHAIN?=GCC_ARM

# Make sure TOOLCHAIN is valid
_CY_RECIPE_ARM_GENERIC_VALID_TOOLCHAINS:=\
    $(patsubst %.mk,%,\
	$(notdir \
	    $(wildcard $(MTB_TOOLS__RECIPE_DIR)/make/toolchains/*.mk)))
$(if \
    $(filter $(TOOLCHAIN),$(_CY_RECIPE_ARM_GENERIC_VALID_TOOLCHAINS)),\
    ,\
    $(error TOOLCHAIN '$(TOOLCHAIN)' is not supported. Legal values include: $(_CY_RECIPE_ARM_GENERIC_VALID_TOOLCHAINS)))

# 
# CONFIG
#   - Build configuration (Debug or Release).
#   - May be set by user in Makefile or by a BSP.
#   - Valid CONFIGs are set by the selected toolchain.
#     currently include: Debug, Release
#
CONFIG?=Debug

# 
# TARGET
#   - Name of the users seleced BSP for the application.
#   - Must be set by user in Makefile.
#

# Make sure TARGET was set.
$(if $(TARGET),,$(error TARGET not set.))

# 
# CFLAGS, CXXFLAGS, ASFLAGS, LDFLAGS
#   - Additional / optional C, C++, assembler, and linker command line arguments provided by user in Makefile.
#

# 
# LINKER_SCRIPT
#   - If set by user, the path to their custom linker script file.
#   - Users linker script file needs to be appropriate for their selected TOOLCHAIN.
#   - If not set, correct linker script will be deduced from the BSPs selected DEVICE.
# 

# If set, make sure LINKER_SCRIPT is valid.
$(if $(LINKER_SCRIPT),$(if $(wildcard $(LINKER_SCRIPT)),,$(error Unable to find custom LINKER_SCRIPT file '$(LINKER_SCRIPT)'.)))

# 
# PREBUILD, POSTBUILD
#   - Custom pre/post build commands (executable+arguments) set by user in Makefile.
#

################################################################################
# ARM generic recipe implementation
################################################################################
include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/internal/implementation.mk


################################################################################
# Outputs from build recipies (used by core-make to drive build process).
################################################################################

# If creating a custom build recipe, the above implementation can be replaced
# in its entirety. However, the new recipe needs to comply with the following
# interface with core-make.

# Start of flash/RAM (in hex, e.g., 0x10000000).
_MTB_RECIPE__START_FLASH=$(_CY_RECIPE_ARM_GENERIC_START_FLASH)

# Final / complete / canonical list of flags to pass to the C compiler.
MTB_RECIPE__CFLAGS=$(_MTB_RECIPE__ARM_GENERIC_CFLAGS)

# Final / complete / canonical list of flags to pass to the C++ compiler.
MTB_RECIPE__CXXFLAGS=$(_MTB_RECIPE__ARM_GENERIC_CXXFLAGS)

# Final / complete / canonical list of flags to pass to the assembler.
MTB_RECIPE__ASFLAGS=$(_MTB_RECIPE__ARM_GENERIC_ASFLAGS)

# Final / complete / canonical list of flags to pass to the linker.
MTB_RECIPE__LDFLAGS=$(_MTB_RECIPE__ARM_GENERIC_LDFLAGS)

# Final / complete / canonical list of flags to pass to the archiver.
MTB_RECIPE__ARFLAGS=$(_MTB_RECIPE__ARM_GENERIC_ARFLAGS)

# Final / complete / canonical list of include directories to pass to compilers/assemblers.
MTB_RECIPE__INCLUDES=$(_MTB_RECIPE__ARM_GENERIC_INCLUDES)

# List of autodiscovered source files the recipe wants to build.
#   - NOTE: User source files in SOURCE are managed separately by core-make.
MTB_RECIPE__SOURCE=$(_MTB_RECIPE__ARM_GENERIC_SOURCE)

# Set compiler/assembler defines used to build code.
#   - NOTE: The -D prefix should be added at this point.
MTB_RECIPE__DEFINES=$(sort $(addprefix -D,$(__MTB_RECIPE__ARM_GENERIC_DEFINES) $(BSP_DEFINES) $(DEVICE_DEFINES) CY_TARGET_DEVICE=$(subst -,_,$(DEVICE))))

# Pre-compiled static libraries that should be directly linked in to the app.
MTB_RECIPE__LIBS=$(_MTB_RECIPE__ARM_GENERIC_LIBS)

# Recipe specific pre/post-build
recipe_prebuild:
	@:

# Need to inject TRX header to allow it to actually run
recipe_postbuild:
	perl "$(MTB_TOOLS__RECIPE_DIR)/make/scripts/make_trx.pl" "$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).elf" "$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).trx.bin"

ifneq ($(CY_SECONDSTAGE),)
MTB_RECIPE__LAST_CONFIG_DIR:=$(MTB_TOOLS__OUTPUT_BASE_DIR)/last_config
$(MTB_RECIPE__LAST_CONFIG_DIR):|
	$(MTB__NOISE)mkdir -p $(MTB_RECIPE__LAST_CONFIG_DIR)

_MTB_RECIPE__LAST_CONFIG_PROG_FILE:=$(MTB_RECIPE__LAST_CONFIG_DIR)/$(APPNAME).trx.bin
_MTB_RECIPE__LAST_CONFIG_TARG_FILE:=$(MTB_RECIPE__LAST_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_TARGET)
_MTB_RECIPE__LAST_CONFIG_PROG_FILE_D:=$(_MTB_RECIPE__LAST_CONFIG_PROG_FILE).d

build_proj qbuild_proj: $(_MTB_RECIPE__LAST_CONFIG_PROG_FILE)

$(_MTB_RECIPE__LAST_CONFIG_PROG_FILE_D): | $(MTB_RECIPE__LAST_CONFIG_DIR)
	$(MTB__NOISE)echo $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).trx.bin > $@.tmp
	$(MTB__NOISE)if ! cmp -s "$@" "$@.tmp"; then \
		mv -f "$@.tmp" "$@" ; \
	else \
		rm -f "$@.tmp"; \
	fi

$(_MTB_RECIPE__LAST_CONFIG_PROG_FILE): $(_MTB_RECIPE__PROG_FILE) $(_MTB_RECIPE__LAST_CONFIG_PROG_FILE_D) recipe_postbuild
	$(MTB__NOISE)cp -rf $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).trx.bin $@
	$(MTB__NOISE)cp -rf $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).elf $(_MTB_RECIPE__LAST_CONFIG_TARG_FILE)

endif

# If environment (and/or make) variable DEBUG contains word 'RECIPE' dump additional build recipe debug
# output.
ifneq ($(filter RECIPE,$(DEBUG)),)
$(info ===================================================)
$(info = RECIPE)
$(info ===================================================)
$(info )
$(info = Main recipe inputs)
$(foreach v,CONFIG CORE LINKER_SCRIPT TARGET TOOLCHAIN VFP_SELECT,$(info $(v)=$($(v))))
$(info )
$(info = Main recipe outputs)
$(foreach v,_MTB_RECIPE__START_FLASH MTB_RECIPE__CFLAGS MTB_RECIPE__CXXFLAGS MTB_RECIPE__ASFLAGS MTB_RECIPE__LDFLAGS MTB_RECIPE__ARFLAGS MTB_RECIPE__INCLUDES MTB_RECIPE__SOURCE MTB_RECIPE__DEFINES MTB_RECIPE__LIBS,$(info $(v)=$($(v))))
$(info )
$(info = Other)
$(foreach v,COMPONENTS SOURCES MTB_RECIPE__SOURCE ,$(info $(v)=$($(v))))
$(info )
endif # ($(filter RECIPE,$(DEBUG)),)

