ARG PYTHON_VERSION=python-3.8.8
ARG BASE_IMAGE=jupyter/scipy-notebook
FROM $BASE_IMAGE:$PYTHON_VERSION

LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab"

# APACHE_SPARK_VERSION=3.0.1 and HADOOP_VERSION=3.2
# APACHE_SPARK_VERSION=2.4.5 and HADOOP_VERSION=2.7 -> Requires python 3.7 and java 8
ARG APACHE_SPARK_VERSION=3.2.1
ARG HADOOP_VERSION=3.2
ENV APACHE_SPARK_VERSION=$APACHE_SPARK_VERSION \
    HADOOP_VERSION=$HADOOP_VERSION \
    JUPYTER_ENABLE_LAB=yes
    # GRANT_SUDO=yes
    # CHOWN_HOME=yes \
    # CHOWN_HOME_OPTS='-R'

RUN npm install --global yarn
# Enable yarn global add:
ENV PATH="$PATH:$HOME/.yarn/bin"

# Install jupyterlab extensions with conda and pip
# Multi conda kernels: #   https://stackoverflow.com/questions/53004311/how-to-add-conda-environment-to-jupyter-lab
RUN mamba install --quiet -y \
      openjdk=11 \
      maven \
      ipywidgets \
      ipython-sql \
      jupyterlab \
      jupyterlab-git \
      jupyterlab-lsp \
      jupyter-lsp-python \
      jupyter_bokeh \
      jupyterlab-drawio \
      rise \
      pyspark=$APACHE_SPARK_VERSION \
      nb_conda_kernels \
      'jupyter-server-proxy>=3.1.0' && \
    mamba install -y -c plotly 'plotly>=4.8.2'

    ## Install BeakerX kernels (requires python 3.7):
    # mamba install -y -c beakerx \
    #   beakerx_kernel_java \
    #   beakerx_kernel_scala

    ## Install RStudio:
    # mamba install -c defaults rstudio
    # mamba install -y -c defaults rstudio r-shiny
    #   rise && \ # Issue when building with GitHub Actions related to jedi package

RUN pip install --upgrade pip && \
    pip install --upgrade \
      sparqlkernel \
      mitosheet3 \
      jupyterlab-spreadsheet-editor \
      jupyterlab_latex \
      jupyterlab-github \
      jupyterlab_theme_solarized_dark \
    #   pyspark==$APACHE_SPARK_VERSION \
    #   nb-serverproxy-openrefine \ 
      git+https://github.com/innovationOUtside/nb_serverproxy_openrefine.git@main \
      jupyterlab-system-monitor

    ## Could also be interesting to install:
    #   jupyter-rsession-proxy \
    #   jupyter-shiny-proxy \
    #   @jupyterlab/server-proxy \
    #   elyra (pipeline builder for Kubeflow and Airflow)


# Change to root user to install things
USER root

RUN apt update && \
    apt install -y curl wget unzip zsh vim htop gfortran \
        python3-dev libpq-dev libclang-dev raptor2-utils

# Install SPARQL kernel
RUN jupyter sparqlkernel install 

# Install Java kernel
# RUN curl -L https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip > /opt/ijava-kernel.zip && \
RUN wget -O /opt/ijava-kernel.zip https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip && \
    unzip /opt/ijava-kernel.zip -d /opt/ijava-kernel && \
    cd /opt/ijava-kernel && \
    python install.py --sys-prefix && \
    rm /opt/ijava-kernel.zip

# Install VS Code server and extensions
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server --install-extension redhat.vscode-yaml \
        --install-extension ms-python.python \
        --install-extension vscjava.vscode-java-pack \
        --install-extension ginfuru.ginfuru-better-solarized-dark-theme \
        --install-extension oderwat.indent-rainbow \
        --install-extension mutantdino.resourcemonitor \
        --install-extension mechatroner.rainbow-csv \
        --install-extension GrapeCity.gc-excelviewer \
        --install-extension tht13.html-preview-vscode \
        --install-extension mdickin.markdown-shortcuts \
        --install-extension redhat.vscode-xml \
        --install-extension nickdemayo.vscode-json-editor \
        --install-extension ms-mssql.mssql \
        # --install-extension ms-azuretools.vscode-docker \
        --install-extension eamodio.gitlens 

RUN cd /opt && \
    export EXT_VERSION=0.1.2 && \
    wget https://open-vsx.org/api/vemonet/stardog-rdf-grammars/$EXT_VERSION/file/vemonet.stardog-rdf-grammars-$EXT_VERSION.vsix && \
    code-server --install-extension vemonet.stardog-rdf-grammars-$EXT_VERSION.vsix

## Not compatible with web yet: https://github.com/janisdd/vscode-edit-csv/issues/67
# RUN cd /opt && \
#     export EXT_VERSION=0.6.4 && \
#     wget https://github.com/janisdd/vscode-edit-csv/releases/download/v$EXT_VERSION/vscode-edit-csv-$EXT_VERSION.vsix && \
#     code-server --install-extension vscode-edit-csv-$EXT_VERSION.vsix


# Install open source gitpod VSCode? https://github.com/gitpod-io/openvscode-releases/blob/main/Dockerfile
# ENV OPENVSCODE_SERVER_ROOT=/opt/openvscode \
#     RELEASE_TAG=openvscode-server-v1.62.3
# ENV LANG=C.UTF-8 \
#     LC_ALL=C.UTF-8 \
#     EDITOR=code \
#     VISUAL=code \
#     GIT_EDITOR="code --wait" \
#     OPENVSCODE_SERVER_ROOT=${OPENVSCODE_SERVER_ROOT}
# RUN wget https://github.com/gitpod-io/openvscode-server/releases/download/${RELEASE_TAG}/${RELEASE_TAG}-linux-x64.tar.gz && \
#     tar -xzf ${RELEASE_TAG}-linux-x64.tar.gz && \
#     mv -f ${RELEASE_TAG}-linux-x64 ${OPENVSCODE_SERVER_ROOT} && \
#     rm -f ${RELEASE_TAG}-linux-x64.tar.gz

# Add JupyterLab and VSCode settings
COPY icons/*.svg /etc/jupyter/
COPY jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py

RUN fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    fix-permissions /home/$NB_USER/.local && \
    fix-permissions /opt && \
    fix-permissions /etc/jupyter


# Switch back to the notebook user to finish installation
USER ${NB_UID}

RUN mkdir -p ~/.jupyter/lab/user-settings/@jupyterlab/terminal-extension
# COPY --chown=$NB_USER:100 plugin.jupyterlab-settings /home/$NB_USER/.jupyter/lab/user-settings/@jupyterlab/terminal-extension/plugin.jupyterlab-settings
COPY themes.jupyterlab-settings /home/$NB_USER/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings
COPY settings.json /home/$NB_USER/.local/share/code-server/User/settings.json

RUN mkdir -p /home/$NB_USER/work

# Update and compile JupyterLab extensions
# RUN jupyter labextension update --all && \
#     jupyter lab build 

## Install Spark for standalone context in /opt
ENV SPARK_HOME=/opt/spark \
    SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx2048M --driver-java-options=-Dlog4j.logLevel=info"
ENV PATH=$PATH:$SPARK_HOME/bin
RUN wget -q -O spark.tgz https://archive.apache.org/dist/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    tar xzf spark.tgz -C /opt && \
    rm "spark.tgz" && \
    ln -s "/opt/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}" $SPARK_HOME


# Install OpenRefine
ENV OPENREFINE_VERSION=3.4.1
RUN cd /opt && \
    wget https://github.com/OpenRefine/OpenRefine/releases/download/$OPENREFINE_VERSION/openrefine-linux-$OPENREFINE_VERSION.tar.gz && \
    tar xzf openrefine-linux-$OPENREFINE_VERSION.tar.gz && \
    mv /opt/openrefine-$OPENREFINE_VERSION /opt/openrefine && \
    rm openrefine-linux-$OPENREFINE_VERSION.tar.gz
    # ln -s /opt/openrefine-$OPENREFINE_VERSION/refine /opt/refine 
ENV REFINE_DIR=/home/$NB_USER/openrefine
ENV PATH=$PATH:/opt/openrefine
RUN mkdir -p ~/openrefine


# Install Oh My ZSH! and custom theme
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN curl -fsSL -o ~/.oh-my-zsh/custom/themes/biratime.zsh-theme https://raw.github.com/vemonet/biratime/main/biratime.zsh-theme
RUN sed -i 's/^ZSH_THEME=".*"$/ZSH_THEME="biratime"/g' ~/.zshrc
RUN echo "\`conda config --set changeps1 false\`" >> ~/.oh-my-zsh/plugins/virtualenv/virtualenv.plugin.zsh
RUN echo 'setopt NO_HUP' >> ~/.zshrc
ENV SHELL=/bin/zsh

USER root
RUN chsh -s /bin/zsh 

ADD bin/* ~/.local/bin/
# ENV PATH=$PATH:/home/$NB_USER/.local/bin

# Git token will be stored in the persistent volume
RUN git config --global credential.helper 'store --file ~/.git-credentials' && \
    git config --global diff.colorMoved zebra && \
    git config --global fetch.prune true && \
    git config --global pull.rebase true


ENV WORKSPACE="/home/${NB_USER}/work"
ENV PERSISTENT_FOLDER="${WORKSPACE}/persistent"
RUN mkdir -p $PERSISTENT_FOLDER
WORKDIR ${WORKSPACE}
VOLUME [ "${PERSISTENT_FOLDER}" ]

ADD README.ipynb $WORKSPACE

CMD [ "start-notebook.sh", "--no-browser", "--ip=0.0.0.0", "--config=/etc/jupyter/jupyter_notebook_config.py" ]

# ENTRYPOINT [ "start-notebook.sh", "--no-browser", "--ip=0.0.0.0", "--config=/etc/jupyter/jupyter_notebook_config.py" ]
# ENTRYPOINT ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--config=/etc/jupyter/jupyter_notebook_config.py"]
