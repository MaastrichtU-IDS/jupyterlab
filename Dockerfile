FROM jupyter/scipy-notebook:latest

ENV JUPYTER_ENABLE_LAB=yes

RUN npm install --global yarn

# Install jupyterlab autocomplete extensions
RUN conda install --quiet --yes \
    ipywidgets \
    jupyterlab-lsp \
    jupyter-lsp-python \
    jupyterlab-git \
    rise && \
  fix-permissions $CONDA_DIR && \
  fix-permissions /home/$NB_USER

RUN pip install --upgrade pip && \
    pip install --upgrade \
      sparqlkernel
      ## Issue with jupyterlab git and jupyterlab 3.0
      # jupyterlab-git \

# Change to root user to install things
USER root

# # Install SPARQL kernel
RUN jupyter sparqlkernel install 

# Install Java
RUN apt-get update && \
    apt-get install default-jdk curl -y

# Nicer Bash terminal
RUN git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it && \
    bash ~/.bash_it/install.sh --silent

# Install Ijava kernel
RUN curl -L https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip > /opt/ijava-kernel.zip
RUN unzip /opt/ijava-kernel.zip -d /opt/ijava-kernel && \
  cd /opt/ijava-kernel && \
  python3 install.py --sys-prefix && \
  rm /opt/ijava-kernel.zip

RUN fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

USER $NB_USER

RUN jupyter labextension update --all
RUN jupyter lab build 