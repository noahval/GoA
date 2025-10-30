# Responsive Layout System Reference

**Technical reference for GoA's centralized responsive scaling system**

---

## System Overview

**File**: [responsive_layout.gd](../../responsive_layout.gd)

**Type**: Autoload singleton

**Purpose**: Centralized configuration for responsive UI scaling across ALL scenes

**Key Principle**: Change one constant, update all scenes automatically

---

## Architecture

### Centralized Constants

ALL scaling values in ONE place:

```gdscript
# Portrait mode
const PORTRAIT_ELEMENT_HEIGHT = 40          # Base height for elements
const PORTRAIT_FONT_SCALE = 1.75           # Font multiplier (1.75 = 175%)
const PORTRAIT_TOP_PADDING = 50
const PORTRAIT_BOTTOM_PADDING = 90
const PORTRAIT_SEPARATION_RATIO = 0.5      # Spacing as % of scaled height

# Landscape mode
const LANDSCAPE_ELEMENT_HEIGHT = 40        # Universal height for all elements
const LANDSCAPE_CONTAINER_HEIGHT = 700     # Height of centered HBoxContainer

# Shared
const NOTIFICATION_BAR_HEIGHT = 100        # Height of notification bar
const LEFT_COLUMN_WIDTH = 220
const RIGHT_COLUMN_WIDTH = 260
```

### Auto-Scaling Formula (Portrait)

**Panel Height** = `PORTRAIT_ELEMENT_HEIGHT * PORTRAIT_FONT_SCALE`
- Default: 40 * 1.75 = **70px**

**Separation** = `Panel Height * PORTRAIT_SEPARATION_RATIO`
- Default: 70 * 0.5 = **35px**

**Why auto-scale**: Prevents overlapping when font size increases

---

## Core Function

### `apply_to_scene(scene_root: Control) -> void`

**Call in every scene's `_ready()`**:

```gdscript
func _ready():
    ResponsiveLayout.apply_to_scene(self)
```

**What it does**:
1. Detects portrait vs landscape (based on viewport aspect ratio)
2. Reparents containers (HBox → VBox or vice versa)
3. Scales buttons, panels, fonts
4. Sets mouse_filter = PASS on Background and containers
5. Auto-loads background image (based on root node name)
6. Adds settings overlay
7. Constrains popups to available play area
8. Hides PopupContainer when empty

**CRITICAL**: Uses `call_deferred` to wait for scene tree to be fully ready (essential for inherited scenes)

---

## Orientation Detection

```gdscript
static func is_portrait_mode(viewport: Viewport) -> bool:
    var size = viewport.get_visible_rect().size
    return size.y > size.x  # Portrait if height > width
```

**Portrait**: Viewport height > width
**Landscape**: Viewport width > height

---

## Layout Transformations

### Landscape → Portrait

**Reparenting**:
- `LeftVBox` → `VBoxContainer/TopVBox`
- `CenterArea` → `VBoxContainer/MiddleArea`
- `RightVBox` → `VBoxContainer/BottomVBox/RightVBox`
- `NotificationBar` → `VBoxContainer/NotificationBar` (between TopVBox and MiddleArea)

**Scaling**:
- All buttons: `custom_minimum_size.y = PORTRAIT_ELEMENT_HEIGHT * PORTRAIT_FONT_SCALE`
- All panels: `custom_minimum_size.y = PORTRAIT_ELEMENT_HEIGHT * PORTRAIT_FONT_SCALE`
- All button fonts: `font_size *= PORTRAIT_FONT_SCALE`
- All label fonts: `font_size *= PORTRAIT_FONT_SCALE`
- VBox separation: `Panel Height * PORTRAIT_SEPARATION_RATIO`

**Visibility**:
- HBoxContainer: hidden
- VBoxContainer: shown

### Portrait → Landscape

**Reparenting** (back to original):
- `TopVBox/LeftVBox` → `HBoxContainer/LeftVBox`
- `MiddleArea/CenterArea` → `HBoxContainer/CenterArea`
- `BottomVBox/RightVBox` → `HBoxContainer/RightVBox`
- `NotificationBar` → Root (anchored to bottom)

**Scaling Reset**:
- All elements: `custom_minimum_size.y = LANDSCAPE_ELEMENT_HEIGHT`
- All fonts: Reset to default theme size (25px)
- HBox separation: 20px

**Visibility**:
- HBoxContainer: shown
- VBoxContainer: hidden

---

## Signal Preservation

**Uses Godot 4's `reparent()` method**

**Benefits**:
- All signal connections preserved automatically
- No manual reconnection needed
- Buttons keep working after orientation changes

**Example**:
```gdscript
# .tscn connection:
[connection signal="pressed" from="HBoxContainer/RightVBox/MyButton" to="." method="_on_button_pressed"]

# After portrait switch:
# Button path changes to: VBoxContainer/BottomVBox/RightVBox/MyButton
# But signal connection STILL WORKS ✅
```

---

## Background Auto-Loading

### How It Works

1. Gets root node name (e.g., "Bar", "CoppersmithCarriage")
2. Converts to snake_case (e.g., "bar", "coppersmith_carriage")
3. Tries to load `res://level1/<snake_case_name>.jpg`
4. Sets as Background texture if successful

### Requirements

**Root node name**: MUST be unique (NOT "SceneRoot")

**Image file**: `level1/<scene_name>.jpg` where scene_name is snake_case version

**Examples**:
- "Bar" → `level1/bar.jpg`
- "CoppersmithCarriage" → `level1/coppersmith_carriage.jpg`
- "LoadingScreen" → `level1/loading_screen.jpg`

**Debug**: Check console for messages:
```
ResponsiveLayout: Background texture: null
ResponsiveLayout: Attempting to auto-load background...
ResponsiveLayout: Trying to load background from: res://level1/bar.jpg
ResponsiveLayout: Successfully auto-loaded background texture!
```

---

## Mouse Filter Management

### Problem

Background TextureRect is full-screen and blocks ALL mouse events by default.

### Solution

`apply_to_scene()` automatically sets `mouse_filter = PASS (2)` on:
- Background
- HBoxContainer
- VBoxContainer
- LeftVBox
- RightVBox
- CenterArea
- MiddleArea
- TopVBox
- BottomVBox

**Result**: Buttons clickable in both orientations

---

## Popup Constraint System

### Problem

Popups can overflow and overlap side menus if not constrained.

### Solution

`apply_to_scene()` finds all popups in PopupContainer and constrains width:

**Landscape**:
```gdscript
max_width = min(600, center_area_width - 40)  # 40px margins
```

**Portrait**:
```gdscript
max_width = viewport_width * 0.9  # 90% of screen
```

**Result**: Popups never overlap menus, always fit in play area

---

## Settings Overlay Auto-Add

**Automatically instantiates** [settings_overlay.tscn](../../settings_overlay.tscn) if not already present

**Components**:
- 30x30px orange gear button (bottom-right corner)
- Centered settings panel
- Dev Speed Mode toggle

**No manual setup needed** - just call `apply_to_scene()`

---

## Configuration Constants Reference

| Constant | Default | Purpose | Effect of Changing |
|----------|---------|---------|-------------------|
| `PORTRAIT_ELEMENT_HEIGHT` | 40 | Base element height | Panels scale to this × PORTRAIT_FONT_SCALE |
| `PORTRAIT_FONT_SCALE` | 1.75 | Font multiplier | Affects fonts AND panel heights |
| `PORTRAIT_SEPARATION_RATIO` | 0.5 | Spacing ratio | Auto-calculates as 50% of panel height |
| `PORTRAIT_TOP_PADDING` | 50 | Top padding (px) | Vertical space at top in portrait |
| `PORTRAIT_BOTTOM_PADDING` | 90 | Bottom padding (px) | Vertical space at bottom in portrait |
| `LANDSCAPE_ELEMENT_HEIGHT` | 40 | Universal height | All buttons/panels in landscape |
| `LANDSCAPE_CONTAINER_HEIGHT` | 700 | HBox height (px) | Vertical centering space in landscape |
| `NOTIFICATION_BAR_HEIGHT` | 100 | NotificationBar (px) | Height of notification area |
| `LEFT_COLUMN_WIDTH` | 220 | Left menu width (px) | Info panel container width |
| `RIGHT_COLUMN_WIDTH` | 260 | Right menu width (px) | Button menu container width |

---

## Making Global Changes

### Example 1: Increase Portrait UI Size

**Change**:
```gdscript
const PORTRAIT_ELEMENT_HEIGHT = 50   # was 40
const PORTRAIT_FONT_SCALE = 2.0      # was 1.75
```

**Result**:
- Panel height: 50 * 2.0 = **100px** (was 70px)
- Font size: 25 * 2.0 = **50px** (was 43.75px)
- Separation: 100 * 0.5 = **50px** (was 35px)

**Applies to**: ALL scenes automatically

### Example 2: Adjust Landscape Container Height

**Change**:
```gdscript
const LANDSCAPE_CONTAINER_HEIGHT = 900  # was 700
```

**Result**:
- HBoxContainer vertically centered in 900px area instead of 700px
- More room for tall menus

### Example 3: Reduce Portrait Spacing

**Change**:
```gdscript
const PORTRAIT_SEPARATION_RATIO = 0.3  # was 0.5
```

**Result**:
- Separation: Panel Height * 0.3 = **21px** (was 35px)
- Tighter UI, more items visible on screen

---

## Common Issues

### Issue: Changes don't appear
**Cause**: Autoload scripts cached

**Solution**: Restart Godot

### Issue: Scene doesn't scale
**Causes**:
1. Didn't call `apply_to_scene(self)` in `_ready()`
2. Scene structure doesn't match requirements
3. Node names wrong (not LeftVBox, RightVBox, etc.)

**Debug**: Check console for warnings about missing nodes

### Issue: Buttons not clickable
**Cause**: Background mouse_filter not PASS

**Solution**: `apply_to_scene()` fixes automatically (if called)

### Issue: Signals broken after orientation change
**Shouldn't happen**: Using `reparent()` preserves signals

**If it does**: Check using Godot 4 signal syntax

---

## Required Scene Structure

For ResponsiveLayout to work, scenes MUST have:

```
SceneRoot (Control)
├── Background (TextureRect)
├── HBoxContainer
│   ├── LeftVBox
│   ├── CenterArea
│   └── RightVBox
├── VBoxContainer
│   ├── TopPadding
│   ├── TopVBox
│   ├── MiddleArea
│   ├── BottomVBox
│   └── BottomPadding
├── NotificationBar (VBoxContainer)
├── PopupContainer
└── SettingsOverlay (optional - auto-added)
```

**Best Practice**: Use [level1/scene_template.tscn](../../level1/scene_template.tscn) as base - structure already correct

---

## When Implementing/Modifying Scenes

**Do**:
- ✅ Call `ResponsiveLayout.apply_to_scene(self)` in `_ready()`
- ✅ Use scene_template.tscn as base
- ✅ Test both portrait and landscape
- ✅ Create matching background image file
- ✅ Trust the system (don't write custom scaling)

**Don't**:
- ❌ Write custom `apply_mobile_scaling()` functions
- ❌ Manually set mouse_filter (system handles it)
- ❌ Call `apply_to_scene()` multiple times
- ❌ Modify ResponsiveLayout constants at runtime
- ❌ Use non-standard node names

---

## Testing Checklist

When working with responsive layout:
1. [ ] Called `apply_to_scene(self)` in `_ready()`?
2. [ ] Scene inherits from scene_template.tscn?
3. [ ] Background image exists in level1/?
4. [ ] Root node has unique name?
5. [ ] Tested in landscape mode?
6. [ ] Tested in portrait mode?
7. [ ] Buttons clickable in both orientations?
8. [ ] Fonts scale correctly?
9. [ ] No UI overlapping?
10. [ ] Settings overlay appears?

---

## Utility Functions

```gdscript
# Check if portrait
if ResponsiveLayout.is_portrait_mode(get_viewport()):
    # Portrait-specific logic

# Get current font scale (1.0 or 1.75)
var scale = ResponsiveLayout.get_font_scale(get_viewport())
```

---

**Related Docs**:
- [scene-template.md](scene-template.md) - Scene structure
- [popup-system.md](popup-system.md) - Popup constraints
- [godot-dev.md](godot-dev.md) - Godot patterns

**Version**: 2.0 (Claude-focused)
**Last Updated**: 2025-10-29
