#!/bin/bash

########################################################################################################
############################################# DEPENDENCIES #############################################
########################################################################################################

# make installs os specific for the installations that need it(gh, look into:[make, gcc])

# check that scoop package manager is installed for windows
check_and_install_scoop() {
  source ~/.profile
  if [[ "${ROOT_ENV_OS}" == "Windows" ]] ; then
    if [[ -n "$(which scoop)" ]] ; then
      echo "Scoop has already been installed"
      echo "_________________________________________________________________________________________"
      echo
    else
      echo "////////////////////// PREPARING TO INSTALL SCOOP PACKAGE MANAGER //////////////////////"
      echo "Installing Scoop package manager"
      echo "_________________________________________________________________________________________"
      echo
      powershell -f ./scoop_install.ps1 2> /dev/null
    fi
  fi
}

# check that chocolatey package manager is installed for windows
check_and_install_chocolatey() {
  source ~/.profile
  if [[ "${ROOT_ENV_OS}" == "Windows" ]] ; then
    if [[ -n "$(which choco)" ]] ; then
      echo "Chocolatey has already been installed"
      echo "_________________________________________________________________________________________"
      echo
    else
      echo "////////////////////// PREPARING TO INSTALL CHOCOLATEY PACKAGE MANAGER //////////////////////"
      echo "Installing Chocolatey package manager"
      echo "_________________________________________________________________________________________"
      echo
      powershell -f ./chocolatey_install.ps1 2> /dev/null
    fi
  fi
}

# snapd(Linux specific)
check_and_install_snapd_package_manager() {
  if [[ -n "$(which snap)" ]] ; then
    echo "Snap has already been installed"
    echo "_________________________________________________________________________________________"
    echo
   else
    echo "////////////////////// PREPARING TO INSTALL SNAP PACKAGE MANAGER //////////////////////"
    echo "Installing Snap package manager"
    echo "_________________________________________________________________________________________"
    echo
    sudo apt-get -y install snapd
  fi
}

# check that home brew is installed(Mac OS specific)
check_and_install_homebrew() {
  source ~/.profile
  if [[ "${ROOT_ENV_OS}" == "Darwin" ]] ; then
    if [[ -n "$(which brew)" ]] ; then
      echo "Homebrew has already been installed."
      echo "_________________________________________________________________________________________"
      echo
    else
      echo "////////////////////// PREPARING TO INSTALL HOMEBREW //////////////////////"
      echo "Installing homebrew"
      echo "_________________________________________________________________________________________"
      echo
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
  else
    echo "Operating system is not Mac OS"
  fi
}

# check that git is installed, and version
check_and_install_git() {
  GIT_VERSION_ARRAY=($(git --version))
  source ~/.profile
  if [[ "${ROOT_ENV_OS}" == "Darwin" ]] ; then
    check_and_install_homebrew
    if [[ -n "$(which git)" ]] ; then
      echo "Git has already been installed."
      echo "Current version: ${GIT_VERSION_ARRAY[2]}"
      echo "_________________________________________________________________________________________"
      echo
    else
      echo "////////////////////// PREPARING TO INSTALL GIT //////////////////////"
      echo "Installing git"
      echo "_________________________________________________________________________________________"
      echo
      brew install git
    fi
  elif [[ "${ROOT_ENV_OS}" == "Linux" ]] ; then
    if [[ -n "$(which git)" ]] ; then
      echo "Git has already been installed."
      echo "Current version: ${GIT_VERSION_ARRAY[2]}"
      echo "_________________________________________________________________________________________"
      echo
    else
      echo "////////////////////// PREPARING TO INSTALL GIT //////////////////////"
      echo "Installing git"
      echo "_________________________________________________________________________________________"
      echo
      sudo apt-get -y install git
    fi
  else
    echo "On windows it's assumed that git is installed, since these scripts have to be run in Git Bash"
  fi

}

# make - does not need to be added to install list
check_and_install_make() {
  if [[ -n "$(which make)" ]] ; then
    echo "Make has already been installed"
    echo "_________________________________________________________________________________________"
    echo
   else
    echo "////////////////////// PREPARING TO INSTALL MAKE //////////////////////"
    echo "Installing make"
    echo "_________________________________________________________________________________________"
    echo
    sudo apt-get -y install make
  fi
}

#gcc - does not need to be added to install list
check_and_install_gcc() {
  if [[ -n "$(which gcc)" ]] ; then
    echo "Gcc has already been installed"
    echo "_________________________________________________________________________________________"
    echo
   else
    echo "////////////////////// PREPARING TO INSTALL GCC //////////////////////"
    echo "Installing gcc"
    echo "_________________________________________________________________________________________"
    echo
    sudo apt-get -y install gcc
  fi
}

# curl
check_and_install_curl() {
  if [[ -n "$(which curl)" ]] ; then
    echo "Curl has already been installed"
    echo "_________________________________________________________________________________________"
    echo
   else
    echo "////////////////////// PREPARING TO INSTALL CURL //////////////////////"
    echo "Installing curl"
    echo "_________________________________________________________________________________________"
    echo
    sudo apt-get -y install curl
  fi
}

# gh Github CLI(can create PRs, Repos, and other git flows without accessing website)
# VERIFIED
check_and_install_gh() {
  source ~/.profile
  if [[ "${ROOT_ENV_OS}" == "Darwin" ]] ; then
    if [[ -n $(gh --version) ]] ; then
      echo "gh(github CLI) has already been installed."
      echo "_________________________________________________________________________________________"
      echo
    else
      echo "////////////////////// PREPARING TO INSTALL GH(GITHUB CLI) //////////////////////"
      echo "Installing gh(github CLI):"
      echo "_________________________________________________________________________________________"
      echo
      brew install gh
    fi    
  elif [[ "${ROOT_ENV_OS}" == "Linux" ]] ; then    
    check_and_install_curl
    if [[ -n $(gh --version) ]] ; then
      echo "gh(github CLI) has already been installed."
      echo "_________________________________________________________________________________________"
      echo
    else
      echo "////////////////////// PREPARING TO INSTALL GH(GITHUB CLI) //////////////////////"
      echo "Installing gh(github CLI):"
      echo "_________________________________________________________________________________________"
      echo
      curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg ;
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null ;
      sudo apt update ;
      sudo apt install dirmngr ;
      sudo apt install gh ;
    fi
  elif [[ "${ROOT_ENV_OS}" == "Windows" ]] ; then
    check_and_install_chocolatey
    # execute powershell script here\
    powershell -f ./gh_install.ps1 2> /dev/null
  else
    echo "Unrecognized OS!"
    exit
  fi
}
