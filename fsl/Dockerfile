# FSL with JupyterLab
FROM ghcr.io/maastrichtu-ids/jupyterlab:latest

LABEL maintainer="Maastricht University - RCS"
LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-Library/fsl"

USER root

ENV FSLDIR="/usr/local/fsl" \
    DEBIAN_FRONTEND="noninteractive" \
    LANG="en_GB.UTF-8"

# Install FSL dependencies
RUN apt update -y && \
    apt upgrade -y && \
    apt install -y \
        python3 \
        wget \
        file \
        dc \
        mesa-utils \
        pulseaudio \
        libquadmath0 \
        libgtk2.0-0 \
        libgomp1 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Install FSL 6.0.7
RUN wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py && \
    python3 ./fslinstaller.py -d /usr/local/fsl/ && \
    rm fslinstaller.py

#PATH for FSL
ENV PATH="/usr/local/fsl/bin:$PATH"

RUN echo ". /usr/local/fsl/etc/fslconf/fsl.sh" >> ~/.bashrc