#!/bin/bash

set -euo pipefail

usage() {
  echo "Usage:"
  echo "  $(basename "$0") BRANCH_FILE"
}

# shellcheck disable=SC2001
echo_err() {
  echo "$@" | sed 's/^/ERROR: /' >&2
}

# shellcheck disable=SC2001
echo_info() {
  echo "$@" | sed 's/^/INFO: /'
}

check_target_branch_file() {
  local branch_file=$1
  
  local target_branch=$GITHUB_BASE_REF

  if [[ ! -f "$branch_file" ]]; then
    echo_info "Skipping the check. Branch file \"$branch_file\" doesn't exist"
    return 0 
  fi

  if [[ $(cat "$branch_file") == "$target_branch" ]]; then
    echo_info "The content of file \"$branch_file\" matches the target branch \"$target_branch\""
    return 0
  else
    echo_err "Wrong target branch. The content of \"$branch_file\" doesn't match the target branch \"$target_branch\""
    return 1
  fi
}

[[ $# -ne 1 ]] && { usage >&2; exit 1; }

[[ ${RUNNER_DEBUG:-} == "1" ]] && set -x

check_target_branch_file "$@"
