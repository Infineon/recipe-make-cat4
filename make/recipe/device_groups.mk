################################################################################
# \file device_group.mk
#
# \brief
# This make file defines device gorups information.
#
################################################################################
# \copyright
# (c) 2024-2025, Cypress Semiconductor Corporation (an Infineon company) or
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

################################################################################
# Device Information
################################################################################

# BSP device groups:
#   - The are a collection of make variables with a specific naming convention.
#
#   - They are used to define valid values of DEVICE (the part number of the 
#     device being targeted by the user).
#
#   - They define required information for closely related devices. E.g.,
#	- Names of COMPONENTS that should be enabled for any devices in the group.
#	- Name of the linker script to use for devices in the group.
#	- Additional defines (-D) to pass to compilers and assemblers for devices in the group.
#	- Start address and sizes of RAM (optional, used to calculate and report
#	  memory consumption at the end of the build).
#
#   - Device groups are defined by creating a set of make variables that follow
#     a naming convention.
#
#	# Required, list of device part numbers that belong to the group.
#	CY_BSP_DEVGROUP_DEVICES_<name>=<list of part numbers>
#	
#	# Requried, path to linker script for devices in this group (relative to the BSPs root folder).
#	CY_BSP_DEVGROUP_LINKER_SCRIPT_<name>=<path>
#
#	# Optional, names of components to enable for devices in this group.
#	CY_BSP_DEVGROUP_COMPONENTS_<name>=<names of components>
#   
#	# Optional, include dirs to pass to compilers and assembler [overrides autodiscovery]
#	CY_BSP_DEVGROUP_INCLUDES_<name>=<include dirs [without leading -I]>
#
#	# Optional, defines to pass to compilers and assembler.
#	CY_BSP_DEVGROUP_DEFINES_<name>=<defines [without leading -D]>
#
#	# Optional, if all of these are expressed report memory consumption at the end of the build.
#	CY_BSP_DEVGROUP_START_FLASH_<name>=<base address of flash [in hex, with leading 0x prefix]>
#

# Discover the names of all available BSP device groups.
#   - They are of the form: CY_BSP_DEVGROUP__<name>=<list of device names>
#     e.g., CY_BSP_DEVGROUP__foo=SLB9645TT1-1 CY8C6246BZI-D04
#   - BSPs may define as many device groups as required.
_CY_RECIPE_ARM_GENERIC_ALL_DEVICE_GROUP_NAMES:=\
    $(patsubst CY_BSP_DEVGROUP_DEVICES_%,%,\
	$(filter CY_BSP_DEVGROUP_DEVICES_%,$(.VARIABLES)))

# Name of device group that contains the BSPs selected DEVICE.
_MTB_RECIPE__ARM_GENERIC_ACTIVE_DEVICE_GROUP:=$(foreach name,$(_CY_RECIPE_ARM_GENERIC_ALL_DEVICE_GROUP_NAMES),$(if $(filter $(DEVICE),$(CY_BSP_DEVGROUP_DEVICES_$(name))),$(name)))

# Abort if we can't find the selected device.
$(if \
    $(CY_BSP_DEVGROUP__$(_MTB_RECIPE__ARM_GENERIC_ACTIVE_DEVICE_GROUP)),\
    $(error Unknown / unsupported DEVICE '$(DEVICE)'. Known devices include:)\
    $(foreach device,\
	$(foreach name,$(_CY_RECIPE_ARM_GENERIC_ALL_DEVICE_GROUP_NAMES),$(CY_BSP_DEVGROUP__$(name))),\
	$(info ... $(device))\
    )\
)


#############################################################################
# Reusable function for reporting device group errors.
_MTB_RECIPE__ARM_GENERIC_DEVGROUP_ERROR=$(error Misconfigured device group '$(_MTB_RECIPE__ARM_GENERIC_ACTIVE_DEVICE_GROUP)' from target '$(TARGET)' [$1].)


#############################################################################
# Linker script (overridden by user, or default for devices in the active group).
#   - NOTE: We need to be careful to make sure _MTB_RECIPE__ARM_GENERIC_LINKER_SCRIPT isn't expanded 
#           by make in this file. 
#   - NOTE: This file must be included by the BSP's $(TARGET).mk file so that we can enabled
#           recipe specific components.
#   - NOTE: That means this variable must forward references toolchain related variables (e.g.,
#           MTB_TOOLCHAIN_$(TOOLCHAIN)__SUFFIX_LS) that have not been set, yet.
#   - NOTE: Linker script validation happens in the recipe implementation (internal/implementation.mk).
_MTB_RECIPE__ARM_GENERIC_LINKER_SCRIPT=$(CY_BSP_DEVGROUP_LINKER_SCRIPT_$(_MTB_RECIPE__ARM_GENERIC_ACTIVE_DEVICE_GROUP))

#############################################################################
# Components for devices in the active group.
_CY_RECIPE_ARM_GENERIC_DEVICE_COMPONENTS=$(CY_BSP_DEVGROUP_COMPONENTS_$(_MTB_RECIPE__ARM_GENERIC_ACTIVE_DEVICE_GROUP))
COMPONENTS+=$(_CY_RECIPE_ARM_GENERIC_DEVICE_COMPONENTS)


#############################################################################
# Includes for devices in the active group.
_MTB_RECIPE__ARM_GENERIC_DEVICE_INCLUDES=$(CY_BSP_DEVGROUP_INCLUDES_$(_MTB_RECIPE__ARM_GENERIC_ACTIVE_DEVICE_GROUP))


#############################################################################
# Defines for devices in the active group.
_MTB_RECIPE__ARM_GENERIC_DEVICE_DEFINES=$(CY_BSP_DEVGROUP_DEFINES_$(_MTB_RECIPE__ARM_GENERIC_ACTIVE_DEVICE_GROUP))


#############################################################################
# SVD file for the target device.
_CY_RECIPE_ARM_GENERIC_SVD_PATH=$(MTB_TOOLS__TARGET_DIR)/$(CY_BSP_DEVGROUP_SVD_$(_MTB_RECIPE__ARM_GENERIC_ACTIVE_DEVICE_GROUP))

# if provided, make sure SVD file exists.
ifneq ($(_CY_RECIPE_ARM_GENERIC_SVD_PATH),)
$(if \
    $(wildcard $(_CY_RECIPE_ARM_GENERIC_SVD_PATH)),,\
    $(error Unable to find SVD file at '$(_CY_RECIPE_ARM_GENERIC_SVD_PATH)' for device '$(DEVICE)' (device group '$(_MTB_RECIPE__ARM_GENERIC_ACTIVE_DEVICE_GROUP)').))
endif

#############################################################################
# [Optional] device name provided to SEGGER J-Link when programming/debugging
_CY_RECIPE_ARM_GENERIC_JLINK_DEVICE_NAME=$(CY_BSP_DEVGROUP_JLINK_DEVICE_NAME_$(_MTB_RECIPE__ARM_GENERIC_ACTIVE_DEVICE_GROUP))


#############################################################################
# Start of flash (address, in hex [e.g., 0x1000000], used to calculate memory consumption).
_CY_RECIPE_ARM_GENERIC_START_FLASH=$(CY_BSP_DEVGROUP_START_FLASH_$(_MTB_RECIPE__ARM_GENERIC_ACTIVE_DEVICE_GROUP))
