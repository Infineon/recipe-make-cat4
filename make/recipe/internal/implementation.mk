
################################################################################
# Linker script verification
################################################################################

# NOTE: This had to be deferred from device_groups.mk. See that file for details.

# Make sure linker script was found for selected device group:
$(if \
    $(_MTB_RECIPE__ARM_GENERIC_LINKER_SCRIPT),\
    ,\
    $(call _MTB_RECIPE__ARM_GENERIC_DEVGROUP_ERROR,linker script not set in 'CY_BSP_DEVGROUP_LINKER_SCRIPT_$(_MTB_RECIPE__ARM_GENERIC_ACTIVE_DEVICE_GROUP'))\
)

# Construct full path to the linker script we'll actually use (users, or default for device group)
_MTB_RECIPE__ARM_GENERIC_LINKER_SCRIPT:=$(MTB_TOOLS__TARGET_DIR)/$(_MTB_RECIPE__ARM_GENERIC_LINKER_SCRIPT)

# Make sure linker script actually exists at expected location
$(if \
    $(wildcard $(_MTB_RECIPE__ARM_GENERIC_LINKER_SCRIPT)),\
    ,\
    $(call _MTB_RECIPE__ARM_GENERIC_DEVGROUP_ERROR,unable to find linker script on disk '$(_MTB_RECIPE__ARM_GENERIC_LINKER_SCRIPT)')\
)

# Check if user has overridden the linker script
_MTB_RECIPE__ARM_GENERIC_LINKER_SCRIPT:=$(if $(LINKER_SCRIPT),$(LINKER_SCRIPT),$(_MTB_RECIPE__ARM_GENERIC_LINKER_SCRIPT))


################################################################################
# Final flags used to compile, assemble, and link (excludes defines and includes)
################################################################################

# C compiler flags
#   - CFLAGS                -- set by user in Makefile.
#   - MTB_TOOLCHAIN_CFLAGS   -- set by users selected toolchain.
_MTB_RECIPE__ARM_GENERIC_CFLAGS=\
    $(CFLAGS) \
    $(MTB_TOOLCHAIN_$(TOOLCHAIN)__CFLAGS)

# C++ compiler flags
#   - CXXFLAGS              -- set by user in Makefile.
#   - CY_BSP_CXXFLAGS       -- set by BSP built on generic ARM recipe.
#   - MTB_TOOLCHAIN_CXXFLAGS -- set by users selected toolchain.
_MTB_RECIPE__ARM_GENERIC_CXXFLAGS=\
    $(CXXFLAGS) \
    $(MTB_TOOLCHAIN_$(TOOLCHAIN)__CXXFLAGS)

# Assembler flags
#   - ASFLAGS               -- set by user in Makefile.
#   - CY_BSP_ASFLAG         -- set by BSP built on generic ARM recipe.
#   - MTB_TOOLCHAIN_ASFLAGS  -- set by users selected toolchain.
_MTB_RECIPE__ARM_GENERIC_ASFLAGS=\
    $(ASFLAGS) \
    $(MTB_TOOLCHAIN_$(TOOLCHAIN)__ASFLAGS)

# Linker flags
#   - LDFLAGS               -- set by user in Makefile.
#   - CY_BSP_LDFLAGS        -- set by BSP built on generic ARM recipe.
#   - MTB_TOOLCHAIN_LDFLAGS  -- set by users selected toolchain.
#   - MTB_TOOLCHAIN_LSFLAGS/ -- some toolchains use linker scripts
#     LINKER_SCRIPT         -- others just pass a pile of args to the linker.
_MTB_RECIPE__ARM_GENERIC_LDFLAGS=\
    $(LDFLAGS) \
    $(MTB_TOOLCHAIN_$(TOOLCHAIN)__LDFLAGS) \
    $(MTB_TOOLCHAIN_$(TOOLCHAIN)__LSFLAGS)$(_MTB_RECIPE__ARM_GENERIC_LINKER_SCRIPT)

# Archiver flags
#   - ARFLAGS               -- set by user in Makefile.
#   - CY_BSP_ARFLAGS        -- set by BSP built on generic ARM recipe.
#   - MTB_TOOLCHAIN_ARFLAGS  -- set by users selected toolchain.
_MTB_RECIPE__ARM_GENERIC_ARFLAGS=\
    $(ARFLAGS) \
    $(MTB_TOOLCHAIN_$(TOOLCHAIN)__ARFLAGS)


################################################################################
# Includes
################################################################################

# Include directories
#   - INCLUDES                                -- set by user in Makefile.
#   - _MTB_RECIPE__ARM_GENERIC_DEVICE_INCLUDES  -- include dirs for selected device.
#   - CY_BSP_INCLUDES                         -- set by BSP built on generic ARM recipe.
#   - MTB_CORE__SEARCH_APP_INCLUDES                  -- found by autodiscovery.
#   - MTB_TOOLCHAIN_INCLUDES                   -- set by users selected toolchain.
_MTB_RECIPE__ARM_GENERIC_INCLUDES=\
	$(addprefix -I,$(INCLUDES))\
	$(addprefix -I,$(_MTB_RECIPE__ARM_GENERIC_DEVICE_INCLUDES))\
	$(addprefix -I,$(MTB_CORE__SEARCH_APP_INCLUDES))\
	$(addprefix -I,$(MTB_RECIPE__TOOLCHAIN_INCLUDES))


################################################################################
# Defines
################################################################################

# Core defines required by the ModusToolbox system.
#   - selected device   :: -D$(DEVICE)
#   - selected BSP      :: -DTARGET_$(TARGET) and -DCY_TARGET_BOARD=$(TARGET)
#   - active components :: -DCOMPONENT_$(component name)
#
#   - NOTE: hyphens are converted to underscores in DEVICE, TARGET, and component names.

#
# Component list
#
# Note: _MTB_RECIPE__DEFAULT_COMPONENT is needed as DISABLE_COMPONENTS cannot be empty
_MTB_RECIPE__COMPONENT_LIST=$(filter-out $(DISABLE_COMPONENTS) _MTB_RECIPE__DEFAULT_COMPONENT,$(MTB_CORE__FULL_COMPONENT_LIST))

_MTB_RECIPE__ARM_GENERIC_CORE_DEFINES:=\
	$(subst -,_,$(DEVICE))\
	TARGET_$(subst -,_,$(TARGET))\
	CY_TARGET_BOARD=$(subst -,_,$(TARGET))\
	$(addprefix COMPONENT_,$(subst -,_,$(_MTB_RECIPE__COMPONENT_LIST)))

# Add -D to defines specified by user in DEFINES in their Makefile.
_MTB_RECIPE__ARM_GENERIC_USER_DEFINES:=$(DEFINES)

# Name of app or library (hyphens converted to underscores).
ifneq ($(LIBNAME),)
_MTB_RECIPE__ARM_GENERIC_USER_NAME=CY_LIBNAME_$(subst -,_,$(LIBNAME))
else
_MTB_RECIPE__ARM_GENERIC_USER_NAME=CY_APPNAME_$(subst -,_,$(APPNAME))
endif

_MTB_RECIPE__ARM_GENERIC_TOOLCHAIN_DEFINES:=$(MTB_RECIPE__TOOLCHAIN_DEFINES)

__MTB_RECIPE__ARM_GENERIC_DEFINES:=\
    $(_MTB_RECIPE__ARM_GENERIC_USER_DEFINES) \
    $(_MTB_RECIPE__ARM_GENERIC_USER_NAME)\
    $(_MTB_RECIPE__ARM_GENERIC_CORE_DEFINES) \
    $(_MTB_RECIPE__ARM_GENERIC_DEVICE_DEFINES) \
    $(_MTB_RECIPE__ARM_GENERIC_TOOLCHAIN_DEFINES)



################################################################################
# Code files
################################################################################

# Source code files to build.
#   - SOURCE                -- source code added by user in Makefile (ignored here, it's handled directly by core-make).
#   - CY_BSP_SOURCE         -- source code forcibly added by BSP (bypass autodiscovery).
#   - MTB_CORE__SEARCH_APP_SOURCE  -- source code found by autodiscovery.
_MTB_RECIPE__ARM_GENERIC_SOURCE=$(MTB_CORE__SEARCH_APP_SOURCE)

# Precompiled code/libraries to link in
#   - LDLIBS                -- libraries added by user in Makefile.
#   - CY_BSP_LIBS           -- libraries added by BSP (bypass autodiscovery).
#   - MTB_CORE__SEARCH_APP_LIBS)   -- libraries found by autodiscovery.
_MTB_RECIPE__ARM_GENERIC_LIBS=\
	$(LDLIBS)\
	$(MTB_CORE__SEARCH_APP_LIBS)


################################################################################
# Libraries
################################################################################
_MTB_RECIPE__ARM_GENERIC_LIBS=$(LDLIBS) $(MTB_CORE__SEARCH_APP_LIBS)

################################################################################
# Memory Consumption
################################################################################

# Use GCC readelf as installed with ModusToolbox tools package.
_MTB_RECIPE__READELF=$(MTB_TOOLCHAIN_GCC_ARM__READELF)

# Not supported with A_Clang toolchain.
ifeq ($(TOOLCHAIN),A_Clang)
_MTB_RECIPE__GEN_READELF=
_MTB_RECIPE__MEMORY_CAL=
else
_MTB_RECIPE__GEN_READELF=$(_MTB_RECIPE__READELF) -Sl $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).$(MTB_RECIPE__SUFFIX_TARGET) > $(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).readelf
_MTB_RECIPE__MEM_CALC=\
	bash --norc --noprofile\
	$(MTB_TOOLS__CORE_DIR)/make/scripts/memcalc.bash\
	$(MTB_TOOLS__OUTPUT_CONFIG_DIR)/$(APPNAME).readelf\
	$(_MTB_RECIPE__DEVICE_FLASH_KB)\
	$(_MTB_RECIPE__START_FLASH)
endif


################################################################################
# Resource files
################################################################################

# These are specific to the core-make resource system and should be left alone.
#
_MTB_RECIPE__RESOURCE_FILES=$(CY_SEARCH_RESOURCE_FILES)
_MTB_RECIPE__GENERATED_FROM_RESOURCES:=$(addprefix $(MTB_TOOLS__OUTPUT_GENERATED_DIR)/,$(addsuffix .$(MTB_TOOLCHAIN_SUFFIX_C),\
					$(basename $(notdir $(subst .,_,$(CY_SEARCH_RESOURCE_FILES))))))
_MTB_RECIPE__GENSRC=\
	bash --norc --noprofile\
	$(MTB_TOOLS__CORE_DIR)/make/scripts/genresources.bash\
	$(MTB_TOOLS__TARGET_DIR)/make/scripts\
	$(MTB_TOOLS__OUTPUT_GENERATED_DIR)/resources.cyrsc\
	$(MTB_TOOLS__OUTPUT_GENERATED_DIR)\
	"MEM"

#   - NOTE: this tells core-make the names of any source files generated during the build process.
#   - NOTE: generated source files should be written to MTB_TOOLS__OUTPUT_GENERATED_DIR.
#   - NOTE: this must include source files genersated for resource files (this recipe stores
#           them in _MTB_RECIPE__GENERATED_FROM_RESOURCES).
_MTB_RECIPE__ARM_GENERIC_GENERATED:=$(CY_BSP_GENERATED) $(_MTB_RECIPE__GENERATED_FROM_RESOURCES)

memcalc:
ifeq ($(LIBNAME),)
	$(MTB__NOISE)echo Calculating memory consumption: $(DEVICE) $(TOOLCHAIN) $(MTB_TOOLCHAIN_OPTIMIZATION)
	$(MTB__NOISE)echo
	$(MTB__NOISE)$(_MTB_RECIPE__GEN_READELF)
	$(MTB__NOISE)$(_MTB_RECIPE__MEM_CALC)
	$(MTB__NOISE)echo
endif

#
# Identify the phony targets
#
.PHONY: memcalc
