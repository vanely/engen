#!/bin/bash

# NOTE: the directories of the files being sourced should be expressed
# relative to the directory of the root script that evetually calls it.

# spellcheck source=./programs-to-install/linux/dev_tools_installs.sh
source ./programs-to-install/linux/dev_tools_installs.sh

# length of installs arrays
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

  if [[ ${indexes} == 'all' ]] ; then
    install_all_programs
  else
    for i in ${indexes[@]}
    do
      # echo "${FUNCTIONS_ARRAY[i]}"

      # Invoke install function
      ${FUNCTIONS_ARRAY[i]} 
    done
  fi
}
