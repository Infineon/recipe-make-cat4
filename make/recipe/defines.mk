################################################################################
# \file defines.mk
#
# \brief
# Defines, needed for the 4390X build recipe.
#
################################################################################
# \copyright
# (c) 2018-2025, Cypress Semiconductor Corporation (an Infineon company) or
# an affiliate of Cypress Semiconductor Corporation. All rights reserved.
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
# Compatibility interface for this recipe make
#
MTB_RECIPE__INTERFACE_VERSION:=2
MTB_RECIPE__EXPORT_INTERFACES:=1 2 3

MTB_RECIPE__NINJA_SUPPORT:=1 2

# Programming interface description
ifeq (,$(BSP_PROGRAM_INTERFACE))
_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR:=FTDI
else
_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR:=$(BSP_PROGRAM_INTERFACE)
endif
ifeq ($(findstring $(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR),FTDI JLink),)
$(call mtb__error,Unable to proceed. $(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR) interface is not supported for this device)
endif

# debug interface validation
debug_interface_check:
ifeq ($(filter $(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR), FTDI JLink),)
	$(error "$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)" interface is not supported for this device. \
	Supported interfaces are "FTDI JLink")
endif

#
# List the supported toolchains
#
ifdef CY_SUPPORTED_TOOLCHAINS
MTB_SUPPORTED_TOOLCHAINS?=$(CY_SUPPORTED_TOOLCHAINS)
else
MTB_SUPPORTED_TOOLCHAINS?=GCC_ARM
endif

# For BWC with Makefiles that do anything with CY_SUPPORTED_TOOLCHAINS
CY_SUPPORTED_TOOLCHAINS:=$(MTB_SUPPORTED_TOOLCHAINS)

include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/features.mk

_MTB_RECIPE__OPENOCD_DEVICE_CFG:=cyw9wcd1eval1.cfg
_MTB_RECIPE__HEX_FILE:=$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).trx.bin

################################################################################
# BSP
################################################################################

ifeq (2,$(words $(DEVICE_$(DEVICE)_CORES)))
_MTB_RECIPE__IS_MULTI_CORE_DEVICE:=true
endif

ifneq (,$(filter StandardSecure,$(DEVICE_$(DEVICE)_FEATURES)))
_MTB_RECIPE__IS_SECURE_DEVICE:=true
endif
ifneq (,$(filter SecureBoot,$(DEVICE_$(DEVICE)_FEATURES)))
_MTB_RECIPE__IS_SECURE_DEVICE:=true
endif

_MTB_RECIPE__DEVICE_DIE:=$(DEVICE_$(DEVICE)_DIE)

_MTB_RECIPE__DEVICE_FLASH_KB:=$(DEVICE_$(DEVICE)_FLASH_KB)
