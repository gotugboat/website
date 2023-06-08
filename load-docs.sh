#!/bin/bash

ROOT_DIR=$(git rev-parse --show-toplevel)

usage() {
  echo -e "A script to load the tugboat documentation using the live source code \n\n"
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

docs_gen_args=""
if [[ "${IS_DEBUG}" == "true" ]]; then
  docs_gen_args="${docs_gen_args} --debug"
fi

if [[ "${IS_DRY_RUN}" == "true" ]]; then
  docs_gen_args="${docs_gen_args} --dry-run"
fi

if [[ "${SKIP_CLI}" == "true" ]]; then
  docs_gen_args="${docs_gen_args} --skip-cli"
fi

if [[ -n "${TUGBOAT_PATH}" ]]; then
  docs_gen_args="${docs_gen_args} --path ${TUGBOAT_PATH}"
fi

${ROOT_DIR}/scripts/docs-generate.sh ${docs_gen_args}
