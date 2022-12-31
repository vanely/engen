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

# spellcheck source="${HOME}/engen/programs-to-install/linux/dev_tools_installs.sh"
source "$(get_engen_fs_location)/programs-to-install/linux/dev_tools_installs.sh"
# spellcheck source="${HOME}/engen/utils/helpers/validation.sh"
source "$(get_engen_fs_location)/utils/helpers/validation.sh"

PROGRAM_NAMES_ARRAY_LEN="${#PROGRAM_NAMES_ARRAY[@]}"

iteratively_install_programs() {
  echo "========================================================================================="
  echo "============================= [--PROGRAMS TO INSTALL--]=================================="
  echo "========================================================================================="
  echo

  echo "all: installs all programs"
  # iteratively generate list of programs to install.
  for (( i=0; i<"${PROGRAM_NAMES_ARRAY_LEN}"; i++ ))
  do
    echo "${i}: ${PROGRAM_NAMES_ARRAY[i]}"
  done

  echo
  echo "From the list above, select which programs you'd like to install"
  echo "as 'all', or numbers separated by spaces. EX:"
  echo "0 2 4"
  echo
  echo -n "> "
  read -r indexes

  while "true"
  do
    if [[ "$(input_is_number_with_possible_spaces "${indexes}")" == "true" ]] || [[ "$(input_is_the_word_all "${indexes}")" == "true" ]]; then
      if [[ ${indexes} == 'all' ]] ; then
        install_all_programs
      else
        for i in ${indexes[@]}
        do
          ${FUNCTIONS_ARRAY[i]}
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
