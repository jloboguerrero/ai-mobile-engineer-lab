# AI Engineering Kit — Flutter & React Native (Expo)

A portable, copy-pasteable set of Claude Code configuration, one payload per stack.

- `flutter/` — Flutter projects
  following feature-first Clean Architecture + `flutter_bloc` + `flutter_modular`, built by
  reverse-engineering a production monorepo (`docflutter`).
- `react-native-expo/` — Expo + Expo Router + TanStack Query + Zustand + RHF/Zod + Unistyles,
  feature-first "lite", built for the SimplifyHR Mobile app (Kraferd). Not a translation of the
  Flutter kit: see `docs/05-react-native-notes.md`.

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
├── react-native-expo/       ← RN payload: CLAUDE.md, eslint.config.js, .cursor/, .claude/
│   └── .claude/             13 rules · 5 hooks (incl. PII guard) · 5 skills · 5 commands · 3 agents
├── docs/                    the "why" — 5 short essays
├── scripts/loop.sh          headless iteration loop for an approved spec
└── install.sh               copies a stack payload into a target project
```

## Install into a project

```bash
./install.sh flutter /path/to/flutter/project
./install.sh react-native-expo /path/to/expo/project
./install.sh react-native-expo /path/to/expo/project --dry-run   # preview only
```

Never overwrites an existing `CLAUDE.md`/`analysis_options.yaml`/`eslint.config.js` — writes a `.new`
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
