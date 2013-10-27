#!/bin/sh
# Git helper


# Remove Submodule
#
# Usage: `git_remove_submodule path/to/submodule`
#
# Does the inverse of `git submodule add`:
#  1) `deinit` the submodule
#  2) Remove the submodule from the index and working directory
#  3) Clean up the .gitmodules file (won't be needed with 1.8.5!)
# Based on example by Adam Sharp, Aug 21, 2013
function git_remove_submodule {
    submodule_name=$(echo "$1" | sed 's/\/$//'); shift
    if git submodule status "$submodule_name" >/dev/null 2>&1; then
        git submodule deinit -f "$submodule_name"
        git rm -rf "$submodule_name"
        git config -f .gitmodules --remove-section "submodule.$submodule_name"
        if [ -z "$(cat .gitmodules)" ]; then
            git rm -f .gitmodules
        else
            git add .gitmodules
        fi
    else
        echo "Submodule '$submodule_name' not found"
        exit 1
    fi
}
