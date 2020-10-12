FROM jupyter/minimal-notebook

# docker build -f sparql.Dockerfile -t ghcr.io/maastrichtu-ids/jupyterlab-on-openshift:sparql .
# docker run --rm -it -p 8888:8888 -e VIRTUAL_HOST=jup.137.120.31.102.nip.io -e JUPYTER_TOKEN=password -v $(pwd):/home/jovyan ghcr.io/maastrichtu-ids/jupyterlab-on-openshift:sparql

# docker run --rm -it -e VIRTUAL_HOST=jup.137.120.31.102.nip.io -e JUPYTER_TOKEN=password -v $(pwd):/home/jovyan ghcr.io/maastrichtu-ids/jupyterlab-on-openshift:sparql

ENV JUPYTER_ENABLE_LAB=True
USER root

# RUN git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it && \
#   bash ~/.bash_it/install.sh --silent

# Install Java
RUN apt-get update -y && \
    apt-get install default-jdk curl -y

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
  apt-get upgrade -y && \
  apt-get install -y nodejs texlive-latex-extra texlive-xetex \
    ca-certificates build-essential \
    wget curl vim raptor2-utils && \
  rm -rf /var/lib/apt/lists/*


# Install SPARQL kernel
RUN pip install sparqlkernel
RUN jupyter sparqlkernel install

# Install Ijava kernel
RUN curl -L https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip > ijava-kernel.zip
RUN unzip ijava-kernel.zip -d ijava-kernel \
  && cd ijava-kernel \
  && python3 install.py --sys-prefix

# Install jupyter RISE extension (for IJava)
# RUN pip install jupyter_contrib-nbextensions RISE \
#   && jupyter-nbextension install rise --py --system \
#   && jupyter-nbextension enable rise --py --system \
#   && jupyter contrib nbextension install --system \
#   && jupyter nbextension enable hide_input/main
RUN rm ijava-kernel.zip
RUN rm -rf ijava-kernel

USER $NB_UID

# RUN python -m pip install --upgrade pip

# COPY requirements.txt .
# RUN pip install --upgrade -r requirements.txt

# RUN jupyter labextension install \
#   @jupyter-widgets/jupyterlab-manager \
#   @jupyterlab/latex \
#   jupyterlab-drawio \ 
#   jupyterlab-plotly \
#   @bokeh/jupyter_bokeh \
#   @krassowski/jupyterlab-lsp \
#   @jupyterlab/git \
#   jupyterlab-spreadsheet 

# COPY config/ /home/$NB_USER/.jupyter/
