FROM ghcr.io/maastrichtu-ids/jupyterlab:r-notebook

LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab"

# Restricting the number of thread allocated to OpenBLAS can speed up computations using OpenBLAS 
# Leave empty for default, e.g. 64 on DSRI
ENV OPENBLAS_NUM_THREADS=1 \
    DISABLE_AUTH=true
    # ROOT= TRUE

# USER root
# ## https://github.com/jupyter/docker-stacks/blob/master/r-notebook/Dockerfile
# # R pre-requisites
# RUN apt-get update --yes && \
#     apt-get install --yes --no-install-recommends \
#     fonts-dejavu \
#     unixodbc \
#     unixodbc-dev \
#     r-cran-rodbc \
#     gfortran \
#     gcc && \
#     apt-get clean && rm -rf /var/lib/apt/lists/*
#     # libxkbcommon libreadline might be required for RStudio

USER root

## Install RStudio manually
# RUN apt-get install -y \
#         libxkbcommon-x11-dev libreadline-dev libqt5gui5 \
#         libapparmor1 libgc1c2 procps \
#         libcurl4-openssl-dev libedit2 libobjc4 libssl-dev \
RUN apt-get update && \
    apt-get install -y libclang-dev psmisc libpq5 lsb-release
    # apt-get install -y gdebi-core 

## Get latest version:
# RUN export DOWNLOAD_VERSION=$(wget -qO - https://rstudio.com/products/rstudio/download-server/debian-ubuntu/ | grep -oP "(?<=rstudio-server-)[0-9]+\.[0-9]+\.[0-9]+-[0-9]+" -m 1) && \

# Dockerfile: https://github.com/rocker-org/rocker-versioned/blob/master/rstudio/3.6.3.Dockerfile
RUN export DOWNLOAD_VERSION=2021.09.1-372 && \
    wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-${DOWNLOAD_VERSION}-amd64.deb && \
    # gdebi rstudio-server-$DOWNLOAD_VERSION-amd64.deb && \
    dpkg -i rstudio-server-*-amd64.deb && \
    # apt-get install -y ./rstudio-server-*-amd64.deb && \
    rm rstudio-server-*-amd64.deb
# ENV PATH=$PATH:/usr/lib/rstudio-server/bin
USER ${NB_UID}

# Install RStudio with conda
# RUN conda install -c defaults rstudio

# Install Jupyter proxy for RStudio
RUN pip install --upgrade pip && \
    pip install --upgrade \
      jupyter-rsession-proxy \
      # jupyter-rsession-proxy>=2.0.1 \
      jupyter-shiny-proxy


# RUN fix-permissions $CONDA_DIR && \
#     # fix-permissions /home/$NB_USER && \
#     fix-permissions /opt

