#!/usr/bin/env bash

# set -Eeuo pipefail
# trap _cleanup SIGINT SIGTERM ERR EXIT

(return 0 2>/dev/null) && sourced=1 || sourced=0
readonly sourced
readonly BASE_SCRIPT_ARGS_STR="$@"
readonly BASE_SCRIPT_RELATIVE_PATH="$(dirname $0)"
readonly BASE_SCRIPT_ABSOLUTE_PATH="$(realpath $BASE_SCRIPT_RELATIVE_PATH)"
readonly BASE_SCRIPT_NAME="$(basename $0)"
readonly CURRENT_FOLDER="$(basename $PWD)"
readonly RUNNING_FROM="${PWD}"

source "${BASE_SCRIPT_ABSOLUTE_PATH}/writer.sh"

# Initilizing vars and setting up colors.
param=''

is_verbose=0
echo "${BASE_SCRIPT_ARGS_STR}" | grep -qPe "(-v|--verbose)((\s*-)|\$)" && is_verbose=1
readonly is_verbose

echo "${BASE_SCRIPT_ARGS_STR}" | grep -qPe "(-nc|--no-colors?)((\s*-)|\$)" && remove_colors || colorize

##                            #####
## READ ONLY functions - BEGIN
##                            #####

# Whenever the script exits this function will be called
function _cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
  debug "${BLK}Cleanning up things${NF}"
}

# Utility function to assert if a var has value. Otherwise prints a message with the var name
# Params:
#   $1 var value
#   $2 var name
function assert_var() {
  if [[ ${#1} -eq 0 ]]; then
    error "$2 is mandatory\n\n"
    usage
  fi
}

# Prints a message to console, only if -v or --verbose is present in the arguments
# Params:
#   $1 message to print
function debug() {
  [ $is_verbose -eq 1 ] && msg "${BLACK}$1${NF}"
  # echo "${BASE_SCRIPT_ARGS_STR}" | grep -qPe "(-v|--verbose)((\s*-)|\$)" && msg "$1"
  return 0
}

# Search for both short or long names among the script's arguments.
# If they are found sets the global var "param"'s value and return success, otherwise failure
# Params:
#   $1 parameter's short name
#   $2 parameter's long name
function get_param() {
  param=''
  local args_array=($BASE_SCRIPT_ARGS_STR)
  local short="-${1}"
  local long="--${2}"
  local found=false
  debug "Trying to get the param (${short}|${long})"
  for opt in "${args_array[@]}"; do

    if $found; then
      if [ ${opt:0:1} != '-' ]; then
        debug "Param (${short}|${long}) was found: ${opt}"
        param="${opt}"
        return 0
      fi
      found=false
    fi

    if [ "${opt}" == "$short" ] || [ "${opt}" == "$long" ]; then
      found=true
    fi
  done
  return 1
}

# Checks if a flag is present among the script's arguments and return success or failure
# Params:
#   $1 flag's short name
#   $2 flag's long name
function has_flag() {
  local short="-${1}"
  local long="--${2-NOT_EXISTS}"
  local regex="((\s+-)|\$)"
  echo "${BASE_SCRIPT_ARGS_STR}" | grep -qPe "((^|\s+)${short}|${long})${regex}" && return 0 || return 1
}

# Checks if a parameter is present among the script's arguments and return success or failure
# Params:
#   $1 parameter's short name
#   $2 parameter's long name
function has_param() {
  local short="-${1}"
  local long="--${2-NOT_EXISTS}"
  # local regex="((\s+-)|\$)|([\s\w]*|\$)"
  local regex="((\s+\w+).*)"
  echo "${BASE_SCRIPT_ARGS_STR}" | grep -qPe "((^|\s+)${short}|${long})${regex}" && return 0 || return 1
}

function main() {
  setup_consts
  if has_flag 'h' 'help'; then
    usage
    exit
  fi
  initialize_vars
  debug "Parsing params ${BASE_SCRIPT_ARGS_STR}"
  parse_params $BASE_SCRIPT_ARGS_STR
  debug 'Params parsed'
  setup_default

  debug "Calling 'run' function"
  run
}

# Renames a declared function from $1 to $2. Allowing to override it.
# Params:
#   $1 function to rename
#   $2 new function's name. Defaults to 'base.$1'
function rename_function() {
  declare -F $1 >/dev/null || return 1
  [ -n "${2-}" ] && new_name=$2 || new_name="base.${1}"
  eval "$(
    echo "${new_name}()"
    declare -f ${1} | tail -n +2
  )"
}

# Write a message to the console and exits with the provided code# Params:
#   $1 Message to be printed
#   $2 error code for the exit. Defaults to 1
function throw_error() {
  local msg=$1
  local code=${2-1} # default exit status 1
  error "[$code] ${msg}"
  exit "$code"
}

readonly -f _cleanup assert_var debug get_param has_flag has_param main rename_function throw_error

##                            #####
## READ ONLY functions - END
##
## Unsetable functions - BEGIN
##                            #####

# Initializes script's variables before the params are parsed
function initialize_vars() {
  debug "${BLACK}No vars initialization${NF}"
}

# Does some dummy parsing. By overriding it you have to redeclare the last four cases (in that order)
function parse_params() {
  while :; do
    case "${1-}" in
    -h | --help)
      usage
      ;;
    ##    usage example
    # -a | --action)
    #   shift
    #   [[ "$1" != 'start' ]] && [[ "$1" != 'stop' ]] && [[ "$1" != 'restart' ]] && throw_error "--action must be either start, stop or restart"
    #   action="$1"
    #   ;;

    # Both declared to avoid throwing error
    -nc | --no-colors?) ;;
    -v | --verbose) ;;

    # If a parameter (not null) is passed to the script, it throws an error
    -?*)
      throw_error "Unknown param: $1"
      ;;
    # If ${1-} is 'null' it ends the loop
    *)
      break
      ;;
    esac
    shift
  done

  # assert_var "$var_name" '--option-name'

}

# Sets script's constants
function setup_consts() {
  debug "No constants"
}

# After the params are parsed it is clled to setup the default values
function setup_default() {
  debug "${BLACK}No defaults${NF}"
}

function usage() {

  [[ $sourced -eq 1 ]] && warning "\n!!!!!!\n You should override 'usage' fuction. Otherwise the default usage function is called\n!!!!!!\n\n"

  msg "Usage: ${BASE_SCRIPT_NAME} [-h | --help]"
  echo ''
  msg "This script is just a skeleton for others scripts. Although it runs, it does nothing. It implements 'readonly' functions:"
  echo ''
  msg "  ${CYN}_cleanup${NF}, ${CYN}assert_var${NF}, ${CYN}debug${NF}, ${CYN}get_param${NF}, ${CYN}has_flag${NF}, ${CYN}has_param${NF},"
  msg "  ${CYN}main${NF}, ${CYN}msg${NF}, ${CYN}rename_function${NF}, and ${CYN}throw_error${NF}"
  echo ''
  msg "and functions that may be overriden (or renamed unsetting them before):"
  echo ''
  msg "  ${BLU}usage${NF}, ${BLU}parse_params${NF}, ${BLU}setup_consts${NF}, ${BLU}setup_default${NF}, ${BLU}initialize_vars${NF}, ${BLU}run${NF}"
  echo ''
  echo ''
  msg "After you've sourced this file, and in the very end of your script, you have to call the ${GRN}main${NF} function."
  msg "It will call the others function in that order:"
  msg '  - setup_consts'
  msg '  - usage: if -h | --help is present and exit'
  msg '  - initialize_vars'
  msg '  - parse_params'
  msg '  - setup_default'
  msg '  - run'
  echo ''
  echo ''
  msg 'Available flags:'
  msg '-h, --help                   Prints this help and exit.'
  msg '-nc, --no-color, no-colors   Disable output color.'
  msg '-v, --verbose                Increase the output message. debug method checks whether it should print or not.'

  exit
}

function run() {
  msg "A function named ${RED}run${NOFORMAT} must be created in order to this script to be useful"
  msg "You sould/can also override other four functions, namely:"
  msg "\t-${GREEN}usage${NOFORMAT}"
  msg "\t-${GREEN}setup_default${NOFORMAT}"
  msg "\t-${GREEN}initialize_vars${NOFORMAT} and"
  msg "\t-${GREEN}parse_params${NOFORMAT}\n"
}

##                            #####
## Unsetable functions - END
##                            #####

# main $@
# echo "sourced: $sourced"
