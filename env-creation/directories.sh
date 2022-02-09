#!/bin/bash

# LIST OF DIRECTORIES

source "${HOME}/engen/utils/git-utils/git_utils.sh"

CURRENT_WORKING_TREE=""

# arg1=PATH_TO_CONFIG
update_dir_tree() {
  # import config file
  source "${1}"
  # echo "Current config from directories.sh: ${1}"
  if [[ -f "${1}" ]] ; then
    if [[ -n "${DIR_ARRAY}" ]] && [[ -n "${CORRESPONDING_PROJECTS_ARRAY}" ]] ; then
      DIR_ARR_LEN="${#DIR_ARRAY[@]}"
      # will have to consume from config file
      for (( i=0; i<"${DIR_ARR_LEN}"; i++ ))
      do
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
          # splits the corresponding project into the project=[0], and access=[1]
          PROJECT_ARRAY_TOUPLE=(${CORRESPONDING_PROJECTS_ARRAY[i]})
          # connect repo to dir if there is one
          # cds into directories and clones repo (clone_git_repo GIT_REPO_NAME DIRECTORY_NAME access_mod(private || public || leave empty))
          clone_git_repo "${PROJECT_ARRAY_TOUPLE[0]}" "${DIR_ARRAY[i]}" "${PROJECT_ARRAY_TOUPLE[1]}"
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
