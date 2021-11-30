FROM ghcr.io/maastrichtu-ids/jupyterlab:latest

LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab"

ENV OPENBLAS_NUM_THREADS=1
# Restricting the number of thread allocated to OpenBLAS can speed up computations using OpenBLAS 
# Leave empty for default, e.g. 64 on DSRI

USER root

## https://github.com/jupyter/docker-stacks/blob/master/r-notebook/Dockerfile
# R pre-requisites
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    fonts-dejavu \
    unixodbc \
    unixodbc-dev \
    r-cran-rodbc \
    gfortran \
    gcc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
    # libxkbcommon libreadline might be required for RStudio

USER ${NB_UID}

# R packages including IRKernel which gets installed globally.
# r-e1071: dependency of the caret R package
RUN mamba install --quiet --yes \
    'r-base' \
    'r-caret' \
    'r-crayon' \
    'r-devtools' \
    'r-e1071' \
    'r-forecast' \
    'r-hexbin' \
    'r-htmltools' \
    'r-htmlwidgets' \
    'r-irkernel' \
    'r-nycflights13' \
    'r-randomforest' \
    'r-rcurl' \
    'r-rodbc' \
    'r-rsqlite' \
    'r-shiny' \
    'unixodbc' && \
    mamba install -c defaults rstudio && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# # Install RStudio
# RUN apt-get install -y r-base \
#         libxkbcommon-x11-dev libreadline-dev libqt5gui5 \
#         libapparmor1 libgc1c2 libclang-dev \
#         libcurl4-openssl-dev libedit2 libobjc4 libssl-dev \
#         libpq5 lsb-release psmisc procps
# RUN export DOWNLOAD_VERSION=$(wget -qO - https://rstudio.com/products/rstudio/download-server/debian-ubuntu/ | grep -oP "(?<=rstudio-server-)[0-9]+\.[0-9]+\.[0-9]+-[0-9]+" -m 1) && \
#     export RSTUDIO_URL="https://download2.rstudio.org/server/bionic/amd64/rstudio-server-${DOWNLOAD_VERSION}-amd64.deb" && \
#     wget $RSTUDIO_URL && \
#     dpkg -i rstudio-server-*-amd64.deb && \
#     rm rstudio-server-*-amd64.deb

# Install Jupyter proxy for RStudio
RUN pip install --upgrade pip && \
    pip install --upgrade \
      jupyter-rsession-proxy \
      jupyter-shiny-proxy


# RUN fix-permissions $CONDA_DIR && \
#     # fix-permissions /home/$NB_USER && \
#     fix-permissions /opt

