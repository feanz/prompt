# Windows setup

Run `setup.ps1` from an elevated PowerShell session after installing WinGet (provided by App Installer in the Microsoft Store). Elevate as your normal Windows user: Claude Code and the shared configuration are installed into that account's profile. Chocolatey is no longer required.

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\windows\setup.ps1
```

The script imports `packages.json`, the Windows equivalent of `macos/Brewfile`, then runs Anthropic's native Claude Code installer. The manifest declares the WinGet-managed Windows toolset, including Azure CLI, WezTerm, JetBrains Mono Nerd Font, PowerShell 7, Oh My Posh, Fastfetch, Terraform, ChatGPT, and T3 Code. Add or remove WinGet package entries in this file rather than editing PowerShell installation commands. Versions are not pinned. Windows Terminal and Cascadia Code are no longer part of the managed setup.

Packages that support machine-wide installation specify `"Scope": "machine"` in the manifest. Desktop installers use their normal system locations, generally under `%ProgramFiles%` or `%ProgramFiles(x86)%`, and fonts use the Windows font directory. Portable tools such as Fastfetch, Terraform, bat, and kubectl use WinGet's machine-wide default, `%ProgramFiles%\WinGet\Packages`, with command links in `%ProgramFiles%\WinGet\Links`. Custom WinGet path settings still apply. Oh My Posh and ChatGPT use Windows-managed MSIX/AppX locations; T3 Code retains its vendor installer default because its WinGet manifest does not declare machine-scope support. Claude Code uses Anthropic's per-user location, `%USERPROFILE%\.local\bin\claude.exe`. No custom install directory is forced.

To apply only the package list, without copying configuration or applying Explorer settings:

```powershell
winget import --import-file .\windows\packages.json --accept-package-agreements --accept-source-agreements --disable-interactivity
```

Run the package-only import from an elevated PowerShell session too, since the manifest requests machine-wide installations. This imports only WinGet packages; it does not install or update Claude Code.

## 1Password CLI

The manifest installs 1Password CLI (`op`) through `AgileBits.1Password.CLI` with machine scope, using WinGet's standard portable-tool locations. After setup, restart your terminal and run `op --version` to verify the installation.

To authenticate through the 1Password desktop app, install and sign in to the app if needed, enable Windows Hello, then enable **Settings > Developer > Integrate with 1Password CLI**. Run `op vault list` to authenticate. See the [official getting-started guide](https://developer.1password.com/docs/cli/get-started/) for details. Setup installs the CLI only; desktop app installation and account sign-in remain manual.

## Claude Code and ChatGPT

Claude Code uses [Anthropic's recommended native Windows installer](https://code.claude.com/docs/en/setup#install-claude-code), `https://claude.ai/install.ps1`, with the `latest` target. Native installations automatically update. WinGet offers [`Anthropic.ClaudeCode`](https://github.com/microsoft/winget-pkgs/tree/master/manifests/a/Anthropic/ClaudeCode), but has no separate latest-channel package equivalent to Homebrew's `claude-code@latest`. Its published versions can lag behind upstream releases, and WinGet installations do not auto-update by default. This setup keeps the native installer to follow the latest channel with automatic updates.

Setup downloads the official installer to a temporary file and runs it in a separate PowerShell process so installer failures stop setup cleanly. It verifies the installed executable, adds `%USERPROFILE%\.local\bin` to the user and current-process PATH if absent, and warns if another `claude` command takes precedence. It does not change the machine PATH. Re-running setup runs the native installer again.

To install or refresh only Claude Code, run this from PowerShell as your normal user (elevation is not required):

```powershell
.\windows\install-claude.ps1
```

If Claude Code was previously installed through WinGet, close running Claude sessions and uninstall that copy first with `winget uninstall --id Anthropic.ClaudeCode --exact` (elevate for a machine-wide installation). Setup does not automatically remove installations managed by other package managers. After setup, restart your terminal, run `claude --version`, then run `claude` and follow the sign-in prompts. Existing applications may need restarting to inherit the updated PATH. The manifest includes Git for Windows, providing Git Bash for Claude Code.

ChatGPT remains `OpenAI.ChatGPT` in the WinGet manifest. That package downloads OpenAI's MSIX from `persistent.oaistatic.com`; it is not a separate WinGet-specific build. OpenAI documents a built-in updater and [standard Windows installation options](https://learn.chatgpt.com/docs/enterprise/windows-deployment), including Microsoft Store installation through WinGet. The community manifest can lag, but there is no confirmed reason to replace this installation method for this setup. No ChatGPT-specific PATH change is needed. Check the current package source with `winget show --id OpenAI.ChatGPT --exact --source winget`.

## Re-running and upgrading older setups

Setup is designed to be re-run after pulling repository updates, but it is not an add-only operation:

- WinGet installs missing listed applications and attempts available upgrades for recognised installations. Already-current packages are skipped. Applications not in the manifest are not upgraded or uninstalled by the import, although package dependencies may also be installed or updated.
- Claude Code is managed separately by the native installer and its automatic updater, not by the WinGet import.
- Changing scope does not move existing installations. To move a tool previously installed under your user profile, close any running instances and uninstall that copy using its original package manager, then re-run setup to install it with the manifest's machine scope. For WinGet portable tools, run `winget uninstall --id <PackageIdentifier> --exact --scope user --preserve` from a non-elevated PowerShell session, then run setup from an elevated session. An import may otherwise retain the existing installation or install a separate machine-wide copy.
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

[Terminal-Icons](https://github.com/devblackops/Terminal-Icons) is installed from PowerShell Gallery and loaded automatically by the shared profile. Open a new WezTerm PowerShell tab and run `dir` to see file and folder icons using the configured JetBrains Mono Nerd Font. See [file and folder icons](../readme.md#file-and-folder-icons) for manual activation and troubleshooting.

Re-run setup after pulling changes so the copied Windows configuration is refreshed. The Explorer helper continues to enable hidden files, file extensions, and protected operating-system files.
