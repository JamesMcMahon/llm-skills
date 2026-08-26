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
    `jj describe` + `jj new`; only `jj bookmark advance` if the repo's
    own instructions call for it — some, like this one, move `main` by
    hand instead; never `jj git push`) and report what changed and what
    verification showed. Same caching caveat as 2a applies here too.

## Fix Discipline (both paths)

**REQUIRED BACKGROUND:** superpowers:writing-skills — its RED-GREEN-
REFACTOR cycle, "Match the Form to the Failure," and token-efficiency
targets all apply directly to a fix, not just to authoring a new skill.
This section covers only what differs when the "test" is one gap in an
already-deployed skill rather than a skill written from scratch.

- Classify the gap: **retrieval** (fix → frontmatter `description`) or
  **application** (fix → body). Fixing the wrong half leaves the real
  gap open.
- Check the target repo's working copy is clean before touching
  anything (`git status`, or the jj equivalent — check for a `.jj`
  directory rather than assuming git) — stash/back up or stop and ask
  if it's dirty; it may hold the owner's in-progress work.
- **RED:** confirm the gap is real — run the scenario that exposed it
  (genericized if dispatching, 2a) against the *current, unfixed* skill
  with a fresh subagent. No repro means the scenario lost the trigger —
  fix that before touching the skill.
- **Make the fix.** Ground every claim in reality — run the actual
  command/tool or check the actual upstream source, don't guess from
  memory.
- **GREEN, then verify:** dispatch a second, fresh, context-free
  subagent — same scenario, no knowledge a fix was made. Confirm it now
  retrieves the skill unprompted (retrieval gaps) or produces the
  correct output (application gaps), not just a confident one.
  Cross-check anything it cites against a primary source yourself;
  agents can cite the wrong thing with equal confidence. Doesn't pass →
  **REFACTOR**: revise and re-verify.
  **Exception — retrieval/description fixes:** unverifiable this way.
  The discovery listing is a process-wide cache, not read live from
  disk — a subagent dispatched right after the fix still sees the old
  description and reproduces the baseline failure regardless of whether
  the fix is correct. Verify these by inspection instead: confirm the
  new wording covers the scenario, tell the user a restart is needed
  before it's behaviorally checkable, and re-run the baseline scenario
  after they restart as the real verify pass.

## Common Mistakes

- Skipping the verify step because you're already in the skill's source
  repo and the fix "obviously" looks right — an in-place edit needs the
  same fresh-subagent check as a dispatched one.
- Treating a self-noticed gap as out of scope because no user filed an
  explicit correction — this skill covers self-driven fixes too, not
  just reported ones.
- Editing the skill file inline and blocking the current task when
  dispatching elsewhere (2a), instead of running it in the background.
- Passing the correction to a dispatched subagent verbatim, carrying
  this repo's proprietary names, code, or business logic into a fix
  committed to someone else's skill repo.
- Fixing the wrong half: adding body content for a retrieval gap, or
  rewording the description for an application gap.
- Landing a fix by addition alone — growing the file past its
  word-count budget instead of trimming elsewhere to offset it.
- Editing straight into a dirty target repo without checking its
  working-copy status first — or assuming it's git when it's jj.
- Accepting a verify subagent's cited fact (a config key, a flag name, a
  version-specific behavior) without checking it against the primary
  source yourself — two independent subagents can produce two different
  confident answers.
- Treating a verify subagent's failed retrieval as proof a description
  fix didn't work — the cache means it won't clear until an actual
  restart (see the Verify exception above).
