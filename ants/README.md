# ANTs with JupyterLab
ANTs (Advanced Normalization Tools) neuroimaging analysis tools with JupyterLab, built on a Python 3.12 base.

## Usage
```bash
docker run -p 8888:8888 ghcr.io/maastrichtu-library/ants:dev
```

Access JupyterLab at http://localhost:8888

## What's Included
- ANTs version 2.6.4 (https://github.com/ANTsX/ANTs/releases)
- JupyterLab

## Building Locally
```bash
docker build -t ants:test .
```

## Testing ANTs
Open a terminal in JupyterLab and run:
```bash
antsRegistration --version  # Should show version info
echo $ANTSPATH  # Should show /opt/ants/bin
```

## Credits
ANTs is developed at https://github.com/ANTsX/ANTs.
This optimized image is maintained by RCS.