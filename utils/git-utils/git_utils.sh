#!/bin/bash

# clone repos into their respective directories
# arg1=GIT_REPO_NAME arg2=DIRECTORY_NAME <--- dir to clone repo into
clone_git_repo() {
  GIT_REPO_TEMPLATE="https://github.com/<USER_NAME>/${1}.git"
  echo
  echo "==================================================="
  cd "${2}" || exit
  echo "Cloning ${GIT_REPO_TEMPLATE} into ${2}"
  # will clone the contents of a repo into a dir but won't create a new dir
  git clone "${GIT_REPO_TEMPLATE}" .
  echo "==================================================="
}

# updates(pulls) git repos in their respective directories
# arg1=DIRECTORY_NAME
update_git_repo() {
  echo
  echo "==================================================="
  cd "${1}" || exit
  echo "Updating Local Repo: "
  echo "${1} ..."
  git pull
  echo "==================================================="
}

# runs git status on repos in their respective directories
# arg1=DIRECTORY_NAME
check_status_of_working_tree() {
  echo
  echo "==================================================="
  cd "${1}" || exit
  echo "Checking Local Repo Status: "
  echo "${1}..."
  git status
  echo "==================================================="
}
