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

## Tailscale and RustDesk

The Brewfile installs the Tailscale standalone desktop app through `tailscale-app` and RustDesk through `rustdesk`. It does not install the separate CLI-only Tailscale formula. The Tailscale cask currently requires macOS 13 or later. If you already use another Tailscale variant, follow the vendor's migration guidance linked in [remote-access configuration](../docs/remote-access.md) before running setup.

If RustDesk was installed manually, quit it and move the existing `/Applications/RustDesk.app` bundle aside before running setup when its version differs from the cask. Homebrew cannot adopt a different app version. Preserve the app's user data; see [existing RustDesk installations](../docs/remote-access.md#existing-rustdesk-installations).

After setup, open Tailscale to approve its system/network extension and VPN configuration, then sign in to your tailnet. Open RustDesk and grant Screen Recording and Accessibility permissions; use the standard public-server defaults. See [remote-access configuration](../docs/remote-access.md) for full first-run steps and verification. Setup preserves existing sign-in and application settings.

## dotnetup

Setup installs the latest public preview of [dotnetup](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnetup/getting-started) into `~/.dotnetup` when absent, using Microsoft's checksum-verifying downloader. It adds that directory to PATH in `${ZDOTDIR:-$HOME}/.zshrc` without duplicating the entry or replacing existing configuration. The shared PowerShell profile also adds it to PATH, including in WezTerm sessions.

To configure only dotnetup, run `bash ./macos/install-dotnetup.sh`. Open a new terminal and run `dotnetup --version` to verify it. Run `dotnetup init` separately to choose SDKs and an access mode; setup does not initialise or migrate SDKs. The existing Homebrew .NET SDK remains installed.

Repeat runs preserve an existing dotnetup executable. Use `dotnetup self update` to update the tool itself.

## Re-running setup

Re-run `./macos/setup.sh` after pulling updates. `brew bundle` installs missing dependencies and upgrades outdated listed packages; it is not add-only and versions are not pinned. It does not uninstall applications removed from the Brewfile. Existing managed symlinks already point at the latest repository files, while conflicting files are backed up before linking. Missing PowerShell modules are installed without upgrading existing ones, and the profile line and Git include are added only if absent. Repository edits affect linked configuration immediately; repeat runs do not reset application data or sign-in state.

AltTab is installed on macOS through the `alt-tab` Homebrew cask.

## T3 Code nightly and providers

The Brewfile installs the nightly desktop app through the [`t3-code@nightly` Homebrew cask](https://formulae.brew.sh/cask/t3-code@nightly) for Apple Silicon or Intel. Open **T3 Code (Nightly)** and use **Settings > Providers** to connect Codex with ChatGPT through T3's managed runtime. For Claude, install [Claude Code separately](https://code.claude.com/docs/en/setup), run `claude auth login`, then enable Claude in T3's provider settings. This repository no longer installs or configures those agents or supplies a Claude status line. Existing agent installations and their data are left in place; setup no longer switches Claude release channels.

The nightly cask installs `T3 Code (Nightly).app`. An existing stable `T3 Code (Beta).app` is left in place; launch the nightly app after setup. Close T3 Code before upgrading. Use the in-app updater, re-run setup, or run `brew upgrade --cask t3-code@nightly` for subsequent nightly updates. See the [T3 Code installation guide](https://github.com/pingdotgg/t3code/blob/main/docs/user/install.md).

The Brewfile retains the previously audited developer and desktop applications while replacing Ghostty with WezTerm and standardising the shared terminal font on JetBrains Mono Nerd Font. It also installs Azure CLI, Fastfetch, and Terraform, with Terraform sourced from HashiCorp's official Homebrew tap. It installs current available versions rather than pinning the audited versions.
