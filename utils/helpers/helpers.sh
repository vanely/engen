#!/bin/bash
# ================================================================
# engen — File System Helpers
# ================================================================

# Search for a file or directory by name pattern
# arg1=location  arg2=search_token  arg3=f(file) or d(directory)
print_file_system_search() {
  local location="${1}"
  local search_token="${2}"
  local type="${3}"
  find "${location}" -maxdepth 2 -type "${type}" -name "*${search_token}*" 2>/dev/null | head -1
}

# Check if a file or directory exists by search
file_or_directory_exists() {
  local result
  result=$(print_file_system_search "${1}" "${2}" "${3}")
  [[ -n "${result}" ]] && echo "true" || echo "false"
}
