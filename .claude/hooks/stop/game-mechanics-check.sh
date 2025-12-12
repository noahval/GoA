#!/bin/bash
# Game Mechanics Safety Check Hook (Stop Event)
# Gentle reminder about GoA game mechanics patterns
# Non-blocking awareness system - doesn't block, just reminds

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get list of recently modified .gd files (last 5 minutes)
MODIFIED_FILES=$(find . -name "*.gd" -mmin -5 2>/dev/null | grep -v "addons/" | head -n 20)

if [ -z "$MODIFIED_FILES" ]; then
    # No files modified, skip check
    exit 0
fi

# Detection flags
SCENE_CHANGE_DETECTED=false
TIMER_DETECTED=false
STAT_MODIFICATION_DETECTED=false
GLOBAL_STAT_DETECTED=false

# Check each file for risky patterns
while IFS= read -r file; do
    if [ ! -f "$file" ]; then
        continue
    fi

    # Check for scene changes (get_tree().change_scene*)
    if grep -qE "get_tree\(\)\.change_scene" "$file" 2>/dev/null; then
        SCENE_CHANGE_DETECTED=true
    fi

    # Check for timer modifications (Timer, timeout, whisper_timer, etc.)
    if grep -qE "(Timer\.new\(\)|\.timeout|whisper_timer|suspicion_timer|stamina_timer|break_timer)" "$file" 2>/dev/null; then
        TIMER_DETECTED=true
    fi

    # Check for direct stat modifications (Global.strength =, etc.)
    if grep -qE "Global\.(strength|constitution|dexterity|wisdom|intelligence|charisma)\s*=" "$file" 2>/dev/null; then
        GLOBAL_STAT_DETECTED=true
    fi

    # Check for stat modifications without using add_stat_exp
    if grep -qE "(strength|constitution|dexterity|wisdom|intelligence|charisma)" "$file" 2>/dev/null; then
        if ! grep -q "add_stat_exp" "$file" 2>/dev/null; then
            STAT_MODIFICATION_DETECTED=true
        fi
    fi

done <<< "$MODIFIED_FILES"

# Only show reminder if risky patterns detected
if [ "$SCENE_CHANGE_DETECTED" = true ] || [ "$TIMER_DETECTED" = true ] || [ "$STAT_MODIFICATION_DETECTED" = true ] || [ "$GLOBAL_STAT_DETECTED" = true ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 GAME MECHANICS SELF-CHECK"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "⚠️  GoA Game Mechanics Detected"

    SUGGESTIONS_SHOWN=false

    if [ "$SCENE_CHANGE_DETECTED" = true ]; then
        echo ""
        echo "   🎬 Scene Changes Detected"
        echo "   ❓ Did you use Global.change_scene_with_check()?"
        echo "   💡 This ensures scene changes respect game mechanics"
        SUGGESTIONS_SHOWN=true
    fi

    if [ "$TIMER_DETECTED" = true ]; then
        echo ""
        echo "   ⏱️  Timer Modifications Detected"
        echo "   ❓ Are you aware of global timer dependencies?"
        echo "   💡 Game has whisper, suspicion, stamina, and break timers"
        SUGGESTIONS_SHOWN=true
    fi

    if [ "$GLOBAL_STAT_DETECTED" = true ]; then
        echo ""
        echo "   📊 Direct Stat Assignment Detected"
        echo "   ❓ Should you use Global.add_stat_exp() instead?"
        echo "   💡 Direct assignment bypasses experience system"
        SUGGESTIONS_SHOWN=true
    fi

    if [ "$STAT_MODIFICATION_DETECTED" = true ] && [ "$GLOBAL_STAT_DETECTED" = false ]; then
        echo ""
        echo "   📈 Stat-Related Code Detected"
        echo "   ❓ Did you use Global.add_stat_exp()?"
        echo "   ❓ Did you use Global.show_stat_notification()?"
        echo "   💡 These ensure proper stat changes & user feedback"
        SUGGESTIONS_SHOWN=true
    fi

    if [ "$SUGGESTIONS_SHOWN" = true ]; then
        echo ""
        echo "   📚 Quick Reference:"
        echo "      → Global.add_stat_exp(stat_name, amount)"
        echo "      → Global.show_stat_notification(stat_name, amount)"
        echo "      → Global.change_scene_with_check(scene_path)"
        echo ""
        echo "   📖 See: game-systems.md for details"
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
fi

exit 0
