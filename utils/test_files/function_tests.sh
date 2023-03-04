# IFS=":" read -r pathArr <<< ${PATH}
# for path in ${pathArr}
# do
#   echo $path
# done

PATH_TO_REMOVE="${1}"
FAKE_PATH="/Users/vanely/Development/marley-devops/cli:/Users/vanely/.nvm/versions/node/v16.17.0/bin:/opt/homebrew/bin:/usr/local/opt/ruby/bin:/Users/vanely/Library/Python/2.7/bin:/Users/vanely/tools/ngrok/bin:/Users/vanely/tools/mongodb-osx-x86_64-3.4.6/bin:/usr/local/opt/mysql@5.7/bin:/Users/vanely/.nvm/versions/node/v16.17.0/bin:/Library/Frameworks/Python.framework/Versions/2.7/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/munki:/Library/Apple/usr/bin:/Users/vanely/Development/marley-devops/cli:/usr/local/opt/ruby/bin:/Users/vanely/Library/Python/2.7/bin:/Users/vanely/tools/ngrok/bin:/Users/vanely/tools/mongodb-osx-x86_64-3.4.6/bin:/usr/local/opt/mysql@5.7/bin:/Users/vanely/opt/miniconda3/bin:/Users/vanely/opt/miniconda3/condabin:/Users/vanely/.nvm/versions/node/v16.17.0/bin:/Library/Frameworks/Python.framework/Versions/2.7/bin:/Users/vanely/.rvm/bin:/usr/local/bin:/Users/vanely/.rvm/bin"
UNWANTED_PATH="/opt/homebrew/bin"
remove_dir_from_path() {
  local DIR_IN_PATH="false"
  local NEW_PATH=""
  IFS=":" read -r path_arr <<< ${FAKE_PATH}
  ##############################
  local structured_arr=(${path_arr})
  local arr_len=${#structured_arr[@]}
  local last_item="${structured_arr[${arr_len} - 1]}"
  echo "structured_Arr Length: ${arr_len}"
  echo "Last Item: ${last_item}"
  echo
  ##############################
  if [[ -z ${PATH_TO_REMOVE} ]]; then
    echo "This command requires an argument"
    echo "Expected argument is a directory that exists in your 'PATH'"
    echo
    echo "EX: rmpath \"/path/to/exclude\""
    echo
    echo "The output will be a list of paths, excluding the one passed in to the command"
    echo "This output can become the value of your PATH variable"
    echo
    echo 'EX: PATH=$(rmpatm /path/to/exclude)'
  else
    for p in ${path_arr};
    do
      if [[ "${p}" == "${PATH_TO_REMOVE}"  ]]; then
        DIR_IN_PATH="true"
      fi
    done

    if [[ "${DIR_IN_PATH}" == "false" ]]; then
      echo "The directory \"${PATH_TO_REMOVE}\" is not in PATH"
    else
      for path in ${path_arr};
      do
        if [[ "${path}" == "${PATH_TO_REMOVE}" ]]; then
          continue
        fi
        if [[ "${path}" == "${last_item}" ]]; then
          NEW_PATH+="${path}"
        else
          NEW_PATH+="${path}:"
        fi
      done
      echo ${NEW_PATH}
    fi
  fi
}

remove_dir_from_path