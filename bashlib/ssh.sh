#!/usr/bin/env bash

sshw() {
  local ssh_options="-o StrictHostKeyChecking=no"
  [[ -z "$1" ]] && echo "\$1 keyname arg missing." && return 1
  [[ -z "$2" ]] && echo "\$2 user arg missing." && return 2
  [[ -z "$3" ]] && echo "\$3 host/ip arg missing." && return 3
  [[ -n "$4" ]] && echo "port provided; opening tunnel to localhost" \
    && local ssh_options="-N -f -L $4:localhost:$4"
  ssh -i ~/.ssh/$1 $ssh_options $2@$3
}

csshw() {
  [[ -z "$1" ]] && echo "\$1 keyname arg missing." && return 1
  [[ -z "$2" ]] && echo "\$2 user arg missing." && return 2
  [[ -z "$3" ]] && echo "\$@ hosts/ips missing." && return 3
  local key_name="$1"
  local user_name="$2"
  shift 2
  local ssh_args="-i ~/.ssh/$key_name -o StrictHostKeyChecking=no"
  for host in $@; do
    local host_list="$host_list $user_name@$host"
  done
  csshx --ssh_args "$ssh_args" $host_list
}
