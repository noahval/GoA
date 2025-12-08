# Default Theme Implementation

This test project demonstrates the complete default theme system as specified in plan 1.9-default-theme.md.

## Files Created

- **default_theme.tres** - Main theme resource with all button variations and UI styles
- **theme_test.tscn** - Test scene showcasing all button types and states
- **project.godot** - Updated with theme reference in [gui] section

## Button Types Available

### 1. Standard Button (Orange)
- **Usage**: Default buttons, cancel, decline, neutral actions
- **How to use**: Just create a Button node - it inherits the standard orange theme automatically
- **States**: Normal (dark orange), Hover (lighter orange), Pressed (darker orange), Disabled (grey)

### 2. Affirmative Button (Blue)
- **Usage**: Positive actions like Yes, OK, Confirm, Accept
- **How to use**: Set `theme_type_variation = &"AffirmativeButton"` on the Button node
- **States**: Normal (blue), Hover (lighter blue), Pressed (darker blue), Disabled (grey)

### 3. ForwardNav Button (Light Blue)
- **Usage**: Navigation forward into scenes - Enter, Explore, Continue
- **How to use**: Set `theme_type_variation = &"ForwardNavButton"` on the Button node
- **Visual Features**: 2px border (thicker), 6px corner radius, shadow effect, sky blue text
- **States**: Normal, Hover (shadow grows), Pressed (shadow shrinks), Disabled (grey)

### 4. BackNav Button (Navy Blue)
- **Usage**: Navigation back to previous scenes - Return, Exit, Leave
- **How to use**: Set `theme_type_variation = &"BackNavButton"` on the Button node
- **Visual Features**: 1px border (thinner), 6px corner radius, minimal shadow, steel blue text
- **States**: Normal, Hover, Pressed, Disabled (grey)

### 5. Danger Button (Red)
- **Usage**: Destructive actions - Delete, Destroy, Quit Without Saving
- **How to use**: Set `theme_type_variation = &"DangerButton"` on the Button node
- **Visual Features**: 2px warning border (bright red), light pink-white text
- **States**: Normal (dark red), Hover (brighter red + yellow text), Pressed (darker red), Disabled (grey)

## Other UI Elements

### Panel
- Dark orange background (30% opacity)
- 4px corner radius
- Used for container panels and info displays

### Label
- White text by default
- Transparent background (no collision with panel colors)
- Optional highlighted background (dark grey 50% opacity) for emphasis

### ProgressBar
- Template structure with transparent dark grey background
- Default fill: Green (30% opacity) - suitable for health bars
- Customize fill color for different bar types (stamina, suspicion, heat, XP)

## Testing the Theme

1. Open **theme_test.tscn** in Godot Editor
2. Run the scene (F5 or F6)
3. Hover over buttons to see hover states
4. Click buttons to see pressed states
5. Observe disabled buttons are clearly grey and unclickable

## Visual Hierarchy

The theme creates natural visual hierarchy:
- **Forward Nav** (2px border + shadow) > **Back Nav** (1px border + minimal shadow)
- **Danger** (red, warning border) stands out for destructive actions
- **Affirmative** (blue) vs **Standard** (orange) clearly distinguishes positive from neutral
- **Disabled** (grey, low opacity) is obviously not clickable

## Usage in Code

```gdscript
# Standard button - no extra code needed
var standard_btn = Button.new()
standard_btn.text = "Cancel"

# Affirmative button
var confirm_btn = Button.new()
confirm_btn.text = "OK"
confirm_btn.theme_type_variation = &"AffirmativeButton"

# Forward navigation button
var enter_btn = Button.new()
enter_btn.text = "Enter"
enter_btn.theme_type_variation = &"ForwardNavButton"

# Back navigation button
var back_btn = Button.new()
back_btn.text = "Return"
back_btn.theme_type_variation = &"BackNavButton"

# Danger button
var delete_btn = Button.new()
delete_btn.text = "Delete Save"
delete_btn.theme_type_variation = &"DangerButton"
```

## Color Palette Reference

- **Orange** (Standard): #5C2E00 base, warm industrial theme
- **Blue** (Affirmative): #026a9e, trustworthy confirmation
- **Light Blue** (Forward Nav): #4169E1 royal blue, progress
- **Navy Blue** (Back Nav): #000080, retreat/safety
- **Red** (Danger): #CC1A1A, warning/caution
- **Grey** (Disabled): Low opacity, clearly inactive

## Notes

- All font sizing should be managed by ResponsiveLayout system (see plan 1.10)
- Theme handles colors, borders, and visual styling only
- Animation for button state transitions is planned for a future phase
- Shadow performance optimization will be addressed in the animation section
- No emoji or unicode symbols used - ASCII only for web compatibility
