
## Build custom JupyterLab image

JupyterLab built from [jupyter/docker-stacks](https://github.com/jupyter/docker-stacks) images, compatible with OpenShift deployment, with additional packages and kernel installed:

* Java 11 and Maven
* [IJava kernel](https://github.com/SpencerPark/IJava)
* [SPARQL kernel](https://github.com/paulovn/sparql-kernel)

## Build and push

Build:

```bash
docker build -t ghcr.io/maastrichtu-ids/jupyterlab-on-openshift .
```

Push:

```bash
docker push ghcr.io/maastrichtu-ids/jupyterlab-on-openshift
```

Using a specific `Dockerfile`:

```bash
docker build -f Dockerfile -t ghcr.io/maastrichtu-ids/jupyterlab-on-openshift .
```

## Run

Test run:

```bash
docker run --rm -it --user $(id -u) -p 8888:8888 -e JUPYTER_TOKEN=password -v $(pwd):/home/jovyan ghcr.io/maastrichtu-ids/jupyterlab-on-openshift
```

> Use `JUPYTER_TOKEN` or `JUPYTER_NOTEBOOK_PASSWORD` for password

Run as `root` user:

```bash
docker run --rm -it --user root -p 8888:8888 -e GRANT_SUDO=yes -e JUPYTER_TOKEN=password -v $(pwd):/home/jovyan ghcr.io/maastrichtu-ids/jupyterlab-on-openshift
```

Check `docker-compose.yml` to run with Docker Compose:

```yaml
  jupyterlab:
    container_name: jupyterlab
    image: ghcr.io/maastrichtu-ids/jupyterlab-on-openshift
    user: root
    environment:
      - JUPYTER_TOKEN=dba
      - GRANT_SUDO=yes
    volumes:
      - ./data/jupyterlab:/home/jovyan
    ports:
      - 8888:8888
```

## Permission issue

The official Jupyter Docker image uses the `jovyan` user by default which does not have admin rights (`sudo`). 

This can cause issues when writing to the shared volumes, to fix it you can change the owner of the folder or start JupyterLab as root user:

### Create the folder with right permission

```bash
mkdir -p data/jupyterlab
sudo chown -R 1000:1000 data/jupyterlab
```

### And run JupyterLab with admin rights

Add the following to your `docker-compose.yml`:

```yaml
services:
  jupyterlab:
    user: root
    environment:
      - GRANT_SUDO=yes
```

You should now be able to install anything in the JupyterLab container, try:

```bash
sudo apt install vim
```

## Deploy on OpenShift

* See this template to deploy [JupyterLab on OpenShift with restricted user](https://github.com/MaastrichtU-IDS/dsri-openshift-applications/blob/main/templates-restricted/template-jupyterlab-dynamic.yml).

* See this template to deploy [JupyterLab on OpenShift with `sudo` privileges](https://github.com/MaastrichtU-IDS/dsri-openshift-applications/blob/main/okd4-templates-anyuid/template-jupyterlab-root-dynamic.yml).

