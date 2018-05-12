################## BASE IMAGE ######################

FROM continuumio/miniconda:latest

################## METADATA ######################

LABEL base_image="continuumio/miniconda:latest"
LABEL version="1"
LABEL software="samtools"
LABEL software.version="1.5"
LABEL about.summary="SAM Tools provide various utilities for manipulating alignments in the SAM format, including sorting, merging, indexing and generating alignments in a per-position format."
LABEL about.home="http://www.htslib.org/"
LABEL about.documentation="http://www.htslib.org/doc/"
LABEL about.license_file="https://github.com/samtools/samtools/blob/develop/LICENSE"
LABEL about.license=""
LABEL about.tags="Genomics"

################## MAINTAINER ######################
MAINTAINER Brian Yee <brian.alan.yee@gmail.com>

RUN conda install python=2.7
RUN conda install -c bioconda samtools=1.5 pysam
RUN mkdir -p /opt && \
    cd /opt && \
    wget https://raw.githubusercontent.com/YeoLab/eclip/master/bin/barcodecollapsepe.py && \
    chmod +x barcodecollapsepe.py

ENV PATH /opt/:$PATH

WORKDIR /data/

CMD ["barcodecollapsepe.py"]
