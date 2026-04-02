#!/bin/bash
# ================================================================
# engen — CLI Entry Point
# Routes subcommands or falls back to the interactive menu.
#
# Usage:
#   engen                    Interactive menu
#   engen new [name]         Create a new environment
#   engen sync <name>        Apply config (create dirs, clone repos)
#   engen edit <name>        Open config in $EDITOR
#   engen list               List all environments
#   engen tunnel [port]      Expose local port via tunnel
#   engen <name>             Sync a named environment
#   engen -h                 Help
# ================================================================

# Source core library
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/core.sh"

# Source JSON subsystem
source "${ENGEN_ROOT}/utils/helpers/json_helpers.sh"
source "${ENGEN_ROOT}/env-creation/generate_json_config.sh"
source "${ENGEN_ROOT}/env-creation/apply_json_config.sh"

# Save execution context
ORIGINAL_DIR="$(pwd)"
cleanup_and_return() {
  cd "${ORIGINAL_DIR}" 2>/dev/null || cd "${HOME}"
}
trap 'cleanup_and_return; exit' SIGINT

# ----------------------------------------------------------------
# Subcommands
# ----------------------------------------------------------------

cmd_help() {
  section_header "engen — Environment Generator"
  bline ""
  bline "Usage: engen [command] [args]"
  bline ""
  bline "Commands:"
  bline "  new [name]         Create a new JSON config + directory tree"
  bline "  sync <name>        Apply config — create missing dirs, clone repos"
  bline "  edit <name>        Open config in \$EDITOR"
  bline "  list               List all environments"
  bline "  tunnel [port]      Expose a local port via Cloudflare tunnel"
  bline ""
  bline "Options:"
  bline "  -h, --help         Show this help"
  bline ""
  bline "No arguments: interactive menu"
  echo ""
}

cmd_new() {
  local name="${1:-}"
  generate_json_config "${name}"
  local newest
  newest=$(ls -t "${ENGEN_CONFIG_DIR}"/*.json 2>/dev/null | head -1)
  if [ -n "${newest}" ]; then
    local apply
    apply=$(prompt "Apply this config now? (y/n)" "y")
    if is_yes "${apply}"; then
      apply_json_config "${newest}"
    fi
  fi
}

cmd_sync() {
  local name="${1:-}"
  if [ -z "${name}" ]; then
    section_header "Sync — Apply Config"
    bline ""
    bline "Usage: engen sync <env-name>"
    bline ""
    bline "Available:"
    local configs
    configs=$(list_configs)
    if [ -n "${configs}" ]; then
      echo "${configs}" | while read -r c; do bline "  ${c}"; done
    else
      bline "  (none — create one with: engen new)"
    fi
    echo ""
    cleanup_and_return
    return 1
  fi

  local path
  path=$(config_path "${name}")
  if [ -f "${path}" ]; then
    apply_json_config "${path}"
  else
    section_header "Sync — Config Not Found"
    err "No config for: ${name}"
    bline ""
    bline "Available:"
    list_configs | while read -r c; do [ -n "$c" ] && bline "  ${c}"; done
    echo ""
  fi
}

cmd_edit() {
  local name="${1:-}"
  if [ -z "${name}" ]; then
    section_header "Edit — Open Config"
    bline ""
    bline "Usage: engen edit <env-name>"
    bline ""
    bline "Available:"
    list_configs | while read -r c; do [ -n "$c" ] && bline "  ${c}"; done
    echo ""
    cleanup_and_return
    return 1
  fi

  local path
  path=$(config_path "${name}")
  if [ -f "${path}" ]; then
    ${EDITOR:-vim} "${path}"
    ok "Config updated."
    bline "Run 'engen sync ${name}' to apply changes."
    echo ""
  else
    section_header "Edit — Config Not Found"
    err "No config for: ${name}"
    echo ""
  fi
}

cmd_list() {
  section_header "Environments"
  bline ""

  local found=false
  for f in "${ENGEN_CONFIG_DIR}"/*.json; do
    [ -f "$f" ] || continue
    found=true
    local name path
    name=$(json_read "$f" "name" 2>/dev/null)
    path=$(json_read "$f" "path" 2>/dev/null)
    bline "${name:-$(basename "$f" .json)}"
    bline "  ${path}"
  done

  if ! $found; then
    bline "(none)"
    bline ""
    bline "Create one: engen new my-workspace"
  fi
  echo ""
}

cmd_tunnel() {
  local port="${1:-}"
  if [ -n "${port}" ]; then
    bash "${ENGEN_ROOT}/utils/tunnel/tunnel.sh" start "${port}"
  else
    bash "${ENGEN_ROOT}/utils/tunnel/tunnel.sh" list
  fi
}

cmd_interactive() {
  local name="${1:-}"

  # If a name was given, pass it as context to main menu
  if [ -n "${name}" ]; then
    bash "${ENGEN_ROOT}/main.sh" "${name}"
    cleanup_and_return
    return
  fi

  # No args — show environments and let user pick, or go to main menu
  local configs=()
  while IFS= read -r c; do
    [ -n "$c" ] && configs+=("$c")
  done < <(list_configs)

  if [ ${#configs[@]} -eq 0 ]; then
    # No environments — go straight to main menu
    bash "${ENGEN_ROOT}/main.sh"
    cleanup_and_return
    return
  fi

  section_header "Environments"

  echo "  Select an environment, or 'm' for main menu:"
  echo ""
  for i in "${!configs[@]}"; do
    echo "  ${i}: ${configs[$i]}"
  done
  echo ""

  while true; do
    echo -n "  > "
    read -r choice

    local lower_choice
    lower_choice=$(echo "${choice}" | tr '[:upper:]' '[:lower:]')

    if [ "${lower_choice}" == "m" ]; then
      bash "${ENGEN_ROOT}/main.sh"
      break
    elif is_number "${choice}" && [ "${choice}" -lt ${#configs[@]} ]; then
      bash "${ENGEN_ROOT}/main.sh" "${configs[$choice]}"
      break
    else
      echo ""
      err "Invalid input. Enter a number from the list, or 'm' for main menu."
      echo ""
    fi
  done

  cleanup_and_return
}

# ----------------------------------------------------------------
# Route
# ----------------------------------------------------------------
case "${1:-}" in
  -h|--help)     cmd_help ;;
  new)           cmd_new "${2:-}" ;;
  sync)          cmd_sync "${2:-}" ;;
  edit)          cmd_edit "${2:-}" ;;
  list)          cmd_list ;;
  tunnel)        cmd_tunnel "${2:-}" ;;
  *)             cmd_interactive "${1:-}" ;;
esac

cleanup_and_return
