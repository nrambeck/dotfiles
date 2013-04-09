#!/bin/bash

# A script to upgrade a Drupal installation to the next minor version
# This script uses drush to initiate database updates; comment out lines beginning with "drush" if you don't have drush installed

TMP="/tmp"

# check for user input
if [ ! $@ ]; then
  echo
  echo "  Usage:"
  echo "    $0 VERSION [DIRECTORY]"
  echo
  echo "    VERSION: The new version to install"
  echo "    DIRECTORY: The relative path to your Drupal installation; if blank the current directory is assumed"
  echo
  echo "  Example usage:"
  echo "    $0 6.9 public_html/"
  echo
  exit 0
fi

VERSION=$1
if [ ! $2 ]; then
  SITEPATH="."
else
  SITEPATH=$2
fi

DRUPAL_VERSION="drupal-${VERSION}"
DRUPAL_PACKAGE="${DRUPAL_VERSION}.tar.gz"
TMP_FILE="${TMP}/${DRUPAL_PACKAGE}"

cd $SITEPATH

# Put the site offline
echo "Putting site in offline mode..."
drush vset --yes site_offline 1 > /dev/null

# backup core files
echo -n "Backing up current Drupal core files... "
tar -czf ../drupal-core.backup.tgz ./.htaccess ./*.php ./includes ./misc ./modules ./profiles ./scripts ./themes
echo "Done."

#backup database; use result-file option to prevent charset corruption
echo -n "Backing up current Drupal database... "
drush sql-dump --result-file=../drupal-upgrade.backup.sql.tgz
echo "Done."

# example download link http://ftp.drupal.org/files/projects/drupal-6.9.tar.gz
DOWNLOAD="http://ftp.drupal.org/files/projects/${DRUPAL_PACKAGE}"
echo -n "Start downloading $DRUPAL_PACKAGE... "
wget -q $DOWNLOAD
echo "Done."

echo -n "Upgrading Drupal core files... "
mv $DRUPAL_PACKAGE $TMP_FILE
tar -xzf $TMP_FILE --exclude-from=.htaccess -C $TMP

rm -rf "./includes"
cp -pr "${TMP}/${DRUPAL_VERSION}/includes" "./includes"
rm -rf "./misc"
cp -pr "${TMP}/${DRUPAL_VERSION}/misc" "./misc"
rm -rf "./modules"
cp -pr "${TMP}/${DRUPAL_VERSION}/modules" "./modules"
rm -rf "./profiles"
cp -pr "${TMP}/${DRUPAL_VERSION}/profiles" "./profiles"
rm -rf "./scripts"
cp -pr "${TMP}/${DRUPAL_VERSION}/scripts" "./scripts"
rm -rf "./themes"
cp -pr "${TMP}/${DRUPAL_VERSION}/themes" "./themes"
# The .htaccess file is purposely not copied
cp -p ${TMP}/${DRUPAL_VERSION}/*.* ./
rm $TMP_FILE
rm -rf "${TMP}/${DRUPAL_VERSION}/"

echo "Done."

echo -n "Upgrading Drupal database... "
yes | drush updatedb
echo "Done."

# Put the site back online
echo -n "Putting site back online... "
drush vset --yes site_offline 0 > /dev/null
echo "Done."

echo
echo -n "If something went horribly wrong type \"restore\" to restore from backup: "
read RESTORE

if [ "$RESTORE" = "restore" ]; then
  echo -n "Restoring database... "
  MYSQL_CONNECT=$(drush sql-connect)
  $MYSQL_CONNECT < ../drupal-upgrade.backup.sql.tgz
  echo "Done."

  echo -n "Restoring files... "
  tar -xzf ../drupal-core.backup.tgz -C ./
  echo "Done."

  drush vset --yes site_offline 0 > /dev/null
  echo "Your upgrade failed, but the backup was restored"
else
  echo "Your upgrade is complete"
fi

BACKUP_DIR=$(readlink -f ../)
echo "Backup files before the upgrade where saved in the following locations:"
echo "  ${BACKUP_DIR}/drupal-core.backup.tgz"
echo "  ${BACKUP_DIR}/drupal-upgrade.backup.sql.tgz"