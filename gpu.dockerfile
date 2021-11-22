
ARG NVIDIA_IMAGE=nvcr.io/nvidia/tensorflow:21.08-tf2-py3
# ARG NVIDIA_IMAGE=nvcr.io/nvidia/cuda:11.4.2-devel-ubuntu20.04

## Example Nvidia images available:
# Tensorflow: https://ngc.nvidia.com/catalog/containers/nvidia:tensorflow
# CUDA: https://ngc.nvidia.com/catalog/containers/nvidia:cuda

FROM ${NVIDIA_IMAGE}

USER root
WORKDIR /workspace

RUN apt-get update && \
    apt-get install -y curl wget git vim zsh

## Install Conda
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV PATH="${CONDA_DIR}/bin:${PATH}" 
# Automatically download the latest release of conda miniforge
RUN export download_url=$(curl -s https://api.github.com/repos/conda-forge/miniforge/releases/latest | grep browser_download_url | grep -P "Mambaforge-\d+((\.|-)\d+)*-Linux-x86_64.sh" | grep -v sha256 | cut -d '"' -f 4) && \
    echo "Downloading latest miniforge from $download_url" && \
    curl -Lf -o miniforge.sh $download_url && \
    # curl -Lf "https://github.com/conda-forge/miniforge/releases/download/${miniforge_version}/${miniforge_installer}" -o miniforge.sh && \
    /bin/bash "miniforge.sh" -f -b -p "${CONDA_DIR}" && \
    rm "miniforge.sh" && \
    mamba config --system --set auto_update_conda false && \
    mamba config --system --set show_channel_urls true

# Install nodejs, java, JupyterLab with conda
RUN mamba install --quiet -y \
      openjdk maven \
      nodejs yarn \
      ipywidgets \
      jupyterlab \
      jupyterlab-git \
      jupyterlab-lsp \
      jupyter-lsp-python \
      jupyter_bokeh \
      jupyterlab-drawio \
      'jupyter-server-proxy>=3.1.0' && \
    mamba install -y -c plotly 'plotly>=4.8.2'

# Install GPU dashboard: https://developer.nvidia.com/blog/gpu-dashboards-in-jupyter-lab/
RUN pip install --upgrade pip && \
    pip install --upgrade \
      jupyterlab-nvdashboard \
      mitosheet3 \
      jupyterlab-spreadsheet-editor

# RUN jupyter labextension update --all && \
#     jupyter lab build 


# Install VS Code server
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server --install-extension redhat.vscode-yaml \
        --install-extension ms-python.python \
        --install-extension vscjava.vscode-java-pack \
        --install-extension ginfuru.ginfuru-better-solarized-dark-theme

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

WORKDIR /workspace
EXPOSE 8888
ENTRYPOINT ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--config=/etc/jupyter/jupyter_notebook_config.py"]
