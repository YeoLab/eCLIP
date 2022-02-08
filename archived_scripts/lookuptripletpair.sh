#!/usr/bin/env bash

# Debugging settings:
#####################
# exit immediately upon any error, output each line as it is executed
set -ex -o pipefail

echo ${@}

ls -la

cp ${1#file://} ./
cp ${2#file://} ./
cp ${3#file://} ./

cp ${4#file://} ./
cp ${5#file://} ./
cp ${6#file://} ./

ls -la
