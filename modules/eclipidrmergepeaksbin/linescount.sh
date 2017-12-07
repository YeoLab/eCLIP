#!/usr/bin/env bash

wc -l ${1} | cut --fields=1 --delimiter=\  --only-delimited

