#!/bin/bash
# ================================================================
# engen — Cleanup Menu
# Selective removal of directories and installed tools.
# JSON config only.
# ================================================================

source "${ENGEN_ROOT}/utils/cleanup/cleanup_installs.sh"

# ----------------------------------------------------------------
# Select a JSON config to operate on
# ----------------------------------------------------------------
select_config() {
  local configs=()
  for f in "${ENGEN_CONFIG_DIR}"/*.json; do
    [ -f "$f" ] || continue
    configs+=("$f")
  done

  if [ ${#configs[@]} -eq 0 ]; then
    err "No environments found. Create one: engen new"
    return 1
  fi

  if [ ${#configs[@]} -eq 1 ]; then
    echo "${configs[0]}"
    return
  fi

  bline "Select environment:"
  for i in "${!configs[@]}"; do
    local name
    name=$(json_read "${configs[$i]}" "name" 2>/dev/null)
    bline "  ${i}: ${name:-$(basename "${configs[$i]}" .json)}"
  done
  local idx
  idx=$(prompt ">" "0")
  if is_number "${idx}" && [ "${idx}" -lt ${#configs[@]} ]; then
    echo "${configs[$idx]}"
  else
    err "Invalid selection"
    return 1
  fi
}

# ----------------------------------------------------------------
# Remove directories — selective from JSON tree
# ----------------------------------------------------------------
remove_directories() {
  section_header "Cleanup — Remove Directories"

  local config_file
  config_file=$(select_config) || return

  local env_name base_path
  env_name=$(json_read "${config_file}" "name")
  base_path=$(json_read "${config_file}" "path")
  base_path="${base_path/#\~/$HOME}"

  bline ""
  bline "Environment: ${env_name}"
  bline "Path: ${base_path}"
  bline ""
  json_tree_display "${config_file}"
  bline ""

  local selection
  selection=$(prompt "Remove (numbers, 'all', or 'env' for entire environment)" "")

  case "${selection,,}" in
    env)
      local confirm
      confirm=$(prompt "Delete ENTIRE environment at ${base_path}? (y/n)" "n")
      if is_yes "${confirm}"; then
        rm -rf "${base_path}"
        rm -f "${config_file}"
        ok "Environment removed: ${env_name}"
      else
        bline "Cancelled."
      fi
      ;;
    all)
      local confirm
      confirm=$(prompt "Remove ALL directories? Config will be kept. (y/n)" "n")
      if is_yes "${confirm}"; then
        while IFS= read -r dir_path; do
          [ -d "${dir_path}" ] && rm -rf "${dir_path}"
        done < <(json_tree_to_paths "${config_file}" | sort -r)
        ok "All directories removed. Config kept at: ${config_file}"
      else
        bline "Cancelled."
      fi
      ;;
    *)
      local indices
      read -ra indices <<< "${selection}"
      IFS=$'\n' sorted=($(printf '%s\n' "${indices[@]}" | sort -rn))
      unset IFS
      for idx in "${sorted[@]}"; do
        if is_number "${idx}"; then
          json_tree_remove_by_index "${config_file}" "${idx}"
          ok "Removed entry ${idx}"
        fi
      done
      bline "Config updated."
      ;;
  esac
  echo ""
}

# ----------------------------------------------------------------
# Remove installed tools
# ----------------------------------------------------------------
remove_tools() {
  section_header "Cleanup — Remove Installed Tools"
  local config_file
  config_file=$(select_config) || return
  remove_installs "${config_file}"
}

# ----------------------------------------------------------------
# Remove entire environment
# ----------------------------------------------------------------
remove_environment() {
  section_header "Cleanup — Remove Environment"
  local config_file
  config_file=$(select_config) || return

  local env_name base_path
  env_name=$(json_read "${config_file}" "name")
  base_path=$(json_read "${config_file}" "path")
  base_path="${base_path/#\~/$HOME}"

  bline ""
  warn "This will delete:"
  bline "  Directory tree: ${base_path}"
  bline "  Config file: ${config_file}"
  bline "  Tracked tool installations"
  bline ""

  local confirm
  confirm=$(prompt "Are you sure? (y/n)" "n")
  if is_yes "${confirm}"; then
    [ -d "${base_path}" ] && rm -rf "${base_path}"
    rm -f "${config_file}"
    ok "Environment '${env_name}' completely removed."
  else
    bline "Cancelled."
  fi
  echo ""
}

# ----------------------------------------------------------------
# Main menu
# ----------------------------------------------------------------

CLEANUP_NAMES=(
  "Remove Directories (selective)"
  "Remove Installed Tools"
  "Remove Entire Environment"
)

CLEANUP_FUNCS=(
  remove_directories
  remove_tools
  remove_environment
)

clean_up() {
  section_header "Cleanup"
  menu_select "Choose an option:" CLEANUP_NAMES CLEANUP_FUNCS
}
