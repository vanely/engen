#!/bin/bash

function get_engen_fs_location() {
  if [[ -z $(grep "ENGEN_FS_LOCATION" ~/.profile)  ]] ; then
    local FINAL_DIR="${PWD##*/}" 
    local REMOVED_FINAL_DIR="${PWD/${FINAL_DIR}/}"
    echo "${REMOVED_FINAL_DIR}"
  else
    # will be exported from ~/.profile
    echo ENGEN_FS_LOCATION
  fi
}

# spellcheck source="${HOME}/engen/env-creation/generate_config_file.sh"
source "$(get_engen_fs_location)/env-creation/generate_config_file.sh"
# source "${HOME}/engen/env-creation/generate_config_file.sh"

# spellcheck source="${HOME}/engen/env-creation/directories.sh"
source "$(get_engen_fs_location)/env-creation/directories.sh"
# source "${HOME}/engen/env-creation/directories.sh"

# spellcheck source="${HOME}/engen/utils/helpers/initial_checks.sh"
source "$(get_engen_fs_location)/utils/helpers/initial_checks.sh"
# source "${HOME}/engen/utils/helpers/initial_checks.sh"

# spellcheck source="${HOME}/engen/utils/helpers/validation.sh"
source "$(get_engen_fs_location)/utils/helpers/validation.sh"
# source "${HOME}/engen/utils/helpers/validation.sh" 

# spellcheck source="${HOME}/engen/utils/helpers/git_utils.sh"
source "$(get_engen_fs_location)/utils/helpers/git_utils.sh"
# source "${HOME}/engen/utils/git-utils/git_utils.sh"

# spellcheck source="${HOME}/engen/utils/helpers/helpers.sh"
source "$(get_engen_fs_location)/utils/helpers/helpers.sh"
# source "${HOME}/engen/utils/helpers/helpers.sh"

# reference to existing config
EXISTING_CONFIG=""
# CURRENT_BASE_DIR="" referenced from directories.sh

# export CURRENT_BASE_DIR dir to be referenced globally
# arg1=CURRENT_BASE_DIR_NAME
make_root_dir_global() {
  # reference to name of env being generated
  current_env_dir="ROOT_ENV_DIR_${1}"

  # file search
  if [[ -f ~/.profile ]] && [[ -n "$(grep ${current_env_dir} ~/.profile)" ]] ; then
    echo "Global path reference variable has already been exported for the directory tree!"
  else
    # at some point I may want to export env to different dir,
    # create a helper function that receives a base dir for where an env will be created and export the full path from the function
    echo export "${current_env_dir}=${HOME}/${1}" >> ~/.profile
  fi
  
  # validate if .profile is already sourced in .bashrc and/ or .zshrc
  if [[ "$(profile_not_sourced)" == "!b" ]] ; then
    echo source ~/.profile >> ~/.bashrc
  elif [[ "$(profile_not_sourced)" == "!z" ]] ; then
    echo source ~/.profile >> ~/.zshrc
  elif [[ "$(profile_not_sourced)" == "!b!z" ]] ; then
    echo source ~/.profile >> ~/.bashrc
    echo source ~/.profile >> ~/.zshrc
  fi
  
  # file search
  if [[ ! -f ~/.zshrc ]] ; then
    source ~/.bashrc
  else
    source ~/.zshrc
  fi
}

set_base_directory_name() {
  # once root is set, add it to .bashrc or .zshrc or .profile for global reference
  # this will allow the non dir creation portion of this script to be decoupled into a separate module. 

  echo "========================================================================================="
  echo "================================= [--INITIAL CHECKS--] =================================="
  echo "========================================================================================="

  check_current_operating_system
  check_and_update_bash
  dependency_checks
  echo "========================================================================================="
  echo "============================= [--EXISTING OR NEW CONFIG--] =============================="
  echo "========================================================================================="
  echo

  # ask user if they want to generate an env from existing config
  # to decide whether or not to ask for a base dir name
  echo "Would you like to generate an environment from an existing config file?"
  echo -n "'y' or 'n': "
  read -r ENV_BOOL

  while "true"
  do
    if [[ "${ENV_BOOL,,}" == "y" ]] || [[ "${ENV_BOOL,,}" == "n" ]] ; then
      break
    else
      echo "Invalid input! Input must be 'y' or 'n'"
      echo
      echo "Would you like to generate an environment from an existing config file?"
      echo -n "'y' or 'n': "
      read -r ENV_BOOL
    fi
  done

  if [[ "${ENV_BOOL,,}" == "y" ]] ; then
    echo
    echo "Enter only the base directory name(suffix of your config file)"
    echo "EX: '.engenrc_baseDirectorySuffix' <-- part after the underscore"
    echo -n "> "
    read -r EXISTING_CONFIG_SUFFIX 
    echo

    # change to ".engenrc_${EXISTING_CONFIG_SUFFIX}" omit the ".sh"
    # use depth search to find config file "find $HOME -maxdepth 2 -type f | grep 'ROOT_ENV'"
    # build_config_file
    EXISTING_CONFIG="$(print_file_system_search "${HOME}" ".engenrc_${EXISTING_CONFIG_SUFFIX}" "f")"
    # EXISTING_CONFIG="${HOME}/ROOT_ENV_CONFIG_${EXISTING_CONFIG_SUFFIX}.sh"
    CURRENT_BASE_DIR="$(readlink -m "${HOME}/""${EXISTING_CONFIG_SUFFIX}")"
    # check git creds or prompt for them here
    config_git_creds_and_auth
  elif [[ "${ENV_BOOL,,}" == "n" ]] ; then
    echo
    echo "========================================================================================="
    echo "================= [--Set the name of the environment's base directory--] ================"
    echo "================= [--Press 'ENTER' to set the name to 'PracticeSpace'--] ================"
    echo "========================================================================================="
    echo
    echo -n "> "
    # add validation for acceptable variable name for base dir name
    read -r BASE

    # create boundary that stops users from creating base dir names with hyphens in them EX: some-dir(not valid variable name for some reason)
    if [[ -z "${BASE}" ]] ; then
      # using the below readlink command normalizes the dir path and prevents occassional double slash
      BASE="PracticeSpace"
      CURRENT_BASE_DIR="$(readlink -m "${HOME}/"${BASE})"
    else
      # using the below readlink command normalizes the dir path and prevents occassional double slash
      CURRENT_BASE_DIR="$(readlink -m "${HOME}/"${BASE})"
    fi

    # file search
    while [[ -d "${CURRENT_BASE_DIR}" ]]
    do
      echo
      echo "$(readlink -m "${HOME}/"${BASE}) already exists!"
      echo "Please choose another name, or enter 'exit' to exit script."
      echo -n "> "
      read -r BASE

      if [[ "${BASE}" = "exit" ]] ; then
        exit
      elif [[ -z "${BASE}" ]] ; then
        # using the below readlink command normalizes the dir path and prevents occassional double slash
        CURRENT_BASE_DIR="$(readlink -m "${HOME}/"PracticeSpace)"
        break
        # file search
      elif [[ ! -d "${HOME}/${BASE}" ]] ; then
        # using the below readlink command normalizes the dir path and prevents occassional double slash
        CURRENT_BASE_DIR="$(readlink -m "${HOME}/""${BASE}")"
        break
      fi
    done

    echo "Base dir has been set to: ${CURRENT_BASE_DIR}"
    
    # file search
    if [[ -f ~/.bashrc ]] && [[ -f ~/.profile ]] ; then
      make_root_dir_global "${BASE}"
    elif [[ -f ~/.bashrc ]] && [[ ! -f ~/.profile ]]; then
      touch ~/.profile
      make_root_dir_global "${BASE}"
    elif [[ ! -f ~/.bashrc ]] && [[ -f ~/.profile ]]; then
      touch ~/.bashrc
      touch ~/.profile
      make_root_dir_global "${BASE}"
    fi
  
    # generate config file
    generate_config_file "${BASE}"
  fi
}
# open source projects directories with project specific repos cloned inside

create_directories() {
  # add function that derives where the root project dir has been cloned, and strore reference(may not need)
  set_base_directory_name

  # arg1=CONFIG_FILE arg2=existing || new
  create_and_update_dir_paths() {
    # source config file /home/<user>/ROOT_ENV_CONFIG_<ROOT_ENV_DIR_NAME>
    source "${1}"
    # iterate through base dir array in config file, and create all
    if [[ -n "${BASE_DIR_ARRAY}" ]] ; then 
      BASE_DIR_ARRAY_LEN="${#BASE_DIR_ARRAY[@]}"

      echo "========================================================================================="
      echo "============================ [--CREATING BASE DIRECTORIES--] ============================"
      echo "========================================================================================="
      echo
      # create base directories
      if [[ -n "${CURRENT_BASE_DIR_PATH}" ]] ; then
        # file search
        if [[ -d "${CURRENT_BASE_DIR_PATH}" ]] ; then
          echo "${CURRENT_BASE_DIR_PATH} already exists!"
        else
          if [[ "${2}" == "existing" ]]; then
            CURRENT_BASE_DIR="${CURRENT_BASE_DIR_PATH}"

            # file search
            if [[ -f ~/.bashrc ]] && [[ -f ~/.profile ]] ; then
              # CURRENT_BASE_DIR_NAME referenced from config file
              make_root_dir_global "${CURRENT_BASE_DIR_NAME}"
            elif [[ -f ~/.bashrc ]] && [[ ! -f ~/.profile ]]; then
              touch ~/.profile
              make_root_dir_global "${CURRENT_BASE_DIR_NAME}"
            elif [[ ! -f ~/.bashrc ]] && [[ ! -f ~/.profile ]]; then
              touch ~/.bashrc
              touch ~/.profile
              make_root_dir_global "${CURRENT_BASE_DIR_NAME}"
            fi
          fi
          
          # create base directories
          for (( i=0; i<"${BASE_DIR_ARRAY_LEN}"; i++ ))
          do
            mkdir -p "${BASE_DIR_ARRAY[i]}"        
          done
        fi
      else
        echo "It seems you might not have a CURRENT_BASE_DIR_PATH in your config file"
      fi

      echo "========================================================================================="
      echo "=================== [--CLONING PROJECTS TO RESPECTIVE DIRECTORIES--] ===================="
      echo "========================================================================================="
      echo
      if [[ -n "${DIR_ARRAY}" ]] && [[ -n "${CORRESPONDING_PROJECTS_ARRAY}" ]] ; then
        # consumes config file path
        update_dir_tree "${1}"
      else
        echo "It seems you might not have a 'DIR_ARRAY', and/or a CORRESPONDING_PROJECTS_ARRAY variable(s) in your config file"
      fi
    else
      echo "It seems you might not have a 'BASE_DIR_ARRAY' variable in your config file"
    fi
  }
  
  if [[ -n ${EXISTING_CONFIG} ]] ; then
    # generate from existing config
    echo
    echo "Generating directory tree from existing config file"
    echo "${EXISTING_CONFIG} ..."
    echo
    create_and_update_dir_paths "${EXISTING_CONFIG}" "existing"
  else
    # generate from newly generated config
    echo
    echo "Generating directory tree from newly created config file"
    echo "${CURRENT_BASE_DIR} ..."
    echo
    IFS="/" read -r -a DIR_NAMES <<< ${CURRENT_BASE_DIR}
    BASE_DIR_NAME=""
    if [[ "${ROOT_ENV_OS}" == "Windows" ]] ; then
      BASE_DIR_NAME="${DIR_NAMES[4]}"
    else
      BASE_DIR_NAME="${DIR_NAMES[3]}"
    fi
    create_and_update_dir_paths "${HOME}/ROOT_ENV_CONFIG_${BASE_DIR_NAME}.sh" "new"
    echo
    echo "Be sure to store your config file somewhere safe, like github where you'll be able to "
    echo "reference it again, incase you'd like to regenerate the same directory tree."
  fi

  # file search
  if [[ -f ~/.profile ]]; then
    if [[ -z $(grep "alias engen=" ~/.profile) ]] ; then
      echo 'alias engen="bash ~/engen/engen.sh"' >> ~/.profile
    fi
  fi
}
