#!/bin/bash

WORKSPACE="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATES="$WORKSPACE/templates"
CORE="$WORKSPACE/core"
EXTENSIONS="$WORKSPACE/extensions"

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

# ─── PLATFORM DETECTION ───────────────────────────────────────
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
  PLATFORM="windows"
  echo "  Platform: Windows (Git Bash)"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  PLATFORM="mac"
  echo "  Platform: macOS"
else
  PLATFORM="linux"
  echo "  Platform: Linux"
fi

# ─── HELPER: YES/NO PROMPT ────────────────────────────────────
# Usage: ask_consent "question" → returns 0 (yes) or 1 (no)
ask_consent() {
  local question=$1
  while true; do
    read -p "  $question (y/n): " yn
    case "$yn" in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "  Please enter y or n." ;;
    esac
  done
}

# ─── STEP 1: GRAPHIFY (OPTIONAL) ──────────────────────────────
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
    echo "  Skipping graphify — rune will write config files directly"
  fi
fi

# ─── STEP 2: CAVEMAN (OPTIONAL) ───────────────────────────────
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
    echo "  Run this in PowerShell to complete caveman install:"
    echo "  irm https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.ps1 | iex"
    echo ""
    echo "  (caveman needs PowerShell on Windows — cannot auto-install from Git Bash)"
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

# ─── STEP 3: GENERATE core/ FROM templates/ ───────────────────
echo ""
echo "  ── Generating core files ────────────────────────────"

mkdir -p "$CORE"
cp "$TEMPLATES/AGENTS.md"  "$CORE/AGENTS.md"
cp "$TEMPLATES/persona.md" "$CORE/persona.md"
echo "  ✓ core/AGENTS.md generated"
echo "  ✓ core/persona.md generated"

# ─── STEP 4: DISCOVER + SELECT TOOLS ─────────────────────────
AVAILABLE=$(ls "$TEMPLATES/adapters/" 2>/dev/null | sed 's/\.md$//')

echo ""
echo "  ── Tool selection ───────────────────────────────────"
echo ""
echo "  Available tools:"
echo "$AVAILABLE" | while read tool; do
  echo "    • $tool"
done
echo ""
echo "  Type tools space-separated (or 'all'):"
echo "  Example: claude copilot cursor"
echo ""
read -p "  → " INPUT

if [ "$INPUT" = "all" ]; then
  SELECTED="$AVAILABLE"
else
  SELECTED=$(echo "$INPUT" | tr ' ' '\n')
fi

# ─── EXTENSION MERGER ─────────────────────────────────────────
merge_extensions() {
  local target=$1
  local found=0
  for f in "$EXTENSIONS"/*.md; do
    [[ "$(basename "$f")" == "README.md" ]] && continue
    [ -f "$f" ] || continue
    echo "" >> "$target"
    echo "## Extension: $(basename "$f" .md)" >> "$target"
    cat "$f" >> "$target"
    found=1
  done
  [ $found -eq 1 ] && echo "  ✓ extensions merged"
}

# ─── GRAPHIFY RUNNER ──────────────────────────────────────────
# Runs graphify only if user consented AND it's available
run_graphify() {
  local cmd=$1
  if [ "$USE_GRAPHIFY" = true ] && command -v graphify &>/dev/null; then
    $cmd 2>/dev/null || true
  fi
}

# ─── STEP 5: INSTALL EACH SELECTED TOOL ──────────────────────
echo ""
echo "  ── Installing tools ─────────────────────────────────"
echo ""

echo "$SELECTED" | while read tool; do
  tool=$(echo "$tool" | xargs)
  [ -z "$tool" ] && continue

  TMPL="$TEMPLATES/adapters/$tool.md"

  if [ ! -f "$TMPL" ]; then
    echo "  ✗ $tool — no template found, skipping"
    continue
  fi

  echo "  Installing $tool..."

  # Merge: AGENTS.md + persona.md + tool-specific template
  MERGED=$(mktemp)
  cat "$CORE/AGENTS.md"  >> "$MERGED"
  echo ""                >> "$MERGED"
  cat "$CORE/persona.md" >> "$MERGED"
  echo ""                >> "$MERGED"
  cat "$TMPL"            >> "$MERGED"

  case "$tool" in
    claude)
      run_graphify "graphify install"
      cp "$MERGED" "$WORKSPACE/CLAUDE.md"
      merge_extensions "$WORKSPACE/CLAUDE.md"
      echo "  ✓ CLAUDE.md written"
      ;;
    copilot)
      run_graphify "graphify install --platform copilot"
      mkdir -p "$WORKSPACE/.github"
      cp "$MERGED" "$WORKSPACE/.github/copilot-instructions.md"
      merge_extensions "$WORKSPACE/.github/copilot-instructions.md"
      echo "  ✓ .github/copilot-instructions.md written"
      ;;
    cursor)
      run_graphify "graphify cursor install"
      mkdir -p "$WORKSPACE/.cursor/rules"
      cp "$MERGED" "$WORKSPACE/.cursor/rules/base.mdc"
      merge_extensions "$WORKSPACE/.cursor/rules/base.mdc"
      echo "  ✓ .cursor/rules/base.mdc written"
      ;;
    antigravity)
      run_graphify "graphify antigravity install"
      cp "$MERGED" "$WORKSPACE/GEMINI.md"
      merge_extensions "$WORKSPACE/GEMINI.md"
      echo "  ✓ GEMINI.md written"
      ;;
    kiro)
      run_graphify "graphify kiro install"
      mkdir -p "$WORKSPACE/.kiro/steering"
      printf -- "---\ninclusion: always\n---\n\n" \
        > "$WORKSPACE/.kiro/steering/rune.md"
      cat "$MERGED" >> "$WORKSPACE/.kiro/steering/rune.md"
      merge_extensions "$WORKSPACE/.kiro/steering/rune.md"
      echo "  ✓ .kiro/steering/rune.md written"
      ;;
    opencode)
      run_graphify "graphify install --platform opencode"
      mkdir -p ~/.config/opencode
      cp "$MERGED" ~/.config/opencode/AGENTS.md
      merge_extensions ~/.config/opencode/AGENTS.md
      echo "  ✓ ~/.config/opencode/AGENTS.md written"
      ;;
  esac

  rm -f "$MERGED"
done

# ─── DONE ─────────────────────────────────────────────────────
echo ""
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ rune is ready."
echo ""
echo "  To reconfigure:  bash scripts/setup.sh"
echo "  To extend:       drop a .md in extensions/"
if [ "$USE_CAVEMAN" = false ]; then
  echo "  Token savings:   install caveman → github.com/JuliusBrussee/caveman"
fi
echo ""