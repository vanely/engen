#!/bin/bash

# NOTE: the directories of the files being sourced should be expressed
# relative to the directory of the root script that evetually calls it.

# spellcheck source=./env-creation/generate_directory_tree.sh
source ./env-creation/generate_directory_tree.sh
# spellcheck source=./programs-to-install/linux/choose_programs_and_install.sh
source ./programs-to-install/linux/choose_programs_and_install.sh
# spellcheck source=./utils/cleanup/main.sh
source ./utils/cleanup/main.sh
# spellcheck source=./utils/git-utils/main.sh
source ./utils/git-utils/main.sh

# script flags
FIRST_PARAM=$1
case "${FIRST_PARAM}" in
  -h|--help)
    echo
    echo "The '0' option will generate a directory tree"
    echo "of practice, projects, and challenges for various languages."
    echo
    echo "The '1' option will allow you to choose which programs you'd like to install"
    echo
    echo "The '2' option will allow you to cleanup(remove dirs, and installs)"
    echo
    echo "The '3' option will allow you to check the status of git repos, do a pull on them"
    echo "create repos remotely, or delete repos remotely"
    echo ;;
  *) ;;
esac

# similar to array of programs to install, present a choice of which main scripts to run
# [x] create directory tree
#   - [x] name coding env
#
# [x] install programs
#   - [x] choose programs to install
#
# [] git api tools
#   - [] create, 
#   - [] delete, 
#   - [x] update repo,
#   - [x] check status
#
# [] clean up
#   - [] remove program,
#   - [x] remove directory tree,
#   - [] remove all

PROCESSES_ARRAY=(
  create_directories
  iteratively_install_programs
  clean_up
  git_utils
)

PROCESS_NAMES_ARRAY=(
  'Generate Programming Environment'
  'Install Programs'
  'Clean Up'
  'Git Utils'
)

PROCESS_NAMES_ARRAY_LEN="${#PROCESS_NAMES_ARRAY[@]}"

echo "Choose one of the processes by entering the corresponding number."
echo "Multiple can be selected as numbers seperated by spaces. EX:"
echo "0 1 2"
echo
for (( i=0; i<"${PROCESS_NAMES_ARRAY_LEN}"; i++ ))
do
  echo "${i}: ${PROCESS_NAMES_ARRAY[i]}"
done
echo
echo -n "> "
read -r processes

for i in ${processes[@]}
do
  ${PROCESSES_ARRAY[i]}
done
