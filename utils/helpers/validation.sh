#!/bin/bash

# arg1=input to be validated as integer
input_is_number() {
  re='^[0-9]+$'
  if [[ ${1} =~ $re ]] ; then
    echo "true"
  else
    echo "false"
  fi
}

# arg1=input to be validated as integer || space separated integers
input_is_number_with_possible_spaces() {
  re='^[0-9 ]+$'
  if [[ ${1} =~ $re ]] ; then
    echo "true"
  else
    echo "false"
  fi
}

# arg1=input to be validated as the word 'all'
input_is_the_word_all() {
  re='(all)'
  if [[ ${1} =~ $re ]] ; then
    echo "true"
  else
    echo "false"
  fi
}

# write validator for acceptable variable name for base dir name(BASE)
