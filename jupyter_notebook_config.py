import os

git_url = os.environ.get('GIT_URL')
# home_dir = os.environ.get('HOME')
# os.chdir(home_dir)

c.NotebookApp.terminado_settings = {'shell_command': ['/bin/zsh']}

if git_url:
    # repo_id = git_url.rsplit('/', 1)[-1].replace('.git', '')
    os.system('git clone --quiet --recursive ' + git_url + ' work')
    # os.chdir(repo_id)

    if os.path.exists('packages.txt'):
        os.system('sudo apt-get update')
        os.system('cat packages.txt | xargs sudo apt-get install -y')

    if os.path.exists('requirements.txt'):
        os.system('pip install -r requirements.txt')

    if os.path.exists('extensions.txt'):
        os.system('cat extensions.txt | xargs -I {} jupyter {} install --user')

os.chdir('work')