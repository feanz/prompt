# Windows setup

Run `setup.ps1` from an elevated PowerShell session after installing Chocolatey.

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\windows\setup.ps1
```

The script installs or upgrades the existing Windows toolset plus WezTerm, JetBrains Mono Nerd Font, PowerShell 7, Oh My Posh, and Fastfetch. Windows Terminal and Cascadia Code are no longer part of the managed setup.

## Managed configuration

The setup copies these shared files into the user's `.config` directory:

- WezTerm configuration
- Oh My Posh stealth theme
- PowerShell profile
- Fastfetch configuration and logo
- Git defaults, aliases, and Windows-specific settings

The shared PowerShell installer installs `posh-git`, `PSReadLine`, `Terminal-Icons`, and `z`, then adds one dot-source line to PowerShell 7's `CurrentUserAllHosts` profile.

Re-run setup after pulling changes so the copied Windows configuration is refreshed. The Explorer helper continues to enable hidden files, file extensions, and protected operating-system files.
