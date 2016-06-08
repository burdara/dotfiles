#!/usr/bin/env bash
#
#  Bash RC

home_bin_dir="$HOME/bin"
[[ -d "$home_bin_dir" ]] && mkdir -p "$home_bin_dir"

add_paths() {
  [[ $# -eq 0 ]] && return 1
  for p in $@; do
    [[ ! -e $p ]] && continue
    [[ ! "$PATH" =~ [:]?$p[:]? ]] && export PATH="$p:$PATH"
  done
}

paths=(
  "/usr/local/bin"
  "/usr/bin"
  "/bin"
  "/usr/local/sbin"
  "/usr/sbin"
  "/sbin"
  "$HOME/bin"
)
add_paths ${paths[@]}

# For SSH
export SHCN="StrictHostKeyChecking=no"

### Aliases
# ls
alias l='ls -CF'
alias ls='ls -hF'
alias ll='ls -l'
alias la='ls -A'
alias lla='ls -lA'
# Disk usage by Folder
alias duf='du -sk * | sort -n | perl -ne '\''($s,$f)=split(m{\t});for (qw(K M G)) {if($s<1024) {printf("%.1f",$s);print "$_\t$f"; last};$s=$s/1024}'\'

# For custom user defined paths
bashrc_custom_file="$HOME/.bashrc_custom"
[[ -s "$bashrc_custom_file" ]] && source "$bashrc_custom_file"
