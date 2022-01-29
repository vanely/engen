#!/bin/bash

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

# input_validation

repo_array() {
  REPO_LIST=$(gh repo list vanely --source)
  REPO_ARR=()
  # gh repo list vanely --source
  for REPO in ${REPO_LIST}
  do
    IFS="/" read -r -a REPO_TOUPLE <<< ${REPO}
    REPO_ARR+=(${REPO_TOUPLE[1]})
  done

  echo "${REPO_ARR[@]}"
}

repo_array