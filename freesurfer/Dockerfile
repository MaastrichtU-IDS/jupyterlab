# Built with https://github.com/ReproNim/neurodocker
# Stage 1: Builder stage for FreeSurfer
FROM debian:bookworm-slim as freesurfer-builder

USER root
ARG DEBIAN_FRONTEND="noninteractive"

ENV FREESURFER_HOME="/opt/freesurfer-7.4.1"

# Install minimal dependencies for FreeSurfer download
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           curl \
           ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and extract FreeSurfer
RUN echo "Downloading FreeSurfer ..." \
    && mkdir -p /opt/freesurfer-7.4.1 \
    && curl -fsSL --retry 5 ftp://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/8.1.0/freesurfer-linux-ubuntu22_x86_64-8.1.0.tar.gz \
    | tar -xz -C /opt/freesurfer-7.4.1 --strip-components 2 \
         --exclude='freesurfer/average/mult-comp-cor' \
         --exclude='freesurfer/lib/cuda' \
         --exclude='freesurfer/lib/qt' \
         --exclude='freesurfer/subjects/V1_average' \
         --exclude='freesurfer/subjects/bert' \
         --exclude='freesurfer/subjects/cvs_avg35' \
         --exclude='freesurfer/subjects/cvs_avg35_inMNI152' \
         --exclude='freesurfer/subjects/fsaverage3' \
         --exclude='freesurfer/subjects/fsaverage4' \
         --exclude='freesurfer/subjects/fsaverage5' \
         --exclude='freesurfer/subjects/fsaverage6' \
         --exclude='freesurfer/subjects/fsaverage_sym' \
         --exclude='freesurfer/trctrain' \
    # Aggressive cleanup
    && find /opt/freesurfer-7.4.1 -type f -name "*.a" -delete \
    && find /opt/freesurfer-7.4.1 -type f -name "*.pyc" -delete \
    && find /opt/freesurfer-7.4.1 -type f -name "*.o" -delete \
    && find /opt/freesurfer-7.4.1 -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true \
    && rm -rf /opt/freesurfer-7.4.1/docs \
    && rm -rf /opt/freesurfer-7.4.1/diffusion/docs \
    && rm -rf /opt/freesurfer-7.4.1/tktools/*.pdf \
    # Remove unnecessary man pages and test files
    && rm -rf /opt/freesurfer-7.4.1/*/man \
    && rm -rf /opt/freesurfer-7.4.1/*/test* \
    # Strip binaries to reduce size
    && find /opt/freesurfer-7.4.1/bin -type f -executable -exec strip --strip-unneeded {} + 2>/dev/null || true

# Stage 2: Final image with miniforge3 (smaller than mambaforge)
FROM condaforge/miniforge3:latest
LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab-freesurfer"

USER root
ARG DEBIAN_FRONTEND="noninteractive"

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    ND_ENTRYPOINT="/neurodocker/startup.sh" \
    FREESURFER_HOME="/opt/freesurfer-7.4.1" \
    PATH="/opt/freesurfer-7.4.1/bin:$PATH"

# Install all necessary packages in a single layer
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           apt-utils \
           bzip2 \
           ca-certificates \
           curl \
           locales \
           unzip \
           bc \
           libgomp1 \
           libxmu6 \
           libxt6 \
           perl \
           tcsh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG="en_US.UTF-8" \
    && chmod 777 /opt && chmod a+s /opt \
    && mkdir -p /neurodocker \
    && echo '#!/usr/bin/env bash' > "$ND_ENTRYPOINT" \
    && echo 'set -e' >> "$ND_ENTRYPOINT" \
    && echo 'export USER="${USER:`whoami`}"' >> "$ND_ENTRYPOINT" \
    && echo 'if [ -n "$1" ]; then "$@"; else /usr/bin/env bash; fi' >> "$ND_ENTRYPOINT" \
    && chmod -R 777 /neurodocker && chmod a+s /neurodocker

# Copy FreeSurfer from builder stage
COPY --from=freesurfer-builder /opt/freesurfer-7.4.1 /opt/freesurfer-7.4.1

# Add FreeSurfer setup to entrypoint and create neurodocker specs
RUN sed -i '$isource "/opt/freesurfer-7.4.1/SetUpFreeSurfer.sh"' "$ND_ENTRYPOINT" \
    && echo '{ \
    \n  "pkg_manager": "apt", \
    \n  "instructions": [ \
    \n    [ \
    \n      "base", \
    \n      "debian:stretch" \
    \n    ], \
    \n    [ \
    \n      "freesurfer", \
    \n      { \
    \n        "version": "7.4.1" \
    \n      } \
    \n    ] \
    \n  ] \
    \n}' > /neurodocker/neurodocker_specs.json

# Install conda packages with cleanup - use mamba for faster resolution
RUN mamba install --quiet -y \
        notebook \
        jupyterlab \
        jupyterlab-lsp \
        jupyter-lsp-python \
    && mamba clean -afy \
    && find /opt/conda -follow -type f -name '*.a' -delete \
    && find /opt/conda -follow -type f -name '*.pyc' -delete \
    && find /opt/conda -follow -type f -name '*.js.map' -delete \
    && find /opt/conda -follow -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null || true \
    && rm -rf /opt/conda/pkgs/*

EXPOSE 8888
ENTRYPOINT ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
