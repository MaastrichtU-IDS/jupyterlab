ARG LAB_VERSION=lab-4.5.1
ARG BASE_IMAGE=quay.io/jupyter/scipy-notebook
FROM $BASE_IMAGE:$LAB_VERSION

LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab"

ENV TZ=Europe/Amsterdam \
    JUPYTER_ENABLE_LAB=yes \
    PYTHONUNBUFFERED=1 \
    OPENBLAS_NUM_THREADS=1
    # GRANT_SUDO=yes \
    # CHOWN_HOME=yes \
    # CHOWN_HOME_OPTS='-R'

USER root
 
RUN apt-get update && \
    apt-get install -y tzdata curl wget unzip bzip2 vim htop gfortran \
        python3-dev libpq-dev libclang-dev \
        openjdk-11-jdk maven \
        r-base r-base-dev

# Install extensions for JupyterLab with pip
RUN pip install --no-cache-dir --root-user-action=ignore --upgrade pip && \
    pip install --no-cache-dir --root-user-action=ignore --upgrade \
      'jupyter-server-proxy>=4.4.0' \
      jupyterlab-git \
      ipython-sql \
      jupyterlab-lsp \
      python-lsp-server \
      jupyterlab-spreadsheet-editor \
      jupyterlab_latex 

# Install Java kernel
# https://www.javaspring.net/blog/java-jupyter-notebook/ & https://github.com/SpencerPark/IJava
RUN wget -O /opt/ijava-kernel.zip https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip && \
    unzip /opt/ijava-kernel.zip -d /opt/ijava-kernel && \
    cd /opt/ijava-kernel && \
    python install.py --sys-prefix && \
    rm /opt/ijava-kernel.zip

# Install R kernel with some common packages
RUN R -e "install.packages(c('IRkernel', 'tidyverse', 'ggplot2', 'dplyr', 'readr', 'data.table'), repos='https://cloud.r-project.org/')" && \
    R -e "IRkernel::installspec(user = FALSE)"

# Install VS Code server and extensions
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server --install-extension redhat.vscode-yaml \
        --install-extension ms-python.python \
        --install-extension anwar.resourcemonitor \
        --install-extension rintoj.json-organizer \
        --install-extension zaaack.markdown-editor \
        --install-extension garlicbreadcleric.document-preview \
        --install-extension bungcip.better-toml \
        --install-extension vscjava.vscode-java-pack \
        --install-extension ginfuru.ginfuru-better-solarized-dark-theme \
        --install-extension oderwat.indent-rainbow \
        --install-extension mechatroner.rainbow-csv \
        --install-extension GrapeCity.gc-excelviewer \
        --install-extension yzhang.markdown-all-in-one \
        --install-extension redhat.vscode-xml \
        --install-extension ms-mssql.mssql \
        --install-extension eamodio.gitlens

# Install oc, kubectl and Helm
RUN cd /tmp && \
    wget https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz && \
    tar xvf oc.tar.gz && \
    mv oc kubectl /usr/local/bin/ && \
    wget https://get.helm.sh/helm-v4.0.4-linux-amd64.tar.gz && \
    tar xvf helm-v4.0.4-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/

# Add JupyterLab and VSCode settings globally
COPY icons/*.svg /etc/jupyter/
COPY base/jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py

RUN fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    fix-permissions /home/$NB_USER/.local && \
    fix-permissions /opt && \
    fix-permissions /etc/jupyter

# Switch back to the notebook user to finish installation
USER ${NB_UID}

# Add user config files for JupyterLab and VSCode
COPY base/settings.json /home/$NB_USER/.local/share/code-server/User/settings.json

RUN mkdir -p /home/$NB_USER/work

# Add some local scripts/shortcuts
ADD bin/* ~/.local/bin/

ENV WORKSPACE="/home/${NB_USER}/work"
WORKDIR ${WORKSPACE}

# Presets for git
RUN git config --global credential.helper "store --file $HOME/.git-credentials" && \
    git config --global diff.colorMoved zebra && \
    git config --global fetch.prune true && \
    git config --global pull.rebase false

ADD base/README.ipynb $WORKSPACE

CMD [ "start-notebook.sh", "--no-browser", "--ip=0.0.0.0", "--config=/etc/jupyter/jupyter_notebook_config.py" ]