#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

function cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
  msg "${BLK}cleanup called${NF}"
}

readonly SCRIPT_ARGS_STR="$@"
function setup_consts() {
  readonly SCRIPT_PATH_RELATIVE="$(dirname $0)"
  readonly SCRIPT_PATH_ABSOLUTE="$(realpath $SCRIPT_PATH_RELATIVE)"
  readonly SCRIPT_NAME="$(basename $0)"
  readonly CURRENT_FOLDER="$(basename $PWD)"
  readonly RUNNING_FROM="${PWD}"
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
    NOFORMAT='' NF='' BLACK='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN=''
  fi

  NF="${NOFORMAT}" BLK="${BLACK}" RED="${RED}" GRN="${GREEN}" ORG="${ORANGE}" BLU="${BLUE}" PPL="${PURPLE}" CYN="${CYAN}"

  MAIN_COLOR="${NOFORMAT}"
  HIGHLIGHT_COLOR="${GREEN}"
}

function assert_var() {
  if [[ ${#1} -eq 0 ]]; then
    msg "\n${RED}$2${NOFORMAT} is mandatory\n\n"
    usage
  fi
}

function msg() {
  echo >&2 -e "${1-}"
}

function throw_error() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "[$code] ${RED}${msg}${NF}"
  exit "$code"
}

function debug() {
  echo "${SCRIPT_ARGS_STR}" | grep -qPe "-v((\s*-)|\$)" && msg "${ORG}$1${NF}"
  echo "${SCRIPT_ARGS_STR}" | grep -qPe "--verbose((\s*-)|\$)" && msg "${ORG}$1${NF}"
}

function has_flag() {
  has_param $@ && return 0 || return 1
}

function has_param() {
  local short="-${1}"
  local long="--${2-NOT_EXISTS}"
  debug "SCRIPT_ARGS_STR: $SCRIPT_ARGS_STR"
  debug "short: ${short}"
  debug "long: ${long}"
  echo "${SCRIPT_ARGS_STR}" | grep -qPe "${short}([\s-\w]*|\$)" && return 0
  echo "${SCRIPT_ARGS_STR}" | grep -qPe "${long}([\s-\w]*|\$)" && return 0
  return 1

}

function get_param() {
  param=()
  local args_array=($SCRIPT_ARGS_STR)
  for par in "${args_array[@]}"; do
    echo "$par"
  done
}

function main() {
  setup_colors
  setup_consts
  param=()
  # if has_flag "v" "verbose"; then
    if has_param "h" "help"; then
    echo "it has"
  else
    echo 'it doesnt have'
  fi
  # get_param "h" "help"
  exit 0
  initialize_vars
  parse_params $@
  setup_colors
  setup_default

  run
}

[[ $(type -t usage) != function ]] && usage() {

  msg "Usage: ${SCRIPT_NAME} [-h | --help] [OPTIONS]"
  msg ""
  msg "This script is just a skeleton for the others. It implements 'final' functions:"
  msg ""
  msg "  - ${CYN}cleanup${NF}"
  msg "  - ${CYN}setup_consts${NF}"
  msg "  - ${CYN}setup_colors${NF}"
  msg "  - ${CYN}main${NF}"
  msg "  - ${CYN}assert_var${NF}"
  msg "  - ${CYN}msg${NF}"
  msg "  - ${CYN}throw_error${NF}"
  msg "  "
  msg " and functions that may be overriden:"
  msg ""
  msg "  - usage"
  msg "  - parse_params"
  msg "  - setup_default"
  msg "  - initialize_vars"
  msg "  - run"
  msg ""
  msg ""
  msg "Available options:"
  msg "-h, --help    Print this help and exit."

  exit
}

[[ $(type -t parse_params) != function ]] && parse_params() {
  while :; do
    case "${1-}" in
    -h | --help)
      usage
      ;;
    --no-color)
      NO_COLOR=1
      ;;
    ##    example of usage
    # -a | --action)
    #   shift
    #   [[ "$1" != 'start' ]] && [[ "$1" != 'stop' ]] && [[ "$1" != 'restart' ]] && throw_error "--action must be either start, stop or restart"
    #   action="$1"
    #   ;;g
    -?*)
      throw_error "Unknown option: $1"
      ;;
    *)
      break
      ;;
    esac
    shift
  done

  # assert_var "$var_name" '--option-name'

}

[[ $(type -t setup_default) != function ]] && setup_default() {
  msg "${BLACK}No defaults${NOFORMAT}"
}

[[ $(type -t initialize_vars) != function ]] && initialize_vars() {
  msg "${BLACK}No vars were initialized${NOFORMAT}"
}

[[ $(type -t run) != function ]] && run() {
  msg "A function named ${RED}run${NOFORMAT} must be created in order to this script to be useful"
  msg "You sould/can also override other four functions, namely:"
  msg "\t-${GREEN}usage${NOFORMAT}"
  msg "\t-${GREEN}setup_default${NOFORMAT}"
  msg "\t-${GREEN}initialize_vars${NOFORMAT} and"
  msg "\t-${GREEN}parse_params${NOFORMAT}\n"
}

main $@
