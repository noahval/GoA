# THE BIBLE - Master Documentation Index

**⚠️ THIS IS THE MASTER INDEX FOR ALL GOA DOCUMENTATION ⚠️**

**Purpose**: Keyword-based navigation to ALL technical documentation for GoA development

**When to Read**: Before working on ANY system, check this index for relevant docs

---

## 📖 How This Works

1. **User mentions keywords** in their request
2. **You identify relevant systems** from keyword table below
3. **You read the corresponding documentation** before taking action
4. **You follow documented patterns** when implementing/modifying code

**ALWAYS check this index before modifying game systems!**

---

## 🤖 Automatic Hook System

**The BIBLE Check Hook automatically triggers when you mention development keywords!**

### How the Hook Works

When you submit a message with development keywords (scene, stats, popup, etc.), the hook:
1. **Detects keywords** in your message
2. **Suggests checking BIBLE.md** for relevant documentation
3. **Provides helpful hints** about which docs might be relevant
4. **I then automatically read BIBLE + relevant docs** before starting work

### Bypass Commands

You can skip the automatic BIBLE check with natural language:

**Casual conversation bypass**:
- `"skip docs"` / `"skip the docs"` / `"don't check"`
- `"quick question"` / `"casual:"` (prefix)

**Direct doc request bypass**:
- `"just read game-systems.md"`
- `"only check popup-system.md"`
- `"look at scene-template.md"`

**Follow-up bypass** (when context is fresh):
- `"and also..."` / `"then..."` / `"continue..."`
- `"same scene"` / `"following up"`

### Example Interactions

**With Hook (Development Task)**:
```
You: "Add a popup to the bar scene"
Hook: 🔍 Keywords detected → popup, scene
      📖 Relevant docs: popup-system.md, scene-template.md
Me: [Reads BIBLE.md + popup-system.md + scene-template.md]
    [Implements following documented patterns]
```

**With Bypass (Quick Question)**:
```
You: "quick question - what's the victory scene path?"
Hook: ⚡ Bypass detected - skipping BIBLE check
Me: [Answers directly without reading docs]
```

**With Direct Request (Specific Doc)**:
```
You: "just read game-systems.md and explain the shop"
Hook: 📄 Specific doc requested - skipping BIBLE check
Me: [Reads only game-systems.md as requested]
```

### Token Efficiency

- **Cost**: 8-16k tokens per message (BIBLE + 1-2 docs)
- **Benefit**: Prevents implementation errors that cost 25k+ tokens to fix
- **ROI**: Avoiding one mistake pays for 3-4 hook-enhanced messages
- **Net Result**: Positive ROI + better code quality

**See**: [.claude/hooks/README.md](../../hooks/README.md) for hook configuration details

---

## 🗺️ Complete Documentation Map

### Core Game Systems

| Documentation | Keywords | When to Read |
|--------------|----------|--------------|
| **[game-systems.md](game-systems.md)** | `stats`, `experience`, `exp`, `level up`, `add_stat_exp`, `strength`, `constitution`, `dexterity`, `wisdom`, `intelligence`, `charisma`, `shop`, `purchase`, `upgrade`, `coins`, `cost`, `timer`, `whisper`, `suspicion`, `get caught`, `stamina`, `break time`, `notification`, `popup message`, `victory`, `win condition` | Working with player stats, shop mechanics, timers, or victory conditions |

### UI & Scene Systems

| Documentation | Keywords | When to Read |
|--------------|----------|--------------|
| **[scene-template.md](scene-template.md)** | `scene`, `template`, `inheritance`, `layout`, `container`, `LeftVBox`, `RightVBox`, `CenterArea`, `HBoxContainer`, `VBoxContainer`, `four-container`, `background`, `auto-load background`, `settings_overlay` | Creating new scenes, modifying scene structure, or debugging layout issues |
| **[responsive-layout.md](responsive-layout.md)** | `responsive`, `portrait`, `landscape`, `scaling`, `mobile`, `orientation`, `ResponsiveLayout`, `apply_to_scene`, `mouse_filter`, `PASS` | Working with UI scaling, orientation changes, or responsive design |
| **[popup-system.md](popup-system.md)** | `popup`, `dialog`, `modal`, `PopupContainer`, `reusable_popup`, `show_popup`, `button_pressed signal` | Implementing dialogs, confirmations, or modal popups |
| **[notifications.md](notifications.md)** | `notification`, `show_stat_notification`, `NotificationBar`, `dynamic notification`, `auto-removal`, `notification panel`, `stat notification` | Working with notification system, displaying messages to user |
| **[theme-system.md](theme-system.md)** | `theme`, `default_theme`, `styling`, `colors`, `StyleBoxFlat`, `theme variation`, `PopupButton`, `SuspicionProgressBar`, `appearance`, `visual style` | Modifying visual appearance, colors, or creating theme variations |

### Development Tools

| Documentation | Keywords | When to Read |
|--------------|----------|--------------|
| **[debug-system.md](debug-system.md)** | `debug`, `logging`, `test`, `testing`, `autonomous test`, `validate`, `verify`, `headless`, `log file`, `DebugLogger` | Testing features, debugging issues, or running autonomous validation |
| **[godot-dev.md](godot-dev.md)** | `godot`, `gdscript`, `node`, `signal`, `autoload`, `_ready`, `_process`, `scene tree`, `@onready` | General Godot development questions, patterns, or best practices |

---

## 📚 All Documentation Files

### Game Mechanics & Systems
**[game-systems.md](game-systems.md)** - Complete game mechanics reference
- Experience & leveling system (Global.gd)
- Stats system (six stats with notifications)
- Shop & upgrade mechanics (shop.gd)
- Timer systems (whisper, suspicion, stamina regeneration)
- Notification system (Global.show_stat_notification)
- Victory conditions and checking
- Resource management (Level1Vars)
- Suspicion & get caught mechanics

### UI Architecture
**[scene-template.md](scene-template.md)** - Scene inheritance & layout
- Four-container layout structure
- Scene template system
- Container purposes (LeftVBox, RightVBox, CenterArea, NotificationBar)
- Background auto-loading
- Standard patterns (panels, progress bars, buttons)
- Popup integration requirements
- Signal preservation

**[responsive-layout.md](responsive-layout.md)** - Responsive scaling system
- Centralized configuration (responsive_layout.gd)
- Portrait vs landscape layouts
- Auto-scaling formulas
- Configuration constants reference
- Mouse filter management
- Orientation detection and transformation

**[popup-system.md](popup-system.md)** - Modal dialog system
- Popup API reference (setup, show_popup, hide_popup)
- PopupContainer requirement
- Implementation patterns
- Theme system (reusable_popup integration)
- Common issues and solutions

**[notifications.md](notifications.md)** - Dynamic notification system
- Complete notification flow (9 steps)
- NotificationBar container management
- Dynamic panel/label creation
- Auto-removal timers (3 seconds)
- Responsive scaling (landscape/portrait)
- Integration with stat system

**[theme-system.md](theme-system.md)** - Centralized theming
- default_theme.tres structure
- Base styles (Button, Label, Panel, ProgressBar)
- Theme variations (PopupButton, SuspicionProgressBar, StyledPopup)
- Component integration (reusable_popup, settings_overlay, notifications)
- Customization guide
- Color palette reference

### Development Infrastructure
**[debug-system.md](debug-system.md)** - Testing & debugging
- DebugLogger autoload implementation
- Autonomous testing procedures
- Log analysis and categories
- Headless testing commands
- Test scenarios and validation

**[godot-dev.md](godot-dev.md)** - Godot 4.5 patterns
- GDScript style guide
- Scene management
- Autoload system usage
- Node patterns (timers, signals, lifecycle)
- Common pitfalls and solutions
- Performance tips

---

## 🎯 Quick Lookup by Task

### "I need to modify player stats..."
→ Read [game-systems.md#experience-system](game-systems.md#experience-system)

### "I need to create a new scene..."
→ Read [scene-template.md](scene-template.md) + [responsive-layout.md](responsive-layout.md)

### "I need to add a dialog popup..."
→ Read [popup-system.md](popup-system.md)

### "I need to test my changes..."
→ Read [debug-system.md](debug-system.md)

### "I need to modify the shop..."
→ Read [game-systems.md#shop-system](game-systems.md#shop-system)

### "UI not scaling correctly..."
→ Read [responsive-layout.md](responsive-layout.md)

### "Buttons not clickable..."
→ Read [responsive-layout.md#mouse-filter-management](responsive-layout.md#mouse-filter-management)

### "Timer not working..."
→ Read [game-systems.md#timer-systems](game-systems.md#timer-systems)

### "Victory condition not triggering..."
→ Read [game-systems.md#victory-system](game-systems.md#victory-system)

### "Background image not loading..."
→ Read [scene-template.md#background-auto-loading](scene-template.md#background-auto-loading)

### "Need to display a notification..."
→ Read [notifications.md](notifications.md)

### "Want to change button/UI colors..."
→ Read [theme-system.md](theme-system.md)

---

## 🔑 Keyword → Documentation Matrix

| Keyword Category | Documentation Files |
|-----------------|-------------------|
| **Stats & Experience** | game-systems.md |
| **Shop & Economy** | game-systems.md |
| **Timers & Events** | game-systems.md |
| **Victory & Progression** | game-systems.md |
| **Scene Structure** | scene-template.md, responsive-layout.md |
| **UI Scaling** | responsive-layout.md |
| **Popups & Dialogs** | popup-system.md, scene-template.md |
| **Notifications** | notifications.md, game-systems.md |
| **Theme & Styling** | theme-system.md |
| **Testing & Debugging** | debug-system.md |
| **Godot Patterns** | godot-dev.md |

---

## ⚠️ Critical Rules

### ALWAYS Read Docs When...
1. **Modifying any game system** → Read game-systems.md
2. **Creating/modifying scenes** → Read scene-template.md + responsive-layout.md
3. **Adding popups** → Read popup-system.md
4. **Testing changes** → Read debug-system.md
5. **Unsure about Godot pattern** → Read godot-dev.md

### Key Patterns to Follow
1. **Stats**: Always use `Global.add_stat_exp()`, NEVER modify stats directly
2. **Scene Changes**: Always use `Global.change_scene_with_check()`, NEVER direct change
3. **Notifications**: Always use `Global.show_stat_notification()`
4. **Popups**: ALWAYS put in PopupContainer
5. **Responsive**: ALWAYS call `ResponsiveLayout.apply_to_scene(self)` in `_ready()`
6. **Timers**: Use Global timers, NOT scene-local timers

---

## 📂 File Structure Reference

```
.claude/
├── docs/
│   ├── BIBLE.md              ← YOU ARE HERE (Master Index)
│   ├── game-systems.md       ← Game mechanics reference
│   ├── scene-template.md     ← Scene structure & inheritance
│   ├── responsive-layout.md  ← UI scaling system
│   ├── popup-system.md       ← Modal dialog system
│   ├── notifications.md      ← Notification system
│   ├── theme-system.md       ← Theme & styling
│   ├── debug-system.md       ← Testing & debugging
│   └── godot-dev.md          ← Godot best practices
├── hooks/
│   ├── README.md             ← Hook system documentation
│   ├── bible-check.sh        ← BIBLE check hook (Bash)
│   └── bible-check.ps1       ← BIBLE check hook (PowerShell)
├── skills/
│   └── README.md             ← Reusable procedures
└── commands/
    └── (slash commands)
```

---

## 🔄 Workflow Example

**User**: "Add a strength bonus when player completes a mini-game"

**Your Process**:
1. **Check BIBLE** → Keywords: "strength", "add", "stats"
2. **Read** [game-systems.md#experience-system](game-systems.md#experience-system)
3. **Learn** to use `Global.add_stat_exp("strength", amount)`
4. **Implement** following documented pattern
5. **Test** using procedures from [debug-system.md](debug-system.md)

**Result**: Correctly implemented, following project patterns

---

## 🛠️ Maintenance

**When to Update This Bible**:
- New systems added to codebase
- New documentation files created
- Common tasks/questions emerge
- Workflow patterns change

**Version**: 2.0 (Master Index)
**Last Updated**: 2025-10-29
**Status**: Active - This is THE authoritative documentation index

---

## 📞 Quick Reference Card

**Before ANY task, ask yourself**:

1. ❓ "What keywords does this task involve?"
2. 📖 "Which docs should I read?" (Check keyword table above)
3. ✅ "Have I read the relevant docs?"
4. 🔨 "Am I following documented patterns?"

**If unsure → READ THE BIBLE (this file) → FIND THE DOCS → READ THEM**

---

**Remember**: This BIBLE exists so you always know WHERE to find information. You don't need to memorize everything - you need to know WHERE to look!

**USE THIS FILE CONSTANTLY** ⭐
