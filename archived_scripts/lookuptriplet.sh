#!/usr/bin/env bash

# Debugging settings:
#####################
# exit immediately upon any error, output each line as it is executed
set -ex -o pipefail

#echo ${@}

ls -la

cp ${1#file://} ./
cp ${2#file://} ./
cp ${3#file://} ./

ls -la
