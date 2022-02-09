#!/bin/bash

# no need to touch this, it will get prepopulate with the ROOT_ENV_OS value
# that gets exported at the beginning of generating a directory tree
CURRENT_ROOT_ENV_OS="${ROOT_ENV_OS}"

# The path to your generated directory tree, starting from the home directory
CURRENT_BASE_DIR_PATH=

# The name of the root directory for a generated directory tree
# this is also the suffix for this files name
CURRENT_BASE_DIR_NAME=

# git credentials used to pull repos
CURRENT_GIT_USER_NAME=

CURRENT_GIT_EMAIL=
########################## BASE DIRS ##########################

# feel free to set base directories of your choosing, and regenerate a directory tree
# from an existing config based on your modifications

# NOTE: don't forget to add your base directories to the BASE_DIR_ARRAY

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

# extenstions to above base directories that will have github projects 
# from the below CORRESPONDING_PROJECTS_ARRAY cloned into them(project must be at same index as directory name)
# name the directory extension something similar to the project as to not have to count the indexes 
DIR_ARRAY=(
  # "${JAVA_CHALLENGES}"                      
  # "${JS_CHALLENGES}"                        
  # "${PYTHON_CHALLENGES}"                    
  # "${RUST_CHALLENGES}"                      
  # "${RUST_PRACTICE}/Course"                 
  # "${SCRIPTS_PRACTICE}/ShellScriptShCourse" 
  # "${SCRIPTS_PRACTICE}/PowerShellCourse"
)

# EX: "Repo-Name repo_access" <--- repo name and repo access separated by space
# NOTE: only set private access if you"ve added your github personal access token in the config file
# you can still use public, or not provide access keyword(which is equivalent to public) 
#  and just enter your git credentials when the cloning process prompts you to.
CORRESPONDING_PROJECTS_ARRAY=(
  # "Java-Challenges private"         
  # "JavaScript-Challenges public"   
  # "Python-Challenges public"       
  # "Rust-Challenges private"         
  # "Exploring-Rust private"          
  # "Shell-Script-Sh-Course public"  
  # "PowerShell-Course public"      
)

########################## NAMES TO BE REFERENCED FOR UPDATING PURPOSES ##########################

# names for your projects(these will be dispaled when using utils to update git repos, and your directory tree)
DIR_NAMES_ARRAY=(
  # "Java Challenges"
  # "JavaScript Challenges"
  # "Python Challenges"
  # "Rust Challenges"
  # "Rust Practice"
  # "Scripts Practice(SH Course)"
  # "Scripts Practice(PowerShell Course)"
)
