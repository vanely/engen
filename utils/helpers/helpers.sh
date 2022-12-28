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
#arg3=f(file) || d(directory)"
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

#arg1=execution_context(main || engen)
find_path_to_engen() {
  local execution_context="${1}"
  local ref_to_pwd=$(pwd)
  local final_path="/"
  echo "pwd: [ ${ref_to_pwd} ]"
  IFS="/" read -r -a path_to_engen <<< ${ref_to_pwd}
  echo "path dirs array: [ ${path_to_engen[@]} ]"

  for dir in ${path_to_engen[@]}
  do
    if [[ "${dir}" == "engen" ]] ; then
      final_path+="${dir}/"
      break
    fi
    final_path+="${dir}/"
  done
  echo "final path: [ ${final_path} ]"
}

# will to convert find to array to get first output
# file_search_arr=$(print_file_system_search "${HOME}" "engen" "d")
# file_search_arr=$(print_file_system_search "${HOME}" ".profile" "f")
# echo ${file_search_arr}
