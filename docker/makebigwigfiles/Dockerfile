################## BASE IMAGE ######################

FROM continuumio/miniconda:latest

################## METADATA ######################

LABEL base_image="continuumio/miniconda:latest"
LABEL version="1"
LABEL software="makebigwigfiles"
LABEL software.version="0.0.3"
LABEL about.summary="A tool that generates strand-specific bigwig files."
LABEL about.home="https://github.com/yeolab/makebigwigfiles"
LABEL about.documentation="https://github.com/yeolab/makebigwigfiles"
LABEL about.license_file=""
LABEL about.license=""
LABEL about.tags="Genomics"

################## MAINTAINER ######################
MAINTAINER Brian Yee <brian.alan.yee@gmail.com>

RUN conda install -y -c bioconda \
    python=2.7 \
    ucsc-bedgraphtobigwig=357 \
    ucsc-bedsort=357 \
    samtools=1.5 \
    bedtools=2.26 \
    pybedtools=0.7.10

RUN mkdir -p /opt && \
    cd /opt && \
    git clone https://github.com/YeoLab/makebigwigfiles && \
    cd makebigwigfiles && \
    python setup.py install;

RUN echo $PATH

ENV PATH /opt/makebigwigfiles:$PATH

WORKDIR /data/

CMD ["makebigwigfiles"]

