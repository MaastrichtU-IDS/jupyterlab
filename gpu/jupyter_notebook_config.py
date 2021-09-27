import os

git_url = os.getenv('GIT_URL', None)

if git_url:
    repo_id = git_url.rsplit('/', 1)[-1].replace('.git', '')
    os.system('git clone --quiet --recursive ' + git_url + '')
    os.chdir(repo_id)

if os.path.exists('packages.txt'):
    os.system('sudo apt-get update')
    os.system('cat packages.txt | xargs sudo apt-get install -y')

if os.path.exists('requirements.txt'):
    os.system('pip install -r requirements.txt')

if os.path.exists('extensions.txt'):
    os.system('cat extensions.txt | xargs -I {} jupyter {} install --user')