# FROM ghcr.io/maastrichtu-ids/jupyterlab:latest
# FROM ghcr.io/maastrichtu-ids/jupyterlab:r-notebook
FROM rocker/binder:4.1.2

LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab"

# Restricting the number of thread allocated to OpenBLAS can speed up computations using OpenBLAS 
# Leave empty for default, e.g. 64 on DSRI
ENV OPENBLAS_NUM_THREADS=1 \
    DISABLE_AUTH=true
    # ROOT= TRUE

## Declares build arguments
ARG NB_USER
ARG NB_UID

COPY --chown=${NB_USER} . ${HOME}

ENV DEBIAN_FRONTEND=noninteractive
USER root
RUN echo "Checking for 'apt.txt'..." \
        ; if test -f "apt.txt" ; then \
        apt-get update --fix-missing > /dev/null\
        && xargs -a apt.txt apt-get install --yes \
        && apt-get clean > /dev/null \
        && rm -rf /var/lib/apt/lists/* \
        ; fi
USER ${NB_USER}

## Run an install.R script, if it exists.
RUN if [ -f install.R ]; then R --quiet -f install.R; fi



# RUN mamba install -y -c conda-forge r-base r-essentials
# RUN mamba update --all -y
# RUN mamba install -y -c r rstudio
# RUN mamba install -y -c conda-forge jupyter-rsession-proxy





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

# USER root

# ## Install RStudio manually
# # RUN apt-get install -y \
# #         libxkbcommon-x11-dev libreadline-dev libqt5gui5 \
# #         libapparmor1 libgc1c2 procps \
# #         libcurl4-openssl-dev libedit2 libobjc4 libssl-dev \
# RUN apt-get update && \
#     apt-get install -y libclang-dev psmisc libpq5 lsb-release libapparmor1
#     # apt-get install -y gdebi-core 

# ## Get latest version:
# # RUN export DOWNLOAD_VERSION=$(wget -qO - https://rstudio.com/products/rstudio/download-server/debian-ubuntu/ | grep -oP "(?<=rstudio-server-)[0-9]+\.[0-9]+\.[0-9]+-[0-9]+" -m 1) && \
# # Dockerfile: https://github.com/rocker-org/rocker-versioned/blob/master/rstudio/3.6.3.Dockerfile

# ## RStudio 1.4 not working: https://github.com/rstudio/rstudio/issues/8888
# # RUN export DOWNLOAD_VERSION=2021.09.1-372 && \
# RUN export DOWNLOAD_VERSION=1.3.1093 && \
#     wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-${DOWNLOAD_VERSION}-amd64.deb && \
#     # gdebi rstudio-server-$DOWNLOAD_VERSION-amd64.deb && \
#     dpkg -i rstudio-server-*-amd64.deb && \
#     # apt-get install -y ./rstudio-server-*-amd64.deb && \
#     rm rstudio-server-*-amd64.deb
# # ENV PATH=$PATH:/usr/lib/rstudio-server/bin
# USER ${NB_UID}

# # Install RStudio with conda
# # RUN conda install -c defaults rstudio

# # Install Jupyter proxy for RStudio
# RUN pip install --upgrade pip && \
#     pip install --upgrade \
#       git+https://github.com/vemonet/jupyter-rsession-proxy@master \
#     #   jupyter-rsession-proxy \
#       # jupyter-rsession-proxy>=2.0.1 \
#       jupyter-shiny-proxy


# RUN fix-permissions $CONDA_DIR && \
#     # fix-permissions /home/$NB_USER && \
#     fix-permissions /opt

