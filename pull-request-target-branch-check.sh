#!/bin/bash

set -euo pipefail

usage() {
  echo "Usage:"
  echo "  $(basename "$0") SOURCE_BRANCH TARGET_BRANCH BRANCH_FILE"
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
  local source_branch=$1
  local target_branch=$2
  local branch_file=$3

  if ! git cat-file -e "$source_branch" 2>/dev/null; then
    echo_err "Branch \"$source_branch\" doesn't exist"
    return 1
  fi

  if ! git cat-file -e "$source_branch:$branch_file" 2>/dev/null; then
    echo_info "Skipping the check. Branch file \"$branch_file\" doesn't exist on \"$source_branch\""
    return 0
  fi

  local branch_file_content; branch_file_content=$(git cat-file blob "$source_branch:$branch_file")

  if [[ $branch_file_content == "$target_branch" ]]; then
    echo_info "The content of file \"$branch_file\" matches the target branch \"$target_branch\""
    return 0
  else
    echo_err "Wrong target branch. The content of \"$branch_file\" doesn't match the target branch \"$target_branch\""
    return 1
  fi
}

[[ $# -ne 3 ]] && { usage >&2; exit 1; }

[[ ${RUNNER_DEBUG:-} == "1" ]] && set -x

check_target_branch_file "$@"
