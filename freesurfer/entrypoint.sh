#!/bin/bash
set -eux

FS_DIR="/usr/local/freesurfer/8.1.0"

if [ ! -d "$FS_DIR" ]; then
    echo "Installing FreeSurfer..."
    dpkg -i /tmp/freesurfer.deb

    cd /usr/local/freesurfer/8.1.0

    echo "Cleaning unnecessary files..."

    rm -rf \
        subjects/fsaverage* \
        subjects/cvs_avg35* \
        subjects/V1_average \
        subjects/sample-* \
        trctrain \
        diffusion/gradients \
        mni/transforms \
        docs \
        tktools/*.pdf

    rm -rf lib/cuda

    find lib -name "*.a" -delete
    find . -type f \( -name "*.pyc" -o -name "*.pyo" \) -delete

    echo "Removing installer..."
    rm -f /tmp/freesurfer.deb
fi

cd "$WORKSPACE"

echo "Starting JupyterLab..."
exec jupyter lab \
    --allow-root \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser
