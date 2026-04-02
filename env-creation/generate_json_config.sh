#!/bin/bash
# ================================================================
# engen — Interactive JSON Config Creation
# ================================================================

generate_json_config() {
  local env_name="${1}"

  # Prompt for environment name if not given
  if [[ -z "${env_name}" ]]; then
    section_header "Create New Environment"
    bline ""
    env_name=$(prompt "Environment name" "")
  fi

  if [[ -z "${env_name}" ]]; then
    err "Name cannot be empty"
    return 1
  fi

  ensure_config_dir
  local config_path
  config_path="$(get_config_path "${env_name}")"

  if [[ -f "${config_path}" ]]; then
    warn "Config already exists: ${config_path}"
    bline "Use 'engen edit ${env_name}' to modify it."
    return 1
  fi

  # Prompt for base path
  bline ""
  local base_path
  base_path=$(prompt "Base path" "${HOME}/Projects/${env_name}")
  base_path="${base_path/#\~/$HOME}"

  # Read git config
  local git_user git_email
  git_user=$(git config --global user.name 2>/dev/null || echo "")
  git_email=$(git config --global user.email 2>/dev/null || echo "")

  # Build initial JSON
  python3 -c "
import json, sys
config = {
    'name': sys.argv[1],
    'path': sys.argv[2],
    'git': {
        'username': sys.argv[3] if sys.argv[3] else None,
        'email': sys.argv[4] if sys.argv[4] else None
    },
    'tree': {},
    'tools': {'installed': []}
}
with open(sys.argv[5], 'w') as f:
    json.dump(config, f, indent=2)
" "${env_name}" "${base_path}" "${git_user}" "${git_email}" "${config_path}"

  bline ""
  bline "Define your directory tree."
  bline "Enter paths relative to ${base_path}."
  bline "Use / for nesting (e.g., Challenges/Java)."
  bline "Empty line = done."
  bline ""

  while true; do
    local dir_path
    dir_path=$(prompt "Directory" "")
    [[ -z "${dir_path}" ]] && break
    json_tree_add_dir "${config_path}" "${dir_path}"
    ok "${dir_path}"
  done

  bline ""
  bline "Add repos? Format: directory_path repo_name"
  bline "Example: Challenges/JS my-js-project"
  bline "Empty line = done."
  bline ""

  while true; do
    local repo_entry
    repo_entry=$(prompt "Dir Repo" "")
    [[ -z "${repo_entry}" ]] && break

    local repo_dir repo_name
    repo_dir=$(echo "${repo_entry}" | awk '{print $1}')
    repo_name=$(echo "${repo_entry}" | awk '{print $2}')

    if [[ -z "${repo_dir}" ]] || [[ -z "${repo_name}" ]]; then
      err "Format: directory_path repo_name"
      continue
    fi

    json_tree_add_repo "${config_path}" "${repo_dir}" "${repo_name}"
    ok "${repo_name} -> ${repo_dir}"
  done

  bline ""
  ok "Config saved: ${config_path}"
  echo ""
}
