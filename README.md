## JupyterLab for data science and knowledge graphs

[![Publish Docker image](https://github.com/MaastrichtU-IDS/jupyterlab/actions/workflows/publish-docker.yml/badge.svg)](https://github.com/MaastrichtU-IDS/jupyterlab/actions/workflows/publish-docker.yml)

JupyterLab image based on the [jupyter/docker-stacks](https://github.com/jupyter/docker-stacks) scipy image, with additional packages and kernels installed for data science and knowledge graphs. 

> This image is compatible with OpenShift security constraints, see below for more information to deploy on OpenShift, or on the [Data Science Research Infrastructure (DSRI)](https://maastrichtu-ids.github.io/dsri-documentation/docs/deploy-jupyter) at Maastricht University 🌉

**Installed kernels**

🐍 Python 3.8 with autocomplete and suggestions ([jupyterlab-lsp 💬](https://github.com/krassowski/jupyterlab-lsp))

☕️ [IJava](https://github.com/SpencerPark/IJava) with current default OpenJDK

✨️ [SPARQL kernel](https://github.com/paulovn/sparql-kernel) to query RDF knowledge graphs

**Installed extensions**

* [jupyterlab-system-monitor](https://github.com/jtpio/jupyterlab-system-monitor) to monitor the resources used

* [jupyter_bokeh](https://github.com/bokeh/jupyter_bokeh)

* [plotly](https://github.com/plotly/plotly.py)

* [jupyterlab-spreadsheet](https://github.com/quigleyj97/jupyterlab-spreadsheet)

* [jupyterlab-drawio](https://github.com/QuantStack/jupyterlab-drawio)

**Wishlist**

🐙 [jupyterlab-git](https://github.com/jupyterlab/jupyterlab-git) does not work on jupyter/docker-stacks images

> Failed to load the jupyterlab-git server extension: The versions of the  JupyterLab Git server frontend and backend do not match. The  @jupyterlab/git frontend extension has version: 0.30.0b2 while the  python package has version 0.24.0. Please install identical version of  jupyterlab-git Python package and the @jupyterlab/git extension. Try  running: pip install --upgrade jupyterlab-git

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

Build:

```bash
docker build -t ghcr.io/maastrichtu-ids/jupyterlab .
```

Also available, build with a python2.7 kernel:

```bash
docker build -f Dockerfile.python27 -t ghcr.io/maastrichtu-ids/jupyterlab:python2.7 .
```

Run python2.7:

```bash
docker run --rm -it --user root -p 8888:8888 -e GRANT_SUDO=yes -e JUPYTER_TOKEN=password -v $(pwd)/data:/home/jovyan ghcr.io/maastrichtu-ids/jupyterlab
```

Push:

```bash
docker push ghcr.io/maastrichtu-ids/jupyterlab
```
