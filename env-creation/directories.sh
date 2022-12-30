#!/bin/bash

function get_engen_fs_location() {
  if [[ -z $(grep "ENGEN_FS_LOCATION" ~/.profile)  ]] ; then
    local FINAL_DIR="${PWD##*/}" 
    local REMOVED_FINAL_DIR="${PWD/${FINAL_DIR}/}"
    echo "${REMOVED_FINAL_DIR}"
  else
    # will be exported from ~/.profile
    echo ENGEN_FS_LOCATION
  fi
}

# find relative location of engen(depth search)
source "$(get_engen_fs_location)/utils/git-utils/git_utils.sh"
# source "${HOME}/engen/utils/git-utils/git_utils.sh"

# arg1=PATH_TO_CONFIG
# arg2=REF_TO_FS_LOCATION
update_dir_tree() {
  # import config file
  source "${1}"

  local REF_TO_FS_LOCATION
  REF_TO_FS_LOCATION="${2}"

  if [[ -f "${1}" ]] ; then

    # check for and add new base directories
    if [[ -n "${BASE_DIR_ARRAY}" ]] ; then
      BASE_DIR_ARR_LEN="${#BASE_DIR_ARRAY[@]}"
      for (( i=0; i<"${BASE_DIR_ARR_LEN}"; i++ ))
      do
        if [[ ! -d "${BASE_DIR_ARRAY[i]}" ]] ; then
          echo
          echo "========================================================================================="
          echo "Adding base directory..."
          echo "${BASE_DIR_ARRAY[i]}"
          # -p flag allows for the crewation of nested dirs
          mkdir -p "${BASE_DIR_ARRAY[i]}"
        fi
      done
    else
      echo "It seems your BASE_DIR_ARRAY is empty"
    fi

    # check for and add new project directories, and clone their corresponding projects
    if [[ -n "${DIR_ARRAY}" ]] && [[ -n "${CORRESPONDING_PROJECTS_ARRAY}" ]] ; then
      DIR_ARR_LEN="${#DIR_ARRAY[@]}"
      # will have to consume from config file
      for (( i=0; i<"${DIR_ARR_LEN}"; i++ ))
      do
        # if [[ -n "$(ls ${DIR_ARRAY[i]} 2> /dev/null)" ]] ; then
        if [[ -d "${DIR_ARRAY[i]}" ]] ; then
          echo "========================================================================================="
          echo "No update needed for: ${DIR_ARRAY[i]}"
          echo "========================================================================================="
          echo
          continue
        else
          echo
          echo "========================================================================================="
          echo "Adding..."
          echo "${DIR_ARRAY[i]}"
          # -p flag allows for the crewation of nested dirs
          mkdir -p "${DIR_ARRAY[i]}"
          # connect repo to dir if there is one
          # cds into directories and clones repo (clone_git_repo GIT_REPO_NAME DIRECTORY_NAME access_mod(private || public || leave empty))
          clone_git_repo "${CORRESPONDING_PROJECTS_ARRAY[i]}" "${DIR_ARRAY[i]}"
          echo "========================================================================================="
        fi
      done
    else
      echo "It seems you might not have a 'DIR_ARRAY', and/or a CORRESPONDING_PROJECTS_ARRAY variable(s) in your config file"
    fi
  else
    echo "The config file: ${1} doesn't exist"
  fi
}
