FROM pytorch/pytorch:2.7.1-cuda12.8-cudnn9-devel

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Amsterdam \
    PYTHONUNBUFFERED=1

USER root

RUN apt-get update && \
    apt-get install -y curl wget git vim gnupg htop \
    python3-pip python3-dev python3-venv libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install TensorFlow
RUN pip install --no-cache-dir --root-user-action=ignore --break-system-packages \
    tensorflow

# Free up disk space during build 
RUN rm -rf /usr/share/dotnet \
           /opt/ghc \
           /usr/local/share/boost \
           /usr/lib/jvm && \
           apt-get clean

## Install packages with pip
# GPU dashboard: https://developer.nvidia.com/blog/gpu-dashboards-in-jupyter-lab/
RUN pip install --no-cache-dir --root-user-action=ignore --break-system-packages --upgrade \
      'jupyter-server-proxy>=4.4.0' \
      jupyterlab-git \
      ipython-sql \
      jupyterlab-lsp \
      python-lsp-server \
      jupyterlab-spreadsheet-editor \
      jupyterlab_latex \
      ipywidgets \
      notebook \
      qtconsole \
      jupyterlab-nvdashboard

# Install VS Code server & extensions
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server --install-extension redhat.vscode-yaml \
        --install-extension ms-python.python \
        --install-extension bungcip.better-toml \
        --install-extension ginfuru.ginfuru-better-solarized-dark-theme \
        --install-extension oderwat.indent-rainbow \
        --install-extension mechatroner.rainbow-csv \
        --install-extension GrapeCity.gc-excelviewer \
        --install-extension redhat.vscode-xml 

COPY settings.json /root/.local/share/code-server/User/settings.json

# Configure Jupyter - Add VSCode icon and JupyterLab config script 
COPY icons/*.svg /etc/jupyter/
COPY jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py

# Set up workspace folders, aliases and configure git
RUN echo 'alias pip="pip3"' >> ~/.bashrc && \
    echo 'alias python="python3"' >> ~/.bashrc

ENV WORKSPACE="/workspace"
ENV PERSISTENT_FOLDER="${WORKSPACE}/persistent"
RUN git config --global credential.helper "store --file $PERSISTENT_FOLDER/.git-credentials"

WORKDIR ${WORKSPACE}
VOLUME [ "${PERSISTENT_FOLDER}" ]

EXPOSE 8888

ENTRYPOINT ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--config=/etc/jupyter/jupyter_notebook_config.py"]