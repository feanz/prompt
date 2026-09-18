prompt_theme="$HOME/.config/prompt/theme.omp.json"

if [[ "$TERM_PROGRAM" != "Apple_Terminal" ]] && command -v oh-my-posh >/dev/null 2>&1 && [[ -r "$prompt_theme" ]]; then
  eval "$(oh-my-posh init zsh --config "$prompt_theme")"
fi

if command -v brew >/dev/null 2>&1; then
  autosuggestions="$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -r "$autosuggestions" ]] && source "$autosuggestions"
  unset autosuggestions
fi

docker_completions="$HOME/.docker/completions"
if [[ -d "$docker_completions" ]]; then
  fpath=("$docker_completions" $fpath)
fi
unset docker_completions prompt_theme

autoload -Uz compinit
compinit
