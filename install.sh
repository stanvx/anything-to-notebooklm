#!/bin/bash

# anything-to-notebooklm Skill Installer
# Installs all dependencies into a local .venv for isolation

set -e

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SKILL_DIR/.venv"
VENV_PY="$VENV_DIR/bin/python"
BIN_DIR="$SKILL_DIR/bin"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Multi-Source → NotebookLM Installer${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 1. Check uv
echo -e "${YELLOW}[1/4] Checking uv...${NC}"
if ! command -v uv &> /dev/null; then
    echo -e "${RED}❌ uv not found. Install from https://docs.astral.sh/uv/getting-started/${NC}"
    exit 1
fi
echo -e "${GREEN}✅ $(uv --version)${NC}"

# 2. Create virtual environment
echo ""
echo -e "${YELLOW}[2/4] Creating virtual environment...${NC}"
if [ -d "$VENV_DIR" ]; then
    echo -e "${GREEN}✅ Already exists${NC}"
else
    uv venv "$VENV_DIR" -q
    echo -e "${GREEN}✅ Created${NC}"
fi

# 3. Install Python dependencies into .venv
echo ""
echo -e "${YELLOW}[3/4] Installing Python dependencies...${NC}"

if [ ! -x "$VENV_PY" ]; then
    echo -e "${RED}❌ Venv python not found at $VENV_PY${NC}"
    exit 1
fi

echo "  → notebooklm CLI..."
uv pip install --python "$VENV_PY" "notebooklm-py @ git+https://github.com/teng-lin/notebooklm-py.git" -q

echo "  → markitdown..."
uv pip install --python "$VENV_PY" "markitdown[all]" -q

echo -e "${GREEN}✅ All dependencies installed${NC}"

# 4. Create convenience wrappers in bin/
echo ""
echo -e "${YELLOW}[4/4] Creating CLI wrappers...${NC}"
mkdir -p "$BIN_DIR"

cat > "$BIN_DIR/notebooklm" <<WRAPPER
#!/bin/bash
exec "$VENV_DIR/bin/notebooklm" "\$@"
WRAPPER

cat > "$BIN_DIR/markitdown" <<WRAPPER
#!/bin/bash
exec "$VENV_DIR/bin/markitdown" "\$@"
WRAPPER

chmod +x "$BIN_DIR/notebooklm" "$BIN_DIR/markitdown"
echo -e "${GREEN}✅ Wrappers created in $BIN_DIR${NC}"

# Done — show next steps
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "📦 Location: $SKILL_DIR"
echo ""
echo -e "${BLUE}📝 Next steps:${NC}"
echo ""
echo "  1. Authenticate NotebookLM (one-time):"
echo -e "     ${GREEN}$BIN_DIR/notebooklm login${NC}"
echo -e "     ${GREEN}$BIN_DIR/notebooklm list${NC}  # verify"
echo ""
echo "  2. (Optional) Add to PATH:"
echo -e "     ${GREEN}export PATH=\"$BIN_DIR:\$PATH\"${NC}"
echo ""
echo "🚀 Try: Turn this article into a podcast https://example.com/article"
echo ""
