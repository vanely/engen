#!/bin/bash


source "${ENGEN_ROOT}/programs-to-install/dependencies/dependencies.sh"

########################################################################################################
############################################### PROGRAMS ###############################################
########################################################################################################

# grub-customizer
check_and_install_grub_customizer() {
  echo "///////////////////////// PREPARING TO INSTALL GRUB CUSTOMIZER //////////////////////////"
  if command -v grub-customizer &>/dev/null ; then
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
  if command -v htop &>/dev/null ; then
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
  if command -v tree &>/dev/null ; then
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
  if command -v rustc &>/dev/null ; then
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

    if command -v rustc &>/dev/null ; then
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
  if command -v flutter &>/dev/null ; then
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
  if command -v theme.sh &>/dev/null && command -v fzf &>/dev/null ; then
    echo "Theme.sh has already been installed."
    echo "_________________________________________________________________________________________"
    echo
  elif ! command -v theme.sh &>/dev/null && command -v fzf &>/dev/null ; then
    install_theme.sh
  else
    sudo apt-get -y install fzf 
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
  if command -v vim &>/dev/null ; then
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
  if command -v code &>/dev/null ; then
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
  if command -v insomnia &>/dev/null ; then
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
  if command -v postman &>/dev/null ; then
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
  if command -v mongo &>/dev/null ; then
    echo "MongoDB has already been installed."
    echo "_________________________________________________________________________________________"
    echo 
  else
    # check updates for snap packages: sudo snap refresh --list
    echo "Updating package index and install dependencies:"
    echo "_________________________________________________________________________________________"
    echo
    sudo apt update ;
    if command -v gpg &>/dev/null ; then
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
  if command -v psql &>/dev/null ; then
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
  if command -v robo3t&>/dev/null ; then
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
  if command -v beekeeper-studio &>/dev/null ; then
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

# Mongo Compass
# VERIFIED
# Doesn't work on ubuntu(mongo compass specific issue[segementation fault])
check_and_install_mongo_compass() {
  echo "////////////////////////////// PREPARING TO INSTALL NVM /////////////////////////////"
  if command -v mongodb-compass &>/dev/null ; then
    echo "mongodb-compass has already been installed."
    echo "_________________________________________________________________________________________"
    echo
  else
    echo "Installing NVM:"
    echo "_________________________________________________________________________________________"
    echo
    wget https://downloads.mongodb.com/compass/mongodb-compass_1.15.1_amd64.deb
    sudo dpkg -i mongodb-compass_1.15.1_amd64.deb
    sudo apt --fix-broken install  # if you get any broken dependency error
    sudo apt-get update
    sudo apt-get install -y libgconf-2-4
    # run with 'mongodb-compass'
  fi
}

check_and_install_dbschema() {
  echo "////////////////////////////// PREPARING TO INSTALL DBSCHEMA /////////////////////////////"
  if command -v DbSchema &>/dev/null ; then
    echo "DbSchema has already been installed."
    echo "_________________________________________________________________________________________"
    echo
  else
    local current_dir=$(pwd)
    echo "Installing DbSchema:"
    echo "_________________________________________________________________________________________"
    echo
    cd ~/Downloads || "---NO SUCH DIRECTORY |~/Downloads|---" ; exit
    wget https://dbschema.com/download/DbSchema_linux_9_4_0.deb
    sudo dpkg -i DbSchema_linux_9_4_0.deb
    # sudo apt --fix-broken install  # if you get any broken dependency error
    sudo apt-get update
    echo "--- returning to previous context ---"
    cd "${current_dir}" || "---NO SUCH DIRECTORY |~/Downloads|---" ; exit
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
  
  if command -v google-chrome-stable &>/dev/null ; then
    echo "Google Chrome has already been installed."
    echo "_________________________________________________________________________________________"
    echo
  else
    if command -v wget &>/dev/null ; then
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
  if command -v slack &>/dev/null ; then
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
  if command -v discord &>/dev/null ; then
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

# NVM
# VERIFIED
check_and_install_nvm() {
  # Linux/ Mac installs:
  # curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  # or
  # wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  check_and_install_curl
  echo "////////////////////////////// PREPARING TO INSTALL NVM /////////////////////////////"
  if command -v nvm &>/dev/null ; then
    echo "NVM has already been installed."
    echo "_________________________________________________________________________________________"
    echo
  else
    echo "Installing NVM:"
    echo "_________________________________________________________________________________________"
    echo
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

    if [[ -f ~/.zshrc ]] && [[ -f ~/.profile ]] ; then
      echo "Exposing NVM export from existing .profile config"
      # echo export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" >> ~/.profile
      # echo [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" >> ~/.profile
      echo export NVM_DIR="$HOME/.nvm" >> ~/.profile
      echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.profile
      echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'  >> ~/.profile
      echo
      echo "Sourcing ~/.zshrc"
      source ~/.zshrc
    elif [[ -f ~/.zshrc ]] && [[ ! -f ~/.profile ]] ; then
      echo "Exposing NVM export from newly created .profile config"
      touch ~/.profile
      # echo export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" >> ~/.profile
      # echo [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" >> ~/.profile
      echo export NVM_DIR="$HOME/.nvm" >> ~/.profile
      echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.profile
      echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'  >> ~/.profile
      echo source ~/.profile >> ~/.zshrc
      echo
      echo "Sourcing ~/.zshrc"
      source ~/.zshrc
    fi
  fi
}

# npm global packages
install_global_npm_packages() {
  echo "////////////////////// PREPARING TO GLOBALLY INSTALL NPM PACKAGES ///////////////////////"
  echo "NO GLOBAL PACKAGES SPECIFIED YET"
}

########################################################################################################
############################################## MODERN TOOLS ############################################
########################################################################################################

# Docker Engine
check_and_install_docker() {
  echo "///////////////////////// PREPARING TO INSTALL DOCKER //////////////////////////"
  if command -v docker &>/dev/null ; then
    echo "Docker is already installed: $(docker --version)"
    echo "_________________________________________________________________________________________"
  else
    echo "Installing Docker Engine..."
    echo "_________________________________________________________________________________________"
    # Remove old versions
    sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    # Install prerequisites
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    # Add Docker's official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    # Add the repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    # Install Docker Engine + CLI + Compose plugin
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    # Add current user to docker group (no sudo needed for docker commands)
    sudo usermod -aG docker "$USER"
    echo ""
    echo "Docker installed. You may need to log out and back in for group changes."
    echo "Run 'docker run hello-world' to verify."
  fi
}

# Docker Compose (standalone, if compose plugin wasn't installed with Docker)
check_and_install_docker_compose() {
  echo "///////////////////////// PREPARING TO INSTALL DOCKER COMPOSE //////////////////////////"
  if docker compose version &>/dev/null 2>&1 || command -v docker-compose &>/dev/null ; then
    echo "Docker Compose is already installed"
    docker compose version 2>/dev/null || docker-compose --version 2>/dev/null
    echo "_________________________________________________________________________________________"
  else
    echo "Installing Docker Compose plugin..."
    echo "_________________________________________________________________________________________"
    sudo apt-get update
    sudo apt-get install -y docker-compose-plugin
    echo "Docker Compose installed: $(docker compose version)"
  fi
}

# lazydocker — terminal UI for Docker
check_and_install_lazydocker() {
  echo "///////////////////////// PREPARING TO INSTALL LAZYDOCKER //////////////////////////"
  if command -v lazydocker &>/dev/null ; then
    echo "lazydocker is already installed"
    echo "_________________________________________________________________________________________"
  else
    echo "Installing lazydocker..."
    echo "_________________________________________________________________________________________"
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
  fi
}

# lazygit — terminal UI for Git
check_and_install_lazygit() {
  echo "///////////////////////// PREPARING TO INSTALL LAZYGIT //////////////////////////"
  if command -v lazygit &>/dev/null ; then
    echo "lazygit is already installed"
    echo "_________________________________________________________________________________________"
  else
    echo "Installing lazygit..."
    echo "_________________________________________________________________________________________"
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm -f lazygit lazygit.tar.gz
  fi
}

# ripgrep — fast search (rg)
check_and_install_ripgrep() {
  echo "///////////////////////// PREPARING TO INSTALL RIPGREP //////////////////////////"
  if command -v rg &>/dev/null ; then
    echo "ripgrep is already installed"
    echo "_________________________________________________________________________________________"
  else
    echo "Installing ripgrep..."
    echo "_________________________________________________________________________________________"
    sudo apt-get install -y ripgrep
  fi
}

# fd — modern find alternative
check_and_install_fd() {
  echo "///////////////////////// PREPARING TO INSTALL FD //////////////////////////"
  if command -v fd &>/dev/null || command -v fdfind &>/dev/null ; then
    echo "fd is already installed"
    echo "_________________________________________________________________________________________"
  else
    echo "Installing fd-find..."
    echo "_________________________________________________________________________________________"
    sudo apt-get install -y fd-find
    # Create fd symlink (Ubuntu installs as fdfind)
    if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
      sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
    fi
  fi
}

# bat — modern cat with syntax highlighting
check_and_install_bat() {
  echo "///////////////////////// PREPARING TO INSTALL BAT //////////////////////////"
  if command -v bat &>/dev/null || command -v batcat &>/dev/null ; then
    echo "bat is already installed"
    echo "_________________________________________________________________________________________"
  else
    echo "Installing bat..."
    echo "_________________________________________________________________________________________"
    sudo apt-get install -y bat
    # Create bat symlink (Ubuntu installs as batcat)
    if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
      sudo ln -sf "$(command -v batcat)" /usr/local/bin/bat
    fi
  fi
}

# fzf — fuzzy finder
check_and_install_fzf() {
  echo "///////////////////////// PREPARING TO INSTALL FZF //////////////////////////"
  if command -v fzf &>/dev/null ; then
    echo "fzf is already installed"
    echo "_________________________________________________________________________________________"
  else
    echo "Installing fzf..."
    echo "_________________________________________________________________________________________"
    sudo apt-get install -y fzf
  fi
}

# tmux — terminal multiplexer
check_and_install_tmux() {
  echo "///////////////////////// PREPARING TO INSTALL TMUX //////////////////////////"
  if command -v tmux &>/dev/null ; then
    echo "tmux is already installed"
    echo "_________________________________________________________________________________________"
  else
    echo "Installing tmux..."
    echo "_________________________________________________________________________________________"
    sudo apt-get install -y tmux
  fi
}

# eza — modern ls replacement
check_and_install_eza() {
  echo "///////////////////////// PREPARING TO INSTALL EZA //////////////////////////"
  if command -v eza &>/dev/null ; then
    echo "eza is already installed"
    echo "_________________________________________________________________________________________"
  else
    echo "Installing eza..."
    echo "_________________________________________________________________________________________"
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg
    sudo apt-get update
    sudo apt-get install -y eza
  fi
}

# zoxide — smart cd replacement
check_and_install_zoxide() {
  echo "///////////////////////// PREPARING TO INSTALL ZOXIDE //////////////////////////"
  if command -v zoxide &>/dev/null ; then
    echo "zoxide is already installed"
    echo "_________________________________________________________________________________________"
  else
    echo "Installing zoxide..."
    echo "_________________________________________________________________________________________"
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    echo ""
    echo "Add to your shell rc: eval \"\$(zoxide init bash)\" or eval \"\$(zoxide init zsh)\""
  fi
}

# test these functions individually
install_all_programs() {
  for func in "${FUNCTIONS_ARRAY[@]}"; do
    $func
  done
}

FUNCTIONS_ARRAY=(
  # ── Essentials ──
  check_and_install_docker
  check_and_install_docker_compose
  check_and_install_vim
  check_and_install_htop
  check_and_install_tree
  check_and_install_nvm
  check_and_install_rust
  check_and_install_zsh
  check_and_install_tmux
  # ── Modern CLI Tools ──
  check_and_install_ripgrep
  check_and_install_fd
  check_and_install_bat
  check_and_install_fzf
  check_and_install_eza
  check_and_install_zoxide
  check_and_install_lazygit
  check_and_install_lazydocker
  # ── Editors & IDEs ──
  check_and_install_vscode
  check_and_install_space_vim
  # ── API Tools ──
  check_and_install_insomnia
  check_and_install_postman
  # ── Databases ──
  check_and_install_mongodb
  check_and_install_postgresql
  check_and_install_beekeeper_studio
  # ── Communication ──
  check_and_install_google_chrome
  check_and_install_slack
  check_and_install_discord
  # ── Languages ──
  check_and_install_flutter_and_dart
  # ── Other ──
  check_and_install_grub_customizer
  install_global_npm_packages
)

PROGRAM_NAMES_ARRAY=(
  # ── Essentials ──
  'Docker Engine'
  'Docker Compose'
  'Vim'
  'Htop (process manager)'
  'Tree (directory visualization)'
  'NVM (Node Version Manager)'
  'Rust Lang'
  'Zshell'
  'tmux (terminal multiplexer)'
  # ── Modern CLI Tools ──
  'ripgrep (fast search — rg)'
  'fd (modern find)'
  'bat (modern cat with syntax highlighting)'
  'fzf (fuzzy finder)'
  'eza (modern ls)'
  'zoxide (smart cd)'
  'lazygit (terminal git UI)'
  'lazydocker (terminal docker UI)'
  # ── Editors & IDEs ──
  'VS Code'
  'Space Vim'
  # ── API Tools ──
  'Insomnia'
  'Postman'
  # ── Databases ──
  'MongoDB'
  'PostgreSQL'
  'Beekeeper Studio'
  # ── Communication ──
  'Google Chrome'
  'Slack'
  'Discord'
  # ── Languages ──
  'Flutter and Dart'
  # ── Other ──
  'Grub Customizer'
  'Global NPM Packages'
)
