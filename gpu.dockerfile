
ARG NVIDIA_IMAGE=nvcr.io/nvidia/tensorflow:21.11-tf2-py3
# ARG NVIDIA_IMAGE=nvcr.io/nvidia/cuda:11.4.2-devel-ubuntu20.04
# ARG NVIDIA_IMAGE=nvcr.io/nvidia/pytorch:21.11-py3

## Example Nvidia images available:
# Tensorflow: https://ngc.nvidia.com/catalog/containers/nvidia:tensorflow
# CUDA: pip and git not installed by default https://ngc.nvidia.com/catalog/containers/nvidia:cuda
# PyTorch: conda installed by default https://ngc.nvidia.com/catalog/containers/nvidia:pytorch

FROM ${NVIDIA_IMAGE}

USER root
RUN mkdir -p /workspace/persistent
RUN mkdir -p /workspace/scratch
WORKDIR /workspace

RUN apt update && \
    apt install -y curl wget git vim zsh python3-pip gnupg htop \
      ffmpeg libsm6 libxext6
      # For opencv

## Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_16.x  | bash -
RUN apt -y install nodejs

## Install Conda if not already installed
ENV CONDA_DIR=${CONDA_DIR:-/opt/conda} \
    SHELL=/bin/bash \
    LANG=${LANG:-en_US.UTF-8} \
    LANGUAGE=${LANGUAGE:-en_US.UTF-8}
ENV PATH="${CONDA_DIR}/bin:${PATH}"
COPY install_conda.sh /tmp/
RUN /tmp/install_conda.sh

## Install packages with Conda
RUN conda install --quiet -y \
    #   openjdk maven \
      nodejs \
      ipywidgets \
      nb_conda_kernels \
      jupyterlab \
      jupyterlab-git \
      jupyterlab-lsp \
      jupyter-lsp-python \
      jupyter_bokeh \
      jupyterlab-drawio \
      rise \
    #   tensorflow tensorboard jupyter_tensorboard \
      'jupyter-server-proxy>=3.1.0' && \
    conda install -y -c plotly 'plotly>=4.8.2'


## Install packages with pip
# GPU dashboard: https://developer.nvidia.com/blog/gpu-dashboards-in-jupyter-lab/
RUN pip install --upgrade pip && \
    pip install --upgrade \
      # jupyterlab \
    #   ipywidgets \
    #   jupyterlab-git \
    #   jupyterlab-lsp 'python-lsp-server[all]' \
      jupyterlab-nvdashboard \
      jupyterlab-spreadsheet-editor \
      mitosheet3
    #   jupyter_bokeh \
    #   'plotly>=4.8.2' \
      ## Issue tensorboard with Jupyterlab3: https://github.com/chaoleili/jupyterlab_tensorboard/issues/28
      ## https://github.com/lspvic/jupyter_tensorboard
      # 'git+https://github.com/cliffwoolley/jupyter_tensorboard.git' \
      # 'git+https://github.com/chaoleili/jupyterlab_tensorboard.git' \
      # 'tensorboard==2.2.1' \
      # 'jupyter-tensorboard==0.2.0' \
    #   'jupyter-server-proxy>=3.1.0'
    

## Conflicting with jupyterlab 3 apparently
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
COPY icons/*.svg /etc/jupyter/


# Install ZSH
RUN sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
RUN wget -O ~/.oh-my-zsh/custom/themes/vemonet_bira.zsh-theme https://raw.githubusercontent.com/vemonet/zsh-theme-biradate/master/zsh/vemonet_bira.zsh-theme
RUN sed -i 's/robbyrussell/vemonet_bira/g' ~/.zshrc
ENV SHELL=/bin/zsh
RUN chsh -s /bin/zsh 

# Add jupyter config script run at the start of the container
COPY jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py

ENV PERSISTENT_DIR="/workspace/persistent"
ENV WORKSPACE="/workspace"
WORKDIR /workspace
VOLUME [ "/workspace/persistent", "/workspace/scratch" ]
EXPOSE 8888
ENTRYPOINT ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--config=/etc/jupyter/jupyter_notebook_config.py"]
