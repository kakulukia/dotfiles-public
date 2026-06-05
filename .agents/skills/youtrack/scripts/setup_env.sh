#!/usr/bin/env bash
set -euo pipefail

marker_start="# >>> youtrack-skill >>>"
marker_end="# <<< youtrack-skill <<<"

shell_name="$(basename "${SHELL:-}")"
case "$shell_name" in
  zsh) rc_file="$HOME/.zshrc" ;;
  bash) rc_file="$HOME/.bashrc" ;;
  *) rc_file="$HOME/.profile" ;;
esac

printf "YouTrack base URL (example: https://youtrack.example.com): "
read -r base_url

if [[ -z "$base_url" || ! "$base_url" =~ ^https?:// ]]; then
  echo "Invalid URL. Expected http:// or https:// prefix." >&2
  exit 1
fi

printf "YouTrack permanent token (input hidden): "
read -r -s token
echo

if [[ -z "$token" ]]; then
  echo "Token is empty." >&2
  exit 1
fi

tmp_file="$(mktemp)"
if [[ -f "$rc_file" ]]; then
  awk -v start="$marker_start" -v end="$marker_end" '
    $0 == start {skip=1; next}
    $0 == end {skip=0; next}
    !skip {print}
  ' "$rc_file" > "$tmp_file"
else
  : > "$tmp_file"
fi

{
  echo
  echo "$marker_start"
  printf 'export YOUTRACK_BASE_URL="%s"\n' "$base_url"
  printf 'export YOUTRACK_TOKEN="%s"\n' "$token"
  echo "$marker_end"
} >> "$tmp_file"

mv "$tmp_file" "$rc_file"

cat <<MSG
Saved YouTrack environment variables to: $rc_file
Run:
  source "$rc_file"
Then restart your coding agent session if needed.
MSG
