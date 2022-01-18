#!/bin/bash

source ./utils/git-utils/git_update_repos.sh

git_update() {
  choose_repos_to_status_or_update "update"
}

git_status() {
  choose_repos_to_status_or_update "status"
}

GIT_UTILS_ARRAY=(
  git_update
  git_status
)
GIT_UTIL_OPTION_NAMES_ARRAY=(
  'Update Git Repo(s)'
  'Status of Git Repo(s)'
)
GIT_UTILS_ARRAY_LEN="${#GIT_UTILS_ARRAY[@]}"

git_utils() {
  for (( i=0; i<"${GIT_UTILS_ARRAY_LEN}"; i++ ))
  do
    echo "${i}: ${GIT_UTIL_OPTION_NAMES_ARRAY[i]}"
  done
  echo
  echo "Choose an option from the list above. EX:"
  echo "0 1 2"
  echo
  echo -n "> "
  read -r indexes

  for i in ${indexes[@]}
  do
    ${GIT_UTILS_ARRAY[i]}
  done
}
