#!/bin/bash

if [[ ! -z "${CONDA_DIR}" && ! -d "${CONDA_DIR}" ]] ; then
    echo "Conda not installed, installing it."

    # Automatically download the latest release of miniforge conda/mamba
    export download_url=$(curl -s https://api.github.com/repos/conda-forge/miniforge/releases/latest | grep browser_download_url | grep -P "Mambaforge-\d+((\.|-)\d+)*-Linux-x86_64.sh" | grep -v sha256 | cut -d '"' -f 4)
    echo "Downloading latest miniforge from $download_url"
    curl -Lf -o miniforge.sh $download_url
    # curl -Lf "https://github.com/conda-forge/miniforge/releases/download/${miniforge_version}/${miniforge_installer}" -o miniforge.sh

    /bin/bash "miniforge.sh" -f -b -p "${CONDA_DIR}"
    rm "miniforge.sh"
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
