# 4390X devices GNU make Build System Release Notes
This repo provides the build recipe make files and scripts for building and programming 4390X devices applications. Builds can be run either through a command-line interface (CLI) or through the Eclipse IDE for ModusToolbox.

### What's Included?
The this release of the 4390X devices GNU make build recipe includes complete support for building, programming, and debugging 4390X devices application projects. It is expected that a code example contains a top level make file for itself and references a Board Support Package (BSP) that defines specifics items, like the 4390X part, for the target board. Supported functionality includes the following:
* Supported operations:
    * Build
    * Program
    * Debug
    * IDE Integration (Eclipse, VS Code)
    * BSP Generation
* Supported toolchains:
    * GCC

This also includes the getlibs.bash script that can be used directly, or via the make target to download additional git repo based libraries for the application.

### What Changed?
#### v1.0.0
* Initial release

### Product/Asset Specific Instructions
Builds require that the ModusToolbox tools be installed on your machine. This comes with the ModusToolbox install. On Windows machines, it is recommended that CLI builds be executed using the Cygwin.bat located in ModusToolBox/tools_x.y/modus-shell install directory. This guarantees a consistent shell environment for your builds.

To list the build options, run the "help" target by typing "make help" in CLI. For a verbose documentation on a specific subject type "make help CY_HELP={variable/target}", where "variable" or "target" is one of the listed make variables or targets.

### Supported Software and Tools
This version of the CAT4 build system was validated for compatibility with the following Software and Tools:

| Software and Tools                        | Version |
| :---                                      | :----:  |
| ModusToolbox Software Environment         | 2.4     |
| GCC Compiler                              | 9.2     |

Minimum required ModusToolbox Software Environment: v2.4

### More information
Use the following links for more information, as needed:
* [Cypress Semiconductor, an Infineon Technologies Company](http://www.cypress.com)
* [Cypress Semiconductor GitHub](https://github.com/cypresssemiconductorco)
* [ModusToolbox](https://www.cypress.com/products/modustoolbox-software-environment)

---
© Cypress Semiconductor Corporation, 2019-2021.