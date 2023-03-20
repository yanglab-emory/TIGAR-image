FROM amazonlinux:2.0.20221004.0

ENV TABIX_VERSION="0.2.6"
ENV TABIX_CHECKSUM="4f0cac0da585abddc222956cac1b6e508ca1c49e"
ENV PLINK_VERSION="linux_x86_64_20230116"

ENV PYTHON_VERSION="3.7.15"
ENV PYTHON_CHECKSUM="beff0cd66129ad1761632aafd72ac866"
# ENV PYTHON_VERSION="3.9.6"
# ENV PYTHON_CHECKSUM="798b9d3e866e1906f6e32203c4c560fa"
ENV APPUSER="appuser"

# Install packages
RUN yum -y update &&\
    yum install -y bzip2 bzip2-libs findutils gcc git \
      gzip libffi-devel make openssl-devel python3-pip \
      readline-devel shadow-utils sqlite-devel tar unzip \
      util-linux which zlib-devel && \
    yum -y autoremove && \
    rm -rf /var/cache/yum && \
    yum clean all

# Add group, user; user directories
RUN groupadd --gid 9999 ${APPUSER} && \
  useradd -g ${APPUSER} -m ${APPUSER} && \
  mkdir -p /home/${APPUSER}/bin /home/${APPUSER}/.local/bin

# Set working directory
WORKDIR /home/${APPUSER}

# # Update PATH
ENV PATH="$PATH:/home/${APPUSER}/bin/:/home/${APPUSER}/.local/bin/:/root/.local/bin"

# Install Python
ADD https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz /home/${APPUSER}/
RUN echo "${PYTHON_CHECKSUM} Python-${PYTHON_VERSION}.tgz" | md5sum --check && \
  tar -xzf Python-${PYTHON_VERSION}.tgz && \
  cd Python-${PYTHON_VERSION} && \
  ./configure --enable-optimizations && make && make altinstall && \
  rm -rf /home/${APPUSER}/Python-${PYTHON_VERSION}* && \
  cd /home/${APPUSER}

# Copy Python package requirements from Docker client directory to image
COPY requirements.txt .

# Upgrade pip
RUN python3.7 -m pip install --upgrade pip setuptools wheel

# Install Python packages
RUN python3.7 -m pip install -r requirements.txt
RUN python3.7 -m pip install numpy --upgrade

# Update paths
ENV PYTHONPATH="$PYTHONPATH:/usr/local/lib/python3.7/site-packages/:/root/.local/lib/python3.7/site-packages"
ENV PATH="$PATH:/home/${APPUSER}/TIGAR:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

# Install Tabix
RUN curl -kLO https://sourceforge.net/projects/samtools/files/tabix/tabix-${TABIX_VERSION}.tar.bz2 && \
  echo "${TABIX_CHECKSUM} tabix-${TABIX_VERSION}.tar.bz2" | sha1sum --check && \
  tar -xvf tabix-${TABIX_VERSION}.tar.bz2 && \
  cd tabix-${TABIX_VERSION} && \
  make && \
  cp bgzip tabix /home/${APPUSER}/bin/ && \
  rm -rf /home/${APPUSER}/tabix-${TABIX_VERSION}* && \
  cd /home/${APPUSER}

# Install Plink
## plink 1.07, harvard
# ENV PLINK_VERSION="1.07-x86_64"
# ADD https://zzz.bwh.harvard.edu/plink/dist/plink-${PLINK_VERSION}.zip /home/${APPUSER}/
# RUN unzip plink-${PLINK_VERSION}.zip && \
#   cp plink-${PLINK_VERSION}/plink /home/${APPUSER}/bin/ && \
#   rm -rf /home/${APPUSER}/plink-${PLINK_VERSION}* && \
#   cd /home/${APPUSER}
ADD https://s3.amazonaws.com/plink1-assets/plink_${PLINK_VERSION}.zip /home/${APPUSER}/
RUN unzip plink_${PLINK_VERSION}.zip -d plink_${PLINK_VERSION} && \
  cp plink_${PLINK_VERSION}/plink /home/${APPUSER}/bin/ && \
  rm -rf /home/${APPUSER}/plink_${PLINK_VERSION}* && \
  cd /home/${APPUSER}


# Switch to user
USER ${APPUSER}

# Add TIGAR to image
# Following line prevents Docker from using cache if there are newer commits to docker branch
ADD "https://api.github.com/repos/yanglab-emory/TIGAR/commits?per_page=1,sha=docker" latest_commit
RUN git clone --branch docker https://github.com/yanglab-emory/TIGAR.git

# Add volume for output/input
RUN mkdir -p VOLUME

# Set arguments
ENV TIGAR_dir=/home/${APPUSER}/TIGAR
ENV in_dir=/home/${APPUSER}/VOLUME
ENV out_dir=/home/${APPUSER}/VOLUME/OUTPUT

# Set working directory
WORKDIR /home/${APPUSER}/TIGAR
