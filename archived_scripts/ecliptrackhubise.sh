#!/bin/bash

mkdir -p ecliptrackhubize/inputs

#
#

#

INTERMPATH=tmp/cwltool_interm/*/

cp -n ${INTERMPATH}*.posbw ecliptrackhubize/inputs/                                  # TODO remove Me
cp -n ${INTERMPATH}*.negbw ecliptrackhubize/inputs/

cp $ECLIP_HOME/init/TEMPLATE.ecliptrackhubize.eclip ecliptrackhubize/
# remove erratic empty files due to cp withoit source available
#rm ./\**


#cp -r ecliptrackhubize/*/tmp/cwltool_interm/*  ./tmp/
#cp -r ecliptrackhubize/*/tmp/cwltool_interm/*  ./tmp/cwltool_interm/
#
