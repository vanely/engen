#!/bin/bash

# imports
# NOTE: the directories of the files being sourced should be expressed
# relative to the directory of the root script that evetually calls it.

# spellcheck source=./utils/git-utils/initial_checks.sh
source ./utils/git-utils/initial_checks.sh 
# spellcheck source=./utils/git-utils/git_utils.sh
source ./utils/git-utils/git_utils.sh

HOME=~/

set_base_directory_name() {
  # once root is set, add it to .bashrc or .zshrc or .profile for global reference
  # this will allow the non dir creation portion of this script to be decoupled into a separate module. 
  ROOT=

  check_git
  echo
  echo "==================================================="
  echo " Set the name of the environment's base directory  "
  echo " Press 'ENTER' to set the name to 'PracticeSpace'  "
  echo "==================================================="
  echo -n "> "
  read -r BASE


  # create boundary that stops users from creating base dir names with hyphens in them EX: some-dir(not valid variable name for some reason)
  if [[ -z "${BASE}" ]] ; then
    # using the below readlink command normalizes the dir path and prevents occassional double slash
    BASE="PracticeSpace"
    ROOT="$(readlink -m ${HOME}${BASE})"
  else
    # using the below readlink command normalizes the dir path and prevents occassional double slash
    ROOT="$(readlink -m ${HOME}${BASE})"
  fi

  while [[ -d "${ROOT}" ]]
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
      ROOT="$(readlink -m ${HOME}PracticeSpace)"
      break
    elif [[ ! -d "${HOME}${BASE}" ]] ; then
      # using the below readlink command normalizes the dir path and prevents occassional double slash
      ROOT="$(readlink -m ${HOME}${BASE})"
      break
    fi
  done

  echo "Base dir has been set to: ${ROOT}"

  # export ROOT dir to be referenced globally
  make_root_dir_global() {
    echo export "ROOT_ENV_DIR_${BASE}"="${ROOT}" >> ~/.profile
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

  if [[ -d "${ROOT}" ]] ; then
    echo "${ROOT} already exists!"
  else 
    CHALLENGES="${ROOT}/Challenges"
    JAVA_CHALLENGES="${CHALLENGES}/Java"
    JS_CHALLENGES="${CHALLENGES}/JS"
    PYTHON_CHALLENGES="${CHALLENGES}/Python"
    RUST_CHALLENGES="${CHALLENGES}/Rust"

    CPP="${ROOT}/C++"
    CPP_PRACTICE="${CPP}/Practice"
    CPP_PROJECTS="${CPP}/Projects"

    JAVA="${ROOT}/Java"
    JAVA_PRACTICE="${JAVA}/Practice"
    JAVA_PROJECTS="${JAVA}/Projects"

    JS="${ROOT}/JS"
    JS_PRACTICE="${JS}/Practice"
    JS_PROJECTS="${JS}/Projects"

    PYTHON="${ROOT}/Python"
    PYTHON_PRACTICE="${PYTHON}/Practice"
    PYTHON_PROJECTS="${PYTHON}/Projects"

    RUST="${ROOT}/Rust"
    RUST_PRACTICE="${RUST}/Practice"
    RUST_PROJECTS="${RUST}/Projects"

    SCRIPTS="${ROOT}/Scripts"
    SCRIPTS_PRACTICE="${SCRIPTS}/Practice"
    SCRIPTS_PROJECTS="${SCRIPTS}/Projects"

    WEB="${ROOT}/Web"
    WEB_PRACTICE="${WEB}/Practice"
    WEB_PROJECTS="${WEB}/Projects"

    OPEN_SOURCE="${ROOT}/OpenSource"

    ##########################################################################
    # cds into directories and clones repo (clone_git_repo GIT_REPO_NAME DIRECTORY_NAME)

    # some directories may need manipulation. This variable can be used to bring us back to the directory where the base script is executed from
    # REVIEW: this may break if base script is added to alias or path variable
    EXECUTION_DIRECTORY="$(pwd)"

    mkdir "${ROOT}" ;
    mkdir "${CHALLENGES}" ;
    mkdir "${JAVA_CHALLENGES}" ;
    mkdir "${JS_CHALLENGES}" ;
    mkdir "${PYTHON_CHALLENGES}" ;
    mkdir "${RUST_CHALLENGES}" ;
    # clone_git_repo GIT_REPO_NAME DIRECTORY_NAME

    mkdir "${CPP}" ;
    mkdir "${CPP_PRACTICE}" ;
    mkdir "${CPP_PROJECTS}" ;
    # clone_git_repo GIT_REPO_NAME DIRECTORY_NAME

    mkdir "${JAVA}" ;
    mkdir "${JAVA_PRACTICE}" ;
    mkdir "${JAVA_PROJECTS}" ;
    # clone_git_repo GIT_REPO_NAME DIRECTORY_NAME

    mkdir "${JS}" ;
    mkdir "${JS_PRACTICE}" ;
    mkdir "${JS_PROJECTS}" ;
    # clone_git_repo GIT_REPO_NAME DIRECTORY_NAME

    mkdir "${PYTHON}" ;
    mkdir "${PYTHON_PRACTICE}" ;
    mkdir "${PYTHON_PROJECTS}" ;
    # clone_git_repo GIT_REPO_NAME DIRECTORY_NAME

    mkdir "${RUST}" ;
    mkdir "${RUST_PRACTICE}" ;
    mkdir "${RUST_PROJECTS}" ;
    # clone_git_repo GIT_REPO_NAME DIRECTORY_NAME

    mkdir "${SCRIPTS}" ;
    mkdir "${SCRIPTS_PRACTICE}" ;
    mkdir "${SCRIPTS_PROJECTS}" ;
    # clone_git_repo GIT_REPO_NAME DIRECTORY_NAME

    mkdir "${WEB}" ;
    mkdir "${WEB_PRACTICE}" ;
    mkdir "${WEB_PROJECTS}" ;
    # clone_git_repo GIT_REPO_NAME DIRECTORY_NAME

    mkdir "${OPEN_SOURCE}" ;
    # clone_git_repo GIT_REPO_NAME DIRECTORY_NAME

  fi
}
