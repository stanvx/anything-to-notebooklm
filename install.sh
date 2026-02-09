#!/bin/bash

# anything-to-notebooklm Skill Installer
# Installs all dependencies into a local .venv for isolation

set -e

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SKILL_DIR/.venv"
VENV_PY="$VENV_DIR/bin/python"
BIN_DIR="$SKILL_DIR/bin"
MCP_DIR="$SKILL_DIR/wexin-read-mcp"

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
echo -e "${YELLOW}[1/6] Checking uv...${NC}"
if ! command -v uv &> /dev/null; then
    echo -e "${RED}❌ uv not found. Install from https://docs.astral.sh/uv/getting-started/${NC}"
    exit 1
fi
echo -e "${GREEN}✅ $(uv --version)${NC}"

# 2. Create virtual environment
echo ""
echo -e "${YELLOW}[2/6] Creating virtual environment...${NC}"
if [ -d "$VENV_DIR" ]; then
    echo -e "${GREEN}✅ Already exists${NC}"
else
    uv venv "$VENV_DIR" -q
    echo -e "${GREEN}✅ Created${NC}"
fi

# 3. Clone wexin-read-mcp if needed
echo ""
echo -e "${YELLOW}[3/6] Setting up WeChat MCP server...${NC}"
if [ -d "$MCP_DIR" ]; then
    echo -e "${GREEN}✅ Already exists${NC}"
else
    git clone -q https://github.com/Bwkyd/wexin-read-mcp.git "$MCP_DIR"
    echo -e "${GREEN}✅ Cloned${NC}"
fi

# 4. Install ALL Python dependencies into .venv
echo ""
echo -e "${YELLOW}[4/6] Installing Python dependencies...${NC}"

if [ ! -x "$VENV_PY" ]; then
    echo -e "${RED}❌ Venv python not found at $VENV_PY${NC}"
    exit 1
fi

# MCP server deps
if [ -f "$MCP_DIR/requirements.txt" ]; then
    echo "  → MCP server dependencies..."
    uv pip install --python "$VENV_PY" -r "$MCP_DIR/requirements.txt" -q
fi

# notebooklm CLI + markitdown
echo "  → notebooklm CLI..."
uv pip install --python "$VENV_PY" "notebooklm-py @ git+https://github.com/teng-lin/notebooklm-py.git" -q

echo "  → markitdown..."
uv pip install --python "$VENV_PY" "markitdown[all]" -q

echo -e "${GREEN}✅ All dependencies installed${NC}"

# 5. Install Playwright browser
echo ""
echo -e "${YELLOW}[5/6] Installing Playwright browser...${NC}"
if "$VENV_PY" -c "from playwright.sync_api import sync_playwright" 2>/dev/null; then
    "$VENV_PY" -m playwright install chromium --quiet 2>/dev/null || \
    "$VENV_PY" -m playwright install chromium
    echo -e "${GREEN}✅ Chromium installed${NC}"
else
    echo -e "${YELLOW}⚠️  Playwright not available — WeChat article fetching may not work${NC}"
    echo -e "${YELLOW}   (Other features will work fine)${NC}"
fi

# 6. Create convenience wrappers in bin/
echo ""
echo -e "${YELLOW}[6/6] Creating CLI wrappers...${NC}"
mkdir -p "$BIN_DIR"

# Wrappers exec the venv binaries directly — no uvx needed
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

# Detect environment
CLAUDE_CONFIG="$HOME/.claude/config.json"
echo -e "${BLUE}📝 Next steps:${NC}"
echo ""
echo "  1. Authenticate NotebookLM (one-time):"
echo -e "     ${GREEN}$BIN_DIR/notebooklm login${NC}"
echo -e "     ${GREEN}$BIN_DIR/notebooklm list${NC}  # verify"
echo ""

echo "  2. (Optional) WeChat article support — configure MCP server:"
echo ""
echo -e "     ${BLUE}Claude Code:${NC} Add to ~/.claude/config.json → mcpServers:"
echo -e "     ${GREEN}\"weixin-reader\": { \"command\": \"$VENV_PY\", \"args\": [\"$MCP_DIR/src/server.py\"] }${NC}"
echo ""
echo -e "     ${BLUE}OpenClaw:${NC} The skill instructions handle this automatically."
echo "     For manual use: $VENV_PY $MCP_DIR/src/server.py"
echo ""

if [ -f "$CLAUDE_CONFIG" ] && grep -q "weixin-reader" "$CLAUDE_CONFIG" 2>/dev/null; then
    echo -e "     ${GREEN}✅ Existing weixin-reader config detected${NC}"
fi

echo "  3. (Optional) Add to PATH:"
echo -e "     ${GREEN}export PATH=\"$BIN_DIR:\$PATH\"${NC}"
echo ""
echo "🚀 Try: Turn this article into a podcast https://mp.weixin.qq.com/s/xxx"
echo ""
