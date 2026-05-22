## Kiro specific
Use steering files for persistent architectural decisions — not session notes.
Hooks should trigger on: file save (lint/format), pre-commit (tests), and PR creation (review).
Always generate a spec before implementing a feature — Kiro's spec workflow prevents scope creep.

### Spec format
Every spec must include: problem statement, proposed solution, acceptance criteria.
Never start implementation until spec is reviewed and marked approved.