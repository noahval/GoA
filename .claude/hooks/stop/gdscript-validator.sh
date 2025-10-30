#!/bin/bash
# GDScript Validator Hook (Stop Event)
# Validates GDScript syntax after Claude finishes editing
# Runs after each response to catch errors immediately

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 GDScript Validator"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Get list of recently modified .gd files (last 5 minutes)
MODIFIED_FILES=$(find . -name "*.gd" -mmin -5 2>/dev/null | grep -v "addons/" | head -n 20)

if [ -z "$MODIFIED_FILES" ]; then
    echo "✅ No GDScript files modified recently"
    echo ""
    exit 0
fi

echo ""
echo "📝 Modified GDScript files detected:"
echo "$MODIFIED_FILES" | while read -r file; do
    echo "   → $file"
done
echo ""

# Check if Godot is available
if ! command -v godot &> /dev/null && ! command -v godot.exe &> /dev/null; then
    echo "⚠️  Godot not found in PATH - skipping syntax check"
    echo "💡 Tip: Add Godot to PATH for automatic validation"
    echo ""
    exit 0
fi

# Determine Godot command
GODOT_CMD="godot"
if command -v godot.exe &> /dev/null; then
    GODOT_CMD="godot.exe"
fi

# Validate each file
ERRORS_FOUND=0
TOTAL_FILES=0

echo "🔧 Running syntax validation..."
echo ""

echo "$MODIFIED_FILES" | while read -r file; do
    if [ ! -f "$file" ]; then
        continue
    fi

    TOTAL_FILES=$((TOTAL_FILES + 1))

    # Run Godot headless check
    OUTPUT=$("$GODOT_CMD" --headless --check-only --script "$file" 2>&1)
    EXIT_CODE=$?

    if [ $EXIT_CODE -ne 0 ]; then
        ERRORS_FOUND=$((ERRORS_FOUND + 1))
        echo "❌ ${file}:1"
        echo "$OUTPUT" | grep -E "(ERROR|SCRIPT ERROR|Parse Error)" | head -n 5
        echo ""
    else
        echo "✅ ${file}"
    fi
done

if [ $ERRORS_FOUND -gt 0 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ Found GDScript errors in $ERRORS_FOUND file(s)"
    echo ""
    echo "💡 Action Required:"
    echo "   Claude should fix these errors before proceeding"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ All GDScript files validated successfully!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
fi

exit 0
