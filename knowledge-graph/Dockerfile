FROM ghcr.io/maastrichtu-ids/jupyterlab:latest

LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab"

USER root

# RUN apt-get update && \
#     apt-get install -y sqlite3

# Install Oxigraph SPARQL endpoint 0.2.5 (latest release)
RUN wget -O /usr/local/bin/oxigraph_server https://github.com/vemonet/oxigraph/releases/download/v0.2.5/oxigraph_server && \
    chmod +x /usr/local/bin/oxigraph_server

# Install Oxigraph SPARQL endpoint 0.3 (current master)
# RUN wget -O /usr/local/bin/oxigraph_server https://github.com/vemonet/oxigraph/releases/download/v0.3.0-beta/oxigraph_server && \
#     chmod +x /usr/local/bin/oxigraph_server


COPY ./knowledge-graph/jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py

USER ${NB_UID}

# Install Blazegraph SPARQL endpoint
# RUN wget -O /opt/blazegraph.jar https://github.com/blazegraph/database/releases/download/BLAZEGRAPH_2_1_6_RC/blazegraph.jar


# Install packages for RDF processing
COPY ./knowledge-graph/requirements.txt requirements.txt
RUN pip install -r requirements.txt && \
    rm requirements.txt

## Install pyOxigraph 0.2.5
RUN pip install pyoxigraph oxrdflib
## Install pyOxigraph from source for 0.3+
# pip install "git+https://github.com/oxigraph/oxigraph.git@master#subdirectory=python"


# Download jar files in /opt, mainly for RDF processing
RUN npm i -g @rmlio/yarrrml-parser && \
    wget -O /opt/rmlmapper.jar https://github.com/RMLio/rmlmapper-java/releases/download/v4.11.0/rmlmapper.jar && \
    wget -O /opt/nanopub.jar https://github.com/Nanopublication/nanopub-java/releases/download/nanopub-1.34/nanopub-1.34-jar-with-dependencies.jar && \
    wget -O /opt/widoco.jar https://github.com/dgarijo/Widoco/releases/download/v1.4.15/widoco-1.4.15-jar-with-dependencies.jar && \
    wget -O /opt/limes.jar https://github.com/dice-group/LIMES/releases/download/1.7.5/limes.jar && \
    wget -O /opt/amie3.jar https://github.com/lajus/amie/releases/download/3.0/amie-milestone-intKB.jar && \
    wget -O /opt/shaclconvert.jar https://github.com/vemonet/shacl-convert/releases/download/0.0.1/shaclconvert.jar
    # wget -O /opt/shaclconvert.jar https://gitlab.ontotext.com/yasen.marinov/shaclconvert/-/raw/master/built/shaclconvert.jar

RUN cd /opt && \
    wget https://repo1.maven.org/maven2/commons-io/commons-io/2.11.0/commons-io-2.11.0.jar && \
    wget http://download.eclipse.org/rdf4j/eclipse-rdf4j-3.7.3-onejar.jar 


# Download latest Jena
RUN cd /opt && \
    export JENA_FILENAME=$(curl -sL https://downloads.apache.org/jena/binaries | grep ".*apache-jena-.*\.tar\.gz<.*" | grep -v ".*fuseki.*" | cut -d '"' -f 6) && \
    wget https://downloads.apache.org/jena/binaries/$JENA_FILENAME && \
    tar xvf apache-jena-*.tar.gz && \
    rm apache-jena-*.tar.gz && \
    mv apache-jena-* apache-jena

# Download latest simpleowlapi jar in /opt/simpleowlapi.jar
RUN cd /opt && \
    curl -s https://api.github.com/repos/kodymoodley/simpleowlapi/releases/latest \
        | grep "browser_download_url.*-jar-with-dependencies.jar" \
        | cut -d : -f 2,3 \
        | tr -d \" \
        | wget -O /opt/simpleowlapi.jar -qi -


# # Download the Nanobench
# ENV NANOBENCH_VERSION=1.37
# RUN mkdir -p /opt/nanobench && cd /opt/nanobench && \
#     wget https://github.com/peta-pico/nanobench/releases/download/nanobench-$NANOBENCH_VERSION/nanobench-$NANOBENCH_VERSION.zip && \
#     unzip nanobench-$NANOBENCH_VERSION.zip
# ENV PATH=$PATH:/opt/openrefine:/opt/nanobench