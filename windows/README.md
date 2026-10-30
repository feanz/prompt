# Windows setup

Run `setup.ps1` from an elevated PowerShell session after installing WinGet (provided by App Installer in the Microsoft Store). Chocolatey is no longer required.

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\windows\setup.ps1
```

The script imports `packages.json`, the Windows equivalent of `macos/Brewfile`. This declares the Windows toolset, including Azure CLI, WezTerm, JetBrains Mono Nerd Font, PowerShell 7, Oh My Posh, Fastfetch, Terraform, Claude Code CLI, and T3 Code. Add or remove package entries in this file rather than editing PowerShell installation commands. Versions are not pinned. Windows Terminal and Cascadia Code are no longer part of the managed setup.

To apply only the package list, without copying configuration or applying Explorer settings:

```powershell
winget import --import-file .\windows\packages.json --accept-package-agreements --accept-source-agreements --disable-interactivity
```

Claude Code CLI uses `Anthropic.ClaudeCode`; T3 Code uses `T3Tools.T3Code`. After setup, open a new terminal, run `claude`, and follow the sign-in prompts. WinGet installations of Claude Code do not auto-update; re-run setup or use `winget upgrade --id Anthropic.ClaudeCode --exact` to update. The manifest includes Git for Windows, providing Git Bash for Claude Code.

## Re-running and upgrading older setups

Setup is designed to be re-run after pulling repository updates, but it is not an add-only operation:

- WinGet installs missing listed applications and attempts available upgrades for recognised installations. Already-current packages are skipped. Applications not in the manifest are not upgraded or uninstalled by the import, although package dependencies may also be installed or updated.
- The script refreshes its process PATH after installation so newly installed tools can be found; restart your terminal after setup for other sessions to pick up changes.
- Managed configuration files are copied again, overwriting local edits at those destinations. Keep customisations in the repository if they should survive setup.
- Missing PowerShell modules are installed; existing modules are not automatically upgraded. The managed profile line and Git include are added only if absent, and the same Explorer settings are reapplied.
- Removing an entry from `packages.json` does not uninstall that application. Setup does not remove Chocolatey or its package records.

On a machine previously set up with Chocolatey, WinGet may recognise standard installer-based applications, but this is not a guaranteed package-manager migration. Portable tools such as Terraform, bat, and kubectl can be installed side by side, and old Chocolatey shims may still take precedence on PATH. Before relying on the migrated setup, inspect `winget list`, `choco list`, and `Get-Command terraform, bat, kubectl -All`. Resolve duplicate installations deliberately; setup never automatically uninstalls the old copies.

## Managed configuration

The setup copies these shared files into the user's `.config` directory:

- WezTerm configuration
- Oh My Posh stealth theme
- PowerShell profile
- Fastfetch configuration and logo
- Git defaults, aliases, and Windows-specific settings

The shared PowerShell installer installs `posh-git`, `PSReadLine`, `Terminal-Icons`, and `z`, then adds one dot-source line to PowerShell 7's `CurrentUserAllHosts` profile.

Re-run setup after pulling changes so the copied Windows configuration is refreshed. The Explorer helper continues to enable hidden files, file extensions, and protected operating-system files.
