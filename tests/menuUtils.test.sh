#!/bin/bash
thisFilePath="$( dirname "${BASH_SOURCE[0]}" )"
source "$thisFilePath/testUtils.sh"
source "$thisFilePath/../libs/menuUtils.sh"

function tests() {
    # Mock
    function clearTerm() {
        echo "-- overriden clearTerm function --"
    }
    # Mock
    function readSelectedOption() {
        echo "-- overriden readSelectedOption function --"
    }
    # Mock
    function pause() {
        echo "-- overriden pause function --"
    }

    describe "IFS Tests"

    TESTNAME "IFS should be bash default"
    actual="$IFS"
    actualEquals $' \t\n'
    
    TESTNAME "setOriginalIFS should set to bash default when IFS is pipe '|'"
    IFS='|'; unset OIFS;
    setOriginalIFS
    IFS=$' \t\n'; actual="$OIFS"
    actualEquals $' \t\n'
    actual="$DEFAULT_IFS"
    actualEquals $' \t\n'
    
    TESTNAME "setOriginalIFS should set to IFS when not a pipe '|'"
    IFS=';'; unset OIFS;
    setOriginalIFS
    IFS=$' \t\n'; actual="$OIFS"
    actualEquals ';'
    
    TESTNAME "setOriginalIFS should keep existing OIFS when IFS is not a pipe '|'"
    IFS=';'; OIFS='blah';
    setOriginalIFS
    IFS=$' \t\n'; actual="$OIFS"
    actualEquals 'blah'; unset OIFS
    
    TESTNAME "resetIFS should set IFS '|' to OIFS ';'"
    OIFS=';'; IFS='|'
    resetIFS
    actual="$IFS"; IFS=$' \t\n'
    actualEquals ';'
    
    TESTNAME "resetIFS should set IFS '|' to OIFS bash default"
    OIFS=$' \t\n'; IFS='|'
    resetIFS
    actual="$IFS"
    actualEquals $' \t\n'
    
    describe "Pointer Tests"
    
    TESTNAME "getMenuItmPointer should return testMenuItems pointer"
    testFunc "getMenuItmPointer" "testMenu"
    actualEquals "testMenuItems"
    
    TESTNAME "getMenuCmdPointer should return testMenuCommands pointer"
    testFunc "getMenuCmdPointer" "testMenu"
    actualEquals "testMenuCommands"
    
    TESTNAME "getMenuTitlePointer should return testMenuTitle pointer"
    testFunc "getMenuTitlePointer" "testMenu"
    actualEquals "testMenuTitle"
    
    describe "Mute Function Tests"
    
    TESTNAME "isValidMenuOption should return true for option 1 limit 2"
    testMuteFunc "isValidMenuOption" 1 2
    actualTrue
    
    TESTNAME "isValidMenuOption should return false for option 2 limit 2"
    testMuteFunc "isValidMenuOption" 2 2
    actualFalse
    
    TESTNAME "isValidMenu should return false for menu that does not exist"
    testMuteFunc "isValidMenu" "nonExistantMenu"
    actualFalse
    
    TESTNAME "isValidMenu should return true for menu that exists"
    addMenuItem "testMenu" "testItm" "testCmd"
    testMuteFunc "isValidMenu" "testMenu"
    actualTrue
}

# On The Fly tests
function otfTests() {
    describe "OTF Testing"
    
    createMenu "testMenu" "Test Menu"
    # printMenuStrs "testMenu"
    addMenuItem "testMenu" "new itm" 'echo "$(pwd)"'
    addMenuItem "testMenu" "new itm2" 'echo "ran new cmd2"'
    addMenuItem "testMenu" "new itm3" 'echo "ran new cmd3"'
    addMenuItem "testMenu" "Go to subMenu" 'loadMenu "subMenu"'
    addMenuItem "testMenu" "Go to fake menu (Doen't exist)" 'loadMenu "fakeMenu"'
    # printMenuStrs "testMenu"
    
    createMenu "subMenu" "Sub Menu"
    addMenuItem "subMenu" "Print date" 'date'
    
    HEADER="TEST HEADER"
    OPTION_PROMPT="Enter an option: "
    loadMenu "testMenu"
}

tests
# otfTests
