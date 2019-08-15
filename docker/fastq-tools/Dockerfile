################## BASE IMAGE ######################

FROM continuumio/miniconda:latest

################## METADATA ######################

LABEL base_image="continuumio/miniconda:latest"
LABEL version="1"
LABEL software="fastq-tools"
LABEL software.version="0.8"
LABEL about.summary="This package provides a number of small and efficient programs to perform common tasks with high throughput sequencing data in the FASTQ format. All of the programs work with typical FASTQ files as well as gzipped FASTQ files."
LABEL about.home="https://github.com/dcjones/fastq-tools"
LABEL about.documentation="https://homes.cs.washington.edu/~dcjones/fastq-tools/"
LABEL about.license_file=""
LABEL about.license=""
LABEL about.tags="Genomics"

################## MAINTAINER ######################
MAINTAINER Brian Yee <brian.alan.yee@gmail.com>

RUN conda install -y -c bioconda fastq-tools=0.8

WORKDIR /data/

CMD ["fastq-sort"]
