# Godot Development Best Practices

**Godot 4.5 development patterns and conventions for GoA**

---

## Table of Contents

1. [Project Configuration](#project-configuration)
2. [GDScript Style Guide](#gdscript-style-guide)
3. [Scene Management](#scene-management)
4. [Autoload System](#autoload-system)
5. [Node Patterns](#node-patterns)
6. [Responsive Design](#responsive-design)
7. [Common Pitfalls](#common-pitfalls)
8. [Performance Tips](#performance-tips)

---

## Project Configuration

### Engine Version
**Godot 4.5** - GL Compatibility renderer

### Project Settings

**Location**: [project.godot](../project.godot)

**Key Settings**:
```ini
[application]
config/name="GoA"
run/main_scene="res://level1/loading_screen.tscn"
config/features=PackedStringArray("4.5", "GL Compatibility")

[display]
window/size/viewport_width=1438
window/size/viewport_height=817
window/stretch/mode="canvas_items"

[autoload]
Global="*res://global.gd"
Level1Vars="*res://level1/level_1_vars.gd"
ResponsiveLayout="*res://responsive_layout.gd"
```

**Resolution**: 1438x817 (custom aspect ratio)

### File Organization

```
GoA/
├── *.gd                    # Global scripts (global.gd, etc.)
├── *.tscn                  # Root-level scenes (victory.tscn, etc.)
├── default_theme.tres      # Global theme
├── level1/                 # Level 1 specific content
│   ├── *.gd               # Level scripts
│   ├── *.tscn             # Level scenes
│   └── level_1_vars.gd    # Level autoload
├── test_scenes/           # Test/debug scenes
└── .claude/               # Claude documentation/config
```

---

## GDScript Style Guide

### Naming Conventions

**Variables**: `snake_case`
```gdscript
var player_health = 100.0
var max_stamina = 125.0
var is_ready = false
```

**Functions**: `snake_case`
```gdscript
func calculate_damage():
func get_xp_for_level(level: int) -> float:
func _on_button_pressed():
```

**Constants**: `UPPER_SNAKE_CASE`
```gdscript
const BASE_XP_FOR_LEVEL = 100
const MAX_PLAYER_LEVEL = 50
```

**Classes**: `PascalCase`
```gdscript
class_name PlayerInventory
class_name ShopManager
```

**Signals**: `snake_case`
```gdscript
signal health_changed(new_value)
signal item_purchased(item_name, cost)
```

### Type Hints

**Always use type hints** for clarity and performance:

```gdscript
# Good
func add_stat_exp(stat_name: String, amount: float) -> void:
	var current_level: int = get_stat_level(stat_name)
	var xp_needed: float = get_xp_for_level(current_level + 1)

# Avoid (no type hints)
func add_stat_exp(stat_name, amount):
	var current_level = get_stat_level(stat_name)
	var xp_needed = get_xp_for_level(current_level + 1)
```

### Properties with Setters/Getters

Use setter/getter syntax for reactive properties:

```gdscript
# Property with setter (triggers notification on change)
var strength = 1:
	set(value):
		if is_node_ready() and floor(value) > floor(strength):
			show_stat_notification("You feel stronger")
		strength = value

# Property with getter (dynamic calculation)
var max_stamina:
	get:
		return 125.0 + (20 * Global.constitution)

# Property with both
var suspicion = 0:
	set(value):
		suspicion = clamp(value, 0, 100)
	get:
		return suspicion
```

### Comments

```gdscript
# Single-line comments for brief explanations
var health = 100.0  # Player's current health

## Documentation comment for functions/classes
## Use double ## for function/class documentation
func calculate_damage(attacker_strength: float) -> float:
	## Calculates damage based on attacker strength
	## Returns the final damage value after all modifiers
	return attacker_strength * 2.0

# ===== SECTION HEADERS =====
# Use decorative comments to separate major sections
# ===== END SECTION =====
```

---

## Scene Management

### Scene Structure

**Root Node Types**:
- **Control**: For UI-heavy scenes (shop, menus)
- **Node2D**: For gameplay scenes (furnace, world)
- **Node**: For pure logic scenes (rare)

**Typical UI Scene Structure**:
```
Shop (Control)
├── HBoxContainer
│   ├── LeftVBox (VBoxContainer)
│   │   ├── SuspicionPanel
│   │   ├── BreakTimerPanel
│   │   └── CoinsPanel
│   └── RightVBox (VBoxContainer)
│       ├── ShovelButton
│       ├── PlowButton
│       └── AutoShovelButton
└── NotificationBar (VBoxContainer)
```

### Scene Transitions

**Always use** `Global.change_scene_with_check()`:

```gdscript
# Good
Global.change_scene_with_check(get_tree(), "res://level1/furnace.tscn")

# Bad (bypasses victory/caught checks)
get_tree().change_scene_to_file("res://level1/furnace.tscn")
```

**Why**: `change_scene_with_check()` handles:
1. Victory condition checks
2. Get caught checks
3. Scene cleanup
4. State preservation

### @onready References

Use `@onready` for node references:

```gdscript
@onready var suspicion_bar = $HBoxContainer/LeftVBox/SuspicionPanel/SuspicionBar
@onready var coins_label = $HBoxContainer/LeftVBox/CoinsPanel/CoinsLabel
@onready var shovel_button = $HBoxContainer/RightVBox/ShovelButton
```

**Benefits**:
- Evaluated after `_ready()`
- Cleaner than manual `get_node()` calls
- More performant than repeated `get_node()` in functions

### Finding Nodes Dynamically

When node location might change (responsive layout):

```gdscript
func _find_notification_bar() -> Node:
	var current_scene = get_tree().current_scene
	if not current_scene:
		return null

	# Try landscape location
	var notification_bar = current_scene.get_node_or_null("NotificationBar")
	if notification_bar:
		return notification_bar

	# Try portrait location
	notification_bar = current_scene.get_node_or_null("VBoxContainer/NotificationBar")
	if notification_bar:
		return notification_bar

	return null
```

**Use `get_node_or_null()`** instead of `get_node()` to avoid errors.

---

## Autoload System

### Purpose

Autoloads (Singletons) persist across scenes and are globally accessible.

### GoA Autoloads

**Configured in project.godot**:

```ini
[autoload]
Global="*res://global.gd"           # Global game state, stats, timers
Level1Vars="*res://level1/level_1_vars.gd"  # Level-specific variables
ResponsiveLayout="*res://responsive_layout.gd"  # Layout management
```

### Usage Pattern

**Accessing Autoloads**:
```gdscript
# From any script
Global.add_stat_exp("strength", 50)
Level1Vars.coins += 10
ResponsiveLayout.apply_to_scene(self)
```

### What Belongs in Autoloads

**Global.gd** (cross-level, persistent):
- Player stats (strength, intelligence, etc.)
- Experience system
- Victory conditions
- Global timers
- Notification system

**Level1Vars.gd** (level-specific, resettable):
- Resources (coal, coins, components)
- Upgrade levels (shovel, plow)
- Level progress (stolen coal, suspicion)
- Temporary buffs
- Scene-specific flags

**ResponsiveLayout.gd** (utility):
- Layout adaptation logic
- Scaling constants
- UI helper functions

### Initialization Order

Autoloads initialize before any scene:

```gdscript
# In Global.gd
func _ready():
	print("Global autoload ready")  # Runs first

# In your scene
func _ready():
	print("Scene ready")  # Runs after autoloads
```

---

## Node Patterns

### Timer Management

**Create timers programmatically** in autoloads:

```gdscript
func _ready():
	# Create timer
	whisper_timer = Timer.new()
	whisper_timer.wait_time = 120.0
	whisper_timer.autostart = true
	whisper_timer.timeout.connect(_on_whisper_timer_timeout)
	add_child(whisper_timer)

func _on_whisper_timer_timeout():
	# Handle timeout
	pass
```

**Benefits over scene timers**:
- Persist across scene changes
- Centralized management
- Easier debugging

### Signal Connections

**Preferred method** (Godot 4.x):
```gdscript
button.pressed.connect(_on_button_pressed)
timer.timeout.connect(_on_timer_timeout)
```

**Old method** (Godot 3.x, still works):
```gdscript
button.connect("pressed", self, "_on_button_pressed")
```

**Lambda functions** for quick connections:
```gdscript
notification_timer.timeout.connect(func(): _remove_notification(notification_data))
```

### Node Lifecycle

```gdscript
func _enter_tree():
	# Called when node enters scene tree
	# Use for early initialization

func _ready():
	# Called after all children are ready
	# Use for main initialization

func _process(delta):
	# Called every frame
	# Use for continuous updates

func _exit_tree():
	# Called when node leaves scene tree
	# Use for cleanup
```

**Important**: Check `is_node_ready()` in setters to prevent premature calls.

---

## Responsive Design

### Overview

GoA adapts UI for landscape (desktop) and portrait (mobile) orientations.

**Location**: [responsive_layout.gd](../responsive_layout.gd)

### Key Constants

```gdscript
const LANDSCAPE_ELEMENT_HEIGHT = 80
const PORTRAIT_ELEMENT_HEIGHT = 120
const PORTRAIT_FONT_SCALE = 1.5
```

### Applying Responsive Layout

**In scene's `_ready()`**:
```gdscript
func _ready():
	# ... other initialization
	ResponsiveLayout.apply_to_scene(self)
```

### Detection

```gdscript
var viewport = get_viewport()
var viewport_size = viewport.get_visible_rect().size
var is_portrait = viewport_size.y > viewport_size.x
```

### Layout Adaptation

**Landscape Mode**:
- Elements arranged horizontally
- Nodes stay in original positions
- Standard sizing

**Portrait Mode**:
- Elements reparented into VBoxContainer
- Vertical stacking
- Scaled fonts and heights

### Manual Scaling

For custom elements (like notifications):

```gdscript
func _apply_notification_scaling(notification_panel: Panel, notification_label: Label):
	var viewport = get_viewport()
	var viewport_size = viewport.get_visible_rect().size
	var is_portrait = viewport_size.y > viewport_size.x

	if is_portrait:
		var scaled_height = ResponsiveLayout.PORTRAIT_ELEMENT_HEIGHT * ResponsiveLayout.PORTRAIT_FONT_SCALE
		notification_panel.custom_minimum_size = Vector2(0, scaled_height)

		var default_font_size = 25
		notification_label.add_theme_font_size_override("font_size", int(default_font_size * ResponsiveLayout.PORTRAIT_FONT_SCALE))
```

---

## Common Pitfalls

### 1. Direct Scene Changes

**Problem**: Bypasses game mechanics
```gdscript
# Bad
get_tree().change_scene_to_file("res://level1/shop.tscn")
```

**Solution**: Always use wrapper
```gdscript
# Good
Global.change_scene_with_check(get_tree(), "res://level1/shop.tscn")
```

### 2. Direct Stat Modification

**Problem**: Breaks experience system
```gdscript
# Bad
Global.strength += 1
```

**Solution**: Use experience system
```gdscript
# Good
Global.add_stat_exp("strength", 150)
```

### 3. Forgetting `is_node_ready()` in Setters

**Problem**: Triggers notifications during initialization
```gdscript
# Bad
var strength = 1:
	set(value):
		show_stat_notification("You feel stronger")  # Triggers on load!
		strength = value
```

**Solution**: Check ready state
```gdscript
# Good
var strength = 1:
	set(value):
		if is_node_ready() and floor(value) > floor(strength):
			show_stat_notification("You feel stronger")
		strength = value
```

### 4. Using `get_node()` Without Null Check

**Problem**: Crashes if node doesn't exist
```gdscript
# Bad
var button = get_node("Button")  # Error if not found
```

**Solution**: Use `get_node_or_null()`
```gdscript
# Good
var button = get_node_or_null("Button")
if button:
	button.disabled = true
```

### 5. Creating UI in Code Without Parent

**Problem**: Elements don't appear
```gdscript
# Bad
var label = Label.new()
label.text = "Hello"
# Label never added to tree!
```

**Solution**: Always add to scene tree
```gdscript
# Good
var label = Label.new()
label.text = "Hello"
add_child(label)  # Now visible
```

### 6. Forgetting to Free Nodes

**Problem**: Memory leaks
```gdscript
# Bad
var temp_node = Node.new()
add_child(temp_node)
remove_child(temp_node)
# Node still in memory!
```

**Solution**: Use `queue_free()`
```gdscript
# Good
var temp_node = Node.new()
add_child(temp_node)
temp_node.queue_free()  # Safely freed at end of frame
```

---

## Performance Tips

### 1. Use `@onready` for Node References

```gdscript
# Fast (cached reference)
@onready var button = $Button

func _process(delta):
	button.text = str(delta)

# Slow (searches tree every frame)
func _process(delta):
	$Button.text = str(delta)
```

### 2. Limit `_process()` Usage

Only use `_process()` when continuous updates are needed:

```gdscript
# Good (needs per-frame update)
func _process(delta):
	if Level1Vars.stamina < Level1Vars.max_stamina:
		Level1Vars.stamina = min(Level1Vars.stamina + delta, Level1Vars.max_stamina)

# Bad (only needs to run once)
func _process(delta):
	update_static_label()  # Inefficient!
```

Use signals or setters for event-driven updates instead.

### 3. Batch UI Updates

```gdscript
# Bad (multiple redraws)
func update_ui():
	label1.text = "Value"
	label2.text = "Other"
	button.disabled = true

# Good (batch update)
func update_ui():
	# Update all properties first
	label1.text = "Value"
	label2.text = "Other"
	button.disabled = true
	# Single redraw happens automatically
```

### 4. Use Typed Arrays

```gdscript
# Fast
var players: Array[Player] = []

# Slower
var players = []
```

### 5. Avoid String Operations in Loops

```gdscript
# Bad
for i in range(1000):
	var message = "Iteration " + str(i)

# Better
var messages = PackedStringArray()
for i in range(1000):
	messages.append("Iteration %d" % i)
```

---

## Debugging Tips

### Print Debugging

```gdscript
# Basic print
print("Player health:", player_health)

# Formatted print
print("Stats - STR: %d, DEX: %d" % [strength, dexterity])

# Debug-only print
if OS.is_debug_build():
	print("Debug info:", debug_data)
```

### Assertions

```gdscript
# Crash in debug mode if condition fails
assert(player_health > 0, "Player health cannot be negative")
assert(level > 0, "Level must be positive")
```

### Remote Debugging

When running game from editor:
- **Debugger tab**: See active nodes, properties
- **Profiler tab**: Performance metrics
- **Network Profiler**: Network calls
- **Visual Profiler**: Frame timing

### Godot Console Commands

```bash
# Run with verbose output
godot --verbose --path "c:\GoA"

# Print all errors
godot --path "c:\GoA" 2>&1 | grep "ERROR"

# Run specific scene
godot --path "c:\GoA" res://level1/shop.tscn
```

---

## Resources & References

### Official Godot Docs
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Godot 4.5 Documentation](https://docs.godotengine.org/en/4.5/)

### Useful Godot Patterns
- **Signals**: Event-driven programming
- **Autoloads**: Global state management
- **Node groups**: Tagging and batch operations
- **Scene instancing**: Reusable prefabs

### GoA-Specific Patterns
- Experience system: [game-systems.md](game-systems.md#experience-system)
- Debug logging: [debug-system.md](debug-system.md)
- Scene management: [game-systems.md](game-systems.md#victory-system)

---

**Version**: 1.0
**Last Updated**: 2025-10-29
**Maintained By**: Claude + User collaboration
