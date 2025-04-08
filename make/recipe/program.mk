################################################################################
# \file program.mk
#
# \brief
# This make file is called recursively and is used to build the
# resoures file system. It is expected to be run from the example directory.
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

# TRX header is necessary to have the image to pass the first stage bootloader in the 43907 chip. Refer to POSTBUILD
_MTB_RECIPE__OPENOCD_SYMBOL_IMG=$(_MTB_RECIPE__LAST_CONFIG_TARG_FILE)
_MTB_RECIPE__OPENOCD_PROGRAM_IMG=$(_MTB_RECIPE__LAST_CONFIG_PROG_FILE)

APP0_SECTOR_ADDRESS=0x00000000

ifeq ($(OS),Windows_NT)
_MTB_RECIPE__PROG_APP_PATH=$(shell cygpath -m --absolute $(_MTB_RECIPE__OPENOCD_PROGRAM_IMG))
else
_MTB_RECIPE__PROG_APP_PATH=$(abspath $(_MTB_RECIPE__OPENOCD_PROGRAM_IMG))
endif

ifneq ($(MTB_PROBE_SERIAL),)
_MTB_RECIPE__OPENOCD_PROBE_SERIAL:=adapter serial $(MTB_PROBE_SERIAL);
_MTB_RECIPE__JLINK_PROBE_SERIAL:=-USB $(MTB_PROBE_SERIAL)
endif

_MTB_RECIPE__PROBE_INTERFACE:=jtag
ifneq ($(MTB_PROBE_INTERFACE),)
_MTB_RECIPE__PROBE_INTERFACE:=$(MTB_PROBE_INTERFACE)
endif

ifeq ($(_MTB_RECIPE__PROBE_INTERFACE),jtag)
_MTB_RECIPE__JLINK_JTAG_CONF=-JTAGConf -1,-1
endif

CY_PROG_CMD_OPENOCD=$(CY_TOOL_openocd_EXE_ABS) \
			$(_MTB_RECIPE__OPENOCD_SCRIPTS) \
			-c "$(_MTB_RECIPE__OPENOCD_PROBE_SERIAL)" \
			-f "board/cyw9wcd1eval1.cfg" \
			-c "program $(_MTB_RECIPE__PROG_APP_PATH) $(APP0_SECTOR_ADDRESS) reset"\
			-c shutdown $(DOWNLOAD_LOG)

CY_ERASE_CMD_OPENOCD=$(CY_TOOL_openocd_EXE_ABS) \
			$(_MTB_RECIPE__OPENOCD_SCRIPTS) \
			-f "board/cyw9wcd1eval1.cfg" \
			-c "init; reset init; erase_all;"\
			-c shutdown $(DOWNLOAD_LOG)

CY_PROG_CMD_JLINK="$(MTB_CORE__JLINK_EXE)" -AutoConnect 1 -ExitOnError 1 -NoGui 1 -Device CYW43907 -If $(_MTB_RECIPE__PROBE_INTERFACE) $(_MTB_RECIPE__JLINK_PROBE_SERIAL) $(_MTB_RECIPE__JLINK_JTAG_CONF) -Speed auto -CommandFile $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/program.jlink
CY_ERASE_CMD_JLINK="$(MTB_CORE__JLINK_EXE)" -AutoConnect 1 -ExitOnError 1 -NoGui 1 -Device CYW43907 -If $(_MTB_RECIPE__PROBE_INTERFACE) $(_MTB_RECIPE__JLINK_PROBE_SERIAL) $(_MTB_RECIPE__JLINK_JTAG_CONF) -Speed auto -CommandFile $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/erase.jlink

ifeq ($(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR), JLink)
CY_ERASE_CMD=$(CY_ERASE_CMD_JLINK)
CY_PROG_CMD=$(CY_PROG_CMD_JLINK)
else
CY_ERASE_CMD=$(CY_ERASE_CMD_OPENOCD)
CY_PROG_CMD=$(CY_PROG_CMD_OPENOCD)
endif

# Generate command files required by JLink tool for programming/erasing
jlink_generate:
	sed "s|&&PROG_FILE&&|$(_MTB_RECIPE__OPENOCD_PROGRAM_IMG)|g;" $(MTB_TOOLS__RECIPE_DIR)/make/scripts/program.jlink > $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/program.jlink
	cp $(MTB_TOOLS__RECIPE_DIR)/make/scripts/erase.jlink $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/erase.jlink

erase: erase_$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)

erase_$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR): debug_interface_check
	$(MTB__NOISE)echo;\
	echo "Erasing target device... ";\
	$(CY_ERASE_CMD)

program qprogram: program_$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR)

program_$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR): memcalc

program_JLink qprogram_JLink: jlink_generate
erase_JLink: jlink_generate

program_$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR) qprogram_$(_MTB_RECIPE__PROGRAM_INTERFACE_SUBDIR): debug_interface_check
	$(MTB__NOISE)echo;\
	echo "Programming target device... ";\
	$(CY_PROG_CMD);
