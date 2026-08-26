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
| `jj bookmark set <name> -r @` | Point bookmark `<name>` at `@` (creates it if it doesn't exist yet) |
| `jj bookmark advance` | Move the closest bookmark behind `@` (e.g. `main`) forward to `@` — no name needed |
| `jj bookmark track <name>@<remote>` | Link a local bookmark to a remote one so push/fetch will manage it |
| `jj git remote add <name> <url>` | Register a remote (`jj git remote list` / `set-url` to inspect / fix it) |
| `jj git push` / `jj git fetch` | Push tracked bookmarks / fetch from remote |
| `jj edit <rev>` | Move `@` onto an existing commit to edit it in place |
| `jj squash --into <rev>` | Fold the current change's contents into `<rev>` |
| `jj absorb` | Auto-distribute uncommitted `@` changes into ancestors |
| `jj next` / `jj prev` | Move `@` to the child / parent revision |
| `jj undo` / `jj op log` | Undo the last operation / view operation history |
| `jj abandon [--retain-bookmarks]` | Discard a change, rebasing descendants onto its parent — **deletes** any bookmark pointing at it unless `--retain-bookmarks` is given |
| `jj new -B <rev>` | Insert a new empty change immediately *before* `<rev>`, auto-rebasing it and its descendants forward |
| `jj resolve` | Launch a merge tool on the conflicted paths of `@` — see Resolving Conflicts below |
| `jj bookmark set <name> -r <rev> --allow-backwards` | Move a bookmark to an earlier revision (refused without the flag) |
| `jj new <rev1> <rev2> ...` | Create a merge commit with multiple parents (`jj merge` is deprecated) |

## Revsets

`-r <rev>` throughout this reference accepts more than a commit id:

| Revset | Meaning |
|---|---|
| `@` / `@-` / `@+` | Current change / its parent / its child |
| `x::y` | Commits between `x` and `y`, inclusive |
| `::x` / `x::` | Ancestors of `x` / descendants of `x` |
| `trunk()` | The main branch's tip on the remote |
| `mine()` | Commits authored by you |
| `heads(all())` | Every branch tip, named or not |

## Typical Solo Workflow

1. Edit files directly — no `add` needed, `@` picks up all changes.
2. `jj describe -m "message"` to label the current change (or `jj commit -m "message"` to label it and open a new empty change on top in one step).
3. `jj bookmark advance` to move the closest bookmark (e.g. `main`) forward to the change you just finished — finds it automatically, no need to name it (equivalent to `jj bookmark set main -r @`, but works generically).
4. `jj git push`. If it warns about a "non-tracking remote bookmark," that bookmark exists on the remote but isn't linked yet — run `jj bookmark track <name>@<remote>` (e.g. `jj bookmark track main@origin`) once, then push again.
5. `jj new` to start the next unit of work. Don't skip this — see below.

There's no staging area, so edit freely before you're "done" — you're
always on `@`. The flip side: nothing stops edits from landing *after*
you're done, either. Once a change is described (or pushed), further
edits silently join that same change until you `jj new` — bookmarks
auto-follow in-place edits, so this won't even show up as a conflict,
just a "done" commit that quietly keeps growing (made exactly this
mistake mid-session). Since there's no manual staging step either way,
the real discipline in jj is temporal, not mechanical: `jj new` between
logical units of work is what gives you a clean `jj log`/`jj op log` —
it costs nothing, so checkpoint after each logically-complete step
rather than batching a whole task into one change. This applies doubly
to agents: `jj describe` + `jj new` as you finish each step gives the
user a real, reviewable record of what happened and when, and gives you
an undo point if a later step goes wrong.

## Connecting a Fresh Repo to a Remote

`jj git init` (with no clone) creates neither a remote nor a bookmark, so
the workflow above doesn't apply until both exist:

1. `jj git remote add origin <url>` — register the remote.
2. `jj bookmark set main -r @` — no bookmark exists yet, so `jj bookmark
   advance` has nothing to move.
3. `jj git push` will refuse: *"Refusing to create new remote bookmark
   main@origin"*. This isn't an error — run `jj bookmark track
   main@origin`, then push again. Same fix as the "non-tracking remote
   bookmark" warning in the normal workflow, just hit on the first push
   instead of after a fetch.

From here the normal `jj bookmark advance` + `jj git push` workflow
applies.

## Finishing a Branch (superpowers:finishing-a-development-branch) in jj

That skill's menu assumes git branches and a real `git merge` step — jj
has neither. There's no separate feature branch to merge back: work
happens directly on top of wherever `@` started, and a bookmark is just
a label on one commit in that graph.

- **"Merge back to `<base-branch>` locally"** → `jj bookmark advance`
  (or `jj bookmark set <base> -r <tip-of-work>`) — moves the base
  bookmark to the tip of the finished work. No checkout, no merge
  commit: you were never on a separate branch to merge.
- **"Push and create a Pull Request"** → same as the normal workflow:
  advance the bookmark, `jj git push`, open the PR.
- **Cleanup step (`git branch -d <feature-branch>`)** → nothing to do.
  Once the bookmark has advanced, the prior commits are just ancestors
  in `jj log` — there's no branch object left to delete.

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
- **Inserting before an existing commit:** `jj new -B <revision>` opens a
  new empty change immediately before `<revision>`, auto-rebasing it (and
  its descendants) onto the new change — use this instead of `edit`/
  `squash` when the commit needs to land *earlier* in history.

Nothing is immutable by default except the root commit, so this works on
already-pushed commits too — but it still rewrites history for anyone
who has them. `jj git push` never needs `--force`: it force-with-lease
checks automatically and asks for `jj git fetch` if the remote moved.

## Resolving Conflicts

Rebase, squash, and `jj new -B` never stop for a conflict — they record
it on the affected commit and keep going. `jj log`/`jj st` marks it
`conflict`, and the conflict propagates to descendants until fixed.

1. Move `@` onto the conflicted commit: `jj new <rev>` (scratch change,
   `jj squash --into <rev>` when done) or `jj edit <rev>` (in place —
   same tradeoff as above).
2. Run `jj resolve` (merge tool) or edit the conflicted file directly.
3. **jj's conflict markers are not git's:** `<<<<<<<`/`>>>>>>>` bound the
   conflict, `+++++++` marks a side's snapshot, `%%%%%%%` marks a diff
   against it. Expecting git's `<<<<`/`====`/`>>>>` format will misread
   the file.

## Undo / Recovery

Almost anything can be undone: `jj undo` steps back one operation, and
`jj op log` shows the full history with ids for `jj op restore <id>` to
jump to any earlier state. This covers accidental `abandon`, bad
`rebase`/`squash`, etc.

## Common Mistakes

- **Running `git add`/`git commit` directly.** Works (colocated), but
  bypasses jj's model — prefer `jj describe`/`jj commit`.
- **Expecting a bookmark to follow new commits.** Unlike a git branch, it
  stays put until you `jj bookmark advance` (or `set`/`move`) it. Symptom:
  `jj git push` prints `Warning: No bookmarks found in the default push
  revset...` then `Nothing changed.` — check `jj bookmark list`.
- **Running `jj new` before every edit.** Unnecessary — you're already
  editing `@`; `jj new` is only for starting a fresh change deliberately.
- **Looking for a `rebase --continue` step after `jj edit`/`jj squash`.**
  There isn't one — conflicts from auto-rebasing just land on the
  affected commits (visible in `jj log`), not blocking the command you
  ran. See Resolving Conflicts above.
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
