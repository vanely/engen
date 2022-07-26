#!/bin/bash

#arg1=location
#arg2=search_token
#arg3=f(file) or d(directory)"
print_file_system_search() {
  local location="${1}"
  local search_token="${2}"
  local type="${3}"

  # doing strict search with "-w" passed into grep command
  local search=($(find "${location}" -maxdepth 2 -type "${type}" | grep "${search_token}"))
  echo "${search}"
}

#arg1=location
#arg2=search_token
#arg3=f(file) or d(directory)"
file_or_directory_exists() {
  local search=$(print_file_system_search "${1}" "${2}" "${3}")
  if [[ -n "${search}" ]] ; then
    echo "true"
  else
    echo "false"
  fi
}

#arg1=root_dir_name
build_config_file() {
  local root_dir_name="${1}"
  echo ".engenrc_${root_dir_name}"
}

# will to convert find to array to get first output
# file_search_arr=$(print_file_system_search "${HOME}" "engen" "d")
# file_search_arr=$(print_file_system_search "${HOME}" ".profile" "f")
# echo ${file_search_arr}
