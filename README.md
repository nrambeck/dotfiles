#Dotfiles

Nathan Rambeck's dotfiles for OS X and Linux.

##Installation

###OS X

To install these dotfiles, run the following commands in your home directory.

    git clone https://github.com/nrambeck/dotfiles.git .dotfiles
    cd .dotfiles
    ./bootstrap.sh

##What's included

My dotfiles are geared towards development with Drupal so it includes Drush and various scripts that make Drupal development easier. Here is a complete list.

- .gitconfig - a configuration file for git with all the aliases I uses (and some I don't ever get around to)
- .gitignore - a global git ignore file with files that are ignored in every project
- drush - submodule of the drush project along with a symlinked bin file so the drush command just works
- .zshrc - configuration file for the ZSH shell. This has a dependency on OhMyZSH. I still need to cover that dependency in the boostrap script.
- .aliases - a collection of shell aliases
- .commonrc - configration file for all shells and systems- drupal-sync - a script for syncing database dumps and user files from one environment to another. this requires that you setup drush aliases correctly. more documentation forthcoming.
- drupal-upgrade - a script that will upgrade to a new minor version of Drupal core automatically. includes backups up files and database in case something goes wrong. please don't use this on production sites (you've been warned).
- newsite - I use this script to setup a new development site locally
