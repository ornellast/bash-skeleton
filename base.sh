#!/usr/bin/env bash

set -Eeuo pipefail
trap _cleanup SIGINT SIGTERM ERR EXIT

(return 0 2>/dev/null) && sourced=1 || sourced=0
readonly sourced
readonly SCRIPT_ARGS_STR="$@"
readonly SCRIPT_PATH_RELATIVE="$(dirname $0)"
readonly SCRIPT_PATH_ABSOLUTE="$(realpath $SCRIPT_PATH_RELATIVE)"
readonly SCRIPT_NAME="$(basename $0)"
readonly CURRENT_FOLDER="$(basename $PWD)"
readonly RUNNING_FROM="${PWD}"

colored_output_configured=0
param=()

source ./colors

##      #####
## READ ONLY functions - BEGIN
##      #####

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
    msg "\n${RED}$2${NOFORMAT} is mandatory\n\n"
    usage
  fi
}

# Prints a message to console, only if -v or --verbose is present in the arguments
# Params:
#   $1 message to print
function debug() {
  echo "${SCRIPT_ARGS_STR}" | grep -qPe "(-v|--verbose)((\s*-)|\$)" && msg "${BLACK}$1${NF}"
  # echo "${SCRIPT_ARGS_STR}" | grep -qPe "(-v|--verbose)((\s*-)|\$)" && msg "$1"
  return 0
}

# Search for both short or long names among the script's arguments.
# If they are found sets the global var "param"'s value and return success, otherwise failure
# Params:
#   $1 parameter's short name
#   $2 parameter's long name
function get_param() {
  param=()
  local args_array=($SCRIPT_ARGS_STR)
  local short="${1}"
  local long="${2}"
  local found=false
  for opt in "${args_array[@]}"; do

    if $found; then
      if [ ${opt:0:1} != '-' ]; then
        param="${opt}"
        return 0
      fi
      found=false
    fi

    if [ "${opt}" == "-$short" ] || [ "${opt}" == "--$long" ]; then
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
  has_param $@ && return 0 || return 1
}

# Checks if a parameter is present among the script's arguments and return success or failure
# Params:
#   $1 parameter's short name
#   $2 parameter's long name
function has_param() {
  local short="-${1}"
  local long="--${2-NOT_EXISTS}"
  # local regex="((\s+-)|\$)([\s\w]*|\$)"
  local regex="((-[\s-\w]*)|\$)"
  echo "${SCRIPT_ARGS_STR}" | grep -qPe "((^|\s+)${short}|${long})${regex}" && return 0
  return 1
}

function main() {
  setup_consts
  if has_flag 'h' 'help'; then
    usage
    exit
  fi
  initialize_vars
  parse_params $@
  setup_colors
  setup_default

  run
}

# Prints a message (echo) to the console evaluating (-e) the content
function msg() {
  echo >&2 -e "${1-}"
}

# Configures if the output will be colored
function setup_colors() {
  if [ $colored_output_configured -eq 0 ]; then
    local no_color=0
    has_flag 'nc' 'no-color' && no_color=1
    if [ $no_color -eq 0 ] && [[ "${TERM-}" != "dumb" ]]; then
      colorize
      debug "Colored output was set"
    else
      remove_colors
      debug 'Colored output was removed'
    fi

    MAIN_COLOR="${NOFORMAT}"
    HIGHLIGHT_COLOR="${GREEN}"
    colored_output_configured=1
  fi
}

# Write a message to the console and exits with the provided code# Params:
#   $1 Message to be printed
#   $2 error code for the exit. Defaults to 1
function throw_error() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "[$code] ${RED}${msg}${NF}"
  exit "$code"
}

setup_colors

readonly -f _cleanup assert_var debug get_param has_flag has_param main msg setup_colors throw_error

##      #####
## READ ONLY functions - END
##      #####

##      #####
## Unsetable functions - BEGIN
##      #####

function initialize_vars() {
  debug "${BLACK}No vars were initialized${NF}"
}

function parse_params() {
  while :; do
    case "${1-}" in
    -h | --help)
      usage
      ;;
    --no-color)
      NO_COLOR=1
      ;;
    ##    usage example
    # -a | --action)
    #   shift
    #   [[ "$1" != 'start' ]] && [[ "$1" != 'stop' ]] && [[ "$1" != 'restart' ]] && throw_error "--action must be either start, stop or restart"
    #   action="$1"
    #   ;;g
    -v | --verbose)
      msg "${BLK}Verbose enabled${NF}"
      ;;
    -?*)
      throw_error "Unknown param: $1"
      ;;
    *)
      break
      ;;
    esac
    shift
  done

  # assert_var "$var_name" '--option-name'

}

# Sets the basic
function setup_consts() {
  debug "No constants"
}

function setup_default() {
  debug "${BLACK}No defaults${NF}"
}

function usage() {

  msg "Usage: ${SCRIPT_NAME} [-h | --help]"
  msg ""
  msg "This script is just a skeleton for the others. It implements 'readonly' functions:"
  msg ""
  msg "  - ${CYN}_cleanup${NF}: "
  msg "  - ${CYN}assert_var${NF}: "
  msg "  - ${CYN}debug${NF}: "
  msg "  - ${CYN}get_param${NF}: "
  msg "  - ${CYN}has_flag${NF}: "
  msg "  - ${CYN}has_param${NF}: "
  msg "  - ${CYN}main${NF}: "
  msg "  - ${CYN}msg${NF}: "
  msg "  - ${CYN}setup_colors${NF}: "
  msg "  - ${CYN}setup_consts${NF}: "
  msg "  - ${CYN}throw_error${NF}: "
  msg ""
  msg "and functions that may be overriden (by unsetting them before):"
  msg ""
  msg "  - ${BLU}usage${NF}, ${BLU}parse_params${NF}, ${BLU}setup_default${NF}, ${BLU}initialize_vars${NF}, ${BLU}run${NF}"
  msg ""
  msg ""
  msg "Available flags:"
  msg "-h, --help    Print this help and exit."

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

##      #####
## Unsetable functions - END
##      #####

# main $@
# echo "sourced: $sourced"
