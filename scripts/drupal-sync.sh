#!/bin/bash

if [ ! $1 ]
then
  echo "Usage:"
  echo " drupal-sync site_shortname [push|pull]"
  echo "Example:"
  echo " drupal-sync acme push"
  exit
 fi

if [ "$2" == "push" ]
then
  target="$1.dev"
  src="$1.local"
else
  target="$1.local"
  src="$1.dev"
fi

echo "Syncing database from $src to $target"
drush sql-sync --temp --no-cache @$src @$target

echo "Syncing files from $src to $target"
drush rsync -O @$src:%files @$target:%files

echo "Clearing the cache on $target"
drush @$target cc all

echo "Sync complete!"


