#!/bin/bash

# To alter behaviour, uncomment the variables below:
#INI_IS_CASE_SENSITIVE_SECTIONS=false
#INI_IS_CASE_SENSITIVE_KEYS=false
#INI_IS_SHOW_WARNINGS=false
#INI_IS_SHOW_ERRORS=false

#Locate the absolute path of the executable with "readlink".
#Then, omit executable name with "dirname".
#Omit with "dirname" again to go one directory up.
SCRIPT_PATH="$( dirname -- "$(dirname -- "$(readlink -f -- "$0")")")"

#Include the library
# shellcheck disable=SC1091
source "${SCRIPT_PATH}/src/libsh-iniparser.sh"

ini_process_file "${SCRIPT_PATH}/demo/example.conf"

ini_display

ini_get_value "section2" "override"
echo ""

ini_get_value "Cleanup" "__Under_scores_"
echo ""