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

appending_to_file_test