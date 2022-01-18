#!/bin/bash

# NOTE: the directories of the files being sourced should be expressed
# relative to the directory of the root script that evetually calls it.

# imports
source ./check_os.sh

# check operating system, and decide which install checks to run.
echo "Current OS from main: ${OS}"