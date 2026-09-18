# Mac system audit

Audit date: 2026-09-17

This is a read-only inventory of the current Mac terminal and Homebrew setup. It is intended to be the input to a later repository restructure and Mac bootstrap implementation; it does not yet declare every discovered package to be part of the desired standard setup.

## Executive summary

- The terminal referred to as "Giti" is **Ghostty 1.3.1**.
- The interactive shell is Apple's **zsh 5.9** on an Apple Silicon Mac running **macOS 26.4 (build 25E246)**.
- The prompt is **Oh My Posh 31.3.0** with a custom, valid JSON theme at `~/ZSHThemes.json`.
- Ghostty uses the **Broadcast** theme and **JetBrainsMono NFM Regular** at 20 pt. The configured font is present.
- Homebrew 7.0.2 is installed at `/opt/homebrew`. The installation contains 38 formulae, 10 casks, one third-party tap, and 35 VS Code extensions.
- Homebrew's reproducible top-level set is seven formulae and ten casks. Most of the other formulae are dependencies.
- Two .NET installations currently coexist. `/opt/homebrew/bin/dotnet` resolves to formula version 10.0.400 while the directly installed `dotnet-sdk` cask contains 10.0.401.
- Go 1.27.1 is installed as a dependency with no remaining installed dependent. It is omitted from `brew bundle dump`, so it would not survive a clean rebuild unless made explicit.
- `brew doctor` reports only a newer Command Line Tools release and Homebrew's Tier 2 support notice for this OS/toolchain combination.

## Repository baseline

The repository is currently organised as a flat, primarily Windows-only setup:

| File | Current purpose |
| --- | --- |
| `Setup.ps1` | Chocolatey packages, PowerShell modules, and Explorer preferences |
| `Microsoft.PowerShell_profile.ps1` | Oh My Posh, Terminal-Icons, and `z` initialisation |
| `settings.json` | Windows Terminal profiles, key bindings, fonts, and colour schemes |
| `Set-WindowsExplorerOptions.ps1` | Windows Explorer preference helper |
| `prompt.PNG` | Windows prompt screenshot |
| `statusline-command.sh` | Claude Code status line shared independently of the Windows setup |
| `.gitconfig` | Git identity plus Windows-specific editor, line-ending, KDiff3, and credential settings |
| `.gitconfig.aliases` | Shared Git alias library |
| `readme.md` | Windows-only manual setup instructions |

The JSON, Bash, and PowerShell files pass basic syntax validation. The working tree was clean before this report was added.

## Terminal: Ghostty

Installed application:

- Application: `/Applications/Ghostty.app`
- Version: 1.3.1 (build 15212)
- Homebrew cask: `ghostty` 1.3.1
- User config: `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`
- Config validation: passed using `ghostty +validate-config`

Current user configuration:

```ini
theme = "Broadcast"
font-family="JetBrainsMono NFM Regular"
font-size = 20
window-padding-x = 10
window-padding-y = 10
adjust-cell-height=35%
copy-on-select="clipboard"
window-save-state=always
maximize=true
```

The selected font is installed by the `font-jetbrains-mono-nerd-font` cask, and Ghostty can resolve `JetBrainsMono NFM Regular`. The Broadcast theme resolves to a dark background (`#2b2b2b`) and light foreground (`#e6e1dc`). Automatic updates are enabled in the app preferences. Window position and update-check state are machine-local preferences and should not be version-controlled.

## Shell: zsh

Startup files found:

- `~/.zprofile` (215 bytes)
- `~/.zshrc` (448 bytes)
- No user `~/.zshenv`, `~/.zlogin`, or `~/.zlogout` was found.

Both startup files pass `zsh -n` syntax validation.

### `.zprofile`

The login profile:

1. Appends `/Users/richardforrest/.docker/bin` to `PATH`.
2. Initialises Homebrew using `/opt/homebrew/bin/brew shellenv zsh`.

### `.zshrc`

The interactive profile:

1. Initialises Oh My Posh for every terminal except Apple Terminal.
2. Loads the custom prompt from `~/ZSHThemes.json`.
3. Forces `TERM=xterm-256color`.
4. Loads Homebrew's `zsh-autosuggestions` plugin.
5. Adds Docker Desktop completions to `fpath` and runs `compinit` when needed.

In a simulated Ghostty login shell, the expected Oh My Posh pre-command and pre-execution hooks are registered, autosuggestions use the `history` strategy, and Docker completion resolves to `_docker`.

### Oh My Posh theme

The custom theme is valid JSON and renders successfully with Oh My Posh 31.3.0. It is a two-line prompt with these conditional segments:

- OS, battery, path, Git branch/stash, Node version, elevated/root state, Kubernetes context, and command status.
- A blue arrow on the second line.
- The path uses folder style, and the Git segment shows the upstream icon, branch, and stash count.

The theme depends on Nerd Font glyphs, supplied by the installed JetBrains Mono Nerd Font cask.

### Portability observations

- The Docker paths contain the literal username `/Users/richardforrest`; bootstrap-managed files should use `$HOME` instead.
- `/opt/homebrew` is correct for this Apple Silicon Mac, but an installer should derive it from `brew --prefix` so the same files also work on Intel Macs.
- Re-entering or sourcing the login environment can duplicate both Homebrew and Docker entries in `PATH`. The effective audit shell contained each twice.
- `export TERM=xterm-256color` overrides the terminal identity supplied by Ghostty. This may be an intentional compatibility workaround, but it should be tested and documented before preserving it.
- The Apple Terminal exception means the custom prompt is deliberately disabled there but enabled in Ghostty.
- `~/ZSHThemes.json` is outside a conventional config directory and is not currently tracked by this repository.

No secrets or credentials were found in the inspected Ghostty, zsh, or Oh My Posh files.

## Homebrew inventory

### Homebrew environment

| Item | Value |
| --- | --- |
| Homebrew version | 7.0.2 |
| Prefix | `/opt/homebrew` |
| Architecture | arm64 |
| Taps | `jandedobbeleer/oh-my-posh` |
| Formulae | 38 |
| Casks | 10 |
| VS Code extensions | 35 |

### Explicit formulae captured by `brew bundle dump`

These are the current reproducible top-level formulae:

| Formula | Version | Purpose |
| --- | --- | --- |
| `gh` | 2.100.0 | GitHub CLI |
| `git` | 2.55.0 | Git |
| `htop` | 3.5.3 | Process viewer |
| `node` | 26.8.2 | Node.js; npm is 11.19.1 |
| `powershell` | 7.6.6 | PowerShell |
| `zsh-autosuggestions` | 0.7.1 | zsh suggestions |
| `jandedobbeleer/oh-my-posh/oh-my-posh` | 31.3.0 | Cross-shell prompt engine |

The generated Brewfile also includes the third-party `jandedobbeleer/oh-my-posh` tap. Oh My Posh is represented by its short installed name in package inventory output and its fully qualified tap name in the generated Brewfile.

### Casks

| Cask | Installed version |
| --- | --- |
| `chatgpt` | 26.908.40834 |
| `docker-desktop` | 4.91.0,239619 |
| `dotnet-sdk` | 10.0.401 |
| `font-jetbrains-mono-nerd-font` | 3.5.1 |
| `ghostty` | 1.3.1 |
| `microsoft-outlook` | 16.112.26081720 |
| `microsoft-teams` | 26225.1706.5101.3140 |
| `rider` | 2026.2.1,262.9437.287 |
| `visual-studio-code` | 1.137.0 |
| `wispr-flow` | 1.6.872 |

### VS Code extensions captured by Homebrew

```text
42crunch.vscode-openapi
4ops.terraform
adpyke.vscode-sql-formatter
austenc.tailwind-docs
bierner.markdown-mermaid
bradlc.vscode-tailwindcss
darkriszty.markdown-table-prettify
dbaeumer.vscode-eslint
editorconfig.editorconfig
esbenp.prettier-vscode
hediet.vscode-drawio
humao.rest-client
kabeerhussain.json-diff-side-by-side
mechatroner.rainbow-csv
microsoft-aspire.aspire-vscode
ms-dotnettools.csdevkit
ms-dotnettools.csharp
ms-dotnettools.vscode-dotnet-runtime
ms-mssql.data-workspace-vscode
ms-mssql.mssql
ms-mssql.sql-bindings-vscode
ms-mssql.sql-database-projects-vscode
ms-python.debugpy
ms-python.python
ms-python.vscode-pylance
ms-python.vscode-python-envs
ms-vscode-remote.remote-wsl
nikolaosgeorgiou.html-fmt-vscode
redhat.vscode-yaml
streetsidesoftware.code-spell-checker
tomoki1207.pdf
usernamehw.errorlens
vitest.explorer
vue.volar
yzhang.markdown-all-in-one
```

### Dependency-only formulae

The remaining installed formulae are not emitted as top-level entries by `brew bundle dump`:

```text
ada-url        brotli          c-ares          ca-certificates
dotnet         fmt             gettext         go
hdrhistogram_c icu4c@78        json-c          libffi
libnghttp2     libnghttp3      libngtcp2       libunistring
libuv          llhttp          lz4             merve
nbytes         ncurses         openssl@3       pcre2
readline       simdjson        simdutf         sqlite
uvwasi         xz              zstd
```

`dotnet` is required by the Homebrew `powershell` formula. `go` is marked as installed as a dependency, but no installed formula currently declares it as a dependency; it should be treated as an orphan that requires an explicit keep/remove decision.

### Package issues and maintenance state

Two .NET SDK sources coexist:

| Command | Version | Source |
| --- | --- | --- |
| `/opt/homebrew/bin/dotnet` | 10.0.400 | `dotnet` formula, required by `powershell` |
| `/usr/local/share/dotnet/dotnet` | 10.0.401 | `dotnet-sdk` cask, installed on request |

Because `/opt/homebrew/bin` appears earlier in `PATH`, an unqualified `dotnet` command uses 10.0.400. The future setup should either accept this Homebrew/PowerShell coupling, avoid the duplicate cask, or explicitly set the desired SDK resolution.

Eight items were outdated at audit time:

- Formulae: `gh`, `merve`, `readline`, `simdutf`.
- Casks: `chatgpt`, `rider`, `visual-studio-code`, `wispr-flow`.

`brew doctor` reported:

- A newer Command Line Tools release is available (Xcode Command Line Tools 26.6).
- The current OS/toolchain combination is a Homebrew Tier 2 configuration.

No package upgrades or repairs were performed during the audit.

## Windows/Mac parity snapshot

The current Windows script asks Chocolatey for several tools that are not part of the current Homebrew top-level set:

| Windows setup item | Current Mac state |
| --- | --- |
| Git | Homebrew formula |
| Nerd Font | JetBrains Mono Nerd Font cask; Windows uses Cascadia Code Nerd Font |
| Terminal | Ghostty cask; Windows uses Windows Terminal |
| PowerShell | Homebrew formula |
| Oh My Posh | Third-party Homebrew tap/formula |
| Vim | macOS system Vim only |
| KDiff3 | Not found |
| GitHub CLI | Homebrew formula |
| bat | Not found |
| Azure CLI | Not found |
| ChatGPT | Homebrew cask |
| AWS CLI | Not found |
| kubectl | Present through Docker Desktop at `/usr/local/bin/kubectl`, not a Homebrew top-level package |

Conversely, the Mac has Node, htop, zsh-autosuggestions, Docker Desktop, .NET/Rider, VS Code, Outlook, Teams, Wispr Flow, and Go that are not represented in the Windows bootstrap.

This is an inventory difference, not yet a recommendation that every application be installed on both platforms.

## Recommended repository shape

A clear next structure would separate shared configuration from OS-specific installers and terminal settings:

```text
.
├── README.md
├── common/
│   └── oh-my-posh/
│       └── theme.omp.json
├── macos/
│   ├── Brewfile
│   ├── bootstrap.sh
│   ├── ghostty/
│   │   └── config
│   └── zsh/
│       ├── .zprofile
│       └── .zshrc
├── windows/
│   ├── setup.ps1
│   ├── explorer/
│   │   └── Set-WindowsExplorerOptions.ps1
│   ├── powershell/
│   │   └── Microsoft.PowerShell_profile.ps1
│   └── terminal/
│       └── settings.json
├── integrations/
│   └── claude/
│       └── statusline-command.sh
└── docs/
    └── mac-system-audit.md
```

The shared Oh My Posh theme can be used by both zsh and PowerShell. Each bootstrap should link or copy version-controlled configuration into the platform's expected locations and should be safe to run repeatedly.

## Decisions required before implementation

1. **Package scope:** decide whether Outlook, Teams, ChatGPT, Wispr Flow, Rider, and all VS Code extensions belong in the default setup or in optional/work profiles.
2. **Go:** promote `go` to an explicit Brewfile entry if it is intentionally used, otherwise leave it out and optionally clean it later.
3. **.NET:** choose the intended SDK source and command precedence; the current formula/cask combination exposes two patch versions.
4. **Cross-platform CLI baseline:** decide whether `bat`, Azure CLI, AWS CLI, KDiff3, and a standalone `kubectl` should be standard on both systems.
5. **Font baseline:** use one Nerd Font across both platforms or preserve JetBrains Mono on Mac and Cascadia Code on Windows.
6. **Terminal capability override:** verify whether the forced `TERM=xterm-256color` is still needed in Ghostty.
7. **Installation profiles:** consider a minimal core plus optional `developer`, `work`, and `personal` groups rather than installing every discovered application unconditionally.

## Proposed implementation sequence

1. Agree the package/profile decisions above.
2. Move existing Windows files without changing behaviour and update references.
3. Add the shared Oh My Posh theme and point both shells at it.
4. Add a reviewed `macos/Brewfile` rather than blindly committing every discovered package.
5. Add idempotent Mac zsh/Ghostty bootstrap logic with dynamic home and Homebrew paths.
6. Add validation commands for shell syntax, JSON, Brewfile consistency, and bootstrap dry runs.
7. Test from a clean user environment or disposable macOS account before using the bootstrap as the source of truth.
