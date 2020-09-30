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

# Install jupyter RISE extension (with IJava).
RUN pip install jupyter_contrib-nbextensions RISE \
  && jupyter-nbextension install rise --py --system \
  && jupyter-nbextension enable rise --py --system \
  && jupyter contrib nbextension install --system \
  && jupyter nbextension enable hide_input/main
RUN rm ijava-kernel.zip

# Dependencies for matplotlib
RUN yum install -y dvipng

# Install Julia lang
RUN dnf copr enable nalimilan/julia
RUN yum install julia

## Permission setup from ROOT notebook
# COPY . /tmp/src

# RUN rm -rf /tmp/src/.git* && \
#     chown -R 1001 /tmp/src && \
#     chgrp -R 0 /tmp/src && \
#     chmod -R g+w /tmp/src && \
#     rm -rf /tmp/scripts && \
#     mv /tmp/src/.s2i/bin /tmp/scripts && \
#     mkdir -p /usr/src/root && \
#     chown -R 1001 /usr/src/root && \
#     chown -R 1001 /usr/local


USER 1001

# Add Julia packages. Only add HDF5 if this is not a test-only build since
# it takes roughly half the entire build time of all of the images on Travis
# to add this one package and often causes Travis to timeout.
#
# Install IJulia as jovyan and then move the kernelspec out
# to the system share location. Avoids problems with runtime UID change not
# taking effect properly on the .local folder in the jovyan home dir.
RUN julia -e 'import Pkg; Pkg.update()' && \
    (test $TEST_ONLY_BUILD || julia -e 'import Pkg; Pkg.add("HDF5")') && \
    julia -e "using Pkg; pkg\"add IJulia\"; pkg\"precompile\"" && \
    # move kernelspec out of home \
    mv "${HOME}/.local/share/jupyter/kernels/julia"* "${CONDA_DIR}/share/jupyter/kernels/" && \
    chmod -R go+rx "${CONDA_DIR}/share/jupyter" && \
    rm -rf "${HOME}/.local" && \
    fix-permissions "${JULIA_PKGDIR}" "${CONDA_DIR}/share/jupyter"

COPY . /tmp/src
RUN pip install -r /tmp/src/requirements.txt

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

# Install facets which does not have a pip or conda package at the moment
WORKDIR /tmp
RUN git clone https://github.com/PAIR-code/facets.git && \
    jupyter nbextension install facets/facets-dist/ --sys-prefix && \
    rm -rf /tmp/facets

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot"

### R packages including IRKernel which gets installed globally.
# RUN conda install --quiet --yes \
#     'r-base=3.6.3' \
#     'r-caret=6.0*' \
#     'r-crayon=1.3*' \
#     'r-devtools=2.3*' \
#     'r-forecast=8.13*' \
#     'r-hexbin=1.28*' \
#     'r-htmltools=0.5*' \
#     'r-htmlwidgets=1.5*' \
#     'r-irkernel=1.1*' \
#     'r-nycflights13=1.0*' \
#     'r-plyr=1.8*' \
#     'r-randomforest=4.6*' \
#     'r-rcurl=1.98*' \
#     'r-reshape2=1.4*' \
#     'r-rmarkdown=2.3*' \
#     'r-rsqlite=2.2*' \
#     'r-shiny=1.5*' \
#     'r-tidyverse=1.3*' \
#     'rpy2=3.3*'

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