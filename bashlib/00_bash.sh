#!/usr/bin/env bash
#
# Bash additions

readonly bash_comp_dir="/usr/local/etc/bash_completion.d"
if [[ -d "$bash_comp_dir" ]]; then
  for bc in "$bash_comp_dir"/*; do
    # shellcheck source=/dev/null
    [[ -r "$bc" ]] && source "$bc"
  done
fi