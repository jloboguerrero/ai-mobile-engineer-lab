# Harness engineering — the model is constant, the harness is the variable

The model itself doesn't change between projects. What changes is everything around
it: what it's allowed to run without asking, what gets checked automatically after
every edit, what context gets injected before it even starts working, what specialized
sub-processes exist for narrow tasks. That surrounding system is the harness, and it's
the actual lever available to an engineer working with AI day to day.

## Pieces of the harness in this kit

### `.claude/settings.json` — permissions as an autonomy dial

`permissions.allow` lists exactly the read-only and verification commands that don't
need a human in the loop: `flutter analyze`, `flutter test`, `dart format`, `git
status/diff/log/branch`. Nothing destructive, nothing that mutates git history, nothing
that touches the network. This is the alternative to `--dangerously-skip-permissions`:
instead of turning off the safety net, you shape exactly which actions don't need it.

`permissions.deny` blocks reads of generated/secret paths — see
`01-context-engineering.md` for why that's also a token-budget move.

### Hooks — four events, four different jobs

- **PreToolUse** (`guard_paths.sh`) — runs *before* an edit is allowed. Used for hard
  constraints: never hand-edit generated files, never add a dependency to the wrong
  `pubspec.yaml`. Exit code 2 blocks the tool call outright.
- **PostToolUse** (`format_and_analyze.sh`, `check_file_size.sh`) — runs *after* an
  edit lands. Used for immediate feedback loops: format on save, analyze on save, warn
  or block on file size. The model sees the failure and fixes it in the same turn,
  without a human pointing it out.
- **SessionStart** (`session_context.sh`) — runs once, at the start. Used to inject
  cheap, high-value context (branch, git status, whether `specs/` exists) instead of
  having the model spend tool calls rediscovering it.
- (Not used in this kit, but worth knowing) **Stop** — runs when the model is about to
  finish; a project could use it to refuse to end the turn while `flutter analyze` is
  dirty, forcing a clean stopping point.

The thesis: **style rules that live only in prose get forgotten under a full context
window. Style rules enforced by a hook do not get forgotten — the hook runs regardless
of what's in context.**

### Skills — packaged procedures, not repeated prose

`.claude/skills/*/SKILL.md` encode multi-step procedures (scaffold a feature, add a
bloc, audit a diff, work under a token budget) once, with `allowed-tools` scoping what
each one can touch. Instead of re-explaining "how we scaffold a feature" in every
prompt, it's invoked by name and loaded only when relevant.

### Subagents — specialized, isolated workers

`.claude/agents/*.md` define narrow, read-only roles (`flutter-architect`,
`flutter-reviewer`) plus one that writes tests. Each has its own `tools:` allowlist —
the architect and reviewer can't `Write`, by design, so a planning or review pass can
never accidentally become an edit.

### Commands — the interface surface

`.claude/commands/*.md` are the day-to-day verbs: `/feature`, `/audit`, `/ship`, `/ctx`.
Each has `allowed-tools` scoped to what that command actually needs, and each states
explicitly what it does *not* do (`/ship` never runs `git commit`).

## Why this matters for the interview

Anyone can paste "follow clean architecture" into a system prompt. The harness is what
makes that instruction survive contact with a long session, a full context window, and
an unattended run — because at that point it's not a suggestion the model might recall,
it's a script that runs regardless.
