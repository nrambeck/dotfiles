#!/bin/bash

if [ ! $1 ]; then
  echo "Usage:"
  echo " $0 site_shortname [push|pull]"
  echo "Example:"
  echo " $0 acme push"
  exit
 fi

if [ $2 == 'push']; then
  target = "$1.dev"
  source = "$1.local"
else
  target = "$1.local"
  source = "$1.dev"
fi

echo "Syncing database from $source to $target"
drush sql-sync --temp --no-cache @$source @$target -y

echo "Syncing files from DEV to LOCAL"
drush rsync -O @$source:%files @$target:%files -y

drush @$target cc all

echo "Sync complete!"


