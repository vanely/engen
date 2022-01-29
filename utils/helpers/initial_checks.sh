#!/bin/bash

GIT_VERSION_ARRAY=($(git --version))

# check that git is installed, and version
check_and_install_git() {
  echo "////////////////////// PREPARING TO INSTALL GIT //////////////////////"
  if [[ -n "$(which git)" ]] ; then
    echo "Git has already been installed."
    echo "Current version: ${GIT_VERSION_ARRAY[2]}"
    echo "_________________________________________________________________________"
    echo
   else
    echo "Installing git"
    echo "_________________________________________________________________________"
    echo
    sudo apt-get -y install git
  fi
}


# gnome-keyring - git auth dependency
check_and_install_gnome_keyring() {
  echo "////////////////////// PREPARING TO INSTALL GNOME-KEYRIING //////////////////////"
  if [[ -n "$(which gnome-keyring)" ]] ; then
    echo "Gnome-keyring has already been installed"
    echo "_________________________________________________________________________"
    echo
   else
    echo "Installing gnome-keyring"
    echo "_________________________________________________________________________"
    echo
    sudo apt-get -y install gnome-keyring
  fi
}

# git credentials and authentication token setup
config_git_creds_and_auth() {
  check_and_install_git

  git config --global user.name "<user_name>"
  git config --global user.email "<email>"
  git config --global credential.helper store
  git config --global credential.helper cache

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
  #  Only an issue on Linux do OS check here
}

# check that bash version is over 4
check_and_update_bash() {
  # NOTE: on mac and linux make sure to navigate to /bin/bash, and /usr/local/bin/bash and check which version is highest, if there are 2
  os_specific_update() {
    if [[ "${ROOT_ENV_OS}" == "Linux" ]] ; then
      echo "////////////////////// PREPARING TO UPDATE BASH //////////////////////"
      echo "Updating bash for Linux"
      echo "_________________________________________________________________________"
      apt-get install --only-upgrade bash
    elif [[ "${ROOT_ENV_OS}" == "Darwin" ]] ; then
      echo "////////////////////// PREPARING TO UPDATE BASH //////////////////////"
      if [[ -n "$(which brew)" ]] ; then
        echo "Homebrew has already been installed."
        echo "_________________________________________________________________________"
        echo
      else
        echo "Installing Homebrew:"
        echo "_________________________________________________________________________"
        echo
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
      fi
      echo "Updating bash for MAC-OS"
      echo "_________________________________________________________________________"
      # Update bash and everything else
      brew upgrade 
    else
      echo "////////////////////// PREPARING TO UPDATE BASH //////////////////////"
      echo "Updating bash for Windows"
      echo "_________________________________________________________________________"
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
    echo "Bash version is 4^"
  fi
}

check_current_operating_system() {
  # maybe export globally, and when last env dir tree is being deleted remove its reference as well
  ROOT_ENV_OS="Windows"
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
    else
      touch ~/.bashrc
      touch ~/.profile
      echo export "ROOT_ENV_OS='${1}'" >> ~/.profile
      echo source ~/.profile >> ~/.bashrc
    fi
  }

  if [[ -f ~/.profile ]] && [[ -z "$(grep ROOT_ENV_OS ~/.profile)" ]] ; then
    if [[ "${CURRENT_OS}" == "Darwin" ]]; then
      # this is working on Darwin
      ROOT_ENV_OS="${CURRENT_OS}"
      export_ref_to_current_os "${ROOT_ENV_OS}"
      echo "Current ROOT_ENV_OS is Darwin: ${CURRENT_OS}"
    elif [[ "${CURRENT_OS}" == "Linux" ]]; then
      # still needs testing on linux machine
      ROOT_ENV_OS="${CURRENT_OS}"
      export_ref_to_current_os "${ROOT_ENV_OS}"
      echo "Current ROOT_ENV_OS is Linux: ${CURRENT_OS}"
    else
      export_ref_to_current_os "${ROOT_ENV_OS}"
      echo "Defaulting to ${ROOT_ENV_OS}"
      echo "These scripts must be run in Git Bash"
    fi
  else
    if [[ "${ROOT_ENV_OS}" == "Windows" ]] ; then
      echo "These scripts must be run in Git Bash"
    fi
  fi
  # echo "Found ROOT_ENV_OS: ${ROOT_ENV_OS}"
}

######################################## WINDOWS CHECKS ########################################

check_and_install_scoop_package_manager() {
  echo
}

# check_and_update_bash
# check_current_operating_system
