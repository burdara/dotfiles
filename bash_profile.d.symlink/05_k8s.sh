#!/usr/bin/env bash
#
# Kubernetes configurations

# Install Kubernetes PS1 scripts.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
_install_k8s_ps1() {
  if [[ "$(uname)" == "Darwin" ]]; then
    local _tmp_kube_ps1_file
    if command -v brew &>/dev/null; then
      brew list kube-ps1 &>/dev/null || brew install kube-ps1
      _tmp_kube_ps1_file="$(brew --prefix)/opt/kube-ps1/share/kube-ps1.sh"
    else
      curl -s -o "$HOME/.kube/kube-ps1.sh" \
        "https://raw.githubusercontent.com/jonmosco/kube-ps1/master/kube-ps1.sh"
      _tmp_kube_ps1_file="$HOME/.kube/kube-ps1.sh"
    fi
    # shellcheck source=/dev/null
    [[ -r "$_tmp_kube_ps1_file" ]] && source "$_tmp_kube_ps1_file"
  fi
}

# Sources kubernetes configs files, if present.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
_source_kube_configs() {
  KUBECONFIG="$HOME/.kube/config"
  [[ ! -r "$KUBECONFIG" ]] && touch "$KUBECONFIG"
  local kubecfgs
  # shellcheck disable=2038
  kubecfgs="$(grep -R '^kind: Config$' "$HOME"/.kube/* | awk -F: '{print $1}' | grep -v "$HOME/.kube/config" | xargs | tr ' ' ':')"
  [[ -n "$kubecfgs" ]] && KUBECONFIG+=":$kubecfgs"
  export KUBECONFIG
}

[[ ! -d "$HOME/.kube" ]] && mkdir -p "$HOME/.kube"
_install_k8s_ps1 && unset _install_k8s_ps1
_source_kube_configs && unset _source_kube_configs
export KUBE_EDITOR="vim -u 'NONE'"