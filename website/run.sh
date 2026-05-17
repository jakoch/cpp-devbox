#!/bin/zsh

jekyll build clean

clear

#
# LiveReload isn't working properly in a Docker environment.
# Force polling is enabled as a workaround.
#

jekyll serve \
  --host 127.0.0.1 \
  --port 4000 \
  --force_polling \
  --config _config.yml,_dev_config.yml \
  --open-url

