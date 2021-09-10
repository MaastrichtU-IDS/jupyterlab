## JupyterLab for knowledge graphs and data science

[![Publish Docker image](https://github.com/MaastrichtU-IDS/jupyterlab/actions/workflows/publish-docker.yml/badge.svg)](https://github.com/MaastrichtU-IDS/jupyterlab/actions/workflows/publish-docker.yml)

JupyterLab image based on the [jupyter/docker-stacks](https://github.com/jupyter/docker-stacks) scipy image, with additional packages and kernels installed for data science and knowledge graphs. 

> This image is compatible with OpenShift security constraints, see below for more information to deploy on OpenShift, or on the [Data Science Research Infrastructure (DSRI)](https://maastrichtu-ids.github.io/dsri-documentation/docs/deploy-jupyter) at Maastricht University 🌉

**Installed kernels**

🐍 Python 3.8 kernel with autocomplete and suggestions ([jupyterlab-lsp 💬](https://github.com/krassowski/jupyterlab-lsp))

☕️ [IJava](https://github.com/SpencerPark/IJava) kernel with current default OpenJDK

✨️ [SPARQL kernel](https://github.com/paulovn/sparql-kernel) to query RDF knowledge graphs

**Installed extensions**

* [jupyterlab-git](https://github.com/jupyterlab/jupyterlab-git)
* [jupyterlab-system-monitor](https://github.com/jtpio/jupyterlab-system-monitor) to monitor the resources used
* [jupyter_bokeh](https://github.com/bokeh/jupyter_bokeh)
* [plotly](https://github.com/plotly/plotly.py)
* [jupyterlab-spreadsheet](https://github.com/quigleyj97/jupyterlab-spreadsheet)
* [jupyterlab-drawio](https://github.com/QuantStack/jupyterlab-drawio)

**Additional programs**

Some `.jar` programs for knowledge graph processing are pre-downloaded in `/opt` in the image: RDF4J, Apache Jena, OWLAPI, RML mapper, etc.

## Customize your JupyterLab image

Choose which image fits your need: base image, gpu, FSL, FreeSurfer, Python2,7

1. Fork this repository.
2. Clone the fork repository 
3. Edit the `Dockerfile` for this image to install the packages you need. Preferably use `conda` to install new packages, you can also install with `apt-get` (need to run as root or with `sudo`) and `pip`

4. Go to the folder and rebuild the `Dockerfile`:

```bash
docker build -t jupyterlab .
```

5. Run the docker image built on http://localhost:8888

```bash
docker run -it --rm -p 8888:8888 -e JUPYTER_TOKEN=yourpassword ghcr.io/maastrichtu-ids/jupyterlab:latest
```

If the built Docker image works well feel free to send a pull request to get your changes merged to the main repository and integrated in the corresponding published Docker image.

## Run with Docker 🐳

Volumes can be mounted into `/home/jovyan` folder.

Run as `jovyan` user with `sudo` privileges, use `JUPYTER_TOKEN` to define your password:

```bash
docker run --rm -it --user root -p 8888:8888 -e GRANT_SUDO=yes -e JUPYTER_TOKEN=password -v $(pwd)/data:/home/jovyan ghcr.io/maastrichtu-ids/jupyterlab
```

> You should now be able to install anything in the JupyterLab container, try:
>
> ```bash
> sudo apt-get update
> ```

You can check the `docker-compose.yml` file to run it easily with Docker Compose.

Run with a restricted `jovyan` user, without `sudo` privileges:

```bash
docker run --rm -it --user $(id -u) -p 8888:8888 -e JUPYTER_TOKEN=password -v $(pwd)/data:/home/jovyan ghcr.io/maastrichtu-ids/jupyterlab
```

Potential permission issue when running locally ⚠️

The official [jupyter/docker-stacks](jupyter/docker-stacks) images use the `jovyan` user by default which does not grant admin rights (`sudo`). This can cause issues when writing to the shared volumes, to fix it you can change the owner of the folder, or start JupyterLab as root user.

Create the folder with the right permissions, replace `1000` by your username

```bash
mkdir -p data/
sudo chown -R 1000:1000 data/
```

## Deploy on OpenShift ☁️

* See this template to [deploy JupyterLab on OpenShift with `sudo` privileges](https://github.com/MaastrichtU-IDS/dsri-documentation/blob/master/applications/templates/template-jupyterlab-root.yml).
* See this template to [deploy JupyterLab on OpenShift with restricted user](https://github.com/MaastrichtU-IDS/dsri-documentation/blob/master/applications/templates/restricted/template-jupyterlab-restricted.yml).

If you are working or studying at Maastricht University you can easily [deploy this notebook on the Data Science Research Infrastructure (DSRI)](https://maastrichtu-ids.github.io/dsri-documentation/docs/deploy-jupyter).

## Build and publish 📦

This repository contains multiple folders with `Dockerfile` to build various flavor of JupyterLab for Data Science.

### JupyterLab for knowledge graphs

With Python 3+, Java and SPARQL kernel

Build:

```bash
docker build -t ghcr.io/maastrichtu-ids/jupyterlab .
```

Run:

```bash
docker run --rm -it --user root -p 8888:8888 -e JUPYTER_TOKEN=password -v $(pwd)/data:/home/jovyan ghcr.io/maastrichtu-ids/jupyterlab
```

Push:

```bash
docker push ghcr.io/maastrichtu-ids/jupyterlab
```

## GPU

Based on the [official Nvidia Tensorflow image](https://ngc.nvidia.com/catalog/containers/nvidia:tensorflow) with `conda` and `jupyterlab`, from the root folder of this repository, build:

```bash
docker build --build-arg NVIDIA_IMAGE=nvcr.io/nvidia/tensorflow:21.08-tf2-py3 -f gpu/Dockerfile -t ghcr.io/maastrichtu-ids/jupyterlab:tensorflow .
```

> For PyTorch, change the `NVIDIA_IMAGE` to use the [official Nvidia PyTorch image](https://ngc.nvidia.com/catalog/containers/nvidia:pytorch)

Run it:

```bash
docker run --rm -it -p 8888:8888 -e JUPYTER_TOKEN=password -v $(pwd)/data:/root ghcr.io/maastrichtu-ids/jupyterlab:tensorflow
```

### Python 2.7

With a python2.7 kernel (python3 not installed)

Build:

```bash
cd python2.7
docker build -t ghcr.io/maastrichtu-ids/jupyterlab:python2.7 .
```

Run (workdir is `/root`):

```bash
docker run --rm -it -p 8888:8888 -e JUPYTER_TOKEN=password ghcr.io/maastrichtu-ids/jupyterlab:python2.7
```

### Ricopili

Based on https://github.com/bruggerk/ricopili_docker

Build:

```bash
cd ricopili
docker build -t ghcr.io/maastrichtu-ids/jupyterlab:ricopili .
```

Run (workdir is `/root`):

```bash
docker run --rm -it -p 8888:8888 -v $(pwd)/data:/root -e JUPYTER_TOKEN=password ghcr.io/maastrichtu-ids/jupyterlab:ricopili
```

### FSL on CPU

Built with https://github.com/ReproNim/neurodocker

Build:

```bash
cd fsl
docker build -t ghcr.io/maastrichtu-ids/jupyterlab:fsl .
```

Run (workdir is `/root`):

```bash
docker run --rm -it -p 8888:8888 -v $(pwd)/data:/root -e JUPYTER_TOKEN=password ghcr.io/maastrichtu-ids/jupyterlab:fsl
```

