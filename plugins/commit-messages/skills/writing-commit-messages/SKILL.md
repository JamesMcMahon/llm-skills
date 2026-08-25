---
name: writing-commit-messages
description: Use when writing or reviewing a commit or change description in any VCS — covers subject line phrasing, when a body is warranted, and what belongs in it versus the diff or review thread.
---

# Writing Commit Messages

## Overview

A commit message is a durable artifact for future readers — a reviewer
today, whoever runs `blame`/`log` (or the jj equivalent) months from now.
It is not a caption for what you just typed. One commit is one logical
change; that's what lets the subject line stay short and the body skip
narration. If a diff bundles unrelated changes, split it before writing
the message, not after.

Two questions decide everything else: what changed (if not obvious from
the diff), and why.

## Subject line

- Imperative mood: "Fix crash on empty input", not "Fixed" or "Fixes". Test:
  it should complete *"If applied, this commit will \_\_\_."*
- Describes the effect, not the mechanism. "Prevent database corruption
  during simultaneous sign-ups" beats "Add a mutex to guard the database
  handle" — the diff already shows the mutex. "Fixed bug" and "Updated
  tests" describe neither and say nothing at all.
- ~50 characters. Not a hard limit, but it forces you to find the concise
  version. Capitalize; no trailing period.
- Blank line after it, always — even with no body, tools that split subject
  from body rely on that blank line.

## Body — only when there's a real why

Skip it for self-explanatory changes; a good subject line is a complete
commit message. Write a body when the diff can't say:

- **Why**: the motivation, constraint, or bug that made this change
  necessary.
- **Rejected alternatives**: what you tried first and why it didn't work,
  if relevant.
- **Impact**: what this means for callers/users, if not obvious.

Wrap body text at ~72 columns — history viewers don't rewrap it for you.

If there's a tracked issue or a breaking change, say so in a trailing line
(`Fixes #123`, `BREAKING CHANGE: ...`) rather than folding it into prose —
tools and future readers scan for these at the end.

## Leave out

- Anything already obvious from reading the diff.
- Ephemeral review discussion — that belongs in the PR/MR thread, not
  permanent history.
- Links with a short shelf life (preview URLs, build artifacts).

