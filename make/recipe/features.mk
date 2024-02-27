################################################################################
# \file device_groups.mk
#
# \brief
# Define the CY8CPROTO-062-4343W target.
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
# Device Group 4390X
################################################################################

# Device MPNs that belong to the "4390X" group
#    - NOTE: The 4390X group will be enabled by the generic ARM build recipe if
#            the DEVICE selected by the user is in this list.
CY_BSP_DEVGROUP_DEVICES_4390X=CYW43907KWBG CYW54907KWBG CYW43903KUBG CYW43909KRFBG

# Path to linker script to use for devices in this group.
#   - NOTE: Value is a path relative to the BSP's root directory.
#   - NOTE: TOOLCHAIN is the name of the users selected toolchain.
#   - NOTE: MTB_TOOLCHAIN_$(TOOLCHAIN)__SUFFIX_LS is the file extension for the selected 
#           toolchain's linker scripts
CY_BSP_DEVGROUP_LINKER_SCRIPT_4390X=TOOLCHAIN_$(TOOLCHAIN)/linker.$(MTB_TOOLCHAIN_$(TOOLCHAIN)__SUFFIX_LS)

# Enable optional code shared by devices in the 4390X group.
CY_BSP_DEVGROUP_COMPONENTS_4390X=4390X

# Additional include directories forcibly added for devices in the 4390X group.
#   - NOTE: Paths are relative to the BSPs root directory.
#   - NOTE: Do not include a leading -I (just list the path).
#   - NOTE: This bypasses the normal autodiscovery mechanisim and should be
#           used infrequently.
CY_BSP_DEVGROUP_INCLUDES_4390X=

# Additional compiler/assembler defines for devices in the 4390X group.
#   - NOTE: Do not include a leading -D (just NAME, or NAME=VALUE).
CY_BSP_DEVGROUP_DEFINES_4390X=

# Optional, base addresses and sizes of flash and RAM.
#   - NOTE: Only used to print a memory consuption report at the end of the build.
#   - NOTE: If not specified, the memory usage report will be skipped.
#   - NOTE: addresses should be expressed as a hex value with leading 0x.
#   - NOTE: sizes should be expressed as decimal byte count.
CY_BSP_DEVGROUP_START_FLASH_4390X=0x00000000

################################################################################
# Include device group support from recipe-make-arm-generic
################################################################################

# Make sure the BSP included locate_recipe.mk first.
$(if $(MTB_TOOLS__RECIPE_DIR),,$(error BSP needs to include locate_recipe.mk before device_groups.mk))

include $(MTB_TOOLS__RECIPE_DIR)/make/recipe/device_groups.mk
