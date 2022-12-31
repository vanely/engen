#!/bin/bash

function get_engen_fs_location() {
  if [[ -z $(grep "ENGEN_FS_LOCATION" ~/.profile) ]] ; then
    # "dirname" returns the path up to but not including the final dir
    REMOVED_FINAL_DIR=$(dirname $(pwd))
    DOUBLY_REMOVED_FINAL_DIR=$(dirname ${REMOVED_FINAL_DIR})
    echo ${DOUBLY_REMOVED_FINAL_DIR}
  else
    # will be exported from ~/.profile
    echo ENGEN_FS_LOCATION
  fi
}

# spellcheck source=./programs-to-install/dependencies/dependencies.sh
source "$(get_engen_fs_location)/programs-to-install/dependencies/dependencies.sh"

########################################################################################################
############################################### PROGRAMS ###############################################
########################################################################################################

# grub-customizer
check_and_install_grub_customizer() {
  echo "///////////////////////// PREPARING TO INSTALL GRUB CUSTOMIZER //////////////////////////"
  if [[ -n "$(which grub-customizer)" ]] ; then
    echo "Grub-customizer has already been installed"
    echo "_________________________________________________________________________________________"
    echo
   else
    echo "Installing grub-customizer"
    echo "_________________________________________________________________________________________"
    echo
    sudo add-apt-repository ppa:danielrichter2007/grub-customizer
    sudo apt update
    sudo apt -y install grub-customizer
  fi
}

# htop
check_and_install_htop() {
  echo "/////////////////////////////// PREPARING TO INSTALL HTOP ///////////////////////////////"
  if [[ -n "$(which htop)" ]] ; then
    echo "Htop has already been installed"
    echo "_________________________________________________________________________________________"
    echo
   else
    echo "Installing htop"
    echo "_________________________________________________________________________________________"
    echo
    sudo apt-get -y install htop
  fi
}

# tree graphically displays a dir tree
check_and_install_tree() {
  echo "/////////////////////////////// PREPARING TO INSTALL TREE ///////////////////////////////"
  if [[ -n "$(which tree)" ]] ; then
    echo "Tree has already been installed"
    echo "_________________________________________________________________________________________"
    echo
   else
    echo "Installing tree"
    echo "_________________________________________________________________________________________"
    echo
    sudo apt-get -y install tree
  fi
}

# rust-lang
# VERIFIED
check_and_install_rust() {
  check_and_install_curl
  echo "/////////////////////////////// PREPARING TO INSTALL RUST ///////////////////////////////"
  if [[ -n $(rustc --version) ]] ; then
    echo "Rust lang has already been installed."
    echo "_________________________________________________________________________________________"
    echo
  else
    echo "Installing Rust lang:"
    echo "_________________________________________________________________________________________"
    echo
    # Update rust installation by running 'rustup update'
    # In the Rust development environment, all tools are installed to the ~/.cargo/bin directory, and this is where you will find the Rust toolchain, including rustc, cargo, and rustup.
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

    if [[ -n $(rustc --version) ]] ; then
      if [[ -f ~/.profile ]] && [[ -f ~/.zshrc ]] ; then
        echo export PATH="$HOME/.cargo/bin:$PATH" >> ~/.profile
        source ~/.zshrc
      elif [[ -f ~/.bashrc ]] && [[ ! -f ~/.zshrc ]] ; then
        echo export PATH="$HOME/.cargo/bin:$PATH" >> ~/.bashrc
        source ~/.bashrc
      else
        touch ~/.bashrc
        echo export PATH="$HOME/.cargo/bin:$PATH" >> ~/.bashrc
        source ~/.bashrc
      fi
    fi
    # To uninstall rust: 'rustup self uninstall'
  fi
}

# flutter and dart
# VERIFIED
check_and_install_flutter_and_dart() {
  check_and_install_snapd_package_manager	
  echo "///////////////////////// PREPARING TO INSTALL FLUTTER AND DART /////////////////////////"
  if [[ -n "$(which flutter)"  ]] ; then
    echo "Flutter and Dart have already been installed."
    echo "_________________________________________________________________________________________"
    echo
  else
   echo "Installing Flutter and Dart dependencies:"
    echo "_________________________________________________________________________________________"
    echo
    sudo apt-get -y install clang cmake ninja-build pkg-config libgtk-3-dev

    echo
    echo "Installing Flutter and Dart:"
    echo "_________________________________________________________________________________________"
    echo
    sudo snap install flutter --classic

    # enable desktop support
    echo "Enabling Flutter and Dart desktop support:"
    echo "_________________________________________________________________________________________"
    echo
    flutter config --enable-linux-desktop

  fi
}

# zsh
# nvm, node, npm
# VERIFIED
check_and_install_zsh() {
  check_and_install_curl
  echo "////////////////////////////// PREPARING TO INSTALL ZSHELL //////////////////////////////"
  if [[ -d ~/.oh-my-zsh ]] && [[ -f ~/.zshrc ]] ; then
    echo "Z-Shell has already been installed."
    echo "_________________________________________________________________________________________"
    echo
  else
    echo "Installing Z-Shell:"
    echo "_________________________________________________________________________________________"
    echo
    # this will install nvm with node and npm lts
    curl -sSL https://github.com/zthxxx/jovial/raw/master/installer.sh | sudo -E bash -s $USER ;
    if [[ -f ~/.zshrc ]] && [[ -f ~/.profile ]] ; then
      echo "############### Aliases ###############" >> ~/.profile
      echo "alias ll='ls -lahF'" >> ~/.profile
      echo source ~/.profile >> ~/.zshrc
      source ~/.zshrc
    elif [[ -f ~/.zshrc ]] && [[ ! -f ~/.profile ]] ; then
      touch ~/.profile
      echo "############### Aliases ###############" >> ~/.profile
      echo "alias ll='ls -lahF'" >> ~/.profile
      echo source ~/.profile >> ~/.zshrc
      source ~/.zshrc
    fi
  fi
}

# theme.sh - interactively set themes in terminal. NOTE: needs "fzf" program
check_and_install_theme.sh() {
  install_theme.sh() {
    echo "Installing Theme.sh:"
    echo "_________________________________________________________________________________________"
    echo
    wget https://raw.githubusercontent.com/lemnos/theme.sh/master/bin/theme.sh -O /tmp/theme.sh
  }

  echo "///////////////////////////// PREPARING TO INSTALL THEME.SH /////////////////////////////"
  if [[ -n "$(theme.sh --version)" ]] && [[ -n "$(fzf --version)" ]] ; then
    echo "Theme.sh has already been installed."
    echo "_________________________________________________________________________________________"
    echo
  elif [[ -z "$(theme.sh --version)" ]] && [[ -n "$(fzf --version)" ]] ; then
    install_theme.sh
  else
    sudo apt-get istall fzf 
    install_theme.sh
  fi
}

# space vim
check_and_install_space_vim() {
  # https://spacevim.org/
  check_and_install_curl
  check_and_install_make
  check_and_install_gcc
  echo "///////////////////////////// PREPARING TO INSTALL SPACE VIM ////////////////////////////"
  if [[ -d  ~/.SpaceVim.d ]] ; then
    echo "Space vim has already been installed"
    echo "_________________________________________________________________________________________"
    echo
   else
    echo "Installing  Space vim"
    echo "_________________________________________________________________________________________"
    echo
    curl -sLf https://spacevim.org/install.sh | bash
  fi

  # For more info about the install script, please check:
  # curl -sLf https://spacevim.org/install.sh | bash -s -- -h

  # If you got a vimproc error like this:
  # [vimproc] vimproc's DLL: "~/.SpaceVim/bundle/vimproc.vim/lib/vimproc_linux64.so" is not found.
}

# vim
# VERIFIED
check_and_install_vim() {
  echo "//////////////////////////////// PREPARING TO INSTALL VIM ///////////////////////////////"
  if [[ -n "$(which vim)" ]] ; then
    echo "Vim has already been installed"
    echo "_________________________________________________________________________________________"
    echo
   else
    echo "Installing Vim"
    echo "_________________________________________________________________________________________"
    echo
    sudo apt-get -y install vim
  fi
}	

# vscode
# VERIFIED
check_and_install_vscode() {
  echo "////////////////////////////// PREPARING TO INSTALL VSCODE //////////////////////////////"
  if [[ -n $(code --version) ]] ; then
    echo "Visual Studio Code has already been installed."
    echo "_________________________________________________________________________________________"
    echo
  else
    echo "Updating package index and install dependencies:"
    echo "_________________________________________________________________________________________"
    echo
    sudo apt update ;
    sudo apt install -y software-properties-common apt-transport-https wget ;
    echo "Importing repository GPG signing key:"
    echo "_________________________________________________________________________________________"
    echo
    wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add - ;
    echo "Enabling Visual Studio Code repository:"
    echo "_________________________________________________________________________________________"
    echo
    sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" ;
    echo "Installing Visual Studio Code:"
    echo "_________________________________________________________________________________________"
    echo
    sudo apt update ;
    sudo apt install -y code ;
  fi
}

# insomnia
# VERIFIED
check_and_install_insomnia() {
  check_and_install_snapd_package_manager
  echo "///////////////////////////// PREPARING TO INSTALL INSOMNIA /////////////////////////////"
  if [[ -n $(which insomnia) ]] ; then
    echo "Insomnia has already been installed."
    echo "_________________________________________________________________________________________"
    echo 
  else
    echo "Installing Insomnia:"
    echo "_________________________________________________________________________________________"
    echo
    # check updates for snap packages: sudo snap refresh --list
    sudo snap install insomnia ;

    # to remove snap install: 'sudo snap remove <package>'
  fi
}

# postman
# VERIFIED
check_and_install_postman() {
  check_and_install_snapd_package_manager
  echo "////////////////////////////// PREPARING TO INSTALL POSTMAN /////////////////////////////"
  if [[ -n $(which postman) ]] ; then
    echo "Postman has already been installed."
    echo "_________________________________________________________________________________________"
    echo 
  else
    echo "Installing Postman:"
    echo "_________________________________________________________________________________________"
    echo
    # check updates for snap packages: sudo snap refresh --list
    sudo snap install postman ;

    # to remove snap install: 'sudo snap remove <package>'
  fi
}

# mongodb
# VERIFIED
check_and_install_mongodb() {
  echo "///////////////////////////// PREPARING TO INSTALL MONGODB //////////////////////////////"
  if [[ -n $(mongo --version) ]] ; then
    echo "MongoDB has already been installed."
    echo "_________________________________________________________________________________________"
    echo 
  else
    # check updates for snap packages: sudo snap refresh --list
    echo "Updating package index and install dependencies:"
    echo "_________________________________________________________________________________________"
    echo
    sudo apt update ;
    if [[ -n $(which gpg) ]] ; then
      echo "Installing gnupg(GPG):"
      echo "_________________________________________________________________________________________"
      echo
      sudo apt-get install -y gnupg ;
    fi
    echo "Importing repository GPG signing key:"
    echo "_________________________________________________________________________________________"
    echo
    wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
    echo "Installing MongoDB:"
    echo "_________________________________________________________________________________________"
    echo
    sudo apt update ;
		sudo apt-get install -y mongodb ;
    
    # // start mongo:
    # sudo systemctl start mongod

    # // if the following or similar error is thrown: Failed to start mongod.service: Unit mongod.service not found.
    #sudo systemctl daemon-reload

    # //  verify mongodb has started successfully:
    # sudo systemctl status mongod

    # // allow mongodb to start on system reboot:
    # sudo systemctl status mongod

    # // stop mongodb:
    # sudo systemctl stop mongod

    # // restart mongodb:
    # sudo systemctl restart mongod

    # // start mongo shell:
    # mongo

    # // mongo shell config:
    # LINK: https://docs.mongodb.com/manual/mongo/
  fi
}

# postgresql
# VERIFIED
check_and_install_postgresql() {
  echo "//////////////////////////// PREPARING TO INSTALL POSTGRESQL ////////////////////////////"
  if [[ -n $(psql --version) ]] ; then
    echo "PostgreSQL has already been installed."
    echo "_________________________________________________________________________________________"
    echo 
  else

    echo "Creating file repository configuration:"
    echo "_________________________________________________________________________________________"
    echo
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    echo "Importing repository GPG signing key:"
    echo "_________________________________________________________________________________________"
    echo
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    echo "Installing PostgreSQL:"
    echo "_________________________________________________________________________________________"
    echo
    sudo apt update ;
    # to install specific version, E.X.: sudo apt-get install postgresql-12
		sudo apt-get install -y postgresql ;
    sudo apt-get install -y postgresql-contrib ;

    # running and manipulating local postres instance: LINK: https://www.postgresqltutorial.com/install-postgresql-linux/
  fi
}

# robo3t
# VERIFIED
check_and_install_robo3t() {
  check_and_install_snapd_package_manager
  echo "////////////////////////////// PREPARING TO INSTALL ROBO-3T /////////////////////////////"
  if [[ -n $(which robo3t) ]] ; then
    echo "Robo3t has already been installed."
    echo "_________________________________________________________________________________________"
    echo
  else
    echo "Installing Robo3t:"
    echo "_________________________________________________________________________________________"
    echo
    # check updates for snap packages: sudo snap refresh --list
    sudo snap install robo3t-snap ;

    # to remove snap install: 'sudo snap remove <package>'
  fi
  # SECTION: Install Robo3t On Ubuntu without using snap
  # Download the package form Robo3t or using wget
  # wget https://download.robomongo.org/1.2.1/linux/robo3t-1.2.1-linux-x86_64-3e50a65.tar.gz
  # Extract here using
  # tar -xvzf robo3t-1.2.1-linux-x86_64-3e50a65.tar.gz

  # Make a new floder in usr/local/bin from the package
  # sudo mkdir /usr/local/bin/robo3t

  # Move the extracted package to usr/local/bin
  # sudo mv  robo3t-1.2.1-linux-x86_64-3e50a65/* /usr/local/bin/robo3t

  # Change directory to cd /usr/local/bin/robo3t/bin
  # Now, We need to give permission to newly created directory using chmod
  # sudo chmod +x robo3t ./robo3t

  # Now we can run Robo3t ./robo3t

  # We can download the icon for Robo3t from and put it here as we will need to make desktop icon later
  # For example save it on /bin with name icon.png /usr/local/bin/robo3t/bin/icon.png

  # mv icon.png /usr/local/bin/robo3t/bin

  # To make desktop icon for Robo3t, we can make a file in usr/share/applications
  # sudo nano /usr/share/applications/robo3t.desktop

  # Paste these there and save

  # [Desktop Entry]
  # Encoding=UTF-8
  # Type=Application
  # Name=Robo3t
  # Icon=/usr/local/bin/robo3t/bin/icon.png
  # Exec="/usr/local/bin/robo3t/bin/robo3t"
  # Comment=Robo3t 
  # Categories=Development;
  # Terminal=false
  # StartupNotify=true
  # Now, we can find the icon in application launcher menu by search for robo3t

  # We can check this also      
}

# beekeeper studio
# SQL DB visualizer
# VERIFIED
check_and_install_beekeeper_studio() {
  check_and_install_snapd_package_manager
  echo "///////////////////////// PREPARING TO INSTALL BEEKEEPER STUDIO /////////////////////////"
  if [[ -n $(which beekeeper-studio) ]] ; then
    echo "Beekeeper Studio has already been installed."
    echo "_________________________________________________________________________________________"
    echo
  else
    echo "Installing Beekeeper Studio:"
    echo "_________________________________________________________________________________________"
    echo
    # check updates for snap packages: sudo snap refresh --list
    sudo snap install beekeeper-studio ;

    # to remove snap install: 'sudo snap remove <package>'
  fi
}

# google chrome
# VERIFIED
check_and_install_google_chrome() {

  install_google_chrome() {
    # LINK: https://linuxize.com/post/wget-command-examples/ wget uses
    # LINK: https://askubuntu.com/questions/291035/how-to-add-a-gpg-key-to-the-apt-sources-keyring adding program key to deb package manager
    sudo mkdir /opt/google
    sudo mkdir /opt/google/chrome
    sudo wget -P /opt/google/chrome https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install /opt/google/chrome/google-chrome-stable_current_amd64.deb 
  }

  echo "////////////////////////// PREPARING TO INSTALL GOOGLE CHROME ///////////////////////////"
  
  if [[ -n $(google-chrome-stable --version) ]] ; then
    echo "Google Chrome has already been installed."
    echo "_________________________________________________________________________________________"
    echo
  else
    if [[ -n $(which wget) ]] ; then
      echo "Installing Google Chrome:"
      echo "_________________________________________________________________________________________"
      echo
      install_google_chrome
    else
      echo "Installing wget and Google Chrome:"
      echo "_________________________________________________________________________________________"
      echo
      sudo apt install wget
      install_google_chrome
    fi
  fi
}

# slack
# VERIFIED
check_and_install_slack() {
  check_and_install_snapd_package_manager
  echo "/////////////////////////////// PREPARING TO INSTALL SLACK //////////////////////////////"
  if [[ -n $(which slack) ]] ; then
    echo "Slack has already been installed."
    echo "_________________________________________________________________________________________"
    echo
  else
    echo "Installing Slack:"
    echo "_________________________________________________________________________________________"
    echo
    # check updates for snap packages: sudo snap refresh --list
    sudo snap install slack --classic
    # to remove snap install: 'sudo snap remove <package>'
  fi
}

# discord
# VERIFIED
check_and_install_discord() {
  check_and_install_snapd_package_manager
  echo "////////////////////////////// PREPARING TO INSTALL discord /////////////////////////////"
  if [[ -n $(which discord) ]] ; then
    echo "Discord has already been installed."
    echo "_________________________________________________________________________________________"
    echo
  else
    echo "Installing Discord:"
    echo "_________________________________________________________________________________________"
    echo
    # check updates for snap packages: sudo snap refresh --list
    sudo snap install discord
    # to remove snap install: 'sudo snap remove <package>'
  fi
}

# npm global packages
install_global_npm_packages() {
  echo "////////////////////// PREPARING TO GLOBALLY INSTALL NPM PACKAGES ///////////////////////"
  echo "NO GLOBAL PACKAGES SPECIFIED YET"
  # typescript tsc
  # serverless
  # aws-sdk
}

# test these functions individually
install_all_programs() {
  check_and_install_grub_customizer ;
  check_and_install_htop ;
  check_and_install_tree ; 
  check_and_install_rust ;
  check_and_install_flutter_and_dart ;
  check_and_install_zsh ;
  check_and_install_theme ;
  check_and_install_vscode ;
  check_and_install_space_vim ;
  check_and_install_vim ;
  check_and_install_insomnia ;
  check_and_install_postman ;
  check_and_install_mongodb ;
  check_and_install_postgresql ;
  check_and_install_robo3t ;
  check_and_install_beekeeper_studio ;
  check_and_install_google_chrome ;
  check_and_install_slack ;
  check_and_install_discord ;
  install_global_npm_packages ;
}

FUNCTIONS_ARRAY=(
  check_and_install_grub_customizer
  check_and_install_htop
  check_and_install_tree
  check_and_install_rust
  check_and_install_flutter_and_dart
  check_and_install_zsh
  check_and_install_theme
  check_and_install_vscode
  check_and_install_space_vim
  check_and_install_vim
  check_and_install_insomnia
  check_and_install_postman
  check_and_install_mongodb
  check_and_install_postgresql
  check_and_install_robo3t
  check_and_install_beekeeper_studio
  check_and_install_google_chrome
  check_and_install_slack
  check_and_install_discord 
  install_global_npm_packages
)

PROGRAM_NAMES_ARRAY=(
  'Grub Customizer'
  'Htop(process manager)'
  'Tree(graphically displays dir tree)'
  'Rust Lang'
  'Flutter and Dart'
  'Zshell'
  'Theme.sh'
  'VS Code'
  'Space Vim'
  'Vim'
  'Insomnia'
  'Postman'
  'MongoDB'
  'PostgreSQL'
  'Robo 3t'
  'Beekeeper Studio'
  'Google Chrome'
  'Slack'
  'Discord'
  'Global NPM Packages'
)
