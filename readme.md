# Cross-platform terminal setup

This repository configures the same terminal experience on Windows and macOS: **WezTerm** launches **PowerShell 7**, which renders the shared **Oh My Posh** theme.

The WezTerm styling, prompt, PowerShell behavior, and Fastfetch setup are adapted from [`deja666/wezterm-dotfiles`](https://github.com/deja666/wezterm-dotfiles). See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for attribution.

## Repository structure

```text
.
├── shared/
│   ├── wezterm/          # Common terminal configuration
│   ├── powershell/       # Common profile and profile installer
│   ├── oh-my-posh/       # Common stealth prompt theme
│   ├── fastfetch/        # Common system-information configuration
│   ├── git/              # Common Git defaults and aliases
│   └── claude/           # Portable Claude Code status line
├── macos/                # Homebrew manifest and macOS bootstrap
├── windows/              # Chocolatey bootstrap and Windows preferences
└── docs/                 # System audits and design notes
```

## Shared terminal behavior

- WezTerm uses GeistMono Nerd Font, the upstream dark colour palette, tab styling, pane shortcuts, and right-side working-directory/time status.
- PowerShell 7 is the default program on both operating systems.
- The shared PowerShell profile loads Oh My Posh, `posh-git`, `PSReadLine`, `Terminal-Icons`, and `z`.
- Fastfetch uses the shared custom logo and module list.
- Shared Git settings are included without replacing machine-local identity or credentials.

On macOS, WezTerm adds the appropriate Homebrew prefix and the full .NET SDK to its child-process `PATH`. On Windows, it resolves `pwsh.exe` from the installed PowerShell package.

## macOS setup

Install [Homebrew](https://brew.sh), clone this repository, then run:

```shell
./macos/setup.sh
```

The script applies `macos/Brewfile`, installs the PowerShell modules, links shared configuration into `~/.config`, and registers the shared Git include. Existing config destinations are moved to timestamped backups before replacement.

See [macos/README.md](macos/README.md) for details.

## Windows setup

Install [Chocolatey](https://chocolatey.org/install), clone this repository, then run an elevated PowerShell session:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\windows\setup.ps1
```

The script installs or upgrades the Chocolatey package set, copies shared configuration into the user's `.config` directory, installs the PowerShell modules, registers the shared Git include, and applies the Explorer preferences.

See [windows/README.md](windows/README.md) for details.

## Personal Git identity

The repository deliberately excludes Git identity and credentials. Configure them per machine:

```shell
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

## Validation

```shell
bash -n macos/setup.sh
jq empty shared/oh-my-posh/stealth.omp.json
wezterm --config-file shared/wezterm/wezterm.lua show-keys
brew bundle check --file macos/Brewfile
```

The original Mac discovery is retained in [docs/mac-system-audit.md](docs/mac-system-audit.md) as a historical record of the setup that preceded WezTerm.
