FROM ghcr.io/maastrichtu-ids/jupyterlab:latest

LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab"

USER root

# Install Oxigraph SPARQL endpoint
RUN wget -O /usr/local/bin/oxigraph_server https://github.com/vemonet/oxigraph/releases/download/v0.2.5/oxigraph_server && \
    chmod +x /usr/local/bin/oxigraph_server

COPY jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py

USER ${NB_UID}

# Install Blazegraph SPARQL endpoint
RUN wget -O /opt/blazegraph.jar https://github.com/blazegraph/database/releases/download/BLAZEGRAPH_2_1_6_RC/blazegraph.jar
