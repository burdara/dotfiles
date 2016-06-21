#!/usr/bin/env bash
my_script="{PATH}"
my_name="{NAME}"

########################################
# START: User specified functions
########################################

# TODO

########################################
# END: User specified functions
########################################


########################################
# Initilization function
# Globals:
#   my_script
#   my_name
# Arguments:
#   None
# Returns:
#   None
########################################
envlib_init_{NAME}() {
  printf "Initilizing '$my_name'\n"
  export _PATH_BACKUP="$PATH"

  # user custom init
  # TODO
}

########################################
# Teardown function
# Globals:
#   my_script
#   my_name
# Arguments:
#   None
# Returns:
#   None
########################################
envlib_teardown_{NAME}() {
  printf "Tearing down '$my_name'\n"

  # remove functions
  local functions=$(cat $my_script | perl -ne 'if (m/^(function\ )?([a-zA-Z0-9_-]+)[ ]*(\(\))?[ ]*{/) { print "$2\n" }')
  for f in $functions; do
    unset -f "$f"
  done

  # remote exported variables
  local exports=$(cat $my_script | perl -ne 'if (m/export ([a-zA-Z0-9_-]+)=/) { print "$1\n" }')
  for e in $exports; do
    [[ "$e" != "_PATH_BACKUP" ]] && unset "$e"
  done

  # reset PATH
  [[ -n "$_PATH_BACKUP" ]] && export PATH="$_PATH_BACKUP" && unset _PATH_BACKUP

  # user custom teardown
  # TODO
}
