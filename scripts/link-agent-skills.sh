#!/usr/bin/env bash
# Symlink every skill into the shared Agent Skills directory.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_dir="$HOME/.agents/skills"
mkdir -p "$skills_dir"

for skill_file in "$repo_root"/plugins/*/skills/*/SKILL.md; do
  [ -f "$skill_file" ] || continue

  source="$(dirname "$skill_file")"
  name="$(basename "$source")"
  target="$skills_dir/$name"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    echo "ok:     $name already linked"
  elif [ -e "$target" ]; then
    echo "skip:   $name — $target exists and isn't linked here (remove it to replace)"
  else
    ln -s "$source" "$target"
    echo "linked: $name -> $source"
  fi
done

echo
echo "Start a new session in your harness to discover new skills."
