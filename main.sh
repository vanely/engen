#!/bin/bash

function get_engen_fs_location() {
  if [[ -z $(grep "ENGEN_FS_LOCATION" ~/.profile)  ]] ; then
    echo "$(pwd)"
  else
    # will be exported from ~/.profile
    echo ENGEN_FS_LOCATION
  fi
}

# optional script arg1=ROOT_ENV_DIR_NAME 
# NOTE: the directories of the files being sourced should be expressed
# relative to the directory of the root script that evetually calls it.

# spellcheck source="$(get_engen_fs_location)/env-creation/generate_directory_tree.sh"
source "$(get_engen_fs_location)/env-creation/generate_directory_tree.sh"
# spellcheck source="$(get_engen_fs_location)/env-creation/directories.sh"
source "$(get_engen_fs_location)/env-creation/directories.sh"
# spellcheck source="$(get_engen_fs_location)/programs-to-install/linux/choose_programs_and_install.sh"
source "$(get_engen_fs_location)/programs-to-install/linux/choose_programs_and_install.sh"
# spellcheck source="$(get_engen_fs_location)/utils/cleanup/main.sh"
source "$(get_engen_fs_location)/utils/cleanup/main.sh"
# spellcheck source="$(get_engen_fs_location)/utils/git-utils/main.sh"
source "$(get_engen_fs_location)/utils/git-utils/main.sh"
# spellcheck source="$(get_engen_fs_location)/utils/helpers/vscode_extensions.sh"
source "$(get_engen_fs_location)/utils/helpers/vscode_extensions.sh"
# spellcheck source="$(get_engen_fs_location)/utils/helpers/validation.sh"
source "$(get_engen_fs_location)/utils/helpers/validation.sh"
# spellcheck source="$(get_engen_fs_location)/utils/helpers/helpers.sh"
source "$(get_engen_fs_location)/utils/helpers/helpers.sh"

# can either be 
CONTEXT_ROOT_DIR_NAME="${1}"

# similar to array of programs to install, present a choice of which main scripts to run
# [x] create directory tree
#   - [x] name coding env
#
# [x] install programs
#   - [x] choose programs to install
#
# [x] git api tools
#   - [x] create, 
#   - [x] delete, 
#   - [x] update repo,
#   - [x] check status
#
# [] clean up
#   - [] remove program,
#   - [x] remove directory tree,
#   - [] remove all

update_current_dir_tree() {
  # CURRENT_WORKING_TREE=$(pwd)
  # IFS="/" read -r -a DIR_LIST <<< ${CURRENT_WORKING_TREE}
  
  # build_config_file
  # will stay referenced this way! configs will be saved to $HOME!!!
  # CURRENT_ROOT_ENV_CONFIG="${HOME}/ROOT_ENV_CONFIG_${CONTEXT_ROOT_DIR_NAME}.sh"
  CURRENT_ROOT_ENV_CONFIG="${HOME}/$(build_config_file CONTEXT_ROOT_DIR_NAME)"
  # DEBUG: outputting the constructed config file to make sure it's in correct format
  echo "Current config file from main.sh: ${CURRENT_ROOT_ENV_CONFIG}"
  # file search
  if [[ "$(config_file_exists "${CURRENT_ROOT_ENV_CONFIG}")" == "true" ]] ; then
    update_dir_tree "${CURRENT_ROOT_ENV_CONFIG}"
  else
    echo
    echo "The expected config file: ${CURRENT_ROOT_ENV_CONFIG}"
    echo "does not exist"
    echo
  fi
}

PROCESSES_ARRAY=(
  create_directories
  update_current_dir_tree
  iteratively_install_programs
  clean_up
  git_utils
  choose_extenstions_to_install
)

PROCESS_NAMES_ARRAY=(
  'Create Directory Tree'
  'Update Directory Tree'
  'Install Programs'
  'Clean Up'
  'Git Utils'
  'VS Code Extensions'
)
PROCESS_NAMES_ARRAY_LEN="${#PROCESS_NAMES_ARRAY[@]}"

echo "========================================================================================="
echo "==================================== [--ENGEN--] ========================================"
echo "========================================================================================="
echo
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
read -r process
echo

while "true" 
do
  if [[ "$(input_is_number "${process}")" != "true" ]] ; then
    echo
    echo "Input must be a number in the above list"
    echo
    echo -n "> "
    read -r process
  else
    # pass context down to each process and see if it gets properly consumed
    # context needs to get to get to git_utils main.sh then to git_update_repos.sh 
    if [[ "${process}" == "4" ]] ; then
      ${PROCESSES_ARRAY[process]} "${CONTEXT_ROOT_DIR_NAME}" "$(get_engen_fs_location)"
    else
      ${PROCESSES_ARRAY[process]} "$(get_engen_fs_location)"
    fi
    break
  fi
done
