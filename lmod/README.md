## Deploy EasyBuild volume with Lmod JupyterLab on DSRI

https://github.com/guimou/odh-highlander

https://github.com/guimou/odh-highlander/tree/main/deploy

1. Create the PVC with Lmod modules in the same project where you will start the JupyterLab:


```bash
oc apply -f 01_easybuild-data_pvc.yaml
oc apply -f 02_easybuild-data_init.yaml
```

> You can change the docker image used to provide the EasyBuild module in `02_easybuild-data_init.yaml`


2. Then start jupyterlab with shared volume to Lmod PVC:

```yaml
    volumes:
        - name: easybuild-data
          persistentVolumeClaim:
            claimName: easybuild-data
            readOnly: true
          mountPath: /opt/apps/easybuild
```

You can do it easily with the DSRI Helm chart for JupyterLab:

Install the chart repository, if not already done:

```bash
helm repo add dsri https://maastrichtu-ids.github.io/dsri-helm-charts/
helm repo update
```

Start JupyterLab with Lmod integration using Helm:

```bash
helm install jupyterlab dsri/jupyterlab \
  --set serviceAccount.name=anyuid \
  --set openshiftRoute.enabled=true \
  --set image.repository=ghcr.io/maastrichtu-ids/jupyterlab \
  --set image.tag=lmod \
  --set image.pullPolicy=Always \
  --set "extraStorage[0].name=easybuild-data" \
  --set "extraStorage[0].mountPath=/opt/apps/easybuild" \
  --set "extraStorage[0].readOnly=true" \
  --set password=changeme
```

> It will use the Docker image with Lmod, based on `jupyter/scipy-notebook` (debian), which is defined in the `Dockerfile` in this folder.

## Add more modules

Check out the full instructions to build modules with EasyBuild: https://github.com/guimou/odh-highlander/tree/main/easybuild-container-ubi8

### Build locally

You can build prepare the EasyBuild environment and add new modules locally:

1. Create the folder for EasyBuild data with the right permissions:

```bash
mkdir -p easybuild/easybuild-data
sudo chown -R 1002:1002 easybuild/easybuild-data
```

2. Start the EasyBuild container on your laptop with docker:

```bash
docker run --rm -it --name easybuild -v $(pwd)/easybuild/easybuild-data:/opt/apps/easybuild:z quay.io/guimou/easybuild-ubi8-py39 bash -c "/opt/app-root/src/easybuild_install.sh && bash"
```

> `/opt/apps/src/easybuild_install.sh` not found

3. Add a new EasyConfig repo, here `easybuild-easyconfigs` :

```bash
mkdir -p /opt/apps/easybuild/repos && cd /opt/apps/easybuild/repos
git clone https://github.com/easybuilders/easybuild-easyconfigs
sed -i '\!^robot-paths! s!$!:/opt/apps/easybuild/repos/easybuild-easyconfigs/!' /opt/apps/easybuild/easybuild.d/config.cfg
```

This will preinstall the modules in the initialized `./easybuild/easybuild-data` folder

> See also ODH easybuilds: https://github.com/guimou/odh-easyconfigs

### Build the easybuild-data image

After you added new EasyConfigs to the `./easybuild/easybuild-data` folder you can build the docker image with the new modules, and publish it:

```bash
cd easybuild
docker build . -t ghcr.io/maastrichtu-ids/easybuild-data:latest
```

> You can also define the complete process to run during `docker build`, checkout the `easybuild/Dockerfile`

### Build on the DSRI

Alternatively, instead of building it locally, you can spawn an easybuild environment on DSRI to build other modules or create your own ones in the `easybuild-data` volume in the current project.

Deploy the pre-built EasyBuild container

```bash
oc apply -f 05_easybuild_deployment.yaml
```

Then access it via the terminal and run the commands to install new EasyConfig repos and modules.

### Write EasyConfigs 

Instructions to write an EasyConfig file for a pip package: https://easybuilders.github.io/easybuild-tutorial/2021-lust/creating_easyconfig_files/#writing-easyconfig-files