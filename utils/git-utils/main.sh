#!/bin/bash

# spellcheck source="${HOME}/engen/utils/git-utils/git_update_repos.sh"
source "${HOME}/engen/utils/git-utils/git_update_repos.sh"
# spellcheck source="${HOME}/engen/utils/helpers/validation.sh"
source "${HOME}/engen/utils/helpers/validation.sh"
# spellcheck source="${HOME}/engen/utils/git-utils/git_utils.sh"
source "${HOME}/engen/utils/git-utils/git_utils.sh"

git_update() {
  choose_repos_to_status_or_update "update"
}

git_status() {
  choose_repos_to_status_or_update "status"
}

create_git_repo() {
  echo
  echo "========================================================================================="
  echo "Signing into Github..."
  github_auth
  echo "Signed into Github."
  echo

  REPO_LIST=$(gh repo list vanely --source)
  REPO_ARR=()
  REPO_NAME_EXISTS="false"
  # gh repo list vanely --source
  for REPO in ${REPO_LIST}
  do
    IFS="/" read -r -a REPO_TOUPLE <<< ${REPO}
    REPO_ARR+=(${REPO_TOUPLE[1]})
  done

  echo
  echo -n "Repo Name > "
  read -r new_repo_name

  while "true"
  do
    for REPO_NAME in ${REPO_ARR[@]}
    do
      if [[ "${REPO_NAME}" == "${new_repo_name}" ]] ; then
        REPO_NAME_EXISTS="true"
      fi
    done

    if [[ "${REPO_NAME_EXISTS}" == "true" ]] ; then
      REPO_NAME_EXISTS="false"
      echo 
      echo "Repo: ${new_repo_name} already exists"
      echo -n "Repo Name > "
      read -r new_repo_name
    else
      echo
      echo "Enter repo access level: 'public' or 'private'"
      echo
      echo -n "Repo Access Level > "
      read -r repo_access_level
      create_repo_with_gh_cli "${new_repo_name}" "${repo_access_level}"
      break
    fi
  done

  echo "Signing out of Github..."
  github_deauth
  echo "========================================================================================="
}

delete_git_repo() {
  echo
  echo "========================================================================================="
  echo "Signing into Github..."
  github_auth
  echo "Signed into Github."
  echo

  REPO_LIST=$(gh repo list vanely --source)
  REPO_ARR=()
  REPO_NAME_EXISTS="false"
  # gh repo list vanely --source
  for REPO in ${REPO_LIST}
  do
    IFS="/" read -r -a REPO_TOUPLE <<< ${REPO}
    REPO_ARR+=(${REPO_TOUPLE[1]})
  done
  REPO_ARR_LEN="${#REPO_ARR[@]}"

  # generate list of existing repo names
  for (( i=0; i<"${REPO_ARR_LEN}"; i++ ))
  do
    echo "${i}: ${REPO_ARR[i]}"
  done
  echo
  echo "From the above list choose a repo to delete by its index"
  echo "or as a list of space separated indexes. EX: 0 1 2"
  echo
  echo -n "> "
  read -r indexes

  while "true"
  do
    if [[ "$(input_is_number_with_possible_spaces "${indexes}")" == "true" ]] ; then
      for i in ${indexes[@]}
      do
        delete_repo_with_gh_cli "${REPO_ARR[i]}"
      done
      break
    else
      echo
      echo "Input must be a number in the above list, or 'all'"
      echo
      echo -n "> "
      read -r indexes
    fi
  done

  echo "Signing out of Github..."
  github_deauth
  echo "========================================================================================="
}

GIT_UTILS_ARRAY=(
  git_update
  git_status
  create_git_repo
  delete_git_repo
)
GIT_UTIL_OPTION_NAMES_ARRAY=(
  'Update Git Repo(s)'
  'Status of Git Repo(s)'
  'Create Repo'
  'Delete Repo'
)
GIT_UTILS_ARRAY_LEN="${#GIT_UTILS_ARRAY[@]}"

git_utils() {
  echo "========================================================================================="
  echo "================================== [--GIT UTILS--] ======================================"
  echo "========================================================================================="
  echo
  for (( i=0; i<"${GIT_UTILS_ARRAY_LEN}"; i++ ))
  do
    echo "${i}: ${GIT_UTIL_OPTION_NAMES_ARRAY[i]}"
  done
  echo
  echo "Choose an option from the list above. EX:"
  echo "0 1 2"
  echo
  echo -n "> "
  read -r index

  while "true" 
  do
    if [[ "$(input_is_number "${index}")" != "true" ]] ; then
      echo
      echo "Input must be a number in the above list"
      echo
      echo -n "> "
      read -r index
    else
      ${GIT_UTILS_ARRAY[index]}
      break
    fi
  done
}
