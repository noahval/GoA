# Scene Template Guide

## Overview

This project uses **scene inheritance** to maintain consistent layouts across all game scenes. Changes to the base template automatically propagate to all inherited scenes.

## Base Template: scene_template.tscn

Location: `level1/scene_template.tscn`

### Layout Structure

```
SceneRoot (Control)
├── Background (TextureRect) - Full screen background
├── HBoxContainer (Landscape layout)
│   ├── LeftVBox (220px wide) - Info panels
│   └── RightVBox (260px wide) - Buttons
└── VBoxContainer (Portrait layout - hidden by default)
    ├── TopPadding (90px)
    ├── TopVBox - Info panels
    ├── Spacer (flexible)
    ├── BottomVBox - Buttons
    └── BottomPadding (90px)
```

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
4. Add your scene-specific content:
   - Set Background texture
   - Add panels to LeftVBox
   - Add buttons to RightVBox
   - Attach your script
5. Save with descriptive name (e.g., `new_location.tscn`)

### Method 2: Manual TSCN File Creation

Create a new `.tscn` file:

```gdscript
[gd_scene load_steps=3 format=3 uid="uid://unique_id_here"]

[ext_resource type="PackedScene" uid="uid://base_scene_template" path="res://level1/scene_template.tscn" id="1_base"]
[ext_resource type="Script" path="res://level1/your_script.gd" id="2_script"]

[node name="SceneRoot" instance=ExtResource("1_base")]
script = ExtResource("2_script")

[node name="Background" parent="." instance=ExtResource("1_base")]
texture = preload("res://level1/your_background.jpg")

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

All scenes should implement responsive switching between landscape and portrait layouts. Copy this pattern from `dream.gd`:

```gdscript
extends Control

@onready var hbox_container = $HBoxContainer
@onready var vbox_container = $VBoxContainer
@onready var left_vbox = $HBoxContainer/LeftVBox
@onready var right_vbox = $HBoxContainer/RightVBox
@onready var top_vbox = $VBoxContainer/TopVBox
@onready var bottom_vbox = $VBoxContainer/BottomVBox

var is_portrait_mode = false

func _ready():
    apply_mobile_scaling()

func apply_mobile_scaling():
    var viewport_size = get_viewport().get_visible_rect().size
    var is_portrait = viewport_size.y > viewport_size.x

    if is_portrait_mode != is_portrait:
        # Reparent columns
        if left_vbox.get_parent():
            left_vbox.get_parent().remove_child(left_vbox)
        if right_vbox.get_parent():
            right_vbox.get_parent().remove_child(right_vbox)

        if is_portrait:
            top_vbox.add_child(left_vbox)
            bottom_vbox.add_child(right_vbox)
        else:
            hbox_container.add_child(left_vbox)
            hbox_container.add_child(right_vbox)

        hbox_container.visible = not is_portrait
        vbox_container.visible = is_portrait
        is_portrait_mode = is_portrait

    # Scale UI for portrait (1.75x larger)
    if is_portrait:
        # Scale buttons to 105px height, increase font by 75%
        # Scale panels to 70px height
    else:
        # Reset to defaults
```

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

## Future Enhancements

Consider creating specialized templates:
- `combat_scene_template.tscn` - For battle scenes
- `shop_scene_template.tscn` - For merchant interactions
- `dialogue_scene_template.tscn` - For conversations

Each can inherit from `scene_template.tscn` and add specific structures.
