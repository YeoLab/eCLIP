################## BASE IMAGE ######################

FROM continuumio/miniconda:latest

################## METADATA ######################

LABEL base_image="continuumio/miniconda:latest"
LABEL version="1"
LABEL software="cutadapt"
LABEL software.version="1.14"
LABEL about.summary="Cutadapt finds and removes adapter sequences, primers, poly-A tails and other types of unwanted sequence from your high-throughput sequencing reads."
LABEL about.home="https://github.com/marcelm/cutadapt"
LABEL about.documentation="http://cutadapt.readthedocs.io/en/stable/guide.html"
LABEL about.license_file="https://github.com/marcelm/cutadapt/blob/v1.14/LICENSE"
LABEL about.license="MIT"
LABEL about.tags="Genomics"

################## MAINTAINER ######################
MAINTAINER Brian Yee <brian.alan.yee@gmail.com>

RUN conda install -y -c bioconda cutadapt=1.14

WORKDIR /data/

CMD ["cutadapt"]
