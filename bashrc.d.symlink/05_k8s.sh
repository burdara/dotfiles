#!/usr/bin/env bash
#
# Kubernetes configurations

# Install Kubernetes PS1 scripts.
if command -v brew &>/dev/null; then
  brew list kube-ps1 &>/dev/null || brew install kube-ps1
  _tmp_kube_ps1_file="$(brew --prefix)/opt/kube-ps1/share/kube-ps1.sh"
else
  curl -s -o "$HOME/.kube/kube-ps1.sh" \
    "https://raw.githubusercontent.com/jonmosco/kube-ps1/master/kube-ps1.sh"
  _tmp_kube_ps1_file="$HOME/.kube/kube-ps1.sh"
fi
# shellcheck source=/dev/null
[[ -n "$_tmp_kube_ps1_file" && -r "$_tmp_kube_ps1_file" ]] \
  && source "$_tmp_kube_ps1_file"
