#!/bin/bash
function TESTNAME() {
    local name="$@"
    printf -v "$( getTestNamePointer )" "$name"
}
# Prints the function name followed by it's evaluated result
# $1    name of function (as string)
# $2+   params passed to function
function printFunc() {
    local func="$1"
    shift
    local params="$@"
    
    printf "$func($params): $( $func "$params" )\n"
}

# Prints the function name and assigns the evaluated result to 'actual'
# $1    name of function (as string)
# $2+   params passed to function
function testFunc() {
    local func="$1"
    shift
    local params="$@"
    
    printf -v "$( getCurrentFuncNamePointer )" "$func"
    printf -v "$( getCurrentFuncParamsPointer )" "$params"
    actual="$( $func $params )"
}

function testMuteFunc() {
    local func="$1"
    shift
    local params="$@"
    
    local cmd="${func} ${params}"
    if $( $cmd ); then
        actual='true'
    else
        actual='false'
    fi
    printf -v "$( getCurrentFuncNamePointer )" "$func"
    printf -v "$( getCurrentFuncParamsPointer )" "$params"
}

function testThruFunc() {
    local func="$1"
    shift
    local params="$@"
    $func $params
    printf -v "$( getCurrentFuncNamePointer )" "$func"
    printf -v "$( getCurrentFuncParamsPointer )" "$params"
}

# Prints a pass or fail msg
function actualEquals() {
    local expected="$@"
    if [[ "$actual" == "$expected" ]]; then
        printPass
    else
        printFail "to equal" "$expected"
    fi
}

# Prints a pass or fail msg
function actualStartsWith() {
    local expected="$@"
    if [[ "$actual" == "$expected"* ]]; then
        printPass
    else
        printFail "to start with" "$expected"
    fi
}

# Prints a pass or fail msg
function actualEndsWith() {
    local expected="$@"
    if [[ "$actual" == *"$expected" ]]; then
        printPass
    else
        printFail "to end with" "$expected"
    fi
}

# Prints a pass or fail msg
function actualContains() {
    local expected="$@"
    if [[ "$actual" == *"$expected"* ]]; then
        printPass
    else
        printFail "to contain" "$expected"
    fi
}

# Prints pass or fail msg
function actualTrue() {
    local expected="true"
    if [[ "$actual" == "$expected" ]]; then
        printPass
    else
        printFail "to be" "$expected"
    fi
}

# Prints pass or fail msg
function actualFalse() {
    local expected="false"
    if [[ "$actual" == "$expected" ]]; then
        printPass
    else
        printFail "to be" "$expected"
    fi
}

function assertEquals() {
    local one="$1"
    local two="$2"
    if [[ "$one" == "$two" ]]; then
        printPass
    else
        printAssertFail "'$one' to equal '$two'"
    fi
}

function getDashDivider() {
    local str="$1"
    local divider=""
    local len=${#str}
    local counter=0
    while [ $counter -lt $len ]; do
        divider="${divider}-"
        let counter=$counter+1
    done
    echo "$divider"
}

function describe() {
    local desc="$1"
    local header="[ $desc ]"
    echo
    echo $header
    echo "$( getDashDivider "$header" )"
}

function getTestNamePointer() {
    echo "currentTestName"
}

function getTestName() {
    local testNamePointer="$( getTestNamePointer )"
    echo "${!testNamePointer}"
}

function getCurrentFuncNamePointer() {
    echo "currentFuncName"
}

function getCurrentFuncName() {
    local currentFuncNamePointer="$( getCurrentFuncNamePointer )"
    echo "${!currentFuncNamePointer}"
}

function getCurrentFuncParamsPointer() {
    echo "currentFuncParams"
}

function getCurrentFuncParams() {
    local currentFuncParamsPointer="$( getCurrentFuncParamsPointer )"
    echo "${!currentFuncParamsPointer}"
}

function printPass() {
    passCount=$(($passCount+1))
    echo " + $( getTestName )"
    clearTestFields
}

function printFail() {
    failCount=$(($failCount+1))
    local comparison="$1"
    local expected="$2"
    
    local redBold='\e[1;31m'
    local resetFmt='\e[0m'
    printf "[!] $( getTestName )${redBold}$( getDots )X${resetFmt}\n"
    echo "$( getTab )$( getCurrentFuncName )($( getCurrentFuncParams ))"
    echo "$( getTab )Expected '$actual' $comparison '$expected'"
    clearTestFields
}

function printAssertFail() {
    local msg="$1"
    echo "[!] $( getTestName )$( getDots )X"
    echo "$( getTab )$( getCurrentFuncName )($( getCurrentFuncParams ))"
    echo "$( getTab )Expected $msg"
    clearTestFields
}

function printTestResults() {
    local redBold='\e[1;31m'
    local greenBold='\e[1;32m'
    local resetFmt='\e[0m'
    [[ ${#passCount} == 0 ]] && passCount=0
    [[ ${#failCount} == 0 ]] && failCount=0 && redBold="$greenBold"
    echo
    printf "${greenBold}${passCount} tests passed; ${redBold}${failCount} tests failed.${resetFmt}\n"
    echo
}

function clearTestFields() {
    printf -v "$( getTestNamePointer )" " "
    printf -v "$( getCurrentFuncNamePointer )" " "
    printf -v "$( getCurrentFuncParamsPointer )" " "
}

function getDots() {
    echo '.........................'
}

function getTab() {
    echo '    '
}
