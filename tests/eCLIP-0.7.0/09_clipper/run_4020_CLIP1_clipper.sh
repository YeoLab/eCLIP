#!/bin/bash

module load clipper/5d865bb;

cwltool \
--no-container \
/projects/ps-yeolab4/software/eclip/0.7.0/cwl/clipper.cwl \
/home/bay001/projects/codebase/eclip/tests/eCLIP-0.7.0/clipper/4020_CLIP1.yaml
