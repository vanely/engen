#!/bin/bash


#arg1=location
#arg2=search_token
#arg3=f(file) or d(directory)"
print_file_system_search() {
  local location="${1}"
  local search_token="${2}"
  local type="${3}"

  local search=$(find ${location} -maxdepth 2 -type ${type} | grep ${search_token})
  echo "${search}"
}

#arg1=location
#arg2=search_token
#arg3=f(file) or d(directory)"
search_file_system() {
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
