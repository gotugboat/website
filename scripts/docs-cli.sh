#!/bin/bash

ROOT_DIR=$(git rev-parse --show-toplevel)

source ${ROOT_DIR}/scripts/common.sh

# Defaults
TUGBOAT_PATH=${TUGBOAT_PATH}
DOC_TEMPLATE_DIR="docs"
DOCS_CLI_DIR="${DOC_TEMPLATE_DIR}/cli"
GENERATED_DOCS_DIR="generated"
GENERATED_DOCS_CLI_DIR="${GENERATED_DOCS_DIR}/cli"

# This controls what commands are documented. The order matters and shows how they will be
# displayed by the website. 'root' is special and means that the root command page will be generated.
# for nested commands use a '-' separator to indicate the parent command and sub command.
DOCUMENTED_COMMANDS="root build tag manifest manifest-create"

usage() {
  echo -e "A script to generate the tugboat cli command usage documentation \n\n"
  echo "Usage:"
  echo "${0} [OPTIONS]"
  echo ""
  echo "Options:"
  echo "    --debug            Output more information about the execution"
  echo "    --dry-run          Print out what will happen, do not execute"
  echo "-h, --help             Show this help message"
  echo "-p, --path             A local path to tugboat source code that will be run with go (requires installation of golang)"
  echo ""
}

# Removes the type hint from the help string
# i.e. The input: '--flag type some text'
# returns: '--flag some text'
remove_type_hint() {
  local string="$1"
  local type_hints="strings,string,bool"

  # Convert comma separated string to space separated string to loop
  local remove_strings=$(echo ${type_hints} | sed 's/,/ /g')

  local match=""
  local value=""
  local replaced_string="${string}"

  for str in $remove_strings; do
    match=$(echo "${replaced_string}" | grep -oE -- "--\w+((-\w+)+)?" | head -n 1)
    value=$(echo "${replaced_string}" | grep -oE -- "--\w+((-\w+)+)?\s${str}")
    if [[ -n ${value} ]]; then
      replaced_string=$(echo "${replaced_string}" | sed -E "s/--[[:alnum:]]+((-[[:alnum:]]+)+)?[[:space:]]${str}/${match}/g")
    fi
  done

  echo "${replaced_string}"
}

# Parse the help string for the default value
get_default_value_from_help() {
  local help_line="$1"

  local match=$(echo "${help_line}" | grep -oE -- "\(default\s"[[:graph:]]+"\)" | head -n 1)
  # find and set the default value to the text between the default output
  local default_value="$(echo "$match" | awk -F '[()]' '{print $2;}' | awk -F '[""]' '{print $2;}')"

  echo "${default_value}"
}

# Parse a line from the help string and returns the cleaned up description output
get_description_from_help() {
  local help_line="$1"
  local description=""

  description=$(echo "${help_line}" | awk '{print $0;}')

  # replace the default comment with nothing
  description=$(echo "${description}" | sed 's/ (default .*//')

  description="$(remove_type_hint "${description}")"

  # remove the flags from description
  local name_shorthand=$(echo "${help_line}" | awk '{print $1;}')
  if contains "${name_shorthand}" ","; then
    description=$(echo "${description}" | awk '{$1=$2=""; print $0;}')
  else
    description=$(echo "${description}" | awk '{$1=""; print $0;}')
  fi
  description=$(trim "${description}")

  echo "${description}"
}

# Generate a markdown table given a cli flag section as a string
# i.e.
#   -c, --config string             Custom path to a configuration file (optional)
#       --registry string           The docker registry to use (default "docker.io")
create_markdown_table() {
  local table="|     Option      | Default | Description |"
  table="${table}\n| --------------- | ------- | ----------- |"

  while read -r line; do
      name_shorthand=$(echo "${line}" | awk '{print $1;}')
      # handle the lines with a shortname flag
      if ends_with "${name_shorthand}" ","; then
        name_shorthand=$(echo "${line}" | awk '{print $1,$2;}')
      fi

      default_value=$(get_default_value_from_help "${line}")
      description=$(get_description_from_help "${line}")

      table="${table}\n| \`${name_shorthand}\` | ${default_value} | ${description} |"
  done <<< "$1"
  echo "${table}"
}

template_root_command() {
  local file=$1
  local command_output=$2
  local available_commands=$(echo "$command_output" | sed -n '/Available Commands/,/Flags/p' | sed '/^Available Commands:/d;/^Flags:/d')
  local see_also="## See also\n"

  # loop over each line and create the see also links
  while read -r line; do
      cmd_name=$(echo "$line" | awk '{print $1;}')

      if [[ "${cmd_name}" == "help" ]]; then
        log_debug "see also section: skipping help command"
        continue
      fi

      description=$(echo "$line" | awk '{ s = ""; for (i = 2; i <= NF; i++) s = s $i " "; print s }')
      description=$(trim "${description}")
      
      # append to section
      if ! [[ "${cmd_name}" =~ ^(completion|version)$ ]]; then
        see_also="${see_also}- [${cmd_name}]({{< relref \"tugboat-${cmd_name}\">}}) - ${description}\n"
      fi
  done <<< "$available_commands"

  replace_text "__SEE_ALSO_SECTION__" "${see_also}" "${file}"
}

execute_tugboat_command() {
  # Check that at least one argument was passed
  if [ $# -eq 0 ]; then
    echo "Usage: execute_tugboat_command [<arg1> <arg2> ...]"
    return 1
  fi

  local cmd=($@)

  if [[ -n ${TUGBOAT_PATH} ]]; then
    # Use local path to run the tugboat source code directly
    cd "${TUGBOAT_PATH}"
    local cmd_output=$(go run cmd/tugboat/main.go "${cmd[@]}" 2>&1)
    cd "${ROOT_DIR}"
  else
    # Assume tugboat is installed
    local cmd_output=$(tugboat "${cmd[@]}" 2>&1)
  fi
  
  echo "${cmd_output}"
}

get_parent_cmd_description() {
  # Check that at least one argument was passed
  if [ $# -eq 0 ]; then
    local parent_cmd=""
  else 
    local parent_cmd=$1
  fi
  local description=""

  local cmd_output=$(execute_tugboat_command ${parent_cmd} --help)
  description="$(echo "${cmd_output}" | head -n 1)"

  echo "${description}"
}

check_requirements() {
  log_debug "tugboat path: '${TUGBOAT_PATH}'"
  log_debug "tugboat binary: '$(which tugboat)'"

  if [[ -z ${TUGBOAT_PATH} ]] && ! check_command tugboat; then
    log_err "Unable to generate the cli documentation, no set TUGBOAT_PATH or tugboat command found"
    exit 1
  fi

  if [[ -n ${TUGBOAT_PATH} ]] && ! check_command go; then
    log_err "Unable to generate the cli documentation, no installation of golang found"
    exit 1
  fi
}

clean_generated_content() {
  # remove the old generated cli docs
  if directory_exists "${GENERATED_DOCS_DIR}"; then
    log_info "Cleaning generated cli folder (${GENERATED_DOCS_CLI_DIR})"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      rm -rf ${ROOT_DIR}/${GENERATED_DOCS_CLI_DIR}/*
    fi
  fi

  # create a fresh generated folder if needed
  if ! directory_exists "${GENERATED_DOCS_DIR}"; then
    log_debug "Creating generated docs folder (./${GENERATED_DOCS_DIR})"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      mkdir -p "${GENERATED_DOCS_DIR}"
    fi
  fi
}

move_compiled_documentation() {
  if ! directory_exists "${GENERATED_DOCS_CLI_DIR}"; then
    log_debug "Creating directory: ${GENERATED_DOCS_CLI_DIR}"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      mkdir -p "${GENERATED_DOCS_CLI_DIR}"
    fi
  fi

  log_info "Moving compiled cli documentation to: ${GENERATED_DOCS_CLI_DIR}"

  # move compiled documentation to the docs root
  if [[ "${IS_DRY_RUN}" != "true" ]]; then
    cp ${DOCS_CLI_DIR}/_index.md ${GENERATED_DOCS_CLI_DIR}
    mv ${DOCS_CLI_DIR}/tugboat*.md ${GENERATED_DOCS_CLI_DIR}
  fi
}

generate_documentation() {
  # Start to compile the command line interface documentation
  value="$(find ${DOCS_CLI_DIR} -type f -name "tugboat*.md" | wc -l | sed 's/^[ ]*//')"
  if [ "${value}" != "0" ]; then
    log_info "Removing existing compiled cli docs"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      rm -r ${DOCS_CLI_DIR}/tugboat*.md
    fi
  fi

  log_info "Generating documentation pages for each cli command"

  command_weight=540
  for cmd in $DOCUMENTED_COMMANDS; do
    # split the command by - to detect sub commands
    IFS="-" read -ra cmds <<< "$cmd"
    command=${cmds[0]}
    sub_command=${cmds[1]}

    options="${command}"
    cmd_title="$(echo $cmd | cut -d "-" -f 1)"
    if [[ -n "${sub_command}" ]]; then
      log_debug "there is a sub command: ${sub_command}"
      options="${command} ${sub_command}"
      cmd_title="$(echo $cmd | cut -d "-" -f 1) $(echo $cmd | cut -d "-" -f 2)"
    fi

    if [[ "$cmd" == "root" ]]; then
      doc_tile="tugboat"
      options=""
    else
      doc_tile="tugboat ${cmd_title}"
    fi

    log_info "Generating page for '${doc_tile}'"

    log_debug "Command to run: '${options}'"

    # run the command and capture output
    cmd_output=$(execute_tugboat_command ${options} --help)
    log_debug "Command output:"
    log_debug "$cmd_output" # this will preserve new lines

    if [[ ${cmd_output} == *"not found"* || ${cmd_output} == *"unknown command"* ]]; then
      log_err "there was an issue building the docs for '${doc_tile}'"
      continue
    fi

    doc_desc="$(echo "${cmd_output}" | head -n 1)"
    
    has_commands=$(echo "$cmd_output" | grep "Available Commands:" | wc -l | sed 's/^[ ]*//')
    if [[ "${has_commands}" == 0 ]]; then
      # parse the output to Usage: ... Flags: then remove the lines that start with 'Usage:' and 'Flags:'
      usage_section=$(echo "$cmd_output" | sed -n '/Usage/,/Flags/p' | sed '/^Usage:/d;/^Flags:/d')
    else
      # parse the sub command output between Usage: ... Available Commands:
      usage_section=$(echo "$cmd_output" | sed -n '/Usage/,/Available Commands/p' | sed '/^Usage:/d;/^Available Commands:/d')
    fi

    usage_section=$(trim_left "${usage_section}")
    # count if tugboat is seen 2 times
    word="tugboat"
    count=$(echo "$usage_section" | tr -d '[[:space:]]' | grep -o "$word" | wc -l)
    count=$(trim_left "${count}")
    # find the index of the second word
    if [[ "${count}" != "1" ]]; then
      # pick the first command to show in the docs
      usage_section="$(echo "${usage_section}" | head -n 1)"
    fi

    doc_usage="${usage_section}"
    log_debug "Doc usage: \"${doc_usage}\""

    options_section=$(echo "$cmd_output" | sed -n '/Flags/,/Global Flags/p' | sed '/^Flags:/d;/^Global Flags:/d;/^Use/d')

    if [[ "${IS_DEBUG}" == "true" ]]; then
      printf "${DIM}"
      echo "=========== options for '${options}' ==========="
      echo "${options_section}"
      echo "================================================"
      printf "${RESET}"
    fi

    log_debug "Creating table for options for '${options}'"
    doc_command_options=$(create_markdown_table "$options_section")
    # replace / with \/
    doc_command_options=$(echo "${doc_command_options}" | sed 's:/:\\/:g')

    if [[ "${IS_DEBUG}" == "true" ]]; then
      printf "${DIM}"
      echo "=========== Generated Options Table ==========="
      echo "${doc_command_options}"
      echo "==============================================="
      printf "${RESET}"
    fi

    options_section=$(echo "$cmd_output" | sed -n '/Global Flags/,$p' | sed '/^Global Flags:/d')
    doc_global_options="$(create_markdown_table "$options_section")"
    
    # get parent command information
    if [[ -n "${sub_command}" ]]; then
      # this is a sub-command
      doc_parent_cmd="${command}"
      doc_parent_ref="tugboat-${command}"
      doc_parent_cmd_desc="$(get_parent_cmd_description ${doc_parent_cmd})"
    else
      # this is a not sub-command
      doc_parent_cmd="tugboat"
      doc_parent_ref="tugboat"
      doc_parent_cmd_desc="$(get_parent_cmd_description)"
    fi

    # copy the template to the new file name
    filename="${DOCS_CLI_DIR}/tugboat-${cmd}.md"
    template_file="${DOCS_CLI_DIR}/template.md"
    if [[ "$cmd" == "root" ]]; then
      filename="${DOCS_CLI_DIR}/tugboat.md"
      template_file="${DOCS_CLI_DIR}/template-root.md"
    fi
    
    log_debug "Copying template file (${template_file} -> ${filename})"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      cp ${template_file} ${filename}
    fi

    if [[ "$cmd" == "root" ]]; then
      log_debug "Making root command template"
      if [[ "${IS_DRY_RUN}" != "true" ]]; then
        template_root_command "${filename}" "${cmd_output}"
      fi
    fi

    # Replace template values
    log_debug "Replace template placeholders with processed values"

    log_debug "Updating document draft status"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      replace_text "draft: true" "draft: false" "$filename"
    fi

    log_debug "Updating document weight"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      replace_text "weight: 540" "weight: ${command_weight}" "$filename"
    fi

    log_debug "Updating document title"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      replace_text "__TITLE__" "${doc_tile}" "$filename"
    fi

    log_debug "Updating document short description"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      replace_text "__COBRA_SHORT_DESCRIPTION__" "${doc_desc}" "$filename"
    fi

    log_debug "Updating document usage"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      replace_text "__TUGBOAT_USAGE__" "${doc_usage}" "$filename"
    fi

    log_debug "Updating document command options"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      replace_text "__TUGBOAT_COMMAND_OPTIONS__" "${doc_command_options}" "$filename"
    fi

    log_debug "Updating document global options"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      replace_text "__TUGBOAT_GLOBAL_OPTIONS__" "${doc_global_options}" "$filename"
    fi

    log_debug "Updating document parent command"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      replace_text "__PARENT_COMMAND__" "${doc_parent_cmd}" "$filename"
    fi

    log_debug "Updating document parent ref"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      replace_text "__PARENT_COMMAND_REF__" "${doc_parent_ref}" "$filename"
    fi

    log_debug "Updating document parent description"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      replace_text "__PARENT_COMMAND_DESCRIPTION__" "${doc_parent_cmd_desc}" "$filename"
    fi

    # increase the command document weight
    command_weight=$((command_weight+1))
  done

  move_compiled_documentation

  if [[ "${IS_DRY_RUN}" != "true" ]]; then
    log_info "The cli command usage documentation was generated successfully"
  fi
}

main() {
  # Parse options
  while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
      -h|--help)
      usage
      exit 0
      ;;
      --debug)
      IS_DEBUG=true
      ;;
      --dry-run)
      IS_DRY_RUN=true
      ;;
      -p|--path)
      TUGBOAT_PATH=$2
      shift
      ;;
      *)
      echo "Unknown option: $key"
      usage
      exit 1
      ;;
    esac
    shift
  done

  setup_color

  if [[ "${IS_DRY_RUN}" == "true" ]]; then
    log_warn "Dry run in progress"
  fi

  check_requirements
  clean_generated_content
  generate_documentation

}

main "$@"
