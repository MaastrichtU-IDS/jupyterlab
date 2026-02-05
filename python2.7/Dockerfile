FROM python:3.11-bullseye

LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab/tree/main/python2.7"

WORKDIR /root

RUN pip install jupyterlab notebook

# Install Python 2.7
RUN apt-get update && apt-get install -y \
    python2.7 \
    python2.7-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install pip for Python 2.7
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py && \
    python2.7 get-pip.py && \
    rm get-pip.py

# Install ipykernel for Python 2.7
RUN python2.7 -m pip install ipykernel==4.10.1
RUN python2.7 -m ipykernel install --name python2 --display-name "Python 2.7"

SHELL ["/bin/bash", "-c"]
ENV SHELL=/bin/bash

ADD README.ipynb /root

EXPOSE 8888
ENTRYPOINT ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser"]


# To have python 2 and 3 in a container, check https://github.com/cclauss/Python2-and-Python3-in-Docker

# Seems like we cant conda activate in jupyter/docker-stacks images: 
# https://stackoverflow.com/questions/58442800/how-do-i-create-a-docker-container-with-both-python-2-and-3-available-in-jupyter

# FROM jupyter/scipy-notebook:latest
# ENV JUPYTER_ENABLE_LAB=yes

# USER $NB_USER
# ENV BASH_ENV ~/.bashrc
# SHELL ["/bin/bash", "--login", "-c"]

# RUN conda create -n py27 python=2.7 && \
#     conda init /bin/bash && \
#     conda activate py27 && \
#     conda install notebook ipykernel && \
#     ipython kernel install --user

# RUN jupyter labextension update --all
# RUN jupyter lab build 