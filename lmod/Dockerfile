FROM jupyter/scipy-notebook:latest

LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab"

# https://quay.io/repository/guimou/s2i-generic-datascience-lmod-notebook/manifest/sha256:4329da31f6ef918b1f3878b037c7517cb72511bf1fcbb632b50dcd5cd0802715

ENV JUPYTER_ENABLE_LAB=yes

# RUN npm install --global yarn 

# Install jupyterlab extensions
RUN conda install --quiet --yes \
      ipywidgets \
      jupyterlab \
      jupyterlab-git \
      jupyterlab-lsp \
      jupyter-lsp-python \
      jupyter_bokeh \
      jupyterlab-drawio && \
      # rise && \ # Issue when building with GitHub Actions related to jedi package
    conda install -c plotly 'plotly>=4.8.2' 
    # fix-permissions $CONDA_DIR && \
    # fix-permissions /home/$NB_USER

RUN pip install --upgrade pip && \
    pip install --upgrade \
    #   sparqlkernel \
      # elyra \
      # Pipeline builder for Kubeflow and Airflow
      jupyterlab-system-monitor && \
    jupyter labextension install jupyterlab-spreadsheet


# Change to root user to install Lmod dependencies
USER root

# Install Lua for Lmod
RUN apt-get update && \
    apt-get install -y lua5.3 \
        lua-bit32:amd64 \
        lua-posix:amd64 \
        lua-posix-dev \
        liblua5.3-0:amd64 \
        liblua5.3-dev:amd64 \
        tcl \
        tcl-dev \
        tcl8.6 \
        tcl8.6-dev:amd64 \
        libtcl8.6:amd64 \
        python-keyring \
        rdma-core \
        curl wget \
        ant
# RUN yum -y update && yum -y install xz iproute pam-devel ant lua lua-devel lua-posix lua-filesystem tcl python-keyring rdma-core-devel && yum -y clean all && rm -rf /var/cache/dnf

RUN mkdir -p /build

RUN fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    fix-permissions /opt && \
    fix-permissions /build

USER $NB_USER

# Install Lmod
ENV USER=jovyan \
    # TODO: Path to modules can be added here
    MODULEPATH=/opt/apps/easybuild/modules/all:/opt/apps/modulefiles/Linux:/opt/apps/modulefiles/Core:/opt/apps/lmod/lmod/modulefiles/Core \
    MODULEPATH_ROOT=/opt/apps/modulefiles \
    # MODULEPATH_ROOT=/opt/apps/lmod/lmod/modulefiles \
    MODULESHOME=/opt/apps/lmod/lmod \
    MANPATH=/opt/apps/lmod/lmod/share/man: \
    LMOD_DIR=/opt/apps/lmod/lmod/libexec \
    LMOD_SETTARG_FULL_SUPPORT=no \
    LMOD_PACKAGE_PATH=/opt/apps/easybuild/ \
    LMOD_VERSION=8.5.9 \
    LMOD_ROOT=/opt/apps/lmod \
    LMOD_sys=Linux \
    LMOD_CMD=/opt/apps/lmod/lmod/libexec/lmod

RUN mkdir -p /opt/apps
WORKDIR /build
RUN curl -LO http://github.com/TACC/Lmod/archive/${LMOD_VERSION}.tar.gz && \
    mv /build/${LMOD_VERSION}.tar.gz /build/Lmod-${LMOD_VERSION}.tar.gz && \
    tar xvf Lmod-${LMOD_VERSION}.tar.gz

WORKDIR /build/Lmod-$LMOD_VERSION

RUN ./configure --prefix=/opt/apps --with-fastTCLInterp=no && \
    make install

USER root
RUN rm -rf /build && \
    ln -s /opt/apps/lmod/lmod/init/profile /etc/profile.d/z00_lmod.sh
USER $NB_USER

# Install Lmod jupyter extension
RUN pip install jupyterlmod && \
    jupyter labextension install jupyterlab-lmod

# RUN pip install --no-cache-dir -r /tmp/requirements.txt && \ 
#     pip install --no-cache-dir /tmp/jupyter_server_proxy-*-py3-none-any.whl && \
#     pip install --no-cache-dir /tmp/jupyterlmod-*-py3-none-any.whl && \
#     pip install --no-cache-dir /tmp/jupyterlmodlauncher && \
#     jupyter labextension install /tmp/jupyterlab-lmod-*.tgz && \
#     jupyter lab build && \
#     jupyter lab clean && \
#     npm cache clean --force && \
#     rm -rf $HOME/.cache/yarn && \
#     rm -rf $HOME/.node-gyp 


RUN jupyter labextension update --all && \
    jupyter lab build 


# # Add jar files in /opt for RDF processing
# RUN npm i -g @rmlio/yarrrml-parser && \
#     wget -q -O /opt/rmlmapper.jar https://github.com/RMLio/rmlmapper-java/releases/download/v4.11.0/rmlmapper.jar && \
#     wget -q -O /opt/widoco.jar https://github.com/dgarijo/Widoco/releases/download/v1.4.15/widoco-1.4.15-jar-with-dependencies.jar && \
#     wget -q -O /opt/limes.jar https://github.com/dice-group/LIMES/releases/download/1.7.5/limes.jar && \
#     wget -q -O /opt/amie3.jar https://github.com/lajus/amie/releases/download/3.0/amie-milestone-intKB.jar && \
#     wget -q -O /opt/shaclconvert.jar https://gitlab.ontotext.com/yasen.marinov/shaclconvert/-/raw/master/built/shaclconvert.jar

# RUN cd /opt && \
#     wget -q https://repo1.maven.org/maven2/commons-io/commons-io/2.11.0/commons-io-2.11.0.jar && \
#     wget -q https://downloads.apache.org/jena/binaries/apache-jena-4.2.0.tar.gz && \
#     wget -q http://download.eclipse.org/rdf4j/eclipse-rdf4j-3.7.3-onejar.jar 

# # Download latest simpleowlapi jar in /opt/simpleowlapi.jar
# RUN curl -s https://api.github.com/repos/kodymoodley/simpleowlapi/releases/latest \
#     | grep "browser_download_url.*-jar-with-dependencies.jar" \
#     | cut -d : -f 2,3 \
#     | tr -d \" \
#     | wget -O /opt/simpleowlapi.jar -qi -

WORKDIR /home/$NB_USER/work

ADD jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py

ENTRYPOINT [ "start-notebook.sh", "--no-browser", "--ip=0.0.0.0", "--config=/etc/jupyter/jupyter_notebook_config.py" ]