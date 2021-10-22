import os

git_url = os.getenv('GIT_URL', None)
git_name = os.getenv('GIT_NAME', 'Default user')
git_email = os.getenv('GIT_EMAIL', 'default@maastrichtuniversity.nl')

# Preconfigure git to avoid to do it manually
os.system('git config --global user.name "' + git_name + '"')
os.system('git config --global user.email "' + git_email + '"')

os.chdir('/home/jovyan/work')

if git_url:
    # repo_id = git_url.rsplit('/', 1)[-1].replace('.git', '')
    os.system('git clone --quiet --recursive ' + git_url + ' .')
    # os.chdir(repo_id)
    # os.chdir('work')

if os.path.exists('packages.txt'):
    os.system('sudo apt-get update')
    os.system('cat packages.txt | xargs sudo apt-get install -y')

if os.path.exists('requirements.txt'):
    os.system('pip install -r requirements.txt')

if os.path.exists('extensions.txt'):
    os.system('cat extensions.txt | xargs -I {} jupyter {} install --user')

# home_dir = os.environ.get('HOME')
# os.chdir(home_dir)
# c.NotebookApp.terminado_settings = {'shell_command': ['/bin/zsh']}


# Fix launcher icons loaded from lmod modules
# https://github.com/cmd-ntrf/jupyter-lmod#jupyterlab-server-proxy
# https://github.com/guimou/s2i-lmod-notebook/blob/main/packages/jupyterlmodlauncher/jupyterlmodlauncher/__init__.py

c.ServerProxy.servers = {
    "code-server": {
        "command": [
            "code-server",
            "--auth=none",
            "--disable-telemetry",
            "--host=127.0.0.1",
            "--port={port}",
            os.getenv("JUPYTER_SERVER_ROOT", ".")
        ],
        "timeout": 20,
        "launcher_entry": {
            "title": "VS Code",
            "enabled" : False
        },
    },
    "rstudio": {
        "command": [
            "rserver",
            f"--www-port={port}",
            "--www-frame-origin=same",
            "--www-address=127.0.0.1"
            "--auth-none=1",
            "--www-frame-origin=same",
            "--www-address=127.0.0.1",
            "--server-data-dir=/opt/app-root/rstudio-server",
            "--server-daemonize=0",
            "--server-user=rstudio-server",
            f"--server-working-dir={os.getenv('JUPYTER_SERVER_ROOT', '.')}"
        ],
        "timeout": 20,
        "launcher_entry": {
                "title": "RStudio",
                "enabled" : False
        },
    }
}

# Automatically load modules at start
# import lmod
# await lmod.purge(force=True)
# await lmod.load('FlexiBLAS/3.0.4-GCC-10.3.0', 'Python/3.9.5-GCCcore-10.3.0', 'protobuf/3.17.3-GCCcore-10.3.0', 'protobuf-python/3.17.3-GCCcore-10.3.0', 'SciPy-bundle/2021.05-foss-2021a', 'typing-extensions/3.10.0.0-GCCcore-10.3.0', 'libyaml/0.2.5-GCCcore-10.3.0', 'PyYAML/5.4.1-GCCcore-10.3.0', 'MPFR/4.1.0-GCCcore-10.3.0', 'LAME/3.100-GCCcore-10.3.0', 'X11/20210518-GCCcore-10.3.0', 'FriBidi/1.0.10-GCCcore-10.3.0', 'FFmpeg/4.3.2-GCCcore-10.3.0', 'Pillow/8.2.0-GCCcore-10.3.0', 'PyTorch/1.9.0-foss-2021a')