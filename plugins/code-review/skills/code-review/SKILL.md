---
name: code-review
description: Use when reviewing a code change, commit, pull request, or diff, especially when the reviewer asks for a guided walkthrough or wants to understand how the parts fit together.
---

# Code Review Walkthrough

## Purpose

Help the reviewer understand how a change works, why its parts fit together, and what deserves attention. This is a guided tour, not a defect hunt or a request to fix the code.

## Prepare the tour

1. Inspect the complete diff and relevant surrounding code. Establish the change's purpose from its context, not only its commit message.
2. Group changed code into logical units of behavior or responsibility. A unit may span files; do not default to one room per file.
3. Build the route from logical units changed by the diff. Default to outside-in: start at the outermost relevant boundary (such as a user-facing entry point, API, CLI, or event handler) and follow the flow inward toward core behavior. Use unchanged code at the boundary as labeled context; do not imply it changed. If another order explains the change better, use it and briefly say why in the Route.
4. Get accurate file and line references from the reviewed revision. Use paths and line ranges the reviewer can open. If line numbers are unavailable, say so rather than guessing.

## Open the tour

For the first response, use this order:

1. `## Why` — state why the change exists and the architectural or behavioral shift.
2. `## Route` — preview the logical stops and key changed files. Keep this brief.
3. `## Room 1 — <unit> (<filename(s)>)` — include the actual filename(s) in the heading, then list the room's highlighted files as bullets with exact paths and line ranges. Explain why this unit changed, what it does, and how it fits.
4. End with one brief question or pause that lets the reviewer steer.

This is a response shape, not a full-tour report. Explain only the first room; continue one room at a time in later turns.

## Walk one room at a time

For each logical unit:

- Name the room with its concept and actual filename(s), then begin with a short bullet list of its highlighted files, each with an exact path and line range. Include only the files needed to follow this room.
- Explain why this room changed, what the code does, how it works, and how it connects to the overall change.
- Include a relevant concern as a short aside where it belongs; distinguish an established behavior from a question or risk.
- Pause at a meaningful boundary for the reviewer's questions or direction. Answer in context, then continue when they are ready.

Do not deliver the entire tour in one response. Expect the reviewer to follow along in the code. For small changes, the route may have one room; do not invent structure just to create more stops.

## Keep the scope

Explain concerns that affect understanding or review, but do not turn the tour into a list of findings. Do not implement fixes. If the reviewer asks to switch into defect-finding or fixing, clarify that this is a different review mode and follow their direction.
