BootStrap: docker
From:  ubuntu:16.04

  #############################################################################

%setup

  # initial setups from outside the container
  # this is run from outside the container to start setting it up

  echo "Looking in directory '$SINGULARITY_ROOTFS' for /bin/sh"
  if [ ! -x "$SINGULARITY_ROOTFS/bin/sh" ]; then
      echo "Hrmm, this container does not have /bin/sh installed..."
      exit 1
  fi

  mkdir -p $SINGULARITY_ROOTFS/oasis/tscc/scratch
  mkdir -p $SINGULARITY_ROOTFS/projects/ps-yeolab
  mkdir -p $SINGULARITY_ROOTFS/projects/ps-yeolab3
  mkdir -p $SINGULARITY_ROOTFS/projects/ps-scrm
  mkdir -p $SINGULARITY_ROOTFS/oasis/projects/nsf

  mkdir -p $SINGULARITY_ROOTFS/opt/torque
  mkdir -p $SINGULARITY_ROOTFS/opt/sdsc/lib

  mkdir -p $SINGULARITY_ROOTFS/media/mis

  mkdir -p $SINGULARITY_ROOTFS/opt/members
  mkdir -p $SINGULARITY_ROOTFS/opt/modules
  mkdir -p $SINGULARITY_ROOTFS/opt/patches

  # these are needed early for post section
  cp -r ./members/* $SINGULARITY_ROOTFS/opt/members/
  cp -r ./modules/* $SINGULARITY_ROOTFS/opt/modules/
  cp -r ./patches/* $SINGULARITY_ROOTFS/opt/patches/

  #############################################################################

%post

  # running post scriptlet
  # this is run inside the container to install all necessary packages

  set -x

  ###########
  # MINICONDA  # instead of having: From: continuumio/miniconda:4.3.11
  # from https://hub.docker.com/r/continuumio/miniconda/~/dockerfile/

  # ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

  apt-get update --fix-missing
  apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

  #echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh
  wget --quiet https://repo.continuum.io/miniconda/Miniconda2-4.3.14-Linux-x86_64.sh -O ~/miniconda.sh
  /bin/bash ~/miniconda.sh -b -p /opt/conda
  rm ~/miniconda.sh

  #apt-get install -y curl grep sed dpkg
  #TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'`
  #curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb
  #dpkg -i tini.deb
  #rm tini.deb
  #apt-get clean

  #ENV PATH /opt/conda/bin:$PATH
  #ENTRYPOINT [ "/usr/bin/tini", "--" ]
  #CMD [ "/bin/bash" ]

  ###########
  # TOUCH-UPS

  #rm $SINGULARITY_ROOTFS/opt/members/bin/bedToBigBed       # no longer there
  ln -s -f /opt/modules/eclipdemux/demux /opt/modules/eclipdemux/eclipdemux
  rm  /opt/modules/makebigwigfiles/bedSort
  rm  /opt/modules/makebigwigfiles/bedGraphToBigWig

  touch /opt/done_with_touchups

  ########
  # UBUNTU
  apt-get -y update
  apt-get -y install make gcc g++ zlib1g-dev libncurses5-dev nano unzip
  # cleanup   x? M
  apt-get clean

  touch /opt/done_with_ubuntu

  ##########
  # SAMTOOLS
  TARBZ2="samtools-1.3.1.tar.bz2"
  wget https://github.com/samtools/samtools/releases/download/1.3.1/${TARBZ2} -P /opt
  tar -C /opt -xjf /opt/${TARBZ2}
  cd /opt/samtools-1.3.1
  make
  make prefix=/usr/local install
  cd -
  rm /opt/${TARBZ2}
  rm -rf /opt/samtools-1.3.1

  touch /opt/done_with_samtools



  #########################
  # CONDA CHANNELS PACKAGES
  # this is required here as the environment section is not processed yet
  PATH=/opt/conda/bin:$PATH
  #export $PATH

  # r-essentials
  /opt/conda/bin/conda install --yes -c r r-base=3.3.2 r-essentials

  touch /opt/done_with_r

  # perl
  /opt/conda/bin/conda install --yes -c bioconda \
    perl-statistics-distributions=1.02 \
    perl-statistics-r=0.34  perl-regexp-common=2016060801 perl-ipc-run=0.94

  touch /opt/done_with_perl

  # TODO: available from conda,
  # TODO: but overridden by /opt/members/map/STAR until shub 2349 included
  # -c liulab star=2.4.2a \
  # -c bioconda star=2.5.2b \
  /opt/conda/bin/conda install --yes -c bioconda \
    star=2.5.2b \
    bcftools=1.4.1 cutadapt=1.13 gffutils=0.8.7.1  \
    bd2k-python-lib=1.14a1.dev37 bedtools=2.26.0 bx-python=0.7.3 emboss=6.5.7 \
    ucsc-bedsort=332 ucsc-bedgraphtobigwig=332-0 ucsc-bedtobigbed=332-0
  #### fastqc=0.11.5 kallisto=0.43.0 sailfish=0.10.1 subread=1.5.0.post3
  #### htseq=0.7.2 pysam==0.11.2.1 pybedtools==0.7.9
  # cleanup 600M
  /opt/conda/bin/conda clean --index-cache --tarballs --packages --yes

  touch /opt/done_with_conda_channels

  ##############
  # PIP PACKAGES
  /opt/conda/bin/pip install pysam pybedtools htseq pyfaidx
  /opt/conda/bin/pip install boto
  ####pip install trackhub

  # customized trackhub
  # /opt/conda/bin/pip install https://github.com/gpratt/trackhub
  /opt/conda/bin/pip install /opt/patches/trackhub/0.1.1

  touch /opt/done_with_pip_packages

  ##########
  # PIP TOIL

  # #pip install toil[cwl]
  # #pip install toil[aws,mesos,azure,google,encryption,cwl]
  # /opt/conda/bin/pip install toil[aws,azure,google,cwl]

  #wget https://github.com/BD2KGenomics/toil/archive/releases/3.9.1.tar.gz --directory-prefix=/opt/
  #tar --directory /opt/ -xzf /opt/3.9.1.tar.gz
  #rm -f /opt/3.9.1.tar/gz
  #rm -f /opt/toil-releases-3.9.1/src/toil/batchSystems/registry.py
  #cp -f /opt/patches/toil_registry_fix/registry.py  /opt/toil-releases-3.9.1/src/toil/batchSystems/
  #/opt/conda/bin/pip install -e /opt/toil-releases-3.9.1[aws,azure,google,cwl]

  ###
  /opt/conda/bin/pip install toil[aws,azure,google,cwl]
  # torque patch
  rm -f /opt/conda/lib/python2.7/site-packages/toil/batchSystems/registry.py
  cp -f /opt/patches/toil_registry_fix/registry.py /opt/conda/lib/python2.7/site-packages/toil/batchSystems/
  ###

  touch /opt/done_with_pip_toil

  #########################
  # CONDA STANDARD PACKAGES
  ###conda install --yes -c conda-forge nodejs=6.10.2
  /opt/conda/bin/conda install --yes nodejs      #=4.4.1-1
  /opt/conda/bin/conda install --yes yaml pyyaml future futures cython curl simplejson \
    boto fabric requests s3transfer azure dill docutils psutil argcomplete \
    tqdm=4.14.0 numpy=1.10.2 matplotlib=1.5.1 scipy=0.16.0 \
    scikit-learn=0.17 pandas=0.18.1 seaborn statsmodels=0.6.1 pcre=8.39
  # cleanup 100M
  /opt/conda/bin/conda clean --index-cache --tarballs --packages --yes

  touch /opt/done_with_conda_standard _packages

  #########
  # CLIPPER
  #conda install --yes libgfortran==1                  # required for clipper!
  # NOT wORKING AS THIS REMOVES libgfortran.so.3 WHICH IS NEEDED BY R
  cp /opt/modules/eclipclipper/repo/libgfortran.so.1.0.0 /opt/conda/lib/
  ln -s /opt/conda/lib/libgfortran.so.1.0.0 /opt/conda/lib/libgfortran.so.1
  /opt/conda/bin/pip install -e /opt/modules/eclipclipper/repo
  #ln -s /opt/conda/bin/clipper /opt/modules/eclipclipper/bin/eclipclipper
  cp /opt/conda/bin/clipper /opt/conda/bin/eclipclipper

  touch /opt/done_with_clipper


  ##################################
  # SECOND ATTEMPT AT PIP PYBEDTOOLS
  ##################################
  /opt/conda/bin/pip uninstall --yes pybedtools
  /opt/conda/bin/pip install pybedtools


  ########################
  # CONDA EXPORT AND CLEAN
  /opt/conda/bin/conda env export \
    -n root > /opt/condaenv_root_`date +%Y-%m-%d-%H-%M`.yaml
  # cleanup 274 M
  /opt/conda/bin/conda clean --index-cache --tarballs --packages --yes

  touch /opt/done_with_conda_export_clean

  set +x

  #############################################################################

%environment

  if [ -z "$LD_LIBRARY_PATH" ]
  then
      LD_LIBRARY_PATH="/opt/conda/lib:/opt/patches/torque_usr_lib64:/opt/sdsc/lib"
  else
      LD_LIBRARY_PATH="/opt/conda/lib:/opt/patches/torque_usr_lib64:/opt/sdsc/lib:$LD_LIBRARY_PATH"
  fi
  export LD_LIBRARY_PATH

  PATH="/opt/conda/bin:$PATH"
  PATH="/opt/torque/bin:/opt/torque/sbin:$PATH"
  PATH="/opt/wf:/opt/cwl:$PATH"

  PATH="/opt/members/bin:$PATH"
  PATH="/opt/members/analyse:$PATH"
  PATH="/opt/members/normalize:$PATH"
  PATH="/opt/members/normalizepy:$PATH"
  PATH="/opt/members/annotate:$PATH"
  PATH="/opt/members/map:$PATH"  # TODO: keep this for STAR2, but in there mv STAR to STAR_OUT
  PATH="/opt/members/trim:$PATH"
  PATH="/opt/members/update:$PATH"
  PATH="/opt/members/eclipget:$PATH"
  PATH="/opt/members/rclone:$PATH"

  PATH="/opt/modules/eclipclipper/bin:$PATH"
  PATH="/opt/modules/eclipdemux:$PATH"
  PATH="/opt/modules/qcsummary:$PATH"
  PATH="/opt/modules/fastqtools:$PATH"
  PATH="/opt/modules/makebigwigfiles:$PATH"
  PATH="/opt/modules/maketrackhubs:$PATH"

  export PATH

  export RCLONE_HOME=/opt/members/rclone
  export RCLONE_CONFIG_GCLOUD_TYPE="google cloud storage"
  export RCLONE_CONFIG_GCLOUD_CLIENT_ID=
  export RCLONE_CONFIG_GCLOUD_CLIENT_SECRET=
  export RCLONE_CONFIG_GCLOUD_PROJECT_NUMBER=207049422273
  export RCLONE_CONFIG_GCLOUD_SERVICE_ACCOUNT_FILE=${RCLONE_HOME}/gcp_service_account_eliprefdownloader_Eclip-84f681496b46.json
  export RCLONE_CONFIG_GCLOUD_OBJECT_ACL=publicRead
  export RCLONE_CONFIG_GCLOUD_BUCKET_ACK=publicReadWrite


  ECLIP_DOCUMENTATION="/opt/documentation"
  export ECLIP_DOCUMENTATION

  HOSTIP=$(hostname -i)
  export HOSTIP

  alias echopathtr='echo $PATH | tr ":" "\n"'
  alias ll='ls -lhF'

 ##############################################################################

%labels

  MAINTAINER adomissy@ucsd.edu
  VERSION 0.1.6.99
  BUILD_DATE $(date -Ihours)

  #############################################################################

%files

  cwl                /opt/
  wf                 /opt/
  init               /opt/
  documentation      /opt/
  tests              /opt/

  #############################################################################

%runscript

  # this will get copied to /.singularity.d/runscript indide the container
  # which will run whenever the container is called as an executable

  set -o errexit
  set -o xtrace
  #set -o pipefail
  set -o nounset

  IDATE=$(date -Iseconds)
  # IDATE=$(date -Iseconds | tr "\:" "-" | tr "T" "+")

  IMAGENAME=eclip_${IDATE}_${SINGULARITY_NAME}
  mv ${SINGULARITY_NAME} ${IMAGENAME}
  ln -sf ${IMAGENAME} eclip.img

  cp /opt/patches/scripts/*    ./
  mv ./ecliprc              ./.ecliprc

  mkdir -p commands
  mv eclip ./commands
  cd commands
  ln -sf eclip eclipcwltool
  ln -sf eclip eclipcwltoil
  ln -sf eclip eclipcwltorq
  ln -sf eclip eclipgetreference
  ln -sf eclip eclipgetdataset
  ln -sf eclip eclipupdate
  cd -

  echo
  echo ======================
  echo please type:
  echo
  echo        source .ecliprc
  echo
  echo and enjoy eclip!
  echo ======================
  echo

  #if [ $# -eq 0 ]
  #then
  #    /opt/wf/eclip
  #else
  #    $1
  #fi

###############################################################################
%test

  # this will be run once upon completion of container building
  #/opt/test.sh
