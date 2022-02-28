#!/bin/bash

# spellcheck source=./utils/helpers/validation.sh
source "${HOME}/engen/utils/helpers/validation.sh"

# convert grep search output with ROOT_ENV_DIR prefix to array
arr=()
# file search
if [[ -f ~/.profile ]] ; then
  arr=($(grep "ROOT_ENV_DIR" ~/.profile))
fi
# remove entries in array that are just "export"
no_exports_arr=( "${arr[@]/export/}" )
# flatten empty spaces out of array
ENV_DIR_ARRAY=(${no_exports_arr[@]})
# get array length
ENV_DIR_ARRAY_LEN="${#ENV_DIR_ARRAY[@]}"
# array of just ENV_DIR_NAMES
ENV_DIR_NAMES=()
ENV_DIR_PATHS=()

for ENV_VAR in ${ENV_DIR_ARRAY[@]}
do
  IFS="=" read -r -a touple <<< ${ENV_VAR}
  ENV_DIR_NAMES+=("${touple[0]}")
  ENV_DIR_PATHS+=("${touple[1]}")
done

# echo "${ENV_DIR_NAMES[@]}"
iteratively_remove_env_dirs() {
  echo "From the following list, select which env dir you'd like to remove"
  echo "as numbers separated by spaces. EX:"
  echo "0 1 2"
  echo
  # iteratively generate list of programs to install.
  for (( i=0; i<"${ENV_DIR_ARRAY_LEN}"; i++ ))
  do
    echo "${i}: ${ENV_DIR_NAMES[i]}"
  done
  echo
  echo -n "> "
  read -r indexes

  while "true"
  do
    if [[ "$(input_is_number_with_possible_spaces "${indexes}")" == "true" ]] ; then
      for i in ${indexes[@]}
      do
        # IS_ENV_VAR_IN_PROFILE="$(grep -wnq ${!ENV_DIR_NAMES[i]} ~/.profile)"
        # w: strict word search, n: output with line number
        ENV_VAR_IN_PROFILE="$(grep -wn ${ENV_DIR_NAMES[i]} ~/.profile)"
        # split by colon to get line number
        IFS=":" read -r -a arr <<< ${ENV_VAR_IN_PROFILE}

        # derive possible config file name
        IFS="/" read -ra dirs_in_path <<< ${ENV_DIR_PATHS[i]}
        local ROOT_ENV_DIR_PATH_NAME="${dirs_in_path[@]: -1:1}"
        # build_config_file
        local CONFIG_FILE="${HOME}/ROOT_ENV_CONFIG_${ROOT_ENV_DIR_PATH_NAME}.sh"

        # evaluates the string stored in the variable to its variable definition
        # file search
        if [[ -d "${ENV_DIR_PATHS[i]}" ]] ; then
          echo
          echo "========================================================================================="
          echo "Removing: ${ENV_DIR_PATHS[i]}..."
          # remove directory
          rm -rf "${ENV_DIR_PATHS[i]}"
          echo "Removing ${CONFIG_FILE}..."
          # remove config file. May not want to remove config file. User may want to keep this!
          if [[ -f "${CONFIG_FILE}" ]] ; then 
            rm "${CONFIG_FILE}"
            echo "Removing exported variable..."
          fi
          # remove env var by line number
          if [[ -n ${ENV_VAR_IN_PROFILE} ]] ; then
            sed -i "${arr[0]}d" ~/.profile
          fi 
          echo "========================================================================================="
        elif [[ ! -d "${ENV_DIR_PATHS[i]}" ]] && [[ -n ${ENV_VAR_IN_PROFILE} ]] ; then
          echo
          echo "========================================================================================="
          echo "Removing exported variable for ${ENV_DIR_PATHS[i]}..."
          # remove env var by line number
          sed -i "${arr[0]}d" ~/.profile
          echo "========================================================================================="
        fi
      done
      break
    else
      echo
      echo "Input must be a number in the above list, or 'all'"
      echo
      echo -n "> "
      read -r indexes
    fi
  done
}
