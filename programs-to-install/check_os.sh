#!/bin/bash

OS="Windows"
CURRENT_OS="$(uname -s)"
# check whether running Linux or Darwin

if [[ "${CURRENT_OS}" == "Darwin" ]]; then
  # this is working on Darwin
  OS="${CURRENT_OS}"
  echo "Current OS is Darwin: ${CURRENT_OS}"
elif [[ "${CURRENT_OS}" == "Linux" ]]; then
  # still needs testing on linux machine
  OS="${CURRENT_OS}"
  echo "Current OS is Linux: ${CURRENT_OS}"
else
  echo "Defaulting to ${OS}"
fi

echo "Found OS: ${OS}"
