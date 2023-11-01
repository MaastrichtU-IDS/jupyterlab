FROM ghcr.io/maastrichtu-ids/jupyterlab:latest

LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab"

# APACHE_SPARK_VERSION=3.0.1 and HADOOP_VERSION=3.2
# APACHE_SPARK_VERSION=2.4.5 and HADOOP_VERSION=2.7 -> Requires python 3.7 and java 8
ARG APACHE_SPARK_VERSION=3.2.1
ARG HADOOP_VERSION=3.2
ENV APACHE_SPARK_VERSION=$APACHE_SPARK_VERSION \
    HADOOP_VERSION=$HADOOP_VERSION 

USER root

RUN apt-get update && \
    apt-get install -y raptor2-utils


# COPY ./jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py


USER ${NB_UID}

## Install Spark for standalone context in /opt
# APACHE_SPARK_VERSION=3.0.1 and HADOOP_VERSION=3.2
# APACHE_SPARK_VERSION=2.4.5 and HADOOP_VERSION=2.7 -> Requires python 3.7 and java 8
ARG APACHE_SPARK_VERSION=3.2.1
ARG HADOOP_VERSION=3.2
ENV APACHE_SPARK_VERSION=$APACHE_SPARK_VERSION \
    HADOOP_VERSION=$HADOOP_VERSION 
ENV SPARK_HOME=/opt/spark \
    SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx2048M --driver-java-options=-Dlog4j.logLevel=info"
ENV PATH=$PATH:$SPARK_HOME/bin
RUN wget -q -O spark.tgz https://archive.apache.org/dist/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    tar xzf spark.tgz -C /opt && \
    rm "spark.tgz" && \
    ln -s "/opt/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}" $SPARK_HOME

RUN mamba install --quiet -y \
      pyspark=$APACHE_SPARK_VERSION


# Install OpenRefine
ENV OPENREFINE_VERSION=3.7.6
RUN cd /opt && \
    wget https://github.com/OpenRefine/OpenRefine/releases/download/$OPENREFINE_VERSION/openrefine-linux-$OPENREFINE_VERSION.tar.gz && \
    tar xzf openrefine-linux-$OPENREFINE_VERSION.tar.gz && \
    mv /opt/openrefine-$OPENREFINE_VERSION /opt/openrefine && \
    rm openrefine-linux-$OPENREFINE_VERSION.tar.gz
    # ln -s /opt/openrefine-$OPENREFINE_VERSION/refine /opt/refine 
ENV REFINE_DIR=/home/$NB_USER/openrefine
ENV PATH=$PATH:/opt/openrefine
RUN mkdir -p ~/openrefine


# Install Blazegraph SPARQL endpoint
# RUN wget -O /opt/blazegraph.jar https://github.com/blazegraph/database/releases/download/BLAZEGRAPH_2_1_6_RC/blazegraph.jar

RUN pip install --upgrade pip && \
    pip install --upgrade \
      sparqlkernel \
      #   nb-serverproxy-openrefine \ 
      git+https://github.com/innovationOUtside/nb_serverproxy_openrefine.git@main


# Install SPARQL kernel
USER root

RUN jupyter sparqlkernel install 

RUN fix-permissions /home/$NB_USER && \
    fix-permissions /home/$NB_USER/.local && \
    fix-permissions /etc/jupyter


USER ${NB_UID}

# Install packages for RDF processing
COPY ./knowledge-graph/requirements.txt requirements.txt
RUN pip install -r requirements.txt && \
    rm requirements.txt

## Install pyOxigraph 0.2.5
# RUN pip install pyoxigraph oxrdflib
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
