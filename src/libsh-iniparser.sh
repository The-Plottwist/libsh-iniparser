#!/bin/bash


# ---------------------------------------------------------------------------- #
#                                  DISCLAIMER                                  #
# ---------------------------------------------------------------------------- #

# The original version of this file is published under MIT License.
# And belongs to Wolf Software.
# You can find that version here: https://github.com/DevelopersToolbox/ini-file-parser

# However, concurrent with the MIT license, this is a modified version.
# Belongs to Fatih Yeğin, and sublicensed under LGPL v3.

# You should have received both licenses with the files.
# If not, you can find a template for both licenses at the addresses below:
# https://www.gnu.org/licenses/lgpl-3.0.en.html (LGPL v3)
# https://opensource.org/licenses/MIT (MIT)

# Copyright (C) <2009-2021> Wolf Software
# Copyright (C) <2022> Fatih Yeğin
# Mail: mail.fyegin@gmail.com


# ---------------------------------------------------------------------------- #
#                                CONFIGURATION                                 #
# ---------------------------------------------------------------------------- #
# To alter the behaviour,
# set below variables to "false" in your executable.
# Note: They are assumed "true" by default.

# INI_IS_CASE_SENSITIVE_SECTIONS
# INI_IS_CASE_SENSITIVE_KEYS
# INI_IS_SHOW_WARNINGS
# INI_IS_SHOW_ERRORS


# ---------------------------------------------------------------------------- #
#                                    USAGE                                     #
# ---------------------------------------------------------------------------- #

# This is a library file.
# Do not execute this file directly.
# Rather, include it in your executable script.
# Ex: source PATH_TO_LIBRARY/libsh-iniparser.sh


# ---------------------------------------------------------------------------- #
#                                   DEFAULTS                                   #
# ---------------------------------------------------------------------------- #

INI_DEFAULT_SECTION='Fallback'
sections=( "${INI_DEFAULT_SECTION}" )


# ---------------------------------------------------------------------------- #
#                                  FUNCTIONS                                   #
# ---------------------------------------------------------------------------- #

function ini_initialize_variables
{
    if ! [[ "${INI_IS_CASE_SENSITIVE_SECTIONS}" = false || "${INI_IS_CASE_SENSITIVE_SECTIONS}" = true ]]; then
        INI_IS_CASE_SENSITIVE_SECTIONS=true
    fi

    if ! [[ "${INI_IS_CASE_SENSITIVE_KEYS}" = false || "${INI_IS_CASE_SENSITIVE_KEYS}" = true ]]; then
        INI_IS_CASE_SENSITIVE_KEYS=true
    fi

    if ! [[ "${INI_IS_SHOW_WARNINGS}" = false || "${INI_IS_SHOW_WARNINGS}" = true ]]; then
        INI_IS_SHOW_WARNINGS=true
    fi

    if ! [[ "${INI_IS_SHOW_ERRORS}" = false || "${INI_IS_SHOW_ERRORS}" = true ]]; then
        INI_IS_SHOW_ERRORS=true
    fi
}

function ini_in_array()
{
    local haystack="${1}[@]"
    local needle=${2}

    if echo "${!haystack}" | grep -q -w "${needle}"; then
        return 0
    fi

    return 1
}

function ini_show_warning()
{
    if [[ "${INI_IS_SHOW_WARNINGS}" = true ]]; then
        format=$1
        shift;

        #shellcheck disable=SC2059
        printf "[ WARNING ] ${format}" "$@";
    fi
}

function ini_show_error()
{
    if [[ "${INI_IS_SHOW_ERRORS}" = true ]]; then
        format=$1
        shift;

        #shellcheck disable=SC2059
        printf "[ ERROR ] ${format}" "$@";
    fi
}

function ini_process_section()
{
    local section=$1

    section="${section##*( )}"                                          #Remove leading spaces
    section="${section%%*( )}"                                          #Remove trailing spaces
    section=$(echo -e "${section}" | tr -s '[:punct:] [:blank:]' '_')   #Replace all :punct: and :blank: with underscore and squish
    section=$(echo -e "${section}" | sed 's/[^a-zA-Z0-9_]//g')          #Remove non-alphanumberics (except underscore)

    if [[ "${INI_IS_CASE_SENSITIVE_SECTIONS}" = false ]]; then
        section=$(echo -e "${section}" | tr '[:upper:]' '[:lower:]')    #Lowercase the section name
    fi
    echo "${section}"
}

#TODO: Replace "echo -e" with printf
function ini_process_key()
{
    local key=$1

    key="${key##*( )}"                                                  #Remove leading spaces
    key="${key%%*( )}"                                                  #Remove trailing spaces
    key=$(echo -e "${key}" | tr -s '[:punct:] [:blank:]' '_')           #Replace all :punct: and :blank: with underscore and squish
    key=$(echo -e "${key}" | sed 's/[^a-zA-Z0-9_]//g')                  #Remove non-alphanumberics (except underscore)

    if [[ "${INI_IS_CASE_SENSITIVE_KEYS}" = false ]]; then
        key=$(echo -e "${key}" | tr '[:upper:]' '[:lower:]')            #Lowercase the section name
    fi
    echo "${key}"
}

function ini_process_value()
{
    local value=$1

    value="${value%%\;*}"                                               #Remove in line right comments
    value="${value%%\#*}"                                               #Remove in line right comments

    #TODO: Remove [:blank:]
    value="${value##*( )}"                                              #Remove leading spaces
    value="${value%%*( )}"                                              #Remove trailing spaces

    value=$(ini_escape_string "$value")

    echo "${value}"
}

function ini_escape_string()
{
    local clean

    clean=${1//\'/SINGLE_QUOTE}
    echo "${clean}"
}

function ini_unescape_string()
{
    local orig

    orig=${1//SINGLE_QUOTE/\'}
    echo "${orig}"
}

#TODO: Remove unnecessry globals
function ini_process_file()
{
    local line_number=0
    local section="${INI_DEFAULT_SECTION}"
    local key_array_name=''

    ini_initialize_variables

    shopt -s extglob

    while read -r line; do
        line_number=$((line_number+1))

        if [[ $line =~ ^# || -z $line ]]; then                          #Ignore comments / empty lines
            continue;
        fi

        if [[ $line =~ ^"["(.+)"]"$ ]]; then                            #Match pattern for a 'section'
            section=$(ini_process_section "${BASH_REMATCH[1]}")

            if ! ini_in_array sections "${section}"; then
                eval "${section}_keys=()"                               #Use eval to declare the keys array
                eval "${section}_values=()"                             #Use eval to declare the values array
                sections+=("${section}")                                #Add the section name to the list
            fi
        elif [[ $line =~ ^(.*)"="(.*) ]]; then                          #Match patter for a key=value pair
            key=$(ini_process_key "${BASH_REMATCH[1]}")
            value=$(ini_process_value "${BASH_REMATCH[2]}")

            if [[ -z ${key} ]]; then
                ini_show_error 'line %d: No key name\n' "${line_number}"
            elif [[ -z ${value} ]]; then
                ini_show_error 'line %d: No value\n' "${line_number}"
            else
                if [[ "${section}" == "${INI_DEFAULT_SECTION}" ]]; then
                    ini_show_warning '%s=%s - Defined on line %s before first section - added to "%s" section\n' "${key}" "${value}" "${line_number}" "${INI_DEFAULT_SECTION}"
                fi

                eval key_array_name="${section}_keys"

                if ini_in_array "${key_array_name}" "${key}"; then
                    ini_show_warning 'key %s - Defined multiple times within section %s\n' "${key}" "${section}"
                fi
                eval "${section}_keys+=(${key})"                        #Use eval to add to the keys array
                eval "${section}_values+=('${value}')"                  #Use eval to add to the values array
                eval "${section}_${key}='${value}'"                     #Use eval to declare a variable
            fi
        fi
    done < "$1"
}

function ini_get_value()
{
    local section=''
    local key=''
    local value=''
    local keys=''
    local values=''

    section=$(ini_process_section "${1}")
    key=$(ini_process_key "${2}")

    eval "keys=( \"\${${section}_keys[@]}\" )"
    eval "values=( \"\${${section}_values[@]}\" )"

    for i in "${!keys[@]}"; do
        if [[ "${keys[$i]}" = "${key}" ]]; then
            orig=$(ini_unescape_string "${values[$i]}")
            printf '%s' "${orig}"
        fi
    done
}

function ini_display()
{
    local section=''
    local key=''
    local value=''

    for s in "${!sections[@]}"; do
        section=${sections[$s]}

        printf '[%s]\n' "${section}"

        eval "keys=( \"\${${section}_keys[@]}\" )"
        eval "values=( \"\${${section}_values[@]}\" )"

        for i in "${!keys[@]}"; do
            orig=$(ini_unescape_string "${values[$i]}")
            printf '%s=%s\n' "${keys[$i]}" "${orig}"
        done
    printf '\n'
    done
}

function ini_display_by_section()
{
    local section=$1
    local key=''
    local value=''
    local keys=''
    local values=''

    printf '[%s]\n' "${section}"

    eval "keys=( \"\${${section}_keys[@]}\" )"
    eval "values=( \"\${${section}_values[@]}\" )"

    for i in "${!keys[@]}"; do
        orig=$(ini_unescape_string "${values[$i]}")
        printf '%s=%s\n' "${keys[$i]}" "${orig}"
    done
    printf '\n'
}
