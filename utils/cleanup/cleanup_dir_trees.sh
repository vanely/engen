#!/bin/bash

# spellcheck source=./utils/helpers/validation.sh
source ./utils/helpers/validation.sh

# export ROOT dir name to .bashrc so it canbe referenced and deleted
# uninstall one or more installed programs
#   - present list of those that are installed by using same pre-install checks
#   - iteratively show list. 
# remove ShellScripts dir that was used to generate the dir tree at the end
# along with anything else that needs cleaning up.

# will be able to generate multiple Envs, grep .profile for ROOT_ENV_DIR exports and iterate through them
# generate a list that will allow for automated deletion
# ENV_GENERATOR_DIR="${HOME}/SomeDir"

# if [ -d "$ENV_GENERATOR_DIR" ] ; then
#   rm -rf "$ENV_GENERATOR_DIR"
# fi

# IFS=" " read -r -a array <<< $(grep ROOT_ENV_DIR* ~/.profile)

# convert grep search output with ROOT_ENV_DIR prefix to array
arr=()
if [[ -f ~/.profile ]] ; then
  arr=($(grep "ROOT_ENV_DIR" ~/.profile))
fi
# remove entries in array that are just "export"
no_exports_arr=( "${arr[@]/export/}" )
# EX: ROOT_ENV_DIR_NAME=/c/Users/<user>/<ROOT_ENV_DIR> - Windows
# EX: ROOT_ENV_DIR_NAME=/home/<user>/<ROOT_ENV_DIR> - Linux
# EX: ROOT_ENV_DIR_NAME=/Users/<user>/<ROOT_ENV_DIR> - Darwin
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

# sed: stream editor(used to delete lines in files)
check_and_install_sed() {
  echo "////////////////////// PREPARING TO INSTALL SED(STREAM EDITOR) //////////////////////"
  if [[ -n "$(which sed)" ]] ; then
    echo "Sed has already been installed"
    echo "_________________________________________________________________________"
   else
    echo "Installing sed(stream editor)"
    echo "_________________________________________________________________________"
    echo
    sudo apt-get -y install sed
  fi
}

remove_all_dirs() {
  # check_and_install_sed
  for (( i=0; i<"${ENV_DIR_ARRAY_LEN}"; i++ ))
  do
      # IS_ENV_VAR_IN_PROFILE="$(grep -wnq ${ENV_DIR_NAMES[i]} ~/.profile)"
      # w: strict word search, n: output with line number
      ENV_VAR_IN_PROFILE="$(grep -wn ${ENV_DIR_NAMES[i]} ~/.profile)"
      # split by colon to get line number
      IFS=":" read -r -a arr <<< ${ENV_VAR_IN_PROFILE}

    # evaluates the string stored in the variable to its variable definition
    if [[ -d "${ENV_DIR_PATHS[i]}" ]] && [[ -n ${ENV_VAR_IN_PROFILE} ]] ; then
      # remove directory
      rm -rf "${ENV_DIR_PATHS[i]}"
      # remove env var by line number
      sed -i "${arr[0]}d" ~/.profile
    elif [[ ! -d "${ENV_DIR_PATHS[i]}" ]] && [[ -n ${ENV_VAR_IN_PROFILE} ]] ; then
      # remove env var by line number
      sed -i "${arr[0]}d" ~/.profile
    fi
  done
}

iteratively_remove_env_dirs() {
  echo "////////////////////// ENV DIRECTORIES THAT CAN BE REMOVED //////////////////////"
  echo
  echo "From the following list, select which env dir you'd like to remove"
  echo "as 'all', or numbers separated by spaces. EX:"
  echo "0 1 2"
  echo
  echo "all: removes all dirs"
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
    if [[ "$(input_is_number_with_possible_spaces "${indexes}")" == "true" ]] || [[ "$(input_is_the_word_all "${indexes}")" == "true" ]]; then
      if [[ ${indexes} == 'all' ]] ; then
        remove_all_dirs
      else
        # check_and_install_sed
        for i in ${indexes[@]}
        do
          # IS_ENV_VAR_IN_PROFILE="$(grep -wnq ${!ENV_DIR_NAMES[i]} ~/.profile)"
          # w: strict word search, n: output with line number
          ENV_VAR_IN_PROFILE="$(grep -wn ${ENV_DIR_NAMES[i]} ~/.profile)"
          # split by colon to get line number
          IFS=":" read -r -a arr <<< ${ENV_VAR_IN_PROFILE}

          # evaluates the string stored in the variable to its variable definition
          if [[ -d "${ENV_DIR_PATHS[i]}" ]] && [[ -n ${ENV_VAR_IN_PROFILE} ]] ; then
            echo
            echo "==================================================="
            echo "Removing: ${ENV_DIR_PATHS[i]}..."
            # remove directory
            rm -rf "${ENV_DIR_PATHS[i]}"
            echo "Removing exported variable..."
            # remove env var by line number
            sed -i "${arr[0]}d" ~/.profile
            echo "==================================================="
          elif [[ ! -d "${ENV_DIR_PATHS[i]}" ]] && [[ -n ${ENV_VAR_IN_PROFILE} ]] ; then
            echo
            echo "==================================================="
            echo "Removing only exported variable for ${ENV_DIR_PATHS[i]}"
            # remove env var by line number
            sed -i "${arr[0]}d" ~/.profile
            echo "==================================================="
          fi
        done
      fi
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
