
ARG NVIDIA_IMAGE=nvcr.io/nvidia/tensorflow:21.08-tf2-py3

## Example Nvidia images available:
# Tensorflow: https://ngc.nvidia.com/catalog/containers/nvidia:tensorflow
# PyTorch: https://ngc.nvidia.com/catalog/containers/nvidia:pytorch
# CUDA: https://ngc.nvidia.com/catalog/containers/nvidia:cuda

FROM ${NVIDIA_IMAGE}

USER root
WORKDIR /root

# RUN apt-get update && \
#     apt-get install -y curl wget

# ## Install Conda
# ENV CONDA_DIR=/opt/conda \
#     SHELL=/bin/bash \
#     LANG=en_US.UTF-8 \
#     LANGUAGE=en_US.UTF-8
# ENV PATH="${CONDA_DIR}/bin:${PATH}" 
# # Automatically download the latest release of conda miniforge
# RUN export download_url=$(curl -s https://api.github.com/repos/conda-forge/miniforge/releases/latest | grep browser_download_url | grep -P "Mambaforge-\d+((\.|-)\d+)*-Linux-x86_64.sh" | grep -v sha256 | cut -d '"' -f 4) && \
#     echo "Downloading latest miniforge from $download_url" && \
#     curl -Lf -o miniforge.sh $download_url && \
#     # curl -Lf "https://github.com/conda-forge/miniforge/releases/download/${miniforge_version}/${miniforge_installer}" -o miniforge.sh && \
#     /bin/bash "miniforge.sh" -f -b -p "${CONDA_DIR}" && \
#     rm "miniforge.sh" && \
#     conda config --system --set auto_update_conda false && \
#     conda config --system --set show_channel_urls true

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
