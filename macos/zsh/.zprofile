# Homebrew uses /opt/homebrew on Apple Silicon and /usr/local on Intel Macs.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

typeset -U path PATH

[[ -d "$HOME/.docker/bin" ]] && path+=("$HOME/.docker/bin")

# Prefer the full SDK installed by the dotnet-sdk cask over the runtime used by
# Homebrew's PowerShell formula.
[[ -x /usr/local/share/dotnet/dotnet ]] && path=(/usr/local/share/dotnet $path)

export PATH
