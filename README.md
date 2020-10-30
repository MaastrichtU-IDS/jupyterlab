
## Build custom JupyterLab image for OpenShift

JupyterLab with additional packages and kernel installed:

* Java 11 and Maven
* IJava kernel
* SPARQL kernel

```bash
docker build -t ghcr.io/maastrichtu-ids/jupyterlab-on-openshift .
```

Push:

```bash
docker push ghcr.io/maastrichtu-ids/jupyterlab-on-openshift
```

Using a specific Dockerfile:

```bash
docker build -f Dockerfile -t ghcr.io/maastrichtu-ids/jupyterlab-on-openshift .
```

Test run:

```bash
docker run --rm -it --name jupyterlab-on-openshift --user $(id -u) -p 8888:8888 -e VIRTUAL_HOST=jup.137.120.31.102.nip.io -e JUPYTER_TOKEN=password -v $(pwd):/home/jovyan ghcr.io/maastrichtu-ids/jupyterlab-on-openshift
```

> Use `JUPYTER_TOKEN` or `JUPYTER_NOTEBOOK_PASSWORD` for password

Run as `root` user:

```bash
docker run --rm -it --name jupyterlab-on-openshift --user root -p 8888:8888 -e GRANT_SUDO=yes -e VIRTUAL_HOST=jup.137.120.31.102.nip.io -e JUPYTER_TOKEN=password -v $(pwd):/home/jovyan ghcr.io/maastrichtu-ids/jupyterlab-on-openshift
```

Import simpleowlapi.jar in a Jupyter notebook:

```
%jars /opt/simpleowlapi.jar
```

