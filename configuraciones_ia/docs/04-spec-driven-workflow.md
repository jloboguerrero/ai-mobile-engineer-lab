# Spec-driven workflow — how `/spec` and `/spec-impl` are used here

**Provenance note, upfront:** `/spec` and `/spec-impl` are not authored in this kit.
They're third-party Claude Code skills (from `Klerith/fernando-skills`), installed and
already in use. This document describes the workflow they establish and how the rest
of this kit (rules, hooks, `scripts/loop.sh`) integrates with it — it does not modify
or reproduce their source.

## The contract

1. **`/spec <description>`** asks clarifying questions in blocks, then writes
   `specs/NN-slug.md` — never code. The header carries a blockquote with
   `**Status:** Draft`, an optional `**Depends on:**` list, a date, and a one-sentence
   objective. It never advances past `Draft` on its own.
2. A human reviews the spec and manually changes its status to `Approved` (or the
   equivalent in another language — the skills recognize several).
3. **`/spec-impl <NN-slug>`** validates that the status actually means "Approved" — if
   not, it stops with an explicit message and refuses to proceed, offering no
   workaround. If approved, it creates/switches to branch `spec-NN-slug`, checks the
   working tree is clean first, and implements the plan one step at a time, pausing
   after each step for a diff review before continuing.
4. It never commits automatically — not per step, not at the end. The human commits.

## Why this is the strongest "control" argument in the kit

The Draft→Approved transition is a **gate only a human can cross** — the skill will not
infer approval from context, urgency, or a confident-sounding request. Combined with
"never commits automatically," it means the two irreversible actions in the whole
pipeline (approving scope, and writing to git history) are both deliberately kept out
of the model's hands.

## How this kit connects to it

- `.claude/rules/*.md` are what `/spec-impl` should be implementing *against* — the
  spec says *what*, the rules say *how* (which files, which patterns, which naming).
- `scripts/loop.sh` (see `03-loop-engineering.md`) automates the *iteration* within an
  already-approved spec's plan — it does not decide approval and does not commit,
  matching `/spec-impl`'s own constraints.
- The `flutter-feature` and `flutter-bloc` skills are what `/spec-impl` would reach for
  when a step in the plan is "scaffold feature X" or "add bloc Y" — concrete
  implementations of steps the spec only describes in prose.

## What this kit deliberately does not do

It does not fork, edit, or vendor the `spec`/`spec-impl` skill files themselves. They
are maintained upstream; treating them as a dependency to document and build on top of
— rather than code to own — keeps this kit from drifting out of sync with updates to
the original skills.
