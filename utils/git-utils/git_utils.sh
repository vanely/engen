#!/bin/bash

# clone repos into their respective directories
# arg1=GIT_REPO_NAME arg2=DIRECTORY_NAME <--- dir to clone repo into arg3=access("private" || ("public" || ""))
clone_git_repo() {
  GIT_REPO_TEMPLATE=""
  if [[ "${3}" == "private" ]] ; then
    # bypass auth "https://<username>:<password>@github.com/<username>/repo-name.git"
    GIT_REPO_TEMPLATE="https://vanely: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@github.com/vanely/${1}.git"
  elif [[ "${3}" == "public" ]] || [[ -z "${3}" ]] ; then
    GIT_REPO_TEMPLATE="https://github.com/vanely/${1}.git"
  else
    echo "Inlavid access modifier(3rd argument: ${3})."
    echo "Use either: 'private' or 'public' or leave empty == public))"
    exit
  fi
  echo
  echo "========================================================================================="
  cd "${2}" || exit
  echo "Cloning ${GIT_REPO_TEMPLATE} into ${2}"
  git clone "${GIT_REPO_TEMPLATE}" .
  echo "========================================================================================="
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
  if [[ -f "/${HOME}/engen/utils/git-utils/tokenFile.txt" ]] ; then 
    gh auth login --with-token < "/${HOME}/engen/utils/git-utils/tokenFile.txt"
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
