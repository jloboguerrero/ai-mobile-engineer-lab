---
description: Pre-PR check — format, analyze, test, and a proposed commit message. Does not commit.
allowed-tools: Read, Glob, Grep, Bash(dart format:*), Bash(flutter analyze:*), Bash(flutter test:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*)
---

Prepare this change for review, without committing anything:

1. `dart format .` on changed files.
2. `flutter analyze` — must be clean. If not, fix the issues (respecting
   `.claude/rules/*.md`) and re-run until clean, or report exactly what's blocking.
3. `flutter test` — run the full suite. Report pass/fail; do not silently skip failures.
4. Summarize the diff: files touched, and a one-paragraph description of the change.
5. Propose a commit message (imperative mood, one line summary + body if needed) but
   **do not run `git commit`** — the user commits themselves, or asks explicitly.
