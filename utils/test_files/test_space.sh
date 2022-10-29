#!/bin/bash

#arg1=location
#arg2=search_token
#arg3=f(file) or d(directory)"
print_file_system_search() {
  local location="${1}"
  local search_token="${2}"
  local type="${3}"

  # doing strict search with "-w" passed into grep command
  local search=($(find "${location}" -maxdepth 2 -type "${type}" | grep -w "${search_token}"))
  echo "${search}"
}

source "$(print_file_system_search "${HOME}" "engen" "d")"/utils/helpers/helpers.sh

# source "../helpers/helpers.sh"
VERSION="$(git --version)"

array_test() {
  read -ra VERSION_ARRAY -d '' <<< "${VERSION}"

  if [[ -n $VERSION ]]; then
    echo "Already installed"
    echo "${VERSION} Array: [${VERSION_ARRAY[0]}, ${VERSION_ARRAY[1]}, ${VERSION_ARRAY[2]}]"
  else 
    echo "Not yet installed"
    echo "${VERSION}"
  fi

  # how I'll likely implement the functions_array
  # this works well for my use case!
  arr=(
    'one'
    'two'
    'three'
    'four'
    'five'
  )

  echo "Select which programs you'd like installed as a list of space separated numbers. EX:"
  echo "0 2 4"
  echo -n ">"
  read -r indexes

  for i in ${indexes[@]}
  do
    echo "${arr[i]}"
  done

  # echo "arr el 1: ${arr[1]}"
}

appending_to_file_test() {
  THING='slight modification'
  echo export THING="${HOME} previous text before:$THING" >> ./file_to_append_to.txt
}

# appending_to_file_test

#returning from function
# arg1=input
input_validation() {
  v1='kjdshf'
  v2='342'
  v3='djkh434'
  v4='0 1 2 6 4'
  v5='4 s 6 a'
  v6='all'

  # validation functions
  input_is_number() {
    re='^[0-9]+$'
    if [[ ${1} =~ $re ]] ; then
      echo "true"
    else
      echo "false"
    fi
  }

  input_is_number_with_space() {
    re='^[0-9 ]+$'
    if [[ ${1} =~ $re ]] ; then
      echo "true"
    else
      echo "false"
    fi
  }

  input_is_the_word_all() {
    re='(all)'
    if [[ ${1} =~ $re ]] ; then
      echo "true"
    else
      echo "false"
    fi
  }

  some_thing="$(input_is_the_word_all ${v6})"
  echo "the func op: ${some_thing}"
  echo

  if [[ $(input_is_the_word_all "${v6}") == "true" ]] ; then
    echo 'Awesome you gots a match'
  else
    echo 'Gross! What is that?!'
  fi
}

repo_array() {
  REPO_LIST=$(gh repo list "<user_name>" --source)
  REPO_ARR=()
  # gh repo list uesr_name --source
  for REPO in ${REPO_LIST}
  do
    IFS="/" read -r -a REPO_TOUPLE <<< ${REPO}
    REPO_ARR+=(${REPO_TOUPLE[1]})
  done

  echo "${REPO_ARR[@]}"
}

config_file_test() {
  # NOTE: whenever referencing config file, always check if it exists

  CURRENT_BASE_DIR_PATH=$(pwd)
  IFS='/' read -ra CURRENT_BASE_DIR_NAME <<< ${CURRENT_BASE_DIR_PATH}
  CONFIG_FILE_NAME="ROOT_ENV_CONFIG_${CURRENT_BASE_DIR_NAME[3]}"

  echo ${CONFIG_FILE_NAME}
  # copy the template, and add the name of the new dir tree to it
  cp ./ROOT_ENV_CONFIG_template.sh "./${CONFIG_FILE_NAME}.sh"

  # make all needed alterations to it
  sed -i "s/CURRENT_ROOT_ENV_OS/CURRENT_ROOT_ENV_OS=${ROOT_ENV_OS}/" filename
  sed -i "s/CURRENT_BASE_DIR/CURRENT_BASE_DIR=${ROOT_ENV_DIR}/" filename
  # will likely be a param passed to whatever function will be doing this
  sed -i "s/CURRENT_BASE_DIR_NAME/CURRENT_BASE_DIR_NAME=${BASE}/" filename

  # move it to home dir
  # mv "./${CONFIG_FILE_NAME}.sh" ~/
  
  # take existing template copy, and rename it, and add new values inside(base dir name)
  # Basic syntax:
  # https://linuxhint.com/replace_string_in_file_bash/
  echo ${arr[@]} >> "./${CONFIG_FILE_NAME}.sh"
}

# config_file_test

arr1=(
  "thing1"
  "thing2"
  "thing3"
)

arr2=(
  "cosa1"
  "cosa2"
  "cosa3"
)
consume_arrays() {
  local -n _arr1=$1
  local -n _arr2=$2
  printf '1: %q\n' "${_arr1[@]}"
  # echo "${_arr1[@]}"
  echo
  printf '2: %q\n' "${_arr2[@]}"
  # echo "${_arr2[@]}"
}


# consume_arrays ${arr1} ${arr2}

# demo_multiple_arrays() {
#   declare -i num_args array_num;
#   declare -a curr_args;
#   while (( $# )) ; do
#     curr_args=( )
#     num_args=$1; shift
#     while (( num_args-- > 0 )) ; do
#       curr_args+=( "$1" ); shift
#     done
#     printf "$((++array_num)): %q\n" "${curr_args[@]}"
#   done
# }

# array_one=( "one argument" "another argument" )
# array_two=( "array two part one" "array two part two" )

# demo_multiple_arrays \
#   "${#array_one[@]}" "${array_one[@]}" \
#   "${#array_two[@]}" "${array_two[@]}"

# demo_multiple_arrays() {
#   local -n _array_one=$1
#   local -n _array_two=$2
#   printf '1: %q\n' "${_array_one[@]}"
#   printf '2: %q\n' "${_array_two[@]}"
# }

# array_one=( "one argument" "another argument" )
# array_two=( "array two part one" "array two part two" )

# demo_multiple_arrays array_one array_two

# find_relative_file() {
# print_file_system_search "${HOME}" "engen" "d"
# }
# find_relative_file

# build_config_file "nUnU"