#!/usr/bin/env bash

export SHKC="StrictHostKeyChecking=no"

sshw() {
  if [[ -z "$@" ]]; then
    cat <<EOF
Usage: sshw [options]

Options:
  -i key         SSH identity file
  -t port        Create SSH tunnel using specified port
  -u user        SSH username
  -h host        SSH host/ip
  -- cmd         Execute command via SSH
  [ssh options]  Pass any other SSH option

EOF
  fi

  local user="robbie"
  local options="-o $SHKC "
  local ssh_cmd="${SSH_CMD:-ssh}"
  local hc=0
  while [[ -n "$1" ]]; do
    case "$1" in
      -i) shift; local options+="-i $1 " ;;
      -t) shift; local options+="-N -f -L $1:localhost:$1 " ;;
      -u) shift; local user="$1" ;;
      -h) shift; local hosts+="$1 "; local hc=$(($hc+1)) ;;
      -c) local show_cmd="true" ;;
      --) shift; local cmd="-T \"$@\"" ;;
      *) local options+=" $1" ;;
    esac
    shift
  done
  local full_cmd="$ssh_cmd $options $user@$hosts $cmd"

  # multiple hosts provided, then use cluster ssh
  if [[ "$hc" -gt 1 ]]; then
    local ssh_cmd="${CSSH_CMD:-csshx}"
    for h in $hosts; do
      local c_hosts+=" $user@$h"
    done
    case "$ssh_cmd" in
      i2cssh) local c_options="--iterm2 $(sed 's/-\(.\) /-X\1=/g' <<< $options)" ;;
      csshx) local c_options="--ssh_args \"$options\"" ;;
    esac
    local full_cmd="$ssh_cmd $c_options $c_hosts"
  fi
  [[ "$show_cmd" == "true" ]] && echo "$full_cmd"
  eval "$full_cmd"
}
