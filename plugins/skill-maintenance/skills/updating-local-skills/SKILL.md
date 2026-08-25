---
name: updating-local-skills
description: Use when the user gives an explicit correction about a locally-installed skill's guidance being wrong, incomplete, or missing something — and the current directory is not that skill's own source repo.
---

# Updating Local Skills

## Overview

Skills installed via symlink (`~/.claude/skills/<name>` → a repo you
own) can be fixed without leaving the current project. Locate the real
source, fix it there, commit — don't disrupt the task at hand.

## When to Use

- An explicit correction, not vague dissatisfaction — "the skill said X
  but it's actually Y," "it's missing Z."
- Current directory isn't that skill's own source repo.
- `~/.claude/skills/<name>` is a **symlink** — marketplace-copy installs
  can't be fixed this way (check with `readlink`, step 1).

## Steps

1. `readlink ~/.claude/skills/<name>` → the real source path. Not a
   symlink? Stop — tell the user this install is a marketplace copy,
   not something this skill can fix in place.
2. Dispatch a background subagent to that path:
   - Make the fix. Ground every claim in reality — run the actual
     command/tool, don't guess from memory.
   - Verify: dispatch a second, fresh subagent with no knowledge of
     the fix. Give it only the corrected skill plus the scenario that
     exposed the gap. Confirm it now retrieves the skill unprompted
     and produces the correct output — not just a confident one. If
     it doesn't, revise and re-verify before moving on.
   - Commit it there (describe + finalize per that repo's own VCS
     conventions) — **never push.**
   - Report back what changed, why, and what the verification showed.
3. Keep working on the original task while it runs — don't block on it.
4. When it reports back: tell the user the fix is committed, not live —
   it needs a Claude Code restart to take effect.

## Common Mistakes

- Editing the skill file inline and blocking the current task, instead
  of dispatching in the background.
- Treating casual complaints as a trigger — wait for an explicit
  correction.
- Forgetting the restart caveat — the user will otherwise expect the fix
  to be live in the current session.
