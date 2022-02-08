#!/usr/bin/env bash


# Debugging settings:
#####################
# exit immediately upon any error, output each line as it is executed
set -ex -o pipefail


CONCATENATED=$1

INPUTS=${@:2}

zcat $INPUTS | gzip > $CONCATENATED
