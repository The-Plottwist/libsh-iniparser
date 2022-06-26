#!/bin/bash

# To alter behaviour, uncomment the variables below:
#INI_IS_CASE_SENSITIVE_SECTIONS=false
#INI_IS_CASE_SENSITIVE_KEYS=false
#INI_IS_SHOW_WARNINGS=false
#INI_IS_SHOW_ERRORS=false
#INI_IS_RAW_MODE=true

#Locate the absolute path of the executable with "readlink".
#Then, omit executable name with "dirname".
#Omit with "dirname" again to go one directory up.
SCRIPT_PATH="$( dirname -- "$(dirname -- "$(readlink -f -- "$0")")")"

#Include the library
# shellcheck disable=SC1091
source "${SCRIPT_PATH}/src/libsh-iniparser.sh"

ini_process_file "${SCRIPT_PATH}/demo/example.conf"

echo ""
echo "::PROCESSED FILE::"

ini_display

echo ""
echo "::ENTIRE SECTION::"
ini_display_by_section "Fallback"

echo "::ONLY KEYS (Additionals)::"
ini_display_keys "Additionals"

echo ""
echo "::ONLY VALUES (Additionals)::"
ini_display_values "Additionals"

echo ""
echo "::SPECIFIC VALUES::"

printf "Override:"
ini_get_value "section2" "override"
echo ""

printf "__Under_scores_:"
ini_get_value "Cleanup" "__Under_scores_"
echo ""

echo ""
echo ::FATALITY CHECK::
eval "Fallback_keys+=('asd')"
ini_display
ini_display_by_section "Fallback"
