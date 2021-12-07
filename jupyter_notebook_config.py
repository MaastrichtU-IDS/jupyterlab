import os

git_url = os.getenv('GIT_URL', None)
git_name = os.getenv('GIT_NAME', 'Default user')
git_email = os.getenv('GIT_EMAIL', 'default@maastrichtuniversity.nl')
persistent_workspace = os.getenv('PERSISTENT_WORKSPACE', None)
workspace = os.getenv('WORKSPACE', None)

# Preconfigure git to avoid to do it manually
os.system('git config --global user.name "' + git_name + '"')
os.system('git config --global user.email "' + git_email + '"')

# os.chdir('/home/jovyan/work')

if persistent_workspace:
    os.chdir(persistent_workspace)

if git_url:
    os.system('git clone --quiet --recursive ' + git_url + ' .')
    # repo_id = git_url.rsplit('/', 1)[-1].replace('.git', '')
    # os.system('git clone --quiet --recursive ' + git_url)
    # os.chdir(repo_id)

if os.path.exists('packages.txt'):
    os.system('sudo apt-get update')
    os.system('cat packages.txt | xargs sudo apt-get install -y')

if os.path.exists('requirements.txt'):
    os.system('pip install -r requirements.txt')

if os.path.exists('extensions.txt'):
    os.system('cat extensions.txt | xargs -I {} jupyter {} install --user')

if os.path.exists('environment.yml'):
    os.system('conda env create -f environment.yml')
    # os.system('mamba env create -f environment.yml')

if os.path.exists('environment.yaml'):
    os.system('conda env create -f environment.yaml')
    # os.system('mamba env create -f environment.yaml')

if workspace:
    os.chdir(workspace)

# https://github.com/jupyter/docker-stacks/blob/master/base-notebook/jupyter_notebook_config.py
# c = get_config() 


c.ServerApp.terminado_settings = {'shell_command': ['/bin/zsh']}

# Avoid duplicate conda kernel starters https://github.com/Anaconda-Platform/nb_conda_kernels/issues/141
# c.NotebookApp.kernel_spec_manager_class = 'nb_conda_kernels.CondaKernelSpecManager'
# c.CondaKernelSpecManager.env_filter = '/opt/conda/share/jupyter/kernels/*'
# c.ServerApp.kernel_spec_manager_class = 'nb_conda_kernels.CondaKernelSpecManager'
# c.CondaKernelSpecManager.env_filter = '/opt/conda/share/jupyter/kernels/*|/usr/local/share/jupyter/kernels/sparql'

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
            "icon_path": "/etc/jupyter/vscode.svg",
            "enabled" : True
        },
    },
    "oxigraph-sparql": {
        "command": [
            "oxigraph_server",
            "--bind",
            "0.0.0.0:{port}",
            "--location",
            os.getenv("JUPYTER_SERVER_ROOT", ".")
        ],
        "timeout": 20,
        "launcher_entry": {
            "title": "Oxigraph SPARQL endpoint",
            "icon_path": "/etc/jupyter/oxigraph.svg",
            "enabled" : True
        },
    },
    # "nanobench": {
    #     "command": [
    #         "java",
    #         "-jar", "/opt/nanobench/nanobench.jar",
    #         "-httpPort", "{port}",
    #         "-resetExtract"
    #     ],
    #     "timeout": 60,
    #     "launcher_entry": {
    #         "title": "Nanobench",
    #         "icon_path": "/etc/jupyter/rdf.svg",
    #         "enabled" : True
    #     },
    # },
    # "openrefine": {
    #     "command": [
    #         "refine",
    #         # "-i", "0.0.0.0",
    #         "-m", "2048m"
    #         "-p", "{port}"
    #     ],
    #     "timeout": 40,
    #     "launcher_entry": {
    #         "title": "OpenRefine",
    #         "icon_path": "/etc/jupyter/openrefine.svg",
    #         "enabled" : True
    #     },
    # }
}

# https://github.com/jupyter/notebook/issues/3130
# c.FileContentsManager.delete_to_trash = False