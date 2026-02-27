# FSL with JupyterLab

This image provides a standalone [FSL (FMRIB Software Library)](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/) workspace based on the standard DSRI JupyterLab environment. It is optimized for neuroimaging researchers who need FSL tools within a web-based Python interface.

## What's Included

- **FSL 6.0.7**: Full installation including all command-line binaries and atlases.
- **JupyterLab**: The standard IDS interface with Python/Conda support.
- **Pre-configured Environment**: `FSLDIR` and `PATH` are set up automatically.

## Usage on DSRI

The easiest way to use this image is via the **DSRI Catalog** using the "FSL with JupyterLab" template.

### Persistence
Researchers should store all notebooks and brain imaging data in the following directory to ensure it is saved between sessions:
`/home/jovyan/work/persistent`

## Local Usage (Docker)

If you want to run the image locally for testing:

```bash
docker run -it -p 8888:8888 ghcr.io/maastrichtu-library/fsl:dev
```
Access the interface at http://localhost:8888.

## Verification
To verify the installation inside the Jupyter terminal, run:

```bash
fslinfo           # Should display usage instructions
echo $FSLDIR      # Should display /usr/local/fsl
```

## Credits
FSL is written by the Analysis Group, FMRIB, Oxford, UK.
This Docker image is maintained by Research Computing Support at Maastricht University.