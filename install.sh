#!/bin/bash

# anything-to-notebooklm Skill Installer
# Automatically installs all dependencies and configures the environment

set -e

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_NAME="anything-to-notebooklm"
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

# 1. Check uv installation
echo -e "${YELLOW}[1/6] Checking uv package manager...${NC}"
if ! command -v uv &> /dev/null; then
    echo -e "${RED}❌ uv not found. Please install uv from https://docs.astral.sh/uv/getting-started/${NC}"
    exit 1
fi

UV_VERSION=$(uv --version)
echo -e "${GREEN}✅ $UV_VERSION${NC}"

# 2. Create local virtual environment
echo ""
echo -e "${YELLOW}[2/6] Creating local virtual environment...${NC}"
if [ -d "$VENV_DIR" ]; then
    echo -e "${GREEN}✅ Virtual environment already exists${NC}"
else
    uv venv "$VENV_DIR"
    echo -e "${GREEN}✅ Virtual environment created${NC}"
fi

# 3. Clone wexin-read-mcp if needed
echo ""
echo -e "${YELLOW}[3/6] Installing MCP server...${NC}"
MCP_DIR="$SKILL_DIR/wexin-read-mcp"

if [ -d "$MCP_DIR" ]; then
    echo -e "${GREEN}✅ MCP server already exists${NC}"
else
    echo "Cloning wexin-read-mcp..."
    git clone https://github.com/Bwkyd/wexin-read-mcp.git "$MCP_DIR"
    echo -e "${GREEN}✅ MCP server cloned successfully${NC}"
fi

# 4. Install MCP dependencies and Playwright
echo ""
echo -e "${YELLOW}[4/6] Installing MCP dependencies and Playwright...${NC}"

if [ ! -x "$VENV_PY" ]; then
    echo -e "${RED}❌ Virtual environment python not found: $VENV_PY${NC}"
    exit 1
fi

if [ -f "$MCP_DIR/requirements.txt" ]; then
    echo "Installing MCP dependencies into local venv..."
    uv pip install --python "$VENV_PY" -r "$MCP_DIR/requirements.txt" -q
    echo -e "${GREEN}✅ MCP dependencies installed${NC}"
fi

echo "Installing Playwright browser..."
echo "This may take a few minutes, please be patient..."

if "$VENV_PY" -c "from playwright.sync_api import sync_playwright" 2>/dev/null; then
    "$VENV_PY" -m playwright install chromium
    echo -e "${GREEN}✅ Playwright browser installed${NC}"
else
    echo -e "${RED}❌ Playwright import failed. Please check installation${NC}"
    exit 1
fi

# 5. Set up CLI wrappers (uvx)
echo ""
echo -e "${YELLOW}[5/6] Setting up CLI wrappers (uvx)...${NC}"
mkdir -p "$BIN_DIR"

cat > "$BIN_DIR/notebooklm" <<'EOF'
#!/bin/bash
exec uvx --from "git+https://github.com/teng-lin/notebooklm-py.git" notebooklm "$@"
EOF

cat > "$BIN_DIR/markitdown" <<'EOF'
#!/bin/bash
exec uvx --from "markitdown[all]" markitdown "$@"
EOF

chmod +x "$BIN_DIR/notebooklm" "$BIN_DIR/markitdown"
echo -e "${GREEN}✅ notebooklm + markitdown wrappers created${NC}"

# 6. Configuration guidance
echo ""
echo -e "${YELLOW}[6/6] Configuration Guide${NC}"
echo ""

CLAUDE_CONFIG="$HOME/.claude/config.json"
CONFIG_SNIPPET="    \"weixin-reader\": {
      \"command\": \"$VENV_PY\",
      \"args\": [
        \"$MCP_DIR/src/server.py\"
      ]
    }"

echo -e "${BLUE}📝 Next step: Configure MCP server${NC}"
echo ""
echo "Edit $CLAUDE_CONFIG"
echo ""
echo "Add to \"mcpServers\":"
echo -e "${GREEN}$CONFIG_SNIPPET${NC}"
echo ""
echo "Full configuration example:"
echo -e "${GREEN}{
  \"primaryApiKey\": \"any\",
  \"mcpServers\": {
$CONFIG_SNIPPET
  }
}${NC}"
echo ""

if [ -f "$CLAUDE_CONFIG" ]; then
    if grep -q "weixin-reader" "$CLAUDE_CONFIG"; then
        echo -e "${GREEN}✅ Existing weixin-reader configuration detected${NC}"
    else
        echo -e "${YELLOW}⚠️  No weixin-reader configuration found. Please add manually${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Claude config file not found. Please create manually${NC}"
fi

echo ""
echo -e "${BLUE}🔐 NotebookLM Authentication${NC}"
echo ""
echo "Before first use, run:"
echo -e "${GREEN}  $BIN_DIR/notebooklm login${NC}"
echo -e "${GREEN}  $BIN_DIR/notebooklm list  # Verify authentication${NC}"
echo ""

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "📦 Install location: $SKILL_DIR"
echo ""
echo "⚠️  Important reminders:"
echo "  1. Restart Claude Code after configuring MCP server"
echo "  2. Add CLI wrappers to PATH: export PATH=\"$BIN_DIR:\$PATH\""
echo "  3. Run notebooklm login before first use"
echo ""
echo "🚀 Usage example:"
echo "  Turn this article into a podcast https://mp.weixin.qq.com/s/xxx"
echo ""
