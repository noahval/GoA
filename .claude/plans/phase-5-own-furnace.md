# Phase 5: Own Furnace and Worker Management

**Status:** Planning
**Created:** 2025-11-11
**Dependencies:** Phases 1-4 (basic furnace mechanics, shop system, stats)

## Overview

Phase 5 represents a major shift in gameplay from being a worker in the Blackbore Furnace to becoming the owner and manager of your own furnace operation. This transition eliminates the overseer-based coin conversion system and introduces a new economy based on steam production, train operations, and meeting fluctuating demand.

### Core Gameplay Loop
1. **Generate Heat** - Shovel coal manually or via workers
2. **Produce Steam** - Heat converts to steam over time
3. **Meet Demand** - Steam demand fluctuates based on train conditions
4. **Earn Revenue** - Get paid based on how well you meet demand
5. **Manage Workers** - Hire and upgrade workers to optimize production

## Key Design Principles

- **No charisma requirement** (deferred for future phases)
- **No visual assets needed** (text-based UI following existing patterns)
- **New scene creation** - owned_furnace.tscn replaces furnace.tscn after purchase
- **Dynamic demand system** - Creates pressure and opportunity
- **Progressive worker management** - Starts simple, scales in complexity

---

## New Metrics & Systems

### 1. Furnace Heat

**Purpose:** Intermediate resource between coal shoveling and steam production

**Properties:**
- Type: Float, can accumulate
- Generation sources:
  - Manual shoveling: +1 heat per shovel (affected by strength bonuses)
  - Workers: Generate heat automatically based on worker level/count
  - Coal burning: Could implement coal auto-consumption for bonus heat
- Decay: Heat slowly dissipates over time (requires constant shoveling/workers)
- Display: Visual meter showing current heat level

**Formula:**
```gdscript
heat_per_shovel = 1.0 + (Global.strength * 0.1)  # Strength bonus
heat_decay_rate = 0.5  # per second
current_heat = clamp(current_heat - (heat_decay_rate * delta), 0, max_heat)
```

**Max Heat (Based on Real Materials):**
Max heat is determined by furnace construction material, wall thickness, and refractory lining:
```gdscript
max_heat = base_temp_limit * thickness_multiplier * lining_multiplier
```

See "Furnace Material & Construction System" section below for detailed progression.

### 2. Steam Generation

**Purpose:** Primary output resource that fulfills demand

**Properties:**
- Type: Float, accumulates in steam reservoir
- Generation rate: Based on current heat level
- Storage: Limited by furnace capacity (upgradeable)
- Display: Steam pressure gauge

**Formula:**
```gdscript
steam_per_second = (current_heat / 10.0) * steam_efficiency
steam_efficiency = 1.0 + (furnace_upgrade_lvl * 0.2)
max_steam = 500.0 + (capacity_upgrade_lvl * 200.0)
```

### 3. Steam Demand (Dynamic System) ⭐

**Purpose:** Creates dynamic gameplay with fluctuating requirements

**Demand States:**
- **Low Demand** (0.5x base): Train coasting, stopped at station, light load
- **Normal Demand** (1.0x base): Steady operation on flat terrain
- **High Demand** (1.5x base): Climbing grade, accelerating, heavy load
- **Critical Demand** (2.5x base): Steep hill, multiple trains, furnace failures

**Properties:**
- Type: Float, represents steam consumption rate
- Base demand: 5.0 steam per second
- Multiplier: 0.5x to 2.5x based on current state
- Transition: Changes every 15-45 seconds with gradual ramping

**Environmental Factors:**
```gdscript
# Demand reasons (displayed to player)
DEMAND_REASONS = {
    "low": [
        "Train stopped at Copper Ridge Station",
        "Light passenger load today",
        "Coasting downhill into the valley",
        "Other furnaces covering the load"
    ],
    "normal": [
        "Steady run on flat terrain",
        "Regular freight schedule",
        "Standard operations"
    ],
    "high": [
        "Climbing toward High Peak",
        "Heavy ore shipment",
        "Accelerating through switchyard",
        "Two furnaces offline for maintenance"
    ],
    "critical": [
        "Emergency! Steep mountain grade!",
        "All other furnaces failed!",
        "Runaway coal train needs stopping!",
        "Governor's express - maximum priority!"
    ]
}
```

**Demand Fluctuation Logic:**
```gdscript
var demand_state: String = "normal"
var demand_multiplier: float = 1.0
var target_multiplier: float = 1.0
var demand_transition_speed: float = 0.1

func _process(delta):
    # Gradually transition to target
    demand_multiplier = lerp(demand_multiplier, target_multiplier, demand_transition_speed * delta)

    # Check for state change (timer-based)
    if demand_timer <= 0:
        change_demand_state()
        demand_timer = randf_range(15.0, 45.0)

func change_demand_state():
    # Weighted random selection
    var roll = randf()
    if roll < 0.15:  # 15% critical
        set_demand_state("critical", 2.5)
    elif roll < 0.35:  # 20% high
        set_demand_state("high", 1.5)
    elif roll < 0.80:  # 45% normal
        set_demand_state("normal", 1.0)
    else:  # 20% low
        set_demand_state("low", 0.5)

func set_demand_state(state: String, multiplier: float):
    demand_state = state
    target_multiplier = multiplier
    var reason = DEMAND_REASONS[state][randi() % DEMAND_REASONS[state].size()]
    show_demand_notification(state, reason)
```

**Demand Fulfillment:**
```gdscript
var current_demand = base_demand * demand_multiplier
var steam_consumed = min(current_steam, current_demand * delta)
var fulfillment_rate = steam_consumed / (current_demand * delta)

# Performance tracking
if fulfillment_rate >= 1.0:
    performance = "excellent"  # Meeting or exceeding demand
elif fulfillment_rate >= 0.8:
    performance = "good"  # Mostly meeting demand
elif fulfillment_rate >= 0.5:
    performance = "poor"  # Struggling to keep up
else:
    performance = "failing"  # Severely underproducing
```

### 4. Train Speed & Revenue

**Purpose:** Convert performance into currency

**Train Speed:**
```gdscript
# Speed affected by how well demand is met
var base_train_speed = 50.0  # km/h
var speed_multiplier = fulfillment_rate  # 0.0 to 1.5 (can exceed with surplus)
var current_train_speed = base_train_speed * speed_multiplier
```

**Revenue Calculation:**
```gdscript
# Base payment per second
var base_revenue = 0.1  # coins per second

# Performance multipliers
var revenue_multipliers = {
    "excellent": 1.5,  # +50% bonus
    "good": 1.0,       # Standard rate
    "poor": 0.6,       # -40% penalty
    "failing": 0.3     # -70% penalty
}

# Bonus for exceeding demand during critical periods
if performance == "excellent" and demand_state == "critical":
    revenue_multipliers["excellent"] = 2.5  # +150% during crisis

var coins_per_second = base_revenue * revenue_multipliers[performance]
```

**Payment Timing:**
- Continuous accrual while in owned_furnace scene
- Display: "Revenue: +0.15 coins/sec" with color coding
- Lifetime earnings tracking

---

## Purchase System

### Furnace Ownership Purchase

**Location:** Overseer's Office scene ([level1/overseers_office.tscn](level1/overseers_office.tscn))

**Button Properties:**
- Text: "Buy Furnace Ownership"
- Position: Right panel, above or below Overtime button
- Visibility: Requires `lifetimecoins >= 1000` (or other milestone)
- Cost: 500 coins (significant investment)

**Purchase Flow:**
```gdscript
func _on_buy_furnace_button_pressed():
    var cost = 500
    if Level1Vars.coins >= cost:
        # Confirmation popup
        show_confirmation_popup(
            "Purchase Furnace Ownership?",
            "You'll become the furnace owner and shift to a new economic model. Cost: %d coins" % cost
        )

func confirm_purchase():
    var cost = 500
    Level1Vars.coins -= cost
    Level1Vars.furnace_owned = true

    # Track for prestige system
    UpgradeTypesConfig.track_equipment_purchase("furnace_ownership", cost)

    # Log purchase
    DebugLogger.log_shop_purchase("Furnace Ownership", cost, 1)

    # Show success notification
    show_notification("You are now the owner of a furnace! Report to your new station.")

    # Transition to owned furnace
    Global.change_scene_with_check(get_tree(), "res://level1/owned_furnace.tscn")
```

**One-Time Purchase:**
- Cannot be reversed
- Button disappears after purchase
- Unlocks worker management systems
- Changes bar scene navigation

---

## Scene Architecture

### Current Furnace (furnace.tscn)

**Remains as-is for non-owners:**
- Worker perspective
- Overseer interaction
- Coal → Coins conversion

### New Owned Furnace (owned_furnace.tscn)

**Purpose:** Manager/owner perspective with new mechanics

**Scene Structure:**
Inherit from scene_template.tscn (3-panel layout)

**Left Panel:**
- Title: "Your Furnace - Manager's Station"
- **Heat Gauge** (ProgressBar)
  - Shows current_heat / max_heat
  - Color: Red/orange gradient
  - Label: "Heat: 45 / 100"
- **Steam Gauge** (ProgressBar)
  - Shows current_steam / max_steam
  - Color: White/blue gradient
  - Label: "Steam: 250 / 500"
- **Demand Indicator** (Panel with RichTextLabel)
  - Shows current demand state (low/normal/high/critical)
  - Shows demand reason text
  - Color-coded: Green/Yellow/Orange/Red
- **Performance Display**
  - "Performance: Excellent" (color-coded)
  - "Revenue: +0.15 coins/sec" (green if positive)
- **Resource Display**
  - Coins
  - Coal (still used for shoveling)

**Right Panel Buttons:**
- **Shovel Coal** - Generates heat (replaces old coal generation)
  - Still costs stamina
  - Still gives strength XP
  - Now generates heat instead of coal
- **Manage Workers** - Opens worker management popup
- **Upgrade Furnace** - Opens furnace upgrade popup
- **Take Break** - Returns to bar

**Center Area:**
- Background: Could reuse furnace.jpg or create owned_furnace.jpg
- Could display animated elements (heat glow, steam pipes) in future

### Bar Scene Navigation Update

**File:** [level1/bar.gd](level1/bar.gd)

**Modified Function:**
```gdscript
func _on_to_blackbore_furnace_button_pressed():
    var target_scene
    if Level1Vars.furnace_owned:
        target_scene = "res://level1/owned_furnace.tscn"
    else:
        target_scene = "res://level1/furnace.tscn"
    Global.change_scene_with_check(get_tree(), target_scene)
```

**Button Text Update:**
- Before: "To Blackbore Furnace"
- After: "To Your Furnace" (when owned)

---

## Worker Management System

### Worker Types

**1. Stoker (Basic Coal Shoveler)**
- Generates heat automatically
- Cost scaling: `50 * pow(1.8, stoker_count)`
- Heat per second: `stoker_count * 1.5`
- Upgrade: Efficiency (heat per stoker)

**2. Fireman (Heat Manager)**
- Reduces heat decay rate
- Cost scaling: `200 * pow(2.0, fireman_count)`
- Decay reduction: `0.1 per fireman`
- Upgrade: Decay reduction amount

**3. Engineer (Steam Optimizer)**
- Increases steam generation efficiency
- Cost scaling: `500 * pow(2.2, engineer_count)`
- Efficiency bonus: `+10% per engineer`
- Upgrade: Efficiency percentage

### Worker Management UI

**Popup:** "Manage Workers" (similar to shop popups)

**Layout:**
```
+----------------------------------+
|  Worker Management            [X]|
+----------------------------------+
| Stokers: 3                       |
| [Hire Stoker - 231 coins]        |
| [Upgrade Stoker Efficiency]      |
|                                  |
| Firemen: 1                       |
| [Hire Fireman - 400 coins]       |
| [Upgrade Heat Retention]         |
|                                  |
| Engineers: 0                     |
| [Hire Engineer - 500 coins] (!)  |
| [Upgrade Steam Efficiency]       |
+----------------------------------+
```

**Button States:**
- Disabled if cannot afford
- Shows current level/count
- Shows next cost
- Progressive unlock (engineers require stokers/firemen)

**Worker Effects:**
```gdscript
func _process(delta):
    # Worker heat generation
    var worker_heat = Level1Vars.stoker_count * 1.5 * delta
    current_heat += worker_heat

    # Heat decay reduction
    var decay_rate = base_decay_rate - (Level1Vars.fireman_count * 0.1)
    current_heat -= max(decay_rate, 0.1) * delta

    # Steam efficiency
    var efficiency = 1.0 + (Level1Vars.engineer_count * 0.1)
    var steam_gen = (current_heat / 10.0) * efficiency * delta
    current_steam += steam_gen
```

---

### Furnace Upgrade UI

**Popup:** "Furnace Upgrades" (tabbed or scrollable interface)

The furnace upgrade system is more complex than worker management, so it benefits from a multi-section UI:

**Tab 1: Shell Material**
```
+----------------------------------+
|  Furnace Upgrades - Material  [X]|
+----------------------------------+
| Current: Cast Iron Shell         |
| Max Temp: 700°C                  |
| Runtime: 15.3 hours              |
|                                  |
| [✓] Cast Iron - 700°C            |
|     (Starting material)          |
|                                  |
| [🔒] Wrought Iron - 900°C        |
|     Cost: 800 coins              |
|     Requires: 20 runtime hours   |
|                                  |
| [🔒] Mild Steel - 1,100°C        |
|     Cost: 2,500 coins            |
|     Requires: Wrought Iron +     |
|               50 runtime hours   |
|                                  |
| [🔒] Cupola Design - 1,550°C     |
|     Cost: 8,000 coins +          |
|           50 components          |
|     Requires: Mild Steel +       |
|               100 runtime hours  |
+----------------------------------+
```

**Tab 2: Wall Thickness**
```
+----------------------------------+
|  Furnace Upgrades - Thickness [X]|
+----------------------------------+
| Current Material: Cast Iron      |
| Current Thickness: Thin          |
|                                  |
| [✓] Thin Wall - 1.0x             |
|     (Included with material)     |
|                                  |
| [ ] Standard Wall - 1.15x        |
|     Cost: 240 coins              |
|     Effect: +15% max heat        |
|             -10% decay rate      |
|                                  |
| [ ] Heavy Wall - 1.3x            |
|     Cost: 480 coins              |
|     Effect: +30% max heat        |
|             -20% decay rate      |
|                                  |
| [🔒] Reinforced Wall - 1.5x      |
|     Requires: Tier 4+ material   |
+----------------------------------+
```

**Tab 3: Refractory Lining**
```
+----------------------------------+
|  Furnace Upgrades - Lining    [X]|
+----------------------------------+
| Current: None                    |
| Lining Durability: N/A           |
|                                  |
| [✓] No Lining - 1.0x             |
|                                  |
| [ ] Firebrick - 1.3x             |
|     Cost: 300 coins              |
|     Max: 960°C                   |
|     Durability: 100 hours        |
|     Requires: Tier 2+ material   |
|                                  |
| [🔒] High-Alumina - 1.6x         |
|     Cost: 1,200 coins            |
|     Max: 1,788°C                 |
|     Durability: 200 hours        |
|     Requires: Tier 3+ material   |
|                                  |
| [Replace Current Lining]         |
|     Cost: (same as purchase)     |
|     (Only visible when degraded) |
+----------------------------------+
```

**Tab 4: Special Systems**
```
+----------------------------------+
|  Furnace Upgrades - Systems   [X]|
+----------------------------------+
| Steam & Support Systems          |
|                                  |
| [ ] Steam Reservoir Upgrade      |
|     Level: 0 → 1                 |
|     Cost: 150 coins              |
|     Effect: +200 max steam       |
|                                  |
| [ ] Steam Efficiency Upgrade     |
|     Level: 0 → 1                 |
|     Cost: 200 coins              |
|     Effect: +20% steam/heat      |
|                                  |
| [🔒] Cooling System              |
|     Cost: 1,500 coins            |
|     Effect: -30% heat decay      |
|     Requires: Mild Steel+        |
|                                  |
| [🔒] Forced Air Injection        |
|     Cost: 3,000 coins +          |
|           25 mechanisms          |
|     Effect: +25% heat from coal  |
|     Requires: Cupola Design+     |
|                                  |
| [ ] Temperature Monitoring       |
|     Cost: 500 coins              |
|     Effect: Shows exact temp,    |
|             advance warnings     |
+----------------------------------+
```

**UI Features:**
- **Color Coding:**
  - ✓ Green checkmark = Owned/Active
  - 🔒 Red lock = Locked (requirements not met)
  - White = Available for purchase
- **Dynamic Calculations:**
  - Show resulting max temperature after each upgrade
  - Display total cost including components/mechanisms
  - Preview effects before purchase
- **Tooltips:**
  - Hover/tap on materials for historical context
  - Explain temperature limits and applications
- **Current Status Panel:**
  - Always visible at top
  - Shows current configuration and stats
  - Updates immediately after purchase

**Example Status Display:**
```
Current Configuration:
- Material: Mild Steel (1,100°C base)
- Thickness: Heavy Wall (1.3x)
- Lining: High-Alumina (1.6x, 82% durability)
- Calculated Max: 1,788°C (capped by lining)
- Systems: Cooling, Temperature Monitoring

Effective Stats:
- Max Heat: 1,788°C
- Heat Decay: 0.35/sec (base 0.5 - 30% cooling)
- Steam Efficiency: 2.4x (base 1.0 + efficiency upgrades)
```

---

## Economy Model Changes

### Removed Mechanics
- ❌ Overseer interaction (no more manual coin conversion)
- ❌ Overseer mood system (no longer relevant)
- ❌ Coal-to-coins button
- ❌ Manual claiming coins
- ❌ Coal per coin scaling

### New Mechanics
- ✅ Heat → Steam production chain
- ✅ Demand-based performance evaluation
- ✅ Continuous revenue stream
- ✅ Worker-based automation
- ✅ Furnace capacity upgrades

### Furnace Material & Construction System

**Design Philosophy:** Realistic progression through metallurgical history, with actual temperature limits based on real materials and industrial furnace types.

---

#### 1. Furnace Shell Material Progression

Each material upgrade unlocks higher base temperature limits and represents historical/industrial evolution.

**Tier 1: Cast Iron Shell** *(Starting Material)*
- **Base Temp Limit:** 700°C (1,292°F)
- **Historical Context:** Early steam locomotive fireboxes, simple foundry work
- **Real Limitation:** Cast iron melts at 1,150-1,300°C, but working temperature kept well below softening point
- **Characteristics:** Brittle, affordable, adequate for basic steam generation
- **Cost:** Included with initial furnace purchase
- **Unlocks:** Basic steam furnace operations

**Tier 2: Wrought Iron Shell**
- **Base Temp Limit:** 900°C (1,652°F)
- **Historical Context:** Mid-1800s improvement for steam locomotives
- **Real Limitation:** Wrought iron melts at 1,480-1,590°C, more ductile than cast iron
- **Characteristics:** Better thermal cycling resistance, less likely to crack
- **Cost:** 800 coins
- **Requirements:** 20 lifetime furnace runtime hours
- **Unlocks:** Improved steam pressure capabilities

**Tier 3: Mild Steel Shell**
- **Base Temp Limit:** 1,100°C (2,012°F)
- **Historical Context:** Late 1800s standard for industrial boilers
- **Real Limitation:** Steel softens around 600-700°C but modern designs use water cooling and refractory
- **Characteristics:** Strong, consistent, allows pressure vessel operations
- **Cost:** 2,500 coins
- **Requirements:** Wrought iron shell, 50 lifetime hours
- **Unlocks:** Transition to industrial smelting capabilities

**Tier 4: Cupola Furnace Design** *(Cast Iron Smelting)*
- **Base Temp Limit:** 1,550°C (2,822°F)
- **Historical Context:** Traditional cast iron melting furnace (1700s-present)
- **Real Limitation:** Actual cupola operating temperature
- **Characteristics:** Cylindrical steel shell with thick refractory lining, continuous operation
- **Cost:** 8,000 coins + 50 components
- **Requirements:** Mild steel shell, 100 lifetime hours
- **Unlocks:** Cast iron melting, component self-production

**Tier 5: Blast Furnace Design** *(Iron Smelting)*
- **Base Temp Limit:** 1,600°C (2,912°F)
- **Historical Context:** Large-scale iron production (1500s-present)
- **Real Limitation:** Industrial blast furnace operating temperature
- **Characteristics:** Tall design, forced air injection, continuous feed
- **Cost:** 20,000 coins + 150 components + 100 mechanisms
- **Requirements:** Cupola design, 200 lifetime hours
- **Unlocks:** Iron ore processing, advanced metallurgy

**Tier 6: Electric Induction Furnace**
- **Base Temp Limit:** 1,800°C (3,272°F)
- **Historical Context:** Modern foundry standard (1900s-present)
- **Real Limitation:** Industrial induction furnace typical operating range
- **Characteristics:** Electromagnetic heating, precise temperature control, clean process
- **Cost:** 50,000 coins + 300 components + 200 mechanisms + 100 pipes
- **Requirements:** Blast furnace design, 300 lifetime hours, Power System unlocked
- **Unlocks:** High-grade steel production, rapid melting

**Tier 7: Electric Arc Furnace**
- **Base Temp Limit:** 3,000°C (5,432°F)
- **Historical Context:** Modern steelmaking and specialty alloy production
- **Real Limitation:** Industrial EAF operating temperature
- **Characteristics:** Arc plasma heating, extreme temperatures, alloy production
- **Cost:** 150,000 coins + 500 components + 500 mechanisms + 300 pipes
- **Requirements:** Induction furnace, 500 lifetime hours, Advanced Power System
- **Unlocks:** Specialty steel, tool steel, high-performance alloys

---

#### 2. Wall Thickness Upgrades

Each material can be upgraded with thicker walls, increasing heat capacity and structural integrity.

**Thin Wall** *(Default)*
- **Multiplier:** 1.0x base temperature
- **Characteristics:** Standard thickness, adequate for normal operations
- **Cost:** Included with material purchase

**Standard Wall**
- **Multiplier:** 1.15x base temperature
- **Characteristics:** Improved heat retention, slower cooling
- **Cost per material:** `current_material_cost * 0.3`
- **Effect:** +15% max heat, -10% heat decay rate

**Heavy Wall**
- **Multiplier:** 1.3x base temperature
- **Characteristics:** Excellent thermal mass, stable operation
- **Cost per material:** `current_material_cost * 0.6`
- **Effect:** +30% max heat, -20% heat decay rate

**Reinforced Wall** *(Tiers 4+)*
- **Multiplier:** 1.5x base temperature
- **Characteristics:** Maximum durability, extended high-temp operation
- **Cost per material:** `current_material_cost * 1.0`
- **Effect:** +50% max heat, -30% heat decay rate
- **Requirements:** Tier 4+ furnace design

---

#### 3. Refractory Lining Progression

Protective heat-resistant linings that allow shell materials to safely contain higher temperatures.

**No Lining** *(Tiers 1-2 Default)*
- **Multiplier:** 1.0x
- **Characteristics:** Direct metal-to-flame contact, limited to low temperatures
- **Suitable for:** Basic steam operations only

**Firebrick Lining** *(Basic Refractory)*
- **Multiplier:** 1.3x
- **Max Operating Temp:** 960°C (1,760°F)
- **Historical Context:** Traditional furnace lining since ancient times
- **Composition:** Silica and alumina clay bricks
- **Cost:** 300 coins
- **Requirements:** Tier 2+ (Wrought iron shell or better)
- **Effect:** +30% temperature limit
- **Maintenance:** Degrades slowly, needs replacement every 100 hours

**High-Alumina Firebrick** *(Improved Refractory)*
- **Multiplier:** 1.6x
- **Max Operating Temp:** 1,788°C (3,250°F)
- **Historical Context:** 1900s development for high-temperature industry
- **Composition:** 50-90% alumina content
- **Cost:** 1,200 coins
- **Requirements:** Tier 3+ (Mild steel or better)
- **Effect:** +60% temperature limit, excellent thermal shock resistance
- **Maintenance:** More durable, replacement every 200 hours

**Mullite-Zirconia Lining** *(Advanced Refractory)*
- **Multiplier:** 1.9x
- **Max Operating Temp:** 2,072°C (3,762°F)
- **Historical Context:** Modern advanced ceramics
- **Composition:** Alumina-zirconia composite
- **Cost:** 5,000 coins + 20 components
- **Requirements:** Tier 5+ (Blast furnace or better)
- **Effect:** +90% temperature limit, superior slag resistance
- **Maintenance:** Replacement every 300 hours

**Magnesia Lining** *(Super Refractory)*
- **Multiplier:** 2.2x
- **Max Operating Temp:** 2,852°C (5,166°F)
- **Historical Context:** Modern steelmaking standard
- **Composition:** Magnesium oxide (MgO)
- **Cost:** 15,000 coins + 100 components + 50 mechanisms
- **Requirements:** Tier 6+ (Electric induction or better)
- **Effect:** +120% temperature limit, extreme heat resistance
- **Maintenance:** Replacement every 400 hours

**Silicon Carbide Lining** *(Extreme Applications)*
- **Multiplier:** 2.5x
- **Max Operating Temp:** 1,650°C (3,002°F) - *Note: Lower than magnesia but better thermal conductivity*
- **Historical Context:** Specialty applications, high thermal stress environments
- **Composition:** SiC ceramic
- **Cost:** 25,000 coins + 200 components + 100 mechanisms
- **Requirements:** Tier 7 (Electric arc furnace)
- **Effect:** +150% temperature limit, excellent thermal conductivity, rapid heating
- **Special:** Oxidizes in air above 1,650°C - requires protective atmosphere
- **Maintenance:** Replacement every 500 hours

---

#### 4. Complete Temperature Calculation

```gdscript
# Base temperature from material tier
var base_temps = {
    "cast_iron": 700,      # °C
    "wrought_iron": 900,
    "mild_steel": 1100,
    "cupola": 1550,
    "blast_furnace": 1600,
    "induction": 1800,
    "arc_furnace": 3000
}

# Wall thickness multipliers
var thickness_mult = {
    "thin": 1.0,
    "standard": 1.15,
    "heavy": 1.3,
    "reinforced": 1.5
}

# Refractory lining multipliers
var lining_mult = {
    "none": 1.0,
    "firebrick": 1.3,        # Max 960°C effective
    "high_alumina": 1.6,     # Max 1788°C effective
    "mullite_zirconia": 1.9, # Max 2072°C effective
    "magnesia": 2.2,         # Max 2852°C effective
    "silicon_carbide": 2.5   # Max 1650°C effective (special case)
}

# Calculate max heat
func calculate_max_heat():
    var base = base_temps[current_material]
    var thickness = thickness_mult[current_thickness]
    var lining = lining_mult[current_lining]

    var calculated_temp = base * thickness * lining

    # Apply refractory material limits
    var lining_limits = {
        "firebrick": 960,
        "high_alumina": 1788,
        "mullite_zirconia": 2072,
        "magnesia": 2852,
        "silicon_carbide": 1650
    }

    if current_lining in lining_limits:
        calculated_temp = min(calculated_temp, lining_limits[current_lining])

    return calculated_temp
```

**Example Progressions:**

*Early Game:*
- Cast Iron (700°C) + Thin (1.0x) + No Lining (1.0x) = **700°C max heat**
- Suitable for basic steam generation

*Mid Game:*
- Mild Steel (1,100°C) + Standard (1.15x) + High-Alumina (1.6x) = **2,024°C**, capped at **1,788°C by lining**
- Suitable for steel melting and advanced operations

*Late Game:*
- Arc Furnace (3,000°C) + Reinforced (1.5x) + Magnesia (2.2x) = **9,900°C**, capped at **2,852°C by lining**
- Suitable for specialty alloys and extreme metallurgy

---

#### 5. Other Furnace Upgrades

**Steam Reservoir Capacity**
- Cost: `150 * pow(1.7, steam_capacity_lvl)`
- Effect: +200 max steam per level
- Buffer against demand spikes

**Steam Generation Efficiency**
- Cost: `200 * pow(1.8, efficiency_lvl)`
- Effect: +20% steam per heat per level
- Core economic upgrade

**Cooling System** *(Tiers 3+)*
- Cost: 1,500 coins
- Effect: Allows higher operating temperatures safely, -30% heat decay
- Requirements: Mild steel shell or better

**Forced Air Injection** *(Tiers 4+)*
- Cost: 3,000 coins + 25 mechanisms
- Effect: +25% heat generation from coal, enables blast furnace operations
- Requirements: Cupola design or better

**Temperature Monitoring** *(Quality of Life)*
- Cost: 500 coins
- Effect: Shows exact temperature readout, advance warning when approaching limits
- Visual: Thermometer gauge on UI

---

#### 6. Educational Flavor Text & Historical Context

When players purchase material upgrades, show brief historical/educational popups:

**Cast Iron Shell Unlock:**
> "Cast iron furnaces dominated early industry, but brittleness limited their use to moderate temperatures. The Darby family revolutionized ironmaking in 1709 with coke-fired furnaces, but the material itself remained the limiting factor."

**Wrought Iron Shell Unlock:**
> "Wrought iron's fibrous structure and lower carbon content made it more ductile and resistant to thermal stress. By the mid-1800s, it was the preferred material for steam locomotive fireboxes and pressure vessels."

**Mild Steel Shell Unlock:**
> "The Bessemer process (1856) and later the open-hearth furnace made steel affordable and consistent. Steel combined the best properties of cast and wrought iron, enabling the Industrial Revolution's greatest achievements."

**Cupola Furnace Unlock:**
> "The cupola furnace has been melting cast iron since the 1700s. Its tall cylindrical design creates a continuous process—coke, limestone, and iron are charged at the top while molten metal pours from the bottom. Your furnace can now reach 1,550°C."

**Blast Furnace Unlock:**
> "Blast furnaces use forced air ('blast') to reach extreme temperatures for smelting iron ore. The tall structure creates counter-current heat exchange, with rising hot gases preheating descending raw materials. Modern blast furnaces produce hundreds of tons of iron per day."

**Induction Furnace Unlock:**
> "Electromagnetic induction heats metal without direct contact, discovered by Michael Faraday in 1831 but not industrialized until the 1900s. Clean, precise, and efficient—perfect for high-grade steel production. Your furnace now operates at 1,800°C."

**Electric Arc Furnace Unlock:**
> "Electric arc furnaces use electrode arcs hot enough to vaporize tungsten (3,422°C). First developed by Paul Héroult in 1900, they now produce most of the world's steel. Arc plasma reaches 3,000-5,000°C—the temperature of the sun's surface."

**Firebrick Lining Unlock:**
> "Firebrick, or refractory brick, has protected furnace walls since ancient times. Made from alumina-silica clay, it insulates and protects metal shells from direct flame contact, enabling higher operating temperatures."

**High-Alumina Lining Unlock:**
> "High-alumina refractories (50-90% Al₂O₃) were developed in the early 1900s for the growing steel industry. Excellent thermal shock resistance and a melting point above 1,750°C made them indispensable for modern metallurgy."

**Magnesia Lining Unlock:**
> "Magnesium oxide (MgO) refractories are 'super refractories' with melting points exceeding 2,800°C. Used in modern steel furnaces and cement kilns, they resist basic slags and extreme temperatures that would destroy other materials."

**Silicon Carbide Lining Unlock:**
> "Silicon carbide (SiC), discovered by Edward Acheson in 1891, is nearly as hard as diamond and conducts heat better than copper. In reducing atmospheres, it can withstand extreme thermal stress. However, it oxidizes rapidly above 1,650°C in air—handle with care."

**Gameplay Integration:**
- Show these messages as popup notifications on first purchase
- Store in a "Furnace Encyclopedia" accessible from UI
- Optional: Quiz system (similar to overseer talks) where answering metallurgy questions gives bonuses
- Achievement system: "Metallurgist" for collecting all furnace types, "Alchemist" for reaching 3,000°C

---

## Technical Implementation

### Level1Vars Additions

**File:** [level1/level_1_vars.gd](level1/level_1_vars.gd)

```gdscript
# Furnace Ownership
var furnace_owned: bool = false
var lifetime_furnace_hours: float = 0.0  # Tracks runtime for unlock requirements

# Furnace Material System
var furnace_material: String = "cast_iron"  # cast_iron, wrought_iron, mild_steel, cupola, blast_furnace, induction, arc_furnace
var furnace_thickness: String = "thin"       # thin, standard, heavy, reinforced
var furnace_lining: String = "none"          # none, firebrick, high_alumina, mullite_zirconia, magnesia, silicon_carbide
var lining_durability: float = 100.0         # Percentage, degrades over time, needs replacement

# Heat System
var current_heat: float = 0.0
var max_heat: float = 700.0  # Calculated dynamically based on material/thickness/lining

# Steam System
var current_steam: float = 0.0
var max_steam: float = 500.0
var steam_capacity_lvl: int = 0
var steam_efficiency_lvl: int = 0

# Material Upgrades Unlocked
var materials_unlocked: Dictionary = {
    "cast_iron": true,
    "wrought_iron": false,
    "mild_steel": false,
    "cupola": false,
    "blast_furnace": false,
    "induction": false,
    "arc_furnace": false
}

var linings_unlocked: Dictionary = {
    "none": true,
    "firebrick": false,
    "high_alumina": false,
    "mullite_zirconia": false,
    "magnesia": false,
    "silicon_carbide": false
}

# Special Systems
var cooling_system_installed: bool = false
var forced_air_installed: bool = false
var temp_monitoring_installed: bool = false

# Demand System
var demand_state: String = "normal"
var demand_multiplier: float = 1.0
var base_demand_rate: float = 5.0

# Performance Tracking
var performance_rating: String = "good"
var fulfillment_rate: float = 1.0
var lifetime_steam_produced: float = 0.0
var lifetime_revenue: float = 0.0

# Worker Counts
var stoker_count: int = 0
var stoker_efficiency_lvl: int = 0
var fireman_count: int = 0
var fireman_efficiency_lvl: int = 0
var engineer_count: int = 0
var engineer_efficiency_lvl: int = 0
```

### Owned Furnace Scene Script

**File:** `level1/owned_furnace.gd` (new)

**Key Functions:**

```gdscript
extends Control

# UI References
@onready var heat_bar = $HBoxContainer/LeftVBox/HeatBar
@onready var steam_bar = $HBoxContainer/LeftVBox/SteamBar
@onready var demand_panel = $HBoxContainer/LeftVBox/DemandPanel
@onready var performance_label = $HBoxContainer/LeftVBox/PerformanceLabel
@onready var revenue_label = $HBoxContainer/LeftVBox/RevenueLabel

# Timers
var demand_timer: float = 30.0
var revenue_timer: float = 1.0

func _ready():
    ResponsiveLayout.apply_to_scene(self)
    update_ui()

func _process(delta):
    process_heat(delta)
    process_steam(delta)
    process_demand(delta)
    process_revenue(delta)
    update_ui()

func process_heat(delta):
    # Worker generation
    var worker_heat = Level1Vars.stoker_count * (1.5 + Level1Vars.stoker_efficiency_lvl * 0.3)
    Level1Vars.current_heat += worker_heat * delta

    # Heat decay
    var decay = 0.5 - (Level1Vars.fireman_count * 0.1)
    Level1Vars.current_heat = max(0, Level1Vars.current_heat - decay * delta)

    # Clamp to max
    Level1Vars.current_heat = min(Level1Vars.current_heat, Level1Vars.max_heat)

func process_steam(delta):
    # Generate steam from heat
    var efficiency = 1.0 + (Level1Vars.engineer_count * 0.1) + (Level1Vars.steam_efficiency_lvl * 0.2)
    var steam_gen = (Level1Vars.current_heat / 10.0) * efficiency * delta
    Level1Vars.current_steam += steam_gen
    Level1Vars.lifetime_steam_produced += steam_gen

    # Consume steam for demand
    var demand = Level1Vars.base_demand_rate * Level1Vars.demand_multiplier * delta
    var consumed = min(Level1Vars.current_steam, demand)
    Level1Vars.current_steam -= consumed

    # Calculate fulfillment
    Level1Vars.fulfillment_rate = consumed / demand if demand > 0 else 1.0

    # Update performance rating
    if Level1Vars.fulfillment_rate >= 1.0:
        Level1Vars.performance_rating = "excellent"
    elif Level1Vars.fulfillment_rate >= 0.8:
        Level1Vars.performance_rating = "good"
    elif Level1Vars.fulfillment_rate >= 0.5:
        Level1Vars.performance_rating = "poor"
    else:
        Level1Vars.performance_rating = "failing"

    # Clamp to max
    Level1Vars.current_steam = min(Level1Vars.current_steam, Level1Vars.max_steam)

func process_demand(delta):
    demand_timer -= delta
    if demand_timer <= 0:
        change_demand_state()
        demand_timer = randf_range(15.0, 45.0)

    # Smooth transition to target multiplier
    # (implement gradual lerp as shown in demand system section)

func process_revenue(delta):
    # Calculate coins per second based on performance
    var revenue_multipliers = {
        "excellent": 1.5 if Level1Vars.demand_state != "critical" else 2.5,
        "good": 1.0,
        "poor": 0.6,
        "failing": 0.3
    }

    var base_revenue = 0.1
    var coins_earned = base_revenue * revenue_multipliers[Level1Vars.performance_rating] * delta

    Level1Vars.coins += coins_earned
    Level1Vars.lifetimecoins += coins_earned
    Level1Vars.lifetime_revenue += coins_earned

func _on_shovel_coal_button_pressed():
    # Similar to old furnace, but generates heat instead of coal
    if Level1Vars.stamina >= 1.0:
        Level1Vars.stamina -= 1.0

        var heat_gained = 1.0 + (Global.strength * 0.1)
        Level1Vars.current_heat += heat_gained

        Global.add_stat_exp("strength", 0.4)

        # Coal still used for fuel (optional)
        Level1Vars.coal += 1

func update_ui():
    heat_bar.value = (Level1Vars.current_heat / Level1Vars.max_heat) * 100
    steam_bar.value = (Level1Vars.current_steam / Level1Vars.max_steam) * 100

    # Demand panel with color coding
    var demand_colors = {
        "low": Color.GREEN,
        "normal": Color.YELLOW,
        "high": Color.ORANGE,
        "critical": Color.RED
    }
    demand_panel.modulate = demand_colors[Level1Vars.demand_state]

    # Performance and revenue
    var perf_colors = {
        "excellent": Color.GREEN,
        "good": Color.YELLOW,
        "poor": Color.ORANGE,
        "failing": Color.RED
    }
    performance_label.modulate = perf_colors[Level1Vars.performance_rating]
```

### UpgradeTypesConfig Updates

**File:** [upgrade_types_config.gd](upgrade_types_config.gd)

```gdscript
const EQUIPMENT_UPGRADES = [
    "shovel", "plow", "auto_shovel",
    "coal_per_tick", "frequency",
    "overtime",
    # Phase 5 additions - Workers
    "furnace_ownership",
    "stoker",
    "fireman",
    "engineer",
    # Phase 5 additions - Furnace Materials
    "wrought_iron_shell",
    "mild_steel_shell",
    "cupola_design",
    "blast_furnace_design",
    "induction_furnace",
    "arc_furnace",
    # Phase 5 additions - Wall Thickness
    "standard_wall",
    "heavy_wall",
    "reinforced_wall",
    # Phase 5 additions - Refractory Linings
    "firebrick_lining",
    "high_alumina_lining",
    "mullite_zirconia_lining",
    "magnesia_lining",
    "silicon_carbide_lining",
    # Phase 5 additions - Other Systems
    "steam_capacity",
    "steam_efficiency",
    "cooling_system",
    "forced_air",
    "temp_monitoring"
]
```

### Save/Load Integration

**Files:**
- `save_manager.gd`
- `nakama_sync.gd`

Add all new Level1Vars variables to save/load dictionaries:
- furnace_owned
- current_heat, max_heat, heat_capacity_lvl
- current_steam, max_steam, steam_capacity_lvl, steam_efficiency_lvl
- demand_state, demand_multiplier
- Worker counts and levels
- Lifetime tracking variables

---

## Step-by-Step Implementation Checklist

### Phase 5A: Core Infrastructure (Foundation)

- [ ] **Update Level1Vars**
  - Add all furnace ownership variables
  - Add heat/steam variables
  - Add demand variables
  - Add worker variables
  - Test save/load with new variables

- [ ] **Create UpgradeTypesConfig entries**
  - Add all Phase 5 equipment types
  - Test prestige integration

- [ ] **Update Save System**
  - Add new vars to save_manager.gd
  - Add new vars to nakama_sync.gd
  - Test cloud sync compatibility

### Phase 5B: Purchase System

- [ ] **Update overseers_office.tscn**
  - Add "Buy Furnace Ownership" button to right panel
  - Position appropriately (near Overtime button)
  - Set visibility conditions

- [ ] **Update overseers_office.gd**
  - Add button reference
  - Implement _on_buy_furnace_button_pressed()
  - Add confirmation popup logic
  - Add purchase transaction with logging
  - Test purchase flow

- [ ] **Update bar.gd**
  - Modify _on_to_blackbore_furnace_button_pressed()
  - Add conditional scene selection
  - Update button text when owned
  - Test navigation both directions

### Phase 5C: Owned Furnace Scene

- [ ] **Create owned_furnace.tscn**
  - Inherit from scene_template.tscn
  - Build left panel (heat bar, steam bar, demand panel, etc.)
  - Build right panel (shovel, manage workers, upgrade, break buttons)
  - Set background image
  - Test responsive layout

- [ ] **Create owned_furnace.gd**
  - Implement _ready() and ResponsiveLayout
  - Implement process_heat()
  - Implement process_steam()
  - Implement _on_shovel_coal_button_pressed()
  - Implement update_ui()
  - Test basic functionality (shoveling generates heat)

### Phase 5D: Demand System

- [ ] **Implement demand fluctuation in owned_furnace.gd**
  - Add DEMAND_REASONS dictionary
  - Implement change_demand_state()
  - Implement process_demand() with timer
  - Add lerp transition for smooth changes
  - Implement show_demand_notification()
  - Test demand state transitions

- [ ] **Implement demand fulfillment tracking**
  - Calculate fulfillment_rate
  - Update performance_rating
  - Color-code UI based on performance
  - Test edge cases (no steam, excess steam)

### Phase 5E: Revenue System

- [ ] **Implement revenue calculation**
  - Add process_revenue() function
  - Implement performance multipliers
  - Add critical demand bonus
  - Update coins and lifetime tracking
  - Test revenue accrual at different performance levels

- [ ] **UI for revenue display**
  - Add revenue_label with real-time coins/sec
  - Color code based on performance
  - Add lifetime_revenue display somewhere
  - Test UI updates

### Phase 5F: Worker Management

- [ ] **Create worker management popup**
  - Design popup layout (similar to shop)
  - Add buttons for each worker type
  - Add upgrade buttons
  - Set visibility/enable conditions

- [ ] **Implement worker hiring**
  - Add _on_hire_stoker_pressed() etc.
  - Implement cost calculation
  - Add purchase transaction with logging
  - Update UI labels
  - Test hiring flow

- [ ] **Implement worker upgrades**
  - Add upgrade cost calculations
  - Add upgrade purchase logic
  - Track upgrade levels
  - Test upgrade effects

- [ ] **Integrate worker effects**
  - Update process_heat() with stoker generation
  - Update heat decay with fireman effects
  - Update steam efficiency with engineer effects
  - Test worker scaling

### Phase 5G: Furnace Upgrades

- [ ] **Create furnace upgrade popup**
  - Design popup layout
  - Add buttons for capacity, efficiency upgrades
  - Show current/next values

- [ ] **Implement furnace upgrades**
  - Heat capacity upgrade
  - Steam capacity upgrade
  - Steam efficiency upgrade
  - (Optional) Demand response time upgrade
  - Test each upgrade's effects

### Phase 5H: Polish & Balance

- [ ] **Balancing pass**
  - Tune heat generation rates
  - Tune steam generation rates
  - Tune demand levels and frequencies
  - Tune revenue rates
  - Tune upgrade costs
  - Test economic progression

- [ ] **UI polish**
  - Add tooltips/help text
  - Improve visual feedback
  - Add sound effects (if applicable)
  - Test readability on different screen sizes

- [ ] **Bug fixes & edge cases**
  - Test scene transitions
  - Test save/load during active production
  - Test offline time accumulation
  - Test with zero workers
  - Test with maxed workers

### Phase 5I: Integration & Testing

- [ ] **Victory condition updates**
  - Determine if furnace ownership affects victory
  - Update Global.victory_conditions if needed
  - Test victory flow

- [ ] **Debug logging**
  - Add logging for all major events
  - Add performance metrics logging
  - Test debug output

- [ ] **Full playthrough test**
  - Start fresh game
  - Progress through phases 1-4
  - Purchase furnace ownership
  - Test full worker management loop
  - Verify progression feels good

- [ ] **Documentation**
  - Update BIBLE.md with Phase 5 systems
  - Add Phase 5 to game-systems.md
  - Document worker types and strategies

---

## Future Enhancements (Post-Phase 5)

### Phase 5.5: Advanced Worker Management
- Worker traits/specializations
- Worker morale system
- Worker accidents/events
- Hiring screen with worker profiles

### Phase 6: Multiple Furnaces
- Own multiple furnaces
- Manage portfolio of operations
- Train network visualization
- Route optimization

### Integration with Other Systems
- Charisma requirement for furnace purchase
- Visual improvements (animated steam, heat glow)
- Sound effects (shoveling, steam hiss, demand alerts)
- Achievement system for performance milestones

---

## Dependencies & Prerequisites

### Required Before Implementation
- ✅ Basic furnace mechanics (Phase 1)
- ✅ Shop/purchase system (Phase 2)
- ✅ Global stats system
- ✅ Scene template and responsive layout
- ✅ Save/load system

### Deferred to Later Phases
- ⏸️ Charisma stat requirement
- ⏸️ Visual assets (sprites, animations)
- ⏸️ Advanced worker AI
- ⏸️ Multiple furnace management

---

## Notes & Design Rationale

### Why Steam Demand Fluctuation?
- Creates dynamic gameplay pressure
- Rewards player attention and optimization
- Provides risk/reward during critical periods
- Adds unpredictability and discovery
- Makes worker management meaningful (need buffer for spikes)

### Why Remove Overseer Conversion?
- Player is now the owner, not the worker
- Old economy was manual click-based
- New economy is continuous and management-focused
- Thematically appropriate progression

### Why Workers Instead of Full Automation?
- Maintains manual shoveling as core mechanic
- Workers augment rather than replace player action
- Provides clear upgrade path
- Allows flexible playstyles (active vs idle)

### Economic Balance Philosophy
- Early game: Manual shoveling dominant
- Mid game: Workers provide strong automation
- Late game: Optimization and efficiency upgrades
- Revenue should feel rewarding but not trivial

---

## Testing Scenarios

### Scenario 1: Zero Workers
- Player manually shovels
- Heat decays faster than generation
- Can only maintain low steam levels
- Struggles during high demand
- Revenue is poor but positive

### Scenario 2: Balanced Workers
- 2 stokers, 1 fireman, 1 engineer
- Heat generation matches decay
- Steam maintains steady level
- Meets normal demand, struggles with high
- Good revenue during normal, poor during spikes

### Scenario 3: Optimized Setup
- 5+ stokers, 3 firemen, 2 engineers
- Heat generation exceeds decay
- Steam rapidly fills reservoir
- Exceeds demand even during critical
- Excellent revenue consistently

### Scenario 4: Critical Demand Event
- Player has moderate steam reserves
- Critical demand triggered
- Steam drains quickly
- Player must manually shovel to help
- High reward if successful, high penalty if not

---

## Conclusion

Phase 5 represents a major evolution in GoA's gameplay, transitioning from worker to owner and introducing sophisticated resource management. The steam demand system creates engaging moment-to-moment decisions, while worker management provides long-term progression. The implementation is designed to be modular, testable, and extensible for future phases.

**Estimated Implementation Time:** 8-12 hours
**Complexity:** High (new systems, UI, balancing)
**Risk Level:** Medium (requires careful balancing, many integration points)
