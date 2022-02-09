#!/bin/bash

CURRENT_ROOT_ENV_OS=""
CURRENT_BASE_DIR=""
CURRENT_BASE_DIR_NAME=""

########################## BASE DIRS ##########################
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
  "${SCRIPTS_PROJECTS}/PersonalEnvGenerator"
  "${SCRIPTS_PROJECTS}/PublicEnvGenerator"  
  "${WEB_PRACTICE}/WebSockets"              
  "${WEB_PROJECTS}/HowManyRepsWasThat"      
  "${MISC}/Vim"                             
)
CORRESPONDING_PROJECTS_ARRAY=(
  "Java-Challenges public"         
  "JavaScript-Challenges public"   
  "Python-Challenges public"       
  "Rust-Challenges public"         
  "Exploring-Rust public"          
  "Shell-Script-Sh-Course public"  
  "PowerShell-Course public"              
  "Personal-Env-Generator private" 
  "Public-Env-Generator public"    
  "WebSockets public"              
  "HowManyRepsWasThat public"      
  "Vim-Specifics public"           
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
  'Scripts Projects(PersonalEnvGenerator)'
  'Scripts Projects(PublicEnvGenerator)'
  'Web Practice(WebSockets)'
  'Web Projects(HowManyRepsWasThat)'
  'Misc(Vim-Specifics)'
)
