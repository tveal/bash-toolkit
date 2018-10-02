#!/bin/bash
thisFilePath="$( dirname "$0" )"
source "$thisFilePath/../libs/pathUtils.sh"

clear
for file in $( find $( getProjectRoot )/tests/ -name "*.test.sh" ); do
    chmod +x $file
    printf "\n\e[96m==> $file <==\e[0m\n"
    . $file
done
printTestResults
