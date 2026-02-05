import os

git_url = os.getenv('GIT_URL', None)
git_name = os.getenv('GIT_NAME', 'Default user')
git_email = os.getenv('GIT_EMAIL', 'default@maastrichtuniversity.nl')
persistent_folder = os.getenv('PERSISTENT_FOLDER', None)
workspace = os.getenv('WORKSPACE', None)

# Preconfigure git to avoid to do it manually
os.system('git config --global user.name "' + git_name + '"')
os.system('git config --global user.email "' + git_email + '"')

c.ServerApp.terminado_settings = {'shell_command': ['/bin/bash']}

# If there is only a persistent folder given, then change dir to that folder
# If workspace is given, change dir to overall workspace, where persistent folder resides in
if persistent_folder:
    os.chdir(persistent_folder)

if workspace:
    os.chdir(workspace)

if git_url:
    os.system('git clone --quiet --recursive ' + git_url)
    repo_id = git_url.rsplit('/', 1)[-1].rsplit('.git', 1)[0]
    print(f'📥️ Cloning {repo_id}')
    os.chdir(repo_id)

if os.path.exists('packages.txt'):
    os.system('sudo apt-get update')
    os.system('cat packages.txt | xargs sudo apt-get install -y')

if os.path.exists('requirements.txt'):
    os.system('pip install -r requirements.txt')

if os.path.exists('extensions.txt'):
    os.system('cat extensions.txt | xargs -I {} jupyter {} install --user')