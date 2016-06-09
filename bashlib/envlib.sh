#!/usr/bin/env bash
lib_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
template_file="$lib_dir/envlib/.template.sh"

alias envlib='benv'
alias env='env | grep -vE "^_(CLR|FMT)_.*$"'

_benv_usage() {
  cat <<EOF
usage: benv
       benv init name
       benv destroy
       benv rm name
       benv list
       benv help
EOF
}

_benv_init() {
  [[ -z "$1" ]] && printf "missing envlib_file arg\n" && return 1
  [[ -z "$2" ]] && printf "missing envlib_name arg\n" && return 1
  [[ ! -e "$1" ]] \
    && printf "creating new envlib file from template: $1\n" \
    && sed -e 's/{NAME}/'$2'/g' \
           -e 's/{PATH}/'$1'/g' \
           "$template_file" > "$1"
  [[ -e "$1" ]] \
    && source "$1" && envlib_init_$2
  export CURRENT_ENVLIB="$2"
}

_benv_destroy() {
  [[ -n "$CURRENT_ENVLIB" ]] \
    && envlib_teardown_$CURRENT_ENVLIB \
    && unset CURRENT_ENVLIB
  source "$HOME/.bash_profile"
}

_benv_rm() {
  [[ -z "$1" ]] && printf "missing envlib_file arg\n" && return 1
  [[ -e "$1" ]] && rm -f $1
}

#######################################
# Will teardown and initilize specified envlibs
# Globals:
#   None
# Arguments:
#   $1  envlib_name
# Returns:
#   None
#######################################
benv() {
  [[ -z "$1" ]] && printf "active: ${CURRENT_ENVLIB:-none}\n" && return 0
  case "$1" in
    init|rm)
      [[ -z "$2" ]] && _benv_usage && return 1
      ;;
    destroy|list) ;;
    *) _benv_usage && return 1
  esac

  local envlib_file="$lib_dir/envlib/$2.sh"
  case "$1" in
    init)
      _benv_destroy
      _benv_init "$envlib_file" "$2"
      ;;
    destroy)
      _benv_destroy
      ;;
    list)
      find $lib_dir/envlib -type f \
        -a ! -name .template.sh \
        -exec basename {} \; | sed 's/\.sh//g'
        return 0
      ;;
    rm)
      [[ "$2" == "$CURRENT_ENVLIB" ]] && _benv_destroy
      _benv_rm $envlib_file
      ;;
  esac
}
