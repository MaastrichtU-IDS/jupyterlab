FROM jupyter/scipy-notebook
# FROM jupyter/scipy-notebook:python-3.8.8
# Using 3.8 because some scientific libraries still dont support 3.9

LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab"

# https://quay.io/repository/guimou/s2i-generic-datascience-lmod-notebook/manifest/sha256:4329da31f6ef918b1f3878b037c7517cb72511bf1fcbb632b50dcd5cd0802715
# https://github.com/guimou/s2i-lmod-notebook/blob/main/f34/Dockerfile

ENV JUPYTER_ENABLE_LAB=yes

# RUN npm install --global yarn 

# Install jupyterlab extensions
RUN conda install --quiet -y \
      ipywidgets \
      jupyterlab \
      jupyterlab-git \
      jupyterlab-lsp \
      jupyter-lsp-python \
      jupyter-server-proxy==3.1.0 \
      jupyter_bokeh \
      jupyterlab-drawio && \
      # rise && \ # Issue when building with GitHub Actions related to jedi package
    conda install -c plotly 'plotly>=4.8.2' 
    # fix-permissions $CONDA_DIR && \
    # fix-permissions /home/$NB_USER

RUN pip install --upgrade pip && \
    pip install --upgrade \
    #   sparqlkernel \
      # elyra \
      # Pipeline builder for Kubeflow and Airflow
      jupyterlab-system-monitor && \
    jupyter labextension install jupyterlab-spreadsheet


# Change to root user to install Lmod dependencies
USER root

# Install Lua for Lmod
RUN apt-get update && \
    apt-get install -y lua5.3 \
        lua-bit32:amd64 lua-posix:amd64 lua-posix-dev \
        liblua5.3-0:amd64 liblua5.3-dev:amd64 \
        tcl tcl-dev tcl8.6 tcl8.6-dev:amd64 libtcl8.6:amd64 \
        ant python-keyring \
        rdma-core \
        curl wget

RUN mkdir -p /build

RUN fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    fix-permissions /opt && \
    fix-permissions /build

USER $NB_USER

# Install Lmod
# Fix required for rstudio permissions
ENV USER=rstudio-server \ 
    # TODO: Path to modules can be added here
    MODULEPATH=/opt/apps/easybuild/modules/all:/opt/apps/modulefiles/Linux:/opt/apps/modulefiles/Core:/opt/apps/lmod/lmod/modulefiles/Core \
    MODULEPATH_ROOT=/opt/apps/modulefiles \
    # MODULEPATH_ROOT=/opt/apps/lmod/lmod/modulefiles \
    MODULESHOME=/opt/apps/lmod/lmod \
    MANPATH=/opt/apps/lmod/lmod/share/man: \
    LMOD_DIR=/opt/apps/lmod/lmod/libexec \
    LMOD_SETTARG_FULL_SUPPORT=no \
    LMOD_PACKAGE_PATH=/opt/apps/easybuild/ \
    LMOD_VERSION=8.5.9 \
    LMOD_ROOT=/opt/apps/lmod \
    LMOD_sys=Linux \
    LMOD_CMD=/opt/apps/lmod/lmod/libexec/lmod

RUN mkdir -p /opt/apps
WORKDIR /build
RUN curl -LO http://github.com/TACC/Lmod/archive/${LMOD_VERSION}.tar.gz && \
    mv /build/${LMOD_VERSION}.tar.gz /build/Lmod-${LMOD_VERSION}.tar.gz && \
    tar xvf Lmod-${LMOD_VERSION}.tar.gz

WORKDIR /build/Lmod-$LMOD_VERSION

RUN ./configure --prefix=/opt/apps --with-fastTCLInterp=no && \
    make install

USER root
RUN rm -rf /build && \
    ln -s /opt/apps/lmod/lmod/init/profile /etc/profile.d/z00_lmod.sh
USER $NB_USER


# Install Lmod jupyter extension
RUN pip install jupyterlmod==2.0.2 && \
    jupyter labextension install jupyterlab-lmod \
        @jupyterlab/server-proxy

# Install jupyterlmodlauncher fix from odh-highlander (launchers showing, but icons logo broken)
# RUN pip install git+https://github.com/guimou/s2i-lmod-notebook/#subdirectory=packages/jupyterlmodlauncher



RUN jupyter labextension update --all && \
    jupyter lab build 

RUN mkdir -p /home/$NB_USER/work
WORKDIR /home/$NB_USER/work

ADD jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py

ENTRYPOINT [ "start-notebook.sh", "--no-browser", "--ip=0.0.0.0", "--config=/etc/jupyter/jupyter_notebook_config.py" ]