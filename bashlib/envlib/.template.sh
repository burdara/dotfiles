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
    unset "$e"
  done

  # user custom teardown
  # TODO
}
