
## JupyterLab for data science and knowledge graphs

JupyterLab image based on the [jupyter/docker-stacks](https://github.com/jupyter/docker-stacks) scipy image, compatible with OpenShift deployment, with additional packages and kernels installed for data science and knowledge graphs.

#### Installed kernels

🐍 Python 3.8 with autocomplete and suggestions ([LSP](https://github.com/krassowski/jupyterlab-lsp))

☕️ [IJava](https://github.com/SpencerPark/IJava) with current default OpenJDK

✨️ [SPARQL kernel](https://github.com/paulovn/sparql-kernel)

#### Installed Jupyterlab extensions

🐙 [jupyterlab-git](https://github.com/jupyterlab/jupyterlab-git)

💬 [jupyterlab-lsp](https://github.com/krassowski/jupyterlab-lsp)

Volumes can be mounted into `/home/jovyan` folder.

## Run with Docker 🐳

Run with restricted `jovyan` user, without `sudo` privileges:

```bash
docker run --rm -it --user $(id -u) -p 8888:8888 -e JUPYTER_TOKEN=password -v $(pwd)/data:/home/jovyan ghcr.io/maastrichtu-ids/jupyterlab
```

> Use `JUPYTER_TOKEN` or `JUPYTER_NOTEBOOK_PASSWORD` for password

Run and grant `sudo` privileges to the `jovyan` user:

```bash
docker run --rm -it --user root -p 8888:8888 -e GRANT_SUDO=yes -e JUPYTER_TOKEN=password -v $(pwd)/data:/home/jovyan ghcr.io/maastrichtu-ids/jupyterlab
```

> You should now be able to install anything in the JupyterLab container, try:
>
> ```bash
> sudo apt install vim
> ```
>

Check the `docker-compose.yml` to run with Docker Compose:

**Potential permission issue ⚠️**

The official [jupyter/docker-stacks](jupyter/docker-stacks) images use the `jovyan` user by default which does not grant admin rights (`sudo`). 

This can cause issues when writing to the shared volumes, to fix it you can change the owner of the folder or start JupyterLab as root user:

Create the folder with right permission

```bash
mkdir -p data/jupyterlab
sudo chown -R 1000:1000 data/jupyterlab
```

Then run JupyterLab with sudo privileges

## Deploy on OpenShift ☁️

* See this template to deploy [JupyterLab on OpenShift with restricted user](https://github.com/MaastrichtU-IDS/dsri-openshift-applications/blob/main/okd4-templates-restricted/template-jupyterlab-restricted.yml).
* See this template to deploy [JupyterLab on OpenShift with `sudo` privileges](https://github.com/MaastrichtU-IDS/dsri-openshift-applications/blob/main/okd4-templates-anyuid/template-jupyterlab-root.yml).

If you are working or studying at Maastricht University you can easily [deploy this notebook on the Data Science Research Infrastructure (DSRI)](https://maastrichtu-ids.github.io/dsri-documentation/docs/deploy-jupyter).

## Build and publish 📦

Build:

```bash
docker build -t ghcr.io/maastrichtu-ids/jupyterlab .
```

Push:

```bash
docker push ghcr.io/maastrichtu-ids/jupyterlab
```

Using a specific `Dockerfile`:

```bash
docker build -f Dockerfile -t ghcr.io/maastrichtu-ids/jupyterlab .
```
