#!/usr/bin/env bash
#
# Installs dotfiles
# Globals: None
# Arguments: None
# Returns: None
MYDIR="$(cd "$(dirname "$0")" && pwd)"
readonly MYDIR
[[ -n "$NOOP" ]] && NOOP="echo [noop]:"

# Download checksums
VIM_PLUG_MD5="14b711fdda4f4dcb97370908890b9d77"
OH_MY_ZSH_INSTALL_MD5="37c19e2522a49c190c5c04ff1882e416"


# Backups, if exists, and creates symbolic link of file.
# Globals: None
# Arguments:
#   1: destination file
#   2: source file
# Returns: None
_link_file() {
  [[ ! -d "$(dirname "$1")" ]] && mkdir -p "$(dirname "$1")"
  [[ -e "$1" && ! -L "$1" ]] && mv "$1" "$1.$(date '+%Y%m%d%H%M%S')"
  [[ -L "$1" ]] && rm -f "$1"
  $NOOP ln -s "$2" "$1"  
}

# Common install 
# Globals:
#   HOME: Home directory
#   MYDIR: Script directory
# Arguments: None
# Returns: None
_common_install() {
  # install vim-plug
  if [[ ! -e "$HOME/.vim/autoload/plug.vim" ]]; then
    [[ ! -d "$HOME/.vim/autoload" ]] && mkdir -p "$HOME/.vim/autoload"
    curl -sfLo "/tmp/vim-plug/plug.vim" --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    if [[ "$VIM_PLUG_MD5" == "$(md5 -q /tmp/vim-plug/plug.vim)" ]]; then
      $NOOP mv "/tmp/vim-plug/plug.vim" "$HOME/.vim/autoload/plug.vim"
    else
      echo "error: plug.vim does not match saved md5" && exit 1
    fi
  fi

  [[ ! -d "$HOME/.config" ]] && mkdir "$HOME/.config"
  _link_file "$HOME/bin" "$MYDIR/bin.symlink"
  _link_file "$HOME/.shellrc" "$MYDIR/shellrc.symlink"
  _link_file "$HOME/.shellrc.d" "$MYDIR/shellrc.d.symlink"
  _link_file "$HOME/.config/git" "$MYDIR/config/git.symlink"
  _link_file "$HOME/.vimrc.bundles" "$MYDIR/vimrc.bundles.symlink"cd 
  _link_file "$HOME/.vimrc" "$MYDIR/vimrc.symlink"

  # create initial git config, if not present
  [[ ! -e "$HOME/.config/git/config.local" ]] \
    && $NOOP touch "$HOME/.config/git/config.local"
}

# Bash install 
# Globals:
#   HOME: Home directory
#   MYDIR: Script directory
# Arguments: None
# Returns: None
_bash_install() {
  _link_file "$HOME/.bash_profile" "$MYDIR/bash_profile.symlink"
  _link_file "$HOME/.bashrc" "$MYDIR/bashrc.symlink"
  _link_file "$HOME/.bashrc.d" "$MYDIR/bashrc.d.symlink"
  # install liquidprompt
  if [[ ! -e "$HOME/.liquidprompt" ]]; then
    git clone --depth=1 \
      "https://github.com/nojhan/liquidprompt.git" "$HOME/.liquidprompt"
  fi
  _link_file "$HOME/.liquid.ps1" "$MYDIR/liquid.ps1.symlink"
}

# ZSH install 
# Globals:
#   HOME: Home directory
#   MYDIR: Script directory
# Arguments: None
# Returns: None
_zsh_install() {
  # install oh-my-zsh
  if [[ ! -e "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
    curl -sfLo "/tmp/oh-my-zsh/install.sh" --create-dir \
      https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
    if [[ "$OH_MY_ZSH_INSTALL_MD5" == "$(md5 -q /tmp/oh-my-zsh/install.sh)" ]]; then
      chmod +x "/tmp/oh-my-zsh/install.sh"
      $NOOP /tmp/oh-my-zsh/install.sh --keep-zshrc --unattended
    else
      echo "error: oh-my-zsh install script does not match saved md5" && exit 1
    fi
  fi
  # ZSH Defaults
  [[ -z "$ZSH_CUSTOM" ]] && export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
  
  # install powerlevel10k fonts
  for ttf in MesloLGS_NF_Regular.ttf \
    MesloLGS_NF_Bold.ttf \
    MesloLGS_NF_Italic.ttf \
    MesloLGS_NF_Bold_Italic.ttf
  do
    curl -sfLo "$HOME/.fonts/$ttf" --create-dir \
      "https://github.com/romkatv/powerlevel10k-media/raw/master/${ttf//_/%20}"
    [[ "$(uname)" == "Darwin" ]] \
      && $NOOP cp "$HOME/.fonts/$ttf" /Library/Fonts/
  done
  # install powerlevel10k theme
  if [[ ! -e "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
    git clone --depth=1 \
      https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
  fi

  # link zshrc
  _link_file "$HOME/.zshrc" "$MYDIR/zshrc.symlink"
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
    && $NOOP xcode-select --install
  [[ "$INSTALL_BREWFILE" == "true" ]] \
    && command -v brew &>/dev/null \
    && ( cd "$MYDIR" && $NOOP brew bundle install ;)
fi

_common_install
_bash_install
_zsh_install
