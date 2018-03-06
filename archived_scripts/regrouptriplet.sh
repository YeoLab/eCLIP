#!/usr/bin/env bash

# Debugging settings:
#####################

# Print commands and their arguments as they are executed.
set -x

#Exit immediately if a command exits with a non-zero status.
set -e

#the return value of a pipeline is the status of
#the last command to exit with a non-zero status,
#or zero if no command exited with a non-zero status
set -o pipefail



ls -la

echo $1 > $1
echo $2 > $2

cp $3 $4 $5 ./

ls -la
