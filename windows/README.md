# Windows setup

Run `setup.ps1` from an elevated PowerShell session after installing WinGet (provided by App Installer in the Microsoft Store). Elevate as your normal Windows user: T3 Code nightly, dotnetup, and the shared configuration are installed into that account's profile. Chocolatey is no longer required.

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\windows\setup.ps1
```

The script imports `packages.json`, the Windows equivalent of `macos/Brewfile`, then runs the official T3 Code nightly installer helper, Microsoft's dotnetup downloader, and the official RustDesk MSI installer helper. The manifest declares the WinGet-managed Windows toolset, including Azure CLI, WezTerm, JetBrains Mono Nerd Font, PowerShell 7, Oh My Posh, Fastfetch, Terraform, ChatGPT, and Tailscale. Add or remove WinGet package entries in this file rather than editing PowerShell installation commands. Versions are not pinned. Windows Terminal and Cascadia Code are no longer part of the managed setup.

Packages that support machine-wide installation specify `"Scope": "machine"` in the manifest. Desktop installers use their normal system locations, generally under `%ProgramFiles%` or `%ProgramFiles(x86)%`, and fonts use the Windows font directory. Portable tools such as Fastfetch, Terraform, bat, and kubectl use WinGet's machine-wide default, `%ProgramFiles%\WinGet\Packages`, with command links in `%ProgramFiles%\WinGet\Links`. Custom WinGet path settings still apply. Oh My Posh and ChatGPT use Windows-managed MSIX/AppX locations. T3 Code nightly uses its vendor's current-user installer defaults. No custom install directory is forced.

To apply only the package list, without copying configuration or applying Explorer settings:

```powershell
winget import --import-file .\windows\packages.json --accept-package-agreements --accept-source-agreements --disable-interactivity
```

Run the package-only import from an elevated PowerShell session too, since the manifest requests machine-wide installations. This imports only WinGet packages; it does not install or update T3 Code nightly, dotnetup, or RustDesk.

## Tailscale and RustDesk

Setup installs Tailscale through WinGet with machine scope and RustDesk through `install-rustdesk.ps1`, which downloads the latest official stable MSI for x64 or ARM64 and verifies its SHA-256 digest. RustDesk is currently unavailable in WinGet. The helper skips current or newer MSI versions and upgrades older MSI versions without resetting app settings or forcing a reboot. Existing EXE installations are preserved with a warning because RustDesk's MSI cannot upgrade them; see the [manual migration steps](../docs/remote-access.md#existing-rustdesk-installations). You can also run `.\windows\install-rustdesk.ps1` independently from an elevated PowerShell session.

After setup, open Tailscale to sign in to your tailnet, then open RustDesk to finish setup using its standard public-server defaults. See [remote-access configuration](../docs/remote-access.md) for first-run steps, unattended-access options, and verification. Existing sign-in and application settings are preserved.

## 1Password CLI

The manifest installs 1Password CLI (`op`) through `AgileBits.1Password.CLI` with machine scope, using WinGet's standard portable-tool locations. After setup, restart your terminal and run `op --version` to verify the installation.

To authenticate through the 1Password desktop app, install and sign in to the app if needed, enable Windows Hello, then enable **Settings > Developer > Integrate with 1Password CLI**. Run `op vault list` to authenticate. See the [official getting-started guide](https://developer.1password.com/docs/cli/get-started/) for details. Setup installs the CLI only; desktop app installation and account sign-in remain manual.

## T3 Code nightly and providers

Setup runs `install-t3-code.ps1` to install the nightly desktop application. WinGet's `T3Tools.T3Code` package tracks stable, so it is no longer in the manifest. The helper reads the official [nightly channel pointer](https://github.com/pingdotgg/t3code/releases/download/update-feed/nightly.json), resolves that exact GitHub release, selects the x64 or ARM64 installer, and verifies its SHA-256 digest before running the current-user NSIS installer silently. A matching installed nightly version is skipped; other versions are refreshed to the published nightly. Downloads are cleaned up even on failure.

To install or refresh only T3 Code nightly, close T3 Code and run this as your normal Windows user:

```powershell
.\windows\install-t3-code.ps1
```

Open **T3 Code (Nightly)** and use **Settings > Providers** to connect Codex with ChatGPT through T3's managed runtime. For Claude, install [Claude Code separately](https://code.claude.com/docs/en/setup), run `claude auth login`, then enable Claude in T3's provider settings. This repository no longer installs or configures those agents, changes their PATH entries, or supplies a Claude status line. Existing agents and their data are left in place. See the [T3 Code provider guide](https://github.com/pingdotgg/t3code/blob/main/docs/user/install.md#providers).

An existing stable desktop installation is not explicitly uninstalled; the vendor installer controls any upgrade or coexistence behaviour. Setup does not remove T3 Code data. Use the nightly application after setup and its in-app updater for subsequent nightly updates, or re-run the helper.

## ChatGPT

ChatGPT remains `OpenAI.ChatGPT` in the WinGet manifest. That package downloads OpenAI's MSIX from `persistent.oaistatic.com`; it is not a separate WinGet-specific build. OpenAI documents a built-in updater and [standard Windows installation options](https://learn.chatgpt.com/docs/enterprise/windows-deployment), including Microsoft Store installation through WinGet. The community manifest can lag, but there is no confirmed reason to replace this installation method for this setup. No ChatGPT-specific PATH change is needed. Check the current package source with `winget show --id OpenAI.ChatGPT --exact --source winget`.

## dotnetup

Setup installs the latest public preview of [dotnetup](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnetup/getting-started) into `%USERPROFILE%\.dotnetup` when absent, using Microsoft's checksum-verifying downloader in a separate PowerShell process. It verifies the executable and adds that directory to the user and current-process PATH without duplicating the entry. The shared PowerShell profile also adds it to PATH for new sessions.

To install or configure only dotnetup, run `.\windows\install-dotnetup.ps1` as your normal user; elevation is not required. Open a new terminal and run `dotnetup --version` to verify it. Run `dotnetup init` separately to choose SDKs and an access mode. On Windows its default `everywhere` mode changes the system PATH and gives managed SDKs precedence; choose `shell` or `none` during initialisation to avoid that system-wide change. Setup does not initialise or migrate SDKs.

Repeat runs preserve an existing dotnetup executable. Use `dotnetup self update` to update the tool itself.

## Re-running and upgrading older setups

Setup is designed to be re-run after pulling repository updates, but it is not an add-only operation:

- WinGet installs missing listed applications and attempts available upgrades for recognised installations. Already-current packages are skipped. Applications not in the manifest are not upgraded or uninstalled by the import, although package dependencies may also be installed or updated.
- T3 Code nightly and RustDesk are managed separately by their installer helpers, not by the WinGet import. Codex can use T3's managed runtime; Claude installation and login remain manual.
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
