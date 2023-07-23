#!/bin/bash

ROOT_DIR=$(git rev-parse --show-toplevel)

source ${ROOT_DIR}/scripts/common.sh

# Defaults
CONTENT_DOCS_DIR="content/docs"
DOC_TEMPLATE_DIR="docs"
GENERATED_DOCS_DIR="generated"
REPOSITORY="gotugboat/tugboat"
REPO_COPY_DIR="repos/tugboat"

usage() {
  echo -e "A script to generate the tugboat documentation \n\n"
  echo "Usage:"
  echo "${0} [OPTIONS]"
  echo ""
  echo "Options:"
  echo "    --debug            Output more information about the execution"
  echo "    --dry-run          Print out what will happen, do not execute"
  echo "-h, --help             Show this help message"
  echo "-p, --path             A local path to tugboat source code that will be run with go (requires installation of golang)"
  echo "    --skip-cli         Skip generating the command line interface documentation"
  echo ""
}

clean_generated_content() {
  # remove the old generated docs
  if directory_exists "${GENERATED_DOCS_DIR}"; then
    log_info "Cleaning contents of the generated cli folder (./${GENERATED_DOCS_DIR})"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      rm -rf ${GENERATED_DOCS_DIR}/*
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

# clones the tugboat repository locally
clone_project_repository() {
  log_info "Cloning project repository (${REPOSITORY}) to ${REPO_COPY_DIR}"
  if [[ "${IS_DRY_RUN}" != "true" ]]; then
    local tag=$(cat ${ROOT_DIR}/data/tugboat.yml | grep version | awk -F ': ' '{print $2}')
    
    log_debug "checking out the ${tag} branch"
    
    if ! git clone --branch "${tag}" "https://github.com/${REPOSITORY}.git" "${REPO_COPY_DIR}" ; then
      log_err "Cloning the ${REPOSITORY} repository failed"
      exit 1
    fi
  fi
}

prepare_doc_generation() {
  # move document sections into the docs folder
  log_info "Copying ${DOC_TEMPLATE_DIR}/_index.md to ${GENERATED_DOCS_DIR}"
  if [[ "${IS_DRY_RUN}" != "true" ]]; then
    cp "${DOC_TEMPLATE_DIR}/_index.md" "${GENERATED_DOCS_DIR}"
  fi
}

prepare_getting_started_documentation() {
  log_info "Preparing getting started documentation"

  if ! directory_exists "${GENERATED_DOCS_DIR}/getting-started"; then
    log_debug "Creating directory: ${GENERATED_DOCS_DIR}/getting-started"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      mkdir -p "${GENERATED_DOCS_DIR}/getting-started"
    fi
  fi

  if [[ "${IS_DRY_RUN}" != "true" ]]; then
    log_debug "Copying getting started documentation (${DOC_TEMPLATE_DIR}/getting-started -> ${GENERATED_DOCS_DIR})"
    cp -r "${DOC_TEMPLATE_DIR}/getting-started" "${GENERATED_DOCS_DIR}"
  fi

  log_debug "Setting install version number"
  if [[ "${IS_DRY_RUN}" != "true" ]]; then
    tugboat_docs_version=$(cat ${ROOT_DIR}/data/tugboat.yml | grep version | awk -F ': ' '{print $2}' | sed 's/^.//')
    replace_text "__TUGBOAT_VERSION__" "${tugboat_docs_version//$'\n'/\\n}" "${GENERATED_DOCS_DIR}/getting-started/installation.md"
  fi
}

prepare_configuration_documentation() {
  log_info "Preparing configuration documentation"

  if ! directory_exists "${GENERATED_DOCS_DIR}/configuration"; then
    log_debug "Creating directory: ${GENERATED_DOCS_DIR}/configuration"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      mkdir -p "${GENERATED_DOCS_DIR}/configuration"
    fi
  fi

  if [[ "${IS_DRY_RUN}" != "true" ]]; then
    log_debug "Copying configuration documentation (${DOC_TEMPLATE_DIR}/configuration -> ${GENERATED_DOCS_DIR})"
    cp -r "${DOC_TEMPLATE_DIR}/configuration" "${GENERATED_DOCS_DIR}"
  fi
}

prepare_help_documentation() {
  log_info "Preparing help documentation"

  if ! directory_exists "${GENERATED_DOCS_DIR}/help"; then
    log_debug "Creating directory: ${GENERATED_DOCS_DIR}/help"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      mkdir -p "${GENERATED_DOCS_DIR}/help"
    fi
  fi

  log_debug "Copying help documentation (${DOC_TEMPLATE_DIR}/help -> ${GENERATED_DOCS_DIR})"
  if [[ "${IS_DRY_RUN}" != "true" ]]; then
    cp -r "${DOC_TEMPLATE_DIR}/help" "${GENERATED_DOCS_DIR}"
  fi
}

prepare_continuous_integration() {
  log_info "Preparing continuous integration documentation"

  if ! directory_exists "${GENERATED_DOCS_DIR}/continuous-integration"; then
    log_debug "Creating directory: ${GENERATED_DOCS_DIR}/continuous-integration"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      mkdir -p "${GENERATED_DOCS_DIR}/continuous-integration"
    fi
  fi

  if [[ "${IS_DRY_RUN}" != "true" ]]; then
    log_debug "Copying continuous integration documentation (${DOC_TEMPLATE_DIR}/continuous-integration -> ${GENERATED_DOCS_DIR})"
    cp -r "${DOC_TEMPLATE_DIR}/continuous-integration" "${GENERATED_DOCS_DIR}"
  fi
}

generate_page_contributing_guidelines() {
  log_info "Generating the contributing guidelines page"

  log_debug "Setting page content"
  if [[ "${IS_DRY_RUN}" != "true" ]]; then
    contribution_guidelines=$(cat ${REPO_COPY_DIR}/.github/CONTRIBUTING.md | sed 's:/:\\/:g')
    replace_text "__TUGBOAT_CONTRIBUTION_GUIDELINES__" "${contribution_guidelines//$'\n'/\\n}" "${GENERATED_DOCS_DIR}/help/contribution-guidelines.md"
  fi

  # fix the markdown links to reference correctly
  # replace ../LICENSE with https://github.com/gotugboat/tugboat/blob/main/LICENSE
  log_debug "Replace license markdown links to reference back to github"
  if [[ "${IS_DRY_RUN}" != "true" ]]; then
    license_url=$(echo github.com/${REPOSITORY}/blob/main/LICENSE | sed 's:/:\\/:g')
    replace_text "\.\.\/LICENSE" "https:\/\/${license_url//$'\n'/\\n}" "${GENERATED_DOCS_DIR}/help/contribution-guidelines.md"
  fi

  # replace ./CODE_OF_CONDUCT.md with https://github.com/gotugboat/tugboat/tree/main/.github/
  log_debug "Replace code of conduct markdown links to reference back to github"
  if [[ "${IS_DRY_RUN}" != "true" ]]; then
    code_of_conduct_url="{{< relref \"code-of-conduct\" >}}"
    replace_text "\.\/CODE_OF_CONDUCT\.md" "${code_of_conduct_url//$'\n'/\\n}" "${GENERATED_DOCS_DIR}/help/contribution-guidelines.md"
  fi

  log_debug "Modifying page content"
  if [[ "${IS_DRY_RUN}" != "true" ]]; then
    remove_text="# Contributing"
    replace_text "${remove_text}" "" "${GENERATED_DOCS_DIR}/help/contribution-guidelines.md"
  fi
}

generate_page_code_of_conduct() {
  log_info "Generating the code of conduct page"

  log_debug "Setting page content"
  if [[ "${IS_DRY_RUN}" != "true" ]]; then
    code_of_conduct=$(cat ${REPO_COPY_DIR}/.github/CODE_OF_CONDUCT.md | sed 's:/:\\/:g')
    replace_text "__TUGBOAT_CODE_OF_CONDUCT__" "${code_of_conduct//$'\n'/\\n}" "${GENERATED_DOCS_DIR}/help/code-of-conduct.md"
  fi

  log_debug "Modifying page content"
  if [[ "${IS_DRY_RUN}" != "true" ]]; then
    remove_text="# Contributor Covenant Code of Conduct"
    replace_text "${remove_text}" "" "${GENERATED_DOCS_DIR}/help/code-of-conduct.md"
  fi
}

generate_page_example_file() {
  log_info "Generating the configuration example file page"

  log_info "Adding example config file to docs"
  log_debug "Setting page content"
  if [[ "${IS_DRY_RUN}" != "true" ]]; then
    # replace / with \/ in the output
    example_config=$(cat ${REPO_COPY_DIR}/example.tugboat.yaml | sed 's:/:\\/:g')
    # this will replace the newline characters with the escape sequence
    replace_text "__EXAMPLE_TUGBOAT_FILE_CONTENT__" "${example_config//$'\n'/\\n}" "${GENERATED_DOCS_DIR}/configuration/example-file.md"
  fi
}

generate_cli_documentation() {
  if [[ "${SKIP_CLI}" == "true" ]]; then
    log_info "Skipping command line interface documentation"
    return
  fi

  log_info "Generating command line interface documentation"

  gen_cli_args=""
  if [[ "${IS_DEBUG}" == "true" ]]; then
    gen_cli_args="${gen_cli_args} --debug"
  fi

  if [[ "${IS_DRY_RUN}" == "true" ]]; then
    gen_cli_args="${gen_cli_args} --dry-run"
  fi

  if [[ -n "${TUGBOAT_PATH}" ]]; then
    gen_cli_args="${gen_cli_args} --path ${TUGBOAT_PATH}"
  fi

  ./scripts/docs-cli.sh ${gen_cli_args}

  rc=$?
  if [[ "${rc}" != "0" ]]; then
    log_err "failed to generate command line interface documentation"
  fi
}

finalize_generated_docs() {
  log_info "Finalizing generated documentation"

  log_debug "Moving generated documentation to ${CONTENT_DOCS_DIR}"
  # If everything so far as worked, remove the old docs
  if directory_exists "${CONTENT_DOCS_DIR}"; then
    log_debug "Cleaning existing content docs folder"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      rm -r "${CONTENT_DOCS_DIR}"
    fi
  fi

  # create the fresh docs folder
  if ! directory_exists "${CONTENT_DOCS_DIR}"; then
    log_debug "Creating folder (${CONTENT_DOCS_DIR})"
    if [[ "${IS_DRY_RUN}" != "true" ]]; then
      mkdir -p "${CONTENT_DOCS_DIR}"
    fi
  fi

  log_debug "Copying generated documentation to docs (${GENERATED_DOCS_DIR}/* -> ${CONTENT_DOCS_DIR})"
  if [[ "${IS_DRY_RUN}" != "true" ]]; then
    cp -r ${GENERATED_DOCS_DIR}/* ${CONTENT_DOCS_DIR}
  fi

  log_info "Documentation generation completed"
}


generate_documentation() {
  log_info "Generating the documentation"

  prepare_doc_generation

  prepare_getting_started_documentation
  prepare_configuration_documentation
  prepare_continuous_integration
  prepare_help_documentation

  generate_page_contributing_guidelines
  generate_page_code_of_conduct
  generate_page_example_file

  generate_cli_documentation

  finalize_generated_docs
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
      --skip-cli)
      SKIP_CLI=true
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

  clean_generated_content

  if ! directory_exists "${REPO_COPY_DIR}"; then
    clone_project_repository
  fi

  generate_documentation

}

main "$@"
