#!/bin/bash

########################################################################################################
############################################# DEPENDENCIES #############################################
########################################################################################################

# snapd
check_and_install_snapd_package_manager() {
  echo "////////////////////// PREPARING TO INSTALL SNAP PACKAGE MANAGER //////////////////////"
  if [[ -n "$(which snap)" ]] ; then
    echo "Snap has already been installed"
    echo "_________________________________________________________________________"
    echo
   else
    echo "Installing Snap package manager"
    echo "_________________________________________________________________________"
    echo
    sudo apt-get -y install snapd
  fi
}

# make - does not need to be added to install list
check_and_install_make() {
  echo "////////////////////// PREPARING TO INSTALL MAKE //////////////////////"
  if [[ -n "$(which make)" ]] ; then
    echo "Make has already been installed"
    echo "_________________________________________________________________________"
    echo
   else
    echo "Installing make"
    echo "_________________________________________________________________________"
    echo
    sudo apt-get -y install make
  fi
}

#gcc - does not need to be added to install list
check_and_install_gcc() {
  echo "////////////////////// PREPARING TO INSTALL GCC //////////////////////"
  if [[ -n "$(which gcc)" ]] ; then
    echo "Gcc has already been installed"
    echo "_________________________________________________________________________"
    echo
   else
    echo "Installing gcc"
    echo "_________________________________________________________________________"
    echo
    sudo apt-get -y install gcc
  fi
}

# grub-customizer
check_and_install_grub_customizer() {
  echo "////////////////////// PREPARING TO INSTALL GRUB CUSTOMIZER //////////////////////"
  if [[ -n "$(which grub-customizer)" ]] ; then
    echo "Grub-customizer has already been installed"
    echo "_________________________________________________________________________"
    echo
   else
    echo "Installing grub-customizer"
    echo "_________________________________________________________________________"
    echo
    sudo add-apt-repository ppa:danielrichter2007/grub-customizer
    sudo apt update
    sudo apt -y install grub-customizer
  fi
}

# curl
check_and_install_curl() {
  echo "////////////////////// PREPARING TO INSTALL CURL //////////////////////"
  if [[ -n "$(which curl)" ]] ; then
    echo "Curl has already been installed"
    echo "_________________________________________________________________________"
    echo
   else
    echo "Installing curl"
    echo "_________________________________________________________________________"
    echo
    sudo apt-get -y install curl
  fi
}

# htop
check_and_install_htop() {
  echo "////////////////////// PREPARING TO INSTALL HTOP //////////////////////"
  if [[ -n "$(which htop)" ]] ; then
    echo "Htop has already been installed"
    echo "_________________________________________________________________________"
    echo
   else
    echo "Installing htop"
    echo "_________________________________________________________________________"
    echo
    sudo apt-get -y install htop
  fi
}

# tree graphically displays a dir tree
check_and_install_tree() {
  echo "////////////////////// PREPARING TO INSTALL TREE //////////////////////"
  if [[ -n "$(which tree)" ]] ; then
    echo "Tree has already been installed"
    echo "_________________________________________________________________________"
    echo
   else
    echo "Installing tree"
    echo "_________________________________________________________________________"
    echo
    sudo apt-get -y install tree
  fi
}

########################################################################################################
############################################### PROGRAMS ###############################################
########################################################################################################

# gh Github CLI(can create PRs, Repos, and other git flows without accessing website)
# VERIFIED
check_and_install_gh() {
  check_and_install_curl
  echo "////////////////////// PREPARING TO INSTALL GH(GITHUB CLI) //////////////////////"
  if [[ -n $(gh --version) ]] ; then
    echo "gh(github CLI) has already been installed."
    echo "_________________________________________________________________________"
    echo
  else
    echo "Installing gh(github CLI):"
    echo "_________________________________________________________________________"
    echo
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg ;
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null ;
    sudo apt update ;
    sudo apt install dirmngr ;
    sudo apt install gh ;
  fi
}

# rust-lang
# VERIFIED
check_and_install_rust() {
  check_and_install_curl
  echo "////////////////////// PREPARING TO INSTALL RUST //////////////////////"
  if [[ -n $(rustc --version) ]] ; then
    echo "Rust lang has already been installed."
    echo "_________________________________________________________________________"
    echo
  else
    echo "Installing Rust lang:"
    echo "_________________________________________________________________________"
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
  echo "////////////////////// PREPARING TO INSTALL FLUTTER AND DART //////////////////////"
  if [[ -n "$(which flutter)"  ]] ; then
    echo "Flutter and Dart have already been installed."
    echo "_________________________________________________________________________"
    echo
  else
   echo "Installing Flutter and Dart dependencies:"
    echo "_________________________________________________________________________"
    echo
    sudo apt-get -y install clang cmake ninja-build pkg-config libgtk-3-dev

    echo
    echo "Installing Flutter and Dart:"
    echo "_________________________________________________________________________"
    echo
    sudo snap install flutter --classic

    # enable desktop support
    echo "Enabling Flutter and Dart desktop support:"
    echo "_________________________________________________________________________"
    echo
    flutter config --enable-linux-desktop

  fi
}

# zsh
# nvm, node, npm
# VERIFIED
check_and_install_zsh() {
  check_and_install_curl
  echo "////////////////////// PREPARING TO INSTALL ZSHELL //////////////////////"
  if [[ -d ~/.oh-my-zsh ]] && [[ -f ~/.zshrc ]] ; then
    echo "Z-Shell has already been installed."
    echo "_________________________________________________________________________"
    echo
  else
    echo "Installing Z-Shell:"
    echo "_________________________________________________________________________"
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
    echo "_________________________________________________________________________"
    echo
    wget https://raw.githubusercontent.com/lemnos/theme.sh/master/bin/theme.sh -O /tmp/theme.sh
  }

  echo "////////////////////// PREPARING TO INSTALL THEME.SH //////////////////////"
  if [[ -n "$(theme.sh --version)" ]] && [[ -n "$(fzf --version)" ]] ; then
    echo "Theme.sh has already been installed."
    echo "_________________________________________________________________________"
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
  echo "////////////////////// PREPARING TO INSTALL SPACE VIM //////////////////////"
  if [[ -d  ~/.SpaceVim.d ]] ; then
    echo "Space vim has already been installed"
    echo "_________________________________________________________________________"
    echo
   else
    echo "Installing  Space vim"
    echo "_________________________________________________________________________"
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
  echo "////////////////////// PREPARING TO INSTALL VIM //////////////////////"
  if [[ -n "$(which vim)" ]] ; then
    echo "Vim has already been installed"
    echo "_________________________________________________________________________"
    echo
   else
    echo "Installing Vim"
    echo "_________________________________________________________________________"
    echo
    sudo apt-get -y install vim
  fi
}	

# vscode
# VERIFIED
check_and_install_vscode() {
  echo "////////////////////// PREPARING TO INSTALL VSCODE //////////////////////"
  if [[ -n $(code --version) ]] ; then
    echo "Visual Studio Code has already been installed."
    echo "_________________________________________________________________________"
    echo
  else
    echo "Updating package index and install dependencies:"
    echo "_________________________________________________________________________"
    echo
    sudo apt update ;
    sudo apt install -y software-properties-common apt-transport-https wget ;
    echo "Importing repository GPG signing key:"
    echo "_________________________________________________________________________"
    echo
    wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add - ;
    echo "Enabling Visual Studio Code repository:"
    echo "_________________________________________________________________________"
    echo
    sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" ;
    echo "Installing Visual Studio Code:"
    echo "_________________________________________________________________________"
    echo
    sudo apt update ;
    sudo apt install -y code ;
  fi
}

# insomnia
# VERIFIED
check_and_install_insomnia() {
  check_and_install_snapd_package_manager
  echo "////////////////////// PREPARING TO INSTALL INSOMNIA //////////////////////"
  if [[ -n $(which insomnia) ]] ; then
    echo "Insomnia has already been installed."
    echo "_________________________________________________________________________"
    echo 
  else
    echo "Installing Insomnia:"
    echo "_________________________________________________________________________"
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
  echo "////////////////////// PREPARING TO INSTALL POSTMAN //////////////////////"
  if [[ -n $(which postman) ]] ; then
    echo "Postman has already been installed."
    echo "_________________________________________________________________________"
    echo 
  else
    echo "Installing Postman:"
    echo "_________________________________________________________________________"
    echo
    # check updates for snap packages: sudo snap refresh --list
    sudo snap install postman ;

    # to remove snap install: 'sudo snap remove <package>'
  fi
}

# mongodb
# VERIFIED
check_and_install_mongodb() {
  echo "////////////////////// PREPARING TO INSTALL MONGODB //////////////////////"
  if [[ -n $(mongo --version) ]] ; then
    echo "MongoDB has already been installed."
    echo "_________________________________________________________________________"
    echo 
  else
    # check updates for snap packages: sudo snap refresh --list
    echo "Updating package index and install dependencies:"
    echo "_________________________________________________________________________"
    echo
    sudo apt update ;
    if [[ -n $(which gpg) ]] ; then
      echo "Installing gnupg(GPG):"
      echo "_________________________________________________________________________"
      echo
      sudo apt-get install -y gnupg ;
    fi
    echo "Importing repository GPG signing key:"
    echo "_________________________________________________________________________"
    echo
    wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
    echo "Installing MongoDB:"
    echo "_________________________________________________________________________"
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
  echo "////////////////////// PREPARING TO INSTALL POSTGRESQL //////////////////////"
  if [[ -n $(psql --version) ]] ; then
    echo "PostgreSQL has already been installed."
    echo "_________________________________________________________________________"
    echo 
  else

    echo "Creating file repository configuration:"
    echo "_________________________________________________________________________"
    echo
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    echo "Importing repository GPG signing key:"
    echo "_________________________________________________________________________"
    echo
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    echo "Installing PostgreSQL:"
    echo "_________________________________________________________________________"
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
  echo "////////////////////// PREPARING TO INSTALL ROBO-3T //////////////////////"
  if [[ -n $(which robo3t) ]] ; then
    echo "Robo3t has already been installed."
    echo "_________________________________________________________________________"
    echo
  else
    echo "Installing Robo3t:"
    echo "_________________________________________________________________________"
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
  echo "////////////////////// PREPARING TO INSTALL BEEKEEPER STUDIO //////////////////////"
  if [[ -n $(which beekeeper-studio) ]] ; then
    echo "Beekeeper Studio has already been installed."
    echo "_________________________________________________________________________"
    echo
  else
    echo "Installing Beekeeper Studio:"
    echo "_________________________________________________________________________"
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

  echo "////////////////////// PREPARING TO INSTALL GOOGLE CHROME //////////////////////"
  
  if [[ -n $(google-chrome-stable --version) ]] ; then
    echo "Google Chrome has already been installed."
    echo "_________________________________________________________________________"
    echo
  else
    if [[ -n $(which wget) ]] ; then
      echo "Installing Google Chrome:"
      echo "_________________________________________________________________________"
      echo
      install_google_chrome
    else
      echo "Installing wget and Google Chrome:"
      echo "_________________________________________________________________________"
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
  echo "////////////////////// PREPARING TO INSTALL SLACK //////////////////////"
  if [[ -n $(which slack) ]] ; then
    echo "Slack has already been installed."
    echo "_________________________________________________________________________"
    echo
  else
    echo "Installing Slack:"
    echo "_________________________________________________________________________"
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
  echo "////////////////////// PREPARING TO INSTALL discord //////////////////////"
  if [[ -n $(which discord) ]] ; then
    echo "Discord has already been installed."
    echo "_________________________________________________________________________"
    echo
  else
    echo "Installing Discord:"
    echo "_________________________________________________________________________"
    echo
    # check updates for snap packages: sudo snap refresh --list
    sudo snap install discord
    # to remove snap install: 'sudo snap remove <package>'
  fi
}

# npm global packages
install_global_npm_packages() {
  echo "////////////////////// PREPARING TO GLOBALLY INSTALL NPM PACKAGES //////////////////////"
  # typescript tsc
  # serverless
  # aws-sdk
}

# test these functions individually
install_all_programs() {
  check_and_install_snapd_package_manager ;
  check_and_install_grub_customizer ;
  check_and_install_curl ;
  check_and_install_htop ;
  check_and_install_tree ; 
  check_and_install_gh ;
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
  check_and_install_snapd_package_manager 
  check_and_install_grub_customizer
  check_and_install_curl
  check_and_install_htop
  check_and_install_tree
  check_and_install_gh
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
  'Snap Package Manager'
  'Grub Customizer'
  'Curl'
  'Htop(process manager)'
  'Tree(graphically displays dir tree)'
  'Github CLI - gh(not Git)'
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
