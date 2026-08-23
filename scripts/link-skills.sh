#!/usr/bin/env bash
# Symlink every plugin in plugins/ into ~/.claude/skills/ so edits here
# are live immediately (restart still required to pick up changes), with
# no marketplace/install copy to go stale. See README "Local development".
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_dir="$HOME/.claude/skills"
mkdir -p "$skills_dir"

for plugin_dir in "$repo_root"/plugins/*/; do
  plugin_json="${plugin_dir}.claude-plugin/plugin.json"
  [ -f "$plugin_json" ] || continue
  [ "$(basename "$plugin_dir")" = "example-skill" ] && continue  # template, not a real skill

  name="$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['name'])" "$plugin_json")"
  source="${plugin_dir%/}"
  target="$skills_dir/$name"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    echo "ok:     $name already linked"
  elif [ -e "$target" ]; then
    echo "skip:   $name — $target exists and isn't linked here (remove it, or"
    echo "        'claude plugin uninstall $name@llm-skills' if it's a marketplace install)"
  else
    ln -s "$source" "$target"
    echo "linked: $name -> $source"
  fi
done

echo
echo "Restart Claude Code for changes to take effect."
