#!/bin/bash
# ================================================================
# engen — Batch Git Operations on JSON Config Repos
# ================================================================

# Update all repos in a JSON config
update_all_repos() {
  local config_file="${1}"

  while IFS=' ' read -r repo_dir repo_name; do
    local target="${repo_dir}/${repo_name}"
    if [ -d "${target}/.git" ]; then
      update_git_repo "${target}"
    fi
  done < <(json_tree_to_repos "${config_file}")
}

# Check status of all repos in a JSON config
status_all_repos() {
  local config_file="${1}"

  while IFS=' ' read -r repo_dir repo_name; do
    local target="${repo_dir}/${repo_name}"
    if [ -d "${target}/.git" ]; then
      check_status_of_working_tree "${target}"
    fi
  done < <(json_tree_to_repos "${config_file}")
}

# Interactive repo selection for update or status
# arg1=operation ("update" or "status")
choose_repos() {
  local operation="${1}"

  # Find config
  local configs=()
  for f in "${ENGEN_CONFIG_DIR}"/*.json; do
    [ -f "$f" ] || continue
    configs+=("$f")
  done

  if [ ${#configs[@]} -eq 0 ]; then
    err "No environments found."
    return 1
  fi

  local config_file
  if [ ${#configs[@]} -eq 1 ]; then
    config_file="${configs[0]}"
  else
    bline "Select environment:"
    for i in "${!configs[@]}"; do
      local name
      name=$(json_read "${configs[$i]}" "name" 2>/dev/null)
      bline "  ${i}: ${name}"
    done
    local idx
    idx=$(prompt ">" "0")
    config_file="${configs[$idx]}"
  fi

  # Get repos
  local repo_dirs=() repo_names=()
  while IFS=' ' read -r dir name; do
    local target="${dir}/${name}"
    if [ -d "${target}/.git" ]; then
      repo_dirs+=("${target}")
      repo_names+=("${name}")
    fi
  done < <(json_tree_to_repos "${config_file}")

  if [ ${#repo_names[@]} -eq 0 ]; then
    warn "No cloned repos found in this environment."
    return
  fi

  bline ""
  bline "Repos:"
  for i in "${!repo_names[@]}"; do
    bline "  ${i}: ${repo_names[$i]}"
  done
  bline ""
  local selection
  selection=$(prompt "Select repos (numbers, or 'all')" "all")

  if [[ "$(echo "${selection}" | tr '[:upper:]' '[:lower:]')" == "all" ]]; then
    for dir in "${repo_dirs[@]}"; do
      if [ "${operation}" == "update" ]; then
        update_git_repo "${dir}"
      else
        check_status_of_working_tree "${dir}"
      fi
    done
  else
    local indices
    read -ra indices <<< "${selection}"
    for idx in "${indices[@]}"; do
      if is_number "${idx}" && [ "${idx}" -lt ${#repo_dirs[@]} ]; then
        if [ "${operation}" == "update" ]; then
          update_git_repo "${repo_dirs[$idx]}"
        else
          check_status_of_working_tree "${repo_dirs[$idx]}"
        fi
      fi
    done
  fi
}
