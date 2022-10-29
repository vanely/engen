#!/bin/bash

# I want to import this as the means of searching for files and dirs
# but need a reference to this function before using it to import
# is there a better what to approach this??? Can I just use a reference to pwd

#arg1=beginning of search
#arg2=search_token
#arg3=f(file) or d(directory)"
print_file_system_search() { 
  local beginning_of_search="${1}"
  local search_token="${2}"
  local type="${3}"

  # doing strict search with "-w" passed into grep command
  local search=($(find "${beginning_of_search}" -maxdepth 2 -type "${type}" | grep -w "${search_token}"))
  echo "${search}"
}

# find relative location of engen(depth search)
source "$(print_file_system_search "${HOME}" "engen" "d")"/utils/git-utils/git_utils.sh
# source "${HOME}/engen/utils/git-utils/git_utils.sh"

CURRENT_WORKING_TREE=""

# arg1=PATH_TO_CONFIG
update_dir_tree() {
  # import config file
  source "${1}"

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
