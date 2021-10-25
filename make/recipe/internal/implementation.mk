
################################################################################
# Linker script verification
################################################################################

# NOTE: This had to be deferred from device_groups.mk. See that file for details.

# Make sure linker script was found for selected device group:
$(if \
    $(_CY_RECIPE_ARM_GENERIC_LINKER_SCRIPT),\
    ,\
    $(call _CY_RECIPE_ARM_GENERIC_DEVGROUP_ERROR,linker script not set in 'CY_BSP_DEVGROUP_LINKER_SCRIPT_$(_CY_RECIPE_ARM_GENERIC_ACTIVE_DEVICE_GROUP'))\
)

# Construct full path to the linker script we'll actually use (users, or default for device group)
_CY_RECIPE_ARM_GENERIC_LINKER_SCRIPT:=$(CY_TARGET_DIR)/$(_CY_RECIPE_ARM_GENERIC_LINKER_SCRIPT)

# Make sure linker script actually exists at expected location
$(if \
    $(wildcard $(_CY_RECIPE_ARM_GENERIC_LINKER_SCRIPT)),\
    ,\
    $(call _CY_RECIPE_ARM_GENERIC_DEVGROUP_ERROR,unable to find linker script on disk '$(_CY_RECIPE_ARM_GENERIC_LINKER_SCRIPT)')\
)

# Check if user has overridden the linker script
_CY_RECIPE_ARM_GENERIC_LINKER_SCRIPT:=$(if $(LINKER_SCRIPT),$(LINKER_SCRIPT),$(_CY_RECIPE_ARM_GENERIC_LINKER_SCRIPT))


################################################################################
# Final flags used to compile, assemble, and link (excludes defines and includes)
################################################################################

# C compiler flags
#   - CFLAGS                -- set by user in Makefile.
#   - CY_BSP_CFLAGS         -- set by BSP built on the generic ARM recipe.
#   - CY_TOOLCHAIN_CFLAGS   -- set by users selected toolchain.
_CY_RECIPE_ARM_GENERIC_CFLAGS=\
    $(CFLAGS) \
    $(CY_BSP_CFLAGS) \
    $(CY_TOOLCHAIN_CFLAGS)

# C++ compiler flags
#   - CXXFLAGS              -- set by user in Makefile.
#   - CY_BSP_CXXFLAGS       -- set by BSP built on generic ARM recipe.
#   - CY_TOOLCHAIN_CXXFLAGS -- set by users selected toolchain.
_CY_RECIPE_ARM_GENERIC_CXXFLAGS=\
    $(CXXFLAGS) \
    $(CY_BSP_CXXFLAGS) \
    $(CY_TOOLCHAIN_CXXFLAGS)

# Assembler flags
#   - ASFLAGS               -- set by user in Makefile.
#   - CY_BSP_ASFLAG         -- set by BSP built on generic ARM recipe.
#   - CY_TOOLCHAIN_ASFLAGS  -- set by users selected toolchain.
_CY_RECIPE_ARM_GENERIC_ASFLAGS=\
    $(ASFLAGS) \
    $(CY_BSP_ASFLAGS) \
    $(CY_TOOLCHAIN_ASFLAGS)

# Linker flags
#   - LDFLAGS               -- set by user in Makefile.
#   - CY_BSP_LDFLAGS        -- set by BSP built on generic ARM recipe.
#   - CY_TOOLCHAIN_LDFLAGS  -- set by users selected toolchain.
#   - CY_TOOLCHAIN_LSFLAGS/ -- some toolchains use linker scripts
#     LINKER_SCRIPT         -- others just pass a pile of args to the linker.
_CY_RECIPE_ARM_GENERIC_LDFLAGS=\
    $(LDFLAGS) \
    $(CY_BSP_LDFLAGS) \
    $(CY_TOOLCHAIN_LDFLAGS) \
    $(CY_TOOLCHAIN_LSFLAGS)$(_CY_RECIPE_ARM_GENERIC_LINKER_SCRIPT)

# Archiver flags
#   - ARFLAGS               -- set by user in Makefile.
#   - CY_BSP_ARFLAGS        -- set by BSP built on generic ARM recipe.
#   - CY_TOOLCHAIN_ARFLAGS  -- set by users selected toolchain.
_CY_RECIPE_ARM_GENERIC_ARFLAGS=\
    $(ARFLAGS) \
    $(CY_BSP_ARFLAGS) \
    $(CY_TOOLCHAIN_ARFLAGS)


################################################################################
# Includes
################################################################################

# Include directories
#   - INCLUDES                                -- set by user in Makefile.
#   - _CY_RECIPE_ARM_GENERIC_DEVICE_INCLUDES  -- include dirs for selected device.
#   - CY_BSP_INCLUDES                         -- set by BSP built on generic ARM recipe.
#   - CY_SEARCH_APP_INCLUDES                  -- found by autodiscovery.
#   - CY_TOOLCHAIN_INCLUDES                   -- set by users selected toolchain.
_CY_RECIPE_ARM_GENERIC_INCLUDES=\
	$(addprefix -I,$(INCLUDES))\
	$(addprefix -I,$(_CY_RECIPE_ARM_GENERIC_DEVICE_INCLUDES))\
	$(addprefix -I,$(CY_BSP_INCLUDES))\
	$(addprefix -I,$(CY_SEARCH_APP_INCLUDES))\
	$(addprefix -I,$(CY_TOOLCHAIN_INCLUDES))


################################################################################
# Defines
################################################################################

# Core defines required by the ModusToolbox system.
#   - selected device   :: -D$(DEVICE) and -DCY_TARGET_DEVICE=$(DEVICE)
#   - selected BSP      :: -DTARGET_$(TARGET) and -DCY_TARGET_BOARD=$(TARGET)
#   - active components :: -DCOMPONENT_$(component name)
#
#   - NOTE: hyphens are converted to underscores in DEVICE, TARGET, and component names.
_CY_RECIPE_ARM_GENERIC_CORE_DEFINES:=\
	$(subst -,_,$(DEVICE))\
	CY_TARGET_DEVICE=$(subst -,_,$(DEVICE))\
	TARGET_$(subst -,_,$(TARGET))\
	CY_TARGET_BOARD=$(subst -,_,$(TARGET))\
	$(addprefix COMPONENT_,$(subst -,_,$(CY_COMPONENT_LIST)))

# Add -D to defines specified by user in DEFINES in their Makefile.
_CY_RECIPE_ARM_GENERIC_USER_DEFINES:=$(DEFINES)
 
# Name of app or library (hyphens converted to underscores).
ifneq ($(LIBNAME),)
_CY_RECIPE_ARM_GENERIC_USER_NAME=CY_LIBNAME_$(subst -,_,$(LIBNAME))
else
_CY_RECIPE_ARM_GENERIC_USER_NAME=CY_APPNAME_$(subst -,_,$(APPNAME))
endif

# The CY_TOOLCHAIN_DEBUG_FLAG is stored as a toolchain argument, even though it's just setting a define.
# Normalize it here, so defines are handled consistently.
_CY_RECIPE_ARM_GENERIC_TOOLCHAIN_DEFINES:=$(patsubst -D%,%,$(CY_TOOLCHAIN_DEBUG_FLAG)) $(CY_TOOLCHAIN_DEFINES)

_CY_RECIPE_ARM_GENERIC_DEFINES:=\
    $(_CY_RECIPE_ARM_GENERIC_USER_DEFINES) \
    $(_CY_RECIPE_ARM_GENERIC_USER_NAME)\
    $(_CY_RECIPE_ARM_GENERIC_CORE_DEFINES) \
    $(_CY_RECIPE_ARM_GENERIC_DEVICE_DEFINES) \
    $(_CY_RECIPE_ARM_GENERIC_TOOLCHAIN_DEFINES) \
    $(CY_BSP_DEFINES)



################################################################################
# Code files
################################################################################

# Source code files to build.
#   - SOURCE                -- source code added by user in Makefile (ignored here, it's handled directly by core-make).
#   - CY_BSP_SOURCE         -- source code forcibly added by BSP (bypass autodiscovery).
#   - CY_SEARCH_APP_SOURCE  -- source code found by autodiscovery.
_CY_RECIPE_ARM_GENERIC_SOURCE=\
	$(CY_BSP_SOURCE)\
	$(CY_SEARCH_APP_SOURCE)

# Precompiled code/libraries to link in
#   - LDLIBS                -- libraries added by user in Makefile.
#   - CY_BSP_LIBS           -- libraries added by BSP (bypass autodiscovery).
#   - CY_SEARCH_APP_LIBS)   -- libraries found by autodiscovery.
_CY_RECIPE_ARM_GENERIC_LIBS=\
	$(LDLIBS)\
	$(CY_BSP_LIBS)\
	$(CY_SEARCH_APP_LIBS)


################################################################################
# Libraries
################################################################################
_CY_RECIPE_ARM_GENERIC_LIBS=$(LDLIBS) $(CY_SEARCH_APP_LIBS) $(CY_BSP_LIBS)

################################################################################
# Memory Consumption
################################################################################

# Use GCC readelf as installed with ModusToolbox tools package.
CY_RECIPE_READELF=$(CY_INTERNAL_TOOL_arm-none-eabi-readelf_EXE)

# Not supported with A_Clang toolchain.
ifeq ($(TOOLCHAIN),A_Clang)
CY_GEN_READELF=
CY_MEMORY_CALC=
else
CY_GEN_READELF=$(CY_RECIPE_READELF) -Sl $(CY_CONFIG_DIR)/$(APPNAME).$(CY_TOOLCHAIN_SUFFIX_TARGET) > $(CY_CONFIG_DIR)/$(APPNAME).readelf
CY_MEM_CALC=\
	bash --norc --noprofile\
	$(CY_BASELIB_CORE_PATH)/make/scripts/memcalc.bash\
	$(CY_CONFIG_DIR)/$(APPNAME).readelf\
	$(CY_MEMORY_FLASH)\
	$(CY_MEMORY_SRAM)\
	$(CY_START_FLASH)\
	$(CY_START_SRAM)
endif


################################################################################
# Resource files
################################################################################

# These are specific to the core-make resource system and should be left alone.
#
CY_RECIPE_RESOURCE_FILES=$(CY_SEARCH_RESOURCE_FILES)
_CY_RECIPE_GENERATED_FROM_RESOURCES:=$(addprefix $(CY_GENERATED_DIR)/,$(addsuffix .$(CY_TOOLCHAIN_SUFFIX_C),\
					$(basename $(notdir $(subst .,_,$(CY_SEARCH_RESOURCE_FILES))))))
CY_RECIPE_GENSRC=CY_RECIPE_GENSRC=\
	bash --norc --noprofile\
	$(CY_BASELIB_CeRE_PATH)/make/scripts/genresources.bash\
	$(CY_BASELIB_CORE_PATH)/make/scripts\
	$(CY_GENERATED_DIR)/resources.cyrsc\
	$(CY_INTERNAL_APP_PATH)\
	$(CY_GENERATED_DIR)\
	"MEM"

#   - NOTE: this tells core-make the names of any source files generated during the build process.
#   - NOTE: generated source files should be written to CY_GENERATED_DIR.
#   - NOTE: this must include source files genersated for resource files (this recipe stores 
#           them in _CY_RECIPE_GENERATED_FROM_RESOURCES).
#   - NOTE: any source files listedin CY_RECIPE_ARM_GENERIC_GENERATED need a make rule whose action
#           converts the input files to given source file.
_CY_RECIPE_ARM_GENERIC_GENERATED:=$(CY_BSP_GENERATED) $(_CY_RECIPE_GENERATED_FROM_RESOURCES)

memcalc:
ifeq ($(LIBNAME),)
	$(CY_NOISE)echo Calculating memory consumption: $(DEVICE) $(TOOLCHAIN) $(CY_TOOLCHAIN_OPTIMIZATION)
	$(CY_NOISE)echo
	$(CY_NOISE)$(CY_GEN_READELF)
	$(CY_NOISE)$(CY_MEM_CALC)
	$(CY_NOISE)echo
endif

#
# Identify the phony targets
#
.PHONY: memcalc
