#!/bin/bash

# imports
# NOTE: the directories of the files being sourced should be expressed
# relative to the directory of the root script that evetually calls it.

source ./env-creation/directories.sh
# spellcheck source=./utils/helpers/initial_checks.sh
source ./utils/helpers/initial_checks.sh 
# spellcheck source=./utils/helpers/git_utils.sh
source ./utils/git-utils/git_utils.sh

# [x] check what home looks like on windows git bash. I believe it's /c/Users/<user_name>/<ROOT_ENV_DIR>
HOME=~/

set_base_directory_name() {
  # once root is set, add it to .bashrc or .zshrc or .profile for global reference
  # this will allow the non dir creation portion of this script to be decoupled into a separate module. 
  # replace all instances of CURRENT_BASE_DIR with CURRENT_BASE_DIR

  # CURRENT_BASE_DIR initialized in --> ./directories.sh
  check_current_operating_system
  check_and_update_bash
  config_git_creds_and_auth
  echo
  echo "==================================================="
  echo " Set the name of the environment's base directory  "
  echo " Press 'ENTER' to set the name to 'PracticeSpace'  "
  echo "==================================================="
  echo -n "> "
  # add validation for acceptable variable name for base dir name
  read -r BASE

  # create boundary that stops users from creating base dir names with hyphens in them EX: some-dir(not valid variable name for some reason)
  if [[ -z "${BASE}" ]] ; then
    # using the below readlink command normalizes the dir path and prevents occassional double slash
    BASE="PracticeSpace"
    CURRENT_BASE_DIR="$(readlink -m ${HOME}${BASE})"
  else
    # using the below readlink command normalizes the dir path and prevents occassional double slash
    CURRENT_BASE_DIR="$(readlink -m ${HOME}${BASE})"
  fi

  while [[ -d "${CURRENT_BASE_DIR}" ]]
  do
    echo
    echo "$(readlink -m ${HOME}${BASE}) already exists!"
    echo "Please choose another name, or enter 'exit' to exit script."
    echo -n "> "
    read -r BASE

    if [[ "${BASE}" = "exit" ]] ; then
      exit
    elif [[ -z "${BASE}" ]] ; then
      # using the below readlink command normalizes the dir path and prevents occassional double slash
      CURRENT_BASE_DIR="$(readlink -m ${HOME}PracticeSpace)"
      break
    elif [[ ! -d "${HOME}${BASE}" ]] ; then
      # using the below readlink command normalizes the dir path and prevents occassional double slash
      CURRENT_BASE_DIR="$(readlink -m ${HOME}${BASE})"
      break
    fi
  done

  echo "Base dir has been set to: ${CURRENT_BASE_DIR}"

  # export CURRENT_BASE_DIR dir to be referenced globally
  make_root_dir_global() {
    echo export "ROOT_ENV_DIR_${BASE}"="${CURRENT_BASE_DIR}" >> ~/.profile
    echo source ~/.profile >> ~/.bashrc
    if [[ ! -f ~/.zshrc ]] ; then
      source ~/.bashrc
    fi
  }

  if [[ -f ~/.bashrc ]] && [[ -f ~/.profile ]] ; then
    make_root_dir_global
  elif [[ -f ~/.bashrc ]] && [[ ! -f ~/.profile ]]; then
    touch ~/.profile
    make_root_dir_global
  else
    touch ~/.bashrc
    touch ~/.profile
    make_root_dir_global
  fi
}
# open source projects directories with project specific repos cloned inside

create_directories() {
  set_base_directory_name
  CHALLENGES="${CURRENT_BASE_DIR}/Challenges"
  JAVA_CHALLENGES="${CHALLENGES}/Java"
  JS_CHALLENGES="${CHALLENGES}/JS"
  PYTHON_CHALLENGES="${CHALLENGES}/Python"
  RUST_CHALLENGES="${CHALLENGES}/Rust"

  CPP="${CURRENT_BASE_DIR}/C++"
  CPP_PRACTICE="${CPP}/Practice"
  CPP_PROJECTS="${CPP}/Projects"

  JAVA="${CURRENT_BASE_DIR}/Java"
  JAVA_PRACTICE="${JAVA}/Practice"
  JAVA_PROJECTS="${JAVA}/Projects"

  JS="${CURRENT_BASE_DIR}/JS"
  JS_PRACTICE="${JS}/Practice"
  JS_PROJECTS="${JS}/Projects"

  PYTHON="${CURRENT_BASE_DIR}/Python"
  PYTHON_PRACTICE="${PYTHON}/Practice"
  PYTHON_PROJECTS="${PYTHON}/Projects"

  RUST="${CURRENT_BASE_DIR}/Rust"
  RUST_PRACTICE="${RUST}/Practice"
  RUST_PROJECTS="${RUST}/Projects"

  SCRIPTS="${CURRENT_BASE_DIR}/Scripts"
  SCRIPTS_PRACTICE="${SCRIPTS}/Practice"
  SCRIPTS_PROJECTS="${SCRIPTS}/Projects"

  WEB="${CURRENT_BASE_DIR}/Web"
  WEB_PRACTICE="${WEB}/Practice"
  WEB_PROJECTS="${WEB}/Projects"

  MISC="${CURRENT_BASE_DIR}/Misc"
  
  OPEN_SOURCE="${CURRENT_BASE_DIR}/OpenSource"

  ##########################################################################
  # cds into directories and clones repo (clone_git_repo GIT_REPO_NAME DIRECTORY_NAME access_mod(private || public || leave empty))

  # some directories may need manipulation. This variable can be used to bring us back to the directory where the base script is executed from
  # REVIEW: this may break if base script is added to alias or path variable

  EXECUTION_DIRECTORY="$(pwd)"
  # set_current_base_dir "${CURRENT_BASE_DIR}"

  mkdir "${CURRENT_BASE_DIR}" ;
  mkdir "${CHALLENGES}" ;
  mkdir "${JAVA_CHALLENGES}" ;
  mkdir "${JS_CHALLENGES}" ;
  mkdir "${PYTHON_CHALLENGES}" ;
  mkdir "${RUST_CHALLENGES}" ;
  # clone_git_repo GIT_REPO_NAME DIRECTORY_NAME ACCESS


  mkdir "${CPP}" ;
  mkdir "${CPP_PRACTICE}" ;
  mkdir "${CPP_PROJECTS}" ;
  # clone_git_repo GIT_REPO_NAME DIRECTORY_NAME ACCESS

  mkdir "${JAVA}" ;
  mkdir "${JAVA_PRACTICE}" ;
  mkdir "${JAVA_PROJECTS}" ;
  # clone_git_repo GIT_REPO_NAME DIRECTORY_NAME ACCESS

  mkdir "${JS}" ;
  mkdir "${JS_PRACTICE}" ;
  mkdir "${JS_PROJECTS}" ;
  # clone_git_repo GIT_REPO_NAME DIRECTORY_NAME ACCESS

  mkdir "${PYTHON}" ;
  mkdir "${PYTHON_PRACTICE}" ;
  mkdir "${PYTHON_PROJECTS}" ;
  # clone_git_repo GIT_REPO_NAME DIRECTORY_NAME ACCESS

  mkdir "${RUST}" ;
  mkdir "${RUST_PRACTICE}" ;
  mkdir "${RUST_PROJECTS}" ;
  # clone_git_repo GIT_REPO_NAME DIRECTORY_NAME ACCESS

  mkdir "${SCRIPTS}" ;
  mkdir "${SCRIPTS_PRACTICE}" ;
  mkdir "${SCRIPTS_PROJECTS}" ;
  # clone_git_repo GIT_REPO_NAME DIRECTORY_NAME ACCESS


  mkdir "${WEB}" ;
  mkdir "${WEB_PRACTICE}" ;
  # clone_git_repo GIT_REPO_NAME DIRECTORY_NAME ACCESS


  mkdir "${WEB_PROJECTS}" ;
  # clone_git_repo GIT_REPO_NAME DIRECTORY_NAME ACCESS

  mkdir "${MISC}" ;
  # clone_git_repo GIT_REPO_NAME DIRECTORY_NAME ACCESS

  mkdir "${OPEN_SOURCE}" ;
  # clone_git_repo GIT_REPO_NAME DIRECTORY_NAME ACCESS
}
