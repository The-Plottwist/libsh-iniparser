#!/bin/bash

# All globals assumed true by default.
# You can find them below:
# INI_IS_CASE_SENSITIVE_SECTIONS
# INI_IS_CASE_SENSITIVE_KEYS
# INI_IS_SHOW_WARNINGS
# INI_IS_SHOW_ERRORS

SCRIPT_PATH="$( dirname -- "$(dirname -- "$(readlink -f -- "$0")")")"

# shellcheck disable=SC1091
source "${SCRIPT_PATH}/src/libsh-iniparser.sh" #include the library

ini_process_file "${SCRIPT_PATH}/demos/complete-example.conf"

echo ""
echo "Display Config:"
ini_display

echo "Display Section 2:"
ini_display_by_section 'section2'

echo "Display Section 1 - Value 1 (get_value lookup):"
value=$(ini_get_value 'section1' 'value1')
echo "${value}"

echo ""
echo "Display Section 1 - Value 1 (Named variable):"
echo "${section1_value1}"


