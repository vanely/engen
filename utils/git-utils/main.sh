#!/bin/bash

function get_engen_fs_location() {
  if [[ -z $(grep "ENGEN_FS_LOCATION" ~/.profile) ]] ; then
    # "dirname" returns the path up to but not including the final dir
    REMOVED_FINAL_DIR=$(dirname $(pwd))
    DOUBLY_REMOVED_FINAL_DIR=$(dirname ${REMOVED_FINAL_DIR})
    echo ${DOUBLY_REMOVED_FINAL_DIR}
  else
    # will be exported from ~/.profile
    echo ENGEN_FS_LOCATION
  fi
}

# spellcheck source="${HOME}/engen/utils/git-utils/git_update_repos.sh"
source "$(get_engen_fs_location)/utils/git-utils/git_update_repos.sh"
# spellcheck source="${HOME}/engen/utils/helpers/validation.sh"
source "$(get_engen_fs_location)/utils/helpers/validation.sh"
# spellcheck source="${HOME}/engen/utils/git-utils/git_utils.sh"
source "$(get_engen_fs_location)/utils/git-utils/git_utils.sh"

#arg1=CONTEXT_ROOT_DIR_NAME
git_update() {
  local CONTEXT_ROOT_DIR_NAME
  CONTEXT_ROOT_DIR_NAME="${1}"
  choose_repos_to_status_or_update "update" "${CONTEXT_ROOT_DIR_NAME}"
}

#arg1=CONTEXT_ROOT_DIR_NAME
git_status() {
  local CONTEXT_ROOT_DIR_NAME
  CONTEXT_ROOT_DIR_NAME="${1}"
  choose_repos_to_status_or_update "status" "${CONTEXT_ROOT_DIR_NAME}"
}

create_git_repo() {
  local name
  local GIT_USER
  GIT_USER="${name[2]}"
  name=($(grep "name" ~/.gitconfig))

  echo
  echo "========================================================================================="
  echo "Signing into Github..."
  github_auth
  echo "Signed into Github."
  echo

  if [[ -n "${GIT_USER}" ]] ; then 
    local REPO_LIST
    local REPO_ARR
    local REPO_NAME_EXISTS
    REPO_LIST=$(gh repo list "${GIT_USER}" --source)
    REPO_ARR=()
    REPO_NAME_EXISTS="false"

    # gh repo list user_name --source
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
  else
    echo
    echo "a global reference to your git config is needed to create repos"
    echo "you'll need to run the following git commands"
    echo
    echo "git config --global user.name '<user_name>'"
    echo "git config --global user.email '<email>'"
    echo
    echo "replace everything inside of the single 'quotes' with your respective credentials"
    echo
  fi

  echo "Signing out of Github..."
  github_deauth
  echo "========================================================================================="
}

delete_git_repo() {
  local name
  local GIT_USER
  name=($(grep "name" ~/.gitconfig))
  GIT_USER="${name[2]}"
  
  echo
  echo "========================================================================================="
  echo "Signing into Github..."
  github_auth
  echo "Signed into Github."
  echo

  if [[ -n "${GIT_USER}" ]] ; then
    local REPO_LIST
    local REPO_ARR
    local REPO_NAME_EXISTS
    REPO_LIST=$(gh repo list "${GIT_USER}" --source)
    REPO_ARR=()
    REPO_NAME_EXISTS="false"

    # gh repo list user_name --source
    for REPO in ${REPO_LIST}
    do
      IFS="/" read -r -a REPO_TOUPLE <<< ${REPO}
      REPO_ARR+=(${REPO_TOUPLE[1]})
    done
    local REPO_ARR_LEN
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
  else
    echo
    echo "a global reference to your git config is needed to delete repos"
    echo "you'll need to run the following git commands"
    echo
    echo "git config --global user.name '<user_name>'"
    echo "git config --global user.email '<email>'"
    echo
    echo "replace everything inside of the single 'quotes' with your respective credentials"
    echo
  fi

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

# arg1=CONTEXT_ROOT_DIR_NAME
# arg2=REF_TO_FS_LOCATION
git_utils() {
  local CONTEXT_ROOT_DIR_NAME
  local REF_TO_FS_LOCATION
  CONTEXT_ROOT_DIR_NAME="${1}"
  REF_TO_FS_LOCATION="${2}"

  echo
  echo "CONTEXT_ROOT_DIR_NAME: ${1}"
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
      if [[ "${index}" == 0 ]] || [[ "${index}" == 1 ]] ; then
        ${GIT_UTILS_ARRAY[index]} "${CONTEXT_ROOT_DIR_NAME}"
      else
        ${GIT_UTILS_ARRAY[index]}
      fi
      break
    fi
  done
}
