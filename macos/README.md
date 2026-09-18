# macOS setup

`setup.sh` uses Homebrew as the package source and symlinks repository-managed terminal configuration into the current user's home directory.

## Managed destinations

| Repository file | Destination |
| --- | --- |
| `macos/zsh/.zprofile` | `~/.zprofile` |
| `macos/zsh/.zshrc` | `~/.zshrc` |
| `macos/ghostty/config` | `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` |
| `shared/oh-my-posh/theme.omp.json` | `~/.config/prompt/theme.omp.json` |
| `shared/git/gitconfig` | `~/.config/prompt/gitconfig` |
| `shared/git/git-aliases` | `~/.config/prompt/git-aliases` |
| `macos/git/gitconfig` | `~/.config/prompt/git-platform` |

The setup is safe to run again. Correct symlinks are left alone; conflicting files are moved to timestamped backups.

## Package policy

The Brewfile contains the audited top-level Homebrew packages, desktop applications, and VS Code extensions. It does not pin versions, allowing `brew bundle` to install the current versions available for the host.

Homebrew itself is not installed automatically. This avoids executing a network-delivered installer from the bootstrap; install it from [brew.sh](https://brew.sh) first.

## Shell behavior

- Homebrew is discovered at the Apple Silicon or Intel prefix.
- `PATH` is deduplicated by zsh.
- Docker's CLI and completion directories are included when present.
- The full .NET SDK installed by the cask is preferred over the formula dependency used by PowerShell.
- Oh My Posh is enabled outside Apple Terminal.
- Ghostty is allowed to advertise its own terminal type; the previous forced `TERM=xterm-256color` override is not retained.
