#!/usr/bin/env bash
#
# Update bash prompt

# Install liquidprompt
liquidprompt_dir="$HOME/.liquidprompt"
[[ ! -d "$liquidprompt_dir" ]] && mkdir -p "$liquidprompt_dir"
if [[ ! -e "$liquidprompt_dir/liquidprompt" ]]; then
  git clone "https://github.com/nojhan/liquidprompt.git" "$liquidprompt_dir"
else
  ( cd "$liquidprompt_dir" && git pull 1>/dev/null ; )
fi

# liquidprompt customizations
export LP_USER_ALWAYS=0
export LP_ENABLE_PERM=0
export LP_ENABLE_SHORTEN_PATH=1
export LP_ENABLE_SVN=0
export LP_ENABLE_HG=0
export LP_ENABLE_BZR=0
export LP_ENABLE_FOSSIL=0
export LP_ENABLE_SCLS=0
export LP_ENABLE_SSH_COLORS=1
export LP_ENABLE_SUDO=1
export LP_ENABLE_TIME=1
export LP_ENABLE_TITLE=0
export LP_ENABLE_RUNTIME=1
# custom color
export LP_COLOR_PATH_SEPARATOR="\033[1;33m"

export LP_PS1_FILE="$HOME/.liquid.ps1"
# shellcheck source=/dev/null
[[ -e "$liquidprompt_dir/liquidprompt" ]] && source "$liquidprompt_dir/liquidprompt"

unset liquidprompt_dir
