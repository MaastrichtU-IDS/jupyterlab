FROM nvcr.io/nvidia/pytorch:25.02-py3

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Amsterdam \
    PYTHONUNBUFFERED=1

USER root

RUN apt-get update && \
    apt-get install -y curl wget git vim htop \
    && rm -rf /var/lib/apt/lists/* && \
    apt-get clean

## Install packages with pip
# GPU dashboard: https://developer.nvidia.com/blog/gpu-dashboards-in-jupyter-lab/
RUN pip install --no-cache-dir --root-user-action=ignore --break-system-packages --upgrade \
      jupyterlab-git \
      jupyterlab-lsp \
      python-lsp-server \
      jupyterlab-spreadsheet-editor \
      jupyterlab-nvdashboard 

# Configure Jupyter - Add JupyterLab config script 
COPY jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py

# Set up workspace folders, and configure git
ENV WORKSPACE="/workspace"
ENV PERSISTENT_FOLDER="${WORKSPACE}/persistent"
RUN git config --global credential.helper "store --file $PERSISTENT_FOLDER/.git-credentials"

WORKDIR ${WORKSPACE}
VOLUME [ "${PERSISTENT_FOLDER}" ]

EXPOSE 8888

ENTRYPOINT ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--config=/etc/jupyter/jupyter_notebook_config.py"]