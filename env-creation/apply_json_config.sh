#!/bin/bash
# ================================================================
# engen — Apply JSON Config
# Creates directories and clones repos from a JSON config file.
# ================================================================

apply_json_config() {
  local config_file="${1}"

  if [[ ! -f "${config_file}" ]]; then
    err "Config file not found: ${config_file}"
    return 1
  fi

  if [[ "$(validate_json "${config_file}")" != "valid" ]]; then
    err "Invalid JSON in config file: ${config_file}"
    return 1
  fi

  local env_name base_path
  env_name=$(json_read "${config_file}" "name")
  base_path=$(json_read "${config_file}" "path")
  base_path="${base_path/#\~/$HOME}"

  section_header "Applying: ${env_name}"
  bline ""

  # Create base directory
  if [[ ! -d "${base_path}" ]]; then
    mkdir -p "${base_path}"
    ok "Created base: ${base_path}"
  fi

  # Create all directories
  bline "Creating directories..."
  while IFS= read -r dir_path; do
    if [[ ! -d "${dir_path}" ]]; then
      mkdir -p "${dir_path}"
      bline "  + ${dir_path##${base_path}/}"
    fi
  done < <(json_tree_to_paths "${config_file}")

  # Clone repos — ensure git is configured before attempting
  local has_repos=false
  local git_user=""

  local repo_count
  repo_count=$(json_tree_to_repos "${config_file}" | wc -l)
  if [ "${repo_count}" -gt 0 ]; then
    ensure_git_configured || { warn "Skipping repo cloning — no git credentials."; echo ""; return; }
    git_user=$(git_username)
  fi

  while IFS=' ' read -r repo_dir repo_name; do
    has_repos=true
    local target_dir="${repo_dir}/${repo_name}"

    if [[ -d "${target_dir}" ]] && [[ -d "${target_dir}/.git" ]]; then
      ok "${repo_name} (exists)"
      continue
    fi

    bline "  Cloning ${repo_name}..."
    mkdir -p "${repo_dir}"

    if [[ "${repo_name}" == */* ]]; then
      if command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1; then
        gh repo clone "${repo_name}" "${target_dir}" 2>/dev/null || \
          git clone "https://github.com/${repo_name}.git" "${target_dir}" 2>/dev/null || \
          err "Failed: ${repo_name}"
      else
        git clone "https://github.com/${repo_name}.git" "${target_dir}" 2>/dev/null || \
          err "Failed: ${repo_name}"
      fi
    else
      if command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1; then
        gh repo clone "${git_user}/${repo_name}" "${target_dir}" 2>/dev/null || \
          err "Failed: ${repo_name}"
      else
        git clone "https://github.com/${git_user}/${repo_name}.git" "${target_dir}" 2>/dev/null || \
          err "Failed: ${repo_name}"
      fi
    fi
  done < <(json_tree_to_repos "${config_file}")

  if ! $has_repos; then
    bline "  (no repos configured)"
  fi

  bline ""
  ok "Environment applied: ${env_name}"
  echo ""
}
