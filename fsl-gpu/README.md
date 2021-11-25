## FSL on GPU

### Generate NeuroDockerfile

Generate FSL container with neurodocker (cf. [DSRI docs about Neurodocker](https://maastrichtu-ids.github.io/dsri-documentation/docs/neuroscience)) 

```bash
docker run --rm repronim/neurodocker:0.7.0 generate docker \
    --base debian:stretch --pkg-manager apt \
    --fsl version=6.0.3 > Dockerfile
```

### Build

Build the FSL for GPU container, based on Nvidia container for CUDA with JupyterLab, from the `Dockerfile` in this folder (cf. https://ngc.nvidia.com/catalog/containers/nvidia:cuda). Use CUDA version `9.1-devel-ubuntu16.04` (or `10.2-devel-ubuntu18.04` starting from FSL `6.0.5`)

```bash
docker build --build-arg CUDA_VERSION=nvcr.io/nvidia/cuda:10.2-devel-ubuntu18.04 -t ghcr.io/maastrichtu-ids/jupyterlab:fsl-gpu .
```

### Run

Test it on http://localhost:8888

```bash
docker run it -p 8888:8888 -e JUPYTER_TOKEN=password ghcr.io/maastrichtu-ids/jupyterlab:fsl-gpu
```

Push it:

```bash
docker push ghcr.io/maastrichtu-ids/jupyterlab:fsl-gpu
```

## Deploy with Helm

See https://github.com/MaastrichtU-IDS/dsri-helm-charts to install the Helm charts, then deploy in your current project on the DSRI (`oc project your-project`):

```bash
helm install jupyterlab-fsl dsri/jupyterlab \
  --set serviceAccount.name=anyuid \
  --set openshiftRoute.enabled=true \
  --set image.repository=ghcr.io/maastrichtu-ids/jupyterlab \
  --set image.tag=fsl-gpu \
  --set storage.mountPath=/workspace \
  --set resources.requests."nvidia\.com/gpu"=1 \
  --set resources.limits."nvidia\.com/gpu"=1 \
  --set password=changeme
```

Or use the values file:

```bash
helm install jupyterlab-fsl dsri/jupyterlab \
  -f fsl-deployment-values.yaml \
  --set password=changeme
```

