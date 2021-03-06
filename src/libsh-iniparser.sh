#!/bin/bash

# shellcheck disable=SC2090,SC2089

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
# set below variables to "true" or "false"
# in your executable script.
# Defaults can be found in README.

# INI_CASE_SENSITIVE_SECTIONS
# INI_CASE_SENSITIVE_KEYS
# INI_SHOW_WARNINGS
# INI_SHOW_ERRORS
# INI_RAW_MODE


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

INI_DEFAULT_PRINTF='printf' #Will also be modified from ini_initialize_variables()
INI_DEFAULT_SECTION='Fallback'
sections=( "${INI_DEFAULT_SECTION}" )


# ---------------------------------------------------------------------------- #
#                                  FUNCTIONS                                   #
# ---------------------------------------------------------------------------- #

function ini_initialize_variables
{
    if ! [[ "${INI_CASE_SENSITIVE_SECTIONS}" = false || "${INI_CASE_SENSITIVE_SECTIONS}" = true ]]; then
        INI_CASE_SENSITIVE_SECTIONS=true
    fi

    if ! [[ "${INI_CASE_SENSITIVE_KEYS}" = false || "${INI_CASE_SENSITIVE_KEYS}" = true ]]; then
        INI_CASE_SENSITIVE_KEYS=true
    fi

    if ! [[ "${INI_SHOW_WARNINGS}" = false || "${INI_SHOW_WARNINGS}" = true ]]; then
        INI_SHOW_WARNINGS=true
    fi

    if ! [[ "${INI_SHOW_ERRORS}" = false || "${INI_SHOW_ERRORS}" = true ]]; then
        INI_SHOW_ERRORS=true
    fi
    
    if [[ "${INI_RAW_MODE}" = true ]]; then
        INI_DEFAULT_PRINTF='printf %s'
    else
        INI_DEFAULT_PRINTF='printf'
    fi
}

function ini_in_array()
{
    local haystack="${1}[@]"
    local needle="${2}"

    if echo "${!haystack}" | grep -q -w "${needle}"; then
        return 0
    fi

    return 1
}

function ini_show_fatal()
{

    local format="${1}"
    shift;
    printf "[ FATAL ]: ${format}" "$@";
}

function ini_show_warning()
{
    if [[ "${INI_SHOW_WARNINGS}" = true ]]; then
        local format="${1}"
        shift;

        printf "[ WARNING ]: ${format}" "$@";
    fi
}

function ini_show_error()
{
    if [[ "${INI_SHOW_ERRORS}" = true ]]; then
        local format="${1}"
        shift;

        printf "[ ERROR ]: ${format}" "$@";
    fi
}

function ini_process_section()
{
    local section="${1}"

    #Remove leading & trailing blanks
    #https://stackoverflow.com/a/3232433/18680316
    value="$($INI_DEFAULT_PRINTF "${section}" | sed -e 's/^[[:blank:]]//g' | sed -e 's/[[:blank:]]*$//g')"
    section=$($INI_DEFAULT_PRINTF "${section}" | tr -s '[:punct:] [:blank:]' '_')                               #Replace all :punct: and :blank: with underscore and squish
    section=$($INI_DEFAULT_PRINTF "${section}" | sed 's/[^a-zA-Z0-9_]//g')                                      #Remove non-alphanumberics (except underscore)

    if [[ "${INI_CASE_SENSITIVE_SECTIONS}" = false ]]; then
        section=$($INI_DEFAULT_PRINTF "${section}" | tr '[:upper:]' '[:lower:]')     #Lowercase the section name
    fi
    echo "${section}"
}

function ini_process_key()
{
    local key="${1}"

    #Remove leading & trailing blanks
    #https://stackoverflow.com/a/3232433/18680316
    value="$($INI_DEFAULT_PRINTF "${key}" | sed -e 's/^[[:blank:]]//g' | sed -e 's/[[:blank:]]*$//g')"
    key=$($INI_DEFAULT_PRINTF "${key}" | tr -s '[:punct:] [:blank:]' '_')                                       #Replace all :punct: and :blank: with underscore and squish
    key=$($INI_DEFAULT_PRINTF "${key}" | sed 's/[^a-zA-Z0-9_]//g')                                              #Remove non-alphanumberics (except underscore)

    if [[ "${INI_CASE_SENSITIVE_KEYS}" = false ]]; then
        key=$($INI_DEFAULT_PRINTF "${key}" | tr '[:upper:]' '[:lower:]')                                        #Lowercase the section name
    fi
    echo "${key}"
}

function ini_process_value()
{
    local value="${1}"

    value="${value%%\;*}"                                                                          #Remove in line right comments
    value="${value%%\#*}"                                                                          #Remove in line right comments

    #Remove leading & trailing blanks
    #https://stackoverflow.com/a/3232433/18680316
    value="$($INI_DEFAULT_PRINTF "${value}" | sed -e 's/^[[:blank:]]//g' | sed -e 's/[[:blank:]]*$//g')"
    value=$(ini_escape_string "$value")

    echo "${value}"
}

function ini_escape_string()
{
    local clean

    clean="${1//\'/SINGLE_QUOTE}"
    echo "${clean}"
}

function ini_unescape_string()
{
    local orig

    orig="${1//SINGLE_QUOTE/\'}"
    echo "${orig}"
}

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
        elif [[ $line =~ ^(.*)"="(.*) ]]; then                          #Match pattern for a key=value pair
            key=$(ini_process_key "${BASH_REMATCH[1]}")
            value=$(ini_process_value "${BASH_REMATCH[2]}")

            if [[ -z ${key} ]]; then
                ini_show_error 'line %d: No key name\n' "${line_number}"
            elif [[ -z ${value} ]]; then
                ini_show_error 'line %d: No value\n' "${line_number}"
            else
                if [[ "${section}" == "${INI_DEFAULT_SECTION}" ]]; then
                    ini_show_warning 'On line %s, no section was identified. "%s=%s" is added to [%s]\n' "${line_number}" "${key}" "${value}" "${INI_DEFAULT_SECTION}"
                fi

                eval key_array_name="${section}_keys"

                if ini_in_array "${key_array_name}" "${key}"; then
                    ini_show_warning 'The key "%s" in [%s] was defined before. Overriding!\n' "${key}" "${section}"
                    
                    #For this loop to work, we need to change IFS to newlines
                    #otherwise, it will make a new iteration on every space encounter ;)
                    OLD_IFS="$IFS"
                    IFS=$'\n'
                    { #Optional curly braces for readability. Has no effect!
                        local cur_key=''
                        local -i index=''
                        for key_iterator in $(ini_print_keys "${section}" "true"); do
                        
                            cur_key="$(echo $key_iterator | awk '{print $2}')" #Get current key
                            if [[ "$cur_key" == "$key" ]]; then
                        
                                index="$(echo $key_iterator | awk '{print $1}')" #Get current key index
                                eval "${section}_values[${index}]='${value}'" #Perform override
                                break
                            fi
                        done
                    }
                    IFS="$OLD_IFS" #Restore old IFS
                else
                    eval "${section}_keys+=(${key})"                        #Use eval to add to the keys array
                    eval "${section}_values+=('${value}')"                  #Use eval to add to the values array
                fi
            fi
        fi
    done < "${1}"
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
    
    #Check for asyncronism
    if [[ "${#keys[@]}" != "${#values[@]}" ]]; then
        ini_show_fatal 'Values and keys in [%s] are asynchronous. Process aborted!\n' "${section}"
        return 55
    fi

    for i in "${!keys[@]}"; do
        if [[ "${keys[$i]}" = "${key}" ]]; then
            orig=$(ini_unescape_string "${values[$i]}")
            printf '%s' "${orig}"
        fi
    done
}

function ini_print_keys()
{

    local section=''
    local keys=''
    local is_print_index="${2:-false}"
    
    section=$(ini_process_section "${1}")
    eval "keys=( \"\${${section}_keys[@]}\" )"
    
    if [[ "$is_print_index" == "true" ]]; then
        for i in "${!keys[@]}"; do
            echo "${i}" "${keys[$i]}"
        done
    else
        for i in "${keys[@]}"; do
            echo "${i}"
        done
    fi
}

function ini_print_values()
{

    local section=''
    local values=''
    local is_print_index="${2:-false}"
    
    section=$(ini_process_section "${1}")
    eval "values=( \"\${${section}_values[@]}\" )"
    
    if [[ "$is_print_index" = true ]]; then
        for i in "${!values[@]}"; do
            echo "${i}" "${values[$i]}"
        done
    else
        for i in "${values[@]}"; do
            ini_unescape_string "${i}"
        done
    fi
}

function ini_display()
{
    local section=''
    local key=''
    local value=''

    for s in "${!sections[@]}"; do
        section="${sections[$s]}"

        printf '[%s]\n' "${section}"

        eval "keys=( \"\${${section}_keys[@]}\" )"
        eval "values=( \"\${${section}_values[@]}\" )"
        
        #Check for asyncronism
        if [[ "${#keys[@]}" != "${#values[@]}" ]]; then
            ini_show_fatal 'Values and keys in [%s] are asynchronous. Process aborted!\n' "${section}"
            return 55
        fi

        for i in "${!keys[@]}"; do
            orig=$(ini_unescape_string "${values[$i]}")
            printf '%s=%s\n' "${keys[$i]}" "${orig}"
        done
        
        echo ""
    done
}

function ini_display_by_section()
{
    local section="${1}"
    local key=''
    local value=''
    local keys=''
    local values=''

    printf '[%s]\n' "${section}"

    eval "keys=( \"\${${section}_keys[@]}\" )"
    eval "values=( \"\${${section}_values[@]}\" )"
    
    #Check for asyncronism
    if [[ "${#keys[@]}" != "${#values[@]}" ]]; then
        ini_show_fatal 'Values and keys in [%s] are asynchronous. Process aborted!\n' "${section}"
        return 55
    fi

    for i in "${!keys[@]}"; do
        orig=$(ini_unescape_string "${values[$i]}")
        printf '%s=%s\n' "${keys[$i]}" "${orig}"
    done
    
    echo ""
}
