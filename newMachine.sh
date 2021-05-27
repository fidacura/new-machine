#!/bin/sh
# New Machine Setup 

machine_echo() {
  local fmt="$1"; shift
  printf "\n$fmt\n" "$@"
}

append_to_zshrc() {
  local text="$1" zshrc
  local skip_new_line="${2:-0}"

  if [ -w "$HOME/.zshrc.local" ]; then
    zshrc="$HOME/.zshrc.local"
  else
    zshrc="$HOME/.zshrc"
  fi

  if ! grep -Fqs "$text" "$zshrc"; then
    if [ "$skip_new_line" -eq 1 ]; then
      printf "%s\n" "$text" >> "$zshrc"
    else
      printf "\n%s\n" "$text" >> "$zshrc"
    fi
  fi
}

# warns if the script fails
trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

if [ ! -d "$HOME/.bin/" ]; then
  mkdir "$HOME/.bin"
fi

if [ ! -f "$HOME/.zshrc" ]; then
  touch "$HOME/.zshrc"
fi

# shellcheck disable=SC2016
append_to_zshrc 'export PATH="$HOME/.bin:$PATH"'

#
sudo chown -R $(whoami) /usr/local

# 
HOMEBREW_PREFIX="/usr/local"

if [ -d "$HOMEBREW_PREFIX" ]; then
  if ! [ -r "$HOMEBREW_PREFIX" ]; then
    sudo chown -R "$LOGNAME:admin" /usr/local
  fi
else
  sudo mkdir "$HOMEBREW_PREFIX"
  sudo chflags norestricted "$HOMEBREW_PREFIX"
  sudo chown -R "$LOGNAME:admin" "$HOMEBREW_PREFIX"
fi

# Update shell to zsh
update_shell() {
  local shell_path;
  shell_path="$(which zsh)"

  machine_echo "Changing your shell to zsh ..."
  if ! grep "$shell_path" /etc/shells > /dev/null 2>&1 ; then
    machine_echo "Adding '$shell_path' to /etc/shells"
    sudo sh -c "echo $shell_path >> /etc/shells"
  fi
  chsh -s "$shell_path"
}

case "$SHELL" in
  */zsh)
    if [ "$(which zsh)" != '/bin/zsh' ] ; then
      update_shell
    fi
    ;;
  *)
    update_shell
    ;;
esac

# Install Homebrew
if ! command -v brew >/dev/null; then
  machine_echo "Installing Homebrew ..."
    curl -fsS \
      'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby

    append_to_zshrc '# recommended by brew doctor'

    # shellcheck disable=SC2016
    append_to_zshrc 'export PATH="/usr/local/bin:$PATH"' 1

    export PATH="/usr/local/bin:$PATH"
fi

# Installing services
machine_echo "Updating Homebrew formulae ..."
brew tap "homebrew/services"
brew tap "caskroom/cask"

# UNIX
brew install "fish"
brew install "git"
brew install "gnupg2"
brew install "openssl"
brew install "tmux"
brew install "vim"

# PGP & Yubikey
brew install gnupg21 pinentry-mac

# Image tools
brew install "imagemagick"

# Programming languages and configurations
brew install "node"
brew install "npm"
brew install "yarn"
# NPM confortable environment
npm install -g bower
npm install -g gulp
npm install -g create-react-app

# Entertainment / Productivity / Work
brew cask install --appdir="/Applications" alfred
brew cask install --appdir="/Applications" appcleaner
brew cask install --appdir="/Applications" brave
brew cask install --appdir="/Applications" caffeine
brew cask install --appdir="/Applications" google-chrome
brew cask install --appdir="/Applications" cryptomator
brew cask install --appdir="/Applications" discord
brew cask install --appdir="/Applications" dropbox
brew cask install --appdir="/Applications" evernote
brew cask install --appdir="/Applications" figma
brew cask install --appdir="/Applications" fontexplorer-x-pro
brew cask install --appdir="/Applications" fontprep
brew cask install --appdir="/Applications" firefox 
brew cask install --appdir="/Applications" iterm2
brew cask install --appdir="/Applications" keepassx
brew cask install --appdir="/Applications" keybase
brew cask install --appdir="/Applications" mullvad
brew cask install --appdir="/Applications" pock
brew cask install --appdir="/Applications" processing
brew cask install --appdir="/Applications" slack
brew cask install --appdir="/Applications" spotify
brew cask install --appdir="/Applications" sketch
brew cask install --appdir="/Applications" sketch-toolbox
brew cask install --appdir="/Applications" sublime-text
brew cask install --appdir="/Applications" the-unarchiver
brew cask install --appdir="/Applications" thunderbird
brew cask install --appdir="/Applications" tor
brew cask install --appdir="/Applications" torbrowser
brew cask install --appdir="/Applications" transmission
brew cask install --appdir="/Applications" transmit
brew cask install --appdir="/Applications" vagrant
brew cask install --appdir="/Applications" vagrant-manager
brew cask install --appdir="/Applications" veracrypt
brew cask install --appdir="/Applications" virtualbox
brew cask install --appdir="/Applications" vlc

# Security
brew cask install --appdir="/Applications" blockblock
brew cask install --appdir="/Applications" dhs
brew cask install --appdir="/Applications" do-not-disturb
brew cask install --appdir="/Applications" knockknock
brew cask install --appdir="/Applications" lulu
brew cask install --appdir="/Applications" oversight
brew cask install --appdir="/Applications" reikey
brew cask install --appdir="/Applications" security-growler
brew cask install --appdir="/Applications" taskexplorer

# Install GNU core utilities (those that come with OS X are outdated)
brew install coreutils

# Clean up Homebrew environment
machine_echo "Cleaning up files..."
brew cleanup
brew cask cleanup

# Final
machine_echo "Yo! We are all set up & ready to rock!"

