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
RUN rm -rf ijava-kernel

# Add fusion repo for ffmpeg
RUN yum localinstall -y --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm
# Dependencyies for matplotlib
RUN yum install -y ffmpeg dvipng

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

# Import matplotlib the first time to build the font cache.
# ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot"


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
ENV JUPYTER_NOTEBOOK_INTERFACE=lab
ENV JUPYTER_ENABLE_WEBDAV=true

EXPOSE 8080

# Home in /opt/app-root/src
# Username: default (1001)
# Size: 7.4G

# RUN /tmp/scripts/assemble

CMD [ "/opt/app-root/builder/run" ]