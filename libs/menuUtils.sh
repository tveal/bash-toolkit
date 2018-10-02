# create menu by name
#   $1 = "menuName" (cannot have spaces)
#   $2 = "Menu Title"
function createMenu() {
    # http://stackoverflow.com/questions/13716607/creating-a-string-variable-name-from-the-value-of-another-string
    local menuName="$1"
    local menuTitle="$2"
    printf -v $( getMenuItmPointer "$menuName" ) ""
    printf -v $( getMenuCmdPointer "$menuName" ) ""
    printf -v $( getMenuTitlePointer "$menuName" ) "$menuTitle"
}

# Add item and command to named menu
# Stores items and commands in pipe-delimited strings
#   $1 = "menuName" (cannot have spaces)
#   $2 = "Item text"
#   $3+= command to run
function addMenuItem() {
    local menuName="$1"
    local newItm="$2"
    shift 2
    local newCmd="$@"
    
    local itmPointer="$( getMenuItmPointer "$menuName" )"
    local cmdPointer="$( getMenuCmdPointer "$menuName" )"
    local itmVal="${!itmPointer}"
    local cmdVal="${!cmdPointer}"
    
    printf -v $itmPointer "${itmVal}|${newItm}"
    printf -v $cmdPointer "${cmdVal}|${newCmd}"
}

# Run the named menu; Clears the terminal, prints the menu, prompts for a option,
# then executes the selected option.
#   $1 = "menuName" (cannot have spaces)
function loadMenu() {
    local menuName="$1"
    
    if isValidMenu "$menuName"; then
        local titlePointer="$( getMenuTitlePointer "$menuName" )"
        local itmPointer="$( getMenuItmPointer "$menuName" )"
        local cmdPointer="$( getMenuCmdPointer "$menuName" )"
        local itmVal="${!itmPointer}"
        local cmdVal="${!cmdPointer}"
        
        # Change IFS (Internal Field Separator) to pipe so arrays can be be processed properly
        # http://timmurphy.org/2012/03/09/convert-a-delimited-string-into-an-array-in-bash/
        IFS='|';
        local itmArray=($itmVal)
        local cmdArray=($cmdVal)
        
        # Print Menu
        clearTerm
        echo "$HEADER"
        # getActiveServerGroupAndTitle
        shouldShowZeroNav "$menuName" && printZeroNav
        echo "  ${!titlePointer}"
        for ((i=1; i < ${#itmArray[@]}; i++)); do
            echo "    $i - ${itmArray[$i]}"
        done
        readSelectedOption
        
        # Execute selected option
        clearTerm
        if $( isValidMenuOption "$selectedOption" "${#cmdArray[@]}" ); then
            eval "${cmdArray[$selectedOption]}"
        else
            echo "Invalid option selected"
            pause
        fi
        
        # Restore IFS to it's original state
        # OIFS is set at highest scope in these scripts so that iterations don't override it
        IFS="$OIFS";
    else
        echo "Oops! The menu ($menuName) does not exist :("
        echo "Please check your config for this menu"
        pause
        return 1
    fi
}

function shouldShowZeroNav() {
    local menuName="$1"
    if [[ "$menuName" == "mainMenu" ]]; then
        return 1
    else
        return 0
    fi
}

# Checks to see if named menu has any items
#   $1 = "menuName" (cannot have spaces)
function isValidMenu() {
    local menuName="$1"
    
    local itmPointer="$( getMenuItmPointer "$menuName" )"
    local itmVal="${!itmPointer}"
    if [[ ${#itmVal} -gt 0 ]]; then
        return 0 # true
    else
        return 1 # false
    fi
}

# Checks to see if ( opt is a number && opt < lim )
#   $1 = option
#   $2 = maxVal (size of array)
function isValidMenuOption() {
    local opt="$1"
    local lim="$2"
    if ! [[ "$opt" =~ ^[0-9]+$ && $opt -lt $lim ]]; then
        return 1
    else
        return 0
    fi
}

function printMenuStrs() {
    local menuName="$1"
    local itmPointer="$( getMenuItmPointer "$menuName" )"
    local cmdPointer="$( getMenuCmdPointer "$menuName" )"
    local titlePointer="$( getMenuTitlePointer "$menuName" )"
    echo "${itmPointer}: ${!itmPointer}"
    echo "${cmdPointer}: ${!cmdPointer}"
    echo "${titlePointer}: ${!titlePointer}"
}

function getMenuItmPointer() {
    local menuName="$1"
    echo "${menuName}Items"
}

function getMenuCmdPointer() {
    local menuName="$1"
    echo "${menuName}Commands"
}

function getMenuTitlePointer() {
    local menuName="$1"
    echo "${menuName}Title"
}

function printZeroNav() {
    echo "    0 - back to main menu"
}

function l8r() {
    echo "Goodbye!"
    keepGoing=1
    clearTerm
}

function pause() {
    read -p "Press Enter to continue..."
}

function readSelectedOption() {
    read -p "  Choose an option: " selectedOption
}

function clearTerm() {
    clear
}
