# Popup System Reference

**Technical reference for GoA's reusable popup dialog system**

---

## System Architecture

**File**: [reusable_popup.tscn](../../reusable_popup.tscn) + [reusable_popup.gd](../../reusable_popup.gd)

**Purpose**: Provide consistent, themed modal dialogs across all scenes

**Key Characteristics**:
- Semi-transparent panel (30% opacity dark background)
- Outlined buttons with distinct borders
- Responsive sizing (landscape vs portrait)
- Shadow effects for depth
- Z-index: 200 (above all game content)

---

## Critical Integration Rules

### Rule 1: PopupContainer Requirement

**ALL popups MUST be children of `PopupContainer`**

```gdscript
# Correct .tscn structure:
[node name="MyPopup" parent="PopupContainer" instance=ExtResource("popup")]

# WRONG - will overlap menus:
[node name="MyPopup" parent="." instance=ExtResource("popup")]
```

**Why**: ResponsiveLayout calculates available space in CenterArea/MiddleArea to prevent menu overlap. Only works if popup is in PopupContainer.

### Rule 2: Hide PopupContainer After Use

**CRITICAL**: PopupContainer blocks clicks even when popups are hidden!

```gdscript
func _on_popup_button_pressed(button_text: String):
    # Handle button press...

    # MUST hide container when done:
    var popup_container = get_node_or_null("PopupContainer")
    if popup_container:
        popup_container.visible = false
```

**Symptom**: Buttons stop working in portrait mode after closing popup
**Cause**: PopupContainer has high z-index and blocks clicks
**Fix**: Hide container when popup sequence completes

### Rule 3: Setup Once, Show Many Times

```gdscript
# In _ready():
popup.setup("Message", ["Button1", "Button2"])
popup.hide_popup()  # Hide by default

# Later, when needed:
popup.show_popup()  # Don't call setup() again
```

**Why**: `setup()` recreates buttons and may cause layout issues if called repeatedly

---

## API Reference

### Methods

#### `setup(message: String, button_texts: Array, auto_resize: bool = true) -> void`
Configure popup content and buttons

**Call once** in `_ready()`, not every time you show the popup

**Parameters**:
- `message`: Main text (auto-wraps)
- `button_texts`: Button labels array
- `auto_resize`: Auto-calculate popup size

**Example**:
```gdscript
popup.setup("Delete this save?", ["Delete", "Cancel"])
```

#### `show_popup() -> void`
Display the popup (centers, shows, raises z-index)

**Don't use** `visible = true` - use this method!

#### `hide_popup() -> void`
Hide the popup

**Note**: Automatically called when any button is pressed

### Signals

#### `button_pressed(button_text: String)`
Emitted when button clicked (popup auto-hides after emission)

```gdscript
popup.button_pressed.connect(_on_popup_button_pressed)

func _on_popup_button_pressed(button_text: String):
    match button_text:
        "Save": save_game()
        "Quit": quit_game()
```

---

## Implementation Patterns

### Pattern 1: Pre-Instantiated Popup (Recommended)

**When to use**: Scene always needs the same popup

**In .tscn**:
```gdscript
[ext_resource type="PackedScene" path="res://reusable_popup.tscn" id="popup"]
[node name="ConfirmPopup" parent="PopupContainer" instance=ExtResource("popup")]
```

**In .gd**:
```gdscript
@onready var confirm_popup = $PopupContainer/ConfirmPopup

func _ready():
    confirm_popup.setup("Are you sure?", ["Yes", "No"])
    confirm_popup.hide_popup()
    confirm_popup.button_pressed.connect(_on_confirm_button_pressed)

func ask_confirmation():
    confirm_popup.show_popup()

func _on_confirm_button_pressed(btn: String):
    if btn == "Yes":
        do_action()
    # Hide container when done
    $PopupContainer.visible = false
```

### Pattern 2: Dynamic Instantiation

**When to use**: One-time notifications or dynamic content

```gdscript
func show_notification(message: String):
    var popup = load("res://reusable_popup.tscn").instantiate()
    get_tree().root.add_child(popup)
    popup.setup(message, ["OK"])
    popup.show_popup()
    popup.button_pressed.connect(func(btn): popup.queue_free())
```

### Pattern 3: Sequential Popups (Conversations)

**Example from bar.gd**:
```gdscript
# Two popups, one after another
@onready var popup1 = $PopupContainer/FirstPopup
@onready var popup2 = $PopupContainer/SecondPopup

func _ready():
    popup1.setup("Part 1 of conversation", ["Continue"])
    popup1.hide_popup()
    popup1.button_pressed.connect(_on_popup1_pressed)

    popup2.setup("Part 2 of conversation", ["OK"])
    popup2.hide_popup()
    popup2.button_pressed.connect(_on_popup2_pressed)

func show_sequence():
    popup1.show_popup()

func _on_popup1_pressed(btn: String):
    popup2.show_popup()  # Show next popup

func _on_popup2_pressed(btn: String):
    # End of sequence - hide container
    $PopupContainer.visible = false
```

---

## Theme System

**File**: [default_theme.tres](../../default_theme.tres)

### StyledPopup Variation

```gdscript
StyledPopup/base_type = &"Panel"
StyledPopup/styles/panel = StyleBoxFlat_popup_panel
```

**Properties**:
- Background: `Color(0.25, 0.25, 0.25, 0.15)` (dark gray, 15% opacity)
- Border: 2px gray, 50% opacity
- Corner radius: 8px
- Shadow: 8px blur, 4px offset
- Content margin: 20px all sides

### PopupButton Variation

```gdscript
PopupButton/base_type = &"Button"
PopupButton/styles/normal = StyleBoxFlat_popup_button_normal
PopupButton/styles/hover = StyleBoxFlat_popup_button_hover
PopupButton/styles/pressed = StyleBoxFlat_popup_button_pressed
```

**States**:
- Normal: Medium gray + 2px border
- Hover: Lighter background + bright border
- Pressed: Darker background + subtle border

### PopupVBox Variation

```gdscript
PopupVBox/base_type = &"VBoxContainer"
PopupVBox/constants/separation = 15
```

**Purpose**: Provides consistent spacing between popup elements
**Usage**: Apply to VBoxContainers inside custom popups

---

## Responsive Behavior

### Landscape Mode
- Max width: 600px OR (CenterArea width - 40px margins), whichever is smaller
- Centered in CenterArea (between LeftVBox and RightVBox)
- Buttons horizontal

### Portrait Mode
- Max width: 90% of viewport width
- Centered in MiddleArea (between TopVBox and BottomVBox)
- Buttons horizontal (text wraps if needed)

**Auto-handled by**: `ResponsiveLayout.apply_to_scene()`

---

## Common Issues & Solutions

### Issue: Popup doesn't appear
**Causes**:
1. Forgot to call `show_popup()` (used `visible = true` instead)
2. Z-index too low
3. Popup not in scene tree

**Solution**: Always use `show_popup()` method

### Issue: Buttons stop working after popup closes (portrait mode)
**Cause**: PopupContainer still visible and blocking clicks

**Solution**:
```gdscript
func _on_popup_button_pressed(btn: String):
    # Handle button...

    # MUST DO THIS:
    $PopupContainer.visible = false
```

### Issue: Buttons have no borders
**Cause**: Button doesn't have `theme_type_variation = &"PopupButton"`

**Solution**: Check button nodes in popup scene have theme variation set

### Issue: Popup wrong size
**Cause**: Auto-resize disabled or manual size overrides

**Solution**:
- Enable auto-resize: `setup(msg, btns, true)`
- Remove manual `custom_minimum_size` overrides in .tscn

---

## Creating Custom Popups

**When to use custom popups instead of reusable_popup**:
- Need persistent UI elements (not just buttons)
- Complex layouts (multiple columns, grids, etc.)
- Interactive elements (sliders, text input, etc.)

**Required Structure for Custom Popups**:

```gdscript
[node name="CustomPopup" type="Panel" parent="PopupContainer"]
theme_type_variation = &"StyledPopup"  # REQUIRED: Themed panel
visible = false

[node name="MarginContainer" type="MarginContainer" parent="PopupContainer/CustomPopup"]
# REQUIRED: 10px margins on all sides
theme_override_constants/margin_left = 10
theme_override_constants/margin_top = 10
theme_override_constants/margin_right = 10
theme_override_constants/margin_bottom = 10

[node name="VBoxContainer" type="VBoxContainer" parent="PopupContainer/CustomPopup/MarginContainer"]
theme_type_variation = &"PopupVBox"  # REQUIRED: 15px separation between elements

# Your content goes here (labels, buttons, etc.)
```

**Example** (from shop.tscn):
```gdscript
[node name="ShovelUpgradesPopup" type="Panel" parent="PopupContainer"]
theme_type_variation = &"StyledPopup"
# ... positioning ...

[node name="MarginContainer" type="MarginContainer" parent="PopupContainer/ShovelUpgradesPopup"]
theme_override_constants/margin_left = 10
theme_override_constants/margin_top = 10
theme_override_constants/margin_right = 10
theme_override_constants/margin_bottom = 10

[node name="VBoxContainer" type="VBoxContainer" parent="PopupContainer/ShovelUpgradesPopup/MarginContainer"]
theme_type_variation = &"PopupVBox"

[node name="TitleLabel" type="Label" parent="PopupContainer/ShovelUpgradesPopup/MarginContainer/VBoxContainer"]
text = "Title"

[node name="Button1" type="Button" parent="PopupContainer/ShovelUpgradesPopup/MarginContainer/VBoxContainer"]
theme_type_variation = &"PopupButton"
```

---

## When Creating/Modifying Popups

**Do**:
- ✅ Put all popups in PopupContainer
- ✅ Use StyledPopup theme variation for Panel
- ✅ Wrap content in MarginContainer (10px margins)
- ✅ Use PopupVBox theme for VBoxContainers
- ✅ Use PopupButton theme for all buttons
- ✅ Setup once in `_ready()`, hide by default
- ✅ Hide PopupContainer when sequence completes
- ✅ Use descriptive button labels ("Save and Quit" not "OK")

**Don't**:
- ❌ Add popups as direct children of root
- ❌ Forget MarginContainer or VBoxContainer spacing
- ❌ Skip theme variations (causes visual inconsistency)
- ❌ Forget to hide PopupContainer after closing
- ❌ Use `visible = true/false` directly for reusable_popup
- ❌ Create more than 3-4 buttons (UI gets cramped)

---

## Testing Checklist

When implementing popups:
1. [ ] Popup in PopupContainer?
2. [ ] StyledPopup theme applied to Panel?
3. [ ] MarginContainer with 10px margins?
4. [ ] PopupVBox theme applied to VBoxContainer?
5. [ ] PopupButton theme applied to all buttons?
6. [ ] Setup called in `_ready()` (if using reusable_popup)?
7. [ ] Hidden by default?
8. [ ] Signal connected (if using reusable_popup)?
9. [ ] PopupContainer hidden after sequence?
10. [ ] Tested in landscape mode?
11. [ ] Tested in portrait mode?
12. [ ] Buttons clickable after closing?
13. [ ] No overlapping elements (title, buttons)?

---

**Related Docs**:
- [scene-template.md](scene-template.md) - Scene structure
- [responsive-layout.md](responsive-layout.md) - Responsive scaling
- [theme-system.md](theme-system.md) - Theme variations
- [godot-dev.md](godot-dev.md) - Godot patterns

**Version**: 2.1 (Added custom popup guidelines & PopupVBox theme)
**Last Updated**: 2025-10-30
