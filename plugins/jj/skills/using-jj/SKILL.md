---
name: using-jj
description: Use when a .jj directory is present at the repo root, or the user asks to commit, branch, push, undo, or otherwise version-control changes with jj/Jujutsu instead of git
---

# Using jj (Jujutsu)

## Overview

jj is a Git-compatible VCS: no staging area, no detached-HEAD state — the
working copy is always itself a real, commit-able change (`@`). Every
mutation is recorded in an operation log and undoable with `jj undo`.
This repo is colocated (`.jj` + `.git`): read-only git commands
(`log`/`status`) still work, but mutations go through `jj`, not `git
add`/`git commit`.

The biggest git-habit trap: bookmarks (jj's branches) don't auto-follow
`@` the way git branches follow HEAD — you move them explicitly with
`jj bookmark advance`. See `reference.md` for the full git→jj command
mapping.

## Typical Solo Workflow

1. Edit files directly — no `add` needed, `@` picks up all changes.
2. `jj describe -m "message"` to label the current change (or `jj
   commit -m "message"` to label it and open a new empty change on top
   in one step).
3. `jj bookmark advance` to move the closest bookmark (e.g. `main`)
   forward to `@` — finds it automatically. Some projects move `main`
   by hand instead; check the project's own instructions (e.g.
   `CLAUDE.md`) before assuming this step is wanted.
4. `jj git push`. A "non-tracking remote bookmark" warning means run
   `jj bookmark track <name>@<remote>` once, then push again.
5. `jj new` to start the next unit of work — don't skip this.

There's no staging area, so edit freely — you're always on `@`. But
edits keep joining the same change silently until you `jj new`, so the
real discipline is temporal: checkpoint (`jj describe` + `jj new`)
after each logically-complete step rather than batching a whole task
into one change — it gives the user a reviewable record and you an
undo point if something goes wrong.

## Reference

See `reference.md` for: the full git→jj command mapping, the quick
command reference, revset syntax, connecting a fresh repo to a remote,
mapping superpowers:finishing-a-development-branch onto jj, editing a
prior commit, resolving conflicts, undo/recovery, and common mistakes.
