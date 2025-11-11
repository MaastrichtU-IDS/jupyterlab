# Built with https://github.com/ReproNim/neurodocker
FROM condaforge/mambaforge

LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab"

USER root

ARG DEBIAN_FRONTEND="noninteractive"

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    ND_ENTRYPOINT="/neurodocker/startup.sh"

# Copy the local FreeSurfer .deb file
COPY freesurfer_ubuntu20-8.1.0_amd64.deb /tmp/freesurfer.deb

RUN export ND_ENTRYPOINT="/neurodocker/startup.sh" \
    && apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           apt-utils \
           bzip2 \
           ca-certificates \
           curl \
           locales \
           unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG="en_US.UTF-8" \
    && chmod 777 /opt && chmod a+s /opt \
    && mkdir -p /neurodocker \
    && if [ ! -f "$ND_ENTRYPOINT" ]; then \
         echo '#!/usr/bin/env bash' >> "$ND_ENTRYPOINT" \
    &&   echo 'set -e' >> "$ND_ENTRYPOINT" \
    &&   echo 'export USER="${USER:=`whoami`}"' >> "$ND_ENTRYPOINT" \
    &&   echo 'if [ -n "$1" ]; then "$@"; else /usr/bin/env bash; fi' >> "$ND_ENTRYPOINT"; \
    fi \
    && chmod -R 777 /neurodocker && chmod a+s /neurodocker

# Install FreeSurfer 8.1.0 from .deb package
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           bc \
           libgomp1 \
           libxmu6 \
           libxt6 \
           perl \
           tcsh \
    && echo "Installing FreeSurfer 8.1.0 for Ubuntu 20.04..." \
    && apt-get install -y /tmp/freesurfer.deb \
    && rm /tmp/freesurfer.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Update environment variables for FreeSurfer 8.1.0 (installed at /usr/local/freesurfer/8.1.0)
ENV FREESURFER_HOME="/usr/local/freesurfer/8.1.0" \
    PATH="/usr/local/freesurfer/8.1.0/bin:$PATH"

# Source FreeSurfer setup in entrypoint and bashrc
RUN sed -i '$isource "$FREESURFER_HOME/SetUpFreeSurfer.sh"' "$ND_ENTRYPOINT" \
    && echo "source ${FREESURFER_HOME}/SetUpFreeSurfer.sh" >> /root/.bashrc

RUN echo '{ \
    \n  "pkg_manager": "apt", \
    \n  "instructions": [ \
    \n    [ \
    \n      "base", \
    \n      "condaforge/mambaforge" \
    \n    ], \
    \n    [ \
    \n      "freesurfer", \
    \n      { \
    \n        "version": "8.1.0" \
    \n      } \
    \n    ] \
    \n  ] \
    \n}' > /neurodocker/neurodocker_specs.json

# Install JupyterLab
RUN conda install --quiet -y \
        notebook \
        jupyterlab \
        jupyterlab-lsp jupyter-lsp-python \
    && conda clean -afy

EXPOSE 8888
ENTRYPOINT ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser"]