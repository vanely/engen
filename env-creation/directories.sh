#!/bin/bash

# LIST OF DIRECTORIES

source ./utils/git-utils/git_utils.sh ;

BASE_DIR=
# Linux specific implementation conditionally set this based on OS
CURRENT_WORKING_TREE=$(pwd) ;
IFS="/" read -r -a DIR_LIST <<< ${CURRENT_WORKING_TREE} ;
CURRENT_BASE_DIR=""
if [[ "${ROOT_ENV_OS}" == "Windows" ]] ; then 
  CURRENT_BASE_DIR="$HOME${DIR_LIST[4]}"
else
  CURRENT_BASE_DIR="$HOME${DIR_LIST[3]}"
fi

########################## BASE DIRS ##########################
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

MISC="${CURRENT_BASE_DIR}/Misc"

OPEN_SOURCE="${CURRENT_BASE_DIR}/OpenSource" ;

BASE_DIR_ARRAY=(
  "${CHALLENGES}"
  "${JAVA_CHALLENGES}"
  "${JS_CHALLENGES}"
  "${PYTHON_CHALLENGES}"
  "${RUST_CHALLENGES}"
  "${CPP}"
  "${CPP_PRACTICE}"
  "${CPP_PROJECTS}"
  "${JAVA}"
  "${JAVA_PRACTICE}"
  "${JAVA_PROJECTS}"
  "${JS}"
  "${JS_PRACTICE}"
  "${JS_PROJECTS}"
  "${PYTHON}"
  "${PYTHON_PRACTICE}"
  "${PYTHON_PROJECTS}"
  "${RUST}"
  "${RUST_PRACTICE}"
  "${RUST_PROJECTS}"
  "${SCRIPTS}"
  "${SCRIPTS_PRACTICE}"
  "${SCRIPTS_PROJECTS}"
  "${WEB}"
  "${WEB_PRACTICE}"
  "${WEB_PROJECTS}"
  "${MISC}"
  "${OPEN_SOURCE}"
)
BASE_DIR_ARRAY_LEN="${#BASE_DIR_ARRAY[@]}"

########################## DIRS WITH REPOS TO UPDATE AND CHECK STATUS ##########################
DIR_ARRAY=(
  # EX: "${JAVA_CHALLENGES}"                      
  # EX: "${JS_CHALLENGES}"                        
  # EX: "${PYTHON_CHALLENGES}"                    
  # EX: "${RUST_CHALLENGES}"                                                 
)
CORRESPONDING_PROJECTS_ARRAY=(
  # EX: "Java-Challenges private"         
  # EX: "JavaScript-Challenges public"   
  # EX: "Python-Challenges private"       
  # EX: "Rust-Challenges public"                   
)
SPECIAL_OPERACTIONS_ARRAY=(

)
DIR_NAMES_ARRAY=(
  # EX: 'Java Challenges'
  # EX: 'JavaScript Challenges'
  # EX: 'Python Challenges'
  # EX: 'Rust Challenges'
)
DIR_ARRAY_LEN="${#DIR_ARRAY[@]}"

update_dir_tree() {
  for (( i=0; i<"${DIR_ARRAY_LEN}"; i++ ))
  do
    if [[ -d "${DIR_ARRAY[i]}" ]] ; then
      echo
      echo "==================================================="
      echo "No update needed"
      echo "==================================================="
      continue
    else
      echo
      echo "==================================================="
      echo "Adding..."
      echo "${DIR_ARRAY[i]}"
      # -p flag allows for the crewation of nested dirs
      mkdir -p "${DIR_ARRAY[i]}"
      # splits the corresponding project into the project=[0], and access=[1]
      PROJECT_ARRAY_TOUPLE=(${CORRESPONDING_PROJECTS_ARRAY[i]})
      # connect repo to dir if there is one
      # cds into directories and clones repo (clone_git_repo GIT_REPO_NAME DIRECTORY_NAME access_mod(private || public || leave empty))
      clone_git_repo "${PROJECT_ARRAY_TOUPLE[0]}" "${DIR_ARRAY[i]}" "${PROJECT_ARRAY_TOUPLE[1]}"
      echo "==================================================="
    fi
  done
}
