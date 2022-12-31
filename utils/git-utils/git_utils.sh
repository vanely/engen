#!/bin/bash

function get_engen_fs_location() {
  if [[ -z $(grep "ENGEN_FS_LOCATION" ~/.profile) ]] ; then
    # "dirname" returns the path up to but not including the final dir
    REMOVED_FINAL_DIR=$(dirname $(pwd))
    DOUBLY_REMOVED_FINAL_DIR=$(dirname ${REMOVED_FINAL_DIR})
    echo ${DOUBLY_REMOVED_FINAL_DIR}
  else
    # will be exported from ~/.profile
    echo ENGEN_FS_LOCATION
  fi
}

# pass config context as an arg to this script from main.sh(main will have the context as an optional arg. Account for this)


# clone repos into their respective directories
# arg1=GIT_REPO_NAME arg2=DIRECTORY_NAME <--- dir to clone repo into
clone_git_repo() {
  # derive USER_NAME from .gitconfig
  # file search
  if [[ ! -f ~/.gitconfig ]] ; then
    echo
    echo "a global reference to your git config is needed to clone repos"
    echo "you'll need to run the following git commands"
    echo
    echo "git config --global user.name '<user_name>'"
    echo "git config --global user.email '<email>'"
    echo
    echo "replace everything inside of the single 'quotes' with your respective credentials"
    echo
  else
    name=($(grep "name" ~/.gitconfig))
    USER_NAME="${name[2]}"
    GIT_REPO_TEMPLATE="https://github.com/${USER_NAME}/${1}.git"
    echo
    echo "========================================================================================="
    cd "${2}" || exit
    echo "Cloning ${GIT_REPO_TEMPLATE} into ${2}"
    git clone "${GIT_REPO_TEMPLATE}" .
    echo "========================================================================================="
  fi
}

# updates(pulls) git repos in their respective directories
# arg1=DIRECTORY_NAME
update_git_repo() {
  echo
  echo "========================================================================================="
  cd "${1}" || exit
  echo "Updating Local Repo: "
  echo "${1} ..."
  git pull
  echo "========================================================================================="
}

# runs git status on repos in their respective directories
# arg1=DIRECTORY_NAME
check_status_of_working_tree() {
  echo
  echo "========================================================================================="
  cd "${1}" || exit
  echo "Checking Local Repo Status: "
  echo "${1}..."
  git status
  echo "========================================================================================="
}

github_auth() {
  # find some way to safely access sensitive token/ or remove
  # file search
  if [[ -f "$(get_engen_fs_location)/utils/git-utils/tokenFile.txt" ]] ; then 
    gh auth login --with-token < "$(get_engen_fs_location)/utils/git-utils/tokenFile.txt"
  else
    gh auth login
  fi
}

github_deauth() {
  gh auth logout
}

# arg1=repo_name arg2=access
create_repo_with_gh_cli() {
  echo "Creating repo: ${1}"
  gh repo create "${1}" "--${2}"
}

# arg1=repo name
delete_repo_with_gh_cli() {
  echo "Deleting repo: ${1}"
  gh repo delete "${1}" --confirm
}
