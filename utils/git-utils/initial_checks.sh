#!/bin/bash

GIT_VERSION="$(git --version)"
GIT_VERSION_ARRAY=("$GIT_VERSION")

# git credentials and authentication token setup
config_git_creds_and_auth() {
  git config --global user.name "<USER_NAME>"
  git config --global user.email "<EMAIL>"
  git config --global credential.helper cache

  touch ~/.xinitrc
  # add to the above file: https://code.visualstudio.com/docs/editor/settings-sync#_troubleshooting-keychain-issues
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

# check that git is installed, and version
check_git() {
  check_and_install_gnome_keyring
  if [[ -n "$(git --version)" ]] ; then
    echo "Great! Git is installed, Current version is: ${GIT_VERSION_ARRAY[2]}"
  else  
    echo "Installing git"
    echo "_________________________________________________________________________"
    echo
    sudo apt-get -y install git
  fi
}
