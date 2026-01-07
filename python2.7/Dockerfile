FROM python:2.7

LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab"

WORKDIR /root

RUN pip install notebook jupyterlab

EXPOSE 8888
ENTRYPOINT ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser"]