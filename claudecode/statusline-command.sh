#!/usr/bin/env bash
# Claude Code Statusline
# Line 1: session info. Below: every rate limit (5h, 7d, per-model weekly)
# rendered as cells in a 2-column grid.

set -euo pipefail

input=$(cat)

# ── Colors ──
GREEN="\033[38;2;151;201;195m"
YELLOW="\033[38;2;229;192;123m"
RED="\033[38;2;224;108;117m"
GRAY="\033[38;2;74;88;92m"
RESET="\033[0m"

color_for_pct() {
  local pct=$1
  if (( pct >= 80 )); then
    printf '%s' "$RED"
  elif (( pct >= 50 )); then
    printf '%s' "$YELLOW"
  else
    printf '%s' "$GREEN"
  fi
}

# ── Progress bar (10 segments) ──
progress_bar() {
  local pct=$1
  local filled=$(( pct / 10 ))
  local empty=$(( 10 - filled ))
  local color
  color=$(color_for_pct "$pct")
  local bar=""
  for ((i=0; i<filled; i++)); do bar+="▰"; done
  for ((i=0; i<empty; i++)); do bar+="▱"; done
  printf '%b%s%b' "$color" "$bar" "$RESET"
}

# ── Line 1: Session info ──
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // ""')

# Context percentage (integer)
ctx_int=0
if [ -n "$used_pct" ]; then
  printf -v ctx_int "%.0f" "$used_pct" 2>/dev/null || ctx_int="${used_pct%%.*}"
fi
ctx_color=$(color_for_pct "$ctx_int")

# Git branch
git_branch=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

sep="${GRAY} │ ${RESET}"

line1="🤖 ${model}${sep}${ctx_color}📊 ${ctx_int}%${RESET}${sep}✏️ +${lines_added}/-${lines_removed}"
if [ -n "$git_branch" ]; then
  line1+="${sep}🔀 ${git_branch}"
fi

# ── Usage API (OAuth, cached 60s) ──
CACHE_FILE="/tmp/claude-usage-cache.json"
CACHE_TTL=360

fetch_usage() {
  # Get OAuth token from macOS Keychain
  local token
  token=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null || true)
  if [ -z "$token" ]; then
    return 1
  fi

  # Token is stored as JSON with nested structure
  local access_token
  access_token=$(echo "$token" | jq -r '.claudeAiOauth.accessToken // .accessToken // .access_token // empty' 2>/dev/null || true)
  if [ -z "$access_token" ]; then
    return 1
  fi

  local response
  response=$(curl -sf --max-time 5 \
    -H "Authorization: Bearer ${access_token}" \
    -H "anthropic-beta: oauth-2025-04-20" \
    "https://api.anthropic.com/api/oauth/usage" 2>/dev/null) || return 1

  # Write cache with timestamp
  local now
  now=$(date +%s)
  echo "$response" | jq --arg ts "$now" '. + {cached_at: ($ts | tonumber)}' > "$CACHE_FILE" 2>/dev/null
  echo "$response"
}

get_usage() {
  local now
  now=$(date +%s)

  # Check cache
  if [ -f "$CACHE_FILE" ]; then
    local cached_at
    cached_at=$(jq -r '.cached_at // 0' "$CACHE_FILE" 2>/dev/null || echo "0")
    local age=$(( now - cached_at ))
    if (( age < CACHE_TTL )); then
      jq -r 'del(.cached_at)' "$CACHE_FILE" 2>/dev/null
      return 0
    fi
  fi

  fetch_usage
}

# Convert ISO 8601 (UTC) to epoch seconds — GNU date first, BSD (stock macOS) fallback
iso_to_epoch() {
  local iso_time=$1
  local stripped="${iso_time%%.*}"
  date -u -d "${stripped}Z" +%s 2>/dev/null \
    || TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$stripped" +%s 2>/dev/null \
    || true
}

# Render an epoch in Asia/Tokyo with the given strftime format
epoch_to_tokyo() {
  local epoch=$1 fmt=$2
  LC_ALL=en_US.UTF-8 TZ="Asia/Tokyo" date -d "@${epoch}" +"$fmt" 2>/dev/null \
    || LC_ALL=en_US.UTF-8 TZ="Asia/Tokyo" date -r "$epoch" +"$fmt" 2>/dev/null \
    || true
}

# Reset time formats — compact, times are Asia/Tokyo. Keep these ASCII-only:
# padding below is byte-based, so a multibyte glyph here would skew the columns.
FMT_RESET_HOUR="%-l%p"        # within today: "9pm"
FMT_RESET_DAY="%b %-d %-l%p"  # days out:     "Aug 7 1pm"

format_reset() {
  local iso_time=$1 fmt=$2 epoch
  [ -z "$iso_time" ] && return 0
  epoch=$(iso_to_epoch "$iso_time")
  [ -z "$epoch" ] && return 0
  epoch_to_tokyo "$epoch" "$fmt" | sed 's/AM/am/;s/PM/pm/'
}

# ── Usage cells ──
# Every cell has the same shape — 1 emoji + fixed-width ASCII fields + a
# 10-glyph bar — so columns line up without measuring emoji display width.
cells=()

# Fields arrive as TSV; tab is IFS whitespace, so empty fields would collapse and
# shift the columns. jq emits "-" for a missing reset instead of an empty field.
add_cell() {
  local emoji=$1 label=$2 pct=$3 reset_iso=$4 window=$5
  [ -z "$pct" ] && return 0
  [ "$reset_iso" = "-" ] && reset_iso=""
  local int color bar reset_str fmt
  case "$window" in
    hour) fmt=$FMT_RESET_HOUR ;;
    *)    fmt=$FMT_RESET_DAY ;;
  esac
  printf -v int "%.0f" "$pct" 2>/dev/null || int="${pct%%.*}"
  color=$(color_for_pct "$int")
  bar=$(progress_bar "$int")
  reset_str=$(format_reset "$reset_iso" "$fmt")
  # "↻ " sits outside the padded field so the padding stays ASCII-only
  local reset_field
  if [ -n "$reset_str" ]; then
    reset_field="↻ $(printf '%-9s' "$reset_str")"
  else
    reset_field="$(printf '%-11s' "")"
  fi
  cells+=("${color}${emoji} $(printf '%-7s' "$label")${RESET}${bar} ${color}$(printf '%3d%%' "$int")${RESET} ${GRAY}${reset_field}${RESET}")
}

emoji_for() {
  case "$1" in
    5h) printf '⏱️' ;;
    7d) printf '📅' ;;
    *)  printf '🧠' ;;
  esac
}

usage_json=$(get_usage 2>/dev/null || true)

if [ -n "$usage_json" ]; then
  # limits[] is the authoritative source: session (5h), weekly_all (7d),
  # and one weekly_scoped entry per rate-limited model.
  while IFS=$'\t' read -r label pct reset fmt; do
    [ -z "$label" ] && continue
    add_cell "$(emoji_for "$label")" "$label" "$pct" "$reset" "$fmt"
  done < <(echo "$usage_json" | jq -r '
    .limits[]?
    | select((.kind == "session" or .group == "weekly") and .percent != null)
    | [ (if .kind == "session" then "5h"
         elif .kind == "weekly_all" then "7d"
         else (.scope.model.display_name // .scope.surface // "week") end),
        .percent,
        (.resets_at // "-"),
        (if .kind == "session" then "hour" else "day" end) ]
    | @tsv' 2>/dev/null || true)

  # Fallback for responses without limits[]: top-level per-window keys
  if (( ${#cells[@]} == 0 )); then
    while IFS=$'\t' read -r label pct reset fmt; do
      [ -z "$label" ] && continue
      add_cell "$(emoji_for "$label")" "$label" "$pct" "$reset" "$fmt"
    done < <(echo "$usage_json" | jq -r '
      [ ["5h", .five_hour, "hour"], ["7d", .seven_day, "day"],
        ["Opus", .seven_day_opus, "day"], ["Sonnet", .seven_day_sonnet, "day"] ]
      | .[]
      | select(.[1] != null and .[1].utilization != null)
      | [ .[0], .[1].utilization, (.[1].resets_at // "-"), .[2] ]
      | @tsv' 2>/dev/null || true)
  fi
fi

# ── Output: line 1, then usage cells in a 2-column grid ──
printf '%b' "$line1"
for ((i = 0; i < ${#cells[@]}; i += 2)); do
  row="${cells[i]}"
  if (( i + 1 < ${#cells[@]} )); then
    row+="${GRAY} │ ${RESET}${cells[i+1]}"
  fi
  printf '\n%b' "$row"
done
