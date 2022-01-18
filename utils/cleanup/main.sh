#!/bin/bash

source ./utils/cleanup/cleanup_dir_trees.sh
source ./utils/cleanup/cleanup_installs.sh # not implremented yet

remove_dir_trees() {
  iteratively_remove_env_dirs
}

remove_intalls() {
  # write impo details
  # iteratively_remove_installs
  echo
}

remove_all_dir_trees_and_installs() {
  remove_all_dirs
  # remove_all_installs
}

# add the other above functions as they get built
CLEAN_UP_OPTIONS_ARRAY=(
  remove_dir_trees
)
CLEAN_UP_OPTION_NAMES_ARRAY=(
  'Remove Directory Trees'
)
CLEAN_UP_OPTIONS_ARRAY_LEN="${#CLEAN_UP_OPTIONS_ARRAY[@]}"

clean_up() {
  for (( i=0; i<"${CLEAN_UP_OPTIONS_ARRAY_LEN}"; i++ ))
  do
    echo "${i}: ${CLEAN_UP_OPTION_NAMES_ARRAY[i]}"
  done
  echo
  echo "Choose an option from the list above. EX:"
  echo "0 1 2"
  echo
  echo -n "> "
  read -r indexes

  for i in ${indexes[@]}
  do
    ${CLEAN_UP_OPTIONS_ARRAY[i]}
  done
}
