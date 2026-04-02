#!/usr/bin/env bash
# Claude Code statusLine — complements oh-my-posh powerline theme
# Color palette matches the user's oh-my-posh config:
#   black:#262B44  blue:#4B95E9  green:#59C9A5
#   orange:#F07623 red:#D81E5B  white:#E0DEF4  yellow:#F3AE35

input=$(cat)

# ── helpers ──────────────────────────────────────────────────────────────────
fg()  { printf '\033[38;2;%s;%s;%sm' "$1" "$2" "$3"; }
bg()  { printf '\033[48;2;%s;%s;%sm' "$1" "$2" "$3"; }
reset(){ printf '\033[0m'; }

# Named palette (R G B as separate args)
BLACK="38 43 68"
BLUE="75 149 233"
GREEN="89 201 165"
ORANGE="240 118 35"
RED="216 30 91"
WHITE="224 222 244"
YELLOW="243 174 53"

# Powerline separators and icons (using bash $'...' for proper encoding)
SEP=$'\ue0b0'
ICON_SPARK=$'\U000f0016'
ICON_FOLDER=$'\uf07b'
ICON_BOLT=$'\uf0e7'
ICON_EYE=$'\uf06e'

# ── extract fields ────────────────────────────────────────────────────────────
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')
five_hr=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Shorten model name: "Claude 3.5 Sonnet" -> "3.5 Sonnet"
short_model=$(echo "$model" | sed 's/^Claude //')

# Shorten cwd to basename for status line brevity
dir_name=$(basename "$cwd")

# ── segment builder ───────────────────────────────────────────────────────────
# Usage: segment <prev_bg_R> <prev_bg_G> <prev_bg_B> <bg_R> <bg_G> <bg_B> <fg_R> <fg_G> <fg_B> <text>
# Prints: powerline separator then the segment content
prev_bg=""

print_segment() {
  local bg_r=$1 bg_g=$2 bg_b=$3
  local fg_r=$4 fg_g=$5 fg_b=$6
  local text=$7

  if [ -n "$prev_bg" ]; then
    # Separator: fg = current segment bg, bg = previous segment bg
    printf "$(bg $bg_r $bg_g $bg_b)$(fg $bg_r $bg_g $bg_b)"
    # Use previous bg as separator bg
    printf "$(bg $bg_r $bg_g $bg_b)"
    # Print the powerline separator with previous bg colour as fg
    eval "printf '\033[48;2;${bg_r};${bg_g};${bg_b}m'"
    eval "printf '\033[38;2;${prev_bg}m'"
    printf "%s" "$SEP"
  fi

  # Segment body
  eval "printf '\033[48;2;${bg_r};${bg_g};${bg_b}m'"
  eval "printf '\033[38;2;${fg_r};${fg_g};${fg_b}m'"
  printf " %s " "$text"

  prev_bg="${bg_r};${bg_g};${bg_b}"
}

end_segments() {
  if [ -n "$prev_bg" ]; then
    printf "$(reset)"
    eval "printf '\033[38;2;${prev_bg}m'"
    printf "%s" "$SEP"
    printf "$(reset)"
  fi
}

# ── build status line ─────────────────────────────────────────────────────────

# We build with printf directly for correctness on all terminals.
# Segments (left to right):
#  [MODEL: yellow bg, black fg]  [DIR: orange bg, white fg]  [CTX: blue/green/red bg, black fg]  [VIM: purple bg, white fg]

# Reset helper colours
C_BLACK_FG='\033[38;2;38;43;68m'
C_WHITE_FG='\033[38;2;224;222;244m'
C_RESET='\033[0m'

# ── Segment 1: Model (yellow bg, black fg) ────────────────────────────────────
printf '\033[48;2;243;174;53m'   # bg yellow
printf '\033[38;2;38;43;68m'     # fg black
printf ' %s %s ' "$ICON_SPARK" "$short_model"

# ── Separator 1→2 ─────────────────────────────────────────────────────────────
printf '\033[48;2;240;118;35m'   # next bg orange
printf '\033[38;2;243;174;53m'   # fg = prev bg (yellow)
printf '%s' "$SEP"

# ── Segment 2: Directory (orange bg, white fg) ────────────────────────────────
printf '\033[48;2;240;118;35m'   # bg orange
printf '\033[38;2;224;222;244m'  # fg white
printf ' %s %s ' "$ICON_FOLDER" "$dir_name"

# ── Context percentage (choose bg colour based on usage) ──────────────────────
if [ -n "$used_pct" ]; then
  int_used=$(printf '%.0f' "$used_pct")

  if   [ "$int_used" -ge 85 ]; then
    # Red — danger zone
    next_bg_r=216; next_bg_g=30;  next_bg_b=91
    ctx_fg_r=224;  ctx_fg_g=222;  ctx_fg_b=244   # white
  elif [ "$int_used" -ge 60 ]; then
    # Yellow — warning
    next_bg_r=243; next_bg_g=174; next_bg_b=53
    ctx_fg_r=38;   ctx_fg_g=43;   ctx_fg_b=68    # black
  else
    # Green — healthy
    next_bg_r=89;  next_bg_g=201; next_bg_b=165
    ctx_fg_r=38;   ctx_fg_g=43;   ctx_fg_b=68    # black
  fi

  # Separator 2→3
  printf '\033[48;2;%s;%s;%sm' "$next_bg_r" "$next_bg_g" "$next_bg_b"
  printf '\033[38;2;240;118;35m'   # fg = prev bg (orange)
  printf '%s' "$SEP"

  # Segment 3: Context
  printf '\033[48;2;%s;%s;%sm' "$next_bg_r" "$next_bg_g" "$next_bg_b"
  printf '\033[38;2;%s;%s;%sm' "$ctx_fg_r" "$ctx_fg_g" "$ctx_fg_b"
  printf ' %s ctx:%s%% ' "$ICON_BOLT" "$int_used"

  last_bg_r=$next_bg_r; last_bg_g=$next_bg_g; last_bg_b=$next_bg_b
else
  last_bg_r=240; last_bg_g=118; last_bg_b=35   # orange (dir segment)
fi

# ── Rate limits segment (blue bg, white fg) — only if data present ─────────────
rate_text=""
if [ -n "$five_hr" ]; then
  rate_text="5h:$(printf '%.0f' "$five_hr")%"
fi
if [ -n "$seven_day" ]; then
  [ -n "$rate_text" ] && rate_text="$rate_text "
  rate_text="${rate_text}7d:$(printf '%.0f' "$seven_day")%"
fi

if [ -n "$rate_text" ]; then
  # Separator
  printf '\033[48;2;75;149;233m'             # next bg blue
  printf '\033[38;2;%s;%s;%sm' "$last_bg_r" "$last_bg_g" "$last_bg_b"   # fg = prev bg
  printf '%s' "$SEP"

  # Segment: rate limits (blue bg, white fg)
  printf '\033[48;2;75;149;233m'
  printf '\033[38;2;38;43;68m'              # fg black
  printf ' %s %s ' "$ICON_EYE" "$rate_text"

  last_bg_r=75; last_bg_g=149; last_bg_b=233
fi

# ── Vim mode segment (only if vim mode active) ────────────────────────────────
if [ -n "$vim_mode" ]; then
  if [ "$vim_mode" = "INSERT" ]; then
    vim_bg_r=89;  vim_bg_g=201; vim_bg_b=165   # green
    vim_fg_r=38;  vim_fg_g=43;  vim_fg_b=68    # black
  else
    vim_bg_r=243; vim_bg_g=174; vim_bg_b=53    # yellow
    vim_fg_r=38;  vim_fg_g=43;  vim_fg_b=68    # black
  fi

  # Separator
  printf '\033[48;2;%s;%s;%sm' "$vim_bg_r" "$vim_bg_g" "$vim_bg_b"
  printf '\033[38;2;%s;%s;%sm' "$last_bg_r" "$last_bg_g" "$last_bg_b"
  printf '%s' "$SEP"

  # Segment
  printf '\033[48;2;%s;%s;%sm' "$vim_bg_r" "$vim_bg_g" "$vim_bg_b"
  printf '\033[38;2;%s;%s;%sm' "$vim_fg_r" "$vim_fg_g" "$vim_fg_b"
  printf ' %s ' "$vim_mode"

  last_bg_r=$vim_bg_r; last_bg_g=$vim_bg_g; last_bg_b=$vim_bg_b
fi

# ── Final powerline cap ────────────────────────────────────────────────────────
printf '\033[0m'
printf '\033[38;2;%s;%s;%sm' "$last_bg_r" "$last_bg_g" "$last_bg_b"
printf '%s' "$SEP"
printf '\033[0m'
