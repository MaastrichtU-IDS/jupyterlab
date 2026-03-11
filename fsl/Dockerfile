# FSL with JupyterLab
FROM python:3.12

LABEL maintainer="Maastricht University - RCS"
LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-Library/fsl"

ENV USER=root
WORKDIR /root

# Install JupyterLab
RUN pip install --no-cache-dir jupyterlab notebook

ENV FSLDIR="/usr/local/fsl" \
    FSLOUTPUTTYPE="NIFTI_GZ" \
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
        libgomp1 \
        libglu1-mesa \
        freeglut3-dev \
        libosmesa6-dev && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Install FSL 6.0.7
RUN wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py && \
    python3 ./fslinstaller.py -d $FSLDIR --skip_registration && \
    rm fslinstaller.py
    
#PATH for FSL
ENV PATH="/usr/local/fsl/bin:$PATH"

#Ensure FSL is sourced for all shell sessions
RUN echo ". /usr/local/fsl/etc/fslconf/fsl.sh" >> /etc/bash.bashrc

SHELL ["/bin/bash", "-c"]
ENV SHELL=/bin/bash

EXPOSE 8888
ENTRYPOINT ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser"]