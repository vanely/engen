#!/bin/bash

# spellcheck source="${HOME}/engen/utils/cleanup/cleanup_installs.sh"
source "${HOME}/engen/utils/cleanup/cleanup_dir_trees.sh"
# spellcheck source="${HOME}/engen/utils/cleanup/cleanup_installs.sh"
source "${HOME}/engen/utils/cleanup/cleanup_installs.sh" # not implremented yet
# spellcheck source="${HOME}/engen/utils/helpers/validation.sh"
source "${HOME}/engen/utils/helpers/validation.sh"

remove_dir_trees() {
  iteratively_remove_env_dirs
}

remove_installs() {
  # write impo details
  # iteratively_remove_installs
  echo 'Not yet implemented: coming soon'
}

remove_all_dir_trees_and_installs() {
  echo
  echo "---------------------------------------------------"
  echo "CURRENTLY ONLY REMOVES DIRS!"
  echo "---------------------------------------------------"
  echo
  remove_all_dirs
  # remove_all_installs
}

# add the other above functions as they get built
CLEAN_UP_OPTIONS_ARRAY=(
  remove_dir_trees
  remove_installs
  remove_all_dir_trees_and_installs
)
CLEAN_UP_OPTION_NAMES_ARRAY=(
  'Remove Directory Trees'
  'Remove Installs'
  'Remove All Directory Trees, and Installs'
)
CLEAN_UP_OPTIONS_ARRAY_LEN="${#CLEAN_UP_OPTIONS_ARRAY[@]}"

clean_up() {
  echo "========================================================================================="
  echo "================================== [--CLEAN UP--]========================================"
  echo "========================================================================================="
  echo
  for (( i=0; i<"${CLEAN_UP_OPTIONS_ARRAY_LEN}"; i++ ))
  do
    echo "${i}: ${CLEAN_UP_OPTION_NAMES_ARRAY[i]}"
  done
  echo
  echo "Choose an option from the list above. EX:"
  echo "0 1 2"
  echo
  echo -n "> "
  read -r index
  echo

  while "true" 
  do
    if [[ "$(input_is_number "${index}")" != "true" ]] ; then
      echo
      echo "Input must be a number in the above list"
      echo
      echo -n "> "
      read -r index
      echo
    else
      ${CLEAN_UP_OPTIONS_ARRAY[index]}
      break
    fi
  done
}
