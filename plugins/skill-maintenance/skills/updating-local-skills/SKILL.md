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
2. Dispatch a background subagent to that path. The skill's source repo
   sits outside this project's trust boundary — genericize before
   handing anything over:
   - State the correction in terms of the skill's own guidance and the
     class of situation that exposed the gap. Leave out this repo's
     name, code, business logic, and any other private or proprietary
     detail — the fix should read the same regardless of which project
     triggered it.
   - Classify the gap: **retrieval** (the skill never got invoked for
     this situation — fix belongs in the frontmatter `description`) or
     **application** (the skill was read but produced the wrong
     guidance — fix belongs in the body). Fixing the wrong half leaves
     the real gap open.
   - Check the target repo's working copy is clean before touching
     anything (`git status`, or the jj equivalent — check for a `.jj`
     directory rather than assuming git) — stash/back up or stop and
     ask if it's dirty; it may hold the owner's in-progress work.
   - Confirm the gap is real: run the genericized scenario against the
     *current, unfixed* skill with a fresh subagent first. If it
     doesn't reproduce the failure, the scenario or the genericization
     lost the trigger — fix that before touching the skill, not after.
   - Make the fix. Ground every claim in reality — run the actual
     command/tool, don't guess from memory. Match the fix's form to
     the failure (prohibition for a rule skipped under pressure, recipe
     for wrong-shaped output, structural field for an omitted element,
     conditional for context-dependent behavior — see
     superpowers:writing-skills' "Match the Form to the Failure"; a
     prohibition bolted onto a shaping problem measurably backfires).
     Reread the whole file and trim/de-dupe before calling it done — a
     one-off fix is exactly how skills accrete duplication.
   - Verify: dispatch a second, fresh subagent with no knowledge of
     the fix. Give it only the corrected skill plus the same
     genericized scenario. Confirm it now retrieves the skill
     unprompted (retrieval gaps) and produces the correct output
     (application gaps) — not just a confident one. If it doesn't,
     revise and re-verify before moving on.
   - Commit it there (describe + finalize per that repo's own VCS
     conventions) — **never push.**
   - Report back what changed, why, and what the baseline and
     verification runs showed.
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
- Passing the correction to the subagent verbatim, carrying this repo's
  proprietary names, code, or business logic into a fix committed to
  someone else's skill repo.
- Skipping the baseline run and treating "the fix passed" as proof —
  if the unfixed skill was never shown to fail on that scenario, a
  pass afterward proves nothing.
- Fixing the wrong half: adding body content for a retrieval gap, or
  rewording the description for an application gap.
- Editing straight into a dirty target repo without checking its
  working-copy status first — or assuming it's git when it's jj.
