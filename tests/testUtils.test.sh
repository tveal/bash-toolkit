#!/bin/bash
thisFilePath="$( dirname "$0" )"
source "$thisFilePath/testUtils.sh"


function tests() {
    describe 'printFunc param example'
    
    function testPrintFunc() {
        local params="$@"
        echo "blahrams=[ $params ]"
    }
    
    printFunc "testPrintFunc" 1 2 3 4 "string"
    
    describe 'Tests for string checks'
    
    TESTNAME "actualEquals should start with pass notation"
    actual='error string'
    testFunc "actualEquals" "$actual"
    actualStartsWith " + "
    
    TESTNAME "actualEquals should start with fail notation"
    actual='actual string'
    testFunc "actualEquals" "test fail"
    actualStartsWith "[!]"
    
    testname="actualStartsWith should return passing test name"
    TESTNAME "$testname"
    actual='random string'
    testFunc "actualStartsWith" 'rand'
    actualEquals " + $testname"
    
    testname="actualStartsWith should contain failing test name"
    TESTNAME "$testname"
    actual='random string'
    testFunc "actualStartsWith" 'test fail'
    actualContains "[!] ${testname}"
    
    testname="actualEndsWith should return passing test name"
    TESTNAME "$testname"
    actual='actual string'
    testFunc "actualEndsWith" 'ing'
    actualEquals " + $testname"
    
    testname="actualEndsWith should contain failing test name"
    TESTNAME "$testname"
    actual='random string'
    testFunc "actualEndsWith" 'test fail'
    actualContains "[!] $testname"
    
    testname="actualContains should return passing test name"
    TESTNAME "$testname"
    actual='actual string'
    testFunc "actualContains" 'ual s'
    actualEquals " + $testname"
    
    testname="actualContains should start with failing test name"
    TESTNAME "$testname"
    actual='random string'
    testFunc "actualContains" 'test fail'
    actualStartsWith "[!] $testname"
}

tests
