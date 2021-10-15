Start on the DSRI with Helm:

```bash
helm install freesurfer dsri/jupyterlab \
  --set serviceAccount.name=anyuid \
  --set openshiftRoute.enabled=true \
  --set image.repository=ghcr.io/maastrichtu-ids/jupyterlab \
  --set image.tag=freesurfer \
  --set storage.mountPath=/root \
  --set password=changeme
```

