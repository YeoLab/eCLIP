#!/bin/bash
#PBS -N wf_clipseqcore_2bc
#PBS -o wf_clipseqcore_2bc.sh.out
#PBS -e wf_clipseqcore_2bc.sh.err
#PBS -V
#PBS -l walltime=24:00:00
#PBS -l nodes=1:ppn=7
#PBS -A yeo-group
#PBS -q home
#PBS -t 1-6

# Go to the directory from which the script was called
cd $PBS_O_WORKDIR
cmd[1]="module load eclip/0.7.0;cd /home/bay001/projects/codebase/eclip/tests/eCLIP-0.7.0/wf_clipseqcore_pe_2barcodes/;./A01_B06.yaml"
cmd[2]="module load eclip/0.7.0;cd /home/bay001/projects/codebase/eclip/tests/eCLIP-0.7.0/wf_clipseqcore_pe_2barcodes/;./A03_G07.yaml"
cmd[3]="module load eclip/0.7.0;cd /home/bay001/projects/codebase/eclip/tests/eCLIP-0.7.0/wf_clipseqcore_pe_2barcodes/;./A04_F05.yaml"
cmd[4]="module load eclip/0.7.0;cd /home/bay001/projects/codebase/eclip/tests/eCLIP-0.7.0/wf_clipseqcore_pe_2barcodes/;./C01_D8f.yaml"
cmd[5]="module load eclip/0.7.0;cd /home/bay001/projects/codebase/eclip/tests/eCLIP-0.7.0/wf_clipseqcore_pe_2barcodes/;./X1A_X1B.yaml"
cmd[6]="module load eclip/0.7.0;cd /home/bay001/projects/codebase/eclip/tests/eCLIP-0.7.0/wf_clipseqcore_pe_2barcodes/;./X2A_X2B.yaml"
eval ${cmd[$PBS_ARRAYID]}

