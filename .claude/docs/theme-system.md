# Theme System Reference

**Complete technical reference for GoA's centralized theming system**

---

## System Overview

**File**: [default_theme.tres](../../default_theme.tres)

**Type**: Godot Theme Resource

**Purpose**: Centralized visual styling for ALL UI elements across the project

**Key Benefit**: Change appearance globally by modifying one file

---

## Architecture

### Theme Structure

```
default_theme.tres
├── Global Settings
│   └── default_font_size = 25
├── Base Styles (Standard UI)
│   ├── Button (normal/hover/pressed)
│   ├── Label (normal)
│   ├── Panel (panel)
│   └── ProgressBar (background/fill)
└── Theme Variations (Specialized)
    ├── SuspicionProgressBar → Red fill variant
    ├── StyledPopup → Popup panel style
    └── PopupButton → Outlined button for popups
```

---

## Global Settings

### Default Font Size

```gdscript
default_font_size = 25
```

**Used by**: All UI elements unless overridden

**Responsive Scaling**:
- Landscape: 25px (default)
- Portrait: 25px * 1.75 = 43px (scaled by ResponsiveLayout)

---

## Base Styles

### Button

**Normal State** (`StyleBoxFlat_button_normal`):
```
background: Color(0.25, 0.25, 0.25, 0.3)  # Dark grey, 30% opacity
corner_radius: 3px (all corners)
content_margin: 8px left/right, 4px top/bottom
font_color: White (1, 1, 1, 1)
```

**Hover State** (`StyleBoxFlat_button_hover`):
```
background: Color(0.35, 0.35, 0.35, 0.3)  # Lighter grey, 30% opacity
corner_radius: 3px (all corners)
content_margin: 8px left/right, 4px top/bottom
font_hover_color: Light yellow (1, 1, 0.8, 1)
```

**Pressed State**:
```
font_pressed_color: Light grey (0.9, 0.9, 0.9, 1)
```

**Visual States**:
- Normal: Dark grey, white text
- Hover: Lighter grey, yellow-white text
- Pressed: Same background, slightly dimmed text

### Label

**Normal State** (`StyleBoxFlat_label`):
```
background: Color(0.25, 0.25, 0.25, 0.3)  # Dark grey, 30% opacity
corner_radius: 3px (all corners)
content_margin: 8px left/right, 4px top/bottom
font_color: White (1, 1, 1, 1)
line_spacing: 2px
```

**Usage**: Info panels, stat displays, counters

### Panel

**Normal State** (`StyleBoxFlat_panel`):
```
background: Color(0.5, 0.5, 0.5, 0.3)  # Medium grey, 30% opacity
corner_radius: 4px (all corners)
```

**Usage**: Container panels in LeftVBox/RightVBox/TopVBox/BottomVBox

### ProgressBar

**Background** (`StyleBoxFlat_progress_bg`):
```
background: Color(0.2, 0.2, 0.2, 0)  # Transparent dark grey
content_margin: 4px top/bottom
```

**Fill - Standard** (`StyleBoxFlat_progress_fill`):
```
background: Color(0, 1, 0, 0.3)  # Green, 30% opacity
content_margin: 4px top/bottom
font_color: White (1, 1, 1, 1)
```

**Fill - Suspicion** (`StyleBoxFlat_progress_fill_red`):
```
background: Color(1, 0, 0, 0.3)  # Red, 30% opacity
content_margin: 4px top/bottom
```

**Usage**:
- Standard (green): Health, stamina, resources
- Suspicion (red): Danger meters, negative meters

---

## Theme Variations

### SuspicionProgressBar

**Type**: ProgressBar variant

**Usage**: Apply to progress bars showing danger/negative values

**How to Use**:
```gdscript
# In .tscn file:
[node name="SuspicionBar" type="ProgressBar"]
theme_type_variation = "SuspicionProgressBar"
```

**Difference from Standard ProgressBar**:
- Fill color: Red instead of green
- Everything else: Same as standard

### StyledPopup

**Type**: Panel variant

**Usage**: Popup dialog backgrounds

**Styling** (`StyleBoxFlat_popup_panel`):
```
background: Color(0.25, 0.25, 0.25, 0.15)  # Dark grey, 15% opacity
border: 2px, Color(0.6, 0.6, 0.6, 0.5)  # Medium grey, 50% opacity
corner_radius: 8px (all corners)
content_margin: 20px (all sides)
shadow_color: Color(0, 0, 0, 0.1)  # Black, 10% opacity
shadow_size: 8px
shadow_offset: Vector2(0, 4)  # Drop shadow downward
```

**Visual Features**:
- Translucent dark background
- Visible border for definition
- Rounded corners for softness
- Drop shadow for depth

**How to Use**:
```gdscript
# In .tscn file:
[node name="PopupPanel" type="Panel"]
theme_type_variation = "StyledPopup"
```

**Used by**: [reusable_popup.tscn](../../reusable_popup.tscn)

### PopupButton

**Type**: Button variant

**Usage**: Buttons inside popup dialogs

**Normal State** (`StyleBoxFlat_popup_button_normal`):
```
background: Color(0.3, 0.3, 0.3, 0.15)  # Medium grey, 15% opacity
border: 2px, Color(0.5, 0.5, 0.5, 0.6)  # Medium grey, 60% opacity
corner_radius: 4px (all corners)
content_margin: 12px left/right, 8px top/bottom
font_color: White (1, 1, 1, 1)
```

**Hover State** (`StyleBoxFlat_popup_button_hover`):
```
background: Color(0.4, 0.4, 0.4, 0.25)  # Lighter grey, 25% opacity
border: 2px, Color(0.7, 0.7, 0.7, 0.8)  # Light grey, 80% opacity
corner_radius: 4px (all corners)
font_hover_color: Light yellow (1, 1, 0.9, 1)
```

**Pressed State** (`StyleBoxFlat_popup_button_pressed`):
```
background: Color(0.25, 0.25, 0.25, 0.35)  # Dark grey, 35% opacity
border: 2px, Color(0.4, 0.4, 0.4, 0.7)  # Dark grey, 70% opacity
corner_radius: 4px (all corners)
font_pressed_color: Light grey (0.9, 0.9, 0.9, 1)
```

**Visual Features**:
- Translucent background (more transparent than standard buttons)
- **Outlined border** (key visual difference)
- Larger content margins (more padding)
- Hover state brightens border significantly

**How to Use**:
```gdscript
# In .tscn file or code:
button.theme_type_variation = &"PopupButton"
```

**Used by**: [reusable_popup.gd](../../reusable_popup.gd) (auto-applies to buttons)

---

## Component Integration

### Reusable Popup System

**File**: [reusable_popup.tscn](../../reusable_popup.tscn) + [reusable_popup.gd](../../reusable_popup.gd)

**Theme Usage**:

**Popup Panel**:
```gdscript
# Uses StyledPopup variation (semi-transparent with border and shadow)
# Auto-applied in .tscn file
```

**Popup Buttons**:
```gdscript
# In reusable_popup.gd setup():
button.theme_type_variation = &"PopupButton"  # Auto-applies outlined button style
```

**Responsive Font Scaling**:
```gdscript
# Portrait mode (in setup()):
if is_portrait:
    var default_font_size = 25
    button.add_theme_font_size_override(
        "font_size",
        int(default_font_size * ResponsiveLayout.PORTRAIT_FONT_SCALE)  # 25 * 1.75 = 43
    )
    message_label.add_theme_font_size_override(
        "font_size",
        int(default_font_size * ResponsiveLayout.PORTRAIT_FONT_SCALE)
    )
```

**See**: [popup-system.md](popup-system.md) for complete API reference

### Settings Overlay

**File**: [settings_overlay.tscn](../../settings_overlay.tscn) + [settings_overlay.gd](../../settings_overlay.gd)

**Theme Usage**:

**Settings Button** (Orange gear):
```gdscript
# Custom orange background via theme override
# Positioned bottom-right corner
# Size: 30x30px (landscape), 70x70px (portrait/mobile)
```

**Menu Overlay Panel**:
```gdscript
# Uses standard Panel style
# Size: 300x200px (landscape), 415x340px (portrait)
```

**Menu Buttons**:
```gdscript
# Use standard Button style
# Font scaling in portrait mode:
if is_portrait:
    var scaled_font_size = int(25 * 1.25)  # 25% bigger = 31px
    child.add_theme_font_size_override("font_size", scaled_font_size)
```

**Responsive Behavior** (in [settings_overlay.gd](../../settings_overlay.gd)):
- **Landscape/Desktop**: Standard sizes, standard font
- **Portrait/Mobile**: Larger button (70x70), larger overlay, 1.25x font scaling

### Notification System

**File**: [global.gd](../../global.gd) show_stat_notification()

**Theme Usage**:

**Notification Panel**:
```gdscript
# Creates StyleBoxFlat dynamically (NOT using theme variations)
var style_box = StyleBoxFlat.new()
style_box.bg_color = Color(0.15, 0.15, 0.15, 0.4)  # Dark grey, 40% opacity
style_box.corner_radius_top_left = 8
style_box.corner_radius_top_right = 8
style_box.corner_radius_bottom_left = 8
style_box.corner_radius_bottom_right = 8
# etc.
```

**Notification Label**:
```gdscript
# Uses default theme font size (25px)
# Overridden in portrait mode:
notification_label.add_theme_font_size_override(
    "font_size",
    int(25 * ResponsiveLayout.PORTRAIT_FONT_SCALE)  # 25 * 1.75 = 43
)
```

**Why Not Theme Variation?** Notifications are fully dynamic and created/destroyed frequently

**See**: [notifications.md](notifications.md) for complete system reference

---

## Customization Guide

### Changing Global Font Size

**Location**: default_theme.tres line 126
```gdscript
default_font_size = 25  # Change to desired size
```

**Effect**: Changes ALL text across project (unless overridden)

**Responsive Note**: Portrait mode multiplies by PORTRAIT_FONT_SCALE (1.75)

### Changing Button Colors

**Normal State** (line 19):
```gdscript
bg_color = Color(0.25, 0.25, 0.25, 0.3)
# Format: Color(Red, Green, Blue, Alpha)
# Example darker: Color(0.15, 0.15, 0.15, 0.4)
# Example blue tint: Color(0.2, 0.2, 0.35, 0.3)
```

**Hover State** (line 8):
```gdscript
bg_color = Color(0.35, 0.35, 0.35, 0.3)
# Example brighter hover: Color(0.45, 0.45, 0.45, 0.35)
```

**Font Colors** (lines 127-129):
```gdscript
Button/colors/font_color = Color(1, 1, 1, 1)           # Normal
Button/colors/font_hover_color = Color(1, 1, 0.8, 1)  # Hover
Button/colors/font_pressed_color = Color(0.9, 0.9, 0.9, 1)  # Pressed
```

### Changing Panel Opacity

**Location**: line 37
```gdscript
bg_color = Color(0.5, 0.5, 0.5, 0.3)
# Last value is opacity: 0.3 = 30%
# Make more opaque: Color(0.5, 0.5, 0.5, 0.5) # 50%
# Make more transparent: Color(0.5, 0.5, 0.5, 0.15) # 15%
```

### Changing ProgressBar Fill Colors

**Standard (Green)** (line 51):
```gdscript
bg_color = Color(0, 1, 0, 0.3)  # Green, 30% opacity
# Blue: Color(0, 0.5, 1, 0.3)
# Yellow: Color(1, 1, 0, 0.3)
```

**Suspicion (Red)** (line 56):
```gdscript
bg_color = Color(1, 0, 0, 0.3)  # Red, 30% opacity
# Orange: Color(1, 0.5, 0, 0.3)
# Purple: Color(0.8, 0, 0.8, 0.3)
```

### Changing Popup Styles

**Popup Panel Background** (lines 63, 68):
```gdscript
bg_color = Color(0.25, 0.25, 0.25, 0.15)  # Panel background
border_color = Color(0.6, 0.6, 0.6, 0.5)  # Border color
# Make darker: bg_color = Color(0.1, 0.1, 0.1, 0.2)
# Remove border: Set border_width_* to 0
```

**Popup Button Border** (PopupButton normal, line 87):
```gdscript
border_color = Color(0.5, 0.5, 0.5, 0.6)
# Brighter border: Color(0.7, 0.7, 0.7, 0.8)
# Colored border: Color(0.3, 0.5, 1.0, 0.7) # Blue
```

### Changing Corner Radius

**Buttons** (lines 9-12):
```gdscript
corner_radius_top_left = 3
corner_radius_top_right = 3
corner_radius_bottom_right = 3
corner_radius_bottom_left = 3
# More rounded: 8
# Sharp corners: 0
```

**Panels** (lines 38-41):
```gdscript
corner_radius_top_left = 4
# etc.
```

---

## Theme Application

### Automatic Application

**All scenes automatically use default_theme.tres** via project settings

**No manual setup needed** in individual scenes

### Manual Theme Overrides

**Per-Node Overrides** (for special cases):
```gdscript
# In code:
button.add_theme_color_override("font_color", Color.RED)
button.add_theme_font_size_override("font_size", 30)
button.add_theme_stylebox_override("normal", custom_style_box)

# In .tscn:
[node name="SpecialButton" type="Button"]
theme_override_colors/font_color = Color(1, 0, 0, 1)
theme_override_font_sizes/font_size = 30
```

**When to Override**:
- Unique one-off styling needed
- Special visual states (warnings, errors, highlights)
- Testing color variations

**Best Practice**: Prefer theme variations over per-node overrides

### Creating New Theme Variations

**Example: Creating "WarningButton" variation**

1. **Edit default_theme.tres** (or use GUI editor)
2. **Add new StyleBoxFlat resources** for normal/hover/pressed
3. **Register variation**:
```gdscript
WarningButton/base_type = &"Button"
WarningButton/colors/font_color = Color(1, 1, 0, 1)  # Yellow
WarningButton/styles/normal = SubResource("StyleBoxFlat_warning_normal")
WarningButton/styles/hover = SubResource("StyleBoxFlat_warning_hover")
WarningButton/styles/pressed = SubResource("StyleBoxFlat_warning_pressed")
```
4. **Apply in scenes**:
```gdscript
button.theme_type_variation = &"WarningButton"
```

---

## Common Issues & Solutions

### Issue: Theme changes don't appear

**Cause**: Editor cache

**Solution**:
1. Close all scenes
2. Delete `.godot/editor/` folder
3. Restart Godot
4. Reopen scenes

### Issue: Some elements don't use theme

**Cause**: Per-node overrides masking theme

**Solution**: Check Inspector for orange reset arrows (indicates override). Click to remove.

### Issue: Font size inconsistent

**Cause**: Manual font_size overrides in scene files

**Solution**:
1. Use theme default_font_size for consistency
2. Use ResponsiveLayout for portrait scaling (don't hardcode sizes)

### Issue: Popup buttons don't have borders

**Cause**: Forgot to set `theme_type_variation = &"PopupButton"`

**Solution**:
```gdscript
# In reusable_popup.gd or scene:
button.theme_type_variation = &"PopupButton"
```

---

## When Working with Themes

### Do:
- ✅ Modify default_theme.tres for global changes
- ✅ Use theme variations for specialized styles
- ✅ Test changes in both landscape and portrait
- ✅ Keep colors consistent (similar opacity/brightness)
- ✅ Document custom theme variations
- ✅ Use alpha (opacity) for translucent UI

### Don't:
- ❌ Hardcode colors in individual scenes
- ❌ Create too many theme variations (keep simple)
- ❌ Forget to test hover/pressed states
- ❌ Use fully opaque backgrounds (breaks visual layering)
- ❌ Override theme in code unless necessary

---

## Testing Checklist

When modifying themes:
1. [ ] Changed default_theme.tres?
2. [ ] Deleted .godot/editor/ cache?
3. [ ] Restarted Godot?
4. [ ] Tested in landscape mode?
5. [ ] Tested in portrait mode?
6. [ ] Tested button hover states?
7. [ ] Tested button pressed states?
8. [ ] Checked popup appearance?
9. [ ] Verified progress bar colors?
10. [ ] Confirmed font sizes appropriate?

---

## Color Palette Reference

**GoA Standard Colors**:

| Element | Color | RGB | Alpha | Notes |
|---------|-------|-----|-------|-------|
| **Buttons Normal** | Dark grey | (0.25, 0.25, 0.25) | 30% | Subtle background |
| **Buttons Hover** | Medium grey | (0.35, 0.35, 0.35) | 30% | Brighter on hover |
| **Panels** | Medium grey | (0.5, 0.5, 0.5) | 30% | Slightly brighter than buttons |
| **Progress Fill** | Green | (0, 1, 0) | 30% | Health/positive |
| **Suspicion Fill** | Red | (1, 0, 0) | 30% | Danger/negative |
| **Popup Panel** | Dark grey | (0.25, 0.25, 0.25) | 15% | More translucent |
| **Popup Border** | Light grey | (0.6, 0.6, 0.6) | 50% | Visible outline |
| **Text** | White | (1, 1, 1) | 100% | High contrast |
| **Text Hover** | Light yellow | (1, 1, 0.8) | 100% | Warm hover effect |

---

**Related Docs**:
- [popup-system.md](popup-system.md) - Popup theming usage
- [notifications.md](notifications.md) - Notification styling
- [godot-dev.md](godot-dev.md) - Theme application patterns
- [responsive-layout.md](responsive-layout.md) - Font scaling system

**Version**: 1.0
**Last Updated**: 2025-10-29
