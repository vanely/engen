#!/bin/bash

<<<<<<< Updated upstream
# so far it seems like or imports, I have to add this function at the top of every file
# is it then worth it to pass this reference to the below scripts
=======
# optional script arg1=ROOT_ENV_DIR_NAME 
CONTEXT_ROOT_DIR_NAME="${1}"

# root dir location in file system
ROOT_PATH="${PWD}"
>>>>>>> Stashed changes

# Function to derive the directory location of the script
get_script_dir() {
  local script_path="${BASH_SOURCE[0]}"
  local script_dir

  # Resolve symbolic links
  while [ -h "$script_path" ]; do
    script_dir="$(cd -P "$(dirname "$script_path")" >/dev/null 2>&1 && pwd)"
    script_path="$(readlink "$script_path")"
    [[ "$script_path" != /* ]] && script_path="$script_dir/$script_path"
  done

  script_dir="$(cd -P "$(dirname "$script_path")" >/dev/null 2>&1 && pwd)"
  echo "$script_dir"
}

# Set ROOT_FS_LOCATION to the script directory
ROOT_FS_LOCATION=$(get_script_dir)

# Ensure the environment variable is set in the user's profile
if [[ -z $(grep "ENGEN_FS_LOCATION" ~/.profile) ]]; then
  echo "export ENGEN_FS_LOCATION='${ROOT_FS_LOCATION}'" >> ~/.profile
  # Reload the profile to apply changes
  source ~/.profile
fi

# Example usage of ROOT_FS_LOCATION
# source "${ROOT_FS_LOCATION}/env-creation/generate_directory_tree.sh"

export ROOT_FS_LOCATION

# Function to import scripts
import_script() {
  local script_path="${ROOT_FS_LOCATION}/$1"
  
  if [ -f "$script_path" ]; then
    source "$script_path"
  else
    echo "Error: Unable to source script. File not found: $script_path"
  fi
}
# # spellcheck source="${ROOT_FS_LOCATION}/env-creation/generate_directory_tree.sh"
# source "${ROOT_FS_LOCATION}/env-creation/generate_directory_tree.sh"
# # spellcheck source="${ROOT_FS_LOCATION}/env-creation/directories.sh"
# source "${ROOT_FS_LOCATION}/env-creation/directories.sh"
# # spellcheck source="${ROOT_FS_LOCATION}/programs-to-install/linux/choose_programs_and_install.sh"
# source "${ROOT_FS_LOCATION}/programs-to-install/linux/choose_programs_and_install.sh"
# # spellcheck source="${ROOT_FS_LOCATION}/utils/cleanup/main.sh"
# source "${ROOT_FS_LOCATION}/utils/cleanup/main.sh"
# # spellcheck source="${ROOT_FS_LOCATION}/utils/git-utils/main.sh"
# source "${ROOT_FS_LOCATION}/utils/git-utils/main.sh"
# # spellcheck source="${ROOT_FS_LOCATION}/utils/helpers/vscode_extensions.sh"
# source "${ROOT_FS_LOCATION}/utils/helpers/vscode_extensions.sh"
# # spellcheck source="${ROOT_FS_LOCATION}/utils/helpers/validation.sh"
# source "${ROOT_FS_LOCATION}/utils/helpers/validation.sh"
# # spellcheck source="${ROOT_FS_LOCATION}/utils/helpers/helpers.sh"
# source "${ROOT_FS_LOCATION}/utils/helpers/helpers.sh"

import_script "env-creation/generate_directory_tree.sh"
import_script "env-creation/directories.sh"
import_script "programs-to-install/linux/choose_programs_and_install.sh"
import_script "utils/cleanup/main.sh"
import_script "utils/git-utils/main.sh"
import_script "utils/helpers/vscode_extensions.sh"
import_script "utils/helpers/validation.sh"
import_script "utils/helpers/helpers.sh"

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

# arg1=REF_TO_FS_LOCATION
update_current_dir_tree() {
  local CURRENT_ROOT_ENV_CONFIG
  local REF_TO_FS_LOCATION
  CURRENT_ROOT_ENV_CONFIG="${HOME}/$(build_config_file "${CONTEXT_ROOT_DIR_NAME}")"
  REF_TO_FS_LOCATION="${1}"
  
  # DEBUG: outputting the constructed config file to make sure it's in correct format
  echo "Current config file: ${CURRENT_ROOT_ENV_CONFIG}"
  # file search
  if [[ "$(config_file_exists "${CURRENT_ROOT_ENV_CONFIG}")" == "true" ]] ; then
    update_dir_tree "${CURRENT_ROOT_ENV_CONFIG}" "${REF_TO_FS_LOCATION}"
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
      ${PROCESSES_ARRAY[process]} "${CONTEXT_ROOT_DIR_NAME}" "${ROOT_FS_LOCATION}" # <-- may not need to pass down fs location
    else
      ${PROCESSES_ARRAY[process]} "${ROOT_FS_LOCATION}" # <-- may not need to pass down fs location
    fi
    break
  fi
done
