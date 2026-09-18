# Cross-platform terminal setup

This repository contains the repeatable terminal, prompt, Git, and application setup for Windows and macOS.

## Repository structure

```text
.
├── macos/                  # Homebrew, Ghostty, and zsh
├── windows/                # Chocolatey, Windows Terminal, and PowerShell
├── shared/                 # Git, Oh My Posh, and portable integrations
└── docs/                   # System audits and design notes
```

The platform setup scripts install their package manifests and connect platform-specific shells to the same Git configuration and Oh My Posh theme.

## Shared configuration

The following files are used on both platforms:

- `shared/git/gitconfig` contains portable Git defaults. It deliberately excludes user name, email, credentials, line-ending policy, and editor choice.
- `shared/git/git-aliases` contains the existing common Git alias library, with GitHub-opening commands made portable through `gh`.
- `shared/oh-my-posh/theme.omp.json` is the prompt theme used by zsh and PowerShell.
- `shared/claude/statusline-command.sh` is the portable Claude Code status line.

The shared config includes a platform layer from `macos/git/gitconfig` or `windows/git/gitconfig` for line endings, editor, and merge-tool behavior. Each setup registers the shared config rather than replacing the user's global `.gitconfig`. Personal identity and credentials therefore remain machine-local:

```shell
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

## macOS

Requirements:

- macOS on Apple Silicon or Intel
- Homebrew
- Git checkout of this repository

Run:

```shell
./macos/setup.sh
```

The script:

1. Applies `macos/Brewfile` with `brew bundle`.
2. Links the shared theme and Git files into `~/.config/prompt`.
3. Backs up and links the managed `.zprofile`, `.zshrc`, and Ghostty config.
4. Registers the shared Git config with the user's global Git configuration.

Existing managed-file destinations are backed up with a timestamp before replacement. Restart Ghostty or open a new login shell afterward.

The Brewfile reflects the explicit formulae, casks, and VS Code extensions found in the 2026-09-17 Mac audit. Go is intentionally omitted because it was an orphaned dependency. The shell prefers the SDK from the `dotnet-sdk` cask over the runtime installed as a dependency of Homebrew PowerShell.

See [macos/README.md](macos/README.md) for configuration details.

## Windows

Requirements:

- Windows PowerShell or PowerShell 7 running as an administrator
- Chocolatey
- Git checkout of this repository

Run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\windows\setup.ps1
```

To replace Windows Terminal settings with the repository version, request that separately:

```powershell
.\windows\setup.ps1 -InstallTerminalSettings
```

That option backs up existing terminal settings first. The script otherwise installs or upgrades the Chocolatey packages, installs the PowerShell modules, copies managed shared configuration to `~/.config/prompt`, connects the PowerShell profile, applies Explorer preferences, and registers the Git include.

See [windows/README.md](windows/README.md) for configuration details.

## Validation

Useful checks after changing configuration:

```shell
bash -n macos/setup.sh
zsh -n macos/zsh/.zprofile macos/zsh/.zshrc
jq empty shared/oh-my-posh/theme.omp.json windows/terminal/settings.json
brew bundle check --file macos/Brewfile
```

On a machine with PowerShell:

```powershell
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile(
    (Resolve-Path '.\windows\setup.ps1'),
    [ref]$null,
    [ref]$errors
) > $null
$errors
```

The original Mac discovery and package analysis is recorded in [docs/mac-system-audit.md](docs/mac-system-audit.md).
