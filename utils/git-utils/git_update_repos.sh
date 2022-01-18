#!/bin/bash

# update repositories for directories within generated environment
# go through all git initialized repos and do a pull

source ./utils/git-utils/git_utils.sh ;

# Linux specific implementation
CURRENT_WORKING_TREE=$(pwd) ;
IFS="/" read -r -a DIR_LIST <<< ${CURRENT_WORKING_TREE} ;
CURRENT_BASE_DIR="$HOME${DIR_LIST[3]}" ;

########################## DIRS ##########################
CHALLENGES="${CURRENT_BASE_DIR}/Challenges" ;
JAVA_CHALLENGES="${CHALLENGES}/Java" ;
JS_CHALLENGES="${CHALLENGES}/JS" ;
PYTHON_CHALLENGES="${CHALLENGES}/Python" ;
RUST_CHALLENGES="${CHALLENGES}/Rust" ;

CPP="${CURRENT_BASE_DIR}/C++" ;
CPP_PRACTICE="${CPP}/Practice" ;
CPP_PROJECTS="${CPP}/Projects" ;

JAVA="${CURRENT_BASE_DIR}/Java" ;
JAVA_PRACTICE="${JAVA}/Practice" ;
JAVA_PROJECTS="${JAVA}/Projects" ;

JS="${CURRENT_BASE_DIR}/JS" ;
JS_PRACTICE="${JS}/Practice" ;
JS_PROJECTS="${JS}/Projects" ;

PYTHON="${CURRENT_BASE_DIR}/Python" ;
PYTHON_PRACTICE="${PYTHON}/Practice" ;
PYTHON_PROJECTS="${PYTHON}/Projects" ;

RUST="${CURRENT_BASE_DIR}/Rust" ;
RUST_PRACTICE="${RUST}/Practice" ;
RUST_PROJECTS="${RUST}/Projects"; 

SCRIPTS="${CURRENT_BASE_DIR}/Scripts" ;
SCRIPTS_PRACTICE="${SCRIPTS}/Practice" ;
SCRIPTS_PROJECTS="${SCRIPTS}/Projects" ;

WEB="${CURRENT_BASE_DIR}/Web" ;
WEB_PRACTICE="${WEB}/Practice" ;
WEB_PROJECTS="${WEB}/Projects" ;

OPEN_SOURCE="${CURRENT_BASE_DIR}/OpenSource" ;

########################## DIRS TO UPDATE AND CHECK STATUS ##########################
DIR_ARRAY=(
  "${JAVA_CHALLENGES}"
  "${JS_CHALLENGES}"
  "${PYTHON_CHALLENGES}"
  "${RUST_CHALLENGES}"
  "${RUST_PRACTICE}/Course"
  "${SCRIPTS_PRACTICE}/ShellScriptShCourse"
  "${SCRIPTS_PROJECTS}/PersonalEnvGenerator"
  "${SCRIPTS_PROJECTS}/PublicEnvGenerator"
  "${WEB_PRACTICE}/WebSockets"
  "${WEB_PROJECTS}/HowManyRepsWasThat"
)
DIR_NAMES_ARRAY=(
  'Java Challenges'
  'JavaScript Challenges'
  'Python Challenges'
  'Rust Challenges'
  'Rust Practice'
  'Scripts Practice(SH Course)'
  'Scripts Projects(PersonalEnvGenerator)'
  'Scripts Projects(PublicEnvGenerator)'
  'Web Practice(WebSockets)'
  'Web Projects(HowManyRepsWasThat)'
)
DIR_ARRAY_LEN="${#DIR_ARRAY[@]}"

update_all_dirs() {
  for (( i=0; i<"${DIR_ARRAY_LEN}"; i++ ))
  do
    update_git_repo "${DIR_ARRAY[i]}"
  done
}

check_all_dirs_status() {
  for (( i=0; i<"${DIR_ARRAY_LEN}"; i++ ))
  do
    check_status_of_working_tree "${DIR_ARRAY[i]}"
  done
}

# updates(pulls) or checks status of git repos in their respective directories
# arg1=status || update
choose_repos_to_status_or_update() {
  echo "all"
  for (( i=0; i<"${DIR_ARRAY_LEN}"; i++ ))
  do
    echo "${i}: ${DIR_NAMES_ARRAY[i]}"
  done

  echo
  echo "From the list above, select which repo you'd like to update"
  echo "as 'all', or numbers separated by spaces. EX:"
  echo "0 1 2"
  echo
  echo -n "> "
  read -r indexes

  if [[ ${indexes} == 'all' ]] ; then
    # invoke function to either update or check status based on arg1
    if [[ ${1} == 'update' ]] ; then
      update_all_dirs
    elif [[ ${1} == 'status' ]] ; then
      check_all_dirs_status
    else
      echo 'Invalid argument passed to "choose_repos_to_status_or_update"'
    fi
  else
    for i in ${indexes[@]}
    do
      # invoke function to either update or check status based on arg1
      if [[ ${1} == 'update' ]] ; then
        update_git_repo ${DIR_ARRAY[i]}
      elif [[ ${1} == 'status' ]] ; then
        check_status_of_working_tree ${DIR_ARRAY[i]}
      else
        echo 'Invalid argument passed to "choose_repos_to_status_or_update"'
      fi
    done
  fi
}   
