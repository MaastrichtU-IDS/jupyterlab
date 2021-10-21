#!/bin/bash
rsync -avhWO --no-perms --no-owner --no-group --no-compress --progress /opt/app-root/src/easybuild-data/ /opt/apps/easybuild/
