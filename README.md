Built based on https://github.com/jackfrost373/jupyter-root/tree/master/root-notebook

## Build custom code-server image

JupyterLab with additional packages and kernel installed:

* Jupyter `scipy` and `tensorflow` packages installed
* Java 11 and Maven
* IJava kernel
* SPARQL kernel
* Spark for Python

Build:

```bash
docker build -t ghcr.io/maastrichtu-ids/jupyterlab-on-openshift .
```

Run on http://localhost:8888

```bash
docker run -it --rm --name jupyterlab-on-openshift -p 8888:8888 -e JUPYTER_NOTEBOOK_PASSWORD=password ghcr.io/maastrichtu-ids/jupyterlab-on-openshift
```

Push updated image:

```bash
docker push ghcr.io/maastrichtu-ids/jupyterlab-on-openshift
```

### Java version

Jupyter `scipy` dependencies installed, Java and SPARQL kernel

```bash
docker build -f Dockerfile -t ghcr.io/maastrichtu-ids/jupyterlab-on-openshift:java .
```

### Spark version

All-spark version with tensorflow, spark installed (the most complete, but large image)

```bash
docker build -f Dockerfile -t ghcr.io/maastrichtu-ids/jupyterlab-on-openshift:spark .
```

### Julia version

> Not used or tested at the moment

Use different tags for different versions, e.g. for a Julia notebook build:

```bash
docker build -f julia.Dockerfile -t ghcr.io/maastrichtu-ids/jupyterlab-on-openshift:julia .
```

## JupyterHub with GitHub OAuth template

You can also find an OpenShift template based on [jackfrost373/jupyter-root](https://github.com/jackfrost373/jupyter-root) and https://github.com/jupyter-on-openshift/jupyterhub-quickstart

Add the template to your project:

```bash
oc apply -f template-jupyterhub.yml
```

