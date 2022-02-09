#!/bin/bash

# spellcheck source=./programs-to-install/dependencies/dependencies.sh
source "${HOME}/engen/programs-to-install/dependencies/dependencies.sh"

# # check that git is installed, and version
# check_and_install_git() {
#   echo "////////////////////// PREPARING TO INSTALL GIT //////////////////////"
#   if [[ -n "$(which git)" ]] ; then
#     echo "Git has already been installed."
#     echo "Current version: ${GIT_VERSION_ARRAY[2]}"
#     echo "_________________________________________________________________________"
#     echo
#    else
#     echo "Installing git"
#     echo "_________________________________________________________________________"
#     echo
#     sudo apt-get -y install git
#   fi
# }

# # check that gh github cli is installed
# check_and_install_gh() {

#   if [[ "${ROOT_ENV_OS}" == "" ]] ; then

#   check_and_install_curl
#   echo "////////////////////// PREPARING TO INSTALL GH(GITHUB CLI) //////////////////////"
#   if [[ -n $(gh --version) ]] ; then
#     echo "gh(github CLI) has already been installed."
#     echo "_________________________________________________________________________"
#     echo
#   else
#     echo "Installing gh(github CLI):"
#     echo "_________________________________________________________________________"
#     echo
#     curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg ;
#     echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null ;
#     sudo apt update ;
#     sudo apt install dirmngr ;
#     sudo apt install gh ;
#   fi
# }

dependency_checks() {
  check_and_install_gh
  # echo
}

# gnome-keyring - git auth dependency
check_and_install_gnome_keyring() {
  # echo "////////////////////// PREPARING TO INSTALL GNOME-KEYRIING //////////////////////"
  if [[ -n "$(which gnome-keyring)" ]] ; then
    echo "Gnome-keyring has already been installed"
    echo "_________________________________________________________________________________________"
    echo
   else
    echo "Installing gnome-keyring"
    echo "_________________________________________________________________________________________"
    echo
    sudo apt-get -y install gnome-keyring
  fi
}

# git credentials and authentication token setup
config_git_creds_and_auth() {
  CURRENT_WORKING_TREE=$(pwd)
  IFS="/" read -r -a DIR_LIST <<< ${CURRENT_WORKING_TREE}
  CURRENT_ROOT_ENV_CONFIG=""
  if [[ "${ROOT_ENV_OS}" == "Windows" ]] ; then 
    CURRENT_ROOT_ENV_CONFIG="${HOME}/ROOT_ENV_CONFIG_${DIR_LIST[4]}"
  else
    CURRENT_ROOT_ENV_CONFIG="${HOME}/ROOT_ENV_CONFIG_${DIR_LIST[3]}"
  fi

  check_and_install_git

  GIT_USER=""
  GIT_EMAIL=""

  prompt_for_git_creds() {
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
  }

  # check if ~/.gitconfig exists but name and email aren't inside, or
  # check if ~/.gitconfig doesn't exist
  if [[ -f "${HOME}/.gitconfig" ]] && [[ -z $(grep "name = " ${HOME}/.gitconfig) ]] && [[ -z $(grep "email = " ${HOME}/.gitconfig) ]] || [[ ! -f "${HOME}/.gitconfig" ]]  ; then

    if [[ -f "${CURRENT_ROOT_ENV_CONFIG}.sh" ]] ; then
      echo "Attempting to extract git credentials from ROOT_ENV_CONFIG"
      echo
      source "${CURRENT_ROOT_ENV_CONFIG}.sh"

      if [[ -n "${CURRENT_GIT_USER_NAME}" ]] && [[ "${CURRENT_GIT_EMAIL}" ]] ; then
        GIT_USER="${CURRENT_GIT_USER_NAME}"
        GIT_EMAIL="${CURRENT_GIT_EMAIL}"
      else
        echo
        # prompt user for git user_name and email
        prompt_for_git_creds
      fi

      git config --global user.name "${GIT_USER}"
      git config --global user.email "${GIT_EMAIL}"
      git config --global credential.helper store
    else
      echo
      # prompt user for git user_name and email
      prompt_for_git_creds
    fi
    
    git config --global user.name "${GIT_USER}"
    git config --global user.email "${GIT_EMAIL}"
    git config --global credential.helper store
  fi
  # git config --global credential.helper cache

  #  Only an issue on Linux do OS check here
  if [[ "${ROOT_ENV_OS}" == "Linux" ]] ; then
    check_and_install_gnome_keyring
    if [[ ! -f ~/.xinitrc ]] ; then
      touch ~/.xinitrc
      
      echo "# see https://unix.stackexchange.com/a/295652/332452" >> ~/.xinitrc
      echo source /etc/X11/xinit/xinitrc.d/50-systemd-user.sh >> ~/.xinitrc

      echo "# see https://wiki.archlinux.org/title/GNOME/Keyring#xinitrc" >> ~/.xinitrc
      echo eval "$(/usr/bin/gnome-keyring-daemon --start)" >> ~/.xinitrc
      echo export SSH_AUTH_SOCK >> ~/.xinitrc

      echo "# see https://github.com/NixOS/nixpkgs/issues/14966#issuecomment-520083836" >> ~/.xinitrc
      echo mkdir -p "$HOME"/.local/share/keyrings >> ~/.xinitrc
      # add to the above file: https://code.visualstudio.com/docs/editor/settings-sync#_troubleshooting-keychain-issues
    fi
  fi
  # echo
}

# check that bash version is over 4
check_and_update_bash() {
  # NOTE: on mac and linux make sure to navigate to /bin/bash, and /usr/local/bin/bash and check which version is highest, if there are 2
  os_specific_update() {
    if [[ "${ROOT_ENV_OS}" == "Linux" ]] ; then
      echo "/////////////////////////////// PREPARING TO UPDATE BASH ////////////////////////////////"
      echo "Updating bash for Linux"
      echo "_________________________________________________________________________________________"
      apt-get install --only-upgrade bash
    elif [[ "${ROOT_ENV_OS}" == "Darwin" ]] ; then
      echo "/////////////////////////////// PREPARING TO UPDATE BASH ////////////////////////////////"
      if [[ -n "$(which brew)" ]] ; then
        echo "Homebrew has already been installed."
      echo "_________________________________________________________________________________________"
        echo
      else
        echo "Installing Homebrew:"
      echo "_________________________________________________________________________________________"
        echo
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
      fi
      echo "Updating bash for MAC-OS"
      echo "_________________________________________________________________________________________"
      # Update bash and everything else
      brew upgrade 
    else
      echo "/////////////////////////////// PREPARING TO UPDATE BASH ////////////////////////////////"
      echo "Updating bash for Windows"
      echo "_________________________________________________________________________________________"
      git update-git-for-windows
    fi
  }

  # check os and update relative to os
  CURRENT_BASH_VERSION_ARRAY=($(bash --version))
  IFS='.' read -ra CURRENT_BASH_VERSION_NUM_ARRAY <<< ${CURRENT_BASH_VERSION_ARRAY[3]}
  
  if [[ "${CURRENT_BASH_VERSION_NUM_ARRAY[0]}" -lt '4' ]] ; then 
    echo "Bash is not at version 4^"
    os_specific_update
  else
    # echo "Bash version is 4^"
    no_op(){
      echo
    }
  fi
  echo
}

check_current_operating_system() {
  # maybe export globally, and when last env dir tree is being deleted remove its reference as well
  local ROOT_ENV_OS="Windows"
  CURRENT_OS="$(uname -s)"
  # check whether running Linux or Darwin

  # arg1=CURREN_OS
  export_ref_to_current_os() {
    if [[ -f ~/.bashrc ]] && [[ -f ~/.profile ]] ; then
      echo export "ROOT_ENV_OS='${1}'" >> ~/.profile
    elif [[ -f ~/.bashrc ]] && [[ ! -f ~/.profile ]]; then
      touch ~/.profile
      echo export "ROOT_ENV_OS='${1}'" >> ~/.profile
      echo source ~/.profile >> ~/.bashrc
    elif [[ ! -f ~/.bashrc ]] && [[ ! -f ~/.profile ]]; then
      touch ~/.bashrc
      touch ~/.profile
      echo export "ROOT_ENV_OS='${1}'" >> ~/.profile
      echo source ~/.profile >> ~/.bashrc
    fi
  }

  if [[ -f ~/.profile ]] && [[ -z "$(grep ROOT_ENV_OS ~/.profile)" ]] ; then
    if [[ "${CURRENT_OS}" == "Darwin" ]] ; then
      # this is working on Darwin
      ROOT_ENV_OS="${CURRENT_OS}"
      export_ref_to_current_os "${ROOT_ENV_OS}"
      echo "Current ROOT_ENV_OS is Darwin: ${CURRENT_OS}"
    elif [[ "${CURRENT_OS}" == "Linux" ]] ; then
      # still needs testing on linux machine
      ROOT_ENV_OS="${CURRENT_OS}"
      export_ref_to_current_os "${ROOT_ENV_OS}"
      echo "Current ROOT_ENV_OS is Linux: ${CURRENT_OS}"
    elif [[ "${CURRENT_OS}" == "Windows" ]] ; then
      export_ref_to_current_os "${ROOT_ENV_OS}"
      echo "Defaulting to ${ROOT_ENV_OS}"
      echo "These scripts must be run in Git Bash"
    fi
  else
    if [[ "${CURRENT_OS}" == "Windows" ]] ; then
      echo "These scripts must be run in Git Bash"
    fi
  fi
  echo
}
