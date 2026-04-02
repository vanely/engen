#!/bin/bash


# clone repos into their respective directories
# arg1=GIT_REPO_NAME arg2=DIRECTORY_NAME <--- dir to clone repo into
clone_git_repo() {
  local USER_NAME
  USER_NAME=$(git_username)

  if [[ -z "${USER_NAME}" ]]; then
    ensure_git_configured || return 1
    USER_NAME=$(git_username)
  fi

  local repo_name="${1}"
  local target_dir="${2}"

  # If repo contains a slash, treat as owner/repo
  local clone_url
  if [[ "${repo_name}" == */* ]]; then
    clone_url="https://github.com/${repo_name}.git"
  else
    clone_url="https://github.com/${USER_NAME}/${repo_name}.git"
  fi

  echo ""
  echo "========================================================================================="
  cd "${target_dir}" || return 1
  echo "Cloning ${clone_url} into ${target_dir}"
  git clone "${clone_url}" .
  echo "========================================================================================="
}

# updates(pulls) git repos in their respective directories
# arg1=DIRECTORY_NAME
update_git_repo() {
  echo ""
  echo "========================================================================================="
  cd "${1}" || return 1
  echo "Updating Local Repo: "
  echo "${1} ..."
  git pull
  echo "========================================================================================="
}

# runs git status on repos in their respective directories
# arg1=DIRECTORY_NAME
check_status_of_working_tree() {
  echo ""
  echo "========================================================================================="
  cd "${1}" || return 1
  echo "Checking Local Repo Status: "
  echo "${1}..."
  git status
  echo "========================================================================================="
}

github_auth() {
  if gh auth status &>/dev/null; then
    echo "Already authenticated with GitHub."
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
