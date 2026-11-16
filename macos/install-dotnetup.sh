#!/usr/bin/env bash

set -euo pipefail

dotnetup_dir="$HOME/.dotnetup"
dotnetup_path="$dotnetup_dir/dotnetup"

if [[ ! -x "$dotnetup_path" ]]; then
  installer_path="$(mktemp -t prompt-dotnetup-install)"
  trap 'rm -f "$installer_path"' EXIT
  curl -fsSL https://aka.ms/dotnetup/get-dotnetup.sh -o "$installer_path"
  bash "$installer_path"
fi

"$dotnetup_path" --version

# Configure interactive zsh sessions without replacing existing customisations.
zshrc="${ZDOTDIR:-$HOME}/.zshrc"
path_line='[[ ":$PATH:" == *":$HOME/.dotnetup:"* ]] || export PATH="$HOME/.dotnetup:$PATH"'
mkdir -p "$(dirname -- "$zshrc")"
touch "$zshrc"
if ! grep -Fqx "$path_line" "$zshrc"; then
  printf '\n# dotnetup toolchain manager.\n%s\n' "$path_line" >> "$zshrc"
fi

printf '\ndotnetup is ready. Open a new terminal and run dotnetup init to choose SDKs and access mode.\n'
