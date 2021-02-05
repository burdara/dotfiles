#!/usr/bin/env bash
#
# Update bash prompt

# TODO(robbie) still a work in progress...

# if command -v __git_ps1 &>/dev/null; then
#   export GIT_PS1_SHOWDIRTYSTATE="true"
#   export GIT_PS1_SHOWSTASHSTATE="true"
#   export GIT_PS1_SHOWUNTRACKEDFILES="true"
#   export GIT_PS1_SHOWUPSTREAM="verbose"
#   export GIT_PS1_STATESEPARATOR=":"
#   export GIT_PS1_SHOWCOLORHINTS="true"
#   PS1+="\$(__git_ps1)"
# fi
#
# command -v aws_ps1 &>/dev/null \
#   && PS1+=" \$(aws_ps1)"
#
# command -v kube_ps1 &>/dev/null \
#   && PS1+=" \$(kube_ps1)"
#
# PS1+=" [\t]\n\$ "
#
# type kube_ps1 &>/dev/null \
#   && LP_PS1_POSTFIX+="\$(kube_ps1)"
#
# ## Add a new line
# LP_PS1_POSTFIX+="\n$(tput bold || echo "\e[1m")>$(tput sgr0 || echo "\e[0m") "

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

export LP_PS1_FILE="$HOME/.liquid.ps1"
# shellcheck source=/dev/null
[[ -e "$liquidprompt_dir/liquidprompt" ]] && source "$liquidprompt_dir/liquidprompt"

unset liquidprompt_dir
