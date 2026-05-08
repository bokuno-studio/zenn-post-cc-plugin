#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dest="${1:-${CLAUDE_LOCAL_MARKETPLACE_PLUGIN_DIR:-$HOME/.claude/local-marketplace/plugins/zenn-post}}"
dest_skill="$dest/skills/zenn-post/SKILL.md"
env_block_file=""

if ! command -v rsync >/dev/null 2>&1; then
  echo "error: rsync is required" >&2
  exit 1
fi

if command -v claude >/dev/null 2>&1; then
  claude plugin validate "$repo_root"
fi

if [ -e "$dest" ] && [ ! -d "$dest" ]; then
  echo "error: destination exists but is not a directory: $dest" >&2
  exit 1
fi

if [ "${PRESERVE_SKILL_ENV_BLOCK:-1}" != "0" ] && [ -f "$dest_skill" ]; then
  env_block_file="$(mktemp)"
  awk '
    /^## 環境情報$/ { capture = 1 }
    capture && /^## / && !/^## 環境情報$/ { exit }
    capture { print }
  ' "$dest_skill" > "$env_block_file"
fi

mkdir -p "$(dirname "$dest")"

rsync -a --delete \
  --exclude ".git/" \
  --exclude ".env" \
  --exclude ".DS_Store" \
  "$repo_root/" "$dest/"

if [ -n "$env_block_file" ]; then
  if [ -s "$env_block_file" ]; then
    tmp_skill="$(mktemp)"
    awk -v block_file="$env_block_file" '
      BEGIN {
        while ((getline line < block_file) > 0) {
          block = block line ORS
        }
        close(block_file)
      }
      /^## 環境情報$/ {
        printf "%s", block
        skip = 1
        next
      }
      skip && /^## / {
        skip = 0
      }
      !skip {
        print
      }
    ' "$dest_skill" > "$tmp_skill"
    mv "$tmp_skill" "$dest_skill"
  fi
  rm -f "$env_block_file"
fi

cat <<EOF
Synced zenn-post plugin to:
  $dest

Next:
  claude plugin update zenn-post@local
  Restart Claude Code to apply the refreshed cache.
EOF
