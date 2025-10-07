FROM ghcr.io/maastrichtu-library/ricopili:2025_jan_30.003

LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab"

WORKDIR /root

RUN apt-get update && \
    apt-get install -y python3-pip python3-dev python3-venv r-base r-base-dev && \
    python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install notebook jupyterlab

# Add venv to PATH
ENV PATH="/opt/venv/bin:$PATH"

# Install R kernel for Jupyter
RUN R -e "install.packages('IRkernel', repos='https://cloud.r-project.org/')" && \
    R -e "IRkernel::installspec(user = FALSE)"

EXPOSE 8888

ENTRYPOINT ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--port=8888", "--no-browser"]
