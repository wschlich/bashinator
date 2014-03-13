#!/bin/bash
## $Id: example.sh,v 1.7 2010/05/13 18:16:20 wschlich Exp wschlich $
## vim:ts=4:sw=4:tw=200:nu:ai:nowrap:
##
## Created by Wolfram Schlich <wschlich@gentoo.org>
## Licensed under the GNU GPLv3

##
## NOTES
## =====
## - you have to run 'bash -O extglob -O extdebug -n thisscriptfile' to test this script!
##

##
## bashinator basic variables
##

export __ScriptFile=${0##*/} # thisscript.sh
export __ScriptName=${__ScriptFile%.sh} # thisscript
export __ScriptPath=${0%/*}; __ScriptPath=${__ScriptPath%/} # /path/to/this/script
export __ScriptHost=$(hostname -f) # host.example.com

##
## bashinator library and config
##

## system installation
#export __BashinatorConfig="/etc/${__ScriptName}/bashinator.cfg.sh"
export __BashinatorLibrary="/usr/lib/bashinator.lib.0.sh" # APIv0
## local installation in dedicated script path
export __BashinatorConfig="${__ScriptPath}/bashinator.cfg.sh"
#export __BashinatorLibrary="${__ScriptPath}/bashinator.lib.0.sh" # APIv0
if ! source "${__BashinatorConfig}"; then
    echo "!!! FATAL: failed to source bashinator config '${__BashinatorConfig}'" 1>&2
    exit 2
fi
if ! source "${__BashinatorLibrary}"; then
    echo "!!! FATAL: failed to source bashinator library '${__BashinatorLibrary}'" 1>&2
    exit 2
fi

##
## boot bashinator
##

__boot

##
## application library and config
##

## system installation
#export ApplicationConfig="/etc/${__ScriptName}/${__ScriptName}.cfg.sh"
#export ApplicationLibrary="/usr/lib/${__ScriptName}.lib.sh"
## local installation in dedicated script path
export ApplicationConfig="${__ScriptPath}/${__ScriptName}.cfg.sh"
export ApplicationLibrary="${__ScriptPath}/${__ScriptName}.lib.sh"

## include required source files
__requireSource "${ApplicationConfig}"
__requireSource "${ApplicationLibrary}"

##
## dispatch the application with all command line arguments
##

__dispatch "${@}"
