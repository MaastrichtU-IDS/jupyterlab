
ARG NVIDIA_IMAGE=nvcr.io/nvidia/tensorflow:21.08-tf2-py3

## Example Nvidia images available:
# Tensorflow: https://ngc.nvidia.com/catalog/containers/nvidia:tensorflow
# PyTorch: https://ngc.nvidia.com/catalog/containers/nvidia:pytorch

FROM ${NVIDIA_IMAGE}

USER root
WORKDIR /root

# RUN apt-get update && \
#     apt-get install -y curl wget

# Install JupyterLab with conda
RUN conda install --quiet -y \
    conda \
    pip \
    nodejs \
    notebook jupyterlab \
    ipywidgets \ 
    jupyterlab-lsp jupyter-lsp-python \
    jupyterlab-git  

# Install GPU dashboard: https://developer.nvidia.com/blog/gpu-dashboards-in-jupyter-lab/
RUN pip install jupyterlab-nvdashboard

# RUN jupyter labextension update --all && \
#     jupyter lab build 

# Add jupyter config script run at the start of the container
COPY jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py

EXPOSE 8888
ENTRYPOINT ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--config=/etc/jupyter/jupyter_notebook_config.py"]
