#!/usr/bin/env bash

export SHKC="StrictHostKeyChecking=no"

sshw() {
  local ssh_options="-o $SHKC"
  local k="$1"; local u="$2"; local h="$3";
  [[ -z "$k" ]] && echo "\$1 keyname arg missing." && return 1
  [[ -z "$u" ]] && echo "\$2 user arg missing." && return 2
  [[ -z "$h" ]] && echo "\$3 host/ip arg missing." && return 3
  shift 3
  while [[ -n "$1" ]]; do
    case "$1" in
      -t) shift;
        echo "port provided; opening tunnel to localhost"
        local ssh_options="-N -f -L $1:localhost:$1"
        ;;
      --) shift; local c="-T \"$@\"" ;;
    esac
    shift
  done
  eval "${SSH_CMD:-ssh} -i $k $ssh_options $u@$h $c"
}

csshw() {
  [[ -z "$1" ]] && echo "\$1 keyname arg missing." && return 1
  [[ -z "$2" ]] && echo "\$2 user arg missing." && return 2
  [[ -z "$3" ]] && echo "\$@ hosts/ips missing." && return 3
  local cmd="${CSSH_CMD:-csshx}"
  local key_name="$1"
  local user_name="$2"
  shift 2
  if [[ "$cmd" == "i2cssh" ]]; then
    local options="--iterm2 -X i=$key_name -X o=\$SHKC"
  else
    local options="--ssh_args \"-i $key_name -o $SHKC\""
  fi
  for host in $@; do
    local host_list="$host_list $user_name@$host"
  done
  eval "${CSSH_CMD:-csshx} $options $host_list"
}
