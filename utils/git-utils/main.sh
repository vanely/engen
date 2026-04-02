#!/bin/bash
# ================================================================
# engen — Git Utilities Menu
# ================================================================

source "${ENGEN_ROOT}/utils/git-utils/git_update_repos.sh"
source "${ENGEN_ROOT}/utils/git-utils/git_utils.sh"

# ----------------------------------------------------------------
# Git operations
# ----------------------------------------------------------------

git_update_repos() {
  section_header "Git — Update Repos"
  choose_repos "update"
}

git_status_repos() {
  section_header "Git — Repo Status"
  choose_repos "status"
}

git_create_repo() {
  section_header "Git — Create Repo"

  ensure_git_configured || return 1
  local git_user
  git_user=$(git_username)

  github_auth

  local repo_name
  repo_name=$(prompt "Repo name" "")
  [ -z "${repo_name}" ] && return

  local visibility
  visibility=$(prompt "Visibility (public/private)" "public")

  create_repo_with_gh_cli "${repo_name}" "${visibility}"
  ok "Created: ${git_user}/${repo_name} (${visibility})"
  echo ""
}

git_delete_repo() {
  section_header "Git — Delete Repo"

  ensure_git_configured || return 1
  local git_user
  git_user=$(git_username)

  github_auth

  # List repos
  local repos
  repos=$(gh repo list "${git_user}" --source --limit 50 2>/dev/null)

  if [ -z "${repos}" ]; then
    warn "No repos found or not authenticated."
    return
  fi

  bline ""
  bline "Your repos:"
  echo "${repos}" | while read -r line; do bline "  ${line}"; done
  bline ""

  local repo_name
  repo_name=$(prompt "Repo name to delete" "")
  [ -z "${repo_name}" ] && return

  local confirm
  confirm=$(prompt "Delete ${git_user}/${repo_name}? This is irreversible. (y/n)" "n")
  if is_yes "${confirm}"; then
    delete_repo_with_gh_cli "${git_user}/${repo_name}"
    ok "Deleted: ${git_user}/${repo_name}"
  else
    bline "Cancelled."
  fi
  echo ""
}

git_setup_credentials() {
  section_header "Git — Setup Credentials"

  local current_user current_email
  current_user=$(git_username)
  current_email=$(git_email)

  local user
  user=$(prompt "GitHub username" "${current_user}")
  local email
  email=$(prompt "GitHub email" "${current_email}")

  if [ -n "${user}" ] && [ -n "${email}" ]; then
    git config --global user.name "${user}"
    git config --global user.email "${email}"
    git config --global credential.helper store
    ok "Git config set: ${user} <${email}>"
  fi

  # GitHub CLI auth
  bline ""
  if gh_authenticated; then
    ok "Already authenticated with GitHub CLI"
  else
    bline "Authenticate with GitHub for private repo access:"
    bline "  1. Go to: https://github.com/settings/tokens"
    bline "  2. Generate new token (classic)"
    bline "  3. Scopes: repo, read:org"
    bline ""
    local token
    token=$(prompt_secret "Paste token (or Enter to skip)")
    if [ -n "${token}" ]; then
      echo "${token}" | gh auth login --with-token 2>/dev/null
      if gh_authenticated; then
        ok "Authenticated with GitHub"
      else
        err "Authentication failed — try: gh auth login"
      fi
    else
      bline "Skipped."
    fi
  fi
  echo ""
}

# ----------------------------------------------------------------
# Menu
# ----------------------------------------------------------------

GIT_NAMES=(
  "Update Repos (pull)"
  "Repo Status"
  "Create Repo"
  "Delete Repo"
  "Setup Git Credentials"
)

GIT_FUNCS=(
  git_update_repos
  git_status_repos
  git_create_repo
  git_delete_repo
  git_setup_credentials
)

git_utils() {
  section_header "Git Utils"
  menu_select "Choose an operation:" GIT_NAMES GIT_FUNCS
}
