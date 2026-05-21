# Extending rune

Drop any .md file into your project's `.rune/skills/` folder.

The AI tools load it through the `.rune/` workspace brain.

## Examples

`.rune/skills/python.md`:
Always use async functions.
Use snake_case. Never use print() — use logging.

Run `rune setup` again to regenerate tool configs with your extensions.