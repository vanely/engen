#!/bin/bash
# ================================================================
# engen — Main Menu
# Interactive menu for environment management.
# ================================================================

# Source core library
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/core.sh"

# Source subsystems
source "${ENGEN_ROOT}/utils/helpers/json_helpers.sh"
source "${ENGEN_ROOT}/utils/helpers/validation.sh"
source "${ENGEN_ROOT}/utils/helpers/helpers.sh"
source "${ENGEN_ROOT}/env-creation/generate_json_config.sh"
source "${ENGEN_ROOT}/env-creation/apply_json_config.sh"
source "${ENGEN_ROOT}/programs-to-install/linux/choose_programs_and_install.sh"
source "${ENGEN_ROOT}/utils/cleanup/main.sh"
source "${ENGEN_ROOT}/utils/git-utils/main.sh"
source "${ENGEN_ROOT}/utils/helpers/vscode_extensions.sh"

# ----------------------------------------------------------------
# Context — passed from engen.sh or as $1
# ----------------------------------------------------------------
CONTEXT_ENV_NAME="${1:-}"

# ----------------------------------------------------------------
# Processes
# ----------------------------------------------------------------

process_create() {
  # Always create fresh — don't pass existing context name
  generate_json_config ""
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

process_sync() {
  if [ -z "${CONTEXT_ENV_NAME}" ]; then
    section_header "Sync Environment"
    local configs
    configs=$(list_configs)
    if [ -z "${configs}" ]; then
      warn "No configs found. Create one first."
      return
    fi
    bline ""
    echo "${configs}" | while read -r name; do bline "  ${name}"; done
    bline ""
    CONTEXT_ENV_NAME=$(prompt "Environment name" "")
  fi

  local path
  path=$(config_path "${CONTEXT_ENV_NAME}")
  if [ -f "${path}" ]; then
    apply_json_config "${path}"
  else
    err "Config not found: ${CONTEXT_ENV_NAME}"
  fi
}

process_install() {
  iteratively_install_programs
}

process_cleanup() {
  clean_up
}

process_git() {
  git_utils
}

process_vscode() {
  choose_extensions_to_install
}

process_tunnel() {
  bash "${ENGEN_ROOT}/utils/tunnel/tunnel.sh" list
}

# ----------------------------------------------------------------
# Menu
# ----------------------------------------------------------------

PROCESS_NAMES=(
  "Create Environment"
  "Sync Environment"
  "Install Programs"
  "Clean Up"
  "Git Utils"
  "VS Code Extensions"
  "Tunnel (expose local port)"
)

PROCESS_FUNCS=(
  process_create
  process_sync
  process_install
  process_cleanup
  process_git
  process_vscode
  process_tunnel
)

if [ -n "${CONTEXT_ENV_NAME}" ]; then
  section_header "ENGEN — ${CONTEXT_ENV_NAME}"
else
  section_header "ENGEN"
fi
menu_select "Choose a process:" PROCESS_NAMES PROCESS_FUNCS
# return code 2 = back — just exit main.sh, returns to engen.sh

