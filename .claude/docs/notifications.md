# Notification System Reference

**Complete technical reference for GoA's dynamic notification system**

---

## System Overview

**Location**: [global.gd](../../global.gd) lines 156-322

**Purpose**: Display temporary translucent notifications that auto-stack and auto-remove

**Key Characteristics**:
- Dynamic panel creation (no pre-existing UI elements)
- VBoxContainer stacking (automatic vertical arrangement)
- Dynamic auto-removal (1 sec base + 45ms per character)
- Responsive scaling (portrait/landscape)
- Translucent dark backgrounds
- White centered text with word-wrap

---

## Architecture

### Core Components

#### 1. NotificationBar Container
**Type**: VBoxContainer
**Location in Scene Tree**:
- **Landscape**: Direct child of SceneRoot, anchored to bottom (100px height)
- **Portrait**: Reparented into VBoxContainer by ResponsiveLayout (between TopVBox and MiddleArea)

**Purpose**: Container where notification panels are dynamically added

**From [scene_template.tscn](../../level1/scene_template.tscn)**: Present in all scenes that inherit from template

#### 2. Active Notifications Tracking
```gdscript
var active_notifications: Array = []
```

**Type**: Array of Dictionaries

**Structure**:
```gdscript
{
    "panel": Panel,           # The notification panel node
    "label": Label,           # The text label inside panel
    "timer": Timer,           # 3-second one-shot timer
    "container": Node         # Reference to NotificationBar
}
```

**Purpose**: Track all active notifications for cleanup

---

## The Notification Flow

### Step 1: User/System Triggers Notification

**Via stat level-up** (automatic):
```gdscript
# In global.gd stat setters:
var strength = 1:
    set(value):
        if is_node_ready() and floor(value) > floor(strength):
            show_stat_notification("You feel stronger")  # ← Triggers notification
        strength = value
```

**Via explicit call**:
```gdscript
Global.show_stat_notification("You've been caught!")
Global.show_stat_notification("A voice whispers in your mind...")
```

### Step 2: Find NotificationBar Container

**Function**: `_find_notification_bar() -> Node`

**Logic** (lines 269-291):
```gdscript
func _find_notification_bar() -> Node:
    var current_scene = get_tree().current_scene

    # Try landscape location (direct child of root)
    var notification_bar = current_scene.get_node_or_null("NotificationBar")
    if notification_bar:
        return notification_bar

    # Try portrait location (reparented by ResponsiveLayout)
    notification_bar = current_scene.get_node_or_null("VBoxContainer/NotificationBar")
    if notification_bar:
        return notification_bar

    return null  # Not found
```

**Handles Both Orientations**:
- Landscape: `NotificationBar` (root child)
- Portrait: `VBoxContainer/NotificationBar` (reparented)

**Fail-Safe**: Prints warning if NotificationBar not found in scene

### Step 3: Create Notification Panel

**Function**: `show_stat_notification(message: String)`

**Panel Creation** (lines 197-219):
```gdscript
# Create panel with custom minimum height
var notification_panel = Panel.new()
notification_panel.custom_minimum_size = Vector2(0, ResponsiveLayout.LANDSCAPE_ELEMENT_HEIGHT)  # 40px

# Create translucent dark background style
var style_box = StyleBoxFlat.new()
style_box.bg_color = Color(0.15, 0.15, 0.15, 0.4)  # Dark grey, 40% opacity
style_box.corner_radius_top_left = 8
style_box.corner_radius_top_right = 8
style_box.corner_radius_bottom_left = 8
style_box.corner_radius_bottom_right = 8

# Content margins (inner padding)
style_box.content_margin_top = 5
style_box.content_margin_bottom = 5
style_box.content_margin_left = 10
style_box.content_margin_right = 10

# Expand margins (outer spacing between notifications)
style_box.expand_margin_top = 3
style_box.expand_margin_bottom = 3

notification_panel.add_theme_stylebox_override("panel", style_box)
```

**Key Properties**:
- **Background**: Dark grey (15% brightness), 40% opacity
- **Corners**: 8px rounded on all corners
- **Content margins**: 5px top/bottom, 10px left/right (inner padding)
- **Expand margins**: 3px top/bottom (outer spacing between stacked notifications)
- **Initial height**: 40px (landscape default)

### Step 4: Create Label Inside Panel

**Label Creation** (lines 221-240):
```gdscript
var notification_label = Label.new()
notification_label.text = message
notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
notification_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
notification_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))  # White
notification_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

# Fill the panel (anchors to all edges)
notification_label.anchor_left = 0
notification_label.anchor_right = 1
notification_label.anchor_top = 0
notification_label.anchor_bottom = 1
notification_label.offset_left = 0
notification_label.offset_right = 0
notification_label.offset_top = 0
notification_label.offset_bottom = 0

notification_panel.add_child(notification_label)
```

**Key Properties**:
- **Text**: White (full brightness, full opacity)
- **Alignment**: Centered both horizontally and vertically
- **Word wrap**: Smart wrapping enabled
- **Anchoring**: Fills entire panel (respects content margins from StyleBoxFlat)

### Step 5: Create Auto-Removal Timer

**Timer Creation** (lines 242-246):
```gdscript
var notification_timer = Timer.new()
notification_timer.one_shot = true
notification_timer.wait_time = 1.0 + (len(message) * 0.045)  # 1 sec base + 45ms per character
add_child(notification_timer)  # Child of Global autoload
```

**Properties**:
- **One-shot**: Only fires once
- **Duration**: 1 second base + 45ms per character (e.g., "You feel stronger" = 17 chars = 1.765 seconds)
- **Parent**: Global autoload (persists across scene changes)

### Step 6: Track Notification

**Tracking** (lines 248-255):
```gdscript
var notification_data = {
    "panel": notification_panel,
    "label": notification_label,
    "timer": notification_timer,
    "container": notification_container
}
active_notifications.append(notification_data)

# Connect timer to cleanup function
notification_timer.timeout.connect(func(): _remove_notification(notification_data))
```

**Purpose**: Keep references for cleanup when timer expires

### Step 7: Add to Scene & Start Timer

**Insertion** (lines 260-267):
```gdscript
# Add panel to NotificationBar
notification_container.add_child(notification_panel)

# Apply responsive scaling if in portrait mode
_apply_notification_scaling(notification_panel, notification_label)

# Start 3-second countdown
notification_timer.start()
```

**VBoxContainer Auto-Stacking**: NotificationBar (a VBoxContainer) automatically arranges children vertically with separation

### Step 8: Responsive Scaling (Portrait Only)

**Function**: `_apply_notification_scaling(notification_panel: Panel, notification_label: Label)`

**Logic** (lines 293-309):
```gdscript
func _apply_notification_scaling(notification_panel: Panel, notification_label: Label):
    var viewport = get_viewport()
    var viewport_size = viewport.get_visible_rect().size
    var is_portrait = viewport_size.y > viewport_size.x

    if is_portrait:
        # Scale panel height
        var scaled_height = ResponsiveLayout.PORTRAIT_ELEMENT_HEIGHT * ResponsiveLayout.PORTRAIT_FONT_SCALE
        # Default: 40 * 1.75 = 70px
        notification_panel.custom_minimum_size = Vector2(0, scaled_height)

        # Scale font size
        var default_font_size = 25  # From theme
        notification_label.add_theme_font_size_override(
            "font_size",
            int(default_font_size * ResponsiveLayout.PORTRAIT_FONT_SCALE)
        )
        # Default: 25 * 1.75 = 43.75 → 43px
```

**Portrait Adjustments**:
- **Panel height**: 40px → 70px (1.75x)
- **Font size**: 25px → 43px (1.75x)

**Landscape**: No changes (uses defaults)

### Step 9: Auto-Removal After Dynamic Duration

**Function**: `_remove_notification(notification_data: Dictionary)`

**Logic** (lines 311-322):
```gdscript
func _remove_notification(notification_data: Dictionary):
    # Remove from tracking array
    var index = active_notifications.find(notification_data)
    if index != -1:
        active_notifications.remove_at(index)

    # Free panel and timer from memory
    if notification_data.panel:
        notification_data.panel.queue_free()  # Removes from scene tree + frees memory
    if notification_data.timer:
        notification_data.timer.queue_free()

    # Note: No manual repositioning needed
    # VBoxContainer automatically adjusts remaining children
```

**Cleanup**:
1. Remove from `active_notifications` array
2. Queue panel for deletion (removes from NotificationBar)
3. Queue timer for deletion
4. VBoxContainer automatically repositions remaining notifications

---

## Visual Appearance

### Landscape Mode

```
┌─────────────────────────────────────────┐
│ Game Content Area                        │
│                                          │
│                                          │
└──────────────────────────────────────────┘
┌──────────────────────────────────────────┐  ← NotificationBar (bottom)
│ ┌──────────────────────────────────────┐ │
│ │ You feel stronger                    │ │  ← Notification 1
│ └──────────────────────────────────────┘ │
│ ┌──────────────────────────────────────┐ │
│ │ A voice whispers...                  │ │  ← Notification 2
│ └──────────────────────────────────────┘ │
└──────────────────────────────────────────┘
```

**Dimensions**:
- NotificationBar: Full width, 100px height, bottom of screen
- Each notification: Full width, 40px height, 3px separation

### Portrait Mode

```
┌──────────────────┐
│ Top Menu         │
├──────────────────┤  ← NotificationBar (between menus)
│ ┌──────────────┐ │
│ │ You feel     │ │  ← Notification 1 (70px tall)
│ │ stronger     │ │
│ └──────────────┘ │
│ ┌──────────────┐ │
│ │ A voice      │ │  ← Notification 2 (70px tall)
│ │ whispers...  │ │
│ └──────────────┘ │
├──────────────────┤
│ Middle Area      │
│ (Gameplay)       │
├──────────────────┤
│ Bottom Menu      │
└──────────────────┘
```

**Dimensions**:
- NotificationBar: Full width, auto height, between top menu and middle area
- Each notification: Full width, 70px height (1.75x scaled)
- Font: 43px (1.75x scaled)

---

## Common Usage Patterns

### Pattern 1: Stat Level-Up (Automatic)

**Triggered by**: Experience system

**Example**:
```gdscript
# In global.gd
Global.add_stat_exp("strength", 150)  # Player gains 150 strength XP

# If this causes level up (e.g., 1 → 2):
# Stat setter automatically calls:
show_stat_notification("You feel stronger")
```

**Messages**:
- Strength: "You feel stronger"
- Constitution: "You feel more resilient"
- Dexterity: "You feel more precise"
- Wisdom: "You feel more introspective"
- Intelligence: "You feel smarter"
- Charisma: "You feel you understand people more"

### Pattern 2: Game Events

**Triggered by**: Explicit calls in game logic

**Examples**:
```gdscript
# Get caught mechanic
Global.show_stat_notification("You've been caught, your coal and coins have been seized")

# Whisper event
Global.show_stat_notification("A voice whispers in your mind, pleading for your help")

# Developer testing
Global.show_stat_notification("developer notification: coins")
```

### Pattern 3: Custom Notifications

**Usage in any scene**:
```gdscript
func _on_achievement_unlocked():
    Global.show_stat_notification("Achievement unlocked: Coal Baron!")

func _on_item_acquired():
    Global.show_stat_notification("You found a mysterious key")
```

---

## Technical Specifications

### Notification Dimensions

| Mode | Panel Height | Font Size | Separation |
|------|-------------|-----------|------------|
| **Landscape** | 40px | 25px | 6px (3px expand top + 3px expand bottom) |
| **Portrait** | 70px | 43px | ~10px (automatically scaled) |

### Colors

| Element | Color | Opacity |
|---------|-------|---------|
| Background | Dark grey (0.15, 0.15, 0.15) | 40% |
| Text | White (1, 1, 1) | 100% |

### Timing

| Event | Duration |
|-------|----------|
| Display time | Dynamic: 1 second base + 45ms per character |
| Fade in | None (instant) |
| Fade out | None (instant removal) |

### Z-Index / Layering

NotificationBar is a direct child of SceneRoot:
- **Below** PopupContainer (z-index 100)
- **Below** SettingsOverlay (z-index 200)
- **Above** game content

**Result**: Notifications visible but don't block popups or settings

---

## Integration with ResponsiveLayout

### Automatic Reparenting

**ResponsiveLayout.apply_to_scene()** moves NotificationBar:

**Landscape**:
```gdscript
# NotificationBar at: SceneRoot/NotificationBar
notification_bar.reparent(scene_root)
```

**Portrait**:
```gdscript
# NotificationBar at: SceneRoot/VBoxContainer/NotificationBar
notification_bar.reparent(vbox_container)
```

**Signal Preservation**: `reparent()` method preserves all properties and children

### Finding NotificationBar

**Always use** `_find_notification_bar()` instead of hardcoded paths:

```gdscript
# Good - works in both orientations
var notification_bar = _find_notification_bar()

# Bad - only works in landscape
var notification_bar = get_node("NotificationBar")
```

---

## Common Issues & Solutions

### Issue: Notification doesn't appear

**Causes**:
1. NotificationBar not in scene (scene doesn't inherit from scene_template.tscn)
2. ResponsiveLayout.apply_to_scene() not called
3. NotificationBar got deleted/hidden

**Debug**:
```gdscript
# Check console for warning:
"Warning: No NotificationBar found in current scene"
```

**Solution**: Ensure scene inherits from scene_template.tscn and calls ResponsiveLayout.apply_to_scene()

### Issue: Notifications overlap

**Cause**: VBoxContainer separation not set

**Solution**: Verify NotificationBar is a VBoxContainer with appropriate separation (handled by template)

### Issue: Text too large/small

**Cause**: ResponsiveLayout constants misconfigured

**Solution**: Check [responsive_layout.gd](../../responsive_layout.gd):
```gdscript
const PORTRAIT_FONT_SCALE = 1.75  # Adjust this value
```

### Issue: Notifications don't auto-remove

**Cause**: Timer not starting or not connected

**Debug**: Check if `notification_timer.start()` is called (line 267)

**Solution**: Ensure timer creation and connection logic intact

---

## When Implementing/Modifying Notifications

### Do:
- ✅ Use `Global.show_stat_notification(message)` for all notifications
- ✅ Keep messages concise (they auto-wrap but short is better)
- ✅ Test in both landscape and portrait modes
- ✅ Ensure scene has NotificationBar (use scene_template.tscn)
- ✅ Call ResponsiveLayout.apply_to_scene() in scene _ready()

### Don't:
- ❌ Create notifications manually (bypassing show_stat_notification)
- ❌ Hardcode NotificationBar paths (use _find_notification_bar())
- ❌ Modify notification styling in individual scenes
- ❌ Try to position notifications manually
- ❌ Create very long messages (word-wrap helps but 2-3 lines max recommended)

---

## Customization Points

### Notification Duration

**Location**: global.gd line 186
```gdscript
notification_timer.wait_time = 1.0 + (len(message) * 0.045)  # 1 sec base + 45ms per character
# Change 1.0 to adjust base time or 0.045 to adjust per-character time
```

### Background Color/Opacity

**Location**: global.gd lines 203
```gdscript
style_box.bg_color = Color(0.15, 0.15, 0.15, 0.4)
# Color(R, G, B, Alpha)
# R, G, B: 0.0 to 1.0 (brightness)
# Alpha: 0.0 (invisible) to 1.0 (opaque)
```

**Examples**:
- Darker: `Color(0.1, 0.1, 0.1, 0.5)`
- More opaque: `Color(0.15, 0.15, 0.15, 0.6)`
- Blue tint: `Color(0.1, 0.1, 0.2, 0.4)`

### Corner Radius

**Location**: global.gd lines 204-207
```gdscript
style_box.corner_radius_top_left = 8     # Change to 0 for sharp corners
style_box.corner_radius_top_right = 8    # Or increase for rounder
style_box.corner_radius_bottom_left = 8
style_box.corner_radius_bottom_right = 8
```

### Spacing Between Notifications

**Location**: global.gd lines 216-217
```gdscript
style_box.expand_margin_top = 3     # Increase for more space
style_box.expand_margin_bottom = 3
```

---

## Testing Checklist

When working with notifications:
1. [ ] Scene inherits from scene_template.tscn?
2. [ ] ResponsiveLayout.apply_to_scene() called?
3. [ ] Notification appears in landscape mode?
4. [ ] Notification appears in portrait mode?
5. [ ] Notification auto-removes after 3 seconds?
6. [ ] Multiple notifications stack correctly?
7. [ ] Text wraps properly for long messages?
8. [ ] Font size appropriate in both modes?
9. [ ] Notifications don't block other UI?
10. [ ] Cleanup happens correctly (no memory leaks)?

---

## Performance Considerations

### Memory Management

**Good**: Notifications auto-cleanup via `queue_free()`

**Each notification creates**:
- 1 Panel node
- 1 Label node
- 1 Timer node
- 1 Dictionary in active_notifications array

**All freed after 3 seconds** - no memory leaks

### Scene Changes

**Timers are children of Global autoload** → Persist across scenes

**Panels are children of NotificationBar** → Destroyed when scene changes

**Result**: Timers clean up panels even if scene changes mid-notification

---

**Related Docs**:
- [game-systems.md](game-systems.md) - Experience system that triggers notifications
- [scene-template.md](scene-template.md) - NotificationBar container location
- [responsive-layout.md](responsive-layout.md) - Auto-reparenting and scaling

**Version**: 1.0
**Last Updated**: 2025-10-29
