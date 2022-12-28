#!/bin/bash


function get_engen_fs_location() {
  if [[ -z $(grep "get_engen_fs_location" ~/.profile)  ]] ; then
    echo "$(pwd)"
  else
    # will be exported from ~/.profile
    echo get_engen_fs_location
  fi
}

echo "$(get_engen_fs_location)"