#!/bin/bash

DIR_NAME="${1}"
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

ROOT_FS_LOCATION=""
if [[ -z ${ROOT_FS_LOCATION} ]]; then
  ROOT_FS_LOCATION="${ENGEN_FS_LOCATION}"
fi

# source ./utils/helpers/validation.sh
# spellcheck source="${HOME}/engen/utils/helpers/helpers.sh"
source "${ROOT_FS_LOCATION}/utils/helpers/helpers.sh"
# spellcheck source=/${HOME}/engen/utils/helpers/validation.sh
source "${ROOT_FS_LOCATION}/utils/helpers/validation.sh"

function engen() {
  # reference to wear command is run from
  local EXECUTION_DIR
  EXECUTION_DIR="$(pwd)"
  return_to_execution_dir() {
    # file search(not needed, using pwd for current dir reference)
    if [[ -d "${EXECUTION_DIR}" ]] ; then
      cd "${EXECUTION_DIR}"
    else
      cd "${HOME}"
    fi
  }

  # SIGINT fall back
  function leave_script() {
    cd "${EXECUTION_DIR}"
    kill $$
  }
  trap leave_script SIGINT

  # command help options
  # TODO: convert these conditions to switch case
  if [[ "${DIR_NAME}" == "-h" ]] || [[ "${DIR_NAME}" == "--help" ]] ; then
    echo "Existing base directories are shown by name and will be the context for the engen command"
    echo "_________________________________________________________________________________________"
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
    echo
    echo "The '4' option will"
    echo
    echo "The '5' option will"
    echo
  else
    local arr=()
    # file search
    if [[ "$(file_or_directory_exists "${HOME}" .profile f)" == "true" ]] ; then
      arr=($(grep "ROOT_ENV_DIR" ~/.profile))
    fi
    # remove 'export' keyword in array
    local no_exports_arr=( "${arr[@]/export/}" )
    # flatten empty spaces out of array
    local ENV_DIR_ARRAY=(${no_exports_arr[@]})
    # get array length
    local ENV_DIR_ARRAY_LEN="${#ENV_DIR_ARRAY[@]}"
    # array of just ENV_DIR_NAMES
    local ENV_VAR_NAME_ARRAY=()
    local ENV_DIR_NAMES=()
    local ENV_DIR_PATHS=()

    if [[ "${ENV_DIR_ARRAY_LEN}" -ge 1 ]] ; then
      for ENV_VAR in ${ENV_DIR_ARRAY[@]}
      do
        IFS="=" read -r -a touple <<< ${ENV_VAR}
        ENV_VAR_NAME_ARRAY+=("${touple[0]}")
        ENV_DIR_PATHS+=("${touple[1]}")
      done

      for DIR_VAR_NAME in ${ENV_VAR_NAME_ARRAY[@]}
      do
        IFS="_" read -r -a name <<< ${DIR_VAR_NAME}
        ENV_DIR_NAMES+=("${name[3]}")
      done

      echo "========================================================================================="
      echo "=============================== [--ENV DIRECTORIES--]===================================="
      echo "========================================================================================="
      echo
      echo "From the following list, select which env dir you'd like to access"
      echo
      # present list of existing dir trees.
      for (( i=0; i<"${ENV_DIR_ARRAY_LEN}"; i++ ))
      do
        echo "${i}: ${ENV_DIR_NAMES[i]}"
      done
      echo
      echo -n "> "
      read -r index

      # validate input
      while "true"
      do
        if [[ "$(input_is_number "${index}")" == "true" ]] ; then
          # derive base dir name and pass as arg. main.sh is now accepting it
          # echo "Current env: ${ENV_DIR_NAMES[${index}]}"
          echo
          cd "${HOME}/${ENV_DIR_NAMES[${index}]}"
          bash "${ROOT_FS_LOCATION}/main.sh" "${ENV_DIR_NAMES[${index}]}"
          return_to_execution_dir
          break
        else
          echo
          echo "Input must be a number in the above list"
          echo
          echo -n "> "
          read -r index
        fi
      done
    else
      # file search use depth search instead
      bash "${ROOT_FS_LOCATION}/main.sh"
      return_to_execution_dir
    fi
  fi
}

engen
