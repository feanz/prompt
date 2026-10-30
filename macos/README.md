# macOS setup

`setup.sh` uses Homebrew for applications and command-line tools, then links the repository-managed configuration into the current user's home directory.

## Requirements

- macOS on Apple Silicon or Intel
- Homebrew
- A clone of this repository

## Run

```shell
./macos/setup.sh
```

## Managed destinations

| Repository file | Destination |
| --- | --- |
| `shared/wezterm/wezterm.lua` | `~/.config/wezterm/wezterm.lua` |
| `shared/oh-my-posh/theme.omp.json` | `~/.config/oh-my-posh/theme.omp.json` |
| `shared/powershell/profile.ps1` | `~/.config/prompt/powershell/profile.ps1` |
| `shared/fastfetch/config.jsonc` | `~/.config/fastfetch/config.jsonc` |
| `shared/fastfetch/logo.txt` | `~/.config/fastfetch/logo.txt` |
| `shared/git/gitconfig` | `~/.config/prompt/gitconfig` |
| `shared/git/git-aliases` | `~/.config/prompt/git-aliases` |
| `macos/git/gitconfig` | `~/.config/prompt/git-platform` |

The PowerShell installer adds one dot-source line to PowerShell 7's `CurrentUserAllHosts` profile. It also installs `posh-git`, `PSReadLine`, `Terminal-Icons`, and `z` for the current user.

Correct symlinks are left untouched on repeat runs. Conflicting managed destinations are moved to timestamped backups.

## Re-running setup

Re-run `./macos/setup.sh` after pulling updates. `brew bundle` installs missing dependencies and upgrades outdated listed packages; it is not add-only and versions are not pinned. It does not uninstall applications removed from the Brewfile. Existing managed symlinks already point at the latest repository files, while conflicting files are backed up before linking. Missing PowerShell modules are installed without upgrading existing ones, and the profile line and Git include are added only if absent. Repository edits affect linked configuration immediately; repeat runs do not reset application data or sign-in state.

AltTab is installed on macOS through the `alt-tab` Homebrew cask.

Claude Code CLI is installed through the `claude-code` Homebrew cask. After setup, run `claude` and follow the sign-in prompts. Homebrew installations do not auto-update; re-run setup or use `brew upgrade --cask claude-code` to update.

The Brewfile retains the previously audited developer and desktop applications while replacing Ghostty with WezTerm and standardising the shared terminal font on JetBrains Mono Nerd Font. It also installs T3 Code through the `t3-code` cask, Azure CLI, Fastfetch, and Terraform, with Terraform sourced from HashiCorp's official Homebrew tap. It installs current available versions rather than pinning the audited versions.
