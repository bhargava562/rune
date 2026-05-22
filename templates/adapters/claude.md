## Claude Code specific

### Session management
At the start of every session: read .rune/memory/project-context.md.
Use /commands for repeated workflows — never re-explain the same task twice.
Use subagents for parallel work — don't do sequentially what can be parallelised.

### File operations
Always use Read tool before Edit tool — never assume file content.
When creating files: check existence first with LS or Read.
Prefer editing existing files over creating new ones.

### Token efficiency
Be concise in explanations — one paragraph maximum unless asked for more.
When exploring: read file trees first, source files second, only when needed.
Batch related file reads into single operations where possible.

### Agentic behaviour
Before running any shell command: state what it does and why.
After completing a task: summarise what changed in 2-3 bullet points.
Update .rune/memory/project-context.md when architectural decisions are made.