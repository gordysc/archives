#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract data from JSON
model_id=$(echo "$input" | jq -r '.model.id // ""')
cwd=$(echo "$input" | jq -r '.cwd // "."')

# Shorten model name
case "$model_id" in
  *opus*)   short_model="Opus" ;;
  *sonnet*) short_model="Sonnet" ;;
  *haiku*)  short_model="Haiku" ;;
  *)        short_model="$model_id" ;;
esac

# Get current directory name
current_dir=$(basename "$cwd")

# Get git branch
branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

# Git diff stats (staged + unstaged vs HEAD)
added=0
deleted=0
if [ -n "$branch" ]; then
  read -r added deleted <<< "$(git -C "$cwd" --no-optional-locks diff HEAD --numstat 2>/dev/null \
    | awk '{a+=$1; d+=$2} END {printf "%d %d", a+0, d+0}')"
fi

# Line 1: [Model] 📁 project | ⚡ branch +added -deleted
if [ -n "$branch" ]; then
  diff_str=""
  if [ "$added" -gt 0 ] || [ "$deleted" -gt 0 ]; then
    diff_str=$(printf " \033[32m+%s\033[0m \033[31m-%s\033[0m" "$added" "$deleted")
  fi
  printf "\033[36m[%s]\033[0m 📁 %s | \033[32m⚡ %s\033[0m%s\n" "$short_model" "$current_dir" "$branch" "$diff_str"
else
  printf "\033[36m[%s]\033[0m 📁 %s\n" "$short_model" "$current_dir"
fi

# Line 2: progress bar | cost | tokens | duration
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
total_tokens=$(echo "$input" | jq -r '
  (.context_window.total_input_tokens // 0) + (.context_window.total_output_tokens // 0)
')

# Format token count compactly (e.g. 1234 -> 1.2k, 1234567 -> 1.2m)
format_tokens() {
  local n="$1"
  if [ "$n" -ge 1000000 ]; then
    printf "%.1fm" "$(echo "$n / 1000000" | bc -l)"
  elif [ "$n" -ge 1000 ]; then
    printf "%.1fk" "$(echo "$n / 1000" | bc -l)"
  else
    printf "%d" "$n"
  fi
}
tokens_str=""
if [ -n "$total_tokens" ] && [ "$total_tokens" != "0" ]; then
  tokens_str=$(format_tokens "$total_tokens")
fi

# Duration
duration_str=""
if [ "$duration_ms" != "0" ] && [ -n "$duration_ms" ]; then
  total_seconds=$((duration_ms / 1000))
  minutes=$((total_seconds / 60))
  seconds=$((total_seconds % 60))
  duration_str=$(printf "%dm %ds" "$minutes" "$seconds")
fi

# Progress bar (context window used) — green < 55%, yellow 55-74%, red >= 75%
if [ -n "$used" ]; then
  if [ "$used" -ge 75 ]; then
    bar_color="31"  # red
  elif [ "$used" -ge 55 ]; then
    bar_color="33"  # yellow
  else
    bar_color="32"  # green
  fi

  bar_width=20
  filled=$((used * bar_width / 100))

  bar=""
  for ((i=0; i<bar_width; i++)); do
    if [ "$i" -lt "$filled" ]; then
      bar="${bar}█"
    else
      bar="${bar}░"
    fi
  done

  printf "\033[%sm%s\033[0m %s%% | \033[33m\$%.2f\033[0m" "$bar_color" "$bar" "$used" "$total_cost"
else
  printf "\033[33m\$%.2f\033[0m" "$total_cost"
fi

if [ -n "$tokens_str" ]; then
  printf " | \033[35m%s tok\033[0m" "$tokens_str"
fi

if [ -n "$duration_str" ]; then
  printf " | ⏱ %s" "$duration_str"
fi

printf "\n"
