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
background: Color(0.58, 0.247, 0.012, 0.3)  # Dark orange (#943f03), 30% opacity
corner_radius: 3px (all corners)
content_margin: 8px left/right, 4px top/bottom
font_color: White (1, 1, 1, 1)
```

**Hover State** (`StyleBoxFlat_button_hover`):
```
background: Color(0.68, 0.35, 0.1, 0.3)  # Light orange, 30% opacity
corner_radius: 3px (all corners)
content_margin: 8px left/right, 4px top/bottom
font_hover_color: Light yellow (1, 1, 0.8, 1)
```

**Pressed State**:
```
font_pressed_color: Light grey (0.9, 0.9, 0.9, 1)
```

**Visual States**:
- Normal: Dark orange, white text
- Hover: Light orange, yellow-white text
- Pressed: Same background, slightly dimmed text

**Usage**: Default for negative/cancel/neutral actions. For affirmative actions, use `AffirmativeButton` variation.

### Label

**Normal State** (`StyleBoxFlat_label`):
```
background: Color(0.58, 0.247, 0.012, 0.3)  # Dark orange (#943f03), 30% opacity
corner_radius: 3px (all corners)
content_margin: 8px left/right, 4px top/bottom
font_color: White (1, 1, 1, 1)
line_spacing: 2px
```

**Usage**: Info panels, stat displays, counters

### Panel

**Normal State** (`StyleBoxFlat_panel`):
```
background: Color(0.58, 0.247, 0.012, 0.3)  # Dark orange (#943f03), 30% opacity
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
background: Color(0.9, 0.4, 0.05, 0.3)  # Orange, 30% opacity
content_margin: 4px top/bottom
```

**Usage**:
- Standard (green): Health, stamina, resources
- Suspicion (orange): Danger meters, negative meters

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

### AffirmativeButton

**Type**: Button variant

**Usage**: Buttons for affirmative/positive actions (Yes, OK, Confirm, Accept, etc.)

**Normal State** (`StyleBoxFlat_affirmative_button_normal`):
```
background: Color(0.008, 0.416, 0.62, 0.3)  # Blue (#026a9e), 30% opacity
corner_radius: 3px (all corners)
content_margin: 8px left/right, 4px top/bottom
font_color: White (1, 1, 1, 1)
```

**Hover State** (`StyleBoxFlat_affirmative_button_hover`):
```
background: Color(0.1, 0.52, 0.75, 0.3)  # Light blue, 30% opacity
corner_radius: 3px (all corners)
font_hover_color: Light yellow (1, 1, 0.9, 1)
```

**Pressed State** (`StyleBoxFlat_affirmative_button_pressed`):
```
background: Color(0.006, 0.33, 0.5, 0.35)  # Dark blue, 35% opacity
corner_radius: 3px (all corners)
font_pressed_color: Light grey (0.9, 0.9, 0.9, 1)
```

**Visual Features**:
- Blue background for positive/affirmative actions
- Contrasts with orange default buttons (negative/cancel actions)
- Matches blue accent theme used in borders and trim

**How to Use**:
```gdscript
# In .tscn file:
[node name="ConfirmButton" type="Button"]
theme_type_variation = "AffirmativeButton"

# In code:
confirm_button.theme_type_variation = &"AffirmativeButton"
```

**Design Pattern**:
- Use **AffirmativeButton** (blue) for: Yes, OK, Confirm, Accept, Save, Submit
- Use **Default Button** (orange) for: No, Cancel, Back, Close, Delete

### ForwardNavButton

**Type**: Button variant

**Usage**: Navigation buttons that take you forward/deeper into scenes

**Normal State** (`StyleBoxFlat_forward_nav_button_normal`):
```
background: Color(0.255, 0.412, 0.882, 0.3)  # Royal blue (#4169E1), 30% opacity
border: 2px, Color(0.357, 0.608, 0.835, 1)  # Bright blue (#5B9BD5), 100% opacity
corner_radius: 6px (all corners)
content_margin: 8px left/right, 4px top/bottom
shadow_color: Color(0, 0, 0, 0.1)
shadow_size: 4px
shadow_offset: Vector2(0, 2)
font_color: Color(0.529, 0.808, 0.922, 1)  # Sky blue (#87CEEB)
```

**Hover State** (`StyleBoxFlat_forward_nav_button_hover`):
```
background: Color(0.3, 0.5, 0.95, 0.35)  # Lighter blue, 35% opacity
border: 2px, Color(0.4, 0.65, 0.88, 1)  # Brighter blue
corner_radius: 6px (all corners)
shadow_size: 6px (increased depth on hover)
shadow_offset: Vector2(0, 3)
font_hover_color: Color(0.65, 0.88, 0.98, 1)  # Brighter sky blue
```

**Pressed State** (`StyleBoxFlat_forward_nav_button_pressed`):
```
background: Color(0.2, 0.35, 0.75, 0.4)  # Darker blue, 40% opacity
border: 2px, Color(0.3, 0.55, 0.78, 1)
corner_radius: 6px (all corners)
shadow_size: 2px (reduced on press)
font_pressed_color: Color(0.45, 0.73, 0.86, 1)  # Dimmed blue
```

**Visual Features**:
- Light blue background (brighter = forward/progress)
- **2px border** (thicker than back nav = more emphasis)
- **6px corner radius** (more rounded than standard buttons)
- Subtle shadow for depth
- Progressive shadow animation (grows on hover, shrinks on press)

**How to Use**:
```gdscript
# In .tscn file:
[node name="EnterDungeonButton" type="Button"]
theme_type_variation = "ForwardNavButton"

# In code:
enter_button.theme_type_variation = &"ForwardNavButton"
```

### BackNavButton

**Type**: Button variant

**Usage**: Navigation buttons that take you back to previous scenes

**Normal State** (`StyleBoxFlat_back_nav_button_normal`):
```
background: Color(0, 0, 0.502, 0.3)  # Navy blue (#000080), 30% opacity
border: 1px, Color(0.176, 0.290, 0.431, 1)  # Dark blue-gray (#2D4A6E), 100% opacity
corner_radius: 6px (all corners)
content_margin: 8px left/right, 4px top/bottom
shadow_color: Color(0, 0, 0, 0.08)
shadow_size: 2px
shadow_offset: Vector2(0, 1)
font_color: Color(0.690, 0.769, 0.871, 1)  # Light steel blue (#B0C4DE)
```

**Hover State** (`StyleBoxFlat_back_nav_button_hover`):
```
background: Color(0.05, 0.05, 0.6, 0.35)  # Slightly lighter navy, 35% opacity
border: 1px, Color(0.22, 0.35, 0.5, 1)  # Lighter border
corner_radius: 6px (all corners)
shadow_size: 3px (slightly increased)
shadow_offset: Vector2(0, 2)
font_hover_color: Color(0.78, 0.85, 0.94, 1)  # Brighter steel blue
```

**Pressed State** (`StyleBoxFlat_back_nav_button_pressed`):
```
background: Color(0, 0, 0.4, 0.4)  # Darker navy, 40% opacity
border: 1px, Color(0.15, 0.25, 0.38, 1)  # Darkened border
corner_radius: 6px (all corners)
shadow_size: 1px (minimal on press)
font_pressed_color: Color(0.60, 0.69, 0.80, 1)  # Dimmed steel blue
```

**Visual Features**:
- Dark blue background (darker = return/retreat)
- **1px border** (thinner than forward nav = less emphasis)
- **6px corner radius** (matches forward nav for consistency)
- Minimal shadow for subtle appearance
- Muted colors for secondary action feel

**How to Use**:
```gdscript
# In .tscn file:
[node name="ReturnButton" type="Button"]
theme_type_variation = "BackNavButton"

# In code:
back_button.theme_type_variation = &"BackNavButton"
```

**Design Pattern - Navigation Buttons**:
- Use **ForwardNavButton** (light blue, 2px border) for: Enter, Explore, Continue, Next, Open, Advance
- Use **BackNavButton** (dark blue, 1px border) for: Return, Exit, Leave, Previous, Close
- Use **Default Button** (orange) for: Standard actions not related to navigation
- Use **AffirmativeButton** (cyan/blue) for: Yes, OK, Confirm, Accept actions in dialogs

**Visual Hierarchy**:
1. **Forward navigation** = Most prominent (light, thick border, larger shadow)
2. **Back navigation** = Less prominent (dark, thin border, minimal shadow)
3. **Border thickness** reinforces directionality (2px forward, 1px back)
4. **Color temperature** creates natural hierarchy (warm = action, cool = navigation)

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

**GoA Color Scheme**: Dark orange (#943f03) base with blue (#026a9e) accents

| Element | Color | Hex / RGB | Alpha | Notes |
|---------|-------|-----------|-------|-------|
| **Buttons Normal** | Dark orange | #943f03 / (0.58, 0.247, 0.012) | 30% | Base negative/neutral |
| **Buttons Hover** | Light orange | (0.68, 0.35, 0.1) | 30% | Brighter on hover |
| **Affirmative Button** | Blue | #026a9e / (0.008, 0.416, 0.62) | 30% | Positive/confirm actions |
| **Affirmative Hover** | Light blue | (0.1, 0.52, 0.75) | 30% | Brighter blue hover |
| **Forward Nav Button** | Royal blue | #4169E1 / (0.255, 0.412, 0.882) | 30% | Forward navigation |
| **Forward Nav Border** | Bright blue | #5B9BD5 / (0.357, 0.608, 0.835) | 100% | 2px border |
| **Forward Nav Text** | Sky blue | #87CEEB / (0.529, 0.808, 0.922) | 100% | Light blue text |
| **Back Nav Button** | Navy blue | #000080 / (0, 0, 0.502) | 30% | Back navigation |
| **Back Nav Border** | Blue-gray | #2D4A6E / (0.176, 0.290, 0.431) | 100% | 1px border |
| **Back Nav Text** | Steel blue | #B0C4DE / (0.690, 0.769, 0.871) | 100% | Muted blue text |
| **Panels** | Dark orange | (0.58, 0.247, 0.012) | 30% | Background panels |
| **Labels** | Dark orange | (0.58, 0.247, 0.012) | 30% | Info displays |
| **Progress Fill** | Green | (0, 1, 0) | 30% | Health/positive resources |
| **Suspicion Fill** | Orange | (0.9, 0.4, 0.05) | 30% | Danger/negative |
| **Popup Panel** | Dark orange | (0.58, 0.247, 0.012) | 15% | More translucent |
| **Popup/Trim Border** | Blue | #026a9e / (0.008, 0.416, 0.62) | 50-80% | Accent borders |
| **Text** | White | (1, 1, 1) | 100% | High contrast |
| **Text Hover** | Light yellow | (1, 1, 0.8) | 100% | Warm hover effect |

### Using AffirmativeButton Variation

For positive actions like "Yes", "Confirm", "OK", "Accept":

```gdscript
# In .tscn file:
[node name="ConfirmButton" type="Button"]
theme_type_variation = "AffirmativeButton"

# In code:
confirm_button.theme_type_variation = &"AffirmativeButton"
```

**Visual Design Philosophy**:
- **Orange buttons** = Negative, cancel, or neutral actions
- **Cyan/blue buttons** = Affirmative, confirm, or positive actions
- **Light blue buttons (2px border)** = Forward navigation (advancing to deeper scenes)
- **Dark blue buttons (1px border)** = Back navigation (returning to previous scenes)
- **Blue borders** = Visual trim and special element highlights
- **30% opacity** = Maintains translucent overlay aesthetic
- **Border thickness** = Visual hierarchy (2px forward > 1px back)

---

**Related Docs**:
- [popup-system.md](popup-system.md) - Popup theming usage
- [notifications.md](notifications.md) - Notification styling
- [godot-dev.md](godot-dev.md) - Theme application patterns
- [responsive-layout.md](responsive-layout.md) - Font scaling system

**Version**: 1.2 (Added ForwardNavButton and BackNavButton navigation variants)
**Last Updated**: 2025-11-05
