# llm-skills

Personal Claude Code plugin marketplace — one plugin per skill under
`plugins/`. See root `README.md` for repo layout and how to add a skill.

## VCS

This repo uses jj (colocated with git) — see
`plugins/jj/skills/using-jj/SKILL.md` for the workflow. Commit and
describe changes locally as normal; **never run the push step** (`jj git
push`) — the user pushes, always, in any repo.

**Commit messages: Conventional Commits, terse (experiment, forward-only
— no rewriting past history).**

```
<type>(<scope>): <short summary>

<body only if there's a real "why" worth a sentence>
```

Types: `feat`, `fix`, `docs`, `chore`, `refactor`. Header is one line,
**50 characters or under**, one commit = one clear thing.

## Authoring/editing skills here

Governed by `superpowers:writing-skills`. On top of that, this repo's
practice:

- **Ground every claim in reality, not memory.** For fast-moving CLIs
  (jj, `claude plugin`, etc.), verify against `--help`/`help` output or
  by actually running the command — don't rely on recalled syntax.
- **Verify with a fresh, context-free subagent before calling an edit
  done.** Retrieval: does it find the skill unprompted? Application:
  does it produce the *correct* command, not just a confident one? Gaps
  it hits are real gaps, not hypothetical ones.
- **Trim after adding.** Skills accrete duplication fast across
  sections when hardened incrementally — reread the whole file and
  de-dupe before considering a change finished, don't just append.
