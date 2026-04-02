#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_root="$repo_root/plugins/kesekit-ko/skills"
codex_root="$HOME/.codex/skills"
claude_cache_base="$HOME/.claude/plugins/cache/kesekit/kesekit-ko"

skills=(
  "start:kesekit-start"
  "check:kesekit-check"
  "fix:kesekit-fix"
  "guide:kesekit-guide"
)

if [[ ! -d "$source_root" ]]; then
  echo "Missing source skills directory: $source_root" >&2
  exit 1
fi

mkdir -p "$codex_root"

for pair in "${skills[@]}"; do
  src_name="${pair%%:*}"
  dst_name="${pair##*:}"
  mkdir -p "$codex_root/$dst_name"
  rsync -a --delete --exclude '.DS_Store' "$source_root/$src_name/" "$codex_root/$dst_name/"
done

if [[ -d "$claude_cache_base" ]]; then
  latest_claude_cache="$(find "$claude_cache_base" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)"

  if [[ -n "${latest_claude_cache:-}" ]]; then
    mkdir -p "$latest_claude_cache/skills" "$latest_claude_cache/skills-legacy"

    for pair in "${skills[@]}"; do
      src_name="${pair%%:*}"
      dst_name="${pair##*:}"

      if [[ -d "$latest_claude_cache/skills/$src_name" ]]; then
        mv "$latest_claude_cache/skills/$src_name" "$latest_claude_cache/skills-legacy/$src_name"
      fi

      mkdir -p "$latest_claude_cache/skills/$dst_name"
      rsync -a --delete --exclude '.DS_Store' "$source_root/$src_name/" "$latest_claude_cache/skills/$dst_name/"
    done
  fi
fi

echo "Installed Codex skills into: $codex_root"
if [[ -n "${latest_claude_cache:-}" ]]; then
  echo "Installed Claude plugin skills into: $latest_claude_cache/skills"
else
  echo "Claude kesekit plugin cache not found; skipped Claude install"
fi
