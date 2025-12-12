# BIBLE Check Hook (PowerShell version)
# Automatically suggests reading BIBLE.md when development keywords are detected
# User can bypass with natural language commands

param(
    [string]$Message
)

# ===== BYPASS DETECTION =====
# Check if user explicitly wants to skip docs
if ($Message -match "(?i)(skip (the )?docs?|don't check|skip bible|without docs?|just (do|make|change)|quick (question|fix)|casual:)") {
    Write-Host "⚡ Bypass detected - skipping BIBLE check"
    Write-Host "💬 Proceeding without documentation lookup"
    exit 0
}

# Check if user is directing to specific doc(s)
if ($Message -match "(?i)(just read|only (read|check|look at)|read only|look at|check) [a-z-]+\.md") {
    Write-Host "📄 Specific doc requested - skipping BIBLE check"
    Write-Host "💬 Claude will read your requested file(s) directly"
    exit 0
}

# Check if this is a follow-up (continuing previous context)
if ($Message -match "(?i)^(and|also|then|now|next|same scene|continue|following up|still working on)") {
    Write-Host "🔄 Follow-up detected - context likely still fresh"
    Write-Host "💡 Hint: Claude may already have needed docs from earlier"
    exit 0
}

# ===== DEVELOPMENT KEYWORD DETECTION =====
# Check if message contains development-related keywords
if ($Message -match "(?i)(scene|stat(s)?|shop|popup|notification|theme|button|timer|victory|experience|exp|level|upgrade|godot|responsive|layout|debug|test|code|function|fix|add|create|modify|implement|build|change|update|refactor|bug|error|issue|problem|help|how (do|to)|why|what|where|panel|label|container|global|autoload|signal|node|script|\.gd|\.tscn|resource|progression|mechanic|system)") {
    Write-Host ""
    Write-Host "🔍 Development keywords detected in your message"
    Write-Host "📖 Recommendation: Check BIBLE.md for relevant documentation"
    Write-Host ""
    Write-Host "💡 Relevant systems might include:"

    # Provide specific hints based on detected keywords
    if ($Message -match "(?i)(scene|template|layout|container|background)") {
        Write-Host "   → scene-template.md (Scene structure & inheritance)"
    }

    if ($Message -match "(?i)(popup|dialog|modal|PopupContainer)") {
        Write-Host "   → popup-system.md (Modal dialogs)"
    }

    if ($Message -match "(?i)(notification|NotificationBar|show_stat_notification)") {
        Write-Host "   → notifications.md (Notification system)"
    }

    if ($Message -match "(?i)(stat(s)?|experience|exp|level|strength|constitution|dexterity|wisdom|intelligence|charisma)") {
        Write-Host "   → game-systems.md (Stats & experience)"
    }

    if ($Message -match "(?i)(shop|purchase|upgrade|coins|cost)") {
        Write-Host "   → game-systems.md (Shop system)"
    }

    if ($Message -match "(?i)(timer|whisper|suspicion|stamina|break.?time)") {
        Write-Host "   → game-systems.md (Timer systems)"
    }

    if ($Message -match "(?i)(theme|color|style|appearance|visual|StyleBoxFlat|variation)") {
        Write-Host "   → theme-system.md (Theme & styling)"
    }

    if ($Message -match "(?i)(responsive|portrait|landscape|scaling|mobile|orientation)") {
        Write-Host "   → responsive-layout.md (Responsive design)"
    }

    if ($Message -match "(?i)(debug|test|logging|validate|verify|headless)") {
        Write-Host "   → debug-system.md (Testing & debugging)"
    }

    if ($Message -match "(?i)(godot|gdscript|node|signal|autoload|_ready|_process)") {
        Write-Host "   → godot-dev.md (Godot patterns)"
    }

    Write-Host ""
    Write-Host "🎯 Claude will check BIBLE and read relevant docs automatically"
    Write-Host ""

    exit 0
} else {
    # No development keywords - likely casual conversation
    Write-Host "💬 General conversation detected - skipping BIBLE check"
    exit 0
}
