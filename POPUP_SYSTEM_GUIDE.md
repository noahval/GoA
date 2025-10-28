# Reusable Popup System Guide

## Overview

GoA now has a professional, reusable popup dialog system that provides consistent, beautiful popups across all scenes. The system features:

- **Professional styling** with semi-transparent dark backgrounds (30% opacity - lets you see the background)
- **Outlined buttons** with borders that distinguish them clearly
- **Automatic responsive sizing** that adapts to landscape and portrait orientations
- **Easy-to-use API** for creating popups with custom messages and buttons
- **Shadow effects** for depth and visual polish
- **Centralized theming** via `default_theme.tres`

## Quick Start

### Method 1: Using Existing Popup Instance (Recommended)

Best for scenes that always need the same popups (like dialog scenes):

**CRITICAL**: Popups must be children of `PopupContainer` to avoid overlapping with menus!

**In your scene file (.tscn):**
```gdscript
[ext_resource type="PackedScene" uid="uid://reusable_popup" path="res://reusable_popup.tscn" id="4_popup"]

[node name="MyPopup" parent="PopupContainer" instance=ExtResource("4_popup")]
```

**Note**: `parent="PopupContainer"` NOT `parent="."` - this is essential!

**In your script (_ready function):**
```gdscript
@onready var my_popup = $PopupContainer/MyPopup

func _ready():
    # Setup the popup with your message and buttons
    my_popup.setup("Your message here", ["Button 1", "Button 2"])
    my_popup.hide_popup()

    # Connect to the button_pressed signal (in .tscn or in code)
    # In .tscn:
    # [connection signal="button_pressed" from="MyPopup" to="." method="_on_my_popup_button_pressed"]
```

**Handle button presses:**
```gdscript
func _on_my_popup_button_pressed(button_text: String):
    if button_text == "Button 1":
        print("User clicked Button 1")
    elif button_text == "Button 2":
        print("User clicked Button 2")

    # CRITICAL: Hide PopupContainer when popup sequence is complete
    # This ensures buttons remain clickable in portrait mode
    var popup_container = get_node_or_null("PopupContainer")
    if popup_container:
        popup_container.visible = false
```

**Show the popup:**
```gdscript
func some_trigger_function():
    my_popup.show_popup()
```

### Method 2: Creating Popups Dynamically

Best for one-time notifications or dynamic content:

```gdscript
func show_notification():
    # Load and instantiate the popup scene
    var popup_scene = load("res://reusable_popup.tscn")
    var popup = popup_scene.instantiate()
    get_tree().root.add_child(popup)

    # Setup and show
    popup.setup("This is a notification!", ["OK"])
    popup.show_popup()

    # Connect signal
    popup.button_pressed.connect(func(btn): print("Clicked:", btn))
```

## API Reference

### ReusablePopup Methods

#### `setup(message: String, button_texts: Array, auto_resize: bool = true) -> void`

Configure the popup with a message and buttons.

**Parameters:**
- `message`: The text to display in the popup
- `button_texts`: Array of button labels (e.g., `["Yes", "No", "Cancel"]`)
- `auto_resize`: If true, popup automatically resizes to fit content

**Example:**
```gdscript
popup.setup(
    "Are you sure you want to quit?",
    ["Yes", "No"]
)
```

#### `show_popup() -> void`

Display the popup. Automatically handles z-index and centering.

**Example:**
```gdscript
popup.show_popup()
```

#### `hide_popup() -> void`

Hide the popup. Note: Popups automatically hide when a button is pressed.

**Example:**
```gdscript
popup.hide_popup()
```

### Signals

#### `button_pressed(button_text: String)`

Emitted when any button in the popup is clicked. The popup automatically closes after emitting this signal.

**Example:**
```gdscript
popup.button_pressed.connect(_on_popup_button_pressed)

func _on_popup_button_pressed(button_text: String):
    match button_text:
        "Save":
            save_game()
        "Don't Save":
            quit_without_saving()
        "Cancel":
            pass  # Popup already closed
```

### Creating Popups Dynamically

For dynamic popup creation, instantiate the scene directly:

**Example:**
```gdscript
func show_level_complete():
    # Load and instantiate
    var popup_scene = load("res://reusable_popup.tscn")
    var popup = popup_scene.instantiate()
    get_tree().root.add_child(popup)

    # Setup
    popup.setup("Level complete! You earned 100 coins.", ["Continue", "View Stats"])
    popup.show_popup()

    # Connect signal
    popup.button_pressed.connect(func(btn):
        if btn == "Continue":
            next_level()
        elif btn == "View Stats":
            show_stats()
    )
```

## Theme Customization

The popup system uses theme variations defined in [default_theme.tres](default_theme.tres):

### PopupPanel Theme

Defines the appearance of the popup panel itself:

```gdscript
PopupPanel/base_type = &"Panel"
PopupPanel/styles/panel = SubResource("StyleBoxFlat_popup_panel")
```

**Properties (in StyleBoxFlat_popup_panel):**
- Background: Dark gray (15% brightness) with 85% opacity
- Border: 2px gray border with 90% opacity
- Corner radius: 8px for smooth rounded corners
- Shadow: 8px blur, 4px offset for depth
- Padding: 20px on all sides

### PopupButton Theme

Defines the appearance of buttons inside popups:

```gdscript
PopupButton/base_type = &"Button"
PopupButton/styles/normal = SubResource("StyleBoxFlat_popup_button_normal")
PopupButton/styles/hover = SubResource("StyleBoxFlat_popup_button_hover")
PopupButton/styles/pressed = SubResource("StyleBoxFlat_popup_button_pressed")
```

**States:**
- **Normal**: Medium gray background with 2px border
- **Hover**: Lighter background, brighter border
- **Pressed**: Darker background, subtle border

**Customizing Colors:**

Edit [default_theme.tres](default_theme.tres) to change colors globally:

```gdscript
# Make popup background darker
bg_color = Color(0.1, 0.1, 0.1, 0.9)  # Darker, more opaque

# Change border color to blue
border_color = Color(0.3, 0.5, 1.0, 1.0)  # Blue border

# Adjust button colors
bg_color = Color(0.2, 0.4, 0.8, 0.8)  # Blue buttons
```

## Integration with Three-Panel Layout

The popup system is **fully integrated** with the three-panel scene template:

### Landscape Mode
- Popups appear in **CenterArea** (between LeftVBox and RightVBox)
- Maximum width: 600px OR available center space minus 40px margins
- Never overlaps with side menus
- Centered horizontally and vertically

### Portrait Mode
- Popups appear in **MiddleArea** (between TopVBox and BottomVBox)
- Maximum width: 90% of viewport width
- Never overlaps with top/bottom menus
- Centered horizontally and vertically

### How It Works

When you call `ResponsiveLayout.apply_to_scene(self)`, the system:
1. Finds all popups in `PopupContainer`
2. Calculates available space in CenterArea (landscape) or MiddleArea (portrait)
3. Constrains popup width to fit within play area
4. Ensures minimum 40px margin from menus

**This happens automatically** - just put your popups in PopupContainer!

## Responsive Behavior

The popup system automatically adapts to different screen sizes and orientations:

### Landscape Mode
- Popup width: Fits content, max 60% of screen width
- Centered horizontally and vertically
- Buttons arranged horizontally

### Portrait Mode
- Popup width: Fits content, max 90% of screen width
- Centered horizontally and vertically
- Text wraps nicely with increased width allowance

### Auto-Resizing

By default, popups automatically resize to fit their content:

- **Width**: Calculated based on message length
- **Height**: Automatically adjusts based on wrapped text and buttons
- **Min Width**: 300px to ensure readability
- **Max Width**: 60% (landscape) or 90% (portrait) of viewport

**Disable auto-resize if needed:**
```gdscript
popup.setup("Message", ["OK"], false)  # auto_resize = false
```

## Examples

### Example 1: Simple Notification

```gdscript
func show_achievement():
    var popup_scene = load("res://reusable_popup.tscn")
    var popup = popup_scene.instantiate()
    get_tree().root.add_child(popup)
    popup.setup("Achievement Unlocked: First Steps!", ["Awesome!"])
    popup.show_popup()
```

### Example 2: Confirmation Dialog

```gdscript
@onready var confirm_popup = $ConfirmPopup

func _ready():
    confirm_popup.setup(
        "Delete this save file?",
        ["Delete", "Cancel"]
    )
    confirm_popup.hide_popup()

func ask_delete_confirmation():
    confirm_popup.show_popup()

func _on_confirm_popup_button_pressed(button_text: String):
    if button_text == "Delete":
        delete_save_file()
    # "Cancel" does nothing - popup auto-closes
```

### Example 3: Multi-Choice Dialog

```gdscript
@onready var choice_popup = $ChoicePopup

func _ready():
    choice_popup.setup(
        "The merchant offers you a strange potion. What do you do?",
        ["Buy it", "Inspect it", "Walk away"]
    )
    choice_popup.hide_popup()

func show_merchant_choice():
    choice_popup.show_popup()

func _on_choice_popup_button_pressed(button_text: String):
    match button_text:
        "Buy it":
            if Level1Vars.coins >= 50:
                Level1Vars.coins -= 50
                Level1Vars.inventory.append("Strange Potion")
        "Inspect it":
            show_inspection_dialog()
        "Walk away":
            Level1Vars.merchant_offended = true
```

### Example 4: Sequential Popups (Bar Scene)

From [bar.gd](level1/bar.gd):

```gdscript
# Setup in _ready()
voice_popup.setup(
    "The voice was coming from further up the train. There's a small door behind the bar that leads ahead.",
    ["enter door", "turn back"]
)
voice_popup.hide_popup()

barkeep_popup.setup(
    "The barkeep sees you. He says \"That's a restricted area, I can't let you pass, although I could be convinced to turn a blind eye...\"",
    ["Ok"]
)
barkeep_popup.hide_popup()

# Show first popup
func _on_follow_voice_button_pressed():
    voice_popup.show_popup()

# Handle first popup response
func _on_voice_popup_button_pressed(button_text: String):
    if button_text == "enter door":
        # Show second popup in sequence
        barkeep_popup.show_popup()

# Handle second popup response
func _on_barkeep_popup_button_pressed(button_text: String):
    if button_text == "Ok":
        # Unlock the bribe option
        Level1Vars.door_discovered = true
        bribe_barkeep_button.visible = true
```

## Best Practices

### DO:
✅ Use descriptive button labels ("Save and Quit" instead of "OK")
✅ Keep messages concise and clear
✅ Use sequential popups for conversations
✅ Connect signals in the scene file or `_ready()` function
✅ Hide popups by default in `_ready()`
✅ **CRITICAL**: Hide PopupContainer when popup sequences complete (see example below)

### DON'T:
❌ Create too many buttons (max 3-4 recommended)
❌ Use very long messages without line breaks
❌ Forget to hide popups after calling setup()
❌ Manually set `visible = true` (use `show_popup()` instead)
❌ Call `setup()` every time you show - set it once in `_ready()`
❌ **CRITICAL**: Forget to hide PopupContainer after popups close (causes buttons to stop working in portrait mode)

## Troubleshooting

**Q: My popup doesn't appear**
- A: Make sure you called `show_popup()`, not just `visible = true`
- A: Check that the popup's z_index is high enough (default: 200)

**Q: Buttons stop working after I close a popup (portrait mode)**
- A: **This is the most common issue!** You must hide PopupContainer after the popup closes
- A: Add this code to your popup button handler:
  ```gdscript
  var popup_container = get_node_or_null("PopupContainer")
  if popup_container:
      popup_container.visible = false
  ```
- A: PopupContainer blocks clicks when visible, even if the popup itself is hidden

**Q: Buttons don't have borders**
- A: Ensure buttons use `theme_type_variation = &"PopupButton"`
- A: Check that `default_theme.tres` is loaded in your scene

**Q: Popup is too small/large**
- A: Auto-resize is enabled by default. Disable it with `setup(msg, btns, false)`
- A: Manually adjust offsets in the .tscn file if needed

**Q: How do I change the background opacity?**
- A: Edit `StyleBoxFlat_popup_panel` in `default_theme.tres`
- A: Change the alpha value in `bg_color = Color(0.15, 0.15, 0.15, 0.85)`

**Q: Can I have different styled popups?**
- A: Yes! Create new StyleBoxFlat resources and theme variations
- A: Or override `theme_type_variation` on individual popup instances

## Future Enhancements

Consider these potential improvements:

- **Animated popups**: Fade in/out or slide animations
- **Icon support**: Add icons next to messages
- **Input fields**: Popups with text input
- **Progress bars**: For loading/waiting popups
- **Custom layouts**: Different button arrangements (vertical, grid)
- **Sound effects**: Audio feedback on popup show/button press

## Related Files

- [reusable_popup.tscn](reusable_popup.tscn) - The popup scene file
- [reusable_popup.gd](reusable_popup.gd) - The popup script with all logic
- [default_theme.tres](default_theme.tres) - Theme definitions for PopupPanel and PopupButton
- [level1/bar.gd](level1/bar.gd) - Example implementation with sequential popups
- [level1/bar.tscn](level1/bar.tscn) - Example scene using reusable popups

## See Also

- [SCENE_TEMPLATE_GUIDE.md](SCENE_TEMPLATE_GUIDE.md) - For overall scene layout
- [RESPONSIVE_LAYOUT_GUIDE.md](RESPONSIVE_LAYOUT_GUIDE.md) - For responsive design patterns
