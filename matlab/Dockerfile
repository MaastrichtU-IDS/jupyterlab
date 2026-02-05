FROM ghcr.io/maastrichtu-ids/jupyterlab

# FROM jupyter/scipy-notebook:latest

LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab"

RUN pip install jupyter-matlab-proxy

# ENTRYPOINT [ "start-notebook.sh", "--no-browser", "--ip=0.0.0.0", "--config=/etc/jupyter/jupyter_notebook_config.py" ]