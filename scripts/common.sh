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

# A function to terminate a program with an error message
exit_err() {
  local message="$1"

  log_err "$message"
  exit 1
}

# A function to check if a string contains a substring
contains() {
  local string="$1"
  local substring="$2"

  [[ "${string}" == *"${substring}"* ]]
}

# A function that returns true if a directory exists, false otherwise
directory_exists() {
  [[ -d "$1" ]]
}

# A function that returns true if a file exists, false otherwise
file_exists() {
  [[ -f "$1" ]]
}

# A function to check if a string starts with a prefix
starts_with() {
  [[ "$1" == "$2"* ]]
}

# A function to check if a string ends with a suffix
ends_with() {
  [[ "$1" == *"$2" ]]
}

# A function to replace a string using three arguments: the pattern to search
# for, the replacement text, and the file to modify.
# Example usage:
#   replace_text "foo" "bar" "file.txt"
replace_text() {
  local pattern="$1"
  local replacement="$2"
  local file="$3"

  if ! file_exists "$file"; then
    exit_err "The file '$file' does not exist"
  fi

  if [[ $(uname) == "Darwin" ]]; then
    sed -i '' "s/$pattern/$replacement/g" "$file" || exit_err "Failed to replace text using sed"
  else
    sed -i "s/$pattern/$replacement/g" "$file" || exit_err "Failed to replace text using sed"
  fi
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
