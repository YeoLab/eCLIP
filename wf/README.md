## This folder contains work-in-progress "metadata runners".

- The idea is to better facilitate switching between cwlref-runner, cwltoil (local), cwltoil (torque)
- Any 'single end' workflow must have ```#!/usr/bin/env eCLIP_singleend``` at the top of their yaml document. This uses the eCLIP_singleend bash script, which specifies the cwl workflow be single-end-specific.
- Likewise for 'paired end' workflows.