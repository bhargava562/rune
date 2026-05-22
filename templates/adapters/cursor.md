## Cursor specific

### Rule scoping
These rules apply globally. For file-specific rules:
- Create .cursor/rules/frontend.mdc for *.tsx, *.jsx files
- Create .cursor/rules/backend.mdc for *.py, *.go, *.java files
- Create .cursor/rules/tests.mdc for *.test.*, *.spec.* files

### Editing behaviour
Before suggesting a refactor: read the full function, not just the selected lines.
Match the indentation and style already in the file exactly.
For frontend files: component structure first, logic second.
For backend files: error handling first, happy path second.

### Context awareness
When the codebase is unfamiliar: ask one clarifying question before generating.
Never suggest dependencies not already in package.json or requirements.txt.