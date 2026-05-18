#!/bin/bash

# ─── CONFIGURATION ────────────────────────────────────────────
WORKSPACE="$PWD"
CORE="$WORKSPACE/core"
EXTENSIONS="$WORKSPACE/extensions"
REPO_URL="https://raw.githubusercontent.com/bhargava562/rune/main"
TMP_DIR="/tmp/rune_templates_$$"

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
read -p "  → " INPUT

if [ "$INPUT" = "all" ]; then
  SELECTED="$AVAILABLE_TOOLS"
else
  SELECTED=$(echo "$INPUT" | tr ' ' '\n')
fi

# ─── STEP 2: FETCH TEMPLATES ──────────────────────────────────
echo ""
echo "  ── Fetching templates ───────────────────────────────"

mkdir -p "$TMP_DIR/adapters"

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

# Fetch specific adapters
echo "$SELECTED" | while read tool; do
  tool=$(echo "$tool" | xargs)
  [ -z "$tool" ] && continue
  
  # Only fetch if it's one of the known tools to avoid 404s breaking things
  if echo "$AVAILABLE_TOOLS" | grep -qw "$tool"; then
    curl -sS "$REPO_URL/templates/adapters/$tool.md" -o "$TMP_DIR/adapters/$tool.md"
  else
    echo "  ✗ Unknown tool: $tool"
  fi
done

echo "  ✓ Templates downloaded"

# ─── STEP 3: GENERATE CORE ────────────────────────────────────
echo ""
echo "  ── Generating files in $WORKSPACE ───────────────────"

mkdir -p "$CORE"
cp "$TMP_DIR/AGENTS.md"  "$CORE/AGENTS.md"
cp "$TMP_DIR/persona.md" "$CORE/persona.md"
echo "  ✓ core/AGENTS.md generated"
echo "  ✓ core/persona.md generated"

# ─── EXTENSION MERGER ─────────────────────────────────────────
merge_extensions() {
  local target=$1
  local found=0
  if [ -d "$EXTENSIONS" ]; then
    for f in "$EXTENSIONS"/*.md; do
      [[ "$(basename "$f")" == "README.md" ]] && continue
      [ -f "$f" ] || continue
      echo "" >> "$target"
      echo "## Extension: $(basename "$f" .md)" >> "$target"
      cat "$f" >> "$target"
      found=1
    done
  fi
  [ $found -eq 1 ] && echo "  ✓ extensions merged"
}

# ─── STEP 4: CONFIGURE SELECTED TOOLS ─────────────────────────
echo ""
echo "  ── Configuring tools ────────────────────────────────"
echo ""

echo "$SELECTED" | while read tool; do
  tool=$(echo "$tool" | xargs)
  [ -z "$tool" ] && continue

  TMPL="$TMP_DIR/adapters/$tool.md"

  if [ ! -f "$TMPL" ]; then
    continue
  fi

  echo "  Setting up $tool..."

  # Merge: AGENTS.md + persona.md + tool-specific template
  MERGED=$(mktemp)
  cat "$CORE/AGENTS.md"  >> "$MERGED"
  echo ""                >> "$MERGED"
  cat "$CORE/persona.md" >> "$MERGED"
  echo ""                >> "$MERGED"
  cat "$TMPL"            >> "$MERGED"

  case "$tool" in
    claude)
      cp "$MERGED" "$WORKSPACE/CLAUDE.md"
      merge_extensions "$WORKSPACE/CLAUDE.md"
      echo "  ✓ CLAUDE.md written"
      ;;
    copilot)
      mkdir -p "$WORKSPACE/.github"
      cp "$MERGED" "$WORKSPACE/.github/copilot-instructions.md"
      merge_extensions "$WORKSPACE/.github/copilot-instructions.md"
      echo "  ✓ .github/copilot-instructions.md written"
      ;;
    cursor)
      mkdir -p "$WORKSPACE/.cursor/rules"
      cp "$MERGED" "$WORKSPACE/.cursor/rules/base.mdc"
      merge_extensions "$WORKSPACE/.cursor/rules/base.mdc"
      echo "  ✓ .cursor/rules/base.mdc written"
      ;;
    antigravity)
      cp "$MERGED" "$WORKSPACE/GEMINI.md"
      merge_extensions "$WORKSPACE/GEMINI.md"
      echo "  ✓ GEMINI.md written"
      ;;
    kiro)
      mkdir -p "$WORKSPACE/.kiro/steering"
      printf -- "---\ninclusion: always\n---\n\n" \
        > "$WORKSPACE/.kiro/steering/rune.md"
      cat "$MERGED" >> "$WORKSPACE/.kiro/steering/rune.md"
      merge_extensions "$WORKSPACE/.kiro/steering/rune.md"
      echo "  ✓ .kiro/steering/rune.md written"
      ;;
    opencode)
      mkdir -p ~/.config/opencode
      cp "$MERGED" ~/.config/opencode/AGENTS.md
      merge_extensions ~/.config/opencode/AGENTS.md
      echo "  ✓ ~/.config/opencode/AGENTS.md written"
      ;;
  esac

  rm -f "$MERGED"
done

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
  echo "  Running graphify integrations..."
  echo "$SELECTED" | while read tool; do
    tool=$(echo "$tool" | xargs)
    case "$tool" in
      claude) run_graphify "graphify install" ;;
      copilot) run_graphify "graphify install --platform copilot" ;;
      cursor) run_graphify "graphify cursor install" ;;
      antigravity) run_graphify "graphify antigravity install" ;;
      kiro) run_graphify "graphify kiro install" ;;
      opencode) run_graphify "graphify install --platform opencode" ;;
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

# ─── DONE ─────────────────────────────────────────────────────
echo ""
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ rune is ready in $WORKSPACE"
echo ""
echo "  To reconfigure:  rune"
echo "  To extend:       drop a .md in extensions/"
if [ "$USE_CAVEMAN" = false ]; then
  echo "  Token savings:   install caveman → github.com/JuliusBrussee/caveman"
fi
echo ""