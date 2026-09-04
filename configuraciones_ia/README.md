# AI Engineering Kit — Flutter

A portable, copy-pasteable set of Claude Code configuration for Flutter projects
following feature-first Clean Architecture + `flutter_bloc` + `flutter_modular`. Built
by reverse-engineering the real conventions of a production monorepo
(`docflutter`), not invented from a style guide.

## What's here

```
configuraciones_ia/
├── flutter/                 ← the payload — copy this into a project
│   ├── CLAUDE.md            routing index (<200 lines), 10 always-on rules
│   ├── AGENTS.md            pointer for Codex/Gemini-style agents
│   ├── analysis_options.yaml
│   ├── .cursor/rules/       Cursor-format equivalent (portability demo)
│   └── .claude/
│       ├── settings.json    permissions allow/deny + wired hooks
│       ├── rules/           6 topic files, loaded on demand
│       ├── hooks/           4 executable bash scripts (real, not illustrative)
│       ├── skills/          4 skills (feature scaffold, bloc, audit, token budget)
│       ├── commands/        /feature /audit /ship /ctx
│       └── agents/          3 subagents (architect, reviewer, test writer)
├── docs/                    the "why" — 4 short essays
├── scripts/loop.sh          headless iteration loop for an approved spec
└── install.sh               copies flutter/ into a target project
```

## Install into a project

```bash
./install.sh /path/to/flutter/project
./install.sh /path/to/flutter/project --dry-run   # preview only
```

Never overwrites an existing `CLAUDE.md`/`analysis_options.yaml` — writes a `.new`
file next to it instead.

## Read this first

`docs/02-harness-engineering.md` — the core idea: the model is constant, the harness
(permissions, hooks, skills, subagents) is the variable you actually control. The other
three docs (`01`, `03`, `04`) go deeper on token budget, unattended work, and the
existing `/spec` + `/spec-impl` workflow this kit builds on top of.

`DEMO.md` (Spanish) is the interview walkthrough.

## Note on `/spec` and `/spec-impl`

Those two are not part of this kit — they're separately-installed skills already in
use. See `docs/04-spec-driven-workflow.md` for how this kit integrates with them
without modifying them.
