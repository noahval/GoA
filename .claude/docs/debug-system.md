# Debug System Documentation

**Comprehensive debugging and autonomous testing system for GoA**

---

## Table of Contents

1. [Overview](#overview)
2. [Debug Logger Implementation](#debug-logger-implementation)
3. [Autonomous Testing Procedures](#autonomous-testing-procedures)
4. [Log Analysis](#log-analysis)
5. [Testing Commands](#testing-commands)
6. [Common Test Scenarios](#common-test-scenarios)

---

## Overview

The debug system provides Claude with autonomous testing capabilities through:
- **Dual-output logging**: Console (stdout) + persistent file logs
- **Structured log format**: Timestamps, categories, call context
- **Autonomous test execution**: Run Godot headless and capture output
- **Log analysis**: Parse and verify expected behaviors

### Key Benefits for Claude

1. **Real-time feedback**: Capture stdout during game execution via bash
2. **Persistent analysis**: Read log files after execution completes
3. **Automated validation**: Verify stat changes, timers, and game logic
4. **Regression testing**: Ensure changes don't break existing features

---

## Debug Logger Implementation

### Location
Create a new autoload: `debug_logger.gd`

### Implementation

```gdscript
extends Node

# ===== DEBUG LOGGER AUTOLOAD =====
# Provides comprehensive logging for autonomous testing and debugging
# Usage: DebugLogger.log("message", "CATEGORY")

var log_file: FileAccess = null
var log_file_path: String = "user://debug.log"
var enable_console_output: bool = true
var enable_file_output: bool = true
var log_level: int = 0  # 0=DEBUG, 1=INFO, 2=WARN, 3=ERROR

enum LogLevel {
	DEBUG = 0,
	INFO = 1,
	WARN = 2,
	ERROR = 3
}

func _ready():
	# Open log file for writing
	if enable_file_output:
		log_file = FileAccess.open(log_file_path, FileAccess.WRITE)
		if log_file:
			_write_header()
		else:
			push_error("Failed to open debug log file at: " + log_file_path)

func _exit_tree():
	# Close log file on exit
	if log_file:
		_write_footer()
		log_file.close()

func _write_header():
	if log_file:
		log_file.store_line("=" * 80)
		log_file.store_line("GoA Debug Log")
		log_file.store_line("Started: " + Time.get_datetime_string_from_system())
		log_file.store_line("=" * 80)
		log_file.flush()

func _write_footer():
	if log_file:
		log_file.store_line("=" * 80)
		log_file.store_line("Log ended: " + Time.get_datetime_string_from_system())
		log_file.store_line("=" * 80)
		log_file.flush()

# Main logging function
func log(message: String, category: String = "DEBUG", level: int = LogLevel.DEBUG):
	if level < log_level:
		return

	var timestamp = Time.get_datetime_string_from_system()
	var level_str = LogLevel.keys()[level]
	var formatted_message = "[%s][%s][%s] %s" % [timestamp, level_str, category, message]

	# Output to console
	if enable_console_output:
		print(formatted_message)

	# Output to file
	if enable_file_output and log_file:
		log_file.store_line(formatted_message)
		log_file.flush()

# Convenience functions for different log levels
func debug(message: String, category: String = "DEBUG"):
	log(message, category, LogLevel.DEBUG)

func info(message: String, category: String = "INFO"):
	log(message, category, LogLevel.INFO)

func warn(message: String, category: String = "WARN"):
	log(message, category, LogLevel.WARN)

func error(message: String, category: String = "ERROR"):
	log(message, category, LogLevel.ERROR)

# Track stat changes
func log_stat_change(stat_name: String, old_value: float, new_value: float, exp_gained: float):
	var message = "Stat '%s': %.2f -> %.2f (exp: +%.2f)" % [stat_name, old_value, new_value, exp_gained]
	info(message, "STAT_CHANGE")

# Track resource changes
func log_resource_change(resource_name: String, old_value: float, new_value: float, reason: String = ""):
	var change = new_value - old_value
	var change_str = "+%.2f" % change if change >= 0 else "%.2f" % change
	var message = "Resource '%s': %.2f -> %.2f (%s)" % [resource_name, old_value, new_value, change_str]
	if reason != "":
		message += " | Reason: " + reason
	info(message, "RESOURCE")

# Track function calls
func log_function_call(function_name: String, parameters: Dictionary = {}):
	var message = "Called: %s" % function_name
	if not parameters.is_empty():
		message += " | Params: " + str(parameters)
	debug(message, "FUNCTION")

# Track timer events
func log_timer_event(timer_name: String, event: String, time_remaining: float = 0.0):
	var message = "Timer '%s': %s" % [timer_name, event]
	if time_remaining > 0:
		message += " | Time: %.2fs" % time_remaining
	info(message, "TIMER")

# Track scene changes
func log_scene_change(from_scene: String, to_scene: String, reason: String = ""):
	var message = "Scene: %s -> %s" % [from_scene, to_scene]
	if reason != "":
		message += " | Reason: " + reason
	info(message, "SCENE")

# Track shop purchases
func log_shop_purchase(item_name: String, cost: float, level: int):
	var message = "Purchase: %s | Cost: %.0f | New Level: %d" % [item_name, cost, level]
	info(message, "SHOP")

# Track victory checks
func log_victory_check(conditions_met: bool, current_progress: Dictionary):
	var message = "Victory Check: %s | Progress: %s" % ["PASSED" if conditions_met else "NOT MET", str(current_progress)]
	info(message, "VICTORY")
```

### Integration Points

#### In global.gd

Add logging to key functions:

```gdscript
func add_stat_exp(stat_name: String, amount: float):
	var old_value = 0.0
	match stat_name:
		"strength": old_value = strength
		"constitution": old_value = constitution
		# ... etc

	# Existing code...

	DebugLogger.log_stat_change(stat_name, old_value, get(stat_name), amount)

func check_victory_conditions() -> bool:
	var current_progress = {}
	for condition in victory_conditions:
		current_progress[condition] = Level1Vars.get(condition)

	var result = # existing check logic

	DebugLogger.log_victory_check(result, current_progress)
	return result
```

#### In shop.gd

```gdscript
func _on_shovel_button_pressed():
	var cost = get_shovel_cost()
	if Level1Vars.coins >= cost:
		DebugLogger.log_resource_change("coins", Level1Vars.coins, Level1Vars.coins - cost, "Shovel purchase")
		Level1Vars.coins -= cost
		Level1Vars.shovel_lvl += 1
		DebugLogger.log_shop_purchase("Shovel", cost, Level1Vars.shovel_lvl)
		update_labels()
```

---

## Autonomous Testing Procedures

### Test Workflow for Claude

#### 1. Pre-Test Setup
```bash
# Ensure debug logger is in autoload
# Check project.godot has DebugLogger autoload configured
```

#### 2. Run Test
```bash
# Headless mode (no window, full logs)
godot --headless --path "c:\GoA" -- test_mode=true

# With timeout (2 minute test run)
timeout 120 godot --headless --path "c:\GoA"
```

#### 3. Capture Output
```bash
# Option A: Direct output capture
godot --headless --path "c:\GoA" 2>&1 | tee test_output.txt

# Option B: Run and read log file after
godot --headless --path "c:\GoA" --quit-after 60
cat ~/.local/share/godot/app_userdata/GoA/debug.log
```

#### 4. Analyze Results
```bash
# Search for errors
grep "ERROR" test_output.txt

# Check stat changes
grep "STAT_CHANGE" ~/.local/share/godot/app_userdata/GoA/debug.log

# Verify shop purchases
grep "SHOP" ~/.local/share/godot/app_userdata/GoA/debug.log
```

---

## Log Analysis

### Log Format

```
[YYYY-MM-DD HH:MM:SS][LEVEL][CATEGORY] Message
```

Example:
```
[2025-10-29 14:23:15][INFO][STAT_CHANGE] Stat 'strength': 1.00 -> 2.00 (exp: +150.00)
[2025-10-29 14:23:20][INFO][SHOP] Purchase: Shovel | Cost: 8 | New Level: 1
[2025-10-29 14:23:45][WARN][TIMER] Timer 'get_caught': triggered | suspicion: 45
```

### Key Log Categories

| Category | What It Tracks | When to Check |
|----------|---------------|---------------|
| `STAT_CHANGE` | All experience/level changes | Verifying stat progression |
| `RESOURCE` | Coins, coal, components, etc. | Tracking economy/resources |
| `SHOP` | Purchase transactions | Testing shop functionality |
| `TIMER` | Timer triggers and events | Debugging time-based mechanics |
| `SCENE` | Scene transitions | Navigation/flow testing |
| `VICTORY` | Win condition checks | Testing victory logic |
| `FUNCTION` | Function call traces | Detailed debugging |

### Log Analysis Commands

```bash
# Count stat level-ups during test
grep "STAT_CHANGE" debug.log | wc -l

# Find all errors
grep "\[ERROR\]" debug.log

# Track coins over time
grep "coins" debug.log | grep "RESOURCE"

# Check victory condition checks
grep "VICTORY" debug.log
```

---

## Testing Commands

### Godot CLI Test Commands

```bash
# Basic headless test (runs until closed)
godot --headless --path "c:\GoA"

# Headless with display server (GUI-less but still renders)
godot --display-driver headless --path "c:\GoA"

# Run specific scene
godot --headless --path "c:\GoA" res://level1/loading_screen.tscn

# Enable verbose output
godot --headless --verbose --path "c:\GoA"

# Quit after N seconds (for automated tests)
godot --headless --path "c:\GoA" --quit-after 60
```

### Custom Test Scenes

Create `test_scenes/` for isolated testing:

**test_scenes/stat_test.gd**:
```gdscript
extends Node

func _ready():
	DebugLogger.info("Starting stat test", "TEST")

	# Test stat gaining
	Global.add_stat_exp("strength", 150)
	Global.add_stat_exp("constitution", 200)

	# Verify levels
	assert(Global.strength >= 2, "Strength should be level 2+")

	DebugLogger.info("Stat test complete", "TEST")
	get_tree().quit()
```

---

## Common Test Scenarios

### Test 1: Stat Progression

**Purpose**: Verify experience system works correctly

```bash
# Run test
godot --headless --path "c:\GoA" res://test_scenes/stat_test.tscn --quit-after 10

# Verify
grep "STAT_CHANGE" ~/.local/share/godot/app_userdata/GoA/debug.log
```

**Expected Output**:
```
[INFO][STAT_CHANGE] Stat 'strength': 1.00 -> 2.00 (exp: +150.00)
```

### Test 2: Shop Purchases

**Purpose**: Verify shop upgrades and cost scaling

```bash
# Run shop test scene
godot --headless --path "c:\GoA" res://test_scenes/shop_test.tscn --quit-after 15

# Verify purchases
grep "SHOP" debug.log
grep "coins" debug.log
```

**Expected Output**:
```
[INFO][RESOURCE] Resource 'coins': 100.00 -> 92.00 (-8.00) | Reason: Shovel purchase
[INFO][SHOP] Purchase: Shovel | Cost: 8 | New Level: 1
```

### Test 3: Timer Systems

**Purpose**: Test whisper timer, suspicion decrease, stamina regen

```bash
# Run for 2 minutes to trigger timers
godot --headless --path "c:\GoA" --quit-after 120

# Check timer events
grep "TIMER" debug.log
```

### Test 4: Victory Conditions

**Purpose**: Verify win conditions trigger correctly

```bash
# Run victory test
godot --headless --path "c:\GoA" res://test_scenes/victory_test.tscn

# Check victory checks
grep "VICTORY" debug.log
```

---

## Claude Autonomous Test Procedure

### When to Run Tests

- After modifying any game system
- Before committing changes
- When debugging reported issues
- After adding new features

### Step-by-Step Test Process

1. **Identify what changed** (e.g., shop system, stat calculations)
2. **Run relevant test** (headless Godot with appropriate scene)
3. **Capture output** (both stdout and log file)
4. **Analyze logs** (grep for relevant categories)
5. **Verify expectations** (check values, assert conditions met)
6. **Report findings** (summarize to user: pass/fail, issues found)

### Example Test Session

```bash
# Test shop upgrade after modifying cost calculation
echo "Testing shop cost calculation changes..."

# Run game for 30 seconds
godot --headless --path "c:\GoA" res://level1/shop.tscn --quit-after 30 2>&1 | tee shop_test.txt

# Check for errors
if grep -q "ERROR" shop_test.txt; then
    echo "ERRORS FOUND:"
    grep "ERROR" shop_test.txt
fi

# Verify shop purchases worked
echo "Shop transactions:"
grep "SHOP" ~/.local/share/godot/app_userdata/GoA/debug.log

# Check coin calculations
echo "Coin changes:"
grep "coins" ~/.local/share/godot/app_userdata/GoA/debug.log | grep "RESOURCE"

echo "Test complete!"
```

---

## Troubleshooting

### Log File Not Created

**Issue**: `debug.log` doesn't exist after running

**Solutions**:
1. Check DebugLogger is in autoload (project.godot)
2. Verify file permissions for `user://` directory
3. Check `enable_file_output = true` in DebugLogger

### No Console Output

**Issue**: Not seeing log messages in stdout

**Solutions**:
1. Ensure `enable_console_output = true`
2. Use `--verbose` flag when running Godot
3. Check log_level setting (0 = show all)

### Test Hangs/Doesn't Quit

**Issue**: Headless test runs indefinitely

**Solutions**:
1. Use `--quit-after N` parameter
2. Add `get_tree().quit()` to test scenes
3. Use `timeout` command: `timeout 60 godot --headless ...`

---

## Configuration

### Project Settings

Add to `project.godot`:

```ini
[autoload]

Global="*res://global.gd"
Level1Vars="*res://level1/level_1_vars.gd"
ResponsiveLayout="*res://responsive_layout.gd"
DebugLogger="*res://debug_logger.gd"
```

### Environment Variables

```bash
# Set custom log path
export GOA_DEBUG_LOG_PATH="$HOME/goa_debug.log"

# Set log level (0-3)
export GOA_DEBUG_LOG_LEVEL=0

# Disable file logging (console only)
export GOA_DEBUG_FILE_LOGGING=false
```

---

## Best Practices

1. **Always log significant changes**: Stats, resources, scene transitions
2. **Use appropriate log levels**: DEBUG for traces, INFO for events, WARN for issues, ERROR for failures
3. **Include context**: Parameter values, reasons for changes
4. **Test after changes**: Run autonomous tests before committing
5. **Clean logs regularly**: Old logs can grow large
6. **Use categories consistently**: Stick to defined categories for easy filtering

---

## Future Enhancements

- **Log rotation**: Automatically archive old logs
- **Test suites**: Organized collection of test scenes
- **Assert framework**: Built-in assertion utilities
- **Performance profiling**: Track frame times, memory usage
- **Network logging**: Send logs to remote server for analysis

---

**Version**: 1.0
**Last Updated**: 2025-10-29
**Maintained By**: Claude + User collaboration
