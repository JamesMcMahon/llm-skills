---
name: writing-commit-messages
description: Use when writing or reviewing a commit or change description, or about to run `git commit` / `jj describe` — including when asked to "commit", "make a commit", or "save changes". Covers subject-line phrasing, when a body is warranted, and what belongs in the message versus the diff or review thread.
---

# Writing Commit Messages

## Overview

A commit message is a durable artifact for future readers — a reviewer
today, whoever runs `blame`/`log` (or the jj equivalent) months from now.
It is not a caption for what you just typed. One commit is one logical
change; that's what lets the subject line stay short and the body skip
narration. If a diff bundles unrelated changes, split it before writing
the message, not after.

Focus on what changed and why. Give a future reader the motivation when
it adds useful context; a self-explanatory change may need no further why.
Write for someone who has the commit and repository, but not the feature
team's conversations. Give them the context needed to understand the
change, not a record of how the discussion unfolded.

## Subject line

- Imperative mood: "Fix crash on empty input", not "Fixed" or "Fixes". Test:
  it should complete *"If applied, this commit will \_\_\_."*
- Describes the effect, not the mechanism. For bug fixes, state the action
  and broken user-visible behavior. For other changes, name the resulting
  effect, not the implementation.
- Use words a reader outside the feature team can understand. Name the
  affected behavior rather than relying on internal shorthand.
- ~50 characters. Not a hard limit, but it forces you to find the concise
  version. Capitalize; no trailing period.
- Separate the subject and body with a blank line when there is a body.

## Body — only when it adds useful context

A good subject can be the whole message. Add a body when a future reader
needs more to understand a non-trivial change, technical detail, or why
it was necessary. Explain only the useful context, not every changed
file or step. A complex behavior can merit a short explanation even when
the details are visible in the diff.

Explain a rejected alternative when its tradeoff or failure gives future
readers a meaningful reason to understand the choice. State that reason
in the message; don't assume knowledge of an LLM or review discussion.

Wrap body text at ~72 columns — history viewers don't rewrap it for you.

If there's a tracked issue or a breaking change, say so in a trailing line
(`Fixes #123`, `BREAKING CHANGE: ...`) rather than folding it into prose —
tools and future readers scan for these at the end.

## Leave out

- Trivial details already clear from the subject or diff.
- Future work and deferred decisions — "left as a follow-up", "handled in
  a separate change". It belongs in an issue tracker or TODO file, not
  permanent history; this message says only what this change did.
- Ephemeral LLM or review discussion — that belongs in the thread, not
  permanent history.
- Links with a short shelf life (preview URLs, build artifacts).

