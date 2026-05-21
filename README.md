<div align="center">

<img src="https://img.shields.io/badge/rune-AI%20Workspace-6C63FF?style=for-the-badge&logoColor=white" alt="rune" />

<br/>
<br/>

[![GitHub stars](https://img.shields.io/github/stars/bhargava562/rune?style=flat-square&logo=github&color=6C63FF)](https://github.com/bhargava562/rune/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/bhargava562/rune?style=flat-square&logo=github&color=6C63FF)](https://github.com/bhargava562/rune/network/members)
[![GitHub PRs](https://img.shields.io/github/issues-pr/bhargava562/rune?style=flat-square&color=blue)](https://github.com/bhargava562/rune/pulls)
[![License: MIT](https://img.shields.io/github/license/bhargava562/rune?style=flat-square&color=green)](LICENSE)
[![Made with Bash](https://img.shields.io/badge/Made%20with-Bash-1f425f?style=flat-square&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)

<h3><b>The Universal Package Manager & Workspace Synchronizer for AI Coding Assistants</b></h3>

*One command gives every terminal, IDE, and containerized AI agent on your system a unified, professional engineering brain.*

</div>

---

## 📖 Overview

In modern development workflows, teams rarely use a single AI tool. You might use **Cursor** for inline code editing, **Claude Code** in the terminal for tasks, **GitHub Copilot** for quick completions, and **Google's Antigravity CLI** in an isolated background container runtime.

Each tool relies on its own configuration format (`CLAUDE.md`, `.cursorrules`, `.github/copilot-instructions.md`, etc.). Keeping these rules synchronized manually leads to context drift, conflicting agent instructions, and degraded performance.

**`rune` solves this by establishing a single source of truth at the filesystem layer.** It acts as a package manager and workspace synchronizer that:
1. Bootstraps a standardized `.rune/` directory structure.
2. Compiles modular, tool-specific configuration pointers linking your AI assistants back to your project context.
3. Automatically shares context state across different tools via a central memory synchronizer.

---

## 🛠️ Supported Integrations

`rune` dynamically generates optimized instructions tailored to the distinct inner workings of the following platforms:

* 🤖 **Claude Code** (`CLAUDE.md`)
* 💻 **GitHub Copilot** (`.github/copilot-instructions.md`)
* 🎨 **Cursor IDE** (`.cursorrules` & `.cursor/rules/base.mdc`)
* 🪐 **Google Antigravity CLI** (`GEMINI.md` & `.agents/rules/rune.md`)
* ⚡ **Kiro** (`.kiro/steering/rune.md`)
* 🌐 **OpenCode** (`~/.config/opencode/AGENTS.md`)

---

## 🚀 Quick Start

### Option A: Zero-Install Execution (Recommended)
Bootstrap any folder into an AI-optimized workspace instantly without installing `rune` globally:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/bhargava562/rune/main/scripts/setup.sh) setup
```

### Option B: Global CLI Installation
Install `rune` as a global command on your system for local access in any folder:

```bash
curl -fsSL https://raw.githubusercontent.com/bhargava562/rune/main/install.sh | bash
```

> [!TIP]
> After global installation, run `rune setup` to initialize a workspace, or `rune install <skill>` to download modular programming rules.

---

## 📂 Architecture

When you run `rune setup`, it builds the following architecture:

```text
your-project/
├── .rune/                         
│   ├── core/                      ← Shared Persona & AGENTS.md
│   ├── skills/                    ← Universal framework/language rules (pulled from registry)
│   └── memory/                    
│       └── project-context.md     ← The Shared Brain State
├── .agents/                       ← Generated rules directory
│   └── rules/
│       └── rune.md                ← Guided by Rune instructions (Antigravity CLI)
├── .cursor/                       ← Cursor configuration directory
│   └── rules/
│       └── base.mdc               ← Cursor instruction pointer
├── .github/
│   └── copilot-instructions.md    ← Copilot instructions pointer
├── CLAUDE.md                      ← Claude Code instructions pointer
├── GEMINI.md                      ← Antigravity CLI instructions pointer
└── .cursorrules                   ← Legacy Cursor rules pointer
```

---

## ⚙️ How It Works

### 🧠 The Core System & Persona
* `rune` compiles templates dynamically from GitHub, combining `AGENTS.md` (general engineering best practices) with `persona.md` (assertive, concise decision-making guidelines) and tool-specific adapters.
* Avoids generic filler phrases (e.g., "Certainly!", "Great question!") and configures AI tools to speak like a senior engineer during a pull request review.

### 🔄 Multi-Agent Sync Protocol
AI tools configured through `rune` are instructed to check and update `.rune/memory/project-context.md`:
* **Read Phase**: Before modifying files, agents inspect the context file to align on current state and recent commits.
* **Write Phase**: Upon completing major changes, agents update the **Architectural Decisions (ADR)** section to instantly notify other agents operating in the same workspace.

### 📦 Dynamic Skills Manager (`rune install`)
Install structured guidelines for specific languages or frameworks using `rune install <skill_name>` (e.g., `react`):
* Downloads modular, vetted skills into `.rune/skills/` from a dynamic, verified GitHub registry.
* Because the skills folder is tracked by Git, all tools in your workspace automatically index these guidelines without bloating individual configuration files.

---

## 🏎️ Optional Integrations

During setup, `rune` checks and offers integration with two optimizing tools:

1. **Graphify (Python 3.10+)**: If chosen, `rune` wires dependencies parsing rules into your base guidelines so AI agents know to execute the `graphify` command locally to evaluate deep repository structures.
2. **Caveman Token Optimizer (Node.js 18+)**: Optimizes prompt tokens by stripping redundant whitespace and filler sentences, compressing context size and accelerating agent processing speed.

---

## 🔔 Auto-Update System

`rune` includes a built-in, non-blocking update notification system:
* Checks the remote `VERSION` file every 24 hours (with a 3-second network timeout) to verify if a new release is available.
* Avoids network calls on every execution by caching timestamps locally in `~/.rune_last_update_check`, preventing command latency.
* Alerts you with a clean update instruction at the end of setup without interrupting the process.

---

## 📋 Requirements

| Platform | Shell | Requirements |
| :--- | :--- | :--- |
| **Linux** | Bash | `bash`, `curl` (pre-installed) |
| **macOS** | Bash / Zsh | `bash`, `curl` (pre-installed) |
| **Windows** | Git Bash | [Git for Windows](https://gitforwindows.org) |

---

## 🤝 Contributing

Contributions of new adapters or features are always welcome:

1. Fork the repository.
2. Create your branch: `git checkout -b feat/new-adapter`.
3. Add your tool template in `templates/adapters/`.
4. Add the appropriate `case` statement handling in `scripts/setup.sh`.
5. Open a Pull Request.

---

## 👨‍💻 About the Author

Built by **Bhargava A** — CS & Business Systems student, Python Backend Engineer, and Tech Member at GDG RMK.

* [![LinkedIn](https://img.shields.io/badge/LinkedIn-bhargavaa1-0A66C2?style=flat-square&logo=linkedin&logoColor=white)](https://linkedin.com/in/bhargavaa1) LinkedIn
* [![GitHub](https://img.shields.io/badge/GitHub-bhargava562-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/bhargava562) GitHub
* [![Portfolio](https://img.shields.io/badge/Portfolio-bhargavaa.vercel.app-000000?style=flat-square&logo=vercel&logoColor=white)](https://bhargavaa.vercel.app) Portfolio

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
