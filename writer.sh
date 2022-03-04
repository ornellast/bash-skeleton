#!/usr/bin/env bash

readonly LOGGER_SCRIPT_RELATIVE_PATH="$(dirname $0)"
readonly LOGGER_SCRIPT_ABSOLUTE_PATH="$(realpath $LOGGER_SCRIPT_RELATIVE_PATH)"

source "${LOGGER_SCRIPT_ABSOLUTE_PATH}/colors.sh"

# Prints a message (echo) to the console evaluating (-e) the content
function msg() {
  echo >&2 -e "${1-}"
}

# Surrounds the message with BLUE color
function info() {
  msg "${BLU}${1-}${NF}"
}

# Surrounds the message with ORANGE/YELLOW color
function warning() {
  msg "${ORG}${1-}${NF}"
}

# Surrounds the message with RED color
function error() {
  msg "${RED}${1-}${NF}"
}

readonly -f  msg info warning error
