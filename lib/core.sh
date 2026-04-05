#!/bin/bash
# ================================================================
# engen — Core Library
# Single source of truth for: path resolution, imports, OS detection,
# colors, TUI helpers, and shared utilities.
#
# Every other script sources this file. Nothing else.
# ================================================================

# ----------------------------------------------------------------
# Path Resolution
# ----------------------------------------------------------------

_resolve_engen_root() {
  local source_file="${BASH_SOURCE[0]:-}"

  if [ -z "${source_file}" ] || [ "${source_file}" = "" ]; then
    for candidate in "$(pwd)" "$(pwd)/.."; do
      if [ -f "${candidate}/lib/core.sh" ]; then
        echo "${candidate}"
        return
      fi
    done
    echo "$(pwd)"
    return
  fi

  while [ -L "$source_file" ]; do
    local dir
    dir=$(cd -P "$(dirname "$source_file")" && pwd)
    source_file=$(readlink "$source_file")
    [[ "$source_file" != /* ]] && source_file="$dir/$source_file"
  done
  cd -P "$(dirname "$source_file")/.." && pwd
}

export ENGEN_ROOT="${ENGEN_ROOT:-$(_resolve_engen_root)}"
export ENGEN_CONFIG_DIR="${HOME}/.config/engen"

mkdir -p "${ENGEN_CONFIG_DIR}" 2>/dev/null

# ----------------------------------------------------------------
# Global Command Setup (idempotent)
# ----------------------------------------------------------------
setup_global_command() {
  local profile="${HOME}/.profile"
  [ -f "${profile}" ] || touch "${profile}"

  if ! grep -q "ENGEN_ROOT" "${profile}" 2>/dev/null; then
    echo "" >> "${profile}"
    echo "# engen — environment generator" >> "${profile}"
    echo "export ENGEN_ROOT='${ENGEN_ROOT}'" >> "${profile}"
  fi

  if ! grep -q "alias engen=" "${profile}" 2>/dev/null; then
    echo "alias engen='bash \${ENGEN_ROOT}/engen.sh'" >> "${profile}"
  fi

  for rc in "${HOME}/.bashrc" "${HOME}/.zshrc"; do
    if [ -f "${rc}" ] && ! grep -q "source.*\.profile\|\..*profile" "${rc}" 2>/dev/null; then
      echo "source ~/.profile" >> "${rc}"
    fi
  done
}

setup_global_command

# ----------------------------------------------------------------
# Colors
# ----------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# ----------------------------------------------------------------
# TUI Helpers
# ----------------------------------------------------------------

# Hardcoded section header — no dynamic width calculation
section_header() {
  local title="${1}"
  echo ""
  echo "╔══════════════════════════════════════════════════╗"
  echo "║     ${title}"
  echo "╚══════════════════════════════════════════════════╝"
  echo ""
}

# Indented line
bline() {
  echo "  ${1}"
}

ok() {
  echo -e "  ${GREEN}[ok]${NC} ${1}"
}

warn() {
  echo -e "  ${YELLOW}[!!]${NC} ${1}"
}

err() {
  echo -e "  ${RED}[error]${NC} ${1}"
}

# ----------------------------------------------------------------
# OS Detection (cached)
# ----------------------------------------------------------------

detect_os() {
  if [ -n "${ENGEN_OS:-}" ]; then
    echo "${ENGEN_OS}"
    return
  fi

  case "$(uname -s)" in
    Darwin)  export ENGEN_OS="Darwin" ;;
    Linux)   export ENGEN_OS="Linux" ;;
    MINGW*|MSYS*|CYGWIN*) export ENGEN_OS="Windows" ;;
    *)       export ENGEN_OS="Linux" ;;
  esac
  echo "${ENGEN_OS}"
}

# ----------------------------------------------------------------
# Input Validation (return exit codes for [[ ]] usage)
# ----------------------------------------------------------------

is_number() {
  [[ "${1}" =~ ^[0-9]+$ ]]
}

is_numbers_or_all() {
  [[ "${1}" =~ ^[0-9\ ]+$ ]] || [[ "$(echo "${1}" | tr '[:upper:]' '[:lower:]')" == "all" ]]
}

is_yes() {
  local lower
  lower=$(echo "${1}" | tr '[:upper:]' '[:lower:]')
  [[ "${lower}" == "y" || "${lower}" == "yes" ]]
}

# ----------------------------------------------------------------
# Prompts (display to stderr so $() capture only gets the value)
# ----------------------------------------------------------------

prompt() {
  local label="${1}" default="${2:-}"
  echo -n "  ${label}" >&2
  [ -n "${default}" ] && echo -n " [${default}]" >&2
  echo -n ": " >&2
  local value
  read -r value
  echo "${value:-${default}}"
}

prompt_secret() {
  local label="${1}"
  echo -n "  ${label}: " >&2
  local value
  read -rs value
  echo "" >&2
  echo "${value}"
}

# ----------------------------------------------------------------
# Git Helpers
# ----------------------------------------------------------------

git_username() {
  git config --global user.name 2>/dev/null || echo ""
}

git_email() {
  git config --global user.email 2>/dev/null || echo ""
}

gh_authenticated() {
  command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1
}

ensure_git_configured() {
  local user email
  user=$(git_username)
  email=$(git_email)

  if [ -n "${user}" ] && [ -n "${email}" ]; then
    return 0
  fi

  section_header "Git Setup Required"

  if [ -z "${user}" ]; then
    bline "No GitHub username found in git config."
  fi
  if [ -z "${email}" ]; then
    bline "No GitHub email found in git config."
  fi
  echo ""

  user=$(prompt "GitHub username" "${user}")
  email=$(prompt "GitHub email" "${email}")

  if [ -z "${user}" ] || [ -z "${email}" ]; then
    err "Git credentials are required for this operation."
    return 1
  fi

  git config --global user.name "${user}"
  git config --global user.email "${email}"
  git config --global credential.helper store
  ok "Git configured: ${user} <${email}>"
  echo ""
  return 0
}

# ----------------------------------------------------------------
# Dependency Checks
# ----------------------------------------------------------------

require_command() {
  local cmd="${1}" install_hint="${2:-}"
  if ! command -v "${cmd}" &>/dev/null; then
    err "${cmd} is required but not installed"
    [ -n "${install_hint}" ] && bline "Install: ${install_hint}"
    return 1
  fi
  return 0
}

# ----------------------------------------------------------------
# Config Helpers
# ----------------------------------------------------------------

config_path() {
  echo "${ENGEN_CONFIG_DIR}/${1}.json"
}

# list_configs is defined in json_helpers.sh (single source of truth)

config_exists() {
  [ -f "$(config_path "${1}")" ]
}

# ----------------------------------------------------------------
# Menu Helper
# Displays a numbered menu and re-prompts on invalid input.
# Supports: single number, space-separated numbers, "all".
#
# Usage: menu_select "Choose:" names_array functions_array [args...]
# ----------------------------------------------------------------
menu_select() {
  local prompt_text="${1}"
  shift
  local _names_ref="$1"
  local _funcs_ref="$2"
  shift 2

  # Bash 3.2 (macOS) compatible — no namerefs, no local inside eval
  local _ms_len _ms_fn _ms_name
  eval "_ms_len=\${#${_names_ref}[@]}"

  echo ""
  echo "  ${prompt_text}"
  echo ""
  local i
  for (( i=0; i<_ms_len; i++ )); do
    eval "_ms_name=\${${_names_ref}[\$i]}"
    echo "  ${i}: ${_ms_name}"
  done
  echo ""

  while true; do
    echo -n "  > "
    local choice
    read -r choice

    if [[ -z "${choice}" ]]; then
      continue
    fi

    local lower_choice
    lower_choice=$(echo "${choice}" | tr '[:upper:]' '[:lower:]')

    if [[ "${lower_choice}" == "all" ]]; then
      for (( i=0; i<_ms_len; i++ )); do
        eval "_ms_fn=\${${_funcs_ref}[\$i]}"
        ${_ms_fn} "$@"
      done
      break
    elif [[ "${choice}" =~ ^[0-9]+$ ]] && [ "${choice}" -lt "${_ms_len}" ]; then
      eval "_ms_fn=\${${_funcs_ref}[\${choice}]}"
      ${_ms_fn} "$@"
      break
    elif [[ "${choice}" =~ ^[0-9\ ]+$ ]]; then
      # Multi-select: space-separated numbers
      local any_valid=false
      local idx
      for idx in ${choice}; do
        if is_number "${idx}" && [ "${idx}" -lt "${_ms_len}" ]; then
          eval "_ms_fn=\${${_funcs_ref}[\${idx}]}"
          ${_ms_fn} "$@"
          any_valid=true
        else
          err "Invalid index: ${idx}"
        fi
      done
      if ${any_valid}; then
        break
      fi
    else
      echo ""
      err "Invalid input. Enter a number from the list above."
      echo ""
    fi
  done
}
