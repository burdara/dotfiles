#!/usr/bin/env bash
#
# Installs dotfiles
# Globals: None
# Arguments: None
# Returns: None

SELF_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SELF_DIR

OH_MY_ZSH_INSTALL_MD5="ecbbd58a4831a9f1d8e75a31b1e32545"

# Backups, if exists, and creates symbolic link of file.
# Globals: None
# Arguments:
#   1: destination file
#   2: source file
# Returns: None
_link_file() {
  [[ -e "$1" && ! -L "$1" ]] && mv "$1" "$1.$(date '+%Y%m%d%H%M%S')"
  [[ -L "$1" ]] && rm -f "$1"
  ln -s "$2" "$1"  
}

# Bash install 
# Globals:
#   HOME: Home directory
#   SELF_DIR: Script directory
# Arguments: None
# Returns: None
_bash_install() {
  _link_file "$HOME/.bashrc" "$SELF_DIR/bash/bashrc.symlink"
  _link_file "$HOME/.bash_profile" "$SELF_DIR/bash/bash_profile.symlink"
  _link_file "$HOME/.bash_profile.d" "$SELF_DIR/bash/bash_profile.d.symlink"
  _link_file "$HOME/.liquid.ps1" "$SELF_DIR/bash/liquid.ps1.symlink"
}

# ZSH install 
# Globals:
#   HOME: Home directory
#   SELF_DIR: Script directory
# Arguments: None
# Returns: None
_zsh_install() {
  _link_file "$HOME/.zshrc" "$SELF_DIR/zsh/zshrc.symlink"
  # install oh-my-zsh
  curl -sfLo "/tmp/oh-my-zsh/install.sh" --create-dir \
    https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
  if [[ "$OH_MY_ZSH_INSTALL_MD5" == "$(md5 -q /tmp/oh-my-zsh/install.sh)" ]]; then
    chmod +x "/tmp/oh-my-zsh/install.sh"
    /tmp/oh-my-zsh/install.sh --keep-zshrc --unattended
  fi

  for ttf in MesloLGS_NF_Regular.ttf \
    MesloLGS_NF_Bold.ttf \
    MesloLGS_NF_Italic.ttf \
    MesloLGS_NF_Bold_Italic.ttf
  do
    curl -sfLo "/tmp/powerlevel10k/$ttf" --create-dir \
      "https://github.com/romkatv/powerlevel10k-media/raw/master/${ttf//_/%20}"
    open "/tmp/powerlevel10k/$ttf"
  done
}

while [[ -n "$1" ]]; do
  case "$1" in
    --xcode) INSTALL_XCODE="true" ;;
    --brew)  INSTALL_BREWFILE="true" ;;
  esac
  shift
done

if [[ "$(uname)" == "Darwin" ]]; then
  [[ "$INSTALL_XCODE" == "true" ]] \
    && command -v xcode-select &>/dev/null \
    && xcode-select --install
  [[ "$INSTALL_BREWFILE" == "true" ]] \
    && command -v brew &>/dev/null \
    && ( cd "$SELF_DIR" && brew bundle install ;)
fi

# create initial config dir
[[ ! -d "$HOME/.config" ]] && mkdir -p "$HOME/.config"

# install vim-plug
curl -sfLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# link dotfiles
case "$SHELL" in
 */bash) _bash_install ;;
 */zsh)  _zsh_install ;;
esac
_link_file "$HOME/bin" "$SELF_DIR/bin.symlink"
_link_file "$HOME/.config/git" "$SELF_DIR/config.git.symlink"
_link_file "$HOME/.vimrc.bundles" "$SELF_DIR/vimrc.bundles.symlink"
_link_file "$HOME/.vimrc" "$SELF_DIR/vimrc.symlink"

# create initial git config; 
touch "$HOME/.config/git/config.local"
