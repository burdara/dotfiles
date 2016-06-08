#!/usr/bin/env bash
lib_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
template_file="$lib_dir/envlib/.template.sh"

#######################################
# Will teardown and initilize specified envlibs
# Globals:
#   None
# Arguments:
#   $1  envlib_name
# Returns:
#   None
#######################################
envlib() {
  local usage="usage: envlib init name\n envlib destroy\n"
  [[ -z "$1" ]] && printf "active: $CURRENT_ENVLIB" && return 0
  case "$1" in
    init)
      [[ -z "$2" ]] && printf "$usage" && return 1
      ;;
    destroy) ;;
    *) printf "$usage" && return 1
  esac

  local envlib_file="$lib_dir/envlib/$2.sh"

  case "$1" in
    init)
      [[ -n "$CURRENT_ENVLIB" ]] \
        && envlib_teardown_$CURRENT_ENVLIB \
        && unset CURRENT_ENVLIB
      [[ ! -e "$envlib_file" ]] \
        && printf "creating new envlib file from template: $envlib_file"
        && sed -e 's/{NAME}/'$2'/g' "$template_file" > "$envlib_file"
      [[ -e "$envlib_file" ]] \
        && source "$envlib_init" && envlib_init_$2
      export CURRENT_ENVLIB="$2"
      ;;
    destroy)
      [[ -n "$CURRENT_ENVLIB" ]] \
        && envlib_teardown_$CURRENT_ENVLIB \
        && unset CURRENT_ENVLIB
      ;;
    *) printf "$usage" && return 1
  esac
}
