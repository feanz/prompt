# macOS setup

`setup.sh` uses Homebrew for applications and command-line tools, installs dotnetup with Microsoft's downloader, then links the repository-managed configuration into the current user's home directory.

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

[Terminal-Icons](https://github.com/devblackops/Terminal-Icons) is installed from PowerShell Gallery and loaded automatically by the shared profile. Open a new WezTerm PowerShell tab and run `ls` to see file and folder icons using the configured JetBrains Mono Nerd Font. See [file and folder icons](../readme.md#file-and-folder-icons) for manual activation and troubleshooting. This module does not change zsh listings.

Correct symlinks are left untouched on repeat runs. Conflicting managed destinations are moved to timestamped backups.

## 1Password CLI

The Brewfile installs 1Password CLI (`op`) through the `1password-cli` Homebrew cask. After setup, run `op --version` to verify the installation.

To authenticate through the 1Password desktop app, install and sign in to the app if needed, then enable **Settings > Developer > Integrate with 1Password CLI**. Run `op vault list` to authenticate; enable Touch ID in the app if you want fingerprint authentication. See the [official getting-started guide](https://developer.1password.com/docs/cli/get-started/) for details. Setup installs the CLI only; desktop app installation and account sign-in remain manual.

## dotnetup

Setup installs the latest public preview of [dotnetup](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnetup/getting-started) into `~/.dotnetup` when absent, using Microsoft's checksum-verifying downloader. It adds that directory to PATH in `${ZDOTDIR:-$HOME}/.zshrc` without duplicating the entry or replacing existing configuration. The shared PowerShell profile also adds it to PATH, including in WezTerm sessions.

To configure only dotnetup, run `bash ./macos/install-dotnetup.sh`. Open a new terminal and run `dotnetup --version` to verify it. Run `dotnetup init` separately to choose SDKs and an access mode; setup does not initialise or migrate SDKs. The existing Homebrew .NET SDK remains installed.

Repeat runs preserve an existing dotnetup executable. Use `dotnetup self update` to update the tool itself.

## Re-running setup

Re-run `./macos/setup.sh` after pulling updates. `brew bundle` installs missing dependencies and upgrades outdated listed packages; it is not add-only and versions are not pinned. It does not uninstall applications removed from the Brewfile. Existing managed symlinks already point at the latest repository files, while conflicting files are backed up before linking. Missing PowerShell modules are installed without upgrading existing ones, and the profile line and Git include are added only if absent. Repository edits affect linked configuration immediately; repeat runs do not reset application data or sign-in state.

AltTab is installed on macOS through the `alt-tab` Homebrew cask.

Claude Code CLI is installed through the [`claude-code@latest` Homebrew cask](https://formulae.brew.sh/cask/claude-code@latest), which tracks Anthropic's latest release channel. The unqualified `claude-code` cask tracks stable, which is typically about a week behind. Setup replaces an existing stable cask before installing the latest cask; it uninstalls without `--zap`, preserving Claude settings and session history.

After setup, run `claude --version` to verify the installed version, then run `claude` and follow the sign-in prompts. Homebrew installations do not auto-update by default; re-run setup or use `brew upgrade --cask claude-code@latest` to update. See [Anthropic's installation and update guidance](https://code.claude.com/docs/en/setup#install-claude-code).

The Brewfile retains the previously audited developer and desktop applications while replacing Ghostty with WezTerm and standardising the shared terminal font on JetBrains Mono Nerd Font. It also installs T3 Code through the `t3-code` cask, Azure CLI, Fastfetch, and Terraform, with Terraform sourced from HashiCorp's official Homebrew tap. It installs current available versions rather than pinning the audited versions.
