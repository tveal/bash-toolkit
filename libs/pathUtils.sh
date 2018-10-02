#!/bin/bash
# http://www.ostricher.com/2014/10/the-right-way-to-get-the-directory-of-a-bash-script/

# Gets absolute path to the script that was directly run
function getActiveScriptDir() {
    src="$0"
    while [ -h "$src" ]; do
        local dir="$( cd -P "$( dirname "$src" )" && pwd )"
        src="$( readlink "$src" )"
        [[ $src != /* ]] && $src="$dir/$src"
    done
    cd -P "$( dirname "$src" )"
    pwd
}

# Gets absolute path to the parent dir of this file
function getProjectRoot() {
    src="${BASH_SOURCE[0]}"
    while [ -h "$src" ]; do
        local dir="$( cd -P "$( dirname "$src" )" && pwd )"
        src="$( readlink "$src" )"
        [[ $src != /* ]] && $src="$dir/$src"
    done
    cd -P "$( dirname $( dirname "$src" ) )"
    pwd
}

# Gets absolute path to config dir
function getConfigDir() {
    local rootDir="$( getProjectRoot )"
    # local configDir="$rootDir/templates/config"
    # local localConfigDir="$rootDir/local/config"
    # [[ -d "$localConfigDir" ]] && configDir="$localConfigDir"
    # echo "$configDir"
    echo "$rootDir/config"
}

# Load config file from proper config dir
function srcConfigFile() {
    local file="$1"
    source "$( getConfigDir )/$file"
}

# Load lib file from proper libs dir
function srcLibFile() {
    local file="$1"
    source "$( getProjectRoot )/libs/$file"
}
