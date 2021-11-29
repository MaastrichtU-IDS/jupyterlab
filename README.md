## JupyterLab for knowledge graphs and data science

[![Publish Docker image](https://github.com/MaastrichtU-IDS/jupyterlab/actions/workflows/publish-docker.yml/badge.svg)](https://github.com/MaastrichtU-IDS/jupyterlab/actions/workflows/publish-docker.yml) [![Publish GPU image](https://github.com/MaastrichtU-IDS/jupyterlab/actions/workflows/publish-docker-gpu.yml/badge.svg)](https://github.com/MaastrichtU-IDS/jupyterlab/actions/workflows/publish-docker-gpu.yml)

JupyterLab image based on the [jupyter/docker-stacks](https://github.com/jupyter/docker-stacks) scipy image, with additional packages and kernels installed for data science and knowledge graphs. 

> This image is compatible with OpenShift security constraints, see below for more information to deploy on OpenShift, or on the [Data Science Research Infrastructure (DSRI)](https://maastrichtu-ids.github.io/dsri-documentation/docs/deploy-jupyter) at Maastricht University 🌉


![Screenshot](/icons/screenshot.png)

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

🧑‍💻 VisualStudio Code server (start it from the JupyterLab UI)

💎 OpenRefine (start it from the JupyterLab UI)

☕️ Some `.jar` programs for knowledge graph processing are pre-downloaded in the `/opt` folder, such as RDF4J, Apache Jena, OWLAPI, RML mapper.

**Automatically install your dependencies**

You can provide the URL to a git repository to be automatically cloned in the workspace at the start of the container.

The following file will be automatically installed if they are present at the root of the provided Git repository:

* The conda environment described in `environment.yml` will be installed, make sure you added `ipykernel` and `nb_conda_kernels` to the `environment.yml` to be able to easily start notebooks using this environment from the JupyterLab Launcher page. See [this repository as example]( https://github.com/MaastrichtU-IDS/dsri-demo).
* The packages in `requirements.txt` will be installed with `pip`
* The packages in `packages.txt` will be installed with `apt`
* The JupyterLab extensions in `extensions.txt` will be installed with `jupyter labextension`

You can also create conda environment in a running JupyterLab (we use `mamba` which is like `conda` but faster):

```bash
mamba env create -f environment.yml
```

You'll need to wait for 1 or 2 minutes before the new conda environment becomes available on the JupyterLab Launcher page.

### Extend the image

The easiest way to build a custom image is to extend the [existing images](https://github.com/MaastrichtU-IDS/jupyterlab).

Here is an example `Dockerfile` to extend [`ghcr.io/maastrichtu-ids/jupyterlab:latest`](https://github.com/MaastrichtU-IDS/jupyterlab/blob/main/Dockerfile) based on the jupyter/docker-stacks:

```dockerfile
FROM ghcr.io/maastrichtu-ids/jupyterlab:latest
# Change to root user to install packages requiring admin privileges:
USER root
RUN apt update && \
    apt install -y vim
# Switch back to the notebook user for other packages:
USER ${NB_UID}
RUN mamba install -c defaults -y rstudio
RUN pip install jupyter-rsession-proxy
```

For docker image that are not based on the jupyter/docker-stack, such as the GPU images defined by the [`gpu.dockerfile`](https://github.com/MaastrichtU-IDS/jupyterlab/blob/main/gpu.dockerfile), you will need to use the root user by default. For example:

```dockerfile
FROM ghcr.io/maastrichtu-ids/jupyterlab:tensorflow
RUN apt update && \
    apt install -y vim
RUN pip install jupyter-tensorboard
```

### Contribute to this repository

Choose which image fits your need: base image, gpu, FSL, FreeSurfer, Python2,7

1. Fork this repository.
2. Clone the forked repository 
3. Edit the `Dockerfile` for this image to install the packages you need. Preferably use `conda` to install new packages, you can also install with `apt-get` (need to run as root or with `sudo`) and `pip`

4. Go to the folder and rebuild the `Dockerfile`:

```bash
docker build -t jupyterlab -f Dockerfile .
```

5. Run the docker image built on http://localhost:8888

```bash
docker run -it --rm -p 8888:8888 -e JUPYTER_TOKEN=yourpassword ghcr.io/maastrichtu-ids/jupyterlab:latest
```

If the built Docker image works well feel free to send a pull request to get your changes merged to the main repository and integrated in the corresponding published Docker image.

You can check the size of the image built in MB:

```bash
expr $(docker image inspect ghcr.io/maastrichtu-ids/jupyterlab:latest --format='{{.Size}}') / 1000000
```

### Run with Docker 🐳

For the `ghcr.io/maastrichtu-ids/jupyterlab:latest` image volumes should be mounted into `/home/jovyan/work` folder.

This command will start JupyterLab as `jovyan` user with `sudo` privileges, use `JUPYTER_TOKEN` to define your password:

```bash
docker run --rm -it --user root -p 8888:8888 -e GRANT_SUDO=yes -e JUPYTER_TOKEN=password -v $(pwd)/data:/home/jovyan/work ghcr.io/maastrichtu-ids/jupyterlab
```

> You should now be able to install anything in the JupyterLab container, try:
>
> ```bash
> sudo apt-get update
> ```

You can check the `docker-compose.yml` file to run it easily with Docker Compose.

Run with a restricted `jovyan` user, without `sudo` privileges:

```bash
docker run --rm -it --user $(id -u) -p 8888:8888 -e CHOWN_HOME=yes -e CHOWN_HOME_OPTS='-R' -e JUPYTER_TOKEN=password -v $(pwd)/data:/home/jovyan/work ghcr.io/maastrichtu-ids/jupyterlab:latest
```

> ⚠️ Potential permission issue when running locally. The official [jupyter/docker-stacks](jupyter/docker-stacks) images use the `jovyan` user by default which does not grant admin rights (`sudo`). This can cause issues when writing to the shared volumes, to fix it you can change the owner of the folder, or start JupyterLab as root user.
>
> To create the folder with the right permissions, replace `1000:100` by your username:group if necessary and run:
>
> ```bash
>mkdir -p data/
> sudo chown -R 1000:100 data/
> ```
> 

### Build CPU images 📦

Instructions to build the various image aimed to run on CPU in this repository.

#### JupyterLab for Data Science

This repository contains multiple folders with `Dockerfile` to build various flavor of JupyterLab for Data Science.

With Python 3.8, conda integration, VisualStudio Code, Java and SPARQL kernels

Build:

```bash
docker build -t ghcr.io/maastrichtu-ids/jupyterlab .
```

Run:

```bash
docker run --rm -it --user root -p 8888:8888 -e JUPYTER_TOKEN=password -v $(pwd)/data:/home/jovyan/work ghcr.io/maastrichtu-ids/jupyterlab
```

Push:

```bash
docker push ghcr.io/maastrichtu-ids/jupyterlab
```

#### Python 2.7

With a python2.7 kernel only (python3 not installed). Build and run (workdir is `/root`):

```bash
cd python2.7
docker build -t ghcr.io/maastrichtu-ids/jupyterlab:python2.7 .
docker run --rm -it -p 8888:8888 -e JUPYTER_TOKEN=password ghcr.io/maastrichtu-ids/jupyterlab:python2.7
```

#### Ricopili

Based on https://github.com/bruggerk/ricopili_docker. Build and run (workdir is `/root`):

```bash
cd ricopili
docker build -t ghcr.io/maastrichtu-ids/jupyterlab:ricopili .
docker run --rm -it -p 8888:8888 -v $(pwd)/data:/root -e JUPYTER_TOKEN=password ghcr.io/maastrichtu-ids/jupyterlab:ricopili
```

#### FSL on CPU

Built with https://github.com/ReproNim/neurodocker. Build and run (workdir is `/root`):

```bash
cd fsl
docker build -t ghcr.io/maastrichtu-ids/jupyterlab:fsl .
docker run --rm -it -p 8888:8888 -v $(pwd)/data:/root -e JUPYTER_TOKEN=password ghcr.io/maastrichtu-ids/jupyterlab:fsl
```

## JupyterLab on GPU ⚡️

To deploy JupyterLab on GPU we use the [official Nvidia images](https://ngc.nvidia.com/catalog/containers/nvidia:tensorflow), we defined the same [`gpu.dockerfile`](https://github.com/MaastrichtU-IDS/jupyterlab/blob/main/gpu.dockerfile) to install additional dependencies, such as JupyterLab and VisualStudio Code, with different images from Nvidia:

* Tensorflow with [`nvcr.io/nvidia/tensorflow`](https://ngc.nvidia.com/catalog/containers/nvidia:tensorflow):
  * `ghcr.io/maastrichtu-ids/jupyterlab:tensorflow` 
* PyTorch with [`nvcr.io/nvidia/pytorch`](https://ngc.nvidia.com/catalog/containers/pytorch):
  * `ghcr.io/maastrichtu-ids/jupyterlab:pytorch` 

* CUDA with [`nvcr.io/nvidia/cuda`](https://ngc.nvidia.com/catalog/containers/cuda):
  * `ghcr.io/maastrichtu-ids/jupyterlab:cuda`


Volumes should be mounted into the `/workspace` folder.

### Extend an image 🏷️

The easiest way to build a custom image is to extend the [existing images](https://github.com/MaastrichtU-IDS/jupyterlab).

Here is an example `Dockerfile` to extend [`ghcr.io/maastrichtu-ids/jupyterlab:tensorflow`](https://github.com/MaastrichtU-IDS/jupyterlab/blob/main/gpu.dockerfile) based on `nvcr.io/nvidia/tensorflow`:

```dockerfile
FROM ghcr.io/maastrichtu-ids/jupyterlab:tensorflow
RUN apt update && \
    apt install -y vim
RUN pip install jupyter-tensorboard
```

### Build GPU images 📦

You will find here the commands to use to build our different GPU docker images, most of them are based on [`gpu.dockerfile`](https://github.com/MaastrichtU-IDS/jupyterlab/blob/main/gpu.dockerfile)

#### Tensorflow on GPU

Change the `build-arg` and run from the root folder of this repository:

```bash
docker build --build-arg NVIDIA_IMAGE=nvcr.io/nvidia/tensorflow:21.11-tf2-py3 -f gpu.dockerfile -t ghcr.io/maastrichtu-ids/jupyterlab:tensorflow .
```

Run an image on http://localhost:8888

```bash
docker run --rm -it -p 8888:8888 -e JUPYTER_TOKEN=password -v $(pwd)/data:/workspace/persistent ghcr.io/maastrichtu-ids/jupyterlab:tensorflow
```

#### CUDA on GPU

Change the `build-arg` and run from the root folder of this repository:

```bash
docker build --build-arg NVIDIA_IMAGE=nvcr.io/nvidia/cuda:11.4.2-devel-ubuntu20.04 -f gpu.dockerfile -t ghcr.io/maastrichtu-ids/jupyterlab:tensorflow .
```

Run an image on http://localhost:8888

```bash
docker run --rm -it -p 8888:8888 -e JUPYTER_TOKEN=password -v $(pwd)/data:/workspace/persistent ghcr.io/maastrichtu-ids/jupyterlab:cuda
```

#### PyTorch on GPU

Change the `build-arg` and run from the root folder of this repository:

```bash
docker build --build-arg NVIDIA_IMAGE=nvcr.io/nvidia/pytorch:21.11-py3 -f gpu.dockerfile -t ghcr.io/maastrichtu-ids/jupyterlab:pytorch .
```

Run an image on http://localhost:8888

```bash
docker run --rm -it -p 8888:8888 -e JUPYTER_TOKEN=password -v $(pwd)/data:/workspace/persistent ghcr.io/maastrichtu-ids/jupyterlab:pytorch
```

#### FSL on GPU

This build use a different image, go to the `fsl-gpu` folder. And check the `README.md` for more details.

Build:

```bash
cd fsl-gpu
docker build -t ghcr.io/maastrichtu-ids/jupyterlab:fsl-gpu .
```

Run (workdir is `/workspace`):

```bash
docker run --rm -it -p 8888:8888 -e JUPYTER_TOKEN=password ghcr.io/maastrichtu-ids/jupyterlab:fsl-gpu
```

## Deploy on Kubernetes and OpenShift ☁️

We recommend to use this Helm chart to deploy these JupyterLab images on Kubernetes or OpenShift: https://artifacthub.io/packages/helm/dsri-helm-charts/jupyterlab

If you are working or studying at Maastricht University you can easily [deploy this notebook on the Data Science Research Infrastructure (DSRI)](https://maastrichtu-ids.github.io/dsri-documentation/docs/deploy-jupyter).
