#!/usr/bin/env bash

mkdir -p errors
grep 'permanentFail' ./eclip-job-log.txt -i -n -B 60 -A 0 > errors/permanentFails.txt
#grep 'permanentFail' ./ECLIP-JOB-LOG.txt > errors.txt

cat errors/permanentFails.txt
