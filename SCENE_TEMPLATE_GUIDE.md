# Scene Template Guide

## Overview

This project uses **scene inheritance** to maintain consistent layouts across all game scenes. Changes to the base template automatically propagate to all inherited scenes.

## Base Template: scene_template.tscn

Location: `level1/scene_template.tscn`

### Layout Structure

```
SceneRoot (Control)
├── Background (TextureRect) - Full screen background - mouse_filter = PASS ⚠️
├── HBoxContainer (Landscape layout) - mouse_filter = PASS
│   ├── LeftVBox (220px wide) - Info panels - mouse_filter = PASS
│   └── RightVBox (260px wide) - Buttons - mouse_filter = PASS
└── VBoxContainer (Portrait layout - hidden by default) - mouse_filter = PASS
    ├── TopPadding (90px)
    ├── TopVBox - Info panels
    ├── Spacer (flexible)
    ├── BottomVBox - Buttons
    └── BottomPadding (90px)
```

**CRITICAL**: The **Background** TextureRect and all container nodes (HBoxContainer, VBoxContainer, LeftVBox, RightVBox) **MUST** have `mouse_filter = 2` (PASS) to ensure buttons are clickable. The Background is full-screen and will block ALL mouse clicks if mouse_filter is not set to PASS!

### Dimensions

**Landscape (HBoxContainer):**
- Container: 500px wide × 600px tall
- Centered using anchor preset 8 (center)
- LeftVBox: 220px minimum width
- RightVBox: 260px minimum width

**Portrait (VBoxContainer):**
- Full screen (anchor preset 15)
- 90px padding top and bottom
- Flexible spacer between top and bottom sections

### Theme Integration

All scenes inherit from `default_theme.tres`:
- Panel backgrounds: 20% opacity white
- Button backgrounds: 20% opacity dark gray
- Labels: White text, 25px font
- ProgressBars: 35% opacity (green standard, red suspicion variant)

## Creating New Scenes from Template

### Method 1: Via Godot Editor (Recommended)

1. Right-click `level1/scene_template.tscn` in FileSystem
2. Select "New Inherited Scene"
3. Godot creates a new scene that inherits the template
4. **IMPORTANT**: Change the root node name from "SceneRoot" to your scene's name (e.g., "Bar", "Tavern", "CoppersmithCarriage")
5. Add your scene-specific content:
   - Add panels to LeftVBox
   - Add buttons to RightVBox
   - Attach your script
6. Save with descriptive name matching the root node name (e.g., `bar.tscn` for root node "Bar")
7. Place a background image in `level1/` with the same name as the root node in snake_case (e.g., `bar.jpg`, `coppersmith_carriage.jpg`)

**The background will auto-load!** ResponsiveLayout automatically loads `level1/<scene_name>.jpg` based on the root node name.

### Method 2: Manual TSCN File Creation (Simple - Auto-Loading Background)

Create a new `.tscn` file with a **unique root node name** and place a matching `.jpg` file in `level1/`:

```gdscript
[gd_scene load_steps=2 format=3 uid="uid://unique_id_here"]

[ext_resource type="PackedScene" uid="uid://base_scene_template" path="res://level1/scene_template.tscn" id="1_base"]
[ext_resource type="Script" path="res://level1/bar.gd" id="2_script"]

[node name="Bar" instance=ExtResource("1_base")]
script = ExtResource("2_script")

[node name="MyPanel" type="Panel" parent="HBoxContainer/LeftVBox"]
layout_mode = 2
custom_minimum_size = Vector2(0, 24)

[node name="MyLabel" type="Label" parent="HBoxContainer/LeftVBox/MyPanel"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
text = "My Text"
horizontal_alignment = 1
vertical_alignment = 1

[node name="MyButton" type="Button" parent="HBoxContainer/RightVBox"]
layout_mode = 2
text = "My Action"
```

Then create `level1/bar.jpg` - ResponsiveLayout will automatically load it!

### Method 3: Manual TSCN File Creation (Explicit Background)

If you need to explicitly set the background texture:

```gdscript
[gd_scene load_steps=3 format=3 uid="uid://unique_id_here"]

[ext_resource type="PackedScene" uid="uid://base_scene_template" path="res://level1/scene_template.tscn" id="1_base"]
[ext_resource type="Script" path="res://level1/your_script.gd" id="2_script"]
[ext_resource type="Texture2D" path="res://level1/your_background.jpg" id="3_texture"]

[node name="YourSceneName" instance=ExtResource("1_base")]
script = ExtResource("2_script")

[node name="Background" parent="." index="0"]
texture = ExtResource("3_texture")

[node name="MyPanel" type="Panel" parent="HBoxContainer/LeftVBox"]
layout_mode = 2
custom_minimum_size = Vector2(0, 24)
```

**CRITICAL SYNTAX NOTES:**
- ✅ **Root node MUST have a unique name** (e.g., "Bar", "CoppersmithCarriage", NOT "SceneRoot")
- ✅ Background uses `[node name="Background" parent="." index="0"]` (NO `instance=` attribute!)
- ✅ Texture is loaded via ExtResource, not preload
- ✅ load_steps should match the number of ext_resource lines + 1

## How Template Updates Work

### What Propagates Automatically

✅ Layout changes (container sizes, positioning)
✅ New nodes added to template
✅ Theme updates (via default_theme.tres)
✅ Default property values

### What Doesn't Propagate

❌ Properties you've overridden in child scenes
❌ Scene-specific content (textures, text, buttons)
❌ Scripts attached to child scenes

### Example: Changing Column Widths

**Before - Template:**
```
LeftVBox: 220px wide
RightVBox: 260px wide
```

**Edit template to:**
```
LeftVBox: 240px wide
RightVBox: 240px wide
```

**Result:** All inherited scenes automatically use new widths (unless overridden)

## Responsive Layout Script Pattern

All scenes should use the centralized ResponsiveLayout system. This is the **modern, recommended approach**:

```gdscript
extends Control

func _ready():
    ResponsiveLayout.apply_to_scene(self)
    # Your other initialization...
```

**That's it!** ResponsiveLayout automatically:
- ✅ Handles portrait/landscape switching
- ✅ Scales UI elements appropriately
- ✅ Adds settings overlay
- ✅ **Uses call_deferred to wait for scene tree to be fully ready** (critical for inherited scenes!)
- ✅ **Sets mouse_filter to PASS on Background and containers** (ensures buttons work!)

**Old Pattern (deprecated):**
```gdscript
# DON'T DO THIS ANYMORE - use ResponsiveLayout instead!
func apply_mobile_scaling():
    # 50+ lines of custom scaling logic...
```

See [RESPONSIVE_LAYOUT_GUIDE.md](RESPONSIVE_LAYOUT_GUIDE.md) for details on the centralized system.

## Standard Panel Pattern

For consistency, use this pattern for info panels:

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

## Standard Progress Bar Pattern

For resource bars with labels:

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
text = "Resource Name"
horizontal_alignment = 1
vertical_alignment = 1
```

For suspicion/danger bars, add:
```
theme_type_variation = "SuspicionProgressBar"
```

## Limitations

### Cannot Remove Inherited Nodes

Once a node exists in the template, child scenes **cannot delete it**. Workarounds:
- Hide it: `visible = false`
- Move it off-screen: `position = Vector2(-10000, -10000)`
- Keep template minimal to avoid this issue

### Overrides Don't Update

If you override a property in a child scene, template changes to that property won't propagate. To reset an override:
- In Godot Editor: Click the circular arrow button next to the property
- Or remove the property line from the `.tscn` file

### Editor Refresh Issues

Sometimes the editor doesn't immediately show template changes. Solutions:
- Close and reopen the child scene
- Restart Godot editor
- Click the revert button on overridden properties

## Migration Guide for Existing Scenes

Since you cannot convert existing scenes to inherited scenes, follow this process:

1. **Create new inherited scene** from template
2. **Copy scene-specific content:**
   - Background texture path
   - Panel nodes from LeftVBox
   - Button nodes from RightVBox
   - Script attachment
3. **Test thoroughly**
4. **Update scene references** in code (Global.change_scene_with_check, etc.)
5. **Archive old scene** (don't delete until confident)

Example scenes already using the pattern:
- `level1/dream.tscn` - Original reference implementation
- `level1/planning_table.tscn` - Updated to use pattern

## Best Practices

### Do:
✅ Keep template minimal (structure only, no content)
✅ Use theme for all visual styling
✅ Test template changes before committing
✅ Document any scene-specific deviations
✅ Use descriptive node names

### Don't:
❌ Add scene-specific content to template
❌ Override too many properties in child scenes
❌ Remove nodes from template after children exist
❌ Forget to implement responsive layout script

## Troubleshooting

**Q: My child scene doesn't show template changes**
- A: Close and reopen the scene, or restart Godot editor

**Q: I need to remove a node from the template**
- A: Hide it in child scenes with `visible = false`, or create a new template

**Q: Can I have multiple templates?**
- A: Yes! Create different templates for different scene types

**Q: How do I override a property temporarily?**
- A: Just change it in the Inspector. Click the circular arrow to revert.

**Q: Theme changes aren't applying**
- A: Delete `.godot/editor` cache and restart Godot

**Q: Buttons aren't clickable in my new scene / Background not showing**
- A: **Check the Godot console output first!** ResponsiveLayout now has debug logging enabled. When you run your scene, look for messages like:
  ```
  ResponsiveLayout: Starting layout application for Bar
  ResponsiveLayout: Found nodes - Background: true HBox: true ...
  ResponsiveLayout: Set Background mouse_filter to PASS
  ResponsiveLayout: Background texture: <Texture2D#...>
  ResponsiveLayout: Found button: ToCoppersmithCarriageButton Text: to coppersmith carriage
  ```

  **If you see "Background: false"**: The Background node wasn't found. This means the scene structure is wrong.

  **If you see "Background texture: null"** followed by **"Attempting to auto-load background..."**:
  - ResponsiveLayout will try to automatically load the background based on your scene's root node name
  - Look for: `ResponsiveLayout: Trying to load background from: res://level1/your_scene.jpg`
  - **If auto-load succeeds**: You'll see `Successfully auto-loaded background texture!`
  - **If auto-load fails**: You need to create the image file or fix the root node name

  **Common issues:**
  1. **Root node is named "SceneRoot"**: Change it to a unique name like "Bar" or "CoppersmithCarriage"
  2. **Image file doesn't exist**: Create `level1/<scene_name>.jpg` where scene_name matches your root node in snake_case
     - "Bar" → `bar.jpg`
     - "CoppersmithCarriage" → `coppersmith_carriage.jpg`
  3. **Wrong .tscn syntax**: If you manually override Background, use:
    ```
    [node name="Background" parent="." index="0"]
    texture = ExtResource("3_texture")
    ```
    NOT:
    ```
    [node name="Background" parent="." instance=ExtResource("1_base")]  ❌ WRONG!
    ```

  **If you don't see any ResponsiveLayout messages**: You forgot to call `ResponsiveLayout.apply_to_scene(self)` in `_ready()`!

  **Manual fixes** (if not using ResponsiveLayout):
  1. Ensure Background, HBoxContainer, VBoxContainer, LeftVBox, RightVBox all have `mouse_filter = 2` (PASS)
  2. Check that your background image file exists in the level1 folder
  3. Verify the texture path in your .tscn file matches the actual file location

## Settings Overlay Pattern

A reusable settings overlay component is available for adding persistent settings UI to any scene.

### Files
- **Scene**: [settings_overlay.tscn](settings_overlay.tscn)
- **Script**: [settings_overlay.gd](settings_overlay.gd)

### Features
- **30x30px orange gear button** in bottom-right corner
- **Centered overlay panel** with settings controls
- **Dev Speed Mode toggle** that controls `Global.dev_speed_mode`
- **Responsive text** - button shows "Dev Speed Mode: ON/OFF" based on state

### Adding to Your Scene

**Automatic (Recommended):**
If your scene uses `ResponsiveLayout.apply_to_scene(self)`, the settings overlay is **automatically added** - no manual work needed!

**Manual Method 1: Via Godot Editor**
1. Open your scene
2. Right-click the root node
3. Select "Instantiate Child Scene"
4. Choose `settings_overlay.tscn`
5. The overlay automatically handles all logic

**Manual Method 2: Via TSCN File**
Add this to your scene file:

```gdscript
[ext_resource type="PackedScene" path="res://settings_overlay.tscn" id="settings"]

[node name="SettingsOverlay" parent="." instance=ExtResource("settings")]
```

**Manual Method 3: Via Scene Template**
The settings overlay is included in [scene_template.tscn](level1/scene_template.tscn), so all scenes inheriting from it automatically have it.

### Usage
- Click the orange gear button in bottom-right corner
- Toggle "Dev Speed Mode" to change `Global.dev_speed_mode` between true/false
- Click "Close" to hide the overlay

### Structure
```
SettingsOverlay (Control)
├── SettingsButton (Button) - 30x30px orange gear
└── MenuOverlay (Panel) - 300x200px centered
    └── VBoxContainer
        ├── TitleLabel - "Settings"
        ├── DevSpeedToggle - Toggle button
        └── CloseButton - Close overlay
```

### Extending the Settings Menu

To add new settings:

1. Open [settings_overlay.tscn](settings_overlay.tscn)
2. Add new Button/CheckBox/etc to VBoxContainer
3. Update [settings_overlay.gd](settings_overlay.gd):

```gdscript
@onready var my_new_setting = $MenuOverlay/VBoxContainer/MyNewSetting

func _on_my_new_setting_pressed():
    Global.my_setting = !Global.my_setting
    # Update UI if needed
```

4. All scenes using the overlay automatically get the new setting

## Future Enhancements

Consider creating specialized templates:
- `combat_scene_template.tscn` - For battle scenes
- `shop_scene_template.tscn` - For merchant interactions
- `dialogue_scene_template.tscn` - For conversations

Each can inherit from `scene_template.tscn` and add specific structures.
