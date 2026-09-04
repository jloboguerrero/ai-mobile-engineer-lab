# Context engineering — spending tokens on purpose

Every token in the context window is paid for on every subsequent turn until it's
dropped. The goal isn't "use fewer tokens" in the abstract — it's making sure the
tokens spent are the ones that change the model's output, and nothing else.

## 1. CLAUDE.md as an index, not a manual

`flutter/CLAUDE.md` in this kit is ~130 lines. An earlier draft that inlined all six
rule files would run ~800 lines — and that whole file is re-sent on every single
request, whether the current task touches bloc code, DI, or neither. Instead:

- CLAUDE.md carries only what applies to *every* edit (10 always-on rules) plus a
  routing table: "working on X → read `.claude/rules/Y.md`".
- Each rule file (`architecture.md`, `bloc.md`, `di-modular.md`, `naming-and-style.md`,
  `error-handling.md`, `testing.md`) loads only when the task actually touches that
  area. A pure-UI change never pays for the DI or error-handling rules.

This is the same principle as lazy imports: pay for what you use, when you use it.

## 2. `permissions.deny` as a token filter, not just a security control

`.claude/settings.json` denies reads on `build/`, `.dart_tool/`, `*.g.dart`,
`*.mocks.dart`, `*.freezed.dart`, `build_config/`, `.env*`. These are read-denied for
two independent reasons that happen to point the same way:

- **Security**: `.env*`, keystores, and build secrets shouldn't enter the context at all.
- **Token cost**: generated files are often the largest files in the repo (mocks,
  freezed classes) and carry zero information the model needs — it should regenerate
  them with `build_runner`, never read and reproduce their contents.

## 3. Subagents as context isolation

An `Explore` or `flutter-architect` subagent call spends tokens *in its own context
window*. Only its final summary returns to the parent conversation. For "where is X
handled across 18 packages" — a question that could mean reading a dozen files — a
subagent absorbs that cost and hands back one paragraph instead of a dozen file dumps.

## 4. Grep before read, ranges before whole files

Codified in the `context-budget` skill. Concretely: don't `Read` an 800-line file to
find one constant — `Grep` for it, then read the 20 lines around the match. Don't
re-read a file that's already in context and hasn't changed.

## 5. `/ctx` — making the budget visible

The `/ctx` command reports what's actually loaded this session: which rule files were
read, which large files are stale and could be dropped, and whether `/compact` (trim
history, keep working set) or `/clear` (start over, keep only files on disk) is the
better move right now. Visibility is the first step — you can't manage a budget you
can't see.

## 6. When *not* to optimize

None of this should mean skipping verification to save tokens. Running `flutter
analyze` after a real batch of changes is worth the tokens; skipping it to save context
and shipping a broken build is not an optimization, it's a bug generator. The target is
removing waste (re-reads, generated files, irrelevant rules), not removing checks.
