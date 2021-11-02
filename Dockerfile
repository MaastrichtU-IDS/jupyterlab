ARG PYTHON_VERSION=python-3.8.8
# ARG PYTHON_VERSION=latest
FROM jupyter/scipy-notebook:$PYTHON_VERSION

LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab"

ENV JUPYTER_ENABLE_LAB=yes \
    GRANT_SUDO=yes
    # CHOWN_HOME=yes \
    # CHOWN_HOME_OPTS='-R' \

RUN npm install --global yarn 

# Install jupyterlab extensions with conda and pip
RUN conda install --quiet -y \
      openjdk maven \
      ipywidgets \
      jupyterlab \
      jupyterlab-git \
      jupyterlab-lsp \
      jupyter-lsp-python \
      jupyter_bokeh \
      jupyterlab-drawio \
      'jupyter-server-proxy>=3.1.0' && \
    conda install -y -c plotly 'plotly>=4.8.2'
    # mamba install -c defaults rstudio
    # conda install -y -c defaults rstudio r-shiny
    #   rise && \ # Issue when building with GitHub Actions related to jedi package

RUN pip install --upgrade pip && \
    pip install --upgrade \
      sparqlkernel \
      mitosheet3 \
      jupyterlab-spreadsheet-editor \
      jupyterlab_latex \
    #   jupyter-rsession-proxy \
    #   jupyter-shiny-proxy \
    #   nb-serverproxy-openrefine \
      git+https://github.com/vemonet/nb_serverproxy_openrefine.git \
      jupyterlab-system-monitor 
#   @jupyterlab/server-proxy \
# elyra : Pipeline builder for Kubeflow and Airflow

# Change to root user to install things
USER root

RUN apt-get update && \
    apt-get install -y curl zsh vim
    # libxkbcommon and libreadline required for RStudio

# Install SPARQL kernel
RUN jupyter sparqlkernel install 


# Install Ijava kernel
RUN curl -L https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip > /opt/ijava-kernel.zip && \
    unzip /opt/ijava-kernel.zip -d /opt/ijava-kernel && \
    cd /opt/ijava-kernel && \
    python3 install.py --sys-prefix && \
    rm /opt/ijava-kernel.zip


# Install VS Code server
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server --install-extension redhat.vscode-yaml \
        --install-extension ms-python.python \
        --install-extension vscjava.vscode-java-pack \
        --install-extension ginfuru.ginfuru-better-solarized-dark-theme

COPY --chown=$NB_USER:0 settings.json /home/$NB_USER/.local/share/code-server/User/settings.json
COPY icons/*.svg /etc/jupyter/



RUN fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    fix-permissions /opt

ADD jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py


USER $NB_USER


# Update and compile JupyterLab extensions
RUN jupyter labextension update --all && \
    jupyter lab build 

# Install packages for RDF processing
ADD requirements.txt requirements.txt
RUN pip install -r requirements.txt && \
    rm requirements.txt

# Add jar files in /opt for RDF processing
RUN npm i -g @rmlio/yarrrml-parser && \
    wget -q -O /opt/rmlmapper.jar https://github.com/RMLio/rmlmapper-java/releases/download/v4.11.0/rmlmapper.jar && \
    wget -q -O /opt/widoco.jar https://github.com/dgarijo/Widoco/releases/download/v1.4.15/widoco-1.4.15-jar-with-dependencies.jar && \
    wget -q -O /opt/limes.jar https://github.com/dice-group/LIMES/releases/download/1.7.5/limes.jar && \
    wget -q -O /opt/amie3.jar https://github.com/lajus/amie/releases/download/3.0/amie-milestone-intKB.jar && \
    wget -q -O /opt/shaclconvert.jar https://gitlab.ontotext.com/yasen.marinov/shaclconvert/-/raw/master/built/shaclconvert.jar

RUN cd /opt && \
    wget -q https://repo1.maven.org/maven2/commons-io/commons-io/2.11.0/commons-io-2.11.0.jar && \
    wget -q https://downloads.apache.org/jena/binaries/apache-jena-4.2.0.tar.gz && \
    wget -q http://download.eclipse.org/rdf4j/eclipse-rdf4j-3.7.3-onejar.jar 


# Install OpenRefine
ENV OPENREFINE_VERSION=3.4.1
RUN cd /opt && \
    wget https://github.com/OpenRefine/OpenRefine/releases/download/$OPENREFINE_VERSION/openrefine-linux-$OPENREFINE_VERSION.tar.gz && \
    tar xzf openrefine-linux-$OPENREFINE_VERSION.tar.gz && \
    mv /opt/openrefine-$OPENREFINE_VERSION /opt/openrefine && \
    rm openrefine-linux-$OPENREFINE_VERSION.tar.gz
    # ln -s /opt/openrefine-$OPENREFINE_VERSION/refine /opt/refine 
ENV REFINE_DIR=/home/$NB_USER/work/openrefine
ENV PATH=$PATH:/opt/openrefine:/opt/nanobench


# Install Nanobench
ENV NANOBENCH_VERSION=1.37
RUN mkdir -p /opt/nanobench && cd /opt/nanobench && \
    wget https://github.com/peta-pico/nanobench/releases/download/nanobench-$NANOBENCH_VERSION/nanobench-$NANOBENCH_VERSION.zip && \
    unzip nanobench-$NANOBENCH_VERSION.zip




RUN mkdir -p /home/$NB_USER/work
WORKDIR /home/$NB_USER/work

# Download latest simpleowlapi jar in /opt/simpleowlapi.jar
RUN curl -s https://api.github.com/repos/kodymoodley/simpleowlapi/releases/latest \
    | grep "browser_download_url.*-jar-with-dependencies.jar" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | wget -O /opt/simpleowlapi.jar -qi -



# Install ZSH
RUN sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
RUN wget -O ~/.oh-my-zsh/custom/themes/vemonet_bira.zsh-theme https://raw.githubusercontent.com/vemonet/zsh-theme-biradate/master/zsh/vemonet_bira.zsh-theme
RUN sed -i 's/robbyrussell/vemonet_bira/g' ~/.zshrc
ENV SHELL=/bin/zsh
USER root
RUN chsh -s /bin/zsh 
USER $NB_USER

# Nicer Bash terminal
# RUN git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it && \
#     bash ~/.bash_it/install.sh --silent


ENTRYPOINT [ "start-notebook.sh", "--no-browser", "--ip=0.0.0.0", "--config=/etc/jupyter/jupyter_notebook_config.py" ]