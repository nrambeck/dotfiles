#!/bin/bash
#
# bootstrap installs things.

DOTFILES_ROOT="`pwd`"

set -e

echo ''

info () {
  printf "  [ \033[00;34m..\033[0m ] $1\n"
}

user () {
  printf "\r  [ \033[0;33m?\033[0m ] $1 "
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

setup_gitconfig () {
  if ! [ -f git/gitconfig.symlink ]
  then
    info 'setup gitconfig'

    user ' - What is your github author name?'
    read -e git_authorname
    user ' - What is your github author email?'
    read -e git_authoremail

    sed -e "s/AUTHORNAME/$git_authorname/g" -e "s/AUTHOREMAIL/$git_authoremail/g" git/gitconfig.symlink.example > git/gitconfig.symlink

    success 'gitconfig'
  fi
}

link_files () {
  ln -s $1 $2
  success "linked $1 to $2"
}

install_zsh () {
  curl -L http://install.ohmyz.sh | sh
}

install_themes () {
  info 'installing themes'

  for source in `find $DOTFILES_ROOT -maxdepth 2 -name \*.zsh-theme`
  do
    dest="$HOME/.oh-my-zsh/themes/`basename \"${source}\"`"
    info "symlink theme $dest --> $source"

    if [ -f $dest ] || [ -d $dest ]
    then
      rm $dest
      link_files $source $dest
    else
      link_files $source $dest
    fi
  done
}

install_dotfiles () {
  info 'installing dotfiles'

  overwrite_all=false
  backup_all=false
  skip_all=false

  for source in `find $DOTFILES_ROOT -maxdepth 2 -name \*.symlink`
  do
    dest="$HOME/.`basename \"${source%.*}\"`"

    if [ -f $dest ] || [ -d $dest ]
    then

      overwrite=false
      backup=false
      skip=false

      if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
      then
        user "File already exists: `basename $source`, what do you want to do? [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac
      fi

      if [ "$overwrite" == "true" ] || [ "$overwrite_all" == "true" ]
      then
        rm -rf $dest
        success "removed $dest"
      fi

      if [ "$backup" == "true" ] || [ "$backup_all" == "true" ]
      then
        mv $dest $dest\.backup
        success "moved $dest to $dest.backup"
      fi

      if [ "$skip" == "false" ] && [ "$skip_all" == "false" ]
      then
        link_files $source $dest
      else
        success "skipped $source"
      fi

    else
      link_files $source $dest
    fi

  done
}

OMZ_SOURCE="source \$HOME/.zshrc-omz"

source_files() {
  info "$OMZ_SOURCE"
  if grep --quiet "$OMZ_SOURCE" $HOME/.zshrc; then
    info '.zshrc-omz already sourced in .zshrc file'
  else
    success 'sourcing .zshrc-omz in .zshrc file'
    echo "$OMZ_SOURCE" >> $HOME/.zshrc
  fi
}

# Grab latest version
git pull --rebase

# Install submodules
git submodule init
git submodule update

setup_gitconfig
install_zsh
install_dotfiles
install_themes
source_files

# Mac-only installations
if [ "$(uname -s)" == "Darwin" ]
then
  info "Mac-only installations"
fi

echo ''
echo '  All installed!'
