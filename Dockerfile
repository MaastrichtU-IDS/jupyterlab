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
      sparqlkernel \
      ontospy \
      # elyra \
      # Pipeline builder for Kubeflow and Airflow
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
    fix-permissions /home/$NB_USER && \
    fix-permissions /opt

USER $NB_USER

RUN jupyter labextension update --all && \
    jupyter lab build 

# Add jar files for RDF handling in /opt
RUN wget -q -O /opt/rmlmapper.jar https://github.com/RMLio/rmlmapper-java/releases/download/v4.11.0/rmlmapper.jar && \
    npm i -g @rmlio/yarrrml-parser && \
    wget -q -O /opt/widoco.jar https://github.com/dgarijo/Widoco/releases/download/v1.4.15/widoco-1.4.15-jar-with-dependencies.jar && \
    wget -q -O /opt/limes.jar https://github.com/dice-group/LIMES/releases/download/1.7.5/limes.jar && \
    wget -q -O /opt/amie3.jar https://github.com/lajus/amie/releases/download/3.0/amie-milestone-intKB.jar && \
    wget -q -O /opt/apache-jena.tar.gz https://ftp.wayne.edu/apache/jena/binaries/apache-jena-4.1.0.tar.gz && \
    tar -xf /opt/apache-jena.tar.gz



# Download latest simpleowlapi jar in /opt/simpleowlapi.jar
# RUN wget -O /opt/simpleowlapi.jar https://github.com/kodymoodley/simpleowlapi/releases/download/v1.0.1/simpleowlapi-lib-1.0.1-jar-with-dependencies.jar
RUN curl -s https://api.github.com/repos/kodymoodley/simpleowlapi/releases/latest \
    | grep "browser_download_url.*-jar-with-dependencies.jar" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | wget -O /opt/simpleowlapi.jar -qi -
