# ANTs 2.6.4 with JupyterLab
FROM python:3.12

LABEL maintainer="Maastricht University - RCS"
LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-Library/ants"

WORKDIR /root

# Install JupyterLab
RUN pip install --no-cache-dir jupyterlab notebook

# Install Dependencies (Added 'unzip' for the new version)
RUN apt update -y && \
    apt upgrade -y && \
    apt install -y \
        wget \
        curl \
        file \
        unzip \
        zlib1g-dev \
    && apt clean && \
    rm -rf /var/lib/apt/lists/*

# Install ANTs 2.6.4 (the latest version)
# Note: Since it''s a ZIP, download, unzip, and then cleanup in one layer
RUN mkdir -p /opt/ants && \
    curl -fsSL -o /tmp/ants.zip https://github.com/ANTsX/ANTs/releases/download/v2.6.4/ants-2.6.4-ubuntu-22.04-X64-gcc.zip && \
    unzip /tmp/ants.zip -d /usr/local/ants && \
    mv /usr/local/ants/ants-2.6.4/* /usr/local/ants/ && \
    rm -rf /usr/local/ants/ants-2.6.4 /tmp/ants.zip

# Set Environment Variables
ENV ANTSPATH=/usr/local/ants/bin \
    PATH=/usr/local/ants/bin:$PATH

# Pre-load paths for every terminal session
RUN echo 'export ANTSPATH=/usr/local/ants/bin' >> ~/.bashrc && \
    echo 'export PATH=$ANTSPATH:$PATH' >> ~/.bashrc

SHELL ["/bin/bash", "-c"]
ENV SHELL=/bin/bash

EXPOSE 8888
ENTRYPOINT ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser"]