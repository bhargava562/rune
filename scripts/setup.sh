#!/bin/bash

# ─── CONFIGURATION ────────────────────────────────────────────
REPO_URL="https://raw.githubusercontent.com/bhargava562/rune/main"
TMP_DIR="/tmp/rune_templates_$$"

# ─── HELPER FUNCTIONS ─────────────────────────────────────────
install_skills() {
  local REGISTRY_URL="$REPO_URL/scripts/registry.txt"
  local TMP_REGISTRY="/tmp/rune_registry.txt"

  if [ $# -eq 0 ]; then
    echo "  ✗ Please specify at least one skill to install."
    return 1
  fi

  echo ""
  echo "  ── Installing skills ────────────────────────────────"
  
  # Silently download registry.txt
  curl -sS "$REGISTRY_URL" -o "$TMP_REGISTRY"
  if [ ! -s "$TMP_REGISTRY" ]; then
    echo "  ✗ Failed to download registry.txt from GitHub."
    return 1
  fi

  mkdir -p "$WORKSPACE/.rune/skills"

  for skill in "$@"; do
    local url=$(grep "^${skill}[[:space:]]" "$TMP_REGISTRY" | awk '{print $2}')
    
    if [ -n "$url" ]; then
      curl -sS "$url" -o "$WORKSPACE/.rune/skills/${skill}.md"
      if [ -s "$WORKSPACE/.rune/skills/${skill}.md" ]; then
        echo "  ✓ ${skill} installed"
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
  install_skills "$@"
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
echo "  AI workspace setup
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
read -r -p "  Enter project directory name (leave blank for current directory): " PROJECT_NAME
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
    case "$yn" in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "  Please enter y or n." ;;
    esac
  done
}

# ─── STEP 1: TOOL SELECTION ───────────────────────────────────
# Hardcoded since we are fetching from remote
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

# ─── STEP 2: FETCH TEMPLATES ──────────────────────────────────
echo ""
echo "  ── Fetching templates ───────────────────────────────"

# Fetch Core templates
echo "  Downloading core templates..."
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

mkdir -p "$CORE"
mkdir -p "$SKILLS"

cp "$TMP_DIR/AGENTS.md"  "$CORE/AGENTS.md"
cp "$TMP_DIR/persona.md" "$CORE/persona.md"
echo "  ✓ .rune/core/AGENTS.md generated"
echo "  ✓ .rune/core/persona.md generated"

if [ ! -f "$SKILLS/README.md" ]; then
  echo "Drop your custom .md files here to add team rules." > "$SKILLS/README.md"
  echo "  ✓ .rune/skills/README.md generated"
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
    echo ".kiro/"
  } >> "$GITIGNORE"
  echo "  ✓ .gitignore updated"
fi

# ─── STEP 4: CONFIGURE SELECTED TOOLS ─────────────────────────
echo ""
echo "  ── Configuring tools ────────────────────────────────"
echo ""

POINTER_TEXT="You are an AI assistant powered by Rune. Your persona and agents are defined in \`.rune/core/\`. The technical stack rules you must follow are located in \`.rune/skills/\`. Read them before coding."

echo "$SELECTED" | while read -r tool; do
  tool=$(echo "$tool" | xargs)
  [ -z "$tool" ] && continue

  echo "  Setting up $tool..."

  case "$tool" in
    claude)
      echo "$POINTER_TEXT" > "$WORKSPACE/CLAUDE.md"
      echo "  ✓ CLAUDE.md written"
      ;;
    copilot)
      mkdir -p "$WORKSPACE/.github"
      echo "$POINTER_TEXT" > "$WORKSPACE/.github/copilot-instructions.md"
      echo "  ✓ .github/copilot-instructions.md written"
      ;;
    cursor)
      mkdir -p "$WORKSPACE/.cursor/rules"
      echo "$POINTER_TEXT" > "$WORKSPACE/.cursor/rules/base.mdc"
      echo "  ✓ .cursor/rules/base.mdc written"
      ;;
    antigravity)
      echo "$POINTER_TEXT" > "$WORKSPACE/GEMINI.md"
      echo "  ✓ GEMINI.md written"
      ;;
    kiro)
      mkdir -p "$WORKSPACE/.kiro/steering"
      printf -- "---\ninclusion: always\n---\n\n" > "$WORKSPACE/.kiro/steering/rune.md"
      echo "$POINTER_TEXT" >> "$WORKSPACE/.kiro/steering/rune.md"
      echo "  ✓ .kiro/steering/rune.md written"
      ;;
    opencode)
      mkdir -p ~/.config/opencode
      echo "$POINTER_TEXT" > ~/.config/opencode/AGENTS.md
      echo "  ✓ ~/.config/opencode/AGENTS.md written"
      ;;
  esac
done

# Install initial skills
if [ -n "$SKILLS_INPUT" ]; then
  install_skills $SKILLS_INPUT
fi

# Clean up tmp
rm -rf "$TMP_DIR"

# ─── GRAPHIFY RUNNER ──────────────────────────────────────────
# Runs graphify only if user consented AND it's available
run_graphify() {
  local cmd=$1
  if [ "$USE_GRAPHIFY" = true ] && command -v graphify &>/dev/null; then
    $cmd 2>/dev/null || true
  fi
}

# ─── STEP 5: GRAPHIFY (OPTIONAL) ──────────────────────────────
echo ""
echo "  ── Optional: graphify ───────────────────────────────"
echo "  graphify wires rune into your AI tools automatically."
echo "  Without it, rune still works — config files are"
echo "  written manually by this script."
echo ""

USE_GRAPHIFY=false

if command -v graphify &> /dev/null; then
  echo "  ✓ graphify already installed"
  USE_GRAPHIFY=true
else
  if ask_consent "Install graphify? (recommended)"; then
    echo "  Installing graphify..."
    npm install -g graphify-ai
    if command -v graphify &> /dev/null; then
      echo "  ✓ graphify installed"
      USE_GRAPHIFY=true
    else
      echo "  ✗ graphify install failed — continuing without it"
      echo "    Install later: npm install -g graphify-ai"
    fi
  else
    echo "  Skipping graphify"
  fi
fi

# Re-run graphify integrations if it's available
if [ "$USE_GRAPHIFY" = true ]; then
  echo "  Configuring graphify for selected tools..."
  echo "$SELECTED" | while read -r tool; do
    tool=$(echo "$tool" | xargs)
    case "$tool" in
      claude) run_graphify "graphify install" >/dev/null 2>&1 ;;
      copilot) run_graphify "graphify install --platform copilot" >/dev/null 2>&1 ;;
      cursor) run_graphify "graphify cursor install" >/dev/null 2>&1 ;;
      antigravity) run_graphify "graphify antigravity install" >/dev/null 2>&1 ;;
      kiro) run_graphify "graphify kiro install" >/dev/null 2>&1 ;;
      opencode) run_graphify "graphify install --platform opencode" >/dev/null 2>&1 ;;
    esac
  done
fi

# ─── STEP 6: CAVEMAN (OPTIONAL) ───────────────────────────────
echo ""
echo "  ── Optional: caveman ────────────────────────────────"
echo "  caveman cuts AI output tokens by 65-75%."
echo "  Saves cost + speeds up every response. MIT licensed."
echo "  github.com/JuliusBrussee/caveman"
echo ""

USE_CAVEMAN=false

if ask_consent "Install caveman token optimizer?"; then
  echo "  Installing caveman..."
  if [[ "$PLATFORM" == "windows" ]]; then
    # Windows PowerShell path
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.ps1 | iex"
    echo "  ✓ caveman installed"
  else
    curl -fsSL \
      https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh \
      | bash
    echo "  ✓ caveman installed"
  fi
  USE_CAVEMAN=true
else
  echo "  Skipping caveman"
fi

# ─── DONE ─────────────────────────────────────────────────────
echo ""
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ rune is ready in $WORKSPACE"
echo ""
echo "  To reconfigure:  rune setup"
echo "  To add skills:   rune install <skill>"
echo "  To extend:       drop a .md in .rune/skills/"
if [ "$USE_CAVEMAN" = false ]; then
  echo "  Token savings:   install caveman → github.com/JuliusBrussee/caveman"
fi
echo ""