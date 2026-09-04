---
description: Report the current context budget - what's loaded, what's large, what can be dropped
allowed-tools: Read, Glob, Bash(wc:*), Bash(du:*)
---

Report a short context-budget summary for this session:

1. Which rule files under `.claude/rules/` have actually been read this session vs.
   which are still unloaded (the point of the index in `CLAUDE.md` — most should be
   unloaded until needed).
2. Any large files read this session (>200 lines) that are no longer needed — name them
   and suggest they be treated as summarized/closed rather than re-read.
3. One line on whether `/compact` or `/clear` would help right now, and why.

Keep the report under 15 lines — it's a budget check, not an essay.
