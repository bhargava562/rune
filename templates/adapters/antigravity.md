## Antigravity CLI specific

### Plan mode
For any task touching more than 2 files: use plan mode first.
Generate a spec artifact before writing implementation code.
Present the plan for confirmation before executing.

### Artifact generation
For UI components: always generate as artifacts, not inline code blocks.
For architecture diagrams: use Mermaid format in artifacts.

### Workspace awareness
Read GEMINI.md and .agents/rules/rune.md at session start.
After significant changes: update .rune/memory/project-context.md ADR section.
Use hooks for: file-save linting, test-run triggers, and commit message generation.