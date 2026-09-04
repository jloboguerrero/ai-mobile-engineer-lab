---
name: context-budget
description: A low-token-consumption protocol for exploring or modifying this codebase — grep before read, ranged reads instead of whole files, subagents for open-ended search, discard-after-summarize. Use when the user explicitly asks to work efficiently / save tokens / be economical, or before a large exploration task in a big repo.
allowed-tools: Read, Grep, Glob, Bash(wc:*)
---

# context-budget

Applies to this session, not to the target code. It's a way of working, summarized so
it doesn't need to be re-explained every time.

## Rules

1. **Grep before read.** Never open a file "to see what's in it" — search for the
   symbol/string first, then read only the matching region.
2. **Ranged reads.** Use `Read` with `offset`/`limit` for files over ~200 lines when you
   only need one function or class — not the whole file.
3. **Subagents for open-ended search.** A question like "where is X handled" or "survey
   how Y is done across the repo" goes to a subagent (`Explore` type for pure search).
   Its tool output stays in its own context; only its summary comes back.
4. **One targeted look beats three guesses.** If unsure which of 2-3 files is relevant,
   `grep -l` across candidates first instead of reading each one fully.
5. **Don't re-read what's already in context.** If a file was read this session and
   hasn't changed, reuse what's known instead of reading it again "to be sure."
6. **Summarize and let go.** After a large exploration, keep the conclusion, not the
   raw transcript — that's what forking/subagents give you for free; for direct
   reading, write the takeaway down (in the response or a scratch note) rather than
   keeping ten files' full contents live in context for the rest of the session.
7. **Prefer the rule file over re-deriving the rule.** If `.claude/rules/*.md` already
   states the convention, cite it — don't re-scan the codebase to reverse-engineer a
   pattern that's already documented.

## Anti-patterns to avoid

- Reading an entire 800-line file to check one constant.
- Running the same `flutter analyze` after every single line change instead of after a
  batch of related edits (the `format_and_analyze.sh` hook already does this per-write —
  don't also run it manually in a loop).
- Spawning a subagent for a lookup that a single `grep` would answer.
