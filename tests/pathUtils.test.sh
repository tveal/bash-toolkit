#!/bin/bash
thisFilePath="$( dirname "$0" )"
source "$thisFilePath/testUtils.sh"
source "$thisFilePath/../libs/pathUtils.sh"

function tests() {
    describe 'Absolute paths'
    
    printFunc "getActiveScriptDir"
    printFunc "getProjectRoot"
    printFunc "getConfigDir"
    
    describe 'Tests for Absolute paths'
    
    TESTNAME "getActiveScriptDir should end with 'tests'"
    testFunc "getActiveScriptDir"
    actualEndsWith "tests"
    
    TESTNAME "getProjectRoot should end with 'bash-toolkit'"
    testFunc "getProjectRoot"
    actualEndsWith "bash-toolkit"
    
    TESTNAME "getConfigDir should end with 'config'"
    testFunc "getConfigDir"
    actualEndsWith "config"
}

tests
