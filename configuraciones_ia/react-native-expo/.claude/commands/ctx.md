---
description: Report the current context budget - what's loaded, what's large, what can be dropped
allowed-tools: Read, Glob, Bash(wc:*), Bash(du:*)
---

Short context-budget summary (≤15 lines):

1. Which `.claude/rules/*.md` were read this session vs still unloaded.
2. Large files (>200 lines) read and no longer needed — treat as summarized.
3. One line: would `/compact` or `/clear` help now, and why.
