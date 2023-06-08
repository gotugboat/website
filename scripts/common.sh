#!/bin/bash

# This file contains functions that scripts can source and utilize

# Use colors if connected to a terminal
setup_color() {
  if [ -t 1 ]; then
    RED=$(printf '\033[31m')
    GREEN=$(printf '\033[32m')
    YELLOW=$(printf '\033[33m')
    BLUE=$(printf '\033[34m')
    BOLD=$(printf '\033[1m')
    DIM=$(printf '\033[2m')
    UNDER=$(printf '\033[4m')
    RESET=$(printf '\033[m')
  fi
}

# Check if the command exists in the system's list of commands
check_command() {
  if command -v "$1" >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

# Debug level log output function
log_debug() {
  if [[ ${IS_DEBUG} == true ]]; then
    printf "${DIM}DEBU: %s${RESET}\n" "$*"
  fi
}

# Info level log output function
log_info() {
  printf "${BLUE}INFO:${RESET} %s\n" "$*"
}

# Warning level log output function
log_warn() {
  printf "${YELLOW}WARN:${RESET} %s\n" "$*"
}

# Error level log output function
log_err() {
  printf "${RED}ERRO:${RESET} %s\n" "$*"
}

# A function to trim white spaces from the right of a string
# Example usage:
#   trimmed_string=$(trim "   myString   ")
#   echo "'${trimmed_string}'"
# Output: '   myString'
trim_right() {
  local string="$1"
  local whitespace="[![:space:]]"
  string="${string%"${string##*$whitespace}"}"
  echo "$string"
}

# A function to trim white spaces from the left of a string
# Example usage:
#   trimmed_string=$(trim "   myString   ")
#   echo "'${trimmed_string}'"
# Output: 'myString   '
trim_left() {
  local string="$1"
  local whitespace="[![:space:]]"
  string="${string#"${string%%$whitespace*}"}"
  echo "$string"
}

# A function to trim white spaces from both the left and right of a string
# Example usage:
#   trimmed_string=$(trim "   myString   ")
#   echo "'${trimmed_string}'"
# Output: 'myString'
trim() {
  local string="$1"
  string="$(trim_left "$string")"
  string="$(trim_right "$string")"
  echo "$string"
}
