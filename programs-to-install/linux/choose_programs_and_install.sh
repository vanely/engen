#!/bin/bash

# NOTE: the directories of the files being sourced should be expressed
# relative to the directory of the root script that evetually calls it.

# spellcheck source=./programs-to-install/linux/dev_tools_installs.sh
source ./programs-to-install/linux/dev_tools_installs.sh
# spellcheck source=./utils/helpers/validation.sh
source ./utils/helpers/validation.sh

PROGRAM_NAMES_ARRAY_LEN="${#PROGRAM_NAMES_ARRAY[@]}"

iteratively_install_programs() {
  echo "////////////////////// PROGRAMS THAT CAN BE INSTALLED //////////////////////"
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
