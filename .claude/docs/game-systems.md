# Game Systems Documentation

**Complete reference for all GoA game mechanics and systems**

---

## Table of Contents

1. [Experience System](#experience-system)
2. [Stats System](#stats-system)
3. [Shop System](#shop-system)
4. [Timer Systems](#timer-systems)
5. [Notification System](#notification-system)
6. [Victory System](#victory-system)
7. [Resource Management](#resource-management)
   - [Multi-Currency System](#multi-currency-system)
   - [Currency Exchange (ATM)](#currency-exchange-atm)
8. [Suspicion & Get Caught Mechanics](#suspicion--get-caught-mechanics)

---

## Experience System

**Location**: [global.gd](../global.gd) lines 13-117

### Overview

GoA uses a non-linear experience system where players gain experience points that accumulate toward stat level-ups. Each stat (strength, constitution, etc.) has independent experience tracking.

### Configuration

```gdscript
const BASE_XP_FOR_LEVEL = 100      # XP needed for first level up (1 -> 2)
const EXP_SCALING = 1.8            # Growth curve steepness
```

**Scaling Values**:
- `1.5` = Gentle curve (faster progression)
- `1.8` = Balanced (current setting)
- `2.0` = Moderate
- `2.5` = Steep (slower progression)

### XP Formula

```gdscript
XP_for_level_N = BASE_XP_FOR_LEVEL * (N - 1)^EXP_SCALING
```

**Example Progression (EXP_SCALING = 1.8)**:
- Level 1 → 2: 100 XP
- Level 2 → 3: 349 XP
- Level 3 → 4: 721 XP
- Level 4 → 5: 1,200 XP

### Key Functions

#### `add_stat_exp(stat_name: String, amount: float)`
**Purpose**: Primary function for adding experience to any stat

**Usage**:
```gdscript
Global.add_stat_exp("strength", 50.0)      # Add 50 XP to strength
Global.add_stat_exp("intelligence", 100.0)  # Add 100 XP to intelligence
```

**Behavior**:
1. Adds XP to the stat's experience pool
2. Automatically checks for level-ups
3. Can trigger multiple level-ups if enough XP
4. Updates the actual stat value
5. Triggers notification on level-up (via stat setter)

**CRITICAL**: Always use this function instead of directly modifying stat values!

#### `get_stat_level_progress(stat_name: String) -> float`
**Purpose**: Get progress toward next level (0.0 to 1.0)

**Usage**:
```gdscript
var progress = Global.get_stat_level_progress("strength")
progress_bar.value = progress * 100  # Convert to percentage
```

**Returns**:
- `0.0` = Just leveled up
- `0.5` = Halfway to next level
- `1.0` = At threshold (about to level up)

### Experience Variables

```gdscript
var strength_exp = 0.0      # Accumulated XP for strength
var constitution_exp = 0.0
var dexterity_exp = 0.0
var wisdom_exp = 0.0
var intelligence_exp = 0.0
var charisma_exp = 0.0
```

**Note**: These track the raw accumulated XP, not the level. Use these for save/load systems.

---

## Stats System

**Location**: [global.gd](../global.gd) lines 119-154

### The Six Stats

| Stat | Description | Starting Value | Notification |
|------|-------------|----------------|--------------|
| **Strength** | Physical power | 1 | "You feel stronger" |
| **Constitution** | Health, stamina | 1 | "You feel more resilient" |
| **Dexterity** | Speed, precision | 1 | "You feel more precise" |
| **Wisdom** | Insight, awareness | 1 | "You feel more introspective" |
| **Intelligence** | Knowledge, learning | 1 | "You feel smarter" |
| **Charisma** | Social influence | 1 | "You feel you understand people more" |

### Stat Setters with Notifications

Each stat uses a custom setter that automatically shows a notification when leveling up:

```gdscript
var strength = 1:
	set(value):
		if is_node_ready() and floor(value) > floor(strength):
			show_stat_notification("You feel stronger")
		strength = value
```

**Key Points**:
- Uses `floor()` to detect whole level changes only
- Checks `is_node_ready()` to prevent notifications during initialization
- Notifications only show when crossing level thresholds (1.9 → 2.0)

### Constitution's Special Role

Constitution affects max stamina:

```gdscript
# In level_1_vars.gd line 18-20
var max_stamina:
	get:
		return 125.0 + (20 * Global.constitution)
```

**Formula**: `max_stamina = 125 + (20 * constitution_level)`

**Examples**:
- Constitution 1: 145 max stamina
- Constitution 2: 165 max stamina
- Constitution 5: 225 max stamina

---

## Shop System

**Location**: [level1/shop.gd](../level1/shop.gd)

### Overview

The shop provides upgrades with exponentially scaling costs. Players spend coins to purchase levels in various upgrades.

### Upgrades

#### 1. Shovel (`shovel_lvl`)
**Purpose**: Basic mining upgrade

**Cost Formula**: `8 * (1.8 ^ shovel_lvl)`

| Level | Cost |
|-------|------|
| 0 → 1 | 8 |
| 1 → 2 | 14 |
| 2 → 3 | 26 |
| 3 → 4 | 46 |
| 4 → 5 | 83 |

**Special**: Unlocks other upgrades:
- Level 2+: Shows "Auto Shovel" button
- Level 5+: Shows "Coal Plow" button

#### 2. Coal Plow (`plow_lvl`)
**Purpose**: Advanced mining tool

**Cost Formula**: `50 * (1.9 ^ plow_lvl)`

| Level | Cost |
|-------|------|
| 0 → 1 | 50 |
| 1 → 2 | 95 |
| 2 → 3 | 180 |
| 3 → 4 | 343 |

**Requirements**: Shovel level 5+

#### 3. Auto Shovel (`auto_shovel_lvl`)
**Purpose**: Automated coal generation

**Cost Formula**: `200 * (1.6 ^ auto_shovel_lvl)`

**Default Frequency**: 3.0 seconds (`auto_shovel_freq`)

| Level | Cost |
|-------|------|
| 1 → 2 | 200 |
| 2 → 3 | 320 |
| 3 → 4 | 512 |

**Requirements**: Shovel level 2+

#### 4. Bribe Shopkeep
**Purpose**: Unlock workshop access

**Cost**: 10 coins (one-time)

**Effect**:
- Sets `shopkeep_bribed = true`
- Reveals "Workshop" button
- Hides bribe button after purchase

### Cost Calculation Functions

```gdscript
func get_shovel_cost() -> int:
	return int(8 * pow(1.8, Level1Vars.shovel_lvl))

func get_plow_cost() -> int:
	return int(50 * pow(1.9, Level1Vars.plow_lvl))

func get_auto_shovel_cost() -> int:
	return int(200 * pow(1.6, Level1Vars.auto_shovel_lvl))
```

### Shop UI Updates

The `update_labels()` function handles:
- Displaying current costs
- Showing/hiding buttons based on requirements
- Enabling/disabling buttons based on affordability
- Updating coin display

**Progressive Unlocking**:
1. Start: Only Shovel visible
2. Shovel 2+: Auto Shovel appears
3. Shovel 5+: Coal Plow appears
4. Bribe paid: Workshop button appears

---

## Timer Systems

**Location**: [global.gd](../global.gd) lines 157-188, 324-363

### Overview

GoA uses multiple global timers managed in `global.gd` for various time-based mechanics.

### 1. Whisper Timer

**Purpose**: Periodic mysterious whisper notification

**Configuration**:
```gdscript
whisper_timer.wait_time = 120.0  # 2 minutes
whisper_timer.autostart = true
```

**Behavior** (line 333-339):
```gdscript
func _on_whisper_timer_timeout():
	Level1Vars.whisper_triggered = true
	if not Level1Vars.heart_taken:
		show_stat_notification("A voice whispers in your mind, pleading for your help")
```

**Triggers every**: 2 minutes
**Condition**: Only shows if heart hasn't been taken

### 2. Suspicion Decrease Timer

**Purpose**: Gradually reduce suspicion over time

**Configuration**:
```gdscript
suspicion_decrease_timer.wait_time = 3.0  # Every 3 seconds
suspicion_decrease_timer.autostart = true
```

**Behavior** (line 341-344):
```gdscript
func _on_suspicion_decrease_timeout():
	if Level1Vars.suspicion > 0:
		Level1Vars.suspicion -= 1
```

**Triggers every**: 3 seconds
**Effect**: -1 suspicion per tick (down to 0)

### 3. Get Caught Timer

**Purpose**: Periodically check if player gets caught stealing

**Configuration**:
```gdscript
get_caught_timer.wait_time = 45.0  # Every 45 seconds
get_caught_timer.autostart = true
```

**Behavior** (line 362-363):
```gdscript
func _on_get_caught_timeout():
	check_get_caught()
```

**Triggers every**: 45 seconds
**See**: [Suspicion & Get Caught Mechanics](#suspicion--get-caught-mechanics) for details

### 4. Stamina Regeneration

**Purpose**: Passive stamina recovery

**Configuration**:
```gdscript
# In global.gd _process(delta) line 324-327
if Level1Vars.stamina < Level1Vars.max_stamina:
	Level1Vars.stamina = min(Level1Vars.stamina + delta, Level1Vars.max_stamina)
```

**Rate**: 1 stamina per second
**Limit**: Up to `max_stamina`

### 5. Talk Button Cooldown

**Purpose**: Prevent spam-clicking talk/dialogue buttons

**Configuration**:
```gdscript
# In global.gd _process(delta) line 329-331
if Level1Vars.talk_button_cooldown > 0:
	Level1Vars.talk_button_cooldown -= delta
```

**Decrements**: Every frame by delta time
**Usage**: Set to desired cooldown (e.g., 2.0 for 2 seconds)

### 6. Break Timer

**Purpose**: Shop scene countdown timer

**Location**: [level1/shop.gd](../level1/shop.gd) line 44-58

**Configuration**:
```gdscript
var break_time = 30.0
var max_break_time = 30.0

# Actual max modified by overseer level
max_break_time = Level1Vars.starting_break_time + Level1Vars.overseer_lvl
```

**Behavior**:
- Counts down every frame
- Progress bar shows percentage remaining
- Scene changes to furnace when timer expires
- Triggers `Global.change_scene_with_check()` (includes victory/caught checks)

---

## Notification System

**Location**: [global.gd](../global.gd) lines 157-322

### Overview

Dynamic notification system that creates temporary translucent panels with messages. Supports responsive design (portrait/landscape).

### Key Function

#### `show_stat_notification(message: String)`

**Purpose**: Display a temporary notification to the user

**Usage**:
```gdscript
Global.show_stat_notification("You feel stronger")
Global.show_stat_notification("You've been caught, your coal and coins have been seized")
Global.show_stat_notification("A voice whispers in your mind, pleading for your help")
```

**Behavior**:
1. Finds `NotificationBar` in current scene
2. Creates a `Panel` with translucent grey background
3. Adds a centered `Label` with the message
4. Applies responsive scaling if in portrait mode
5. Auto-removes after 3 seconds
6. Stacks vertically in a `VBoxContainer`

### Notification Appearance

**Visual Style**:
- **Background**: Dark grey (0.15, 0.15, 0.15) with 40% opacity
- **Text Color**: White (1, 1, 1, 1)
- **Corner Radius**: 8px on all corners
- **Duration**: 3 seconds
- **Height**: `ResponsiveLayout.LANDSCAPE_ELEMENT_HEIGHT` (or scaled for portrait)

### Implementation Details

**Finding NotificationBar** (line 269-291):
```gdscript
func _find_notification_bar() -> Node:
	# Try landscape location first (direct child of root)
	var notification_bar = current_scene.get_node_or_null("NotificationBar")
	if notification_bar:
		return notification_bar

	# Try portrait location (reparented into VBoxContainer)
	notification_bar = current_scene.get_node_or_null("VBoxContainer/NotificationBar")
	if notification_bar:
		return notification_bar

	return null
```

**Multiple Notifications**:
- Uses `active_notifications` array to track all visible notifications
- Each notification has its own timer
- VBoxContainer automatically stacks them
- Old notifications don't need repositioning when removed

### Responsive Scaling

Portrait mode applies scaling (line 293-309):
```gdscript
var scaled_height = ResponsiveLayout.PORTRAIT_ELEMENT_HEIGHT * ResponsiveLayout.PORTRAIT_FONT_SCALE
notification_panel.custom_minimum_size = Vector2(0, scaled_height)

var default_font_size = 25
notification_label.add_theme_font_size_override("font_size", int(default_font_size * ResponsiveLayout.PORTRAIT_FONT_SCALE))
```

---

## Victory System

**Location**: [global.gd](../global.gd) lines 5-11, 377-398

### Overview

GoA uses a configurable dictionary-based victory system. Players must achieve specific values in multiple tracked variables.

### Victory Conditions

```gdscript
var victory_conditions = {
	"stolen_coal": 3,
	"stolen_writs": 3,
	"mechanisms": 3
}
```

**Win Condition**: ALL values must be met simultaneously

**Current Requirements**:
- 3+ stolen coal
- 3+ stolen writs
- 3+ mechanisms

### Key Functions

#### `check_victory_conditions() -> bool`

**Purpose**: Check if all victory conditions are met

**Logic** (line 378-393):
```gdscript
func check_victory_conditions() -> bool:
	for condition in victory_conditions:
		var required_amount = victory_conditions[condition]
		var current_amount = 0

		if condition in Level1Vars:
			current_amount = Level1Vars.get(condition)

		if current_amount < required_amount:
			return false

	return true  # All conditions met
```

**Returns**:
- `true` if all conditions satisfied
- `false` if any condition not met

#### `check_and_trigger_victory(scene_tree: SceneTree)`

**Purpose**: Check conditions and immediately transition to victory scene if met

**Usage**:
```gdscript
# After player gains a mechanism
Level1Vars.mechanisms += 1
Global.check_and_trigger_victory(get_tree())
```

**Behavior** (line 396-398):
```gdscript
func check_and_trigger_victory(scene_tree: SceneTree):
	if check_victory_conditions():
		scene_tree.change_scene_to_file("res://victory.tscn")
```

### Integration with Scene Changes

Victory is checked in `change_scene_with_check()` (line 366-375):

```gdscript
func change_scene_with_check(scene_tree: SceneTree, scene_path: String):
	# Check victory first
	if check_victory_conditions():
		scene_tree.change_scene_to_file("res://victory.tscn")
		return

	# Then check if caught
	if not check_get_caught():
		scene_tree.change_scene_to_file(scene_path)
```

**Priority**:
1. Victory conditions (highest priority)
2. Get caught check
3. Normal scene change

### Modifying Victory Conditions

**To change requirements**:
```gdscript
# In global.gd
var victory_conditions = {
	"stolen_coal": 5,      # Increase coal requirement
	"stolen_writs": 2,     # Decrease writ requirement
	"mechanisms": 3,       # Keep same
	"components": 10       # Add new condition
}
```

**Important**: New conditions must exist in `Level1Vars` or be checked differently.

---

## Resource Management

**Location**: [level1/level_1_vars.gd](../level1/level_1_vars.gd)

### Primary Resources

| Resource | Type | Starting Value | Purpose |
|----------|------|----------------|---------|
| `coal` | float | 0.0 | Mining resource |
| `coins` | float | 0.0 | Shop currency (legacy, synced with copper) |
| `components` | int | 0 | Crafting material |
| `mechanisms` | int | 0 | Victory resource |
| `pipes` | int | 5 | Puzzle resource |
| `stamina` | float | 125.0 | Action points |
| `stolen_coal` | int | 0 | Victory resource (stolen) |
| `stolen_writs` | int | 0 | Victory resource (stolen documents) |

### Multi-Currency System

**Location**: [currency_manager.gd](../currency_manager.gd), [level1/level_1_vars.gd](../level1/level_1_vars.gd)

GoA uses a 4-tier currency system with market volatility and exchange mechanics.

#### Currency Tiers

| Currency | Base Rate | Class Association | Volatility |
|----------|-----------|-------------------|------------|
| Copper Pieces | 1x | Laborers/destitute | vs Silver |
| Silver Marks | 100x | Merchants/artisans | vs Gold |
| Gold Crowns | 10,000x | Nobles/gentry | vs Platinum |
| Platinum Bonds | 1,000,000x | Ruling class | Stable anchor |

**Conversion**: 100 of lower tier = 1 of next tier (baseline)

#### Currency Storage

```gdscript
# In Level1Vars
var currency = {
	"copper": 0.0,
	"silver": 0.0,
	"gold": 0.0,
	"platinum": 0.0
}

var lifetime_currency = {  # Never decreases
	"copper": 0.0,
	"silver": 0.0,
	"gold": 0.0,
	"platinum": 0.0
}
```

#### Currency Exchange (ATM)

**Location**: [level1/atm.tscn](../level1/atm.tscn), [level1/atm.gd](../level1/atm.gd)

**Market Volatility**:
- Bell curve distribution (randfn with std dev 0.1)
- ±30% maximum deviation (extremes are rare)
- Updates every 15-30 minutes
- Only Copper, Silver, Gold fluctuate (Platinum stable)

**Transaction Fees**:
- Base: 8% for small transactions
- Floor: 1% minimum (never lower)
- Scaling: Logarithmic (larger = better rate)
- Charisma bonus: 2% reduction per level (respects floor)
- XP gain: Charisma gains XP equal to fee paid

**Currency Unlocks** (ATM-specific):
- Silver: Always available
- Gold: Unlocks at 60 silver (current holdings)
- Platinum: Unlocks at 60 gold (current holdings)

**Example Exchange**:
```gdscript
# Exchange 100 copper -> silver (baseline rates)
Fee: 8 copper (8%)
Net: 92 copper
Received: 0.92 silver
Charisma XP: 8
```

**Extreme Market Events**:
When volatility hits ±20-30%, classist grimdark notifications appear:
- High copper: "Furnace accident: labor shortage drives copper rates"
- Low copper: "Coal quotas doubled: labor value plummets"
- 18 total variants (3 per direction per currency)

**Usage**:
```gdscript
# Add currency
CurrencyManager.add_currency(CurrencyManager.CurrencyType.SILVER, 10.0)

# Check affordability
if CurrencyManager.can_afford({"silver": 5.0, "copper": 100.0}):
	CurrencyManager.deduct_currency({"silver": 5.0, "copper": 100.0})

# Exchange with fee (use at ATM)
var result = CurrencyManager.exchange_currency_with_fee(
	CurrencyManager.CurrencyType.COPPER,
	CurrencyManager.CurrencyType.SILVER,
	100.0
)
if result.success:
	print("Received: ", result.received, " silver")
	print("Fee: ", result.fee, " copper")
```

**See Also**: [.claude/plans/atm-currency-exchange.md](../.claude/plans/atm-currency-exchange.md)

### Upgrade Levels

| Upgrade | Starting Level | Purpose |
|---------|----------------|---------|
| `shovel_lvl` | 0 | Mining power |
| `plow_lvl` | 0 | Advanced mining |
| `auto_shovel_lvl` | 1 | Automation level |
| `overseer_lvl` | 0 | Break time extension |

### State Flags

| Flag | Type | Default | Purpose |
|------|------|---------|---------|
| `barkeep_bribed` | bool | false | Barkeep access unlocked |
| `shopkeep_bribed` | bool | false | Workshop access unlocked |
| `heart_taken` | bool | true | Heart quest status |
| `whisper_triggered` | bool | false | Whisper event occurred |
| `door_discovered` | bool | false | Secret door found |
| `shown_tired_notification` | bool | false | Stamina warning shown |
| `shown_lazy_notification` | bool | false | Laziness warning shown |

### Dynamic Resources

#### Max Stamina
```gdscript
var max_stamina:
	get:
		return 125.0 + (20 * Global.constitution)
```

Constitution-based scaling.

#### Suspicion
```gdscript
var suspicion = 0:
	set(value):
		suspicion = clamp(value, 0, 100)
```

Clamped between 0-100, affects get caught chance.

#### Timed Buffs
```gdscript
var stimulated_remaining = 0.0:  # Clamped 0-300
var resilient_remaining = 0.0:   # Clamped 0-300
```

Temporary buff durations.

---

## Suspicion & Get Caught Mechanics

**Location**: [global.gd](../global.gd) lines 346-363

### Overview

Suspicion system creates risk/reward tension. Higher suspicion increases catch chance, which resets progress.

### Suspicion Tracking

**Range**: 0 to 100 (clamped)

**Changes**:
- Increases: Player steals coal, does suspicious actions
- Decreases: Automatically -1 every 3 seconds (suspicion decrease timer)

### Get Caught Mechanic

#### `check_get_caught() -> bool`

**Purpose**: Determine if player gets caught based on suspicion

**Logic** (line 348-360):
```gdscript
func check_get_caught() -> bool:
	# Only check if suspicion is 17% or higher
	if Level1Vars.suspicion >= 17:
		# Percentage chance equal to third of suspicion level
		var caught_chance = (Level1Vars.suspicion / 100.0) / 3.0
		if randf() < caught_chance:
			# Player got caught!
			Level1Vars.stolen_coal = 0
			Level1Vars.suspicion = 0
			Level1Vars.coins = 0
			show_stat_notification("You've been caught, your coal and coins have been seized")
			return true
	return false
```

**Activation Threshold**: 17+ suspicion

**Catch Chance Formula**: `(suspicion / 100) / 3`

**Examples**:
- Suspicion 17: 5.7% chance per check
- Suspicion 30: 10% chance per check
- Suspicion 60: 20% chance per check
- Suspicion 90: 30% chance per check
- Suspicion 100: 33% chance per check

**Check Frequency**: Every 45 seconds (via get caught timer)

**Penalties on Caught**:
1. `stolen_coal` reset to 0
2. `suspicion` reset to 0
3. `coins` reset to 0
4. Notification shown

**Return Value**:
- `true` = Player was caught
- `false` = Player not caught (or suspicion < 17)

### Integration with Scene Changes

`change_scene_with_check()` includes get caught check:

```gdscript
func change_scene_with_check(scene_tree: SceneTree, scene_path: String):
	# Check victory first
	if check_victory_conditions():
		scene_tree.change_scene_to_file("res://victory.tscn")
		return

	# Check if caught
	if not check_get_caught():
		# Only change scene if NOT caught
		scene_tree.change_scene_to_file(scene_path)
	# If caught, stay in current scene
```

**Important**: Always use `change_scene_with_check()` instead of direct `change_scene_to_file()` to respect game mechanics.

---

## Best Practices

### Documentation Standards

**[!] CRITICAL: No Unicode Symbols in Documentation**

When documenting game systems, avoid unicode symbols (emoji, special characters like arrows, checkmarks, warning signs, etc.).

**Use Instead**: Plain ASCII markers ([!], [x], ->), words (WARNING, NOTE), or markdown formatting.

**Why**: Unicode symbols display incorrectly in web contexts (GitHub, browsers, terminals), breaking documentation readability.

### Experience & Stats

1. **Always use `add_stat_exp()`**: Never directly set stat values
2. **Check for balance**: Test XP gains feel rewarding but not too fast
3. **Document XP sources**: Keep track of where players earn experience

### Shop System

1. **Test cost scaling**: Ensure costs feel balanced across levels
2. **Progressive unlocking**: Gate advanced upgrades behind basic ones
3. **Clear requirements**: Show why buttons are disabled/hidden

### Timers

1. **Don't stack timers**: Use autoload timers in Global, not per-scene
2. **Test timing**: Ensure timer durations feel appropriate
3. **Handle edge cases**: What if player exits during timer?

### Resources

1. **Use Level1Vars**: Store level-specific state there, not Global
2. **Clamp values**: Prevent invalid states (negative resources, etc.)
3. **Save/Load compatible**: Ensure resources can be serialized

### Victory Conditions

1. **Use `check_and_trigger_victory()`**: After significant achievements
2. **Use `change_scene_with_check()`**: For all scene transitions
3. **Test all paths**: Ensure victory triggers correctly from any scene

---

**Version**: 1.0
**Last Updated**: 2025-10-29
**Maintained By**: Claude + User collaboration
