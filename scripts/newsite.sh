#!/bin/bash

sitesdir="/Users/nathan/Sites/"

# get domain
echo "What domain name? "
read domain

# get path
echo "What file path? (relative to $sitesdir): "
read path

fullpath="${sitesdir}${path}"

vhosts="/private/etc/apache2/extra/httpd-vhosts.conf"

# check if this site domain already exists
#if [ -f $fn ]; then
#  echo "A site with this domain already exists"
#  exit
#fi

echo "" >> $vhosts
echo "<VirtualHost *:80>" >> $vhosts
echo "  ServerName $domain" >> $vhosts
echo "  DocumentRoot \"$fullpath\"" >> $vhosts
echo "</VirtualHost>" >> $vhosts

echo "127.0.0.1       $domain" >> /etc/hosts

#a2ensite $domain
apachectl restart
