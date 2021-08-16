FROM python:3.5
# TODO: might need to start from fsl build and then install jupyterlab/vscode
# Or NeuroDesk

LABEL org.opencontainers.image.source="https://github.com/MaastrichtU-IDS/jupyterlab"

WORKDIR /root

RUN pip install notebook jupyterlab git+https://github.com/jersaal/img_pipe

ENTRYPOINT ["jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--no-browser"]
