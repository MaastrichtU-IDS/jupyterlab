
ARG NVIDIA_IMAGE=nvcr.io/nvidia/tensorflow:21.11-tf2-py3
# ARG NVIDIA_IMAGE=nvcr.io/nvidia/cuda:11.4.2-devel-ubuntu20.04
# ARG NVIDIA_IMAGE=nvcr.io/nvidia/pytorch:21.11-py3

## Example Nvidia images available:
# Tensorflow: https://ngc.nvidia.com/catalog/containers/nvidia:tensorflow
# CUDA: pip and git not installed by default https://ngc.nvidia.com/catalog/containers/nvidia:cuda
# PyTorch: conda installed by default https://ngc.nvidia.com/catalog/containers/nvidia:pytorch

FROM ${NVIDIA_IMAGE}

USER root
# RUN mkdir -p /workspace/persistent
# RUN mkdir -p /workspace/scratch
# WORKDIR /workspace

RUN apt-get update && \
    apt-get install -y curl wget git vim zsh gnupg htop \
      python3-pip python3-dev libpq-dev 
      # ffmpeg libsm6 libxext6
      # For opencv, but causes pytorch and cuda build to crash

# # Create user
# ARG NB_USER="jovyan" \
#     NB_UID="1000" \
#     NB_GID="100"
# ENV NB_USER="${NB_USER}" \
#     NB_UID=${NB_UID} \
#     NB_GID=${NB_GID}
# ENV HOME="/home/${NB_USER}"
# # Create NB_USER with name jovyan user with UID=1000 and in the 'users' group
# RUN useradd -l -m -s /bin/zsh -N -u "${NB_UID}" "${NB_USER}" && \
#     mkdir -p /opt && \
#     mkdir -p /home/$NB_USER/work && \
#     mkdir -p /home/$NB_USER/persistent && \
#     chown -R $NB_USER:$NB_GID /opt

# USER ${NB_USER}


## Install Conda if not already installed
ENV CONDA_DIR=${CONDA_DIR:-/opt/conda} \
    SHELL=/bin/bash \
    LANG=${LANG:-en_US.UTF-8} \
    LANGUAGE=${LANGUAGE:-en_US.UTF-8}
ENV PATH="${CONDA_DIR}/bin:${PATH}"
COPY install_conda.sh /tmp/
RUN /tmp/install_conda.sh

## Install packages with Conda
RUN mamba install --quiet -y \
      nodejs \
      ipywidgets \
      jupyterlab \
      jupyterlab-git \
      jupyterlab-lsp \
      nb_conda_kernels \
      jupyter-lsp-python \
      'jupyter-server-proxy>=3.1.0'
      # jupyter_bokeh \
      # jupyterlab-drawio \
      # rise \
      # openjdk maven \
    #   tensorflow tensorboard jupyter_tensorboard \
    # conda install -y -c plotly 'plotly>=4.8.2'


## Install packages with pip
# GPU dashboard: https://developer.nvidia.com/blog/gpu-dashboards-in-jupyter-lab/
RUN pip install --upgrade pip && \
    pip install --upgrade \
      jupyterlab-nvdashboard \
      jupyterlab-github \
      jupyterlab-spreadsheet-editor
      # mitosheet3
      # jupyterlab-git jupyterlab-lsp 'python-lsp-server[all]' \

      ## Issue tensorboard with Jupyterlab3: https://github.com/chaoleili/jupyterlab_tensorboard/issues/28
      ## https://github.com/lspvic/jupyter_tensorboard
      # 'git+https://github.com/cliffwoolley/jupyter_tensorboard.git' \
      # 'git+https://github.com/chaoleili/jupyterlab_tensorboard.git' \
      # 'tensorboard==2.2.1' \
      # 'jupyter-tensorboard==0.2.0' \
    #   'jupyter-server-proxy>=3.1.0'
    
## Conflicting with jupyterlab 3 apparently:
# RUN jupyter labextension install jupyterlab_tensorboard

# RUN jupyter labextension update --all && \
#     jupyter lab build 


# Install VS Code server
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server --install-extension redhat.vscode-yaml \
        --install-extension ms-python.python \
        # --install-extension vscjava.vscode-java-pack \
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
# RUN cd /opt && \
#     export EXT_VERSION=0.6.4 && \
#     wget https://github.com/janisdd/vscode-edit-csv/releases/download/v$EXT_VERSION/vscode-edit-csv-$EXT_VERSION.vsix && \
#     code-server --install-extension vscode-edit-csv-$EXT_VERSION.vsix

COPY settings.json /root/.local/share/code-server/User/settings.json
COPY settings.json /home/$NB_USER/.local/share/code-server/User/settings.json

# Add jupyter config script run at the start of the container
USER root
COPY icons/*.svg /etc/jupyter/
COPY jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py

USER ${NB_USER}

# Install Oh My ZSH! and custom theme
RUN sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
RUN curl -fsSL -o ~/.oh-my-zsh/custom/themes/biratime.zsh-theme https://raw.github.com/vemonet/biratime/main/biratime.zsh-theme
RUN sed -i 's/^ZSH_THEME=".*"$/ZSH_THEME="biratime"/g' ~/.zshrc
RUN echo "\`conda config --set changeps1 false\`" >> ~/.oh-my-zsh/plugins/virtualenv/virtualenv.plugin.zsh
RUN echo 'setopt NO_HUP' >> ~/.zshrc
ENV SHELL=/bin/zsh
# RUN chsh -s /bin/zsh

# Git token will be stored in the persistent volume
RUN git config --global credential.helper 'store --file ~/.git-credentials'

ENV WORKSPACE="/workspace"
# ENV WORKSPACE="/home/${NB_USER}"
ENV PERSISTENT_FOLDER="${WORKSPACE}/persistent"
WORKDIR ${WORKSPACE}
VOLUME [ "${PERSISTENT_FOLDER}", "${WORKSPACE}/scratch" ]
EXPOSE 8888
ENTRYPOINT ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--config=/etc/jupyter/jupyter_notebook_config.py"]
