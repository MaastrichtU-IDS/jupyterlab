FROM ghcr.io/maastrichtu-library/ricopili:2025_jan_30.003

LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab"

WORKDIR /root

RUN apt-get update && \
    apt-get install -y python3-pip python3-dev python3-venv && \
    python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install notebook jupyterlab

EXPOSE 8888

ENTRYPOINT ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
