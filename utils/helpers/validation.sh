#!/bin/bash
# ================================================================
# engen — Input Validation Helpers
# These functions return "true"/"false" strings for backward
# compatibility with existing [[ ]] checks.
# ================================================================

# Validate single integer
input_is_number() {
  if [[ "${1}" =~ ^[0-9]+$ ]]; then
    echo "true"
  else
    echo "false"
  fi
}

# Validate space-separated integers
input_is_number_with_possible_spaces() {
  if [[ "${1}" =~ ^[0-9\ ]+$ ]]; then
    echo "true"
  else
    echo "false"
  fi
}

# Validate the word "all"
input_is_the_word_all() {
  if [[ "${1,,}" == "all" ]]; then
    echo "true"
  else
    echo "false"
  fi
}

# Check if .profile is sourced in shell rc files
# Returns: "sourced", "!b" (not in bashrc), "!z" (not in zshrc), "!b!z" (neither)
profile_not_sourced() {
  local in_bashrc=false
  local in_zshrc=false

  if [ -f "${HOME}/.bashrc" ]; then
    grep -q "source.*\.profile\|\..*profile" "${HOME}/.bashrc" 2>/dev/null && in_bashrc=true
  else
    in_bashrc=true  # No bashrc = no need to source there
  fi

  if [ -f "${HOME}/.zshrc" ]; then
    grep -q "source.*\.profile\|\..*profile" "${HOME}/.zshrc" 2>/dev/null && in_zshrc=true
  else
    in_zshrc=true  # No zshrc = no need to source there
  fi

  if $in_bashrc && $in_zshrc; then
    echo "sourced"
  elif ! $in_bashrc && ! $in_zshrc; then
    echo "!b!z"
  elif ! $in_bashrc; then
    echo "!b"
  else
    echo "!z"
  fi
}

# Check if a config file exists
config_file_exists() {
  if [[ -f "${1}" ]]; then
    echo "true"
  else
    echo "false"
  fi
}

# Validate y/n input
input_is_y_or_n() {
  if [[ "${1,,}" == "y" ]] || [[ "${1,,}" == "n" ]]; then
    echo "true"
  else
    echo "false"
  fi
}

# Validate JSON config structure
validate_json_config() {
  local config_file="${1}"

  if [[ ! -f "${config_file}" ]]; then
    echo "missing"
    return
  fi

  python3 -c "
import json, sys
try:
    with open('${config_file}') as f:
        data = json.load(f)
    for key in ['name', 'path', 'tree']:
        if key not in data:
            print(f'missing_key:{key}')
            sys.exit(0)
    if not isinstance(data['tree'], dict):
        print('invalid_tree')
        sys.exit(0)
    print('valid')
except json.JSONDecodeError as e:
    print(f'parse_error:{e}')
" 2>/dev/null
}
