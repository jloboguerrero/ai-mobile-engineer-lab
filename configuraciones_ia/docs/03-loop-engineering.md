# Loop engineering — working unattended, safely

"Let the AI keep working while I'm not watching" is not one capability, it's a ladder.
Each rung trades more autonomy for more guardrails, and the right rung depends on how
reversible the action is and how good the automated check is.

## Rung 1 — hooks that self-correct within a single turn

`format_and_analyze.sh` and `check_file_size.sh` (PostToolUse) already do this: an edit
that violates formatting or introduces an analyzer error gets caught and reported back
in the same turn, before the model moves on. This is unattended in the smallest sense —
no human looked at that one file — but it's still inside one active session.

## Rung 2 — a Stop gate

Not implemented in this kit, but the natural next step: a `Stop` hook that refuses to
let the session end while `flutter analyze` is dirty. This raises the bar from "the
model can self-correct if it notices" to "the model cannot claim done while broken."

## Rung 3 — subagents running in the background

`flutter-test-writer`, `flutter-reviewer` and similar subagents can run detached from
the main conversation — dispatch the work, keep doing something else, get notified on
completion. This is autonomy over *where attention goes*, not over *how long the work
runs unsupervised* — each subagent still has a bounded, well-defined task and a narrow
tool allowlist.

## Rung 4 — a headless loop (`scripts/loop.sh`)

The real "leave it running" case: a spec exists, its acceptance criteria are checkable
by machine (`flutter analyze && flutter test`), and iteration continues until they pass
or a budget runs out.

```bash
scripts/loop.sh --spec specs/03-notifications --max-iter 5
```

What it does, each iteration:
1. Reads the spec's implementation plan and acceptance criteria.
2. Runs `claude -p` (headless, non-interactive) against the next unfinished step.
3. Runs `flutter analyze && flutter test` as the objective check.
4. Logs the iteration's diff and check output to `.loop/`.
5. Stops when criteria pass, or after `MAX_ITERATIONS`, whichever comes first.

## Guardrails that make Rung 4 safe to leave running

- **No `--dangerously-skip-permissions`.** The loop runs under the same
  `.claude/settings.json` allowlist as an interactive session — it can run `flutter
  analyze`/`test`/`format`, it cannot push, cannot touch secrets, cannot run arbitrary
  shell.
- **Never commits, never pushes.** The loop stops with a dirty working tree and a log;
  a human reviews the diff and commits. This mirrors the `/spec-impl` skill's own rule
  of never committing automatically.
- **Isolated worktree recommended.** Running the loop in a separate `git worktree`
  means a runaway iteration can be discarded by deleting the worktree, without ever
  touching the branch you're actually working from.
- **Explicit stop condition, not a token/time budget alone.** "Acceptance criteria pass"
  is a real stop condition; "ran for N minutes" is not — it just means you stopped
  looking, not that the work is done.
- **Bounded iteration count.** `--max-iter` caps runaway loops (an unfixable analyzer
  error, a flaky test) from burning the budget indefinitely.

## Where this connects to `/spec` + `/spec-impl`

The loop is designed to run *inside* the contract those skills already establish: a
spec's state must mean "Approved" before implementation starts, and `/spec-impl`
already refuses to touch a dirty working tree or invent scope. `scripts/loop.sh`
assumes that gate has already been crossed by a human — it automates the iteration
*after* approval, not the decision to approve. See `04-spec-driven-workflow.md`.
