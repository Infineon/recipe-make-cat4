################################################################################
# \file defines.mk
#
# \brief
# Defines, needed for the PSoC 6 build recipe.
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
# General
################################################################################

# 
# CORE
#   - The type of ARM core used by the application.
#   - May be set by user in Makefile or by a BSP.
#   - If not set, assume CM0P.
#   - Valid COREs are determined by the selected toolchain. 
#     Currently this includes: CM0, CM0P, CM4, and CM33.
#
#
# Define the default core
#
CORE?=CR4
COMPONENTS+=$(CORE)

#
# List the supported toolchains
#
CY_SUPPORTED_TOOLCHAINS=GCC_ARM
DEVICE_GEN?=$(DEVICE)

include $(CY_INTERNAL_BASELIB_PATH)/make/recipe/features.mk

CY_OPENOCD_DEVICE_CFG=cyw9wcd1eval1.cfg
CY_PROG_FILE=$(CY_CONFIG_DIR)/$(APPNAME).trx.bin
CY_HEX_FILE=$(CY_PROG_FILE)

################################################################################
# Paths
################################################################################

# Set the output file paths
ifneq ($(CY_BUILD_LOCATION),)
CY_SYM_FILE?=$(CY_INTERNAL_BUILD_LOC)/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_TARGET)
CY_PROG_FILE?=$(CY_INTERNAL_BUILD_LOC)/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_PROGRAM)
else
CY_SYM_FILE?=\$$\{cy_prj_path\}/$(notdir $(CY_INTERNAL_BUILD_LOC))/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_TARGET)
CY_PROG_FILE?=\$$\{cy_prj_path\}/$(notdir $(CY_INTERNAL_BUILD_LOC))/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_PROGRAM)
endif


################################################################################
# IDE specifics
################################################################################

# Eclipse
ifeq ($(filter eclipse,$(MAKECMDGOALS)),eclipse)
CY_ECLIPSE_ARGS+="s|&&CY_OPENOCD_CFG&&|$(CY_OPENOCD_DEVICE_CFG)|g;"\
				"s|&&CY_OPENOCD_CHIP&&|$(CY_OPENOCD_CHIP_NAME)|g;"\
				"s|&&CY_APPNAME&&|$(CY_IDE_PRJNAME)|;"\
				"s|&&CY_CONFIG&&|$(CONFIG)|;"\
				"s|&&CY_SYM_FILE&&|$(CY_SYM_FILE)|;"\
				"s|&&CY_PROG_FILE&&|$(CY_PROG_FILE)|;"\
				"s|&&CY_ECLIPSE_GDB&&|$(CY_ECLIPSE_GDB)|g;"
endif

# VSCode
ifeq ($(filter vscode,$(MAKECMDGOALS)),vscode)
CY_GCC_BASE_DIR=$(subst $(CY_INTERNAL_TOOLS)/,,$(CY_INTERNAL_TOOL_gcc_BASE))
CY_GCC_VERSION=$(shell $(CY_INTERNAL_TOOL_arm-none-eabi-gcc_EXE) -dumpversion)
CY_OPENOCD_EXE_DIR=$(patsubst $(CY_INTERNAL_TOOLS)/%,%,$(CY_INTERNAL_TOOL_openocd_EXE))
CY_OPENOCD_SCRIPTS_DIR=$(patsubst $(CY_INTERNAL_TOOLS)/%,%,$(CY_INTERNAL_TOOL_openocd_scripts_SCRIPT))

ifneq ($(CY_BUILD_LOCATION),)
CY_ELF_FILE?=$(CY_INTERNAL_BUILD_LOC)/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_TARGET)
CY_HEX_FILE?=$(CY_INTERNAL_BUILD_LOC)/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_PROGRAM)
else
CY_ELF_FILE?=./$(notdir $(CY_INTERNAL_BUILD_LOC))/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_TARGET)
CY_HEX_FILE?=./$(notdir $(CY_INTERNAL_BUILD_LOC))/$(TARGET)/$(CONFIG)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_PROGRAM)
endif

CY_C_FLAGS=$(subst $(CY_SPACE),\"$(CY_COMMA)$(CY_NEWLINE_MARKER)\",$(strip $(CY_RECIPE_CFLAGS)))

ifeq ($(CY_ATTACH_SERVER_TYPE),)
CY_ATTACH_SERVER_TYPE=openocd
endif

CY_VSCODE_ARGS+="s|&&CY_ELF_FILE&&|$(CY_ELF_FILE)|g;"\
				"s|&&CY_HEX_FILE&&|$(CY_HEX_FILE)|g;"\
				"s|&&CY_OPEN_OCD_FILE&&|$(CY_OPENOCD_DEVICE_CFG)|g;"\
				"s|&&CY_MTB_PATH&&|$(CY_TOOLS_DIR)|g;"\
				"s|&&CY_TOOL_CHAIN_DIRECTORY&&|$(subst ",,$(CY_CROSSPATH))|g;"\
				"s|&&CY_C_FLAGS&&|$(CY_C_FLAGS)|g;"\
				"s|&&CY_GCC_VERSION&&|$(CY_GCC_VERSION)|g;"\
				"s|&&CY_OPENOCD_EXE_DIR&&|$(CY_OPENOCD_EXE_DIR)|g;"\
				"s|&&CY_OPENOCD_SCRIPTS_DIR&&|$(CY_OPENOCD_SCRIPTS_DIR)|g;"\
				"s|&&CY_CDB_FILE&&|$(CY_CDB_FILE)|g;"\
				"s|&&CY_CONFIG&&|$(CONFIG)|g;"\
				"s|&&CY_DEVICE_ATTACH&&|$(CY_JLINK_DEVICE_CFG_ATTACH)|g;"\
				"s|&&CY_MODUS_SHELL_BASE&&|$(CY_TOOL_modus-shell_BASE)|g;"\
				"s|&&CY_ATTACH_SERVER_TYPE&&|$(CY_ATTACH_SERVER_TYPE)|g;"

ifeq ($(CY_USE_CUSTOM_GCC),true)
CY_VSCODE_ARGS+="s|&&CY_GCC_BIN_DIR&&|$(CY_INTERNAL_TOOL_gcc_BASE)/bin|g;"\
				"s|&&CY_GCC_DIRECTORY&&|$(CY_INTERNAL_TOOL_gcc_BASE)|g;"
else
CY_VSCODE_ARGS+="s|&&CY_GCC_BIN_DIR&&|$$\{config:modustoolbox.toolsPath\}/$(CY_GCC_BASE_DIR)/bin|g;"\
				"s|&&CY_GCC_DIRECTORY&&|$$\{config:modustoolbox.toolsPath\}/$(CY_GCC_BASE_DIR)|g;"
endif
endif
