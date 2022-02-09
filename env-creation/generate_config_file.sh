#!/bin/bash

# arg1=ROOT_ENV_DIR_NAME 
generate_config_file() {
  CONFIG_FILE_NAME="ROOT_ENV_CONFIG_${1}.sh"

  # copy the template, and add the name of the new dir tree to it
  # paths here needs to also be relative to main.sh execution script
  cp ./config-file-templates/ROOT_ENV_CONFIG_template.sh "./config-file-templates/${CONFIG_FILE_NAME}"

  ROOT_ENV_DIR_PATH="${HOME}/${1}"
  # make sure to use different delimeter when "/"s are included in replace text or escape the "/"
  sed -i s+CURRENT_BASE_DIR_PATH=+CURRENT_BASE_DIR_PATH="${ROOT_ENV_DIR_PATH}"+ ./config-file-templates/"${CONFIG_FILE_NAME}"
  sed -i s/CURRENT_BASE_DIR_NAME=/CURRENT_BASE_DIR_NAME="${1}"/ ./config-file-templates/"${CONFIG_FILE_NAME}"

  # move generated config to home dir
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
