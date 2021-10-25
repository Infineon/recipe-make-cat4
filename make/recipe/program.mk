################################################################################
# \file program.mk
#
# \brief
# This make file is called recursively and is used to build the
# resoures file system. It is expected to be run from the example directory.
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

#CY_OPENOCD_SYMBOL_IMG=$(CY_CONFIG_DIR)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_TARGET)
CY_OPENOCD_PROGRAM_IMG=$(CY_CONFIG_DIR)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_PROGRAM)
# TRX header is necessary to have the image to pass the first stage bootloader in the 43907 chip. Refer to POSTBUILD
CY_OPENOCD_SYMBOL_IMG=$(CY_CONFIG_DIR)/$(APPNAME).trx.bin

################################################################################
#
# Note: This was pieced together from MTB 1.0 ES10.3 programming flow.
# 		1. C&P to browser - https://home.ore.cypress.com/#
#		2. Click 'software repository' on the right hand side
#		3. Download and install "ModusToolbox 1.0 ES10.3 (Build 2315)"
#
# Reference:
# "--norc" "--noprofile" "${cy_tools_path:wiced-scripts}/program.bash" 
# "-kit" 
# "CYW943907AEVAL1F" 
# "-shell" "${cy_tools_path:modus-shell}" 
# "-scripts" "${cy_tools_path:wiced-scripts}" 
# "-openocd" "${cy_tools_path:openocd}" 
# "-dct" "${workspace_loc:/WiFiScanner_dct}/${config_name:WiFiScanner_dct}/WiFiScanner_dct.bin" 
# "-filesystem" "${workspace_loc:/WiFiScanner_resources}/filesystem.bin"
# "-lut" "${workspace_loc:/WiFiScanner_lut}/${config_name:WiFiScanner_lut}/WiFiScanner_lut.bin" 
# "-boot" "${workspace_loc:/WiFiScanner_bootloader}/${config_name:WiFiScanner_bootloader}/WiFiScanner_bootloader.trx.bin" 
# "-app0" "${workspace_loc:/WiFiScanner_mainapp}/${config_name:WiFiScanner_mainapp}/WiFiScanner_mainapp.stripped.elf" 
# "-flashloader" "${cy_sdk_install_dir}/libraries/wiced_base-1.0/components/WIFI-SDK/platforms/CYW943907AEVAL1F/sflash_write.elf" 
# "-reset" 
# "-gdbinit" "${workspace_loc:/WiFiScanner_lut}/.gdbinit"
#
################################################################################

CY_OPENOCD_EXE=$(CY_INTERNAL_TOOL_openocd_EXE)

APP0_SECTOR_ADDRESS=0x00000000

ifeq ($(OS),Windows_NT)
CY_PROG_APP_PATH=$(shell cygpath -m --absolute $(CY_OPENOCD_SYMBOL_IMG))
else
CY_PROG_APP_PATH=$(abspath $(CY_OPENOCD_SYMBOL_IMG))
endif

CY_PROG_CMD=$(CY_OPENOCD_EXE) \
			$(CY_OPENOCD_SCRIPTS) \
			-f "board/cyw9wcd1eval1.cfg" \
			-c "program $(CY_PROG_APP_PATH) $(APP0_SECTOR_ADDRESS) reset"\
			-c shutdown $(DOWNLOAD_LOG)

CY_ERASE_CMD=$(CY_OPENOCD_EXE) \
			$(CY_OPENOCD_SCRIPTS) \
			-f "board/cyw9wcd1eval1.cfg" \
			-c "init; reset init; erase_all;"\
			-c shutdown $(DOWNLOAD_LOG)

erase:
	$(CY_NOISE)echo;\
	echo "Erasing target device... ";\
	$(CY_ERASE_CMD)

program: build qprogram

qprogram: memcalc
	$(CY_NOISE)echo;\
	echo "Programming target device... ";\
	$(CY_PROG_CMD);