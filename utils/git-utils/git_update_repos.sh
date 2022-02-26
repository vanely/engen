#!/bin/bash

# update repositories for directories within generated environment
# go through all git initialized repos and do a pull

# spellcheck source=./env-creation/directories.sh
# source ./env-creation/directories.sh
# spellcheck source="${HOME}/engen/utils/git-utils/git_utils.sh" 
source "${HOME}/engen/utils/git-utils/git_utils.sh"
# spellcheck source="${HOME}/engen/utils/helpers/validation.sh"
source "${HOME}/engen/utils/helpers/validation.sh"

#arg1=CONTEXT_ROOT_DIR_NAME consumed from main.sh
update_all_dirs() {
  local CURRENT_ROOT_ENV_CONFIG
  CURRENT_ROOT_ENV_CONFIG="${1}"

  if [[ ! -f "${CURRENT_ROOT_ENV_CONFIG}" ]] ; then
    echo
    echo "The expected config file: ${CURRENT_ROOT_ENV_CONFIG}"
    echo "does not exist"
    echo
    echo "Exiting..."
    kill $$
  else
    source "${CURRENT_ROOT_ENV_CONFIG}"
    local DIR_ARRAY_LEN="${#DIR_ARRAY[@]}"

    for (( i=0; i<"${DIR_ARRAY_LEN}"; i++ ))
    do
      update_git_repo "${DIR_ARRAY[i]}"
    done
  fi
}

#arg1=CONTEXT_ROOT_DIR_NAME
check_all_dirs_status() {
  local CURRENT_ROOT_ENV_CONFIG
  CURRENT_ROOT_ENV_CONFIG="${1}"

  if [[ ! -f "${CURRENT_ROOT_ENV_CONFIG}" ]] ; then
    echo
    echo "The expected config file: ${CURRENT_ROOT_ENV_CONFIG}"
    echo "does not exist"
    echo
    echo "Exiting..."
    kill $$
  else
    source "${CURRENT_ROOT_ENV_CONFIG}"
    local DIR_ARRAY_LEN="${#DIR_ARRAY[@]}"

    for (( i=0; i<"${DIR_ARRAY_LEN}"; i++ ))
    do
      check_status_of_working_tree "${DIR_ARRAY[i]}"
    done
  fi
}

# updates(pulls) or checks status of git repos in their respective directories
# arg1=status || update arg2=CONTEXT_ROOT_DIR_NAME
choose_repos_to_status_or_update() {
  local CONTEXT_ROOT_DIR_NAME
  CONTEXT_ROOT_DIR_NAME="${2}"
  local CURRENT_ROOT_ENV_CONFIG
  # once context arrives derive config file name here
  CURRENT_ROOT_ENV_CONFIG="${HOME}/ROOT_ENV_CONFIG_${CONTEXT_ROOT_DIR_NAME}.sh"


  if [[ "${CURRENT_ROOT_ENV_CONFIG}" == "!e" ]] ; then
    echo
    echo "The expected config file: ${CURRENT_ROOT_ENV_CONFIG}"
    echo "does not exist"
    echo
    echo "Exiting..."
    kill $$
  else
    source "${CURRENT_ROOT_ENV_CONFIG}"
    local DIR_ARRAY_LEN="${#DIR_ARRAY[@]}"

    echo "all"
    for (( i=0; i<"${DIR_ARRAY_LEN}"; i++ ))
    do
      echo "${i}: ${DIR_NAMES_ARRAY[i]}"
    done

    echo
    echo "From the list above, select which repo you'd like to update"
    echo "as 'all', or numbers separated by spaces. EX:"
    echo "0 1 2"
    echo
    echo -n "> "
    read -r indexes

    while "true"
    do
      if [[ "$(input_is_number_with_possible_spaces "${indexes}")" == "true" ]] || [[ "$(input_is_the_word_all "${indexes}")" == "true" ]]; then
        if [[ ${indexes} == 'all' ]] ; then
          # invoke function to either update or check status based on arg1
          if [[ ${1} == 'update' ]] ; then
            update_all_dirs "${CURRENT_ROOT_ENV_CONFIG}"
          elif [[ ${1} == 'status' ]] ; then
            check_all_dirs_status "${CURRENT_ROOT_ENV_CONFIG}"
          else
            echo 'Invalid argument passed to "choose_repos_to_status_or_update"'
          fi
        else
          for i in ${indexes[@]}
          do
            # invoke function to either update or check status based on arg1
            if [[ ${1} == 'update' ]] ; then
              update_git_repo ${DIR_ARRAY[i]}
            elif [[ ${1} == 'status' ]] ; then
              check_status_of_working_tree ${DIR_ARRAY[i]}
            else
              echo 'Invalid argument passed to "choose_repos_to_status_or_update"'
            fi
          done
        fi
        break
      else
        echo
        echo "Input must be a number in the above list, or 'all'"
        echo
        echo -n "> "
        read -r indexes
      fi
    done
  fi
}   
