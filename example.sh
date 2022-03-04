#!/usr/bin/env bash

# Including the library
source ./base.sh

# The readonly function are NOT renamed only copied
rename_function 'msg' 'new_msg_fnc'

# Copying base's setup_default function to a new one 'base.setup_default'
rename_function 'setup_default'

# Overriding base's setup_default function
function setup_default() {
  msg "Overriding setup default and executing something before"
  # Calling base's setup_default function
  base.setup_default
  new_msg_fnc "Executing something after"
}

# Overriding base's setup_default function
function initialize_vars() {
  action=''
  directory_to_list="${RUNNING_FROM}"
  list_is_present=()
}

function parse_params() {
  while :; do
    case "${1-}" in
    -a | --action)
      shift
      [[ "$1" != 'start' ]] && [[ "$1" != 'stop' ]] && [[ "$1" != 'restart' ]] && throw_error "--action must be either start, stop or restart"
      action="$1"
      ;;
    -l | --list)
      list_is_present='true'
      if [[ ! "${2--}" =~ ^- ]]; then
        shift
        directory_to_list="${1}"
      fi
      ;;
    # Declared to avoid throwing error
    -v | --verbose) ;;

    # If a parameter (not null) is passed to the script, it throws an error
    -?*)
      throw_error "Unknown param: $1"
      ;;
    # If ${1-} is null it ends the loop
    *)
      break
      ;;
    esac
    shift
  done

  assert_var "$action" '--action'
}

# Overriding base's run function
function run() {
  print_action_value
  ls_directory
}

# Custom function called inside of run
function print_action_value() {
  get_param 'a' 'action'
  echo "last output: $?"
  echo "param: $param"
  msg "Executing ${BLU}${param}${NF} action"
}

# Custom function called inside of run
function ls_directory() {
  if [[ -n $list_is_present ]]; then
    msg "Listing directory: ${BLU}${directory_to_list}${NF}\n\n"
    ls -lah $directory_to_list
  fi
}

# Main have to be added in the very end of the script
main

$(has_flag 'l' 'list') && msg "NO colors" || msg "${GRN}WITH${NF} colors"
