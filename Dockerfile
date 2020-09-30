FROM quay.io/jupyteronopenshift/s2i-minimal-notebook-py36:2.5.1

USER root
ENV XDG_CACHE_HOME=/opt/app-root/src/.cache

RUN yum update -y
RUN yum install -y software-properties-common build-essential vim curl wget
RUN yum install -y epel-release \
 && yum install -y git cmake3 gcc-c++ gcc gfortran binutils \
  libX11-devel libXpm-devel libXft-devel libXext-devel openssl-devel \
  python36-devel \
 && localedef -i en_US -f UTF-8 en_US.UTF-8

# Install Java and NodeJS
RUN curl -sL https://rpm.nodesource.com/setup_12.x | bash -
RUN yum install -y java-11-openjdk-devel maven nodejs

# Install SPARQL kernel
RUN pip install sparqlkernel
RUN jupyter sparqlkernel install

# Install Ijava kernel
RUN curl -L https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip > ijava-kernel.zip
RUN unzip ijava-kernel.zip -d ijava-kernel \
  && cd ijava-kernel \
  && python3 install.py --sys-prefix

# Install jupyter RISE extension (for IJava)
RUN pip install jupyter_contrib-nbextensions RISE \
  && jupyter-nbextension install rise --py --system \
  && jupyter-nbextension enable rise --py --system \
  && jupyter contrib nbextension install --system \
  && jupyter nbextension enable hide_input/main
RUN rm ijava-kernel.zip

# Add fusion repo for ffmpeg
RUN yum localinstall -y --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm
# Dependencyies for matplotlib
RUN yum install -y ffmpeg dvipng

## Install Spark
ARG spark_version="3.0.1"
ARG hadoop_version="3.2"
ARG spark_checksum="E8B47C5B658E0FBC1E57EEA06262649D8418AE2B2765E44DA53AAF50094877D17297CC5F0B9B35DF2CEEF830F19AA31D7E56EAD950BBE7F8830D6874F88CFC3C"
ARG py4j_version="0.10.9"

ENV APACHE_SPARK_VERSION="${spark_version}" \
    HADOOP_VERSION="${hadoop_version}"

# Spark installation
WORKDIR /tmp
# Using the preferred mirror to download Spark
RUN wget -q $(wget -qO- https://www.apache.org/dyn/closer.lua/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz\?as_json | \
    python -c "import sys, json; content=json.load(sys.stdin); print(content['preferred']+content['path_info'])") && \
    echo "${spark_checksum} *spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" | sha512sum -c - && \
    tar xzf "spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" -C /usr/local --owner root --group root --no-same-owner && \
    rm "spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz"

WORKDIR /usr/local
RUN ln -s "spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}" spark

# Configure Spark
ENV SPARK_HOME=/usr/local/spark
ENV PYTHONPATH="${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-${py4j_version}-src.zip" \
    SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info" \
    PATH=$PATH:$SPARK_HOME/bin

# Install facets which does not have a pip or conda package at the moment
WORKDIR /tmp
RUN git clone https://github.com/PAIR-code/facets.git && \
    jupyter nbextension install facets/facets-dist/ --sys-prefix && \
    rm -rf /tmp/facets


# # Install pip packages
# RUN pip install -r /tmp/src/requirements.txt

COPY . /tmp/src
RUN pip install -r /tmp/src/requirements.txt

## Set permissions

RUN rm -rf /tmp/src/.git* && \
    chown -R 1001 /tmp/src && \
    chgrp -R 0 /tmp/src && \
    chmod -R g+w /tmp/src && \
    rm -rf /tmp/scripts && \
    mv /tmp/src/.s2i/bin /tmp/scripts && \
    mkdir -p /usr/src/root && \
    chown -R 1001 /usr/src/root && \
    chown -R 1001 /usr/local && \
    chown -R 1001 /opt/app-root

USER 1001

### Install Python 3 packages using conda
# RUN conda install --quiet --yes \
#     'beautifulsoup4=4.9.*' \
#     'conda-forge::blas=*=openblas' \
#     'bokeh=2.2.*' \
#     'bottleneck=1.3.*' \
#     'cloudpickle=1.6.*' \
#     'cython=0.29.*' \
#     'dask=2.25.*' \
#     'dill=0.3.*' \
#     'h5py=2.10.*' \
#     'ipywidgets=7.5.*' \
#     'ipympl=0.5.*'\
#     'matplotlib-base=3.3.*' \
#     'numba=0.51.*' \
#     'numexpr=2.7.*' \
#     'pandas=1.1.*' \
#     'patsy=0.5.*' \
#     'protobuf=3.12.*' \
#     'pytables=3.6.*' \
#     'scikit-image=0.17.*' \
#     'scikit-learn=0.23.*' \
#     'scipy=1.5.*' \
#     'seaborn=0.11.*' \
#     'sqlalchemy=1.3.*' \
#     'statsmodels=0.12.*' \
#     'sympy=1.6.*' \
#     'vincent=0.4.*' \
#     'widgetsnbextension=3.5.*'\
#     'xlrd=1.2.*' && \
#     conda clean --all -f -y && \
#     # Activate ipywidgets extension in the environment that runs the notebook server
#     jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
#     # Also activate ipywidgets extension for JupyterLab
#     # Check this URL for most recent compatibilities
#     # https://github.com/jupyter-widgets/ipywidgets/tree/master/packages/jupyterlab-manager
#     jupyter labextension install @jupyter-widgets/jupyterlab-manager@^2.0.0 --no-build && \
#     jupyter labextension install @bokeh/jupyter_bokeh@^2.0.0 --no-build && \
#     jupyter labextension install jupyter-matplotlib@^0.7.2 --no-build && \
#     jupyter lab build -y && \
#     jupyter lab clean -y && \
#     npm cache clean --force && \
#     rm -rf "/home/${NB_USER}/.cache/yarn" && \
#     rm -rf "/home/${NB_USER}/.node-gyp"


# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot"


# Install pyarrow
# RUN conda install --quiet --yes --satisfied-skip-solve 'pyarrow=1.0.*'

# R packages
# RUN conda install --quiet --yes \
#     'r-base=3.6.3' \
#     'r-ggplot2=3.3*' \
#     'r-irkernel=1.1*' \
#     'r-rcurl=1.98*' \
#     'r-sparklyr=1.2*'

# Spylon-kernel
# RUN conda install --quiet --yes 'spylon-kernel=0.4*' && \
#     conda clean --all -f -y && \
#     python -m spylon_kernel install --sys-prefix && \
#     rm -rf "/home/${NB_USER}/.local"

# RUN conda clean --all -f -y && \
#     fix-permissions "${CONDA_DIR}" && \
#     fix-permissions "/home/${NB_USER}"


# Also activate ipywidgets/bokeh extension for JupyterLab.
# RUN jupyter nbextension enable --py widgetsnbextension --sys-prefix
# RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager@^1.0.1 --no-build
# RUN jupyter labextension install jupyterlab_bokeh@1.0.0 --no-build
# RUN jupyter lab build --minimize=False

# Fix permissions
RUN fix-permissions /opt/app-root

WORKDIR $HOME

ENV PYTHONPATH /usr/local/lib
ENV LD_LIBRARY_PATH "$LD_LIBRARY_PATH:/usr/local/lib/"

# RUN /tmp/scripts/assemble

CMD [ "/opt/app-root/builder/run" ]