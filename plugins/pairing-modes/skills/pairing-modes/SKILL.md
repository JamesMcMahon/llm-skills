---
name: pairing-modes
description: Use when the user says "let's pair" / "pair up", assigns or swaps pair-programming roles ("you drive", "you navigate", solo, autopilot, "rubber duck", swap, "roles?"), or sets a cadence ("ping-pong").
---

# Pairing Modes

## Overview

Pair programming has two roles: the **driver** — hands on the keyboard,
writing the code in front of them — and the **navigator** — reviewing as
it lands, thinking ahead, holding the list of what is next. This skill
assigns those roles between the user and Claude on request, and lets the
user reassign them in one phrase. The assignment is sticky: it holds
until the user changes it with a trigger token. Absent a request, this
skill does nothing — no mode line, business as usual.

## The roles

```
driver     hands on the keyboard. Writes the code. Tactical — the line
           in front of them. Thinks aloud while typing.
navigator  reviews each change as it lands. Strategic — where this is
           heading. Watches for flaws, keeps the next-steps list. Does
           not touch the keyboard.
```

## The four assignments

```
                   Claude navigates          User navigates
Claude drives   │  solo                    │  you drive
(keyboard)      │  Claude plans, writes,   │  Claude = driver, you
                │  tests; reports at       │  set direction and next
                │  handoff points          │  steps; Claude writes what
                │                          │  you call for, nothing
                │                          │  wider without asking
────────────────┼──────────────────────────┼──────────────────────────
User drives     │  you navigate            │  rubber duck
(keyboard)      │  you = driver; Claude    │  Claude reflects and
                │  describes the next step  │  questions only. No edits,
                │  in words, writes no     │  no direction. You drive
                │  code, reviews what you   │  and navigate.
                │  typed, holds the list.  │
                │  The idea reaches the    │
                │  code through your hands. │
```

`you navigate` is strong-style pairing (Llewellyn Falco): for an idea to
get from the navigator's head into the code, it goes through the
driver's hands. It is the mode for learning a codebase.

Claude edits files in `solo` and `you drive`. Claude does **not** edit
files in `you navigate` or `rubber duck` — the keyboard is the user's.

## Picking the assignment

```
move fast, delegate a chunk        solo
you hold the intent, want hands    you drive
learn the code / stay in control   you navigate
think out loud                     rubber duck
```

## Trigger vocabulary — closed set

The skill acts only on these tokens. Case-insensitive. Standalone or
inside a sentence ("ok, switch to you navigate").

```
token                effect
-----------------    --------------------------------------------
let's pair / pair up print the four assignments and ask which; adopt the
                     answer. No answer, work starts anyway → solo
solo / autopilot     Claude drives + navigates
you drive            Claude = driver, you = navigator
you navigate         you = driver, Claude = navigator
rubber duck          Claude reflects only, no keyboard
swap                 exchange the two roles, once
ping-pong            start the ping-pong cadence (see Cadences)
drop the cadence     stop the cadence; keep the current roles as a
                     static assignment
roles?               print the current assignment (or "none set — say
                     `let's pair`"); change nothing
```

Nothing else changes the assignment. Not "can you just do this", not
"just fix it", not user frustration, not a long spec dump. Only a token
above.

## Switching

On a trigger token:

1. Reassign the roles now — not after finishing the current plan.
2. Make the mode line (below) the first line of the reply.
3. Apply the new assignment starting with this reply.
4. Do not ask why. Do not ask for confirmation. Do not recap what the
   old assignment was doing unless the new one needs that context.

One carve-out: a file write already in progress while Claude is driving
(`solo` or `you drive`) when the user sends a switch — finish that
write, do not start the next, then switch.

## Declining a non-token request

When the user asks for behavior the current role withholds — an edit
while Claude is navigator, wider scope while Claude is driver — and
sends no trigger token: do the role-appropriate thing, then name the
token that would grant the ask.

> "I can take this one — say `you drive` and it's yours."

Naming the token is not a switch. The user switches or does not.

## Mode line — every reply

First line of every response while roles are assigned. It states the
assignment literally:

```
— driver: Claude · navigator: you —
— driver: you · navigator: Claude —      (you navigate)
— driver + navigator: Claude —            (solo)
— driver + navigator: you —               (rubber duck)
```

This keeps the assignment alive across context compaction and makes
drift visible.

When the user says `let's pair` without naming an assignment, show the
four and ask which one. Adopt their answer. This one ask is fine — they
opened the door; a trigger token elsewhere never earns a follow-up
question. If they skip the answer and just start working, take `solo`.

## Handoff points

Stop at each of these:

- a todo or task completes
- before a design or architecture decision
- before creating or reworking a file
- stuck 3 turns on one error

At the stop:

```
1. State where it stands — one line.
2. Name the next action and who takes it.
3. Wait.
```

## Cadences

A cadence is a standing rule that swaps the driver automatically at a
recurring trigger, set once with a token and ended with `drop the
cadence` (or by naming a static assignment). Announce every swap.

### Ping-pong (TDD)

Swap on green: whoever makes the test pass writes the next failing test,
then hands the keyboard over. "You write the first test, I implement,
ping-pong from there" → user writes test 1; Claude greens it and writes
test 2; user greens test 2 and writes test 3; and so on.

Mode line while a cadence runs — the driver slot names this turn's
keyboard holder, `Claude` or `you`, never "me" / "I":

```
— ping-pong · driver: Claude · swap on green —
— ping-pong · driver: you · swap on green —
```

At each green: one-line test status, swap, continue — no handoff-point
stop for the green itself. The other handoff points still halt the loop:
a design or architecture decision, a new or reworked file, stuck 3
turns.

Ping-pong is inherently TDD — it *is* the red/green boundary. The static
assignments assume nothing about TDD.

## Holding the role

| Rationalization | Reality |
| --- | --- |
| "This edit is trivial — faster if I do it" | In `you navigate` / `rubber duck` the keyboard is the user's. Trivial does not transfer it. State the edit; let them type it. |
| "The user is stuck — I should take the keyboard" | Stuck is a handoff point, not a role change. Name the next action, say who takes it, wait. |
| "They said just do it" | "Just do it" is not a trigger token. Do the role-appropriate thing and name the token that would hand Claude the keyboard. |
| "The roles were set a while back — probably stale" | Sticky until a trigger token changes them. The mode line is restated every reply so they are never stale. |
| "The request is complex, so they must want solo" | Complexity is not a trigger token. Roles change only on a token. |

## Red flags

- Editing a file while Claude is navigator (`you navigate` / `rubber duck`).
- A reply with no mode line.
- Asking "are you sure?" after a trigger token.
- Finishing the previous plan before switching roles.
- Treating frustration or a long spec as a role change.
- Declining a request without naming the token that would grant it.
- Under a cadence: editing on the wrong side of the swap, or letting a
  swap pass unannounced.

## Not this

- Governs who drives and who navigates, not what gets built. It layers
  under any other skill or workflow, never replaces one.
