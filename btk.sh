#!/bin/bash
thisFilePath="$( dirname "${BASH_SOURCE[0]}" )"
source "$thisFilePath/libs/pathUtils.sh"
srcLibFile "menuUtils.sh"
# srcLibFile "sshUtils.sh"
srcConfigFile "menus.sh"

TRUE=0
FALSE=1
NIL='nil'

ORIG_DIR="$(pwd)"
SCRIPT_DIR="$( getActiveScriptDir )"
BASHRC=~/.bashrc
export OIFS="$IFS";

# help set
#   -e  Exit immediately if a command exits with a non-zero status.
set -e
function main() {
    keepGoing=$TRUE
    cd "$SCRIPT_DIR"
    init
    
    while keepGoing; do
        loadMenu "mainMenu" || l8r
    done
    
    cd "$ORIG_DIR"
    resetBashFunctions
    clear
}
set +e

function keepGoing() {
    return $keepGoing;
}

function init() {
    HEADER="$HEADER_MSG"
}

# Since this file must be sourced in order to set env variables,
# many functions are also defined in the env scope; Hence this hack
# to remove all env functions, then reset from the BASHRC file
function resetBashFunctions() {
    echo "Removing all functions in current shell... Count:"
    declare -F |wc -l
    for line in $(declare -F | cut -d' ' -f3); do unset -f $line; done
    echo "Removed. Function Count:"
    declare -F |wc -l
    . $BASHRC
    echo "Reset BASHRC; Function Count:"
    declare -F |wc -l
}

main "$@"
IFS="$OIFS";