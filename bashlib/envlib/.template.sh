#!/usr/bin/env bash

my_name="{NAME}"

########################################
# Initilization function
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
########################################
envlib_init_{NAME}() {
  printf "Initilizing '$my_name'"
  #TODO
}

########################################
# Teardown function
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
########################################
envlib_teardown_{NAME}() {
  printf "Tearing down '$my_name'"
  # TODO

  # remove functions
  unset -f envlib_init_{NAME}
  unset -f envlib_teardown_{NAME}
}
