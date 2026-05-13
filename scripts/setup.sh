#!/bin/bash

WORKSPACE="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATES="$WORKSPACE/templates"
CORE="$WORKSPACE/core"
EXTENSIONS="$WORKSPACE/extensions"
ADAPTERS="$WORKSPACE/adapters"

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

# ─── STEP 1: CHECK GRAPHIFY ───────────────────────────────────
echo ""
echo "  Checking dependencies..."

if ! command -v graphify &> /dev/null; then
  echo "  graphify not found. Installing..."
  npm install -g graphify-ai
  if ! command -v graphify &> /dev/null; then
    echo "  ✗ graphify install failed."
    echo "    Run manually: npm install -g graphify-ai"
    exit 1
  fi
fi
echo "  ✓ graphify ready"

# ─── STEP 2: GENERATE core/ FROM templates/ ───────────────────
echo ""
echo "  Generating core files from templates..."

mkdir -p "$CORE"
cp "$TEMPLATES/AGENTS.md"  "$CORE/AGENTS.md"
cp "$TEMPLATES/persona.md" "$CORE/persona.md"
echo "  ✓ core/AGENTS.md generated"
echo "  ✓ core/persona.md generated"

# ─── STEP 3: DISCOVER AVAILABLE TOOLS ────────────────────────
AVAILABLE=$(ls "$TEMPLATES/adapters/" 2>/dev/null \
  | sed 's/\.md$//')

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

# ─── OS DETECTION ─────────────────────────────────────────────
is_windows() {
  [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" \
     || "$OSTYPE" == "cygwin" ]]
}

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

# ─── STEP 4: INSTALL EACH SELECTED TOOL ──────────────────────
echo ""
echo "  Installing..."
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

  # Build the merged config for this tool
  MERGED=$(mktemp)
  cat "$CORE/AGENTS.md"    >> "$MERGED"
  echo ""                  >> "$MERGED"
  cat "$CORE/persona.md"   >> "$MERGED"
  echo ""                  >> "$MERGED"
  cat "$TMPL"              >> "$MERGED"

  # Write tool-specific output file
  case "$tool" in
    claude)
      graphify install 2>/dev/null || true
      cp "$MERGED" "$WORKSPACE/CLAUDE.md"
      merge_extensions "$WORKSPACE/CLAUDE.md"
      echo "  ✓ CLAUDE.md written"
      ;;
    copilot)
      graphify install --platform copilot 2>/dev/null || true
      mkdir -p "$WORKSPACE/.github"
      cp "$MERGED" "$WORKSPACE/.github/copilot-instructions.md"
      merge_extensions "$WORKSPACE/.github/copilot-instructions.md"
      echo "  ✓ .github/copilot-instructions.md written"
      ;;
    cursor)
      graphify cursor install 2>/dev/null || true
      mkdir -p "$WORKSPACE/.cursor/rules"
      cp "$MERGED" "$WORKSPACE/.cursor/rules/base.mdc"
      merge_extensions "$WORKSPACE/.cursor/rules/base.mdc"
      echo "  ✓ .cursor/rules/base.mdc written"
      ;;
    antigravity)
      graphify antigravity install 2>/dev/null || true
      cp "$MERGED" "$WORKSPACE/GEMINI.md"
      merge_extensions "$WORKSPACE/GEMINI.md"
      echo "  ✓ GEMINI.md written"
      ;;
    kiro)
      graphify kiro install 2>/dev/null || true
      mkdir -p "$WORKSPACE/.kiro/steering"
      printf -- "---\ninclusion: always\n---\n\n" \
        > "$WORKSPACE/.kiro/steering/rune.md"
      cat "$MERGED" >> "$WORKSPACE/.kiro/steering/rune.md"
      merge_extensions "$WORKSPACE/.kiro/steering/rune.md"
      echo "  ✓ .kiro/steering/rune.md written"
      ;;
    opencode)
      graphify install --platform opencode 2>/dev/null || true
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
echo "  To add a tool later:  bash scripts/setup.sh"
echo "  To extend:            drop a .md in extensions/"
echo ""