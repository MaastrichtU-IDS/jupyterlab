
#ARG NVIDIA_IMAGE=nvcr.io/nvidia/pytorch:21.09-py3
ARG NVIDIA_IMAGE=nvcr.io/nvidia/cuda:10.1-devel-ubuntu18.04

## Example Nvidia images available:
# PyTorch: https://ngc.nvidia.com/catalog/containers/nvidia:pytorch

FROM ${NVIDIA_IMAGE}

USER root
WORKDIR /root

# RUN apt-get update && \
#     apt-get install -y curl wget

# Manual install of Cuda 10.1 and cudNN 7.6.5 version.
# Variable CUDNN_TAR_FILE can be changed to download from the repo.
# The default repo set is http://people.cs.uchicago.edu/~kauffman/nvidia/cudnn/ as NVIDIA requires login. Change the REPO variable as necessary.
RUN REPO="http://people.cs.uchicago.edu/~kauffman/nvidia/cudnn/"
RUN CUDA_VERSION="10.1"
RUN CUDNN_TAR_FILE="cudnn-10.1-linux-x64-v7.6.5.32.tgz"
RUN apt-get install -y wget g++ freeglut3-dev build-essential \
    libx11-dev libxmu-dev libxi-dev libglu1-mesa libglu1-mesa-dev 
RUN add-apt-repository ppa:graphics-drivers/ppa
RUN apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
RUN echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" | tee /etc/apt/sources.list.d/cuda.list
RUN apt-get update
RUN apt-get -o Dpkg::Options::="--force-overwrite" install cuda-$CUDA_VERSION cuda-drivers
RUN echo 'export PATH=/usr/local/cuda-$CUDA_VERSION/bin:$PATH' >> ~/.bashrc
RUN echo 'export LD_LIBRARY_PATH=/usr/local/cuda-$CUDA_VERSION/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
RUN source ~/.bashrc
RUN ldconfig
RUN wget $REPO$CUDNN_TAR_FILE
RUN tar -xzvf ${CUDNN_TAR_FILE}
RUN cp -P cuda/include/cudnn*.h /usr/local/cuda-$CUDA_VERSION/include
RUN cp -P cuda/lib64/libcudnn* /usr/local/cuda-$CUDA_VERSION/lib64/
RUN chmod a+r /usr/local/cuda-$CUDA_VERSION/lib64/libcudnn*

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
