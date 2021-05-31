FROM jupyter/scipy-notebook:latest

LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab"

ENV JUPYTER_ENABLE_LAB=yes

RUN npm install --global yarn

# Install jupyterlab extensions
RUN conda install --quiet --yes \
      ipywidgets \
      jupyterlab-lsp \
      jupyter-lsp-python \
      jupyter_bokeh \
      jupyterlab-drawio && \
      # rise && \ # Issue when building with GitHub Actions related to jedi package
    conda install -c plotly 'plotly>=4.8.2' 
    # fix-permissions $CONDA_DIR && \
    # fix-permissions /home/$NB_USER


RUN pip install --upgrade pip && \
    pip install --upgrade \
      sparqlkernel  \
      jupyterlab-system-monitor && \
    jupyter labextension install jupyterlab-spreadsheet

# Install fail for jupyterlab-git 
# Issues with versions not matching between the JS and python
# https://github.com/jupyterlab/jupyterlab-git

# @jupyterlab/latex not officialy supporting 3.0 yet

# Change to root user to install things
USER root

# Install SPARQL kernel
RUN jupyter sparqlkernel install 

# Install Java
RUN apt-get update && \
    apt-get install default-jdk curl -y

# Install Ijava kernel
RUN curl -L https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip > /opt/ijava-kernel.zip && \
  unzip /opt/ijava-kernel.zip -d /opt/ijava-kernel && \
  cd /opt/ijava-kernel && \
  python3 install.py --sys-prefix && \
  rm /opt/ijava-kernel.zip

# Nicer Bash terminal
RUN git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it && \
    bash ~/.bash_it/install.sh --silent


RUN fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

USER $NB_USER

RUN jupyter labextension update --all && \
    jupyter lab build 