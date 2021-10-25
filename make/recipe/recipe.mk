################################################################################
# \file recipe.mk
#
# \brief
# Primary interface for ModusToolbox "core-make" build recipe for simple / 
# generic / single core ARM MCUs.
#
################################################################################
# \copyright
# Copyright 2018-2021 Cypress Semiconductor Corporation
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
	    $(wildcard $(CY_INTERNAL_BASELIB_PATH)/make/toolchains/*.mk)))
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
# VFP_SELECT
#   - Floating point type (hardfp, softfp, or softfloat) to use.
#   - May be set by user in Makefile or by a BSP.
#
VFP_SELECT?=softfp

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

# CY_BASELIB_CORE_PATH
#   - Path to core-make's directory.

# CY_INTERNAL_BASELIB_PATH
#   - Path to the recipies root directory.
#   - Set by core-make before including recipe.mk
#

# 
# CY_SEARCH_APP_SOURCE
#   - Complete list of all C, C++, and assembly files found by autodiscovery.
# 
# CY_SEARCH_AVAILABLE_C_SOURCES
# CY_SEARCH_AVAILABLE_CPP_SOURCES
# CY_SEARCH_AVAILABLE_S_SOURCES
# CY_SEARCH_AVAILABLE_s_SOURCES
#   - C, C++, and assembly files grouped by type.
#   - Assembly source files are separated in to two variables for primary and secondary extensions.
#
# CY_SEARCH_AVAILABLE_O_SOURCES
# CY_SEARCH_AVAILABLE_A_LIBS
#   - Pre-compiled object files and static libraries found by autodiscovery.
# 
# CY_SEARCH_AVAILABLE_INCLUDES
#   - List of include directories detected by autodiscovery.
# 
# CY_SEARCH_RESOURCE_FILES
#   - List of resource files found 

# CY_GENERATED_DIR
#   - Directory (created by core-make) where generated source code files should be placed.


################################################################################
# ARM generic recipe implementation
################################################################################
include $(CY_INTERNAL_BASELIB_PATH)/make/recipe/internal/implementation.mk


################################################################################
# Outputs from build recipies (used by core-make to drive build process).
################################################################################

# If creating a custom build recipe, the above implementation can be replaced
# in its entirety. However, the new recipe needs to comply with the following
# interface with core-make.

# Start of flash/RAM (in hex, e.g., 0x10000000).
CY_START_FLASH=$(_CY_RECIPE_ARM_GENERIC_START_FLASH)
CY_START_SRAM=$(_CY_RECIPE_ARM_GENERIC_START_RAM)

# Size of flash/RAM (as bytes in decimal)
CY_MEMORY_FLASH=$(_CY_RECIPE_ARM_GENERIC_SIZE_FLASH)
CY_MEMORY_SRAM=$(_CY_RECIPE_ARM_GENERIC_SIZE_RAM)

# Final / complete / canonical list of flags to pass to the C compiler.
CY_RECIPE_CFLAGS=$(_CY_RECIPE_ARM_GENERIC_CFLAGS)

# Final / complete / canonical list of flags to pass to the C++ compiler.
CY_RECIPE_CXXFLAGS=$(_CY_RECIPE_ARM_GENERIC_CXXFLAGS)

# Final / complete / canonical list of flags to pass to the assembler.
CY_RECIPE_ASFLAGS=$(_CY_RECIPE_ARM_GENERIC_ASFLAGS)

# Final / complete / canonical list of flags to pass to the linker.
CY_RECIPE_LDFLAGS=$(_CY_RECIPE_ARM_GENERIC_LDFLAGS)

# Final / complete / canonical list of flags to pass to the archiver.
CY_RECIPE_ARFLAGS=$(_CY_RECIPE_ARM_GENERIC_ARFLAGS)

# Final / complete / canonical list of include directories to pass to compilers/assemblers.
CY_RECIPE_INCLUDES=$(_CY_RECIPE_ARM_GENERIC_INCLUDES)

# List of autodiscovered source files the recipe wants to build.
#   - NOTE: User source files in SOURCE are managed separately by core-make.
#   - NOTE: Recipe generated source files in CY_RECIPE_GENERATED are managed separately by core-make.
CY_RECIPE_SOURCE=$(_CY_RECIPE_ARM_GENERIC_SOURCE)

# Source files generated by the recipe.
CY_RECIPE_GENERATED:=$(_CY_RECIPE_ARM_GENERIC_GENERATED) 

# Set to TRUE if there are any files in CY_RECIPE_GENERATED, otherwise it should be empty..
CY_RECIPE_GENERATED_FLAG:=$(if $(filter 0,$(words $(CY_RECIPE_GENERATED))),,TRUE)

# Set compiler/assembler defines used to build code.
#   - NOTE: The -D prefix should be added at this point.
CY_RECIPE_DEFINES:=$(addprefix -D,$(_CY_RECIPE_ARM_GENERIC_DEFINES))

# Pre-compiled static libraries that should be directly linked in to the app.
CY_RECIPE_LIBS=$(_CY_RECIPE_ARM_GENERIC_LIBS)

# Recipe specific pre/post-build
CY_RECIPE_PREBUILD=
# Need to inject TRX header to allow it to actually run
CY_RECIPE_POSTBUILD=perl "$(CY_INTERNAL_BASELIB_PATH)/make/scripts/make_trx.pl" "$(CY_CONFIG_DIR)/$(APPNAME).elf" "$(CY_CONFIG_DIR)/$(APPNAME).trx.bin"

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
$(foreach v,CY_START_FLASH CY_START_SRAM CY_MEMORY_FLASH CY_MEMORY_SRAM CY_RECIPE_CFLAGS CY_RECIPE_CXXFLAGS CY_RECIPE_ASFLAGS CY_RECIPE_LDFLAGS CY_RECIPE_ARFLAGS CY_RECIPE_INCLUDES CY_RECIPE_SOURCE CY_RECIPE_GENERATED CY_RECIPE_GENERATED_FLAG CY_RECIPE_DEFINES CY_RECIPE_LIBS CY_RECIPE_PREBUILD CY_RECIPE_POSTBUILD,$(info $(v)=$($(v))))
$(info )
$(info = Other)
$(foreach v,COMPONENTS SOURCES CY_RECIPE_SOURCE CY_RECIPE_GENERATED,$(info $(v)=$($(v))))
$(info )
endif # ($(filter RECIPE,$(DEBUG)),)

