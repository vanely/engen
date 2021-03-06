#!/bin/bash

# spellcheck source=./utils/helpers/validation.sh
source "${HOME}/engen/utils/helpers/validation.sh"

# associative array of extensions
# declare -A PERSONAL_EXTENSIONS_LIST
# PERSONAL_EXTENSIONS_LIST["Better_TOML"]="bungcip.better-toml"
# PERSONAL_EXTENSIONS_LIST["Path_Intellisense"]="christian-kohler.path-intellisense"
# PERSONAL_EXTENSIONS_LIST["Bracket_Pair_Colorizer_2"]="coenraads.bracket-pair-colorizer-2"
# PERSONAL_EXTENSIONS_LIST["ESLint"]="dbaeumer.vscode-eslint"
# PERSONAL_EXTENSIONS_LIST["Git_Lens"]="eamodio.gitlens"
# PERSONAL_EXTENSIONS_LIST["Prettier"]="esbenp.prettier-vscode"
# PERSONAL_EXTENSIONS_LIST["Comment_Anchors"]="exodiusstudios.comment-anchors"
# PERSONAL_EXTENSIONS_LIST["Code_Runner"]="formulahendry.code-runner"
# PERSONAL_EXTENSIONS_LIST["Bash_Automated_Testing"]="jetmartin.bats"
# PERSONAL_EXTENSIONS_LIST["Bash_IDE"]="mads-hartmann.bash-ide-vscode"
# PERSONAL_EXTENSIONS_LIST["JavaScript_Docstrings"]="massi.javascript-docstrings"
# PERSONAL_EXTENSIONS_LIST["Rust_Analyzer"]="matklad.rust-analyzer"
# PERSONAL_EXTENSIONS_LIST["Monokai_Pro"]="monokai.theme-monokai-pro-vscode"
# PERSONAL_EXTENSIONS_LIST["Rust_Assist"]="mooman219.rust-assist"
# PERSONAL_EXTENSIONS_LIST["Atom_Keybindings"]="ms-vscode.atom-keybindings"
# PERSONAL_EXTENSIONS_LIST["Material_Icon_Theme"]="pkief.material-icon-theme"
# PERSONAL_EXTENSIONS_LIST["Power_Mode"]="hoovercj.vscode-power-mode"
# PERSONAL_EXTENSIONS_LIST["Live_Server"]="ritwickdey.liveserver"
# PERSONAL_EXTENSIONS_LIST["Bash_Debug"]="rogalmic.bash-debug"
# PERSONAL_EXTENSIONS_LIST["Rust"]="rust-lang.rust"
# PERSONAL_EXTENSIONS_LIST["SpellCheck"]="timonwong.shellcheck"

# TO ADD

# Back & Forward Buttons - nick-rudenko.back-n-forth 

EXTENSIONS_LIST_IDS=(
  azuretools.vscode-docker
  bungcip.better-toml
  christian-kohler.path-intellisense
  coenraads.bracket-pair-colorizer-2
  cyberbiont.vscode-profiles
  dbaeumer.vscode-eslint
  eamodio.gitlens
  esbenp.prettier-vscode
  exodiusstudios.comment-anchors
  formulahendry.code-runner
  jetmartin.bats
  ms-vsliveshare.vsliveshare
  mads-hartmann.bash-ide-vscode
  massi.javascript-docstrings
  matklad.rust-analyzer
  monokai.theme-monokai-pro-vscode
  mooman219.rust-assist
  ms-vscode.powershell
  ms-vscode.atom-keybindings
  pkief.material-icon-theme
  hoovercj.vscode-power-mode
  ritwickdey.liveserver
  rogalmic.bash-debug
  rust-lang.rust
  timonwong.shellcheck

  ############################### THEMES ###############################
  
  beardedbear.beardedicons
  beardedbear.beardedtheme
  d3ciph3r3r.boundless-gray
  impavan.theme-editor
  inksea.inksea-theme
  n0us.all-gray
  pkief.material-icon-theme
)

EXTENSIONS_LIST_NAMES=(
  'Docker'
  'Better_TOML'
  'Path_Intellisense'
  'Bracket_Pair_Colorizer_2'
  'Extension_Profiles'
  'ESLint'
  'Git_Lens'
  'Prettier'
  'Comment_Anchors'
  'Code_Runner'
  'Bash_Automated_Testing'
  'Live Share'
  'Bash_IDE'
  'JavaScript_Docstrings'
  'Rust_Analyzer'
  'Monokai_Pro'
  'Rust_Assist'
  'PowerShell_Support'
  'Atom_Keybindings'
  'Material_Icon_Theme'
  'Power_Mode'
  'Live_Server'
  'Bash_Debug'
  'Rust'
  'SpellCheck'

  ############################### THEMES ###############################

  'Bearded_Icons'
  'Bearded_Theme'
  'Boundless_Gray'
  'Theme-Editor'
  'Ink_Sea'
  'All_Gray'
  'Material_Icon_Theme'
)
EXTENSIONS_LIST_NAMES_LEN="${#EXTENSIONS_LIST_NAMES[@]}"
INSTALLS_ARR=($(code --list-extensions))
INSTALLS_LEN="${#INSTALLS_ARR[@]}"

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
  ALREADY_INSTALLED="false"

  for (( i=0; i<"${EXTENSIONS_LIST_NAMES_LEN}"; i++ ))
  do
    for (( j=0; j<"${INSTALLS_LEN}"; j++ ))
    do
      # (,,)=toLowerCase, (^^)=toUpperCase
      if [[ "${EXTENSIONS_LIST_IDS[i],,}" == "${INSTALLS_ARR[j],,}" ]] ; then
        ALREADY_INSTALLED="true"
        break
      fi
    done

    if [[ "${ALREADY_INSTALLED}" == "true" ]] ; then
      ALREADY_INSTALLED="false"
      continue
    else
      echo
      echo "========================================================================================="
      echo "Installing: ${EXTENSIONS_LIST_NAMES[i]}..."
      code --install-extension "${EXTENSIONS_LIST_IDS[i]}"
      echo "========================================================================================="
    fi
  done
}

choose_extenstions_to_install() {
  ALREADY_INSTALLED="false"

  echo "========================================================================================="
  echo "================================ [--VS-CODE EXTENSIONS--]================================"
  echo "========================================================================================="
  echo
  # for key in ${!PERSONAL_EXTENSIONS_LIST[@]}; 
  # do 
  #   echo "$key => ${PERSONAL_EXTENSIONS_LIST[$key]}"; 
  # done

  echo "all"
  for (( i=0; i<"${EXTENSIONS_LIST_NAMES_LEN}"; i++ ))
  do
    for (( j=0; j<"${INSTALLS_LEN}"; j++ ))
    do
      # (,,)=toLowerCase, (^^)=toUpperCase
      if [[ "${EXTENSIONS_LIST_IDS[i],,}" == "${INSTALLS_ARR[j],,}" ]] ; then
        ALREADY_INSTALLED="true"
        break
      fi
    done

    if [[ "${ALREADY_INSTALLED}" == "true" ]] ; then
      ALREADY_INSTALLED="false"
      continue
    else
      # create array for validating that only the not yet installed extensions can be selected for install
      # current install list is only visual and other indexes can still be chosen
      echo "${i}: ${EXTENSIONS_LIST_NAMES[i]}"
    fi
  done

  echo
  echo "From the list above, select which vs-code extensions you'd like to install"
  echo "as 'all', or numbers separated by spaces. EX:"
  echo "0 2 4"
  echo
  echo -n "> "
  read -r indexes

  while "true"
  do
    if [[ "$(input_is_number_with_possible_spaces "${indexes}")" == "true" ]] || [[ "$(input_is_the_word_all "${indexes}")" == "true" ]]; then
      if [[ ${indexes} == 'all' ]] ; then
        install_all_vscode_extensions
      else
        for i in ${indexes[@]}
        do
          echo
          echo "========================================================================================="
          echo "Installing: ${EXTENSIONS_LIST_NAMES[i]}..."
          code --install-extension "${EXTENSIONS_LIST_IDS[i]}"
          echo "========================================================================================="
        done
      fi
      break
    else
      echo
      echo "Input must be a number in the above list, or 'all'"
      echo
      echo -n "> "
      read -r indexes
    fi
  done

}

# choose_extenstions_to_install
