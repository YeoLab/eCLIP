################## BASE IMAGE ######################

FROM continuumio/miniconda:latest

################## METADATA ######################

LABEL base_image="continuumio/miniconda:latest"
LABEL version="1"
LABEL software="ucsc-tools"
LABEL software.version="377"
LABEL about.summary="A partial collection of UCSC tools from conda."
LABEL about.home="http://hgdownload.soe.ucsc.edu/downloads.html#source_downloads"
LABEL about.documentation=""
LABEL about.license_file=""
LABEL about.license=""
LABEL about.tags="Genomics"

################## MAINTAINER ######################
MAINTAINER Brian Yee <brian.alan.yee@gmail.com>

RUN conda install -y -c bioconda -c conda-forge \
  ucsc-liftover=377 \
  ucsc-bedtobigbed=377 \ 
  ucsc-bigbedtobed=377 \
  ucsc-bedgraphtobigwig=377 \
  ucsc-fetchchromsizes=377 \
  ucsc-bigwigtobedgraph=377 \
  ucsc-bigwigtowig=377 \
  ucsc-bigwigmerge=377 \
  ucsc-wigtobigwig=377 \
  ucsc-genepredcheck=377 \
  ucsc-fatotwobit=377 \
  ucsc-gtftogenepred=377 \
  ucsc-hggcpercent=377 \
  ucsc-gff3togenepred=377 \
  ucsc-genepredtofakepsl=377 \
  ucsc-bamtopsl=377 \
  ucsc-genepredtobed=377 \
  ucsc-transmappsltogenepred=377 \
  ucsc-pslpostarget=377 \
  ucsc-axtchain=377 \
  ucsc-chainmergesort=377 \
  ucsc-pslrecalcmatch=377 \
  ucsc-pslmappostchain=377 \
  ucsc-gtftogenepred=377 \
  ucsc-genepredtogtf=377 \
  ucsc-pslcheck=377 \
  ucsc-clustergenes=377 \
  ucsc-psltobigpsl=377 \
  ucsc-bedsort=377 \
  ucsc-blat=377


WORKDIR /data/

CMD ["bedToBigBed"]
