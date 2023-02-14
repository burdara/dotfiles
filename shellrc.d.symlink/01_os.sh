#!/usr/bin/env sh
#
# Mac (darwin) specific configurations

if [ "$(uname)" = "Darwin" ]; then
  alias md5="md5 -r"
  alias md5sum="md5 -r"
  alias crontab="VIM_CRONTAB=true crontab"
  alias killcam="sudo killall VDCAssistant"

  # setup iterm auto theme script
  # ref: https://gist.github.com/jamesmacfie/2061023e5365e8b6bfbbc20792ac90f8
  _base_dir="$HOME/Library/Application Support/iTerm2"
  _src="$HOME/.shellrc.d/files/iterm-auto_dark_mode.py"
  _dst="$_base_dir/Scripts/AutoLaunch/auto_dark_mode.py"
  if test -d "$_base_dir"; then
    ! test -d "$_base_dir/Scripts/AutoLaunch" \
      && mkdir -p "$_base_dir/Scripts/AutoLaunch"
    test -e "$_src" && cp -p "$_src" "$_dst"
  fi
  
  # custom paths
  # helm resources require latest gnu-getopt
  test -d "$(brew --prefix)/Cellar/gnu-getopt" \
    && add_paths --prepend "$(dirname "$(find "$(brew --prefix)/Cellar/gnu-getopt" -path '*/bin/getopt')")"
fi
