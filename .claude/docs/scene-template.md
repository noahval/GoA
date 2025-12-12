# Scene Template System Reference

**Technical reference for GoA's scene inheritance and layout structure**

---

## System Overview

**Base Template**: [level1/scene_template.tscn](../../level1/scene_template.tscn)

**Architecture**: Scene inheritance - child scenes inherit structure from base template

**Purpose**: Maintain consistent four-container layout across all game scenes

**Key Benefit**: Changes to template propagate to all child scenes automatically

---

## Four-Container Layout Structure

### Landscape Mode

```
SceneRoot (Control)
├── Background (TextureRect) - Full screen, mouse_filter=PASS ⚠️
├── HBoxContainer - Centered (700px height), mouse_filter=PASS
│   ├── LeftVBox (220px min) - Information Menu
│   ├── CenterArea (flexible) - Main Play Area
│   └── RightVBox (260px min) - Button Menu
├── NotificationBar (VBoxContainer) - Bottom anchored (100px)
├── VBoxContainer (Portrait) - Hidden
├── PopupContainer (z-index 100) - For all popups
└── SettingsOverlay (z-index 200) - Gear button + menu
```

### Portrait Mode

```
SceneRoot (Control)
├── Background (TextureRect) - Full screen
├── HBoxContainer (Landscape) - Hidden
├── VBoxContainer (Portrait) - Full screen, mouse_filter=PASS
│   ├── TopPadding (90px)
│   ├── TopVBox - Information Menu (reparented LeftVBox)
│   ├── NotificationBar - Reparented here
│   ├── MiddleArea (flexible) - Main Play Area (reparented CenterArea)
│   ├── BottomVBox - Button Menu (reparented RightVBox)
│   └── BottomPadding (90px)
├── PopupContainer (z-index 100)
└── SettingsOverlay (z-index 200)
```

---

## Container Purposes

### 1. Information Menu (LeftVBox → TopVBox in portrait)
**Contains**: Titles, counters, progress bars, stats

**Dimensions**:
- Landscape: 220px min width
- Portrait: Full width, auto height

**Child Nodes**: Panel + Label combos, ProgressBars

### 2. Main Play Area (CenterArea → MiddleArea in portrait)
**Contains**: Gameplay, mini-games, dialogs, interactive content

**Dimensions**:
- Flexible - expands to fill available space
- Landscape: Between left/right menus
- Portrait: Between top/bottom menus

**Use**: Primary game content area, popups center here

### 3. Button Menu (RightVBox → BottomVBox in portrait)
**Contains**: Navigation buttons, action buttons, purchases

**Dimensions**:
- Landscape: 260px min width
- Portrait: Full width, auto height

**Child Nodes**: Button nodes for user actions

### 4. NotificationBar (NEW - 4th Container) ⭐
**Contains**: Dynamic game notifications from `Global.show_stat_notification()`

**Dimensions**:
- Landscape: Full width, 100px height, bottom-anchored
- Portrait: Full width, auto height, between top menu and middle area

**Auto-reparenting**: ResponsiveLayout moves this container based on orientation

**Primary Use**:
- Stat level-ups
- Event whispers
- System messages
- Stacks vertically, auto-removes after 3s

---

## Critical Implementation Details

### Mouse Filter MUST Be PASS

**ALL these nodes MUST have `mouse_filter = 2` (PASS)**:
- Background (TextureRect)
- HBoxContainer
- VBoxContainer
- LeftVBox
- RightVBox
- CenterArea
- MiddleArea

**Why**: Background is full-screen and blocks ALL clicks if not set to PASS

**Handled automatically**: `ResponsiveLayout.apply_to_scene(self)` sets this at runtime

### Background Auto-Loading

ResponsiveLayout automatically loads backgrounds based on root node name:

```gdscript
# Root node name: "Bar"
# Auto-loads: res://level1/bar.jpg

# Root node name: "CoppersmithCarriage"
# Auto-loads: res://level1/coppersmith_carriage.jpg
```

**Requirements**:
1. Root node has unique name (NOT "SceneRoot")
2. Image file exists in `level1/` directory
3. Filename is snake_case version of root node name

### Signal Preservation

**Godot 4's `reparent()` preserves signal connections**

When ResponsiveLayout switches orientations:
- Buttons move from HBoxContainer to VBoxContainer (or vice versa)
- All .tscn signal connections remain intact
- No manual signal reconnection needed

**Example**:
```gdscript
# .tscn signal connection:
[connection signal="pressed" from="HBoxContainer/RightVBox/MyButton" to="." method="_on_button_pressed"]

# After portrait switch:
# Button is now at: VBoxContainer/BottomVBox/RightVBox/MyButton
# Signal still connected to _on_button_pressed ✅
```

---

## Creating New Scenes

### Method 1: Via Godot Editor (Recommended)

1. Right-click `level1/scene_template.tscn`
2. Select "New Inherited Scene"
3. **Change root node name** from "SceneRoot" to unique name (e.g., "Bar")
4. Add scene content to containers
5. Attach script
6. Save as `bar.tscn`
7. Create `level1/bar.jpg` for auto-loading background

**ResponsiveLayout will auto-load the background!**

### Method 2: Manual .tscn Creation (With Auto-Loading Background)

```gdscript
[gd_scene load_steps=2 format=3 uid="uid://unique"]

[ext_resource type="PackedScene" path="res://level1/scene_template.tscn" id="1_base"]
[ext_resource type="Script" path="res://level1/bar.gd" id="2_script"]

[node name="Bar" instance=ExtResource("1_base")]
script = ExtResource("2_script")

[node name="MyPanel" type="Panel" parent="HBoxContainer/LeftVBox"]
layout_mode = 2
custom_minimum_size = Vector2(0, 24)

[node name="MyButton" type="Button" parent="HBoxContainer/RightVBox"]
layout_mode = 2
text = "Action"
```

Then create `level1/bar.jpg` - auto-loads!

### Method 3: Manual With Explicit Background

```gdscript
[gd_scene load_steps=3 format=3 uid="uid://unique"]

[ext_resource type="PackedScene" path="res://level1/scene_template.tscn" id="1_base"]
[ext_resource type="Script" path="res://level1/bar.gd" id="2_script"]
[ext_resource type="Texture2D" path="res://level1/custom_bg.jpg" id="3_bg"]

[node name="Bar" instance=ExtResource("1_base")]
script = ExtResource("2_script"]

[node name="Background" parent="." index="0"]
texture = ExtResource("3_bg")
```

**CRITICAL SYNTAX**:
- ✅ `[node name="Background" parent="." index="0"]` (NO `instance=`!)
- ✅ Root node has unique name (NOT "SceneRoot")
- ✅ `load_steps` matches number of ExtResources + 1

---

## Standard Patterns

### Panel Pattern (Info Display)

```gdscript
[node name="InfoPanel" type="Panel" parent="HBoxContainer/LeftVBox"]
custom_minimum_size = Vector2(0, 24)
layout_mode = 2

[node name="InfoLabel" type="Label" parent="HBoxContainer/LeftVBox/InfoPanel"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
text = "Info Text"
horizontal_alignment = 1
vertical_alignment = 1
```

### Progress Bar Pattern (Resource Display)

```gdscript
[node name="ResourcePanel" type="Panel" parent="HBoxContainer/LeftVBox"]
custom_minimum_size = Vector2(0, 24)
layout_mode = 2

[node name="ResourceBar" type="ProgressBar" parent="HBoxContainer/LeftVBox/ResourcePanel"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
value = 100.0
show_percentage = false

[node name="ResourceLabel" type="Label" parent="HBoxContainer/LeftVBox/ResourcePanel"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
text = "Resource: 100"
horizontal_alignment = 1
vertical_alignment = 1
```

**For suspicion/danger bars**: Add `theme_type_variation = "SuspicionProgressBar"`

### Popup Integration

**ALWAYS put popups in PopupContainer**:

```gdscript
[ext_resource type="PackedScene" path="res://reusable_popup.tscn" id="popup"]

[node name="MyPopup" parent="PopupContainer" instance=ExtResource("popup")]
```

**Reference in script**:
```gdscript
@onready var my_popup = $PopupContainer/MyPopup
```

See [popup-system.md](popup-system.md) for details.

---

## Responsive Layout Integration

### Required in Every Scene

```gdscript
extends Control

func _ready():
    ResponsiveLayout.apply_to_scene(self)
    # Other initialization...
```

**This handles**:
- Portrait/landscape detection
- Container reparenting
- Element scaling
- Mouse filter setting (PASS on Background)
- Background auto-loading
- Settings overlay addition

**CRITICAL**: Use `ResponsiveLayout.apply_to_scene(self)`, NOT custom scaling functions!

---

## Inheritance Rules

### What Propagates
✅ Layout changes (container sizes, positions)
✅ New nodes added to template
✅ Theme updates (via default_theme.tres)
✅ Default property values

### What Doesn't Propagate
❌ Properties overridden in child scenes
❌ Scene-specific content (textures, text, buttons)
❌ Scripts attached to child scenes

### Cannot Remove Inherited Nodes
If a node exists in template, child scenes **cannot delete it**

**Workarounds**:
- Hide: `visible = false`
- Move off-screen: `position = Vector2(-10000, -10000)`
- Keep template minimal

---

## Theme Integration

**File**: [default_theme.tres](../../default_theme.tres)

**Standard Styles**:
- Panel backgrounds: 20% opacity white
- Button backgrounds: 20% opacity dark gray
- Labels: White text, 25px font
- ProgressBars: 35% opacity (green standard, red suspicion variant)

**Popup Variations**:
- PopupPanel: Dark translucent panel style
- PopupButton: Outlined button with hover/pressed states

---

## Settings Overlay

**Automatically added** by ResponsiveLayout

**Components**:
- 30x30px orange gear button (bottom-right)
- Centered overlay panel with settings
- Dev Speed Mode toggle (controls `Global.dev_speed_mode`)

**No manual setup needed** - included in template, managed by ResponsiveLayout

---

## Common Issues

### Issue: Buttons not clickable
**Cause**: Background mouse_filter not set to PASS

**Solution**: `ResponsiveLayout.apply_to_scene(self)` fixes automatically

### Issue: Background not showing
**Causes**:
1. Root node named "SceneRoot" (not unique)
2. Background image file doesn't exist
3. Wrong .tscn syntax for Background override

**Debug**: Check Godot console for ResponsiveLayout messages:
- "Background: false" → Structure wrong
- "Background texture: null" → Image missing
- "Trying to load background from: res://level1/..." → Auto-load attempt
- "Successfully auto-loaded background texture!" → Success

**Solutions**:
1. Change root node to unique name
2. Create matching image file in level1/
3. Fix .tscn syntax (use `parent="." index="0"`, NOT `instance=`)

### Issue: Template changes don't appear
**Cause**: Editor cache

**Solution**: Close/reopen scene, or restart Godot

### Issue: Signals broken after orientation change
**Shouldn't happen**: `reparent()` preserves signals

**If it does**: Check using correct Godot 4 signal syntax, not Godot 3

---

## When Creating/Modifying Scenes

**Do**:
- ✅ Use unique root node names
- ✅ Call `ResponsiveLayout.apply_to_scene(self)` in `_ready()`
- ✅ Put popups in PopupContainer
- ✅ Create matching background image
- ✅ Follow standard panel/button patterns
- ✅ Test both landscape and portrait

**Don't**:
- ❌ Name root "SceneRoot"
- ❌ Forget ResponsiveLayout call
- ❌ Add popups as direct children of root
- ❌ Write custom scaling functions
- ❌ Manually set mouse_filter (ResponsiveLayout handles it)
- ❌ Try to delete inherited template nodes

---

## Debugging Checklist

When scene has issues:
1. [ ] Root node has unique name?
2. [ ] Background image exists in level1/?
3. [ ] ResponsiveLayout.apply_to_scene() called in _ready()?
4. [ ] Popups in PopupContainer?
5. [ ] Checked Godot console for ResponsiveLayout messages?
6. [ ] Tested in both orientations?
7. [ ] Buttons clickable in both modes?

---

**Related Docs**:
- [responsive-layout.md](responsive-layout.md) - Responsive scaling system
- [popup-system.md](popup-system.md) - Popup dialogs
- [godot-dev.md](godot-dev.md) - Godot patterns

**Version**: 2.0 (Claude-focused)
**Last Updated**: 2025-10-29
