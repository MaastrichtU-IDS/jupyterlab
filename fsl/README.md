# FSL with JupyterLab
FSL (FMRIB Software Library) neuroimaging analysis tools with JupyterLab, built on a Python 3.12 base.

## Important: CLI vs GUI
This is a **standalone JupyterLab image** intended for Command Line (CLI) processing. 

- **Use this image if:** You are running scripts, notebooks, or terminal commands like `bet`, `flirt`, or `fslmaths`.
- **Use the Ubuntu VNC Pre-processing image if:** You need to use FSL Graphical Interfaces (GUIs) like `fsleyes` or the main `fsl` menu.

## Usage
```bash
docker run -p 8888:8888 ghcr.io/maastrichtu-library/fsl:dev
```

Access JupyterLab at http://localhost:8888

## What's Included
- FSL (latest version via official installer)
- JupyterLab

## Building Locally
```bash
docker build -t fsl:test .
```

## Testing FSL
Open a terminal in JupyterLab and run:
```bash
fslinfo  # Should show usage
echo $FSLDIR  # Should show /usr/local/fsl
```

## Credits
FSL is developed by the Analysis Group, FMRIB, Oxford, UK.
This optimized image is maintained by RCS.