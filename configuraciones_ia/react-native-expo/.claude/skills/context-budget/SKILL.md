---
name: context-budget
description: A low-token protocol for exploring or modifying this codebase — grep before read, ranged reads, subagents for open-ended search, summarize and let go. Use when the user asks to work efficiently / save tokens, or before a large exploration in a big repo.
allowed-tools: Read, Grep, Glob, Bash(wc:*)
---

# context-budget

1. **Grep before read.** Search the symbol, then read only that region.
2. **Ranged reads** for files > ~200 lines.
3. **Subagents** (`Explore`) for "where/how is X done across the repo".
4. **Never read** `node_modules/`, `ios/`, `android/`, `.expo/`, `generated/` (denied anyway).
   For a library API, read its `.d.ts` via grep in `node_modules/<pkg>/**/*.d.ts` only if the
   user allows, otherwise ask or use docs.
5. **Don't re-read** unchanged files already in context.
6. **Summarize and let go** after big explorations.
7. **Cite the rule file** instead of re-deriving conventions from code.

Anti-patterns: reading a whole 600-line screen to change one prop; running `npm test` (full)
after each edit — run the feature folder; the lint hook already runs per write.
