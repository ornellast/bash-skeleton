#!/usr/bin/env bash

# Long names
declare NOFORMAT BLACK RED GREEN ORANGE BLUE PURPLE CYAN

# Short names
declare NF BLK RED GRN ORG BLU PPL CYN

function update_short_names_values() {

  NF="${NOFORMAT}"
  BLK="${BLACK}"
  RED="${RED}"
  GRN="${GREEN}"
  ORG="${ORANGE}"
  BLU="${BLUE}"
  PPL="${PURPLE}"
  CYN="${CYAN}"

  MCLR="${NOFORMAT}"
  HIGHCL="${GREEN}"

}

function colorize() {
  NOFORMAT='\033[0m'
  BLACK='\033[1;30m'
  RED='\033[1;31m'
  GREEN='\033[1;32m'
  ORANGE='\033[0;33m'
  BLUE='\033[1;34m'
  PURPLE='\033[1;35m'
  CYAN='\033[0;36m'

  MAIN_COLOR="${NOFORMAT}"
  HIGHLIGHT_COLOR="${GREEN}"

  update_short_names_values
}

function remove_colors() {
  NOFORMAT=''
  BLACK=''
  RED=''
  GREEN=''
  ORANGE=''
  BLUE=''
  PURPLE=''
  CYAN=''

  MAIN_COLOR=''
  HIGHLIGHT_COLOR=''

  update_short_names_values
}

readonly -f  update_short_names_values colorize remove_colors

colorize
