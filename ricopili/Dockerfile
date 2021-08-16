FROM bruggerk/ricopili:latest

LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab"

WORKDIR /root

RUN apt-get update && \
    apt-get install -y python3-pip python3-dev && \
    pip3 install notebook jupyterlab

EXPOSE 8888
ENTRYPOINT ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser"]