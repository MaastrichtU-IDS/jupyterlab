
ARG NVIDIA_IMAGE=nvcr.io/nvidia/pytorch:23.03-py3
# PyTorch: https://ngc.nvidia.com/catalog/containers/nvidia:pytorch

FROM ${NVIDIA_IMAGE}

USER root

# Unminimize Ubuntu image to enable to push with git
# RUN yes | unminimize

RUN apt-get update && \
    apt-get install -y curl wget git vim zsh gnupg htop \
      python3-pip python3-dev libpq-dev
# For opencv, but causes pytorch and cuda build to crash: ffmpeg libsm6 libxext6

# Install NodeJS
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

## Install packages with pip
# GPU dashboard: https://developer.nvidia.com/blog/gpu-dashboards-in-jupyter-lab/
RUN pip3 install --upgrade pip && \
    pip3 install --upgrade \
      ipywidgets \
      jupyterlab \
      jupyterlab-git \
      jupyterlab-lsp \
      python-lsp-server[all] \
      jupyterlab-nvdashboard \
      jupyterlab-github \
      jupyterlab-spreadsheet-editor \
      jupyter_tensorboard \
      'jupyter-server-proxy>=3.1.0'
      # mitosheet3
      ## Issue tensorboard with Jupyterlab3: https://github.com/chaoleili/jupyterlab_tensorboard/issues/28
      ## https://github.com/lspvic/jupyter_tensorboard


# Install VS Code server
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server --install-extension redhat.vscode-yaml \
        --install-extension ms-python.python \
        --install-extension ginfuru.ginfuru-better-solarized-dark-theme \
        --install-extension oderwat.indent-rainbow \
        --install-extension mechatroner.rainbow-csv \
        --install-extension GrapeCity.gc-excelviewer \
        --install-extension tht13.html-preview-vscode \
        --install-extension mdickin.markdown-shortcuts \
        --install-extension redhat.vscode-xml \
        --install-extension nickdemayo.vscode-json-editor \
        --install-extension mutantdino.resourcemonitor

# https://github.com/stardog-union/stardog-vsc/issues/81
# https://open-vsx.org/extension/vemonet/stardog-rdf-grammars
RUN cd /opt && \
    export EXT_VERSION=0.1.2 && \
    wget https://open-vsx.org/api/vemonet/stardog-rdf-grammars/$EXT_VERSION/file/vemonet.stardog-rdf-grammars-$EXT_VERSION.vsix && \
    code-server --install-extension vemonet.stardog-rdf-grammars-$EXT_VERSION.vsix

COPY settings.json /root/.local/share/code-server/User/settings.json
COPY settings.json /home/$NB_USER/.local/share/code-server/User/settings.json

# Add jupyter config script run at the start of the container
USER root
COPY icons/*.svg /etc/jupyter/
COPY jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py

# Install Oh My ZSH! and custom theme
RUN sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
RUN curl -fsSL -o ~/.oh-my-zsh/custom/themes/biratime.zsh-theme https://raw.github.com/vemonet/biratime/main/biratime.zsh-theme
RUN sed -i 's/^ZSH_THEME=".*"$/ZSH_THEME="biratime"/g' ~/.zshrc
RUN echo "\`conda config --set changeps1 false\`" >> ~/.oh-my-zsh/plugins/virtualenv/virtualenv.plugin.zsh
RUN echo 'setopt NO_HUP' >> ~/.zshrc
ENV SHELL=/bin/zsh

RUN echo 'alias pip="pip3"' >> ~/.bashrc
RUN echo 'alias pip="pip3"' >> ~/.zshrc

ENV WORKSPACE="/workspace"
ENV PERSISTENT_FOLDER="${WORKSPACE}/persistent"

RUN git config --global credential.helper "store --file $PERSISTENT_FOLDER/.git-credentials"

WORKDIR ${WORKSPACE}
VOLUME [ "${PERSISTENT_FOLDER}", "${WORKSPACE}/scratch" ]
EXPOSE 8888
ENTRYPOINT ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--config=/etc/jupyter/jupyter_notebook_config.py"]
