#!/usr/bin/env bash

mkdir -p results/metrics

#cp -n tmp/cwltool_interm/*/*.metrics metrics/

cd results/metrics
#

# pattern path to all intermediates directories under interm
INTERMPATH=../../.tmp/cwltool_interm/*/

#ln -s ${INTERMPATH}*.*.*.metrics ./
cp ${INTERMPATH}*.*.*.metrics ./









# remove erratic empty files due to cp withoit source available
rm -f ./\**
cd ../..
