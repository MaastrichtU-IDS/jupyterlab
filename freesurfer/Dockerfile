# Stage 1
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    FREESURFER_HOME=/usr/local/freesurfer/8.1.0 \
    FS_LICENSE="/license.txt" \
    PATH=/usr/local/freesurfer/8.1.0/bin:$PATH \
    #NVIDIA_VISIBLE_DEVICES=all \
    #NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1 

COPY ./deb/freesurfer_ubuntu22-8.1.0_amd64.deb /tmp/freesurfer.deb

RUN apt-get update -qq && \
    apt-get install -y -q --no-install-recommends \
        python3 \
        python3-pip \
        python3-venv \
        ca-certificates \
        csh \
        tcsh \
        bc \
        file \
        libx11-6 \
        libgomp1 \
        libxmu6 \
        libxt6 \
        tk \
        language-pack-en \
        binutils \
        libx11-dev \
        gettext \
        xterm \
        x11-apps \
        perl \
        make \
        xorg \
        xorg-dev \
        xserver-xorg-dev \
        xserver-xorg-video-intel \
        libncurses5 \
        libegl1 \
        libgl1 \
        libglib2.0-0 \
        libglu1-mesa \
        libglvnd0 \
        libglx0 \
        libicu70 \
        libjpeg62 \
        libopengl0 \
        libpcre2-16-0 \
        libquadmath0 \
        libx11-xcb1 \
        libxcb-icccm4 \
        libxcb-image0 \
        libxcb-keysyms1 \
        libxcb-randr0 \
        libxcb-render-util0 \
        libxcb-render0 \
        libxcb-shape0 \
        libxcb-shm0 \
        libxcb-sync1 \
        libxcb-util1 \
        libxcb-xfixes0 \
        libxcb-xinerama0 \
        libxcb-xinput0 \
        libxcb-xkb1 \
        libxi6 \
        libxkbcommon-x11-0 \
        libxkbcommon0 && \
    # Cleanup
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /usr/share/doc/* /usr/share/man/*

RUN python3 -m pip install \
        #six \
        jupyterlab \
        jupyterlab-lsp \
        python-lsp-server 

# Set bash as default shell for JupyterLab terminal
RUN mkdir -p /root/.jupyter && \
    echo "c.ServerApp.terminado_settings = {'shell_command': ['/bin/bash']}" > /root/.jupyter/jupyter_lab_config.py

ENV WORKSPACE="/workspace"
ENV PERSISTENT_FOLDER="${WORKSPACE}/persistent"

WORKDIR ${WORKSPACE}
VOLUME [ "${PERSISTENT_FOLDER}" ]

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8888

ENTRYPOINT ["/entrypoint.sh"]