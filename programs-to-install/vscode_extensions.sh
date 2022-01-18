#!/bin/bash

# TO ADD
# christian-kohler.path-intellisense
# visualstudioexptteam.vscodeintellicode
# work on interactive install similar to other flows and installs

EXTENSIONS_LIST_IDS=(
  coenraads.bracket-pair-colorizer-2
  dbaeumer.vscode-eslint
  eamodio.gitlens
  esbenp.prettier-vscode
  exodiusstudios.comment-anchors
  formulahendry.code-runner
  mads-hartmann.bash-ide-vscode
  massi.javascript-docstrings
  monokai.theme-monokai-pro-vscode
  ms-vscode.atom-keybindings
  pkief.material-icon-theme
  ritwickdey.liveserver
  rogalmic.bash-debug
  swellaby.rust-pack
)
EXTENSIONS_LIST_NAMES=(
  'Bracket Pair Colorizer 2'
  'ESLint'
  'Git Lens'
  'Prettier'
  'Comment Anchors'
  'Code Runner'
  'Bash IDE'
  'JavaScript Docstrings'
  'Monokai Pro'
  'Atom Keybindings'
  'Material Icon Theme'
  'Live Server'
  'Bash Debug'
  'Rust Extension Pack'
)
INSTALLED_EXTENSIONS=$'\n' read -rd '' -a y <<<"$(code --list-extensions)"
EXTENSIONS_LIST_LEN="${#EXTENSIONS_LIST_NAMES[@]}"

install_all_vscode_extensions() {
  # Set the root path for extensions.
  #   code --extensions-dir <dir>
  # List the installed extensions.
  #   code --list-extensions
  # Show versions of installed extensions, when using --list-extension.
  #   code --show-versions
  # Installs an extension.
  #   code --install-extension (<extension-id> | <extension-vsix-path>)
  # Uninstalls an extension.
  #   code --uninstall-extension (<extension-id> | <extension-vsix-path>)
  # Enables proposed API features for extensions. Can receive one or more extension IDs to enable individually.
  #   code --enable-proposed-api (<extension-id>)
  
  # bracket colorizer 2
  code --install-extension coenraads.bracket-pair-colorizer-2
  # es-lint
  code --install-extension dbaeumer.vscode-eslint
  # git lens
  code --install-extension eamodio.gitlens
  # prettier
  code --install-extension esbenp.prettier-vscode
  # comment anchors
  code --install-extension exodiusstudios.comment-anchors
  # code runner
  code --install-extension formulahendry.code-runner
  # bash IDE
  code --install-extension mads-hartmann.bash-ide-vscode
  # javascript docstrings
  code --install-extension massi.javascript-docstrings
  # monokai pro
  code --install-extension monokai.theme-monokai-pro-vscode
  # atom keymap
  code --install-extension ms-vscode.atom-keybindings
  # live-server
  code --install-extension ritwickdey.liveserver
  # bash debug
  code --install-extension rogalmic.bash-debug
  # rust extension pack
  code --install-extension swellaby.rust-pack
}

choose_extenstions_to_install() {
  echo "////////////////////// EXTENSIONS THAT ARE INSTALLED //////////////////////"
  echo "------------------ Installed ------------------"
  for (( i=0; i<"${EXTENSIONS_LIST_LEN}"; i++ ))
  do
    echo "${i}: ${INSTALLED_EXTENSIONS[i]}"
    echo
    echo
    if [[ INSTALLED_EXTENSIONS[i] = EXTENSIONS_LIST_IDS[i] ]] ; then
      continue ; 
    else
    echo "${i}: ${EXTENSIONS_LIST_NAMES[i]}"
      echo 
    fi
    # echo "${i}: ${INSTALLED_EXTENSIONS[i]}"
  done

  echo "////////////////////// EXTENSIONS THAT CAN BE INSTALLED //////////////////////"

}

choose_extenstions_to_install
