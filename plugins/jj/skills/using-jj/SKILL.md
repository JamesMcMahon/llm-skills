---
name: using-jj
description: Use when a .jj directory is present at the repo root, or the user asks to commit, branch, push, undo, or otherwise version-control changes with jj/Jujutsu instead of git
---

# Using jj (Jujutsu)

## Overview

jj is a Git-compatible VCS: no staging area, no detached-HEAD state — the
working copy is always itself a real, commit-able change (`@`). Every
mutation is recorded in an operation log and undoable with `jj undo`.
This repo is colocated (`.jj` + `.git`), so `git log`/`git status` still
work read-only, but mutations should go through `jj`, not `git add`/`git
commit`.

## Mental Model vs Git

| Git concept | jj equivalent |
|---|---|
| staging area / `git add` | none — all tracked-directory changes are part of `@` automatically |
| `git commit` | `jj describe -m "msg"` (labels `@`) or `jj commit -m "msg"` (labels `@` **and** creates a new empty child to work in) |
| branch (auto-follows HEAD) | bookmark (does **not** auto-follow — move it explicitly) |
| `git checkout <branch>` | `jj new <revision>` |
| `git rebase -i` (edit an old commit) | `jj edit`/`jj new -r`+`jj squash` — see below, no todo list, no "continue" step |
| `git reset`/`git revert` (undo a mistake) | `jj undo` (undoes the last jj operation, repeatable) |
| `git log` | `jj log` |
| `git push`/`git fetch` | `jj git push`/`jj git fetch` |

## Quick Reference

| Command | Purpose |
|---|---|
| `jj st` / `jj log` / `jj diff` | Status / change graph / diff of `@` |
| `jj describe -m "msg"` | Label `@` without moving to a new change |
| `jj commit -m "msg"` | Label `@`, then start a fresh empty change on top |
| `jj new [-r <rev>]` | Start a new empty change (on `@`, or on `<rev>`) |
| `jj bookmark set <name> -r @` | Point bookmark `<name>` at `@` |
| `jj bookmark advance` | Move the closest bookmark behind `@` (e.g. `main`) forward to `@` — no name needed |
| `jj bookmark track <name>@<remote>` | Link a local bookmark to an existing remote one so push/fetch will manage it |
| `jj git push` / `jj git fetch` | Push tracked bookmarks / fetch from remote |
| `jj edit <rev>` | Move `@` onto an existing commit to edit it in place |
| `jj squash --into <rev>` | Fold the current change's contents into `<rev>` |
| `jj absorb` | Auto-distribute uncommitted `@` changes into ancestors |
| `jj next` / `jj prev` | Move `@` to the child / parent revision |
| `jj undo` / `jj op log` | Undo the last operation / view operation history |
| `jj abandon [--retain-bookmarks]` | Discard a change, rebasing descendants onto its parent — **deletes** any bookmark pointing at it unless `--retain-bookmarks` is given |

## Typical Solo Workflow

1. Edit files directly — no `add` needed, `@` picks up all changes.
2. `jj describe -m "message"` to label the current change (or `jj commit -m "message"` to label it and open a new empty change on top in one step).
3. `jj bookmark advance` to move the closest bookmark (e.g. `main`) forward to the change you just finished — finds it automatically, no need to name it (equivalent to `jj bookmark set main -r @`, but works generically).
4. `jj git push`. If it warns about a "non-tracking remote bookmark," that bookmark exists on the remote but isn't linked yet — run `jj bookmark track <name>@<remote>` (e.g. `jj bookmark track main@origin`) once, then push again.

To keep working on top without committing yet, just keep editing — there's
no need to run `jj new` first; you're always editing `@`.

## Editing a Prior Commit

No todo list, no "continue" step — descendants rebase immediately and
automatically whenever an ancestor changes.

- **In place:** `jj edit <revision>`, edit files, then `jj edit
  <original-revision>` (or `jj next`) to return. Simple, but moves `@`
  out from under whatever you were doing.
- **Recommended:** `jj new -r <revision>` (scratch change off it, `@`
  stays put) → edit → `jj squash --into <revision>` (folds back in,
  scratch commit auto-abandons once empty). Used this to fix the owner
  name in an earlier commit in this repo.
- **Fixups already in `@`:** `jj absorb` auto-detects which ancestor each
  uncommitted hunk belongs to and folds it in — no fixup markers needed.

Nothing is immutable by default except the root commit, so this works on
already-pushed commits too — but it still rewrites history for anyone
who has them. `jj git push` never needs `--force`: it force-with-lease
checks automatically and asks for `jj git fetch` if the remote moved.

## Undo / Recovery

Almost anything can be undone: `jj undo` steps back one operation, and
`jj op log` shows the full history with ids for `jj op restore <id>` to
jump to any earlier state. This covers accidental `abandon`, bad
`rebase`/`squash`, etc.

## Common Mistakes

- **Running `git add`/`git commit` directly.** Works (colocated), but
  bypasses jj's model — prefer `jj describe`/`jj commit`.
- **Expecting a bookmark to follow new commits.** Unlike a git branch, it
  stays put until you `jj bookmark advance` (or `set`/`move`) it — check
  `jj bookmark list` if `jj git push` claims there's nothing to push.
- **Running `jj new` before every edit.** Unnecessary — you're already
  editing `@`; `jj new` is only for starting a fresh change deliberately.
- **Looking for a `rebase --continue` step after `jj edit`/`jj squash`.**
  There isn't one — conflicts from auto-rebasing just land on the
  affected commits (visible in `jj log`) to resolve whenever, not
  blocking the command you ran.
- **Running `jj undo` and then redoing similar work.** `jj undo` doesn't
  erase the undone operation, it just restores an earlier view — so a
  later rewrite of the same change can end up unrelated to the first one
  in jj's eyes, and the change shows as **divergent** (`jj log` marks it,
  and its bookmark ends up conflicted, e.g. `main??`, blocking push).
  Fix: `jj bookmark set <name> -r <the-revision-you-actually-want>` to
  resolve the bookmark, then `jj abandon` the stale duplicate revision.
- **Assuming `jj abandon` moves a bookmark to the parent.** It doesn't —
  by default it *deletes* any bookmark pointing at the abandoned commit
  entirely. If you want it preserved (moved to the parent instead), pass
  `--retain-bookmarks`.
- **Trusting `git status`/`git log` for truth here.** Git's HEAD stays
  detached and its index goes stale — it can show "changes not staged"
  right after a clean `jj describe`. Refs like `refs/heads/main` are
  correct; verify with `jj log`/`jj status`, not `git status`.
