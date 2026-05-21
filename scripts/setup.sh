#!/bin/bash

# ─── RUNTIME CHECK ────────────────────────────────────────────
if [ -z "$BASH_VERSION" ]; then
  echo "Error: rune requires bash."
  echo "Windows users: install Git for Windows → https://gitforwindows.org"
  exit 1
fi

# ─── CONFIGURATION ────────────────────────────────────────────
REPO_URL="https://raw.githubusercontent.com/bhargava562/rune/main"
TMP_DIR="/tmp/rune_templates_$$"

# ─── HELPER FUNCTIONS ─────────────────────────────────────────
install_skills() {
  local REGISTRY_URL="$REPO_URL/scripts/registry.txt"
  local TMP_REGISTRY="/tmp/rune_registry_$$"

  if [ $# -eq 0 ]; then
    echo "  ✗ Please specify at least one skill to install."
    return 1
  fi

  echo ""
  echo "  ── Installing skills ────────────────────────────────"
  
  # Fetch the remote registry.txt from GitHub to a temporary file
  curl -fsSL "$REGISTRY_URL" -o "$TMP_REGISTRY" 2>/dev/null
  if [ ! -s "$TMP_REGISTRY" ]; then
    echo "  ✗ Failed to download registry.txt from GitHub."
    return 1
  fi

  mkdir -p "$WORKSPACE/.rune/skills"

  for skill in "$@"; do
    local url
    # Use standard grep and awk loops to parse the requested arguments against the file
    url=$(grep "^${skill}[[:space:]]" "$TMP_REGISTRY" | awk '{print $2}')
    
    if [ -n "$url" ]; then
      curl -fsSL "$url" -o "$WORKSPACE/.rune/skills/${skill}.md"
      if [ -s "$WORKSPACE/.rune/skills/${skill}.md" ]; then
        echo "  ✓ ${skill} installed successfully"
      else
        echo "  ✗ Failed to download skill: ${skill}"
        rm -f "$WORKSPACE/.rune/skills/${skill}.md"
      fi
    else
      echo "  ✗ unknown skill: ${skill}"
    fi
  done
  
  rm -f "$TMP_REGISTRY"
}

# ─── ARGUMENT ROUTING ─────────────────────────────────────────
WORKSPACE="$PWD"

if [ "$1" = "install" ]; then
  shift
  # Trim \r from input arguments if any
  clean_args=()
  for arg in "$@"; do
    clean_args+=("$(echo "$arg" | tr -d '\r')")
  done
  install_skills "${clean_args[@]}"
  exit 0
elif [ "$1" != "setup" ]; then
  echo "Usage:"
  echo "  rune setup                - Initialize a new AI workspace"
  echo "  rune install <skills...>  - Install skills from the registry"
  exit 0
fi

# ─── DISPLAY ──────────────────────────────────────────────────
echo ""
echo "  ██████╗ ██╗   ██╗███╗   ██╗███████╗"
echo "  ██╔══██╗██║   ██║████╗  ██║██╔════╝"
echo "  ██████╔╝██║   ██║██╔██╗ ██║█████╗  "
echo "  ██╔══██╗██║   ██║██║╚██╗██║██╔══╝  "
echo "  ██║  ██║╚██████╔╝██║ ╚████║███████╗"
echo "  ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝"
echo ""
echo "  AI workspace setup"
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
read -r -p "  Enter project directory name (leave blank for current directory): " PROJECT_NAME
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr -d '\r')
if [ -n "$PROJECT_NAME" ]; then
  mkdir -p "$PROJECT_NAME"
  cd "$PROJECT_NAME" || exit 1
fi
WORKSPACE="$PWD"
RUNE_DIR="$WORKSPACE/.rune"
CORE="$RUNE_DIR/core"
SKILLS="$RUNE_DIR/skills"

# ─── PLATFORM DETECTION ───────────────────────────────────────
case "$OSTYPE" in
  msys*|cygwin*|mingw*)
    PLATFORM="windows"
    echo "  Platform: Windows"
    ;;
  darwin*)
    PLATFORM="mac"
    echo "  Platform: macOS"
    ;;
  *)
    PLATFORM="linux"
    echo "  Platform: Linux"
    ;;
esac

# ─── HELPER: YES/NO PROMPT ────────────────────────────────────
ask_consent() {
  local question=$1
  while true; do
    read -r -p "  $question (y/n): " yn
    yn=$(echo "$yn" | tr -d '\r')
    case "$yn" in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "  Please enter y or n." ;;
    esac
  done
}

# ─── STEP 1: TOOL SELECTION ───────────────────────────────────
AVAILABLE_TOOLS="claude copilot cursor antigravity kiro opencode"

echo ""
echo "  ── Tool selection ───────────────────────────────────"
echo ""
echo "  Available tools:"
for tool in $AVAILABLE_TOOLS; do
  echo "    • $tool"
done
echo ""
echo "  Type tools space-separated (or 'all'):"
echo "  Example: claude copilot cursor"
echo ""
read -r -p "  → " INPUT
INPUT=$(echo "$INPUT" | tr -d '\r')

if [ "$INPUT" = "all" ]; then
  SELECTED="$AVAILABLE_TOOLS"
else
  SELECTED=$(echo "$INPUT" | tr ' ' '\n')
fi

echo ""
echo "  ── Skill selection ──────────────────────────────────"
echo ""
echo "  Type skills to install now (e.g. react springboot) or leave blank:"
read -r -p "  → " SKILLS_INPUT
SKILLS_INPUT=$(echo "$SKILLS_INPUT" | tr -d '\r')

# ─── STEP 2: FETCH TEMPLATES ──────────────────────────────────
echo ""
echo "  ── Fetching templates ───────────────────────────────"

# Fetch Core templates
echo "  Downloading core templates..."
mkdir -p "$TMP_DIR"
curl -sS "$REPO_URL/templates/AGENTS.md" -o "$TMP_DIR/AGENTS.md"
curl -sS "$REPO_URL/templates/persona.md" -o "$TMP_DIR/persona.md"

if [ ! -s "$TMP_DIR/AGENTS.md" ] || [ ! -s "$TMP_DIR/persona.md" ]; then
  echo "  ✗ Failed to download core templates from GitHub."
  echo "    Please check your connection or REPO_URL."
  rm -rf "$TMP_DIR"
  exit 1
fi

echo "  ✓ Templates downloaded"

# ─── STEP 3: GENERATE CORE ────────────────────────────────────
echo ""
echo "  ── Bootstrapping workspace in $WORKSPACE ────────────────"

mkdir -p "$WORKSPACE/.rune/core"
mkdir -p "$WORKSPACE/.rune/skills"
mkdir -p "$WORKSPACE/.rune/memory"

cp "$TMP_DIR/AGENTS.md"  "$CORE/AGENTS.md"
cp "$TMP_DIR/persona.md" "$CORE/persona.md"
echo "  ✓ .rune/core/AGENTS.md generated"
echo "  ✓ .rune/core/persona.md generated"

AGENTS_CONTENT=$(cat "$CORE/AGENTS.md")
PERSONA_CONTENT=$(cat "$CORE/persona.md")
# shellcheck disable=SC2034
POINTER_TEXT="$AGENTS_CONTENT

$PERSONA_CONTENT

## Workspace Context
Read .rune/memory/project-context.md before writing code.
Update the ADR section after architectural decisions."

if [ ! -f "$SKILLS/README.md" ]; then
  echo "Drop your custom .md files here to add team rules." > "$SKILLS/README.md"
  echo "  ✓ .rune/skills/README.md generated"
fi

if [ ! -f "$WORKSPACE/.rune/memory/project-context.md" ]; then
  cat > "$WORKSPACE/.rune/memory/project-context.md" << 'EOF'
# Project Overview

# Current State & Recent Commits

# Cross-Agent Architectural Decisions (ADR)
EOF
  echo "  ✓ .rune/memory/project-context.md generated"
fi

# Manage .gitignore
GITIGNORE="$WORKSPACE/.gitignore"
if ! grep -q "# rune - AI Workspace Configurations" "$GITIGNORE" 2>/dev/null; then
  {
    echo ""
    echo "# rune - AI Workspace Configurations"
    echo ".rune/core/"
    echo "CLAUDE.md"
    echo "GEMINI.md"
    echo ".github/copilot-instructions.md"
    echo ".cursor/"
    echo ".cursorrules"
    echo ".kiro/"
    echo ".agents/"
  } >> "$GITIGNORE"
  echo "  ✓ .gitignore updated"
fi

# ─── STEP 4: CONFIGURE SELECTED TOOLS ─────────────────────────
echo ""
echo "  ── Configuring tools ────────────────────────────────"
echo ""

echo "$SELECTED" | while read -r tool; do
  tool=$(echo "$tool" | xargs)
  [ -z "$tool" ] && continue

  echo "  Setting up $tool..."

  case "$tool" in
    claude)
      curl -sS "$REPO_URL/templates/adapters/claude.md" -o "$TMP_DIR/adapter_claude.md" 2>/dev/null
      {
        cat "$CORE/AGENTS.md"
        echo ""
        cat "$CORE/persona.md"
        echo ""
        [ -s "$TMP_DIR/adapter_claude.md" ] && cat "$TMP_DIR/adapter_claude.md"
        echo ""
        echo "## Workspace Context"
        echo "Read .rune/memory/project-context.md before writing code."
        echo "Update the ADR section after architectural decisions."
      } > "$WORKSPACE/CLAUDE.md"
      echo "  ✓ CLAUDE.md written"
      ;;
    copilot)
      mkdir -p "$WORKSPACE/.github"
      curl -sS "$REPO_URL/templates/adapters/copilot.md" -o "$TMP_DIR/adapter_copilot.md" 2>/dev/null
      {
        cat "$CORE/AGENTS.md"
        echo ""
        cat "$CORE/persona.md"
        echo ""
        [ -s "$TMP_DIR/adapter_copilot.md" ] && cat "$TMP_DIR/adapter_copilot.md"
        echo ""
        echo "## Workspace Context"
        echo "Read .rune/memory/project-context.md before writing code."
        echo "Update the ADR section after architectural decisions."
      } > "$WORKSPACE/.github/copilot-instructions.md"
      echo "  ✓ .github/copilot-instructions.md written"
      ;;
    cursor)
      mkdir -p "$WORKSPACE/.cursor/rules"
      curl -sS "$REPO_URL/templates/adapters/cursor.md" -o "$TMP_DIR/adapter_cursor.md" 2>/dev/null
      {
        cat "$CORE/AGENTS.md"
        echo ""
        cat "$CORE/persona.md"
        echo ""
        [ -s "$TMP_DIR/adapter_cursor.md" ] && cat "$TMP_DIR/adapter_cursor.md"
        echo ""
        echo "## Workspace Context"
        echo "Read .rune/memory/project-context.md before writing code."
        echo "Update the ADR section after architectural decisions."
      } > "$TMP_DIR/merged_cursor.md"
      cat "$TMP_DIR/merged_cursor.md" > "$WORKSPACE/.cursor/rules/base.mdc"
      echo "  ✓ .cursor/rules/base.mdc written"
      cat "$TMP_DIR/merged_cursor.md" > "$WORKSPACE/.cursorrules"
      echo "  ✓ .cursorrules written"
      ;;
    antigravity)
      curl -sS "$REPO_URL/templates/adapters/antigravity.md" -o "$TMP_DIR/adapter_antigravity.md" 2>/dev/null
      {
        cat "$CORE/AGENTS.md"
        echo ""
        cat "$CORE/persona.md"
        echo ""
        [ -s "$TMP_DIR/adapter_antigravity.md" ] && cat "$TMP_DIR/adapter_antigravity.md"
        echo ""
        echo "## Workspace Context"
        echo "Read .rune/memory/project-context.md before writing code."
        echo "Update the ADR section after architectural decisions."
      } > "$TMP_DIR/merged_antigravity.md"
      cat "$TMP_DIR/merged_antigravity.md" > "$WORKSPACE/GEMINI.md"
      echo "  ✓ GEMINI.md written"
      mkdir -p "$WORKSPACE/.agents/rules"
      cat "$TMP_DIR/merged_antigravity.md" > "$WORKSPACE/.agents/rules/rune.md"
      echo "  ✓ .agents/rules/rune.md written"
      ;;
    kiro)
      mkdir -p "$WORKSPACE/.kiro/steering"
      curl -sS "$REPO_URL/templates/adapters/kiro.md" -o "$TMP_DIR/adapter_kiro.md" 2>/dev/null
      {
        printf -- "---\ninclusion: always\n---\n\n"
        cat "$CORE/AGENTS.md"
        echo ""
        cat "$CORE/persona.md"
        echo ""
        [ -s "$TMP_DIR/adapter_kiro.md" ] && cat "$TMP_DIR/adapter_kiro.md"
        echo ""
        echo "## Workspace Context"
        echo "Read .rune/memory/project-context.md before writing code."
        echo "Update the ADR section after architectural decisions."
      } > "$WORKSPACE/.kiro/steering/rune.md"
      echo "  ✓ .kiro/steering/rune.md written"
      ;;
    opencode)
      mkdir -p ~/.config/opencode
      curl -sS "$REPO_URL/templates/adapters/opencode.md" -o "$TMP_DIR/adapter_opencode.md" 2>/dev/null
      {
        cat "$CORE/AGENTS.md"
        echo ""
        cat "$CORE/persona.md"
        echo ""
        [ -s "$TMP_DIR/adapter_opencode.md" ] && cat "$TMP_DIR/adapter_opencode.md"
        echo ""
        echo "## Workspace Context"
        echo "Read .rune/memory/project-context.md before writing code."
        echo "Update the ADR section after architectural decisions."
      } > ~/.config/opencode/AGENTS.md
      echo "  ✓ ~/.config/opencode/AGENTS.md written"
      ;;
    *)
      echo "  ✗ $tool — no template found, skipping"
      ;;
  esac
done


# Install initial skills
if [ -n "$SKILLS_INPUT" ]; then
  # shellcheck disable=SC2086
  install_skills $SKILLS_INPUT
fi

# Clean up tmp
rm -rf "$TMP_DIR"

# ─── STEP 5: GRAPHIFY (OPTIONAL) ──────────────────────────────
echo ""
echo "  ── Optional: graphify ───────────────────────────────"
echo "  graphify wires rune into your AI tools automatically."
echo "  Without it, rune still works — config files are"
echo "  written manually by this script."
echo ""

if ask_consent "Install graphify? (recommended)"; then
  USE_G="y"
else
  USE_G="n"
fi

if [[ "$USE_G" =~ ^[Yy]$ ]]; then
  echo ""
  echo "  Checking Python (required for graphify)..."

  if ! command -v python3 &>/dev/null; then
    echo "  ✗ Python 3 not found."
    echo "    Install from https://python.org then re-run setup.sh"
    echo "    Skipping graphify."
  else
    PY_VERSION=$(python3 -c 'import sys; print(sys.version_info.minor)' 2>/dev/null)
    if [ -z "$PY_VERSION" ] || ! [[ "$PY_VERSION" =~ ^[0-9]+$ ]]; then
      echo "  ✗ Python 3 is not fully functional (it might be a Windows execution alias)."
      echo "    Install from https://python.org then re-run setup.sh"
      echo "    Skipping graphify."
    elif [ "$PY_VERSION" -lt 10 ]; then
      echo "  ✗ Python 3.10+ required. You have 3.$PY_VERSION"
      echo "    Upgrade from https://python.org then re-run setup.sh"
    else
      echo "  ✓ Python 3.$PY_VERSION found"
      pip install graphifyy --quiet \
        && echo "  ✓ graphify installed" \
        || echo "  ✗ graphify install failed — run: pip install graphifyy"
      echo "  ℹ Run 'graphify install' inside each project to activate."
      printf "\n### Core System Tool: Graphify\nThis system is configured with Graphify. If you need to evaluate file hierarchies or map cross-module structural dependencies, execute the shell command \`graphify\` locally.\n" >> "$WORKSPACE/.rune/core/AGENTS.md"
    fi
  fi
fi

# ─── STEP 6: CAVEMAN (OPTIONAL) ───────────────────────────────
echo ""
echo "  ── Optional: caveman ────────────────────────────────"
echo "  caveman cuts AI output tokens by 65-75%."
echo "  Saves cost + speeds up every response. MIT licensed."
echo "  github.com/JuliusBrussee/caveman"
echo ""

if ask_consent "Install caveman token optimizer?"; then
  USE_C="y"
else
  USE_C="n"
fi

if [[ "$USE_C" =~ ^[Yy]$ ]]; then
  echo ""
  echo "  Checking Node.js (required for caveman)..."

  if ! command -v node &>/dev/null; then
    echo "  ✗ Node.js not found."
    echo "    Install from https://nodejs.org then re-run setup.sh"
    echo "    Skipping caveman."
  else
    NODE_VERSION=$(node -e 'console.log(process.versions.node.split(".")[0])')
    if [ "$NODE_VERSION" -lt 18 ]; then
      echo "  ✗ Node 18+ required. You have Node $NODE_VERSION"
      echo "    Upgrade from https://nodejs.org then re-run setup.sh"
    else
      echo "  ✓ Node $NODE_VERSION found"
      if [[ "$PLATFORM" == "windows" ]]; then
        echo "  ℹ Run in PowerShell to install caveman:"
        echo "    irm https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.ps1 | iex"
      else
        curl -fsSL \
          https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh \
          | bash \
          && echo "  ✓ caveman installed"
      fi
    fi
  fi
fi

# ─── DONE ─────────────────────────────────────────────────────
echo ""
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ rune is ready in $WORKSPACE"
echo ""
echo "  To reconfigure:  rune setup"
echo "  To add skills:   rune install <skill>"
echo "  To sync agents:  tell them to update .rune/memory/project-context.md"
echo "  To extend:       drop a .md in .rune/skills/"
if [[ "$USE_C" =~ ^[Nn]$ ]]; then
  echo "  Token savings:   install caveman → github.com/JuliusBrussee/caveman"
fi
echo ""