https://github.com/guimou/odh-highlander

https://github.com/guimou/odh-highlander/tree/main/deploy

1. Create the PVC with Lmod modules in the same project as JupyterLab:


```bash
oc apply -f 01_easybuild-data_pvc.yaml
oc apply -f 02_easybuild-data_init.yaml
```

2. Start jupyterlab with shared volume to Lmod PVC:

```yaml
    volumes:
        - name: easybuild-data
          persistentVolumeClaim:
            claimName: easybuild-data
            readOnly: true
          mountPath: /opt/apps/easybuild
```

You can do it easily with the DSRI Helm chart for JupyterLab:

```bash
helm install jupyterlab dsri/jupyterlab \
  --set serviceAccount.name=anyuid \
  --set openshiftRoute.enabled=true \
  --set extraStorage[0].name=easybuild-data \
  --set extraStorage[0].mountPath=/opt/apps/easybuild \
  --set extraStorage[0].readOnly=true \
  --set password=changeme
```