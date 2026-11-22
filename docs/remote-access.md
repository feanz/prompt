# Tailscale and RustDesk

Both applications are included in the default Windows and macOS setup. Re-run the platform setup after pulling these changes.

| Platform | Tailscale | RustDesk |
| --- | --- | --- |
| Windows | WinGet `Tailscale.Tailscale`, machine scope | Official stable MSI via `windows/install-rustdesk.ps1` |
| macOS | Homebrew cask `tailscale-app` (standalone desktop app) | Homebrew cask `rustdesk` |

The Windows RustDesk helper resolves the latest stable release from the [official GitHub releases](https://github.com/rustdesk/rustdesk/releases/latest), selects the x64 or ARM64 MSI, and verifies its SHA-256 digest from the GitHub release API before installation. It skips an installed machine-wide MSI version that is already current or newer. Older MSI versions are upgraded using MSI defaults without forcing a restart. Existing EXE installations are preserved with a warning. RustDesk is currently absent from the [WinGet catalogue](https://github.com/microsoft/winget-pkgs/issues/368229), so it is deliberately excluded from `windows/packages.json`.

To install or update only these apps:

```powershell
# Windows: run from an elevated PowerShell session in the repository root.
winget install --id Tailscale.Tailscale --exact --scope machine --accept-package-agreements --accept-source-agreements
.\windows\install-rustdesk.ps1
```

```shell
# macOS
brew install --cask tailscale-app rustdesk
```

For later Tailscale updates on Windows use `winget upgrade --id Tailscale.Tailscale --exact`; for Mac updates use `brew upgrade --cask tailscale-app rustdesk`. Full setup reruns also attempt upgrades as described in the platform READMEs.

## Existing RustDesk installations

On Windows, RustDesk's MSI rejects installations created by the EXE installer. Setup detects these and leaves them in place, allowing the rest of setup to continue. Update an EXE installation through RustDesk itself. To migrate to MSI, first back up its settings, close RustDesk, uninstall the EXE-installed copy using Windows Installed apps, then run `windows/install-rustdesk.ps1` from an elevated PowerShell session. Preserve user settings during uninstall and verify them afterwards; setup never performs this migration automatically.

On Mac, Homebrew may refuse to adopt a manually installed `/Applications/RustDesk.app` whose version differs from the cask. Before setup, quit RustDesk and move only that application bundle to a backup location outside `/Applications`, then rerun setup. Leave RustDesk's files in your user Library in place so the new app can reuse its settings. Do not use a cleanup tool or `brew uninstall --zap` for this migration.

## Tailscale: finish on each machine

1. Open Tailscale from the Start menu (Windows) or Applications (Mac).
2. On Mac, approve the system/network extension and VPN configuration when prompted. Enable launch at login in the app if you want it available after signing in to macOS.
3. Sign in to the intended Tailscale network (tailnet) using the app's browser login. Approve the device in the admin console if your tailnet requires it.
4. Confirm both machines appear connected in Tailscale. On Windows, run `tailscale status`; on Mac, use the app or run `/Applications/Tailscale.app/Contents/MacOS/Tailscale status`.

The Mac setup uses the [standalone desktop app](https://tailscale.com/docs/concepts/macos-variants), packaged by the [`tailscale-app` cask](https://formulae.brew.sh/cask/tailscale-app), rather than the separate CLI-only `tailscale` formula. If an App Store or other Tailscale variant is already installed, follow the vendor's variant-switching instructions before running setup; setup does not remove it automatically.

For Windows connectivity after signing out, enable **Preferences > Run unattended** in Tailscale after login. See [Tailscale's unattended-mode guidance](https://tailscale.com/docs/how-to/run-unattended) for platform limitations; the Mac desktop app does not provide the same before-login behaviour.

## RustDesk: finish on each machine

1. Open RustDesk from the Start menu or Applications.
2. On Mac, use RustDesk's permission prompts to grant **Screen Recording** and **Accessibility** under **System Settings > Privacy & Security**. Grant **Input Monitoring** if requested for local input. Quit and reopen RustDesk after changing permissions if prompted. See the [official Mac guide](https://rustdesk.com/docs/en/client/mac/).
3. Leave the ID/relay server settings at their defaults to use RustDesk's public servers. To connect, enter the other machine's RustDesk ID and have the person at that machine accept the session, or use the password displayed by that app.
4. Test a session in each direction, checking both screen capture and keyboard/mouse control.

If you need unattended RustDesk access, configure a unique permanent password locally in **Settings > Security** and verify the service/startup settings in the app. Installation alone does not guarantee access after logout or reboot; test that separately before relying on it.

Tailscale and RustDesk run independently with these defaults. Installing both does not route RustDesk sessions exclusively through Tailscale; RustDesk continues to use its public ID/relay service. Setup preserves existing sign-in, server, and security settings on reruns. It does not copy credentials, auth keys, device IDs, or unattended-access passwords into the repository.
