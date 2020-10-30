FROM jupyter/minimal-notebook

# docker build -f sparql.Dockerfile -t ghcr.io/maastrichtu-ids/jupyterlab-on-openshift:sparql .

# docker run --rm -it --user $(id -u) -p 8888:8888 -e VIRTUAL_HOST=jup.137.120.31.102.nip.io -e JUPYTER_TOKEN=password -v $(pwd):/home/jovyan ghcr.io/maastrichtu-ids/jupyterlab-on-openshift:sparql

ENV JUPYTER_ENABLE_LAB=yes

RUN pip install --upgrade jupyterlab-git

# Install SPARQL kernel (pip install needs to be done as jovyan user)
RUN pip install sparqlkernel


# Change to root user to install things
USER root

RUN jupyter sparqlkernel install 

RUN git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it && \
  bash ~/.bash_it/install.sh --silent

# Install Java
RUN apt-get update -y && \
    apt-get install default-jdk curl -y

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
  apt-get upgrade -y && \
  apt-get install -y nodejs texlive-latex-extra texlive-xetex \
    ca-certificates build-essential \
    wget curl vim raptor2-utils && \
  rm -rf /var/lib/apt/lists/*


# Install Ijava kernel
RUN curl -L https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip > ijava-kernel.zip
RUN unzip ijava-kernel.zip -d ijava-kernel \
  && cd ijava-kernel \
  && python3 install.py --sys-prefix

# Install jupyter RISE extension (for IJava)
RUN pip install jupyter_contrib-nbextensions RISE \
  && jupyter-nbextension install rise --py --system \
  && jupyter-nbextension enable rise --py --system \
  && jupyter contrib nbextension install --system \
  && jupyter nbextension enable hide_input/main
RUN rm ijava-kernel.zip
RUN rm -rf ijava-kernel

# RUN python -m pip install --upgrade pip

RUN jupyter labextension install \
  @jupyter-widgets/jupyterlab-manager \
  @jupyterlab/git \
  nbdime-jupyterlab \
  @jupyterlab/latex \
  jupyterlab-drawio 
  # jupyterlab-plotly \
  # @bokeh/jupyter_bokeh \
  # @krassowski/jupyterlab-lsp \
  # jupyterlab-spreadsheet 

RUN jupyter lab build 

# RUN chown -R $NB_UID:$NB_UID /home/$NB_USER
# RUN chgrp -R 0 /home/$NB_USER && \
#     chmod -R g+rw /home/$NB_USER

# Download latest simpleowlapi jar in /opt/simpleowlapi.jar
# RUN wget -O /opt/simpleowlapi.jar https://github.com/kodymoodley/simpleowlapi/releases/download/v1.0.1/simpleowlapi-lib-1.0.1-jar-with-dependencies.jar
RUN curl -s https://api.github.com/repos/kodymoodley/simpleowlapi/releases/latest \
    | grep "browser_download_url.*-jar-with-dependencies.jar" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | wget -O /opt/simpleowlapi.jar -qi -


RUN fix-permissions /opt/simpleowlapi.jar && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

USER $NB_UID

# COPY config/ /home/$NB_USER/.jupyter/
