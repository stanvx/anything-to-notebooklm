#!/bin/bash

# Package anything-to-notebooklm skill for sharing
# Creates a lightweight tar.gz without large files

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_NAME="anything-to-notebooklm"
OUTPUT_DIR="${1:-$HOME/Desktop}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$OUTPUT_DIR/${SKILL_NAME}_${TIMESTAMP}.tar.gz"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Packaging ${SKILL_NAME} Skill${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

FILES=(
    "SKILL.md"
    "README.md"
    "install.sh"
    "check_env.py"
    "requirements.txt"
    ".gitignore"
)

TEMP_DIR=$(mktemp -d)
TEMP_SKILL="$TEMP_DIR/$SKILL_NAME"
mkdir -p "$TEMP_SKILL"
mkdir -p "$TEMP_SKILL/references"

echo "📦 Packaging files..."

for file in "${FILES[@]}"; do
    if [ -f "$SKILL_DIR/$file" ]; then
        cp "$SKILL_DIR/$file" "$TEMP_SKILL/"
        echo "  ✓ $file"
    fi
done

# Include reference files
if [ -d "$SKILL_DIR/references" ]; then
    cp "$SKILL_DIR/references/"*.md "$TEMP_SKILL/references/" 2>/dev/null
    echo "  ✓ references/"
fi

cd "$TEMP_DIR"
tar -czf "$OUTPUT_FILE" "$SKILL_NAME"

rm -rf "$TEMP_DIR"

FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)

echo ""
echo -e "${GREEN}✅ Packaging complete!${NC}"
echo ""
echo "📦 File: $OUTPUT_FILE"
echo "📊 Size: $FILE_SIZE"
echo ""
echo "📤 Sharing instructions:"
echo "  After receiving the file, run:"
echo "    cd ~/.claude/skills/"
echo "    tar -xzf ${SKILL_NAME}_${TIMESTAMP}.tar.gz"
echo "    cd ${SKILL_NAME}"
echo "    ./install.sh"
echo ""
echo ""
