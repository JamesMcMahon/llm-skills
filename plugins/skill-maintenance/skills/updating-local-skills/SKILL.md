---
name: updating-local-skills
description: Use when fixing or improving a locally-installed skill's guidance — from an explicit user correction, or a gap you notice yourself (reading upstream docs, hitting an edge case, code review) while working in that skill's own source repo. Covers locating a symlinked source when needed, and verifying the fix either way.
---

# Updating Local Skills

## Overview

A skill installed via symlink (`~/.claude/skills/<name>` → a repo you
own) can be fixed without leaving the current project — locate the real
source, fix it there. When the current directory already *is* that
source repo (e.g. you're improving one of this repo's own skills while
working in this repo), skip locating and edit in place instead of
dispatching to yourself. **Either way, the fix isn't done until a
fresh, context-free subagent has verified it** — that's the part most
likely to get skipped when you're already sitting in the source repo
and the fix feels obviously right.

## When to Use

- An explicit correction ("the skill said X but it's actually Y," "it's
  missing Z"), **or** a gap you notice yourself while authoring,
  reviewing, or cross-checking a skill against its own source repo —
  not just user-reported issues.
- `~/.claude/skills/<name>` is a **symlink** — marketplace-copy installs
  can't be fixed this way (check with `readlink`, step 1).

## Steps

1. `readlink ~/.claude/skills/<name>` → the real source path.
   - **Not a symlink at all:** stop — tell the user this install is a
     marketplace copy, not something this skill can fix in place.
   - **Resolves outside the current repo:** go to 2a.
   - **Resolves inside the current repo** (you're already in the
     skill's own source, as with this repo's own skills): go to 2b.

2a. **Dispatch to a different repo.** It sits outside this project's
    trust boundary — genericize before handing anything over. Dispatch
    a background subagent:
    - State the correction in terms of the skill's own guidance and the
      class of situation that exposed the gap. Leave out this repo's
      name, code, business logic, and any other private or proprietary
      detail — the fix should read the same regardless of which project
      triggered it.
    - Follow the Fix Discipline below.
    - Commit it there (describe + finalize per that repo's own VCS
      conventions) — **never push.**
    - Report back what changed, why, and what the baseline and
      verification runs showed.

    Keep working on the original task while it runs — don't block on
    it. When it reports back: tell the user the fix is committed. Body
    content is live immediately — anyone reading the file after the
    commit gets the new text. A description/trigger change is not: the
    discovery listing is cached **process-wide, not per-session** — even
    a subagent dispatched fresh after the commit still sees the old
    description until Claude Code actually restarts. Say that
    explicitly; don't imply the fix is fully live.

2b. **Edit in place.** No genericization needed — this repo already
    owns the source. Follow the Fix Discipline below directly, then
    commit locally per this repo's own VCS conventions (jj here —
    `jj describe` + `jj bookmark advance` + `jj new`, never `jj git
    push`) and report what changed and what verification showed. Same
    caching caveat as 2a applies here too.

## Fix Discipline (both paths)

- Classify the gap: **retrieval** (the skill never got invoked for this
  situation — fix belongs in the frontmatter `description`) or
  **application** (the skill was read but produced the wrong guidance —
  fix belongs in the body). Fixing the wrong half leaves the real gap
  open.
- Check the target repo's working copy is clean before touching
  anything (`git status`, or the jj equivalent — check for a `.jj`
  directory rather than assuming git) — stash/back up or stop and ask
  if it's dirty; it may hold the owner's in-progress work.
- Confirm the gap is real: run the scenario that exposed it — genericized
  if dispatching (2a) — against the *current, unfixed* skill with a
  fresh subagent first. If it doesn't reproduce the failure, the
  scenario (or its genericization) lost the trigger — fix that before
  touching the skill, not after.
- Make the fix. Ground every claim in reality — run the actual
  command/tool or check the actual upstream source, don't guess from
  memory. Match the fix's form to the failure (prohibition for a rule
  skipped under pressure, recipe for wrong-shaped output, structural
  field for an omitted element, conditional for context-dependent
  behavior — see superpowers:writing-skills' "Match the Form to the
  Failure"; a prohibition bolted onto a shaping problem measurably
  backfires). Reread the whole file and trim/de-dupe before calling it
  done — a one-off fix is exactly how skills accrete duplication.
- **Verify: dispatch a second, fresh, context-free subagent** with no
  knowledge of the fix. Give it only a realistic scenario that exercises
  the change (the same one from the baseline check) — not the fact that
  a fix was just made. Confirm it now retrieves the skill unprompted
  (retrieval gaps) and produces the correct output (application gaps) —
  not just a confident one. Cross-check anything the verify subagent
  cites against a primary source yourself before trusting it; agents
  disagree with each other and can cite the wrong thing with equal
  confidence. If it doesn't pass, revise and re-verify before moving on.
  **Exception — retrieval/description fixes:** a subagent can't verify
  these. The discovery listing agents use to decide "should I use this
  skill" is a process-wide cache, not read live from disk (confirmed by
  directly asking a freshly dispatched subagent to quote the description
  it currently sees — it quoted the pre-edit text after the fix had
  already been committed). A subagent will reproduce the exact baseline
  failure even against a correct fix — that's a false negative, not
  evidence the fix is wrong. For a description fix: verify by inspection
  that the new wording actually covers the scenario, tell the user a
  restart is needed before it's behaviorally checkable, and if they
  restart, re-run the same baseline scenario afterward as the real
  verify pass.

## Common Mistakes

- Skipping the verify step because you're already in the skill's source
  repo and the fix "obviously" looks right — an in-place edit needs the
  same fresh-subagent check as a dispatched one; being in the trusted
  repo has no bearing on whether the *wording* actually lands.
- Treating a self-noticed gap as out of scope because no user filed an
  explicit correction — this skill covers self-driven fixes too, not
  just reported ones.
- Editing the skill file inline and blocking the current task when
  dispatching elsewhere (2a), instead of running it in the background.
- Passing the correction to a dispatched subagent verbatim, carrying
  this repo's proprietary names, code, or business logic into a fix
  committed to someone else's skill repo.
- Skipping the baseline run and treating "the fix passed" as proof — if
  the unfixed skill was never shown to fail on that scenario, a pass
  afterward proves nothing.
- Fixing the wrong half: adding body content for a retrieval gap, or
  rewording the description for an application gap.
- Editing straight into a dirty target repo without checking its
  working-copy status first — or assuming it's git when it's jj.
- Accepting a verify subagent's cited fact (a config key, a flag name, a
  version-specific behavior) without checking it against the primary
  source yourself — two independent subagents can produce two different
  confident answers.
- Treating a verify subagent's failure to retrieve the skill as proof a
  description fix didn't work. The discovery listing is a process-wide
  cache — a subagent dispatched right after a description edit still
  sees the old text and will fail identically to the baseline, even
  against a fully correct fix. Only an actual restart clears it.
