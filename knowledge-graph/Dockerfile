ARG LAB_VERSION=lab-4.5.1
ARG BASE_IMAGE=quay.io/jupyter/minimal-notebook
FROM $BASE_IMAGE:$LAB_VERSION

LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab"

# Install Python libraries for RDF / knowledge-graph
USER ${NB_UID}
COPY ./requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt && \
    rm requirements.txt

# Install Java runtime — REQUIRED by Apache Jena. 
RUN mamba install --yes 'openjdk=17' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Install Apache Jena 
ARG JENA_VERSION=5.2.0
USER root
RUN cd /opt && \
    wget -q https://archive.apache.org/dist/jena/binaries/apache-jena-${JENA_VERSION}.tar.gz && \
    tar xzf apache-jena-${JENA_VERSION}.tar.gz && \
    rm apache-jena-${JENA_VERSION}.tar.gz && \
    ln -s /opt/apache-jena-${JENA_VERSION} /opt/apache-jena
ENV PATH=$PATH:/opt/apache-jena/bin
USER ${NB_UID}

# Set up workspace
ENV WORKSPACE="/home/${NB_USER}/work"
ENV PERSISTENT_FOLDER="${WORKSPACE}/persistent"
USER root
RUN mkdir -p "${PERSISTENT_FOLDER}" && fix-permissions "${WORKSPACE}"
USER ${NB_UID}
WORKDIR ${WORKSPACE}
VOLUME [ "${PERSISTENT_FOLDER}" ]
