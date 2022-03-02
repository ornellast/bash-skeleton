#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

(return 0 2>/dev/null) && sourced=1 || sourced=0
readonly sourced
readonly SCRIPT_ARGS_STR="$@"

##      #####
## READ ONLY functions - BEGIN
##      #####

function assert_var() {
  if [[ ${#1} -eq 0 ]]; then
    msg "\n${RED}$2${NOFORMAT} is mandatory\n\n"
    usage
  fi
}

function cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
  debug "${BLK}cleanup called${NF}"
}

function debug() {
  echo "${SCRIPT_ARGS_STR}" | grep -qPe "(-v|--verbose)((\s*-)|\$)" && msg "$1"
  return 0
}

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

function has_flag() {
  has_param $@ && return 0 || return 1
}

function has_param() {
  local short="-${1}"
  local long="--${2-NOT_EXISTS}"
  local regex="((\s*-)|\$)([\s\w]*|\$)"
  debug "Validating '${RED}${SCRIPT_ARGS_STR}${NF}' against '${RED}(${short}|${long})${regex}${NF}'"
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

function msg() {
  echo >&2 -e "${1-}"
}

function setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m'
    BLACK='\033[1;30m'
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    ORANGE='\033[0;33m'
    BLUE='\033[1;34m'
    PURPLE='\033[1;35m'
    CYAN='\033[0;36m'
  else
    NOFORMAT='' BLACK='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN=''
  fi

  NF="${NOFORMAT}" BLK="${BLACK}" RED="${RED}" GRN="${GREEN}" ORG="${ORANGE}" BLU="${BLUE}" PPL="${PURPLE}" CYN="${CYAN}"

  MAIN_COLOR="${NOFORMAT}"
  HIGHLIGHT_COLOR="${GREEN}"
}

function setup_consts() {
  readonly SCRIPT_PATH_RELATIVE="$(dirname $0)"
  readonly SCRIPT_PATH_ABSOLUTE="$(realpath $SCRIPT_PATH_RELATIVE)"
  readonly SCRIPT_NAME="$(basename $0)"
  readonly CURRENT_FOLDER="$(basename $PWD)"
  readonly RUNNING_FROM="${PWD}"

  param=()
}

function throw_error() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "[$code] ${RED}${msg}${NF}"
  exit "$code"
}

setup_colors

readonly -f cleanup setup_consts setup_colors assert_var msg throw_error debug has_flag has_param get_param main

##      #####
## READ ONLY functions - END
##      #####



##      #####
## Unsetable functions - BEGIN
##      #####

function usage() {

  msg "Usage: ${SCRIPT_NAME} [-h | --help] [PARAMS]"
  msg ""
  msg "This script is just a skeleton for the others. It implements 'readonly' functions:"
  msg ""
  msg "  - ${CYN}cleanup${NF}"
  msg "  - ${CYN}setup_consts${NF}"
  msg "  - ${CYN}setup_colors${NF}"
  msg "  - ${CYN}main${NF}"
  msg "  - ${CYN}assert_var${NF}"
  msg "  - ${CYN}msg${NF}"
  msg "  - ${CYN}throw_error${NF}"
  msg "  "
  msg " and functions that may be overriden (by unsetting them before):"
  msg ""
  msg "  - ${BLU}usage${NF}"
  msg "  - ${BLU}parse_params${NF}"
  msg "  - ${BLU}setup_default${NF}"
  msg "  - ${BLU}initialize_vars${NF}"
  msg "  - ${BLU}run${NF}"
  msg ""
  msg ""
  msg "Available flags:"
  msg "-h, --help    Print this help and exit."

  exit
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

function setup_default() {
  debug "${BLACK}No defaults${NF}"
}

function initialize_vars() {
  debug "${BLACK}No vars were initialized${NF}"
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
echo "sourced: $sourced"