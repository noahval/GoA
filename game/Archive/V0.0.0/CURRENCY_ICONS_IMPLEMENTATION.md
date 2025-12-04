# Currency Icon System Implementation

## Overview
This document describes the new currency icon system that replaces text-based currency displays (e.g., "C: 1,234") with icon-based displays (e.g., 🪙 1,234) across all scenes.

## ✅ Completed Components

### 1. Icon Assets
**Location:** `level1/icons/`
- `copper_icon.png` - 64x64px copper coin icon
- `silver_icon.png` - 64x64px silver coin icon
- `gold_icon.png` - 64x64px gold coin icon
- `platinum_icon.png` - 64x64px platinum coin icon

**Status:** Scripts created to generate icons. **ACTION REQUIRED:** Run icon generation before testing.

#### How to Generate Icons:
Choose ONE of these methods:

**Option 1: Godot Editor Tool (Recommended)**
1. Open `tool_generate_icons.gd` in Godot Editor
2. Go to File → Run (or press Ctrl+Shift+X)
3. Check console for success messages
4. Right-click FileSystem dock → Reimport to refresh

**Option 2: Headless Batch File**
```bash
# From project directory
run generate_icons.bat
```

**Option 3: Python Script**
```bash
# Requires: pip install Pillow
python generate_currency_icons.py
```

### 2. Currency Panel Component
**File:** `currency_panel.gd`
**Class Name:** `CurrencyPanel`

**Key Features:**
- Automatically creates icon + label pairs for each currency
- Handles portrait/landscape orientation changes
- Calculates minimum width including icons
- Updates values without rebuilding structure

**API:**
```gdscript
# Setup display (creates structure)
func setup_currency_display(currencies: Array)
# currencies = [{"icon": "res://...", "value": "1,234"}, ...]

# Update values only (fast)
func update_currency_values(new_values: Array)

# Calculate width for ResponsiveLayout
func calculate_minimum_width() -> float

# Update icon sizes for orientation
func update_icon_sizes_for_orientation(is_portrait: bool)
```

### 3. Currency Manager Updates
**File:** `currency_manager.gd`

**New Functions:**
```gdscript
# Get icon path for currency type
static func get_currency_icon(currency_type: int) -> String

# Format currency for icon display
func format_currency_for_icons(show_all: bool = false) -> Array
# Returns: [{"icon": "res://...", "value": "1,234"}, ...]
```

**New Constants:**
```gdscript
const CURRENCY_ICONS = {
	CurrencyType.COPPER: "res://level1/icons/copper_icon.png",
	CurrencyType.SILVER: "res://level1/icons/silver_icon.png",
	CurrencyType.GOLD: "res://level1/icons/gold_icon.png",
	CurrencyType.PLATINUM: "res://level1/icons/platinum_icon.png"
}
```

### 4. Responsive Layout Integration
**File:** `responsive_layout.gd`

**Changes:**
- `_scale_for_portrait()` - Detects and updates CurrencyPanel icon sizes
- `_reset_portrait_scaling()` - Resets CurrencyPanel to landscape mode
- `_calculate_max_panel_width()` - Uses CurrencyPanel.calculate_minimum_width()

**Icon Sizes:**
- Landscape: 32x32px
- Portrait: 34x34px

### 5. Updated Scenes
**Completed:**
- ✅ `level1/furnace.tscn` + `furnace.gd`
- ✅ `level1/bar.tscn` + `bar.gd`

**Remaining (Need Updates):**
- ⏳ `level1/shop.tscn` + `shop.gd`
- ⏳ `level1/overseers_office.tscn` + script
- ⏳ `level1/coppersmith_carriage.tscn` + script
- ⏳ `level1/dorm.tscn` + script
- ⏳ `level1/atm.tscn` + script

### 6. Test Suite
**Files:**
- `tests/test_currency_icons.gd` - Unit tests (7 tests)
- `tests/test_currency_icons_integration.gd` - Integration tests (4 tests)
- `tests/test_runner.gd` - Updated to include new tests

**Test Coverage:**
1. Icon files exist and are 64x64
2. CurrencyManager icon paths correct
3. CurrencyManager.format_currency_for_icons() structure
4. CurrencyPanel structure creation
5. Icon sizes for portrait/landscape
6. Panel width calculation includes icons
7. Value updates without rebuilding
8. Furnace scene has CurrencyPanel
9. ResponsiveLayout integration
10. Icon size updates with responsive layout
11. Currency display updates when values change

**Run Tests:**
```bash
run_tests.bat
# Or manually:
godot --headless --script res://tests/test_runner.gd
```

## 📝 Remaining Work

### Step 1: Generate Icons
**CRITICAL:** Must be done before testing anything!

Run `tool_generate_icons.gd` from Godot Editor or use alternative methods above.

### Step 2: Update Remaining Scenes

For each scene (`shop.tscn`, `overseers_office.tscn`, etc.):

**Scene File (.tscn):**
1. Add currency_panel.gd as external resource:
```gdscript
[ext_resource type="Script" path="res://currency_panel.gd" id="currency_panel_script"]
```

2. Replace CoinsPanel structure:
```gdscript
# BEFORE:
[node name="CoinsPanel" type="Panel" parent="..."]
...
[node name="CoinsLabel" type="Label" parent=".../CoinsPanel"]
text = "Coins: 0"
...

# AFTER:
[node name="CoinsPanel" type="Panel" parent="..."]
script = ExtResource("currency_panel_script")
```

**Script File (.gd):**
1. Change `@onready` reference:
```gdscript
# BEFORE:
@onready var coins_label = $.../CoinsPanel/CoinsLabel

# AFTER:
@onready var coins_panel = $.../CoinsPanel
```

2. Add currency display function:
```gdscript
func _update_currency_display():
	if coins_panel:
		var currency_data = CurrencyManager.format_currency_for_icons(false)
		coins_panel.setup_currency_display(currency_data)
```

3. Replace all `coins_label.text =` calls with `_update_currency_display()`

**Example Pattern:**
```gdscript
# BEFORE:
coins_label.text = CurrencyManager.format_currency_display(false, true)

# AFTER:
_update_currency_display()
```

### Step 3: Test Implementation
1. Generate icons (if not done)
2. Open Godot Editor
3. Run furnace scene - verify currency displays with icons
4. Test portrait/landscape switching
5. Test currency value updates
6. Run headless tests: `run_tests.bat`

### Step 4: Update Documentation
**Files to Update:**
- `.claude/docs/theme-system.md` - Add currency icon system section
- `.claude/docs/game-systems.md` - Update currency display section

## 🎨 Design Specifications

### Icon Layout Structure
```
CurrencyPanel (Panel)
└── MarginContainer (8px margins)
    └── HBoxContainer (center alignment)
        ├── TextureRect (icon, 32x32)
        ├── Control (spacer, 8px)
        ├── Label (value, e.g., "1,234")
        ├── Label (separator " | ")
        ├── TextureRect (next icon)
        └── ...
```

### Sizing Rules
- **Margins:** 8px top/bottom, 8px left/right
- **Icon Size (Landscape):** 32x32px
- **Icon Size (Portrait):** 34x34px
- **Icon-Label Spacing:** 8px
- **Currency Spacing:** 12px
- **Panel Height:** 40px (landscape), 42px (portrait)

### Display Logic
- Shows only non-zero currencies by default
- Always shows at least copper (even if zero)
- Separator (" | ") between multiple currencies
- Icon replaces "C:", "S:", etc. prefixes
- Values formatted with commas (e.g., "1,234")

## 🔧 Troubleshooting

### Icons Not Showing
1. Verify icons generated: Check `level1/icons/` directory
2. Check file paths in CurrencyManager.CURRENCY_ICONS
3. Verify scene has `script = ExtResource("currency_panel_script")`
4. Check console for "Icon not found" errors

### Icons Wrong Size
1. Verify ResponsiveLayout.apply_to_scene() called in _ready()
2. Check icon generation produced 64x64 images
3. Test orientation switching

### Panel Too Wide/Narrow
1. CurrencyPanel calculates width automatically
2. ResponsiveLayout uses calculate_minimum_width()
3. Check margins and spacing constants in currency_panel.gd

### Tests Failing
1. Ensure icons generated before running tests
2. Check test output for specific failures
3. Verify CurrencyManager and ResponsiveLayout changes applied
4. Test scenes load correctly in Godot Editor first

## 📦 File Summary

**New Files:**
- `currency_panel.gd` - Reusable currency display component
- `tool_generate_icons.gd` - Godot editor tool to generate icons
- `generate_currency_icons.gd` - Headless GDScript icon generator
- `generate_currency_icons.py` - Python icon generator
- `generate_icons.bat` - Batch file to run icon generator
- `tests/test_currency_icons.gd` - Unit tests
- `tests/test_currency_icons_integration.gd` - Integration tests
- `level1/icons/` - Icon directory (created)
- `level1/icons/*.png` - 64x64 currency icons (to be generated)

**Modified Files:**
- `currency_manager.gd` - Added icon paths and format_currency_for_icons()
- `responsive_layout.gd` - Added CurrencyPanel support
- `level1/furnace.tscn` + `furnace.gd` - Using CurrencyPanel
- `level1/bar.tscn` + `bar.gd` - Using CurrencyPanel
- `tests/test_runner.gd` - Added new test suites

**Remaining Files to Update:**
- `level1/shop.tscn` + `shop.gd`
- `level1/overseers_office.tscn` + script
- `level1/coppersmith_carriage.tscn` + script
- `level1/dorm.tscn` + script
- `level1/atm.tscn` + script
- `.claude/docs/theme-system.md`
- `.claude/docs/game-systems.md`

## 🚀 Quick Start

1. **Generate Icons:**
   ```bash
   # In Godot Editor:
   Open tool_generate_icons.gd → File → Run
   ```

2. **Test Furnace Scene:**
   ```bash
   # In Godot Editor:
   Press F5 or click Play
   # Navigate to furnace scene
   # Verify currency displays with icon
   ```

3. **Run Tests:**
   ```bash
   run_tests.bat
   ```

4. **Update Remaining Scenes:**
   Follow "Step 2: Update Remaining Scenes" above

## 📖 References

- **CurrencyPanel API:** See `currency_panel.gd` comments
- **ResponsiveLayout Integration:** See `responsive_layout.gd` lines 475-479, 537-540, 1106-1111
- **Example Usage:** See `level1/furnace.gd` lines 20, 44-47, 99
