################## BASE IMAGE ######################

FROM continuumio/miniconda:latest

################## METADATA ######################

LABEL base_image="continuumio/miniconda:latest"
LABEL version="1"
LABEL software="umi_tools"
LABEL software.version="0.5.3"
LABEL about.summary="Tools for handling Unique Molecular Identifiers in NGS data sets"
LABEL about.home="https://github.com/CGATOxford/UMI-tools"
LABEL about.documentation="https://github.com/CGATOxford/UMI-tools"
LABEL about.license_file="https://github.com/samtools/samtools/blob/develop/LICENSE"
LABEL about.license=""
LABEL about.tags="Genomics"

################## MAINTAINER ######################
MAINTAINER Brian Yee <brian.alan.yee@gmail.com>

RUN conda install -y -c bioconda umi_tools

WORKDIR /data/

CMD ["umi_tools"]