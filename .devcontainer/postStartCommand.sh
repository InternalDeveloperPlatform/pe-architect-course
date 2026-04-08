#!/usr/bin/env bash

# Runs on every workspace start. Idempotently ensures bash completion and aliases
# are present in .bashrc so they survive workspace restarts.

if ! grep -q "kubectl completion bash" "$HOME/.bashrc"; then
  echo "source <(kubectl completion bash)" >> "$HOME/.bashrc"
  echo "complete -F __start_kubectl k" >> "$HOME/.bashrc"
fi

if ! grep -q "alias k='kubectl'" "$HOME/.bashrc"; then
  echo "alias k='kubectl'" >> "$HOME/.bashrc"
  echo "alias kg='kubectl get'" >> "$HOME/.bashrc"
  echo "alias h='humctl'" >> "$HOME/.bashrc"
  echo "alias sk='score-k8s'" >> "$HOME/.bashrc"
fi
