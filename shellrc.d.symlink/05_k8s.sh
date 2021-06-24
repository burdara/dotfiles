#!/usr/bin/env bash
#
# Kubernetes configurations
export KUBECONFIG_HOME="$HOME/.kube"
export KUBE_EDITOR="vim -u 'NONE'"

! test -d "$KUBECONFIG_HOME" && mkdir -p "$KUBECONFIG_HOME"
# source kube configs
KUBECONFIG="$KUBECONFIG_HOME/config"
! test -r "$KUBECONFIG" && touch "$KUBECONFIG"
kubecfgs="$(grep '^kind: Config$' "$KUBECONFIG_HOME"/* 2>/dev/null \
  | awk -F: '{print $1}' | grep -v "$KUBECONFIG_HOME/config" \
  | xargs | tr ' ' ':')"
test -n "$kubecfgs" && KUBECONFIG+=":$kubecfgs"
export KUBECONFIG

# krew binaries
test -d "$HOME/.krew/bin" && add_paths "$HOME/.krew/bin"