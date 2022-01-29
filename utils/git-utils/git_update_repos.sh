#!/bin/bash

# update repositories for directories within generated environment
# go through all git initialized repos and do a pull

# spellcheck source=./env-creation/directories.sh
source ./env-creation/directories.sh
# spellcheck source=./utils/git-utils/git_utils.sh 
source ./utils/git-utils/git_utils.sh 
# spellcheck source=./utils/helpers/validation.sh
source ./utils/helpers/validation.sh

update_all_dirs() {
  for (( i=0; i<"${DIR_ARRAY_LEN}"; i++ ))
  do
    update_git_repo "${DIR_ARRAY[i]}"
  done
}

check_all_dirs_status() {
  for (( i=0; i<"${DIR_ARRAY_LEN}"; i++ ))
  do
    check_status_of_working_tree "${DIR_ARRAY[i]}"
  done
}

# updates(pulls) or checks status of git repos in their respective directories
# arg1=status || update
choose_repos_to_status_or_update() {
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
          update_all_dirs
        elif [[ ${1} == 'status' ]] ; then
          check_all_dirs_status
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
}   
