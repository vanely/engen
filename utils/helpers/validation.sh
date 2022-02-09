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

# check if .profile is already being sourced inside of .bashrc, and .zshrc
profile_not_sourced() {

  BASHRC_SOURCE=$(grep "source ${HOME}/.profile" ~/.bashrc || grep "source ${HOME}//.profile" ~/.bashrc || grep 'source ~/.profile' ~/.bashrc)
  ZSHRC_SOURCE=$(grep "source ${HOME}/.profile" ~/.zshrc || grep "source ${HOME}//.profile" ~/.zshrc || grep 'source ~/.profile' ~/.zshrc)


  if [[ -z "${BASHRC_SOURCE}" ]] ; then
    # not sourced in .bashrc
    echo "!b"
  elif [[ -z "${ZSHRC_SOURCE}" ]] ; then
    # not sourced in .zshrc
    echo "!z"
  elif [[ -z "${BASHRC_SOURCE}" ]] && [[ -z "${ZSHRC_SOURCE}" ]] ; then
    # not sourced in either config files
    echo "!b!z"
  else
    # sourced in both
    echo "sourced"
  fi
}

# checks if config file exists for an existing directory tree
# arg1=ROOT_ENV_CONFIG
config_file_exists() {
  if [[ -f "${1}" ]] ; then
    echo "true"
  else
    echo "false"
  fi
}

# arg1=input that should be 'y' or 'n'
input_is_y_or_n() {
  # (,,)=toLowerCase (^^)=toUpperCase
  if [[ "${1,,}" == "y" ]] || [[ "${1,,}" == "n" ]] ; then
    echo "true"
  else
    echo "false"
  fi
}

# write validator for acceptable variable name for base dir name(BASE)
# https://bash.cyberciti.biz/guide/Rules_for_Naming_variable_name