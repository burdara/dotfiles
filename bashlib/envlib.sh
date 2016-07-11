#!/usr/bin/env bash
lib_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
template_file="$lib_dir/envlib/.template.sh"
[[ -z "$BENV_ACTIVE_FILE" ]] && export BENV_ACTIVE_FILE="$HOME/.benv.active"

alias envlib='benv'
alias env='env | grep -vE "^_(CLR|FMT)_.*$"'

_benv_usage() {
  cat <<EOF
usage: benv
       benv init name
       benv destroy
       benv rm name
       --
       benv tmp name
       benv reset
       --
       benv list
       benv help
EOF
}

_benv_flag() {
  if [[ -n "$1" ]]; then
    export BENV_ACTIVE="$1"
    [[ -z "$BENV_TMP" ]] && echo "$1" > "$BENV_ACTIVE_FILE"
  else
    [[ -n "$BENV_ACTIVE" ]] && unset BENV_ACTIVE
    [[ -e "$BENV_ACTIVE_FILE" && -z "$BENV_TMP" ]] && rm -f "$BENV_ACTIVE_FILE"
  fi
}

_benv_init() {
  [[ -z "$1" ]] && printf "missing envlib_name arg\n" && return 1
  local envlib_file="$lib_dir/envlib/$1.sh"
  [[ ! -e "$envlib_file" ]] \
    && printf "creating new envlib file from template: $envlib_file\n" \
    && sed -e 's/{NAME}/'$1'/g' \
           -e 's/{PATH}/'${envlib_file//\//\\/}'/g' \
           "$template_file" > "$envlib_file"
  [[ -e "$envlib_file" ]] \
    && source "$envlib_file" && envlib_init_$1
  _benv_flag "$1"
}

_benv_destroy() {
  [[ -n "$BENV_ACTIVE" ]] \
    && envlib_teardown_$BENV_ACTIVE \
    && _benv_flag \
    && source "$HOME/.bash_profile"
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
  if [[ -z "$1" ]]; then
    printf "active: ${BENV_ACTIVE:-none}\n"
    if [[ -n "$BENV_TMP" ]]; then
      printf "tmp: true\n"
      [[ -s "$BENV_ACTIVE_FILE" ]] && printf "original: $(cat $BENV_ACTIVE_FILE)\n"
    fi
    return 0
  fi
  case "$1" in
    init|rm|tmp)
      [[ -z "$2" ]] && _benv_usage && return 1
      ;;
    destroy|list|reset) ;;
    *) _benv_usage && return 1
  esac

  case "$1" in
    init|tmp)
      [[ "$1" == "tmp" ]] && export BENV_TMP=true
      [[ "$2" != "$BENV_ACTIVE" ]] && _benv_destroy
      _benv_init "$2"
      ;;
    reset)
      _benv_destroy
      unset BENV_TMP
      [[ -s "$BENV_ACTIVE_FILE" ]] && _benv_init "$(cat $BENV_ACTIVE_FILE)"
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
      [[ "$2" == "$BENV_ACTIVE" ]] && _benv_destroy
      _benv_rm $envlib_file
      ;;
  esac
}

[[ -s "$BENV_ACTIVE_FILE" ]] && export BENV_ACTIVE="$(cat $BENV_ACTIVE_FILE)"
[[ -n "$BENV_ACTIVE" ]] && benv init "$BENV_ACTIVE"
