#!/bin/bash

if [[ ! -z "${CONDA_DIR}" && ! -d "${CONDA_DIR}" ]] ; then
    echo "Conda not installed, installing it."

    # export CONDA_DIR=${CONDA_DIR:-/opt/conda}
    # SHELL=/bin/bash \
    # LANG=${LANG:-en_US.UTF-8} \
    # LANGUAGE=${LANGUAGE:-en_US.UTF-8}
    # ENV PATH="${CONDA_DIR}/bin:${PATH}"

    # Automatically download the latest release of mambaforge for conda/mamba
    wget -O Mambaforge-Linux-x86_64.sh https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh
    chmod +x Mambaforge-Linux-x86_64.sh
    /bin/bash Mambaforge-Linux-x86_64.sh -f -b -p "${CONDA_DIR}"
    rm "Mambaforge-Linux-x86_64.sh"

    mamba config --system --set auto_update_conda false
    mamba config --system --set show_channel_urls true

    # Install Tensorflow
    mamba install -y tensorflow tensorboard
    pip install jupyter_tensorboard

else
    echo "Conda already installed."
    if ! command -v mamba &> /dev/null
    then
        echo "Mamba not installed. Installing it."
        conda install -y -c conda-forge mamba
    fi
fi

# Old approach to download the latest version of mambaforge
# export download_url=$(curl -s https://api.github.com/repos/conda-forge/miniforge/releases/latest | grep browser_download_url | grep -P "Mambaforge-\d+((\.|-)\d+)*-Linux-x86_64.sh" | grep -v sha256 | cut -d '"' -f 4)
# echo "Downloading latest miniforge from $download_url"
# curl -Lf -o miniforge.sh $download_url
# /bin/bash "miniforge.sh" -f -b -p "${CONDA_DIR}"
# rm "miniforge.sh"