<div align="center">

<img src="https://img.shields.io/badge/rune-AI%20Workspace-6C63FF?style=for-the-badge&logoColor=white" alt="rune" />

<br/><br/>

[![GitHub stars](https://img.shields.io/github/stars/bhargava562/rune?style=flat-square&logo=github&color=6C63FF)](https://github.com/bhargava562/rune/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/bhargava562/rune?style=flat-square&logo=github&color=6C63FF)](https://github.com/bhargava562/rune/network/members)
[![License: MIT](https://img.shields.io/github/license/bhargava562/rune?style=flat-square&color=green)](LICENSE)
[![Made with Bash](https://img.shields.io/badge/Made%20with-Bash-1f425f?style=flat-square&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen?style=flat-square)](https://github.com/bhargava562/rune/pulls)

<br/>

**The missing setup layer for AI coding tools.**

*One command. Every tool configured. From one source of truth.*

</div>

---

## The problem

Six AI coding tools. Six config file formats. Zero shared memory.

| Tool | Needs this file |
|---|---|
| Claude Code | `CLAUDE.md` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Cursor | `.cursor/rules/*.mdc` + `.cursorrules` |
| Google Antigravity CLI | `GEMINI.md` + `.agents/rules/*.md` |
| Kiro | `.kiro/steering/*.md` |
| OpenCode | `~/.config/opencode/AGENTS.md` |

Without these files every tool starts blank every session — no coding style, no project conventions, no memory of your stack. Setting them up manually takes hours. They drift apart the moment anything changes. Most developers never configure them at all.

---

## What rune does

Rune writes all of them from a single source of truth.

```
$ rune setup

  ██████╗ ██╗   ██╗███╗   ██╗███████╗
  ...

  Platform: macOS
  
  Available tools:
    • claude  • copilot  • cursor
    • antigravity  • kiro  • opencode

  Type tools space-separated (or 'all'):
  → claude copilot cursor

  Fetching templates...  ✓
  Bootstrapping workspace...  ✓
  
  Setting up claude...   ✓ CLAUDE.md written
  Setting up copilot...  ✓ .github/copilot-instructions.md written
  Setting up cursor...   ✓ .cursor/rules/base.mdc written
                         ✓ .cursorrules written

  ✅ rune is ready
```

Every config file gets the same professional engineering persona — senior engineer communication style, behaviour rules, tool-specific instructions — merged and written automatically.

---

## Quick start

**Run once in any project (no install required):**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/bhargava562/rune/main/scripts/setup.sh) setup
```

**Or install globally and use anywhere:**

```bash
curl -fsSL https://raw.githubusercontent.com/bhargava562/rune/main/install.sh | bash
```

Then in any project:

```bash
rune setup
```

---

## What gets created

```
your-project/
├── .rune/
│   ├── core/                  ← base rules (generated, gitignored)
│   ├── skills/                ← framework rules you install
│   └── memory/
│       └── project-context.md ← shared brain state across tools
├── CLAUDE.md                  ← Claude Code config
├── GEMINI.md                  ← Antigravity CLI config
├── .cursorrules               ← Cursor config
├── .cursor/rules/base.mdc     ← Cursor scoped rules
├── .github/
│   └── copilot-instructions.md
├── .agents/rules/rune.md      ← Antigravity workspace rules
└── .kiro/steering/rune.md     ← Kiro steering file
```

Generated files are gitignored. Every developer on your team runs `rune setup` and gets their own local configs from the same source.

---

## Installing framework skills

```bash
rune install react
```

Downloads vetted rules from a verified registry into `.rune/skills/react.md`. Every AI tool in your project immediately picks up the new rules through the shared `.rune/` brain.

Available skills: `react` — more coming. Submit a PR to add yours.

---

## Extending without forking

Drop a `.md` file into `.rune/skills/` and re-run `rune setup`:

```
.rune/skills/python.md
```

```markdown
Always use async functions.
Use snake_case. Never use print() — use logging.
```

Your rules merge on top of the base. Core files stay untouched. Works per-project, per-team, per-stack.

---

## What's inside the default config

Every tool gets the same three layers merged together:

**Behaviour rules** — plan before coding, explain before acting, never delete code without confirmation, verify files before assuming anything.

**Communication style** — direct, no filler phrases, production quality bar, recommendations not options.

**Tool-specific instructions** — each tool gets rules tuned to how it actually works. Claude Code gets slash command guidance. Cursor gets scoped rule advice. Kiro gets steering file conventions.

---

## Requirements

| Platform | What you need |
|---|---|
| Linux | `bash`, `curl` — pre-installed |
| macOS | `bash`, `curl` — pre-installed |
| Windows | [Git for Windows](https://gitforwindows.org) — includes Git Bash |

Optional: `python3 ≥ 3.10` for graphify integration. `node ≥ 18` for caveman token optimizer. Both are prompted during setup — never installed without consent.

---

## Adding a new tool

1. Create `templates/adapters/newtool.md` with tool-specific instructions
2. Add a `case` block in `scripts/setup.sh` pointing to the correct config path
3. Submit a PR

No other files change.

---

## Contributing

Open an issue before starting work on large changes.

```bash
git checkout -b feat/new-adapter
# add templates/adapters/newtool.md
# add case block in scripts/setup.sh
# open PR
```

---

## License

MIT — [Bhargava A](https://bhargavaa.vercel.app)

[![LinkedIn](https://img.shields.io/badge/LinkedIn-bhargavaa1-0A66C2?style=flat-square&logo=linkedin&logoColor=white)](https://linkedin.com/in/bhargavaa1)
[![GitHub](https://img.shields.io/badge/GitHub-bhargava562-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/bhargava562)
