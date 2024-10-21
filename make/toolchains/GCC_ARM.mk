################################################################################
# \file GCC_ARM.mk
#
# \brief
# GCC ARM toolchain configuration
#
################################################################################
# \copyright
# Copyright 2021-2024 Cypress Semiconductor Corporation
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
# Macros
################################################################################

# The base path to the GCC cross compilation executables
_MTB_TOOLCHAIN_GCC_ARM__INSTALL_DIR:=$(wildcard $(call mtb_core__escaped_path,$(CY_TOOL_gcc_BASE_ABS)))
ifneq ($(_MTB_TOOLCHAIN_GCC_ARM__INSTALL_DIR),)
MTB_TOOLCHAIN_GCC_ARM__BASE_DIR:=$(call mtb_core__escaped_path,$(CY_TOOL_gcc_BASE_ABS))
endif

ifeq ($(TOOLCHAIN),GCC_ARM)
_MTB_TOOLCHAIN_GCC_ARM__USER_1_DIR :=$(wildcard $(call mtb_core__escaped_path,$(CY_COMPILER_PATH)))
ifneq ($(_MTB_TOOLCHAIN_GCC_ARM__USER_1_DIR),)
MTB_TOOLCHAIN_GCC_ARM__BASE_DIR:=$(call mtb_core__escaped_path,$(CY_COMPILER_PATH))
endif
endif

_MTB_TOOLCHAIN_GCC_ARM__USER_2_DIR :=$(wildcard $(call mtb_core__escaped_path,$(CY_COMPILER_GCC_ARM_DIR)))
ifneq ($(_MTB_TOOLCHAIN_GCC_ARM__USER_2_DIR),)
MTB_TOOLCHAIN_GCC_ARM__BASE_DIR:=$(call mtb_core__escaped_path,$(CY_COMPILER_GCC_ARM_DIR))
endif

# Elf to bin conversion tool
MTB_TOOLCHAIN_GCC_ARM__ELF2BIN:=$(MTB_TOOLCHAIN_GCC_ARM__BASE_DIR)/bin/arm-none-eabi-objcopy

# Run ELF2BIN conversion
# $(1) : artifact elf
# $(2) : artifact bin
mtb_toolchain_GCC_ARM__elf2bin:=$(MTB_TOOLCHAIN_GCC_ARM__ELF2BIN) -O binary $1 $2


################################################################################
# Tools
################################################################################


# Build tools
MTB_TOOLCHAIN_GCC_ARM__CC :=$(MTB_TOOLCHAIN_GCC_ARM__BASE_DIR)/bin/arm-none-eabi-gcc
MTB_TOOLCHAIN_GCC_ARM__CXX:=$(MTB_TOOLCHAIN_GCC_ARM__BASE_DIR)/bin/arm-none-eabi-g++
MTB_TOOLCHAIN_GCC_ARM__AS :=$(MTB_TOOLCHAIN_GCC_ARM__CC)
MTB_TOOLCHAIN_GCC_ARM__AR :=$(MTB_TOOLCHAIN_GCC_ARM__BASE_DIR)/bin/arm-none-eabi-ar
MTB_TOOLCHAIN_GCC_ARM__LD :=$(MTB_TOOLCHAIN_GCC_ARM__CXX)

MTB_TOOLCHAIN_GCC_ARM__READELF:=$(MTB_TOOLCHAIN_GCC_ARM__BASE_DIR)/bin/arm-none-eabi-readelf
MTB_TOOLCHAIN_GCC_ARM__GDB    :=$(MTB_TOOLCHAIN_GCC_ARM__BASE_DIR)/bin/arm-none-eabi-gdb
MTB_TOOLCHAIN_GCC_ARM__OBJCOPY:=$(MTB_TOOLCHAIN_GCC_ARM__BASE_DIR)/bin/arm-none-eabi-objcopy


################################################################################
# Options
################################################################################

#
# DEBUG/NDEBUG selection
#
ifeq ($(CONFIG),Debug)
_MTB_TOOLCHAIN_GCC_ARM__DEBUG_FLAG:=DEBUG
_MTB_TOOLCHAIN_GCC_ARM__OPTIMIZATION:=-Og
else ifeq ($(CONFIG),Release)
_MTB_TOOLCHAIN_GCC_ARM__DEBUG_FLAG:=NDEBUG
_MTB_TOOLCHAIN_GCC_ARM__OPTIMIZATION:=-Os
else
_MTB_TOOLCHAIN_GCC_ARM__DEBUG_FLAG:=
_MTB_TOOLCHAIN_GCC_ARM__OPTIMIZATION:=
endif

# Note: Refer to WICED for flags list -
#  43xxx_Wi-Fi/tools/makefiles/wiced_toolchain_ARM_GNU.mk
#
# Flags common to compile and link
#
_MTB_TOOLCHAIN_GCC_ARM__COMMON_FLAGS:=\
	-mthumb\
	-mthumb-interwork\
	-mlittle-endian\
	-ffunction-sections\
	-fdata-sections\
	-ffat-lto-objects\
	-g\
	-Wall\
	-pipe

_MTB_TOOLCHAIN_GCC_ARM__NEWLIBNANO:=--specs=nano.specs --specs=nosys.specs

#
# CPU core specifics
#
_MTB_TOOLCHAIN_GCC_ARM__FLAGS_CORE:=-mcpu=cortex-r4 $(_MTB_TOOLCHAIN_GCC_ARM__NEWLIBNANO)
# Insert proper floating-point command if available
_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS:=-mfloat-abi=soft

#
# Command line flags for c-files
#
MTB_TOOLCHAIN_GCC_ARM__CFLAGS:=\
	-c\
	$(_MTB_TOOLCHAIN_GCC_ARM__FLAGS_CORE)\
	$(_MTB_TOOLCHAIN_GCC_ARM__OPTIMIZATION)\
	$(_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS)\
	$(_MTB_TOOLCHAIN_GCC_ARM__COMMON_FLAGS)\
	-fno-builtin-memcmp -fno-builtin-memcpy -fno-builtin-memset

#
# Command line flags for cpp-files
#
MTB_TOOLCHAIN_GCC_ARM__CXXFLAGS:=\
	$(MTB_TOOLCHAIN_GCC_ARM__CFLAGS)\
	-fno-rtti\
	-fno-exceptions

# Command line flags for s-files
MTB_TOOLCHAIN_GCC_ARM__ASFLAGS:=\
	-c\
	$(_MTB_TOOLCHAIN_GCC_ARM__FLAGS_CORE)\
	$(_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS)\
	$(_MTB_TOOLCHAIN_GCC_ARM__COMMON_FLAGS)

# Command line flags for linking (Note: requires -nostartfiles)
MTB_TOOLCHAIN_GCC_ARM__LDFLAGS:=\
	$(_MTB_TOOLCHAIN_GCC_ARM__FLAGS_CORE)\
	$(_MTB_TOOLCHAIN_GCC_ARM__VFP_FLAGS)\
	$(_MTB_TOOLCHAIN_GCC_ARM__COMMON_FLAGS)\
	-nostartfiles\
	-Wl,--gc-sections\
	-Wl,-A,thumb -Wl,-z,max-page-size=0x10 -Wl,-z,common-page-size=0x10

# Command line flags for archiving
MTB_TOOLCHAIN_GCC_ARM__ARFLAGS=rvs

# Toolchain-specific suffixes
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_S  :=S
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_s  :=s
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_C  :=c
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_H  :=h
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_CPP:=cpp
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_CXX:=cxx
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_CC :=cc
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_HPP:=hpp
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_O  :=o
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_A  :=a
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_D  :=d
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_LS :=ld
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_MAP:=map
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_TARGET:=elf
MTB_TOOLCHAIN_GCC_ARM__SUFFIX_PROGRAM:=hex

# Toolchain specific flags
MTB_TOOLCHAIN_GCC_ARM__OUTPUT_OPTION=-o
MTB_TOOLCHAIN_GCC_ARM__ARCHIVE_LIB_OUTPUT_OPTION=-o
MTB_TOOLCHAIN_GCC_ARM__MAPFILE=-Wl,-Map,
MTB_TOOLCHAIN_GCC_ARM__STARTGROUP=-Wl,--start-group
MTB_TOOLCHAIN_GCC_ARM__ENDGROUP=-Wl,--end-group
MTB_TOOLCHAIN_GCC_ARM__LSFLAGS=-T
MTB_TOOLCHAIN_GCC_ARM__INCRSPFILE=@
MTB_TOOLCHAIN_GCC_ARM__INCRSPFILE_ASM=@
MTB_TOOLCHAIN_GCC_ARM__OBJRSPFILE=@

#
# Produce a makefile dependency rule for each input file
#
MTB_TOOLCHAIN_GCC_ARM__DEPENDENCIES=-MMD -MP -MF "$(@:.$(MTB_TOOLCHAIN_GCC_ARM__SUFFIX_O)=.$(MTB_TOOLCHAIN_GCC_ARM__SUFFIX_D))" -MT "$@"
MTB_TOOLCHAIN_GCC_ARM__EXPLICIT_DEPENDENCIES=-MMD -MP -MF "$$(@:.$(MTB_TOOLCHAIN_GCC_ARM__SUFFIX_O)=.$(MTB_TOOLCHAIN_GCC_ARM__SUFFIX_D))" -MT "$$@"

#
# Additional includes in the compilation process based on this
# toolchain
#
MTB_TOOLCHAIN_GCC_ARM__INCLUDES:=

#
# Additional libraries in the link process based on this toolchain
#

# Refer to WICED - 43xxx_Wi-Fi/WICED/platform/MCU/BCM4390x/BCM4390x.mk
MTB_TOOLCHAIN_GCC_ARM__DEFINES:=\
	RESET_ENTRY_POINT_THUMB2 \
	BCM_WICED \
	BCMCHIPID=BCM43909_CHIP_ID \
	BCMCHIPREV=2 \
	BCMDRIVER \
	NO_MALLOC_H \
	WICED_DISABLE_EXCEPTION_DUMP \
	$(_MTB_TOOLCHAIN_GCC_ARM__DEBUG_FLAG)

MTB_TOOLCHAIN_GCC_ARM__VSCODE_INTELLISENSE_MODE:=gcc-arm
MTB_TOOLCHAIN_GCC_ARM__VSCODE_PROBLEM_MATCHER:=gcc