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
c.NotebookApp.terminado_settings = {'shell_command': ['/bin/zsh']}

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
    "openrefine": {
        "command": [
            "refine",
            # "-i", "0.0.0.0",
            "-m", "2048m"
            "-p", "{port}"
        ],
        "timeout": 40,
        "launcher_entry": {
            "title": "OpenRefine",
            "icon_path": "/etc/jupyter/openrefine.svg",
            "enabled" : True
        },
    }
}
