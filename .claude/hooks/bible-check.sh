#!/bin/bash
# BIBLE Check Hook
# Automatically suggests reading BIBLE.md when development keywords are detected
# User can bypass with natural language commands

MESSAGE="$1"

# ===== BYPASS DETECTION =====
# Check if user explicitly wants to skip docs
if echo "$MESSAGE" | grep -qiE "(skip (the )?docs?|don't check|skip bible|without docs?|just (do|make|change)|quick (question|fix)|casual:)"; then
    echo "⚡ Bypass detected - skipping BIBLE check"
    echo "💬 Proceeding without documentation lookup"
    exit 0
fi

# Check if user is directing to specific doc(s)
if echo "$MESSAGE" | grep -qiE "(just read|only (read|check|look at)|read only|look at|check) [a-z-]+\.md"; then
    echo "📄 Specific doc requested - skipping BIBLE check"
    echo "💬 Claude will read your requested file(s) directly"
    exit 0
fi

# Check if this is a follow-up (continuing previous context)
if echo "$MESSAGE" | grep -qiE "^(and|also|then|now|next|same scene|continue|following up|still working on)"; then
    echo "🔄 Follow-up detected - context likely still fresh"
    echo "💡 Hint: Claude may already have needed docs from earlier"
    exit 0
fi

# ===== DEVELOPMENT KEYWORD DETECTION =====
# Check if message contains development-related keywords
if echo "$MESSAGE" | grep -qiE "(scene|stat(s)?|shop|popup|notification|theme|button|timer|victory|experience|exp|level|upgrade|godot|responsive|layout|debug|test|code|function|fix|add|create|modify|implement|build|change|update|refactor|bug|error|issue|problem|help|how (do|to)|why|what|where|panel|label|container|global|autoload|signal|node|script|\.gd|\.tscn|resource|progression|mechanic|system)"; then
    echo ""
    echo "🔍 Development keywords detected in your message"
    echo "📖 Recommendation: Check BIBLE.md for relevant documentation"
    echo ""
    echo "💡 Relevant systems might include:"

    # Provide specific hints based on detected keywords
    if echo "$MESSAGE" | grep -qiE "(scene|template|layout|container|background)"; then
        echo "   → scene-template.md (Scene structure & inheritance)"
    fi

    if echo "$MESSAGE" | grep -qiE "(popup|dialog|modal|PopupContainer)"; then
        echo "   → popup-system.md (Modal dialogs)"
    fi

    if echo "$MESSAGE" | grep -qiE "(notification|NotificationBar|show_stat_notification)"; then
        echo "   → notifications.md (Notification system)"
    fi

    if echo "$MESSAGE" | grep -qiE "(stat(s)?|experience|exp|level|strength|constitution|dexterity|wisdom|intelligence|charisma)"; then
        echo "   → game-systems.md (Stats & experience)"
    fi

    if echo "$MESSAGE" | grep -qiE "(shop|purchase|upgrade|coins|cost)"; then
        echo "   → game-systems.md (Shop system)"
    fi

    if echo "$MESSAGE" | grep -qiE "(timer|whisper|suspicion|stamina|break.?time)"; then
        echo "   → game-systems.md (Timer systems)"
    fi

    if echo "$MESSAGE" | grep -qiE "(theme|color|style|appearance|visual|StyleBoxFlat|variation)"; then
        echo "   → theme-system.md (Theme & styling)"
    fi

    if echo "$MESSAGE" | grep -qiE "(responsive|portrait|landscape|scaling|mobile|orientation)"; then
        echo "   → responsive-layout.md (Responsive design)"
    fi

    if echo "$MESSAGE" | grep -qiE "(debug|test|logging|validate|verify|headless)"; then
        echo "   → debug-system.md (Testing & debugging)"
    fi

    if echo "$MESSAGE" | grep -qiE "(godot|gdscript|node|signal|autoload|_ready|_process)"; then
        echo "   → godot-dev.md (Godot patterns)"
    fi

    echo ""
    echo "🎯 Claude will check BIBLE and read relevant docs automatically"
    echo ""

    exit 0
else
    # No development keywords - likely casual conversation
    echo "💬 General conversation detected - skipping BIBLE check"
    exit 0
fi
