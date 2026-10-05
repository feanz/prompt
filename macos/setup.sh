#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"
config_root="$HOME/.config/prompt"

if ! command -v brew >/dev/null 2>&1; then
  cat >&2 <<'MESSAGE'
Homebrew is required but was not found.
Install it from https://brew.sh, then run this script again.
MESSAGE
  exit 1
fi

backup_and_link() {
  local source_path="$1"
  local destination_path="$2"

  mkdir -p "$(dirname -- "$destination_path")"

  if [[ -L "$destination_path" ]] && [[ "$(readlink "$destination_path")" == "$source_path" ]]; then
    return
  fi

  if [[ -e "$destination_path" || -L "$destination_path" ]]; then
    local backup_path="${destination_path}.backup.$(date +%Y%m%d%H%M%S)"
    mv "$destination_path" "$backup_path"
    printf 'Backed up %s to %s\n' "$destination_path" "$backup_path"
  fi

  ln -s "$source_path" "$destination_path"
  printf 'Linked %s -> %s\n' "$destination_path" "$source_path"
}

printf 'Installing Homebrew dependencies from %s\n' "$script_dir/Brewfile"
brew bundle --file "$script_dir/Brewfile"

backup_and_link "$repo_root/shared/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
backup_and_link "$repo_root/shared/oh-my-posh/theme.omp.json" "$HOME/.config/oh-my-posh/theme.omp.json"
backup_and_link "$repo_root/shared/powershell/profile.ps1" "$config_root/powershell/profile.ps1"
backup_and_link "$repo_root/shared/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
backup_and_link "$repo_root/shared/fastfetch/logo.txt" "$HOME/.config/fastfetch/logo.txt"
backup_and_link "$repo_root/shared/git/gitconfig" "$config_root/gitconfig"
backup_and_link "$repo_root/shared/git/git-aliases" "$config_root/git-aliases"
backup_and_link "$script_dir/git/gitconfig" "$config_root/git-platform"

pwsh -NoProfile -File "$repo_root/shared/powershell/install-profile.ps1"

git_include="$config_root/gitconfig"
if ! git config --global --get-all include.path 2>/dev/null | grep -Fqx "$git_include"; then
  git config --global --add include.path "$git_include"
  printf 'Added shared Git configuration to the global include list.\n'
fi

printf '\nMac setup complete. Restart WezTerm to load the shared configuration.\n'
