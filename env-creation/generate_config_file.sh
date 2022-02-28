#!/bin/bash

GIT_USER=""
GIT_EMAIL=""

get_or_prompt_for_git_creds() {
  # file search
  if [[ -f ~/.gitconfig ]] ; then
    name=($(grep "name" ~/.gitconfig))
    email=($(grep "email" ~/.gitconfig))
    GIT_USER="${name[2]}"
    GIT_EMAIL="${email[2]}"
  else
    echo
    echo "Would you like to enter your git 'user_name' and 'email'"
    echo "for connecting your repos to configured directories?"
    echo -n "'y' or 'n': "
    read -r GIT_BOOL

    while "true"
    do
      if [[ "${GIT_BOOL,,}" == "y" ]] || [[ "${GIT_BOOL,,}" == "n" ]] ; then
        break
      else
        echo "Invalid input! Input must be 'y' or 'n'"
        echo
        echo "Would you like to enter your git 'user_name' and 'email'"
        echo "for connecting your repos to configured directories?"
        echo -n "'y' or 'n': "
        read -r GIT_BOOL
      fi
    done

    if [[ "${GIT_BOOL,,}" == "y" ]] ; then
      echo
      echo -n "Github user name: "
      read -r USER_NAME
      echo -n "Github email: "
      read -r EMAIL 
      echo
      GIT_USER="${USER_NAME}"
      GIT_EMAIL="${EMAIL}"
    fi
  fi
}

# arg1=ROOT_ENV_DIR_NAME 
generate_config_file() {
  # change to ".engenrc_${1}" omit the ".sh"
  CONFIG_FILE_NAME="ROOT_ENV_CONFIG_${1}.sh"

  # copy the template, and add the name of the new dir tree to it
  # paths here needs to also be relative to main.sh execution script
  # copy ""./config-file-templates/.engenrc_template"
  cp ./config-file-templates/ROOT_ENV_CONFIG_template.sh "./config-file-templates/${CONFIG_FILE_NAME}"

  ROOT_ENV_DIR_PATH="${HOME}/${1}"

  # check for git creds in ~/.gitconfig or prompt for git creds here
  get_or_prompt_for_git_creds
  # make sure to use different delimeter when "/"s are included in replace text or escape the "/"
  # git creds
  sed -i s/CURRENT_GIT_USER_NAME=/CURRENT_GIT_USER_NAME="${GIT_USER}"/ ./config-file-templates/"${CONFIG_FILE_NAME}"
  sed -i s/CURRENT_GIT_EMAIL=/CURRENT_GIT_EMAIL="${GIT_EMAIL}"/ ./config-file-templates/"${CONFIG_FILE_NAME}"
  # path info
  sed -i s+CURRENT_BASE_DIR_PATH=+CURRENT_BASE_DIR_PATH="${ROOT_ENV_DIR_PATH}"+ ./config-file-templates/"${CONFIG_FILE_NAME}"
  sed -i s/CURRENT_BASE_DIR_NAME=/CURRENT_BASE_DIR_NAME="${1}"/ ./config-file-templates/"${CONFIG_FILE_NAME}"

  # move generated config to home dir
  # file search
  if [[ -f "${HOME}/${CONFIG_FILE_NAME}" ]] ; then
    echo "${CONFIG_FILE_NAME} already exists in home directory"
  else
    mv "./config-file-templates/${CONFIG_FILE_NAME}" ~/
    echo "${CONFIG_FILE_NAME} created in home directory: ${HOME}"
  fi
  
  # take existing template copy, and rename it, and add new values inside(base dir name)
  # Basic syntax:
  # https://linuxhint.com/replace_string_in_file_bash/
}
