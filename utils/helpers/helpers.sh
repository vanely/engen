#!/bin/bash

# write file/ directory search helper
#arg1=location
#arg2=search_token
#arg3=f(file) or d(directory)"
search_file_system() {
  local location="${1}"
  local search_token="${2}"
  local type="${3}"

  local search=$(find ${location} -maxdepth 2 -type ${type} | grep ${search_token})
  if [[ -n "${search}" ]] ; then
    echo "true"
  else
    echo "false"
  fi
}