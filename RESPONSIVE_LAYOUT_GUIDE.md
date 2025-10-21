# Responsive Layout System Guide

## Overview

The **ResponsiveLayout** autoload provides centralized scaling configuration for all game scenes. Change values in one place and ALL scenes update automatically.

## Files

- **Configuration**: [responsive_layout.gd](c:\Goa\responsive_layout.gd) - Autoload singleton
- **Template**: [level1/scene_template.tscn](c:\Goa\level1\scene_template.tscn) - Base scene structure
- **Example**: [level1/test.gd](c:\Goa\level1\test.gd) - Implementation example

## How It Works

### Centralized Constants (responsive_layout.gd)

All scaling values are defined in ONE place:

```gdscript
# Portrait mode scaling factors
const PORTRAIT_BUTTON_HEIGHT = 105
const PORTRAIT_PANEL_HEIGHT = 70
const PORTRAIT_FONT_SCALE = 1.75
const PORTRAIT_TOP_PADDING = 90
const PORTRAIT_BOTTOM_PADDING = 90

# Landscape mode defaults
const LANDSCAPE_PANEL_HEIGHT = 24
const LANDSCAPE_BUTTON_HEIGHT = 0  # 0 = auto

# Column widths (from template)
const LEFT_COLUMN_WIDTH = 220
const RIGHT_COLUMN_WIDTH = 260

# Container dimensions (from template)
const CONTAINER_WIDTH = 500
const CONTAINER_HEIGHT = 600
```

### Usage in Scene Scripts

**Simple - Just one line in _ready():**

```gdscript
extends Control

func _ready():
	ResponsiveLayout.apply_to_scene(self)
	# Your other initialization...
```

That's it! The ResponsiveLayout autoload handles everything:
- ✅ Detects portrait vs landscape
- ✅ Reparents columns to correct containers
- ✅ Scales buttons, panels, and fonts
- ✅ Resets everything when switching orientations
- ✅ Automatically adds settings overlay (gear button in bottom-right)
- ✅ **Uses call_deferred to ensure scene tree is fully ready** (critical for inherited scenes!)
- ✅ **Ensures mouse_filter is PASS on Background and all containers at runtime** (fixes button clicks!)

## Making Global Changes

### Example 1: Change Portrait Button Height

**Before**: Buttons are 105px tall in portrait mode
**Want**: Buttons should be 120px tall

**Solution**:
1. Open [responsive_layout.gd](c:\Goa\responsive_layout.gd)
2. Change line: `const PORTRAIT_BUTTON_HEIGHT = 105` → `const PORTRAIT_BUTTON_HEIGHT = 120`
3. Save

**Result**: ALL scenes using ResponsiveLayout now have 120px buttons in portrait mode!

### Example 2: Increase Font Scaling

**Before**: Fonts scale by 1.75x in portrait mode
**Want**: Fonts should scale by 2.0x for better readability

**Solution**:
1. Open [responsive_layout.gd](c:\Goa\responsive_layout.gd)
2. Change line: `const PORTRAIT_FONT_SCALE = 1.75` → `const PORTRAIT_FONT_SCALE = 2.0`
3. Save

**Result**: ALL text becomes 2x larger in portrait mode across all scenes!

### Example 3: Adjust Column Widths

**Before**: LeftVBox is 220px, RightVBox is 260px
**Want**: Equal width columns (240px each)

**Solution**:
1. Open [responsive_layout.gd](c:\Goa\responsive_layout.gd)
2. Change:
   ```gdscript
   const LEFT_COLUMN_WIDTH = 220
   const RIGHT_COLUMN_WIDTH = 260
   ```
   to:
   ```gdscript
   const LEFT_COLUMN_WIDTH = 240
   const RIGHT_COLUMN_WIDTH = 240
   ```
3. Open [level1/scene_template.tscn](c:\Goa\level1\scene_template.tscn)
4. Update the template columns to match:
   - LeftVBox: `custom_minimum_size = Vector2(240, 0)`
   - RightVBox: `custom_minimum_size = Vector2(240, 0)`

**Result**: All inherited scenes now have equal width columns!

## Scene Requirements

For ResponsiveLayout to work, scenes must have this structure (provided by scene_template.tscn):

```
SceneRoot (Control)
├── Background (TextureRect) - mouse_filter = PASS (2) ⚠️ CRITICAL
├── HBoxContainer - mouse_filter = PASS (2)
│   ├── LeftVBox - mouse_filter = PASS (2)
│   └── RightVBox - mouse_filter = PASS (2)
└── VBoxContainer - mouse_filter = PASS (2)
    ├── TopPadding
    ├── TopVBox
    ├── Spacer
    ├── BottomVBox
    └── BottomPadding
```

**CRITICAL**: The **Background** TextureRect and all container nodes must have `mouse_filter = 2` (PASS) set to ensure buttons are clickable. The Background is full-screen and will block ALL clicks if not set to PASS!

**If using scene_template.tscn as base**: ✅ Structure already correct (includes mouse_filter on Background and containers)
**If creating custom scene**: ⚠️ Must follow this naming convention AND set mouse_filter = 2 on Background and all containers

## Migration Guide

### Migrating Existing Scenes

If you have scenes with custom `apply_mobile_scaling()` functions:

**Before** (old custom code in each scene):
```gdscript
extends Control

@onready var hbox_container = $HBoxContainer
@onready var vbox_container = $VBoxContainer
# ... lots of node references ...
var is_portrait_mode = false

func _ready():
	apply_mobile_scaling()

func apply_mobile_scaling():
	# 50+ lines of scaling logic...
```

**After** (using ResponsiveLayout):
```gdscript
extends Control

func _ready():
	ResponsiveLayout.apply_to_scene(self)
	# Other initialization...
```

**Steps**:
1. Remove all `@onready` container references (unless needed for other logic)
2. Remove `is_portrait_mode` variable
3. Remove entire `apply_mobile_scaling()` function
4. Add single line: `ResponsiveLayout.apply_to_scene(self)` in `_ready()`
5. Test!

### Example: Migrating dream.gd

**Original dream.gd**: ~100 lines with custom scaling logic
**Migrated dream.gd**:

```gdscript
extends Control

@onready var stamina_bar = $HBoxContainer/LeftVBox/StaminaPanel/StaminaBar
var stamina_timer = 0.0

func _ready():
	ResponsiveLayout.apply_to_scene(self)  # ← Add this line
	update_stamina_bar()

# Rest of dream-specific logic...
```

## Advanced Usage

### Utility Functions

```gdscript
# Check if currently in portrait mode
if ResponsiveLayout.is_portrait_mode(get_viewport()):
	print("Portrait!")

# Get current font scale factor (1.0 or 1.75)
var scale = ResponsiveLayout.get_font_scale(get_viewport())
```

### Custom Scaling for Specific Scenes

If a scene needs different scaling behavior:

```gdscript
func _ready():
	# Apply standard responsive layout first
	ResponsiveLayout.apply_to_scene(self)

	# Then add scene-specific customization
	if ResponsiveLayout.is_portrait_mode(get_viewport()):
		custom_portrait_adjustments()

func custom_portrait_adjustments():
	# Scene-specific overrides here
	$SpecialButton.custom_minimum_size = Vector2(0, 150)
```

## Configuration Reference

### All Available Constants

| Constant | Default | Description |
|----------|---------|-------------|
| `PORTRAIT_BUTTON_HEIGHT` | 105 | Button height in portrait mode (px) |
| `PORTRAIT_PANEL_HEIGHT` | 70 | Panel height in portrait mode (px) |
| `PORTRAIT_FONT_SCALE` | 1.75 | Font size multiplier for portrait (1.75 = 175%) |
| `PORTRAIT_TOP_PADDING` | 90 | Top padding for portrait layout (px) |
| `PORTRAIT_BOTTOM_PADDING` | 90 | Bottom padding for portrait layout (px) |
| `LANDSCAPE_PANEL_HEIGHT` | 24 | Panel height in landscape mode (px) |
| `LANDSCAPE_BUTTON_HEIGHT` | 0 | Button height in landscape (0 = auto) |
| `LEFT_COLUMN_WIDTH` | 220 | Minimum width for left column (px) |
| `RIGHT_COLUMN_WIDTH` | 260 | Minimum width for right column (px) |
| `CONTAINER_WIDTH` | 500 | HBoxContainer width in landscape (px) |
| `CONTAINER_HEIGHT` | 600 | HBoxContainer height in landscape (px) |

### Common Adjustments

**Make portrait UI bigger:**
```gdscript
const PORTRAIT_BUTTON_HEIGHT = 120  # was 105
const PORTRAIT_PANEL_HEIGHT = 80    # was 70
const PORTRAIT_FONT_SCALE = 2.0     # was 1.75
```

**Make portrait UI smaller:**
```gdscript
const PORTRAIT_BUTTON_HEIGHT = 90   # was 105
const PORTRAIT_PANEL_HEIGHT = 60    # was 70
const PORTRAIT_FONT_SCALE = 1.5     # was 1.75
```

**Change landscape container size:**
```gdscript
const CONTAINER_WIDTH = 600   # was 500 (wider)
const CONTAINER_HEIGHT = 700  # was 600 (taller)
```

## Testing Changes

After modifying responsive_layout.gd:

1. **Save the file**
2. **Reload Godot** (or press F5 to restart game)
3. **Test multiple scenes** - all should reflect new values
4. **Test both orientations** - resize viewport to check

## Benefits

✅ **Single source of truth** - All scaling in one file
✅ **No code duplication** - Each scene just calls one function
✅ **Easy experimentation** - Change one value, see it everywhere
✅ **Consistent UX** - All scenes behave the same way
✅ **Quick iteration** - Adjust constants without editing scenes

## Scenes Using ResponsiveLayout

- [level1/test.tscn](c:\Goa\level1\test.tscn) - Example implementation
- Add more scenes here as you migrate them...

## Best Practices

### Do:
✅ Always call `ResponsiveLayout.apply_to_scene(self)` in `_ready()`
✅ Test changes in both portrait and landscape
✅ Use scene_template.tscn for new scenes (correct structure)
✅ Document any scene-specific overrides

### Don't:
❌ Hardcode scaling values in individual scenes
❌ Duplicate the responsive logic across multiple scenes
❌ Call `apply_to_scene()` multiple times (once is enough)
❌ Modify ResponsiveLayout constants at runtime (they're constants!)

## Troubleshooting

**Q: Changes to responsive_layout.gd don't appear**
A: Restart Godot. Autoload scripts are cached and need reload.

**Q: Scene doesn't respond to scaling**
A: Check scene structure matches requirements (HBoxContainer, VBoxContainer, etc.)

**Q: Getting "missing required container nodes" warning**
A: Scene is missing HBoxContainer, LeftVBox, RightVBox, TopVBox, or BottomVBox nodes

**Q: Want different scaling for one scene**
A: Call `ResponsiveLayout.apply_to_scene(self)` first, then add custom adjustments after

**Q: Can I change constants at runtime?**
A: No, they're constants. You'd need scene-specific logic for dynamic changes.

**Q: Buttons aren't clickable in my scene**
A: **FIXED AUTOMATICALLY!** As of the latest update, `ResponsiveLayout.apply_to_scene()` automatically sets `mouse_filter = PASS` on the Background and all container nodes at runtime. Just call `ResponsiveLayout.apply_to_scene(self)` in your `_ready()` function and buttons will work!

  If you're NOT using ResponsiveLayout for some reason, you can manually set:
  - Background → Inspector → Mouse → Filter → "Pass"
  - HBoxContainer, VBoxContainer, LeftVBox, RightVBox → same setting

  **Root cause**: The Background TextureRect is full-screen and blocks ALL mouse events unless mouse_filter is set to PASS.

## Future Enhancements

Consider adding:
- Device-specific presets (phone, tablet, desktop)
- Orientation change detection at runtime
- Animation transitions when switching layouts
- Different scaling profiles for different scene types

## Related Documentation

- [SCENE_TEMPLATE_GUIDE.md](c:\Goa\SCENE_TEMPLATE_GUIDE.md) - Scene template inheritance
- [CLAUDE.md](c:\Goa\CLAUDE.md) - Project overview
- [default_theme.tres](c:\Goa\default_theme.tres) - Visual styling reference
