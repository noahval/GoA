# Claude Hooks

**Event-triggered commands that execute automatically in response to specific actions**

---

## What Are Hooks?

Hooks are shell commands or scripts that run automatically when certain events occur during Claude Code sessions. They enable:
- Pre/post-commit validation
- Automated testing before submissions
- Code formatting on file changes
- Custom workflows triggered by tool use

---

## Available Hook Types

### user-prompt-submit-hook
**Trigger**: After user submits a message
**Use case**: Pre-process user input, check for patterns

### tool-use-hook
**Trigger**: Before/after tool execution
**Use case**: Validate operations, log activities

### file-change-hook
**Trigger**: When files are modified
**Use case**: Auto-format, lint, run tests

---

## Example Hooks

### Example: Pre-Commit Test Hook

**File**: `pre-commit-test.sh`

```bash
#!/bin/bash
# Run tests before allowing commit

echo "Running pre-commit tests..."

# Run GDScript tests
godot --headless --path "$(pwd)" res://test_scenes/all_tests.tscn --quit-after 30

if [ $? -ne 0 ]; then
    echo "Tests failed! Commit blocked."
    exit 1
fi

echo "Tests passed! Proceeding with commit."
exit 0
```

### Example: File Format Hook

**File**: `format-on-save.sh`

```bash
#!/bin/bash
# Auto-format GDScript files when saved

FILE=$1
if [[ $FILE == *.gd ]]; then
    gdformat "$FILE"
    echo "Formatted: $FILE"
fi
```

---

## Configuration

Hooks are configured in [.claude/settings.local.json](../.claude/settings.local.json):

```json
{
  "hooks": {
    "user-prompt-submit-hook": {
      "command": "bash .claude/hooks/pre-submit-check.sh"
    },
    "file-change-hook": {
      "command": "bash .claude/hooks/format-on-save.sh {file_path}"
    }
  }
}
```

---

## Creating Your Own Hooks

1. **Create script** in `.claude/hooks/`
2. **Make executable**: `chmod +x your-hook.sh`
3. **Configure** in `settings.local.json`
4. **Test** by triggering the event

---

## Best Practices

1. **Keep hooks fast**: Slow hooks delay workflows
2. **Handle errors gracefully**: Non-zero exit codes block operations
3. **Log verbosely**: Help debug when hooks fail
4. **Test thoroughly**: Ensure hooks don't break normal operation

---

## Implemented Hooks for GoA

### BIBLE Check Hook ⭐

**Files**: `bible-check.sh` (Bash) / `bible-check.ps1` (PowerShell)

**Purpose**: Automatically suggest reading [BIBLE.md](../docs/BIBLE.md) and relevant documentation when development keywords are detected in user messages.

**How It Works**:
1. Hook receives user message as input
2. Checks for bypass commands (skip docs, casual conversation, etc.)
3. Detects development keywords (scene, stats, popup, timer, etc.)
4. Provides helpful hints about which docs are relevant
5. I then read BIBLE.md and load relevant docs before working on the task

**Bypass Detection** - Hook skips when user says:
- `"skip docs"` / `"skip the docs"` / `"don't check"`
- `"skip bible"` / `"without docs"`
- `"just do it"` / `"just make X"` / `"quick question"`
- `"casual:"` (prefix for casual conversation)
- `"just read X.md"` (direct doc request)
- Follow-up indicators: `"and"`, `"also"`, `"then"`, `"continue"`

**Keyword Categories Detected**:
- **Scene System**: scene, template, layout, container, background
- **Popup System**: popup, dialog, modal, PopupContainer
- **Notification System**: notification, NotificationBar, show_stat_notification
- **Stats System**: stat, experience, exp, level, strength, constitution, etc.
- **Shop System**: shop, purchase, upgrade, coins, cost
- **Timer System**: timer, whisper, suspicion, stamina, break time
- **Theme System**: theme, color, style, appearance, StyleBoxFlat
- **Responsive System**: responsive, portrait, landscape, scaling, orientation
- **Debug System**: debug, test, logging, validate, headless
- **Godot Patterns**: godot, gdscript, node, signal, autoload, _ready, _process

**Example Output**:
```
🔍 Development keywords detected in your message
📖 Recommendation: Check BIBLE.md for relevant documentation

💡 Relevant systems might include:
   → scene-template.md (Scene structure & inheritance)
   → popup-system.md (Modal dialogs)
   → responsive-layout.md (Responsive design)

🎯 Claude will check BIBLE and read relevant docs automatically
```

**Configuration Example**:

In `.claude/settings.local.json`:
```json
{
  "hooks": {
    "user-prompt-submit-hook": {
      "command": "bash .claude/hooks/bible-check.sh '{message}'"
    }
  }
}
```

For Windows PowerShell:
```json
{
  "hooks": {
    "user-prompt-submit-hook": {
      "command": "powershell -File .claude/hooks/bible-check.ps1 '{message}'"
    }
  }
}
```

**Token Efficiency**:
- BIBLE.md: ~3k tokens
- Average doc: 5-8k tokens each
- Total per message: 8-16k tokens
- Avoiding one mistake (25k tokens) pays for 3-4 hook-enhanced messages
- **Net positive ROI** by preventing implementation errors

---

### GDScript Validator Hook ⭐

**Files**: `stop/gdscript-validator.sh` (Bash) / `stop/gdscript-validator.ps1` (PowerShell)

**Purpose**: Validates GDScript syntax after Claude finishes editing to catch errors immediately.

**How It Works**:
1. Hook runs after Claude finishes responding (Stop event)
2. Detects all `.gd` files modified in the last 5 minutes
3. Runs `godot --headless --check-only --script` on each file
4. Shows errors immediately so Claude can fix them
5. Prevents broken scripts from sitting unnoticed

**Example Output**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 GDScript Validator
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 Modified GDScript files detected:
   → global.gd
   → level1/shop.gd

🔧 Running syntax validation...

❌ global.gd:1
   ERROR: Parse Error at line 42

✅ level1/shop.gd

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ Found GDScript errors in 1 file(s)

💡 Action Required:
   Claude should fix these errors before proceeding
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Benefits**:
- Catches syntax errors immediately (no more finding errors hours later)
- Works like TypeScript build checker from the Reddit post
- Non-blocking if Godot isn't in PATH
- Zero tolerance for broken code

---

### Game Mechanics Safety Check Hook ⭐

**Files**: `stop/game-mechanics-check.sh` (Bash) / `stop/game-mechanics-check.ps1` (PowerShell)

**Purpose**: Gentle reminder about GoA game mechanics patterns to ensure Claude follows best practices.

**How It Works**:
1. Hook runs after Claude finishes responding (Stop event)
2. Scans recently modified `.gd` files for risky patterns
3. Detects scene changes, timer modifications, and stat changes
4. Shows gentle reminders (non-blocking awareness system)
5. Claude self-assesses whether patterns were followed correctly

**Patterns Detected**:
- **Scene Changes**: `get_tree().change_scene*` → Remind about `Global.change_scene_with_check()`
- **Timer Modifications**: Timer creation/modifications → Warn about global timer dependencies
- **Direct Stat Assignment**: `Global.strength =` → Suggest using `Global.add_stat_exp()`
- **Stat-Related Code**: Stats without `add_stat_exp()` → Remind about proper API usage

**Example Output**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 GAME MECHANICS SELF-CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  GoA Game Mechanics Detected

   📊 Direct Stat Assignment Detected
   ❓ Should you use Global.add_stat_exp() instead?
   💡 Direct assignment bypasses experience system

   📈 Stat-Related Code Detected
   ❓ Did you use Global.add_stat_exp()?
   ❓ Did you use Global.show_stat_notification()?
   💡 These ensure proper stat changes & user feedback

   📚 Quick Reference:
      → Global.add_stat_exp(stat_name, amount)
      → Global.show_stat_notification(stat_name, amount)
      → Global.change_scene_with_check(scene_path)

   📖 See: game-systems.md for details

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Benefits**:
- Protects core game mechanics from being bypassed
- Inspired by "Error Handling Reminder" hook from Reddit post
- Non-blocking, just awareness (philosophy hook approach)
- Reduces implementation mistakes significantly

---

### Potential Future Hooks

### Testing Hook
Run automated tests before commits to catch regressions.

### Documentation Hook
Auto-update TOC.md when files change (already implemented via toc_updater.gd).

### Debug Log Hook
Archive debug logs before new sessions.

### Victory Condition Validator
Verify victory conditions are still achievable after changes.

---

**See Also**:
- [BIBLE.md](../docs/BIBLE.md) - Master documentation index
- [Claude Code Hooks Documentation](https://docs.claude.com/)
- [Skills README](../skills/README.md)
- [Debug System](../docs/debug-system.md)
