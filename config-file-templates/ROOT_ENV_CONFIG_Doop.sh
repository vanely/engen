#!/bin/bash

# no need to touch this, it will get prepopulate with the ROOT_ENV_OS value
# that gets exported at the beginning of generating a directory tree
CURRENT_ROOT_ENV_OS="${ROOT_ENV_OS}"

# The path to your generated directory tree, starting from the home directory
CURRENT_BASE_DIR_PATH="/home/vanely/Doop"

# The name of the root directory for a generated directory tree
# this is also the suffix for this files name
CURRENT_BASE_DIR_NAME="Doop"

# git credentials used to pull repos
CURRENT_GIT_USER_NAME=

CURRENT_GIT_EMAIL=
########################## BASE DIRS ##########################
CHALLENGES="${CURRENT_BASE_DIR_PATH}/Challenges"
JAVA_CHALLENGES="${CHALLENGES}/Java"
JS_CHALLENGES="${CHALLENGES}/JS"
PYTHON_CHALLENGES="${CHALLENGES}/Python"
RUST_CHALLENGES="${CHALLENGES}/Rust"

CPP="${CURRENT_BASE_DIR_PATH}/C++"
CPP_PRACTICE="${CPP}/Practice"
CPP_PROJECTS="${CPP}/Projects"

JAVA="${CURRENT_BASE_DIR_PATH}/Java"
JAVA_PRACTICE="${JAVA}/Practice"
JAVA_PROJECTS="${JAVA}/Projects"

JS="${CURRENT_BASE_DIR_PATH}/JS"
JS_PRACTICE="${JS}/Practice"
JS_PROJECTS="${JS}/Projects"

PYTHON="${CURRENT_BASE_DIR_PATH}/Python"
PYTHON_PRACTICE="${PYTHON}/Practice"
PYTHON_PROJECTS="${PYTHON}/Projects"

RUST="${CURRENT_BASE_DIR_PATH}/Rust"
RUST_PRACTICE="${RUST}/Practice"
RUST_PROJECTS="${RUST}/Projects" 

SCRIPTS="${CURRENT_BASE_DIR_PATH}/Scripts"
SCRIPTS_PRACTICE="${SCRIPTS}/Practice"
SCRIPTS_PROJECTS="${SCRIPTS}/Projects"

WEB="${CURRENT_BASE_DIR_PATH}/Web"
WEB_PRACTICE="${WEB}/Practice"
WEB_PROJECTS="${WEB}/Projects"

MISC="${CURRENT_BASE_DIR_PATH}/Misc"

OPEN_SOURCE="${CURRENT_BASE_DIR_PATH}/OpenSource"

########################## BASE DIRS ARRAY ##########################
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

########################## DIRS WITH REPOS TO UPDATE AND CHECK STATUS ##########################
DIR_ARRAY=(
  "${JAVA_CHALLENGES}"                      
  "${JS_CHALLENGES}"                        
  "${PYTHON_CHALLENGES}"                    
  "${RUST_CHALLENGES}"                      
  "${RUST_PRACTICE}/Course"                 
  "${SCRIPTS_PRACTICE}/ShellScriptShCourse" 
  "${SCRIPTS_PRACTICE}/PowerShellCourse"    
  "${SCRIPTS_PROJECTS}/Private-engen"
  "${SCRIPTS_PROJECTS}/engen"  
  "${WEB_PRACTICE}/WebSockets"              
  "${WEB_PROJECTS}/HowManyRepsWasThat"      
  "${MISC}/Vim"                             
)
CORRESPONDING_PROJECTS_ARRAY=(
  "Java-Challenges"         
  "JavaScript-Challenges"   
  "Python-Challenges"       
  "Rust-Challenges"         
  "Exploring-Rust"          
  "Shell-Script-Sh-Course"  
  "PowerShell-Course"              
  "Private-engen" 
  "engen"    
  "WebSockets"              
  "HowManyRepsWasThat"      
  "Vim-Specifics"           
)

########################## NAMES TO BE REFERENCED FOR UPDATING PURPOSES ##########################
DIR_NAMES_ARRAY=(
  'Java Challenges'
  'JavaScript Challenges'
  'Python Challenges'
  'Rust Challenges'
  'Rust Practice'
  'Scripts Practice(SH Course)'
  'Scripts Practice(PowerShell Course)'
  'Scripts Projects(Private-engen)'
  'Scripts Projects(engen)'
  'Web Practice(WebSockets)'
  'Web Projects(HowManyRepsWasThat)'
  'Misc(Vim-Specifics)'
)
