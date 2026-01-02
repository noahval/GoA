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

**Portrait**: Containers reparented to VBoxContainer, elements scaled by `PORTRAIT_FONT_SCALE`, HBox hidden
**Landscape**: Containers in HBoxContainer, standard sizing (40px), VBox hidden

Key reparenting: LeftVBox/CenterArea/RightVBox move between HBox and VBox structures. NotificationBar moves between root and VBox.

---

## Signal Preservation

Uses Godot 4's `reparent()` - all signal connections preserved automatically during orientation changes. No manual reconnection needed.

---

## Background Auto-Loading

Automatically loads background image based on root node name:
1. Converts root name to snake_case (e.g., "Bar" → "bar")
2. Loads `level1/<snake_case_name>.jpg`
3. Sets as Background texture

**Requirements**: Root node must have unique name (not "SceneRoot"), image must exist in level1/

---

## Mouse Filter Management

`apply_to_scene()` sets `mouse_filter = PASS` on Background and all containers (HBox, VBox, LeftVBox, RightVBox, CenterArea, etc.) to prevent full-screen background from blocking button clicks.

---

## Popup Constraint System

`apply_to_scene()` constrains popup width to prevent overlap with side menus:
- **Landscape**: `min(600, center_area_width - 40)`
- **Portrait**: `viewport_width * 0.9`

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

### Portrait Mode
| Constant | Default | Purpose | Effect of Changing |
|----------|---------|---------|-------------------|
| `PORTRAIT_ELEMENT_HEIGHT` | 30 | Base element height | Panels scale to this × PORTRAIT_FONT_SCALE |
| `PORTRAIT_FONT_SCALE` | 1.4 | Font multiplier | Affects fonts AND panel heights |
| `PORTRAIT_SEPARATION_RATIO` | 0.5 | Spacing ratio | Auto-calculates as 50% of panel height |
| `PORTRAIT_TOP_PADDING` | 60 | Top padding (px) | Vertical space at top in portrait |
| `PORTRAIT_BOTTOM_PADDING` | 60 | Bottom padding (px) | Vertical space at bottom in portrait |

### Landscape Mode - Legacy Fixed Widths
| Constant | Default | Purpose | Effect of Changing |
|----------|---------|---------|-------------------|
| `LANDSCAPE_ELEMENT_HEIGHT` | 40 | Universal height | All buttons/panels in landscape |
| `LANDSCAPE_CONTAINER_HEIGHT` | 700 | HBox height (px) | Vertical centering space in landscape |
| `NOTIFICATION_BAR_HEIGHT` | 100 | NotificationBar (px) | Height of notification area |
| `LEFT_COLUMN_WIDTH` | 220 | Left menu width (px) | Legacy fixed width (used when dynamic widths disabled) |
| `RIGHT_COLUMN_WIDTH` | 260 | Right menu width (px) | Legacy fixed width (used when dynamic widths disabled) |

### Landscape Mode - Dynamic Responsive Widths
| Constant | Default | Purpose | Effect of Changing |
|----------|---------|---------|-------------------|
| `LANDSCAPE_LEFT_WIDTH_PERCENT` | 0.25 | Left menu width % | Percentage of screen width for left menu |
| `LANDSCAPE_CENTER_WIDTH_PERCENT` | 0.50 | Center area width % | Percentage of screen width for center |
| `LANDSCAPE_RIGHT_WIDTH_PERCENT` | 0.25 | Right menu width % | Percentage of screen width for right menu |
| `LANDSCAPE_EDGE_PADDING` | 25 | Edge padding (px) | Padding on left and right screen edges |
| `LANDSCAPE_ENABLE_DYNAMIC_WIDTHS` | true | Enable dynamic widths | Use percentages vs fixed widths |
| `LANDSCAPE_ENABLE_FONT_SCALING` | true | Enable font scaling | Scale fonts at higher resolutions |
| `LANDSCAPE_BASE_RESOLUTION` | 1438 | Base resolution (px) | Reference width for 1:1 font scaling |
| `LANDSCAPE_MIN_FONT_SCALE` | 1.0 | Minimum font scale | Font scale at base resolution |
| `LANDSCAPE_MAX_FONT_SCALE` | 2.0 | Maximum font scale | Cap for very high resolutions |

---

## Making Global Changes

Change constants in [responsive_layout.gd](../../responsive_layout.gd) to affect ALL scenes:

### Portrait Mode
- Increase `PORTRAIT_FONT_SCALE` → larger fonts + panels
- Adjust `PORTRAIT_SEPARATION_RATIO` → tighter/looser spacing

### Landscape Mode
- Adjust `LANDSCAPE_LEFT_WIDTH_PERCENT`, `LANDSCAPE_CENTER_WIDTH_PERCENT`, `LANDSCAPE_RIGHT_WIDTH_PERCENT` → change menu proportions (must sum to 1.0)
- Change `LANDSCAPE_EDGE_PADDING` → adjust padding from screen edges
- Set `LANDSCAPE_ENABLE_DYNAMIC_WIDTHS = false` → revert to fixed pixel widths
- Set `LANDSCAPE_ENABLE_FONT_SCALING = false` → disable font scaling at higher resolutions
- Adjust `LANDSCAPE_BASE_RESOLUTION` → change reference resolution for font scaling
- Adjust `LANDSCAPE_MAX_FONT_SCALE` → cap maximum font size at very high resolutions

**IMPORTANT**: Restart Godot after changing constants (autoload scripts are cached).

---

## Common Issues

- **Changes don't appear**: Restart Godot (autoload scripts cached)
- **Scene doesn't scale**: Call `apply_to_scene(self)` in `_ready()`, verify scene structure matches requirements
- **Buttons not clickable**: `apply_to_scene()` sets mouse_filter automatically
- **Signals broken**: Shouldn't happen with `reparent()` - check Godot 4 signal syntax

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

- [ ] Called `apply_to_scene(self)` in `_ready()`, scene inherits from scene_template.tscn, background image exists
- [ ] Tested both landscape & portrait: buttons clickable, fonts scale correctly, no overlapping

---

## Utility Functions

`ResponsiveLayout.is_portrait_mode(viewport)` - Returns true if portrait
`ResponsiveLayout.get_font_scale(viewport)` - Returns current font scale multiplier (1.0 landscape, 1.75 portrait)
`ResponsiveLayout.get_scaled_font_size(viewport, base_size)` - Returns scaled font size in pixels

### get_scaled_font_size Usage

For dynamically created UI elements that need consistent font scaling:

```gdscript
# Get scaled font size (base 25px)
var font_size = ResponsiveLayout.get_scaled_font_size(get_viewport(), 25)
label.add_theme_font_size_override("font_size", font_size)

# At 720p landscape: 25px
# At 1080p landscape: ~37px (1.5x)
# At 720p portrait: 44px (1.75x)
# At 1080p portrait: ~65px (1.5x * 1.75x)
```

**Implementation** (add to responsive_layout.gd):
```gdscript
static func get_scaled_font_size(viewport: Viewport, base_size: int = 25) -> int:
    var scale = get_font_scale(viewport)
    return int(base_size * scale)
```

---

**Related Docs**:
- [scene-template.md](scene-template.md) - Scene structure
- [popup-system.md](popup-system.md) - Popup constraints
- [godot-dev.md](godot-dev.md) - Godot patterns

**Version**: 2.0 (Claude-focused)
**Last Updated**: 2025-10-29
