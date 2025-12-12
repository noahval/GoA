# Phase 5: Own Furnace and Worker Management

**Status:** Planning
**Created:** 2025-11-11
**Updated:** 2025-11-12 (Currency costs reworked for Silver/Gold economy)
**Dependencies:** Phases 1-4 (basic furnace mechanics, shop system, stats)

**Currency System Note:** All costs in this document use the multi-currency system:
- 1 Silver = 1000 Copper
- 1 Gold = 1000 Silver
- 1 Platinum = 1000 Gold

Phase 5 begins at ~20 hours of gameplay, when players spend 1 gold to buy their own furnace.

## Overview

Phase 5 represents a major shift in gameplay from being a worker in the Blackbore Furnace to becoming the owner and manager of your own furnace operation. This transition eliminates the overseer-based coin conversion system and introduces a new economy based on steam production, train operations, and meeting fluctuating demand.

### Core Gameplay Loop
1. **Generate Heat** - Shovel coal manually or via workers
2. **Produce Steam** - Heat converts to steam over time
3. **Meet Demand** - Steam demand fluctuates based on train conditions
4. **Earn Revenue** - Get paid based on how well you meet demand
5. **Manage Workers** - Hire and upgrade workers to optimize production

## Key Design Principles

- **Charisma as obscure stat** - No explicit UI, but affects worker efficiency subtly
- **Leadership over labor** - Player manages and leads rather than shovels
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
heat_per_shovel = 1.0
heat_decay_rate = 0.5  # per second
current_heat = clamp(current_heat - (heat_decay_rate * delta), 0, max_heat)
```

**Max Heat (Based on Real Materials):**
Max heat is determined by furnace construction material, wall thickness, and refractory lining:
```gdscript
max_heat = base_temp_limit * thickness_multiplier * lining_multiplier
```

See "Furnace Material & Construction System" section below for detailed progression.

### 2. Steam Production

**Purpose:** Primary output resource that fulfills demand, measured in pounds per hour (lb/h)

**Properties:**
- Type: Float, measured in lb/h (pounds per hour)
- Production rate: Based on current heat level
- **No initial storage** - steam converts directly to gold payment
- Storage: Purchasable upgrade (unlocks about 3H into own furnace phase, starts at 5 gold)
- Display: Production rate gauge in lb/h

**Formula:**
```gdscript
# Steam production in pounds per hour (lb/h)
steam_production_rate_lbh = (current_heat / 10.0) * steam_efficiency
steam_efficiency = 1.0 + (furnace_upgrade_lvl * 0.2)

# Starting production: 10 lb/h
base_production = 10.0  # lb/h at base heat and efficiency

# Storage only available after purchase
has_storage_system = false  # Initially no storage
max_storage_lbs = 0.0  # Set when storage purchased (e.g., 500 lb for Tier 1)
```

### 3. Steam Demand (Dynamic System) ⭐

**Purpose:** Creates dynamic gameplay with fluctuating requirements, measured in decimals of gold coin per lb/h

**Demand States:**
- **Very Low Demand**: Range 0.0x - 0.45x (avg ~0.225x) - Train idling, coasting downhill, rare low revenue/storage opportunity
  - Oscillation period: 40-60s (slow, lazy drift)
- **Low Demand**: Range 0.45x - 0.75x (avg ~0.6x) - Light load, slow operation, reduced payment
  - Oscillation period: 30-40s (relaxed variation)
- **Medium Demand**: Range 0.75x - 1.35x (avg ~1.05x) - Steady operation on flat terrain, baseline payment
  - Oscillation period: 25-30s (standard rhythm)
- **High Demand**: Range 1.35x - 2.65x (avg ~2.0x) - Climbing grade, accelerating, bonus revenue opportunity
  - Oscillation period: 15-25s (urgent fluctuation)
- **Critical Demand**: Range 2.65x - 3.75x (avg ~3.2x) - Steep hill, emergency conditions, maximum revenue/stress event
  - Oscillation period: 10-20s (frantic, emergency pace)

**Note:** Multipliers smoothly interpolate within each state's range using sine wave oscillation with state-dependent periods. When state changes, multiplier starts at a random point within the new state's range for unpredictable transitions.

**Properties:**
- Type: Float, represents steam demand rate in lb/h (pounds per hour)
- Base demand: Starting around 10-15 lb/h at medium state
- Demand scales with train progression and upgrades
- Transition: Changes every 1-5 minutes (triangular distribution, avg ~2.5 min)
- Payment: Steam production × demand multiplier → Gold coins

**Environmental Factors:**
```gdscript
# Demand reasons (displayed to player)
DEMAND_REASONS = {
    "very_low": [
        "Coasting downhill: gravity assist",
        "Long downgrade through valley",
        "Descending eastern slope: minimal power",
        "Momentum carrying train through lowlands",
        "Deep night, all train districts sleeping",
        "Holiday, minimal train systems active",
        "Lower districts powered down for conservation",
        "Peasant quarters population reduced, less demand",
        "Gentle downhill run through foothills",
        "Slight descent, brakes engaged",
        "Cruising through lowland plains",
        "Tail wind assisting movement",
        "Rolling through river valley",
        "Night shift, residential districts dormant",
        "Mild weather, reduced heating demands",
        "Backup furnaces handling train base load",
        "Worker districts on rationing schedule",
        "Lower deck amenities disabled"
    ],
    "low": [
        "Light downgrade into basin",
        "Steady cruise on flat prairie",
        "Easy rolling through farmlands",
        "Gentle curves, maintaining speed",
        "Approaching downhill section",
        "Following river downstream",
        "Off-peak hours, light train demand",
        "Temperate weather, reduced steam demand",
        "Other furnaces covering most train needs",
        "Peasant district scheduled blackout period",
        "Third class quarters on reduced power allocation"
    ],
    "normal": [
        "Steady run on flat terrain",
        "Cruising across plains",
        "Maintaining speed through open country",
        "Regular travel pace",
        "Standard train operations",
        "Balanced residential and commercial load",
        "lower level amenities powered on"
    ],
    "high": [
        "Climbing toward High Peak",
        "Ascending the eastern slope",
        "Pulling uphill through switchbacks",
        "Fighting headwinds across plateau",
        "Accelerating from reduced speed",
        "Sharp curves requiring power",
        "Pushing through mountain pass",
        "Morning rush: all elevators running",
        "Factory district at full production",
        "Cold snap, residential heating surge",
        "Nobility ball: upper district lighting maxed",
        "Elite quarter demanding perfect climate control"
    ],
    "critical": [
        "Emergency! Climbing Devil's Backbone!",
        "Steep grade: maximum power needed!",
        "Triple switchback up Iron Mountain!",
        "Fighting blizzard headwinds uphill!",
        "Emergency acceleration required!",
        "Extreme grade with heavy load!",
        "All other furnaces failed!",
        "Catastrophic pressure drop: full steam NOW!",
        "Noble override: lower districts cut off!",
        "Aristocrat emergency: maximum power demanded!"
    ]
}
```

**Demand Fluctuation Logic:**
```gdscript
# Range definitions for each demand state
const DEMAND_RANGES = {
    "very_low": {"min": 0.0, "max": 0.45},      # Avg ~0.225x (replaces "zero")
    "low": {"min": 0.45, "max": 0.75},          # Avg ~0.6x
    "medium": {"min": 0.75, "max": 1.35},       # Avg ~1.05x
    "high": {"min": 1.35, "max": 2.65},         # Avg ~2.0x
    "critical": {"min": 2.65, "max": 3.75}      # Avg ~3.2x
}

# State variables
var demand_state: String = "medium"
var demand_multiplier: float = 1.05
var target_range_min: float = 0.75
var target_range_max: float = 1.35
var interpolation_time: float = 0.0
var interpolation_speed: float = 0.3  # Controls oscillation period (~27s)
var demand_timer: float = 150.0

func _process(delta):
    # Smooth sine wave interpolation within current range
    interpolation_time += delta * interpolation_speed
    var normalized = (sin(interpolation_time) + 1.0) / 2.0
    demand_multiplier = lerp(target_range_min, target_range_max, normalized)

    # Check for state change (timer-based)
    demand_timer -= delta
    if demand_timer <= 0:
        change_demand_state()
        # Triangular distribution: 1-5 minutes, weighted toward 2.5 minutes
        var rand1 = randf_range(60.0, 180.0)  # 1-3 minutes
        var rand2 = randf_range(60.0, 300.0)  # 1-5 minutes
        demand_timer = (rand1 + rand2) / 2.0  # Averages ~2.5 minutes

func change_demand_state():
    # Weighted random selection (5 states - "zero" removed)
    var roll = randf()
    if roll < 0.20:  # 20% very_low (+10% from removed "zero")
        set_demand_state("very_low")
    elif roll < 0.35:  # 15% low
        set_demand_state("low")
    elif roll < 0.70:  # 35% medium
        set_demand_state("medium")
    elif roll < 0.85:  # 15% high
        set_demand_state("high")
    else:  # 15% critical
        set_demand_state("critical")

func set_demand_state(state: String):
    demand_state = state
    target_range_min = DEMAND_RANGES[state]["min"]
    target_range_max = DEMAND_RANGES[state]["max"]

    # Reset to middle of new range for smooth transitions
    demand_multiplier = (target_range_min + target_range_max) / 2.0
    interpolation_time = 0.0

    # Show notification with random reason
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

### 4. Steam Storage System ⭐ (PURCHASABLE UPGRADE - Not Available Initially)

**Purpose:** **Optional upgrade** to capture excess steam during low/zero demand periods for use during high demand spikes

**Important:** Players start with **NO storage** - steam converts directly to Gold payment. Storage must be purchased as an upgrade.

**Unlock Requirements:**
- Capacity Tier 1 purchase unlocks the entire storage system (with 50% base efficiency)

**NEW: Two Independent Upgrade Paths**

The storage system now offers two separate upgrade progressions:
- **Capacity Upgrades:** Increase storage tank size (5 tiers)
- **Efficiency Upgrades:** Reduce storage loss (5 tiers)

Both paths are sequential within themselves but independent of each other. Players can prioritize capacity, efficiency, or balance both based on strategy and budget.

---

#### A. Storage Capacity Upgrades (5 Tiers)

**Capacity Tier 1: Steam Accumulator Tank** *(First Purchase Unlocks Storage)*
- **Cost:** 5 gold
- **Capacity:** 300 lb storage
- **Base Efficiency:** 50% (requires efficiency upgrades to improve)
- **Technology:** Simple insulated pressure vessel
- **Historical:** 1800s technology, used on traction engines and early locomotives
- **Description:** "A basic pressure vessel that stores excess steam when demand is low"
- **Unlocks:** has_storage_system = true, storage_capacity_tier = 1, storage_efficiency_tier = 0

**Capacity Tier 2: Compressed Steam Reservoir**
- **Cost:** 20 gold
- **Requires:** Capacity Tier 1
- **Capacity:** 800 lb total (+500 lb)
- **Technology:** High-pressure compression system
- **Description:** "Stores steam at higher pressure for increased capacity"

**Capacity Tier 3: Multi-Chamber Storage System**
- **Cost:** 75 gold
- **Requires:** Capacity Tier 2
- **Capacity:** 1,500 lb total (+700 lb)
- **Technology:** Multiple interconnected tanks with valves
- **Feature:** Unlocks manual release controls (10% increments) and auto-release system
- **Description:** "Interconnected tanks allow precise control over steam release"

**Capacity Tier 4: Hydraulic Accumulator**
- **Cost:** 200 gold
- **Requires:** Capacity Tier 3
- **Capacity:** 2,500 lb total (+1,000 lb)
- **Technology:** Converts steam pressure to hydraulic pressure
- **Historical:** Used in Victorian-era hydraulic power networks (London, 1880s)
- **Description:** "Hydraulic system provides stable long-term storage"

**Capacity Tier 5: Battery Bank** *(Late Game)*
- **Cost:** 500 gold
- **Requires:** Capacity Tier 4 + Power System unlocked
- **Capacity:** 5,000 lb total (+2,500 lb)
- **Technology:** Electrical energy storage charged by steam turbine
- **Feature:** Maximum capacity for endgame storage needs
- **Description:** "Modern electrical storage provides massive capacity"

---

#### B. Storage Efficiency Upgrades (5 Tiers)

**Base:** 50% efficiency (when Capacity Tier 1 is purchased)

**Efficiency Tier 1: Improved Insulation**
- **Cost:** 7 gold
- **Requires:** Capacity Tier 1 (storage system unlocked)
- **Efficiency:** 60% (10% improvement from base)
- **Technology:** Cork and asbestos insulation layers
- **Description:** "Better insulation reduces heat loss when storing steam"

**Efficiency Tier 2: Double-Wall Construction**
- **Cost:** 25 gold
- **Requires:** Efficiency Tier 1
- **Efficiency:** 70% (20% total improvement from base)
- **Technology:** Vacuum-sealed double walls
- **Description:** "Double-wall design with vacuum gap minimizes thermal transfer"

**Efficiency Tier 3: Steam Trap System**
- **Cost:** 90 gold
- **Requires:** Efficiency Tier 2
- **Efficiency:** 80% (30% total improvement from base)
- **Technology:** Automatic condensate removal
- **Description:** "Prevents condensation losses with automatic steam traps"

**Efficiency Tier 4: Superheater Integration**
- **Cost:** 225 gold
- **Requires:** Efficiency Tier 3
- **Efficiency:** 90% (40% total improvement from base)
- **Technology:** Re-heats stored steam before use
- **Description:** "Superheater restores temperature to stored steam, reducing waste"

**Efficiency Tier 5: Perfect Thermal Management**
- **Cost:** 550 gold
- **Requires:** Efficiency Tier 4
- **Efficiency:** 100% (50% total improvement, no loss)
- **Technology:** Advanced thermal regulation and active heating
- **Description:** "Zero-loss storage through active thermal management"

**Storage Mechanics (Only Active After Purchase):**

```gdscript
# Level1Vars variables - NO initial storage
var has_storage_system: bool = false  # Must purchase Capacity Tier 1 to unlock
var storage_capacity_tier: int = 0  # 0 = none, 1-5 = capacity upgrade tiers
var storage_efficiency_tier: int = 0  # 0 = base (50%), 1-5 = efficiency upgrade tiers
var stored_steam_lbs: float = 0.0  # Pounds of stored steam
var max_storage_lbs: float = 0.0  # Starts at 0, set by capacity tier (300/800/1500/2500/5000 lb)
var storage_efficiency: float = 0.5  # 50% base, set by efficiency tier (60%/70%/80%/90%/100%)
var storage_diversion_percentage: float = 0.0  # % of steam production diverted to storage (0-100)
var auto_release_enabled: bool = false  # Unlocked at Capacity Tier 3
var auto_release_threshold: float = 1.8  # Auto-release when multiplier >= 1.8x (during high/critical demand)

# Capacity tier -> max storage mapping
const STORAGE_CAPACITIES = {
    0: 0.0,      # No storage
    1: 300.0,    # Steam Accumulator Tank
    2: 800.0,    # Compressed Steam Reservoir
    3: 1500.0,   # Multi-Chamber Storage
    4: 2500.0,   # Hydraulic Accumulator
    5: 5000.0    # Battery Bank
}

# Efficiency tier -> storage efficiency mapping
const STORAGE_EFFICIENCIES = {
    0: 0.5,   # Base 50%
    1: 0.6,   # Improved Insulation
    2: 0.7,   # Double-Wall Construction
    3: 0.8,   # Steam Trap System
    4: 0.9,   # Superheater Integration
    5: 1.0    # Perfect Thermal Management
}

# Payment variables (no initial storage, direct conversion)
var steam_production_rate_lbh: float = 10.0  # Starting: 10 lb/h
var demand_multiplier: float = 1.0  # Payment multiplier based on demand state
var gold_progress: float = 0.0  # Fractional gold accumulated

# In _process()
func _process(delta):
    # Calculate steam produced this tick (in pounds)
    var steam_lbs_this_tick = steam_production_rate_lbh * (delta / 3600.0)

    # WITHOUT STORAGE (initial state): Direct conversion to gold
    if not has_storage_system:
        var gold_earned = steam_lbs_this_tick * demand_multiplier * PAYMENT_RATE_CONSTANT
        gold_progress += gold_earned

        # Award whole gold coins
        if gold_progress >= 1.0:
            var whole_gold = floor(gold_progress)
            Level1Vars.current_gold += whole_gold
            gold_progress -= whole_gold

    # WITH STORAGE (after purchase): Handle storage/overflow logic
    else:
        # Check if producing excess steam relative to demand
        var demand_lbs = current_demand_rate_lbh * (delta / 3600.0)

        if steam_lbs_this_tick >= demand_lbs:
            # Excess steam - can store it
            var excess_lbs = steam_lbs_this_tick - demand_lbs
            var storable_lbs = excess_lbs * storage_efficiency
            var actually_stored = min(storable_lbs, max_storage_lbs - stored_steam_lbs)
            stored_steam_lbs += actually_stored

            # Payment from what was demanded
            var gold_earned = demand_lbs * demand_multiplier * PAYMENT_RATE_CONSTANT
            gold_progress += gold_earned
        else:
            # Deficit - use storage if available
            var deficit_lbs = demand_lbs - steam_lbs_this_tick
            var from_storage = min(deficit_lbs, stored_steam_lbs)
            stored_steam_lbs -= from_storage

            # Payment from production + storage
            var total_delivered = steam_lbs_this_tick + from_storage
            var gold_earned = total_delivered * demand_multiplier * PAYMENT_RATE_CONSTANT
            gold_progress += gold_earned

        # Award whole gold coins
        if gold_progress >= 1.0:
            var whole_gold = floor(gold_progress)
            Level1Vars.current_gold += whole_gold
            gold_progress -= whole_gold

    # Auto-release during high demand (if enabled and storage exists)
    # Uses multiplier-based trigger for precise control (not state-based)
    if has_storage_system and auto_release_enabled and demand_multiplier >= auto_release_threshold:
        if stored_steam_lbs > 0:
            release_stored_steam_manual(1.0)  # Release 100%

func release_stored_steam_manual(percentage: float):
    # Manual release of stored steam (increases production temporarily)
    var release_amount_lbs = max_storage_lbs * percentage
    var available_to_release = min(release_amount_lbs, stored_steam_lbs)

    # Boost production rate temporarily
    steam_production_rate_lbh += (available_to_release / delta) * 3600.0  # Convert back to per-hour
    stored_steam_lbs -= available_to_release

    show_notification("Released %d lb steam from storage" % int(available_to_release))
```

**UI Elements:**

**Storage Gauge (Left Panel):**
```
Storage: 450 / 1200
[■■■■■■□□□□]
```

**Storage Control Buttons (Tier 3+):**
- "Release 10%" - Releases 10% of max storage capacity per click (consistent amount regardless of current storage)
- "Auto-Release: ON/OFF" - Toggle automatic release during high demand
- Threshold slider (when auto-release enabled)

**Strategic Gameplay:**

**Active Diversion Strategy (New!):**
1. Player notices "Very Low Demand" state (0.2x multiplier) - trains coasting downhill
2. Current payment: 0.5 coins/sec (low revenue during low demand)
3. Player opens Storage Controls, sets diversion slider to 40%
4. Steam production: 25/sec → Main gets 15/sec, Storage gets 10/sec (before efficiency loss)
5. Storage builds: 200 → 400 → 600 steam over 3 minutes
6. Demand shifts to "High" (1.5x) - trains climbing steep grade
7. Payment jumps to higher value rate
8. Player sets diversion back to 0%, clicks "Release 10%" three times
9. Storage floods main reservoir with 360 steam (3 × 120)
10. Player exceeds high demand, earns maximum revenue for 2 minutes
11. Strategic profit: Stored cheap steam, sold it at premium rates!

**Overflow Capture (Passive Strategy):**
1. Zero demand state triggers (train stopped)
2. Workers continue producing steam
3. Main reservoir fills to 500/500
4. Overflow automatically diverts to storage (with 80% efficiency)
5. Storage fills to 800/1200
6. Player sees: "Excess steam stored for later use"
7. Critical demand spike occurs!
8. Player manually releases storage or auto-release triggers
9. Stored steam floods into main reservoir
10. Player maintains "Excellent" performance during spike
11. Earns bonus revenue for exceeding critical demand

### 5. Train Speed & Payment

**Purpose:** Convert steam production into Gold currency

**Payment Calculation (Direct Steam-to-Gold Conversion):**
```gdscript
# Payment Rate Constant
const PAYMENT_RATE_CONSTANT = 0.01  # Tune for desired earning speed
# Example: 10 lb/h × 1.0 multiplier × 0.01 = 0.1 gold/hour = 6 gold/hour

# Demand Multiplier Ranges (affects payment rate)
# Each state has a min/max range. Actual multiplier interpolates smoothly via sine wave.
# See DEMAND_RANGES constant in Demand Fluctuation Logic section for full definitions.
var demand_ranges = {
    "very_low": {"min": 0.0, "max": 0.45},   # Avg ~0.225x
    "low": {"min": 0.45, "max": 0.75},       # Avg ~0.6x
    "medium": {"min": 0.75, "max": 1.35},    # Avg ~1.05x
    "high": {"min": 1.35, "max": 2.65},      # Avg ~2.0x
    "critical": {"min": 2.65, "max": 3.75}   # Avg ~3.2x
}

# Current demand multiplier (interpolated value within current state's range)
var demand_multiplier: float = 1.05  # Starts at medium midpoint

# Gold accumulation (fractional)
var gold_progress: float = 0.0

# In _process(delta)
var steam_lbs_this_tick = steam_production_rate_lbh * (delta / 3600.0)
var gold_earned = steam_lbs_this_tick * demand_multiplier * PAYMENT_RATE_CONSTANT
gold_progress += gold_earned

# Award whole gold coins
if gold_progress >= 1.0:
    var whole_gold = floor(gold_progress)
    Level1Vars.current_gold += whole_gold
    gold_progress -= whole_gold

# Calculate earning rate for display (gold per minute)
var gold_per_minute = (steam_production_rate_lbh * demand_multiplier * PAYMENT_RATE_CONSTANT) / 60.0
var minutes_per_gold = 1.0 / gold_per_minute if gold_per_minute > 0 else 0
```

**Payment Display (Option 2):**
- Progress bar showing fractional gold accumulated (0.0 - 1.0)
- Visual progress: `[=====>--------------] 0.25 Gold`
- See detailed mockups in approved plan

**Payment Timing:**
- Continuous accrual while in owned_furnace scene
- Pays in **Gold** coins
- Display updates in real-time

---

## Purchase System

### Furnace Ownership Purchase

**Location:** Overseer's Office scene ([level1/overseers_office.tscn](level1/overseers_office.tscn))

**Button Properties:**
- Text: "Buy Furnace Ownership"
- Position: Right panel, below Overtime button
- Visibility: Requires `lifetimecoins >= 10000` (1 Gold lifetime)
- Cost: 1 Gold

**Purchase Flow:**
```gdscript
func _on_buy_furnace_button_pressed():
    var cost = 10000  # 1 Gold
    if Level1Vars.coins >= cost:
        # Confirmation popup
        show_confirmation_popup(
            "Purchase Furnace Ownership?",
            "You'll become a furnace owner. Cost: 1 Gold"
        )

func confirm_purchase():
    var cost = 10000  # 1 Gold
    Level1Vars.coins -= cost
    Level1Vars.furnace_owned = true

    # Track for prestige system
    UpgradeTypesConfig.track_equipment_purchase("furnace_ownership", cost)

    # Log purchase
    DebugLogger.log_shop_purchase("Furnace Ownership", cost, 1)

    # Show success notification
    show_notification("You are now the owner of your own furnace")

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

### New Owned Furnace (own_furnace.tscn)

**Purpose:** Manager/owner perspective with new mechanics

**Scene Structure:**
Inherit from scene_template.tscn and set background to own-furnace.jpg

**Left Panel:**
- Title: "Your Furnace - Manager's Station"
- **Heat Gauge** (ProgressBar)
  - Shows current_heat / max_heat
  - Color: Red/orange gradient
  - Label: "Heat: 45 / 100"
- **Steam Production Display** (Label)
  - Shows steam_production_rate_lbh
  - Format: "Production: 10 lb/h"
  - Color: White text
- **Demand Indicator** (Panel with RichTextLabel)
  - Shows current demand state and rate
  - Format: "Demand: gold per lb/h (MEDIUM)"
  - Color-coded: Dark Blue (ZERO) / Green (LOW) / Yellow (MEDIUM) / Orange (HIGH) / Red (CRITICAL)
  - Shows demand reason text below
- **Payment Progress Display** (Option 2 Format)
  - **Progress Bar:** Shows gold_progress (0.0 - 1.0)
    - Color: Gold/yellow gradient
    - Visual: [=====>--------------]
  - Updates in real-time
- **Steam Storage Gauge** (ProgressBar) *(visible only when storage purchased)*
  - Shows stored_steam_lbs / max_storage_lbs
  - Color: Cyan/blue gradient (distinct from production)
  - Label: "Storage: 180 / 500 lb"
  - Shows efficiency: "Efficiency: 80%" (subtle, small text)
  - **Hidden by default** - only shows when has_storage_system = true
- **Resource Display**
  - Gold coins (current_gold)
  - Coal (still used for shoveling)

**Right Panel Buttons:**
- **Shovel Coal** - Manager helps with shoveling (replaces old coal generation)
  - Costs stamina
  - Gives charisma XP and strength
  - Generates small amount of heat
  - Temporarily boosts worker morale/efficiency
- **To Dormitory** - Transitions to owned_dorm.tscn for worker management ⭐ NEW
- **Upgrade Furnace** - Opens furnace upgrade popup
- **Storage Controls** *(visible only when Tier 3+ storage purchased)*
  - Opens storage control popup with release buttons and auto-release settings
- **Take Break** - Returns to bar

**Center Area:**
- Could display animated elements (heat glow, steam pipes) in future

**Color Indicator** (subtle discovery mechanic):
- Small dot next to "Visit Dormitory" button
- **Green:** All workers healthy (< 55 fatigue, morale > 60, food > 25%)
- **Yellow:** Some concerns (workers 55-80 fatigue OR morale 40-60 OR food 10-25%)
- **Red:** Critical issues (any worker > 80 fatigue OR morale < 40 OR food < 10%)

### New Owned Dormitory (owned_dorm.tscn) ⭐

**Purpose:** Worker management hub - hire, manage, upgrade dormitory

**Scene Structure:**
Duplicate existing [level1/dorm.tscn](level1/dorm.tscn) → owned_dorm.tscn

**Visual Changes:**
- Shows actual beds in scene (empty vs occupied)
- Bed count increases as upgrades purchased (visual progression)
- Workers visible when idle/on break

**Panel 1 (Left in Landscape / Top in Portrait): Worker Roster**
- Title: "Worker Roster"
- **Scrollable list** of hired workers (up to 20)
- Each worker entry shows:
  - **Name** (e.g., "Thomas")
  - **Type** (Stoker/Fireman/Engineer)
  - **Quality descriptor** (e.g., "Steady Hand", "Skilled Worker")
  - **Current status**: Active / Idle / On Break
  - If on break: countdown timer ("Break: 3:45 remaining")
  - **Action buttons per worker:**
    - [Assign Active] - Send to work
    - [Set Idle] - Rest in dorm
    - [Send on Break] - 5min recovery break
    - [Fire] - Remove worker (confirmation required)

**Panel 2 (Right in Landscape / Bottom in Portrait): Status & Controls**

*Status Info Section (Top):*
- **Food Supply:** "Food: 47 units (Decent Meal quality)"
  - Warning color if low (< 15 units: orange, < 5 units: red)
- **Dormitory Capacity:** "Beds: 8 / 10 occupied"
- **Reputation Hint** (narrative only, no number):
  - High reputation (70+): "Workers speak well of this place"
  - Medium reputation (30-70): "Your reputation is mixed"
  - Low reputation (< 30): "Conditions here are poorly regarded"
- **Worker Status Indicator:** Color dot (discovery mechanic)
  - Green/Yellow/Red based on crew health
  - No explicit explanation - players discover meaning

*Action Buttons Section (Middle):*
- **[Hire Workers]** - Opens hiring pool dialog (shows 3-8 candidates)
- **[Send All on Break]** - Group break, enhanced recovery ⭐
  - Shows "Cooldown: 12:34" if recently used (15min cooldown)
- **[Buy Food]** - Opens food shop (5 quality tiers)
- **[Dormitory Upgrades]** - Opens upgrade menu
  - **Beds Tab:** Purchase bed expansions (7 tiers, 2 → 20 capacity)
  - **Amenities Tab:** Purchase quality-of-life upgrades (10 tiers)
- **[Return to Furnace]** - Goes back to owned_furnace.tscn

*Settings Section (Bottom):*
- **Auto-Break Policy:** Dropdown selector
  - Options: Never / Conservative / Balanced / Aggressive / Preventive
  - Applies to all workers (individual breaks only)

**Dialogs Opened from owned_dorm.tscn:**

**1. Hiring Pool Dialog**
- Shows 3-8 available candidates (based on reputation)
- Each candidate: Name, Type, Quality descriptor, Hire cost
- [Refresh Pool - 50 coins] button
- Cannot hire if no empty beds

**2. Food Shop Dialog**
- Shows current supply and quality
- Purchase options: 5 quality tiers (Stale Bread → Premium Provisions)
- Each tier: Cost per 10 units, purchase buttons (10/50/100 units)
- Auto-purchase settings: Enable toggle, tier selector, amount selector

**3. Dormitory Upgrades Dialog**
- **Beds Tab:** 7 tiers of bed expansions
  - Visual: Checkmarks for owned, locks for locked
  - Shows requirements (runtime hours, components/mechanisms)
- **Amenities Tab:** 10 tiers of quality-of-life upgrades
  - Each shows: Description, vague benefit (no numbers), cost, requirements
  - Players discover actual effects through experimentation

**Center Area:**
- Background: dormitory interior (reuse dorm.jpg or create owned_dorm.jpg)
- Visual representation of beds (scalable, shows occupancy)
- Could show workers as sprites when idle/on break (future enhancement)

### Bar Scene Navigation Updates

**File:** [level1/bar.gd](level1/bar.gd)

**Modified Functions:**

**1. Furnace Button:**
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

**2. Dormitory Button:** ⭐ NEW
```gdscript
func _on_to_dorm_button_pressed():
    var target_scene
    if Level1Vars.furnace_owned:
        target_scene = "res://level1/owned_dorm.tscn"
    else:
        target_scene = "res://level1/dorm.tscn"
    Global.change_scene_with_check(get_tree(), target_scene)
```

**Button Text Update:**
- Before: "To Dormitory"
- After: "To Worker Quarters" or "To Your Dormitory" (when owned)

**Routing Logic:**
- Before furnace purchase: All scenes route to original worker-perspective scenes
- After furnace purchase: Bar routes to owned_furnace.tscn and owned_dorm.tscn
- Maintains narrative consistency (player is now the owner/manager)

---

## Worker Management System ⭐

Phase 5 introduces a comprehensive **individual worker management system** where each worker is a named person with fatigue, morale, and quality levels. This replaces the simple "hire X workers" model with a deeper, discovery-based system focused on workforce management.

### Core Philosophy

**Discovery-Based Complexity:**
- Worker fatigue and morale are **never shown as numbers** - players discover through narrative notifications
- Workers provide contextual feedback ("Thomas is exhausted", "The crew is in high spirits")
- Quality differences discovered through observation (skilled workers tire slower, produce more)
- Reputation system affects hiring pool quality (hidden mechanic)

**Individual Agency:**
- Each worker has a procedurally generated steampunk fantasy name
- Players develop attachment to specific workers
- Firing workers has real social / morale consequences or benefits
- Active/idle/break management per worker

**Strategic Depth:**
- Multiple valid playstyles: sweatshop vs premium operation
- Trade-offs: cheap workers vs skilled workers, food quality, amenities
- Long-term investment: treat workers well → better reputation → attract better candidates

---

### Worker Types

Three worker types serve different functions in furnace operation:

**1. Stoker (Coal Shoveler)**
- **Role:** Generates heat automatically through coal shoveling
- **Base Rate:** 1.2 fatigue/sec (hard physical labor)
- **Heat Generation:** Varies by quality tier (0.6 to 1.5/sec at baseline)
- **Hire Cost:** 2-120 Silver (or up to 1.2 Gold) depending on quality tier

**2. Fireman (Heat Manager)**
- **Role:** Manages furnace heat, reduces decay rate
- **Base Rate:** 0.8 fatigue/sec (moderate work)
- **Decay Reduction:** 0.1/sec per fireman (varies by quality)
- **Hire Cost:** 5-260 Silver (or up to 2.6 Gold) depending on quality tier

**3. Engineer (Steam Optimizer)**
- **Role:** Optimizes steam generation efficiency
- **Base Rate:** 0.6 fatigue/sec (technical work, less physical)
- **Efficiency Bonus:** +10% per engineer (varies by quality)
- **Hire Cost:** 10-480 Silver (or up to 4.8 Gold) depending on quality tier

---

### Individual Worker System

#### Worker Data Structure

Each worker in the roster has:
- **Name**: Procedurally generated 
- **Type**: Stoker, Fireman, or Engineer
- **Quality Tier**: 1-7 (Sickly Youth → Skilled Worker)
- **Current Fatigue**: 0.0 (fresh) to 100.0 (exhausted) - **hidden from player**
- **Status**: Active (working), Idle (resting), or On Break

#### Worker Quality Tiers (7 Tiers)

Quality affects productivity, fatigue resistance, and base morale. **Quality is shown only as narrative descriptions** - no stats revealed to player.

**Tier 1 - Sickly Youth**
- **Description:** "Young and frail, barely fit for work"
- **Productivity:** 60% of baseline
- **Fatigue Accumulation:** +60% (tires 1.6x faster)
- **Base Morale Contribution:** 25
- **Hire Cost:** 2 Silver (stoker), 5 Silver (fireman), 10 Silver (engineer)
- **Availability:** Always available in hiring pool

**Tier 2 - Green Recruit**
- **Description:** "Inexperienced but willing to learn"
- **Productivity:** 75%
- **Fatigue Accumulation:** +30%
- **Base Morale Contribution:** 35
- **Hire Cost:** 4 Silver (stoker), 10 Silver (fireman), 20 Silver (engineer)
- **Availability:** Always available

**Tier 3 - Ordinary Laborer**
- **Description:** "Average worker, nothing special"
- **Productivity:** 90%
- **Fatigue Accumulation:** +10%
- **Base Morale Contribution:** 45
- **Hire Cost:** 8 Silver (stoker), 18 Silver (fireman), 35 Silver (engineer)
- **Availability:** Always available

**Tier 4 - Steady Hand**
- **Description:** "Reliable and experienced"
- **Productivity:** 100% (baseline reference)
- **Fatigue Accumulation:** 0% (baseline)
- **Base Morale Contribution:** 55
- **Hire Cost:** 15 Silver (stoker), 35 Silver (fireman), 65 Silver (engineer)
- **Availability:** After 15h runtime as owner

**Tier 5 - Capable Hand**
- **Description:** "Knows the work well"
- **Productivity:** 115%
- **Fatigue Accumulation:** -15% (tires 0.85x as fast)
- **Base Morale Contribution:** 65
- **Hire Cost:** 30 Silver (stoker), 65 Silver (fireman), 120 Silver (or 1.2 Gold) (engineer)
- **Availability:** After 35h runtime as owner

**Tier 6 - Practiced Worker**
- **Description:** "Years of experience show"
- **Productivity:** 130%
- **Fatigue Accumulation:** -30%
- **Base Morale Contribution:** 75
- **Hire Cost:** 60 Silver (stoker), 130 Silver (or 1.3 Gold) (fireman), 240 Silver (or 2.4 Gold) (engineer)
- **Availability:** After 55h runtime as owner

**Tier 7 - Skilled Worker**
- **Description:** "As good as they come"
- **Productivity:** 150%
- **Fatigue Accumulation:** -45%
- **Base Morale Contribution:** 85
- **Special:** 20% chance to self-rest when fatigue hits 65 (discovered mechanic)
- **Hire Cost:** 120 Silver (or 1.2 Gold) (stoker), 260 Silver (or 2.6 Gold) (fireman), 480 Silver (or 4.8 Gold) (engineer)
- **Availability:** After 75h runtime as owner

**Strategic Notes:**
- Early game: Forced to hire Tier 1-3 (cheap but inefficient)
- Mid game: Tier 4-5 become accessible (reliable workers)
- Late game: Tier 6-7 available if reputation is high enough

---

### Dormitory Capacity System ⭐

**Worker capacity is determined by dormitory beds**, not arbitrary limits. This creates a tangible, visual progression.

#### Starting Capacity
- **2 beds** included with furnace purchase
- Can hire up to 2 workers initially

#### Bed Expansion Upgrades

All bed upgrades purchased in **owned_dorm.tscn** (new scene).

**Tier 1: Bunk Bed Pair**
- **Cost:** 40 Silver
- **Capacity:** +2 workers (total: 4)
- **Description:** "Simple wooden bunks"
- **Unlocks:** Immediately available

**Tier 2: Second Bunk Set**
- **Cost:** 60 Silver
- **Requires:** 12h runtime
- **Capacity:** +2 workers (total: 6)
- **Description:** "Additional sleeping space"

**Tier 3: Third Bunk Set**
- **Cost:** 90 Silver
- **Requires:** 25h runtime
- **Capacity:** +2 workers (total: 8)
- **Description:** "Cramped but functional"

**Tier 4: Fourth Bunk Set**
- **Cost:** 140 Silver (or 1.4 Gold) + 20 components
- **Requires:** 40h runtime
- **Capacity:** +2 workers (total: 10)
- **Description:** "The dormitory is quite crowded now"

**Tier 5: Reinforced Bunks (Triple-Tier)**
- **Cost:** 250 Silver (or 2.5 Gold) + 50 components
- **Requires:** 55h runtime
- **Capacity:** +3 workers (total: 13)
- **Description:** "Sturdier construction allows triple-stacking"
- **Note:** Replaces one bunk pair with stronger 3-tier design

**Tier 6: Second Reinforced Set**
- **Cost:** 3 Gold + 70 components + 25 mechanisms
- **Requires:** 70h runtime
- **Capacity:** +3 workers (total: 16)
- **Description:** "Maximum occupancy approaching"

**Tier 7: Final Expansion**
- **Cost:** 4.5 Gold + 110 components + 50 mechanisms
- **Requires:** 85h runtime
- **Capacity:** +4 workers (total: 20 maximum)
- **Description:** "Every inch of space utilized"

**Visual Feedback:**
- Dorm scene shows actual beds (empty vs occupied)
- Overcrowding warning if trying to hire beyond beds
- Cannot hire if no empty beds available

---

### Dynamic Hiring Pool System ⭐

The **hiring pool** shows available worker candidates. Pool size and quality improve based on **reputation** (hidden score).

#### Reputation System (Hidden Score: 0-100)

Reputation is **never shown as a number** - players discover through:
- Hiring pool size changes
- Quality of available candidates
- Narrative notifications ("Word has spread about your operation")

**Reputation Increases From:**
- **High crew morale (70+):** +0.3 reputation/hour
- **Good amenities:** +1 to +15 reputation per amenity tier
- **Low average fatigue (< 45):** +0.2 reputation/hour
- **Quality food provided:** +0.1 to +0.3 reputation/hour
- **Charisma:** +1 reputation per charisma level (max +30)
- **No recent firings:** +0.1 reputation/hour (if none fired in 24h)
- **Skilled workers on roster:** +0.5 reputation per Tier 6+ worker

**Reputation Decreases From:**
- **Low crew morale (< 40):** -0.5 reputation/hour
- **High average fatigue (> 70):** -0.4 reputation/hour
- **Worker collapses (95+ fatigue):** -3 reputation per incident
- **Recent firings:** -8 reputation per firing (decays over 24h)
- **Poor/no food:** -0.3 reputation/hour
- **Ruthless management:** -0.2 reputation/hour

#### Hiring Pool Mechanics

**Pool Size by Reputation:**
- 0-15 reputation: 3 candidates
- 15-30 reputation: 4 candidates
- 30-50 reputation: 5 candidates
- 50-70 reputation: 6 candidates
- 70-85 reputation: 7 candidates
- 85-100 reputation: 8 candidates

**Quality Distribution by Reputation:**

*Low Reputation (0-25):*
- Tier 1 (Sickly Youth): 40%
- Tier 2 (Green Recruit): 35%
- Tier 3 (Ordinary Laborer): 20%
- Tier 4 (Steady Hand): 5%
- Tier 5+: 0%

*Medium Reputation (25-50):*
- Tier 1: 15%
- Tier 2: 30%
- Tier 3: 30%
- Tier 4: 20%
- Tier 5 (Capable Hand): 5%
- Tier 6+: 0%

*Good Reputation (50-75):*
- Tier 1: 5%
- Tier 2: 15%
- Tier 3: 25%
- Tier 4: 30%
- Tier 5: 20%
- Tier 6 (Practiced Worker): 5%
- Tier 7: 0%

*Excellent Reputation (75-100):*
- Tier 1: 0%
- Tier 2: 5%
- Tier 3: 15%
- Tier 4: 25%
- Tier 5: 25%
- Tier 6: 20%
- Tier 7 (Skilled Worker): 10%

**Pool Refresh:**
- **Manual refresh:** 200 silver, generates new pool immediately
- **Auto-refresh:** Pool regenerates every 2 hours of runtime
- **Notifications:** "A skilled worker has applied for a position!" when Tier 6-7 appears

---

### Hidden Worker Fatigue System ⭐

**Fatigue is completely hidden from the player** - no gauges, no numbers. Players learn through worker notifications and productivity changes.

#### Fatigue Tracking

Each worker tracks fatigue individually: **0.0 (fresh) → 100.0 (exhausted)**

**Base Fatigue Rates by Type:**
- Stoker: 1.2/sec (heavy physical labor)
- Fireman: 0.8/sec (moderate work)
- Engineer: 0.6/sec (technical work)

#### Fatigue Accumulation Formula

```gdscript
fatigue_rate = base_rate * demand_multiplier * management_style_multiplier *
               (1.0 + tier_resistance) * (1.0 - charisma_bonus) *
               (1.0 - facility_bonus) * food_modifier
```

**Fatigue Drivers:**

**Demand State Multiplier:**
- Very Low: 0.7x
- Low: 0.85x
- Normal: 1.0x
- High: 1.4x (climbing grade, stressful)
- Critical: 2.3x (emergency, extremely stressful)

**Management Style Multiplier** (from overseer slider):
- Comfortable (0-20%): 0.5x fatigue accumulation
- Orderly (20-40%): 0.85x fatigue accumulation
- Firm (40-70%): 1.15x fatigue accumulation
- Harsh (70-90%): 1.7x fatigue accumulation
- Ruthless (90-100%): 2.1x fatigue accumulation

**Quality Tier Resistance:**
- Built into tier stats: -45% (Tier 7) to +60% (Tier 1)

**Charisma Bonus:**
- -2% fatigue per charisma level (max -40% at charisma 20)
- High charisma = workers tire much slower

**Food Modifier:**
- Well-fed (Tier 4-5 food): 0.85x to 0.75x
- Basic food (Tier 2-3): 1.0x to 1.08x
- Stale bread (Tier 1): 1.15x
- No food: 1.25x

**Facility Bonus:**
- Varies by amenity purchases: -5% to -30%

#### Performance Impact by Fatigue Level

Fatigue directly affects each worker's productivity:

- **0-10 (Peak):** 120% productivity (rare, freshly rested)
- **10-25 (Energetic):** 115% productivity
- **25-55 (Fresh):** 100% productivity (ideal working range)
- **55-70 (Tiring):** 85% productivity
- **70-80 (Tired):** 65% productivity
- **80-90 (Exhausted):** 40% productivity
- **90-95 (Critical):** 25% productivity, rapid morale damage
- **95-100 (Collapsed):** 15% productivity, severe morale damage, -3 reputation

**Overall furnace productivity** = average of all active workers' productivity multipliers.

#### Fatigue Recovery System

Workers recover fatigue based on their status:

```gdscript
# Base recovery rate
active_recovery = 0.25 + (morale * 0.015) + charisma_bonus + facility_bonus + food_bonus

# Recovery multipliers by status
idle_recovery = active_recovery * 3
individual_break_recovery = active_recovery * 5
group_break_recovery = active_recovery * 8  # Social bonus!

# Additional bonuses
if demand_state in ["zero", "very_low"]:
    active_recovery += 0.4  # Workers can pace themselves

if crew_morale >= 70:
    all_recovery += 0.3/sec  # High morale accelerates recovery
```

**Charisma Bonus:** +0.02/sec per 5 charisma levels

**Facility Bonuses:**
- Varies by amenity tier: +0.2 to +3.0/sec

**Food Bonuses:**
- Tier 4-5 food: +0.2 to +0.4/sec recovery

---

### Worker Morale System ⭐

**Morale is a shared pool** affecting all workers: **0.0 (mutinous) → 100.0 (devoted)**

Starts at 50.0 (neutral).

#### Morale Influences

**Positive Factors:**
- **Charisma:** +0.4 morale per level (max +12 at charisma 30)
- **Quality workers:** +5 morale per Tier 6+ worker employed
- **Amenities:** +3 to +28 morale depending on tiers purchased
- **Regular breaks:** +2.5 morale per individual break
- **Group breaks:** +5 morale (social benefit!)
- **Low average fatigue (< 40):** +0.6 morale/min
- **Well-fed:** +0.4 morale/min
- **Good reputation (70+):** +0.2 morale/min

**Negative Factors:**
- **High individual fatigue (75+):** -0.4 morale/min per worker
- **Collapsed worker (95+):** -2.0 morale/min
- **Ruthless management:** -0.5 morale/min
- **Critical demand sustained:** -0.3 morale/min
- **Fired workers recently:** -5 morale instantly
- **No breaks for 40+ min at 65+ fatigue:** -2.5 morale/min
- **Poor/no food:** -0.5 morale/min
- **Overcrowding (workers > beds):** -1.0 morale/min

#### Morale Effects

**Recovery Speed Multiplier:**
- 0-25 morale: 0.5x recovery (demoralized, slow healing)
- 25-50 morale: 0.8x recovery
- 50-75 morale: 1.0x recovery (neutral)
- 75-90 morale: 1.3x recovery (motivated)
- 90-100 morale: 1.6x recovery (inspired, rapid healing)

**Productivity Modifier:**
- 0-25 morale: 0.7x productivity (demoralized)
- 25-50 morale: 0.85x productivity
- 50-75 morale: 1.0x productivity (neutral)
- 75-90 morale: 1.12x productivity (motivated)
- 90-100 morale: 1.25x productivity (inspired)

**Notification Tone:**
- High morale: Polite, apologetic ("Sorry boss, I need a moment")
- Low morale: Hostile, accusatory ("Thomas: 'You're killing us!'")

**Fatigue Resistance:**
- High morale (75+): -10% fatigue accumulation (workers more resilient)

---

### Worker Food Supply System ⭐

Workers consume food while active. Food quality affects fatigue, morale, and reputation.

#### Food Mechanics

- **Consumption Rate:** 1 food unit per worker per 10 minutes (active only)
- **Storage:** Player purchases food in advance, stored in inventory
- **Idle/Break Workers:** Do not consume food
- **Running Out:** "Hungry" penalties apply if food supply reaches 0

#### Food Quality Tiers

**Tier 1 - Stale Bread**
- **Cost:** 0.2 Silver per 10 units (2 copper each)
- **Effects:** +15% fatigue accumulation, -0.3 morale/min, -0.2 reputation/hour
- **Description:** "Barely edible scraps"
- **Strategic Use:** Desperate times only

**Tier 2 - Basic Rations**
- **Cost:** 0.5 Silver per 10 units (5 copper each)
- **Effects:** Neutral (1.0x fatigue, no morale/reputation change)
- **Description:** "Plain but filling"
- **Strategic Use:** Early game, cost-conscious

**Tier 3 - Decent Meal**
- **Cost:** 1.2 Silver per 10 units (12 copper each)
- **Effects:** -8% fatigue accumulation, +0.2 morale/min, +0.1 reputation/hour
- **Description:** "Simple but satisfying"
- **Strategic Use:** Balanced mid-game choice

**Tier 4 - Quality Food**
- **Cost:** 2.5 Silver per 10 units (25 copper each)
- **Requires:** 20h runtime
- **Effects:** -15% fatigue, +0.4 morale/min, +0.2/sec recovery, +0.2 reputation/hour
- **Description:** "Good, hearty portions"
- **Strategic Use:** Late game, well-funded operations

**Tier 5 - Premium Provisions**
- **Cost:** 5 Silver per 10 units (50 copper each)
- **Requires:** 50h runtime
- **Effects:** -25% fatigue, +0.6 morale/min, +0.4/sec recovery, +0.3 reputation/hour
- **Description:** "Surprisingly good for furnace work"
- **Strategic Use:** Premium operations, maximizing efficiency

#### Hunger Penalties

If food supply reaches 0:
- **+25% fatigue accumulation** (workers tire much faster)
- **-1.0 morale/min** (rapid morale decay)
- **-0.5 reputation/hour** (word spreads about poor conditions)
- **Complaint notifications every 5 minutes**

#### Food Management UI

Located in owned_dorm.tscn or owned_furnace.tscn:
- **Current Supply Display:** "Food: 47 units (Decent Meal quality)"
- **Purchase Button:** Opens food shop with 5 tiers
- **Auto-Purchase Toggle:** Automatically buys selected tier when supply < 20 units
- **Low Supply Warning:** Notification at < 15 units remaining

---

### Break Management System ⭐

Players can send workers on breaks to recover fatigue. Two types: individual and group.

#### Individual Breaks

**Per-Worker Control:**
- **Button:** "Send [Name] on Break" (no cooldown)
- **Duration:** 5 minutes
- **Recovery Rate:** 5x active recovery rate
- **Status:** Worker becomes idle, stops producing
- **Morale Bonus:** +2.5 morale per individual break

**Use Case:** Targeted recovery for specific exhausted workers

#### Group Breaks (Enhanced) ⭐

**Social Benefit:**
- **Button:** "Send All Workers on Break"
- **Duration:** 5 minutes
- **Recovery Rate:** **8x active recovery rate** (better than individual!)
- **Cooldown:** 15 minutes
- **Morale Bonus:** +5 morale (doubled due to socialization)
- **Special:** All active workers break simultaneously

**Social Notifications:**
Group breaks trigger special notifications emphasizing camaraderie:
- "The crew gathers to chat and rest together"
- "You hear laughter from the dormitory"
- "Someone says: 'Thanks boss, we needed this'"
- "The workers seem in better spirits after spending time together"
- "[Thomas] and [Jakob] are swapping stories"
- "The crew looks refreshed and ready to get back to it"

**Strategic Value:** Group breaks are more efficient than individual breaks, but require coordinating downtime.

#### Auto-Break Policy

**5 Settings** (applies to all workers, individual breaks only):

1. **Never:** Manual control only
2. **Conservative:** Auto-break at 75 fatigue (minimizes downtime)
3. **Balanced:** Auto-break at 60 fatigue (recommended)
4. **Aggressive:** Auto-break at 45 fatigue (prevents buildup)
5. **Preventive:** Auto-break at 30 fatigue (maximum welfare, frequent breaks)

**Behavior:**
- Auto-breaks are individual only (one worker at a time)
- Staggered (30 seconds apart) to maintain some production
- Group breaks must be manual (strategic player choice)

---

### Dormitory Amenities System ⭐

**Amenities are purchased in owned_dorm.tscn**. They're presented as **vague quality-of-life improvements** - effects are hidden, players discover through experimentation.

All amenities are **small-scale** (appropriate for cramped furnace dorm):

**Tier 1: Water Barrels**
- **Cost:** 30 Silver
- **Description:** "Cool water for the crew"
- **Vague Benefit:** "Basic necessity"
- **Hidden Effects:** -5% fatigue accumulation, +0.2/sec recovery, +1 reputation

**Tier 2: Simple Cots**
- **Cost:** 50 Silver, 8h runtime
- **Description:** "Mattresses for the bunks"
- **Vague Benefit:** "Better than the floor"
- **Hidden Effects:** +0.5/sec recovery when idle, +5 morale, +2 reputation

**Tier 3: Tool Storage Rack**
- **Cost:** 80 Silver, 15h runtime
- **Description:** "Organized equipment area"
- **Vague Benefit:** "Keeps things tidy"
- **Hidden Effects:** -8% fatigue accumulation, +3 reputation

**Tier 4: Ventilation Grate**
- **Cost:** 150 Silver (or 1.5 Gold) + 20 components, 25h runtime
- **Description:** "Better airflow"
- **Vague Benefit:** "Makes breathing easier"
- **Hidden Effects:** -12% fatigue accumulation, +0.3/sec recovery, +8 morale, +4 reputation

**Tier 5: Cushioned Benches**
- **Cost:** 220 Silver (or 2.2 Gold) + 35 components, 35h runtime
- **Description:** "Comfortable seating for breaks"
- **Vague Benefit:** "Somewhere to rest"
- **Hidden Effects:** +1.2/sec recovery during breaks, +10 morale, +5 reputation

**Tier 6: Personal Lockers**
- **Cost:** 3.5 Gold + 60 components + 20 mechanisms, 45h runtime
- **Description:** "Storage for belongings"
- **Vague Benefit:** "A touch of dignity"
- **Hidden Effects:** +12 morale, -10% fatigue accumulation, +6 reputation

**Tier 7: Better Bedding**
- **Cost:** 5 Gold + 90 components + 35 mechanisms, 55h runtime
- **Description:** "Proper mattresses and blankets"
- **Vague Benefit:** "Quality rest is important"
- **Hidden Effects:** +1.8/sec recovery when idle, +15 morale, +7 reputation

**Tier 8: Oil Lamps**
- **Cost:** 7.5 Gold + 130 components + 55 mechanisms, 65h runtime
- **Description:** "Better lighting"
- **Vague Benefit:** "Easier on the eyes"
- **Hidden Effects:** +18 morale, -15% fatigue accumulation, +0.8/sec recovery, +8 reputation

**Tier 9: Insulated Walls**
- **Cost:** 11 Gold + 180 components + 80 mechanisms + 30 pipes, 75h runtime
- **Description:** "Temperature control"
- **Vague Benefit:** "More comfortable year-round"
- **Hidden Effects:** -22% fatigue accumulation, +2.2/sec recovery, +20 morale, +10 reputation

**Tier 10: Premium Furnishings**
- **Cost:** 18 Gold + 280 components + 140 mechanisms + 70 pipes, 90h runtime
- **Description:** "Surprisingly nice accommodations"
- **Vague Benefit:** "Workers comment on the improvements"
- **Hidden Effects:** -30% fatigue accumulation, +3.0/sec recovery, +28 morale, +15 reputation, **workers start each session at 0 fatigue**

**Strategic Discovery:**
- Players experiment to find which amenities provide best value
- High-tier amenities dramatically improve operation sustainability
- Reputation benefits create positive feedback loop

---

### Notification System ⭐

Workers communicate their state through **contextual, named notifications**. Never mention "fatigue" or "morale" directly.

#### Individual Worker Fatigue Notifications

**Peak Performance (0-10 fatigue, 70+ morale):**
- "[Thomas] whistles while working"
- "[Jakob]: 'Best job I've ever had!'"
- "You notice [William] working with unusual enthusiasm"
- **Frequency:** Every 12-18 minutes per worker (rare treat)

**Energetic (10-25 fatigue, 60+ morale):**
- "[Thomas] is in high spirits today"
- "[Jakob] tackles the job with enthusiasm"
- "[William]: 'I could do this all day!'"
- **Frequency:** Every 10-15 minutes

**Fresh/Normal (25-55 fatigue):**
- **No notifications** (ideal working state)

**Tiring (55-70 fatigue):**
- "[Thomas] wipes sweat from his brow"
- "[Jakob] pauses to catch his breath"
- "You hear [William] ask for water"
- **Frequency:** Every 8-12 minutes

**Tired (70-80 fatigue):**
- "[Thomas] is breathing heavily"
- "[Jakob]: 'Could really use a break soon...'"
- "[William] leans on his shovel, looking worn"
- **Frequency:** Every 5-8 minutes

**Exhausted (80-90 fatigue):**
- "[Thomas] stumbles slightly"
- "[Jakob]: 'I don't know how much longer I can keep this up'"
- "[William]'s movements are noticeably slower"
- **Frequency:** Every 3-5 minutes

**Critical (90-95 fatigue, morale dropping):**
- "[Thomas] nearly drops his tools"
- "[Jakob]: 'Please, I need to stop!'"
- "[William] is barely standing"
- **Frequency:** Every 2-3 minutes

**Collapsed (95-100 fatigue):**
- "[Thomas] collapses! Other workers help him aside"
- "[Jakob]: 'I... I can't... do this...'"
- "[William] slumps against the wall, completely spent"
- **Frequency:** Every 90-120 seconds (very intrusive, signals crisis)

#### Group Break Notifications (Social Benefits)

When player uses "Send All on Break":
- "The crew gathers to chat and rest together"
- "You hear laughter from the dormitory"
- "Someone says: 'Thanks boss, we needed this'"
- "The workers seem in better spirits after spending time together"
- "[Thomas] and [Jakob] are swapping stories"
- "The crew looks refreshed and ready to get back to it"

**Purpose:** Reinforces that group breaks have social value beyond just fatigue recovery.

#### Food-Related Notifications

When food supply is low or workers are hungry:
- "[Thomas]'s stomach growls loudly"
- "[Jakob]: 'Any chance of some food?'"
- "[William] complains about being hungry"
- "The crew is asking about food"

#### Reputation Hints (Narrative Only)

At high reputation (70+):
- "Workers speak well of this place in town"
- "Your operation has a good reputation"

At low reputation (30-):
- "Rumors of poor conditions are spreading"
- "Fewer workers want to work here"

#### Hiring Pool Changes

When reputation changes significantly:
- "Word has spread about your operation - more workers are interested" (pool size increased)
- "A skilled worker has applied for a position!" (Tier 6-7 candidate available)
- "Your reputation is suffering - fewer workers want to work here" (pool shrunk)

#### Morale-Modified Tone

Notification tone adapts to morale level:

**High Morale (75+):** Polite, apologetic
- "[Thomas]: 'Sorry boss, I need a moment'"
- "[Jakob]: 'If it's alright, could I take a short break?'"

**Low Morale (< 40):** Hostile, accusatory
- "[Thomas]: 'You're working us into the ground!'"
- "[Jakob]: 'This is inhumane!'"

---

### Worker Management UI

All worker management happens in **owned_dorm.tscn** (new scene).

#### Owned Dormitory Scene (owned_dorm.tscn)

**New Scene Required:**
- Duplicate existing [level1/dorm.tscn](level1/dorm.tscn) → owned_dorm.tscn
- Shows dormitory with visible beds (empty vs occupied)
- Accessible from owned_furnace scene via "Visit Dormitory" button
- Accessible from bar scene (replaces dorm.tscn after furnace purchase)

**Scene Layout:**

**Left Panel: Worker Roster**
- Title: "Worker Roster"
- Scrollable list of hired workers
- Each entry shows:
  - Name (e.g., "Thomas")
  - Type (Stoker/Fireman/Engineer)
  - Quality descriptor (e.g., "Steady Hand")
  - Current status: Active / Idle / On Break
  - Buttons: [Assign Active] [Set Idle] [Send on Break] [Fire]
- If on break, shows countdown timer

**Right Panel Buttons:**
- **Hire Workers** - Opens hiring pool dialog
- **Send All on Break** - Group break (shows 15min cooldown if active)
- **Buy Food** - Opens food shop
- **Dormitory Upgrades** - Opens upgrade menu (beds + amenities)
- **Return to Furnace** - Goes back to owned_furnace.tscn

**Top Panel Info:**
- Current Food Supply: "Food: 47 units (Decent Meal)"
- Dormitory Capacity: "Beds: 8 / 10 occupied"
- Subtle reputation hint (narrative only, no number):
  - High reputation: "Workers speak well of this place"
  - Low reputation: "Conditions here are poorly regarded"

**Bottom Panel:**
- Auto-break policy dropdown: [Never ▼]
- Color indicator dot (discovery mechanic):
  - **Green:** All workers < 55 fatigue, morale > 60, food > 25%
  - **Yellow:** Some concerns (55-80 fatigue OR morale 40-60 OR food 10-25%)
  - **Red:** Critical issues (any worker > 80 fatigue OR morale < 40 OR food < 10%)

#### Hiring Pool Dialog

**Opened from:** "Hire Workers" button in owned_dorm.tscn

**Layout:**
```
+---------------------------------------+
|  Available Workers                 [X]|
+---------------------------------------+
| Beds Available: 2 / 10                |
|                                       |
| [Refresh Pool - 5 Silver]             |
|                                       |
| 1. Thomas (Stoker)                    |
|    "Ordinary Laborer"                 |
|    Cost: 8 Silver                     |
|    [Hire]                             |
|                                       |
| 2. Jakob (Fireman)                    |
|    "Green Recruit"                    |
|    Cost: 10 Silver                    |
|    [Hire]                             |
|                                       |
| 3. William (Stoker)                   |
|    "Sickly Youth"                     |
|    Cost: 2 Silver                     |
|    [Hire]                             |
|                                       |
| 4. Elias (Engineer)                   |
|    "Steady Hand"                      |
|    Cost: 65 Silver                    |
|    [Hire]                             |
|                                       |
| 5. Henrik (Stoker)                    |
|    "Capable Hand"                     |
|    Cost: 30 Silver                    |
|    [Hire]                             |
+---------------------------------------+
```

**Features:**
- Shows 3-8 candidates (based on reputation)
- Quality distribution based on reputation (hidden)
- Manual refresh: 5 Silver, generates new candidates
- Auto-refresh: Every 2 hours of runtime
- Cannot hire if no empty beds

#### Food Shop Dialog

**Opened from:** "Buy Food" button

**Layout:**
```
+---------------------------------------+
|  Food Supply                       [X]|
+---------------------------------------+
| Current: 47 units (Decent Meal)       |
|                                       |
| [✓] Stale Bread - 0.2 Silver/10 units |
|     "Barely edible scraps"            |
|     [Buy 50 units - 1 Silver]         |
|                                       |
| [✓] Basic Rations - 0.5 Silver/10 units |
|     "Plain but filling"               |
|     [Buy 50 units - 2.5 Silver]       |
|                                       |
| [✓] Decent Meal - 1.2 Silver/10 units |
|     "Simple but satisfying"           |
|     [Buy 50 units - 6 Silver]         |
|                                       |
| [🔒] Quality Food - 2.5 Silver/10 units |
|     Requires: 20h runtime             |
|                                       |
| [🔒] Premium Provisions - 5 Silver/10 units |
|     Requires: 50h runtime             |
|                                       |
| Auto-Purchase Settings:               |
| [✓] Enable Auto-Purchase              |
| When supply < 20 units, buy:          |
| [Decent Meal ▼] [50 units ▼]          |
+---------------------------------------+
```

#### Dormitory Upgrades Dialog

**Opened from:** "Dormitory Upgrades" button

**Two tabs:** Beds | Amenities

**Beds Tab:**
```
+---------------------------------------+
|  Dormitory Upgrades - Beds         [X]|
+---------------------------------------+
| Current Capacity: 8 / 10 beds         |
|                                       |
| [✓] Starting Beds - 2 beds            |
|     (Included)                        |
|                                       |
| [✓] Bunk Bed Pair - 2 beds            |
|     (Purchased)                       |
|                                       |
| [✓] Second Bunk Set - 2 beds          |
|     (Purchased)                       |
|                                       |
| [ ] Third Bunk Set - 2 beds           |
|     Cost: 90 Silver                   |
|     Requires: 25h runtime             |
|     [Purchase]                        |
|                                       |
| [🔒] Fourth Bunk Set - 2 beds         |
|     Requires: 40h runtime             |
+---------------------------------------+
```

**Amenities Tab:**
```
+---------------------------------------+
|  Dormitory Upgrades - Amenities    [X]|
+---------------------------------------+
| Improve worker conditions             |
|                                       |
| [✓] Water Barrels                     |
|     "Cool water for the crew"         |
|     (Purchased)                       |
|                                       |
| [ ] Simple Cots                       |
|     Cost: 50 Silver, 8h runtime       |
|     "Mattresses for the bunks"        |
|     Benefit: "Better than the floor"  |
|     [Purchase]                        |
|                                       |
| [ ] Tool Storage Rack                 |
|     Cost: 80 Silver, 15h runtime      |
|     "Organized equipment area"        |
|     Benefit: "Keeps things tidy"      |
|     [Purchase]                        |
|                                       |
| [🔒] Ventilation Grate                |
|     Requires: 25h runtime             |
+---------------------------------------+
```

---

### Worker Production Formulas

#### Heat Generation (Stokers)

```gdscript
func calculate_stoker_heat_generation(delta):
    var total_heat = 0.0
    for worker in worker_roster:
        if worker.type == "stoker" and worker.status == "active":
            var base_heat_per_sec = 1.0  # Baseline for Tier 4
            var quality_multiplier = get_quality_productivity(worker.quality_tier)
            var fatigue_multiplier = get_fatigue_performance(worker.fatigue)
            var morale_multiplier = get_morale_productivity(crew_morale)

            var worker_heat = base_heat_per_sec * quality_multiplier *
                              fatigue_multiplier * morale_multiplier * delta
            total_heat += worker_heat

    current_heat += total_heat
```

#### Heat Decay Reduction (Firemen)

```gdscript
func calculate_heat_decay(delta):
    var base_decay = 0.5  # per second
    var fireman_reduction = 0.0

    for worker in worker_roster:
        if worker.type == "fireman" and worker.status == "active":
            var quality_multiplier = get_quality_productivity(worker.quality_tier)
            var fatigue_multiplier = get_fatigue_performance(worker.fatigue)
            var morale_multiplier = get_morale_productivity(crew_morale)

            fireman_reduction += 0.1 * quality_multiplier *
                                 fatigue_multiplier * morale_multiplier

    var effective_decay = max(base_decay - fireman_reduction, 0.1)
    current_heat -= effective_decay * delta
```

#### Steam Efficiency (Engineers)

```gdscript
func calculate_steam_efficiency():
    var base_efficiency = 1.0
    var engineer_bonus = 0.0

    for worker in worker_roster:
        if worker.type == "engineer" and worker.status == "active":
            var quality_multiplier = get_quality_productivity(worker.quality_tier)
            var fatigue_multiplier = get_fatigue_performance(worker.fatigue)
            var morale_multiplier = get_morale_productivity(crew_morale)

            engineer_bonus += 0.1 * quality_multiplier *
                              fatigue_multiplier * morale_multiplier

    return base_efficiency + engineer_bonus
```

---

### Strategic Gameplay Implications

#### Multiple Valid Strategies

**"Sweatshop" Strategy:**
- Hire cheap workers (Tier 1-2)
- Feed stale bread
- Ruthless management
- Minimal amenities
- **Result:** Low productivity, high fatigue, low morale, poor reputation, unsustainable long-term

**"Balanced" Strategy:**
- Mid-tier workers (Tier 3-4)
- Decent food
- Orderly management
- Some amenities
- **Result:** Stable, reliable production, moderate costs

**"Premium Operation" Strategy:**
- Skilled workers (Tier 6-7)
- Quality/premium food
- Comfortable management
- All amenities
- **Result:** High productivity, low fatigue, high morale, excellent reputation, attracts best candidates

**"Rotation Specialist" Strategy:**
- Many workers hired
- Manual active/idle management
- Strategic group breaks
- **Result:** Micromanagement-intensive but highly efficient

**"Automation" Strategy:**
- Aggressive auto-break policy
- Good amenities
- Quality food
- **Result:** Hands-off, consistent performance

#### Reputation Feedback Loop

Good treatment → High reputation → Better candidates → Higher efficiency → More profits → Afford better treatment

Poor treatment → Low reputation → Only desperate workers → Low efficiency → Lower profits → Cannot afford improvements

#### Charisma as Key Stat

High charisma provides:
- -40% fatigue accumulation (workers tire much slower)
- +12 morale (workers happier)
- +30 reputation (attracts better workers)
- Better recovery rates

**Makes charisma extremely valuable** beyond just dialogue options.

---

### Save/Load Variables

Add to Level1Vars:

```gdscript
# Worker roster (array of dictionaries)
var worker_roster = []
# Each worker dict:
# {
#     "name": "Thomas",
#     "type": "stoker",  # stoker, fireman, engineer
#     "quality_tier": 4,  # 1-7
#     "fatigue": 35.0,  # 0.0-100.0
#     "status": "active",  # active, idle, on_break
#     "break_end_time": 0,  # timestamp
#     "hire_timestamp": 12345
# }

# Dormitory capacity
var dormitory_beds = 2  # Starts at 2, increases with bed purchases

# Reputation system (hidden from player)
var worker_reputation = 0.0  # 0-100

# Hiring pool
var hiring_pool = []
# Each candidate dict:
# {
#     "name": "Jakob",
#     "type": "fireman",
#     "tier": 3,
#     "cost": 180
# }
var last_pool_refresh_time = 0

# Crew morale (shared pool)
var crew_morale = 50.0  # 0-100

# Food system
var food_supply = 0  # Units remaining
var current_food_tier = 2  # Which quality tier is stocked
var auto_purchase_food = false
var auto_purchase_tier = 2
var auto_purchase_amount = 50

# Break management
var break_policy = "never"  # never, conservative, balanced, aggressive, preventive
var last_group_break_time = 0

# Amenities purchased (bitmask for 10 tiers)
var dorm_amenities_purchased = 0

# Statistics tracking
var total_workers_hired = 0
var total_workers_fired = 0
var total_individual_breaks = 0
var total_group_breaks = 0
var total_worker_collapses = 0  # Times any worker hit 95+ fatigue
var peak_morale = 50.0
var peak_reputation = 0.0

# Notification throttling
var last_fatigue_notification_per_worker = {}  # {"Thomas": 12345, ...}
var last_food_notification = 0
var last_reputation_notification = 0
```

---

### Integration with Existing Systems

#### Charisma Stat Integration

Update Global.gd experience system documentation:

**Charisma Benefits (Hidden from Player):**
- **Fatigue Reduction:** -2% per level (max -40% at level 20)
- **Morale Bonus:** +0.4 morale per level (max +12 at level 30)
- **Reputation Bonus:** +1 reputation per level (max +30)
- **Recovery Speed:** +0.02/sec per 5 levels
- **Hiring Pool:** High charisma attracts better quality candidates

#### Overseer Management Style Integration

Update Hired Overseer System section:

**Management Style Effects** (add fatigue column):

| Slider % | Label | Cost | Production | Charisma Gain | **Fatigue Rate** |
|----------|-------|------|------------|---------------|------------------|
| 0% | Comfortable | -20% | 0.5x | 0.2 | 0.5x |
| 10% | Considerate | -16% | 0.6x | 0.5 | 0.6x |
| 20% | Lenient | -12% | 0.7x | 0.8 | 0.7x |
| 30% | **Orderly** | -8% | **0.8x** | **1.0** | **0.85x** |
| 40% | Fair | -5% | 0.9x | 0.8 | 1.0x |
| 50% | Firm | 0% | 1.0x | 0.5 | 1.15x |
| 60% | Strict | -3% | 1.1x | 0.3 | 1.3x |
| 70% | Demanding | -5% | 1.2x | 0.15 | 1.5x |
| 80% | Harsh | -7% | 1.3x | 0.05 | 1.7x |
| 90% | **Severe** | -9% | **1.35x** | **0.01** | **1.9x** |
| 100% | Ruthless | -10% | 1.4x | 0.0 | 2.1x |

**Note:** Management style affects worker fatigue accumulation both online (player present) and offline (hired overseer managing).

#### Revenue Formula Integration

Update revenue calculation in owned_furnace.tscn:

```gdscript
# Revenue calculation with worker productivity
var base_revenue = 0.1  # coins per second
var performance_multiplier = revenue_multipliers[performance]  # excellent/good/poor/failing
var worker_productivity = calculate_average_worker_productivity()
var morale_modifier = get_morale_productivity(crew_morale)

var final_revenue = base_revenue * performance_multiplier *
                    worker_productivity * morale_modifier
```

Where `calculate_average_worker_productivity()` returns average of all active workers' fatigue-based performance multipliers.

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
|     Cost: 80 Silver              |
|     Requires: 20 runtime hours   |
|                                  |
| [🔒] Mild Steel - 1,100°C        |
|     Cost: 250 Silver (or 2.5 Gold) |
|     Requires: Wrought Iron +     |
|               50 runtime hours   |
|                                  |
| [🔒] Cupola Design - 1,550°C     |
|     Cost: 8 Gold +               |
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
|     Cost: 24 Silver              |
|     Effect: +15% max heat        |
|             -10% decay rate      |
|                                  |
| [ ] Heavy Wall - 1.3x            |
|     Cost: 48 Silver              |
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
|     Cost: 30 Silver              |
|     Max: 960°C                   |
|     Durability: 100 hours        |
|     Requires: Tier 2+ material   |
|                                  |
| [🔒] High-Alumina - 1.6x         |
|     Cost: 120 Silver (or 1.2 Gold) |
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
|     Cost: 15 Silver              |
|     Effect: +200 max steam       |
|                                  |
| [ ] Steam Efficiency Upgrade     |
|     Level: 0 → 1                 |
|     Cost: 20 Silver              |
|     Effect: +20% steam/heat      |
|                                  |
| [🔒] Cooling System              |
|     Cost: 150 Silver (or 1.5 Gold) |
|     Effect: -30% heat decay      |
|     Requires: Mild Steel+        |
|                                  |
| [🔒] Forced Air Injection        |
|     Cost: 3 Gold +               |
|           25 mechanisms          |
|     Effect: +25% heat from coal  |
|     Requires: Cupola Design+     |
|                                  |
| [ ] Temperature Monitoring       |
|     Cost: 50 Silver              |
|     Effect: Shows exact temp,    |
|             advance warnings     |
+----------------------------------+
```

**Tab 5: Steam Storage**
```
+----------------------------------+
|  Furnace Upgrades - Storage   [X]|
+----------------------------------+
| Steam Storage System             |
| Capture excess steam during low  |
| demand for use during spikes     |
|                                  |
| [✓] No Storage                   |
|     Current: 0 capacity          |
|                                  |
| [ ] Steam Accumulator Tank       |
|     Cost: 30 Silver              |
|     Capacity: +200 storage       |
|     Efficiency: 80%              |
|                                  |
| [🔒] Compressed Steam Reservoir  |
|     Cost: 80 Silver              |
|     Capacity: +300 storage       |
|     Requires: Accumulator Tank   |
|                                  |
| [🔒] Multi-Chamber Storage       |
|     Cost: 200 Silver (or 2 Gold) |
|     Capacity: +700 storage       |
|     Unlocks: Manual release      |
|              (10% button) &      |
|              auto-release        |
|     Requires: Compressed Res.    |
|                                  |
| [🔒] Hydraulic Accumulator       |
|     Cost: 5 Gold +               |
|           50 mechanisms          |
|     Capacity: +1,300 storage     |
|     Efficiency: 90%              |
|     Requires: Multi-Chamber      |
|                                  |
| [🔒] Battery Bank (Late Game)    |
|     Cost: 15 Gold +              |
|           100 components +       |
|           50 pipes               |
|     Capacity: +2,500 storage     |
|     Efficiency: 100%             |
|     Requires: Hydraulic Accum. + |
|               Power System       |
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

### Storage Control UI

**Popup:** "Steam Storage Controls" (Tier 3+ only)

**Purpose:** Manage stored steam release and configure auto-release settings

**Layout:**
```
+----------------------------------+
|  Steam Storage Controls       [X]|
+----------------------------------+
| Current Storage: 800 / 1200      |
| Efficiency: 80%                  |
|                                  |
| Divert Production to Storage:    |
| [--------○------] 0%             |
|                                  |
| Manual Release:                  |
| [Release 10%]                    |
|                                  |
| Auto-Release Settings:           |
| [✓] Enable Auto-Release          |
|                                  |
| Trigger when steam drops below:  |
| [--------○------] 60%            |
|                                  |
| Info: Auto-release activates     |
| during high/critical demand only |
+----------------------------------+
```

**Button Functions:**

**Diversion Slider:**
- Range: 0% to 100%
- Default: 0% (no active diversion)
- Saves to Level1Vars.storage_diversion_percentage
- Continuously diverts X% of steam production to storage (before demand consumption)
- Works independently of overflow (overflow still captures excess when main is full)
- Strategic use: Set to 20-50% during low demand/low pay periods to build reserves
- Real-time preview: "Diverting ~15 steam/sec to storage at current production"
- Color indicator: Green when diverting, gray when at 0%

**Release 10% Button:**
- Releases 10% of max storage capacity (not current stored amount)
- Example: With 1,200 max storage, always releases 120 steam per click
- Consistent release amount regardless of how much is currently stored
- Can be clicked multiple times rapidly for larger releases
- Button disabled if stored_steam == 0
- Shows actual amount being released: "Release 10% (120 steam)"
- Provides fine-grained, predictable control

**Auto-Release Toggle:**
- Checkbox to enable/disable
- Saves state to Level1Vars.auto_release_enabled
- When enabled, shows threshold slider

**Threshold Slider:**
- Range: 0% to 100%
- Default: 60%
- Saves to Level1Vars.auto_release_threshold
- Real-time preview: "Will release when below 300/500 steam"

**Behavior:**
- Auto-release only triggers during "high" or "critical" demand states
- Releases 100% of stored steam when triggered
- Shows notification: "Auto-release activated!"
- Useful for semi-idle gameplay

---

## Hired Overseer System (Offline Progression) ⭐

### System Overview

**Purpose:** Enable offline progression by hiring an overseer to manage the furnace while the player is away

**Design Philosophy:**
- **No offline progression by default** - Heat, steam, demand, and revenue only accumulate when actively playing
- **Paid management** - Overseer must be compensated from accumulated revenue
- **Efficiency penalties** - Overseer operates at reduced efficiency compared to active player
- **Limited shift duration** - Initially short shifts, upgradeable to longer absences
- **Three independent upgrade dimensions** - Quality, duration, and management style

**Thematic Role Reversal:**
- Player was a worker under an overseer in the initial furnace scene
- Now the player is the owner hiring an overseer to manage their furnace
- Creates narrative symmetry and progression

---

### Three Independent Upgrade Paths

The Hired Overseer system has three separate, independently upgradeable dimensions:

**1. Overseer Quality (Production Efficiency)**
- Determines how efficiently the overseer operates the furnace
- Higher tiers = better production during offline periods
- 6 tiers: Apprentice → Junior → Experienced → Senior → Master → Executive Manager

**2. Shift Duration (Time Away Limit)**
- Determines maximum hours the overseer can manage before requiring player return
- Longer shifts = more offline time possible
- 10 tiers: 1h → 2h → 4h → 8h → 12h → 18h → 24h → 36h → 48h → 72h

**3. Management Style (Comfort ←→ Efficiency)**
- Continuous slider controlling overseer's treatment of workers
- Affects production (hidden), cost (visible), and charisma gain (hidden)
- Player only sees cost differences, must discover optimal settings through experimentation

---

### 1. Overseer Quality Upgrades

Progressive efficiency tiers representing overseer skill and experience.

**Tier 1: Apprentice Overseer**
- **Efficiency:** 30% of full production
- **Cost:** 15 Silver
- **Requirements:** Furnace ownership
- **Description:** "Inexperienced manager, still learning the ropes. Keeps things running at minimal capacity."

**Tier 2: Junior Overseer**
- **Efficiency:** 50% of full production
- **Cost:** 40 Silver
- **Requirements:** Apprentice Overseer
- **Description:** "Competent but cautious manager. Maintains stable operations."

**Tier 3: Experienced Overseer**
- **Efficiency:** 65% of full production
- **Cost:** 100 Silver (or 1 Gold)
- **Requirements:** Junior Overseer
- **Description:** "Seasoned manager who knows the furnace well. Good efficiency."

**Tier 4: Senior Overseer**
- **Efficiency:** 80% of full production
- **Cost:** 250 Silver (or 2.5 Gold)
- **Requirements:** Experienced Overseer
- **Description:** "Veteran manager with years of experience. Near-optimal operations."

**Tier 5: Master Overseer**
- **Efficiency:** 90% of full production
- **Cost:** 6 Gold + 25 mechanisms
- **Requirements:** Senior Overseer
- **Description:** "Expert manager, one of the best in the region. Exceptional efficiency."

**Tier 6: Executive Manager**
- **Efficiency:** 98% of full production
- **Cost:** 15 Gold + 75 mechanisms + 50 components
- **Requirements:** Master Overseer
- **Description:** "Elite professional manager with formal training. Nearly matches owner's personal oversight."

---

### 2. Shift Duration Upgrades

Progressive time limit upgrades allowing longer offline periods.

**Tier 1: Trial Shift**
- **Duration:** 1 hour
- **Cost:** Included with first overseer hire
- **Description:** "Brief test shift to evaluate the overseer's capabilities."

**Tier 2: Short Shift**
- **Duration:** 2 hours
- **Cost:** 10 Silver
- **Description:** "Quick shift for short absences."

**Tier 3: Standard Shift**
- **Duration:** 4 hours
- **Cost:** 25 Silver
- **Description:** "Half-day shift for moderate absences."

**Tier 4: Extended Shift**
- **Duration:** 8 hours
- **Cost:** 60 Silver
- **Description:** "Full workday shift for daytime management."

**Tier 5: Double Shift**
- **Duration:** 12 hours
- **Cost:** 120 Silver (or 1.2 Gold)
- **Description:** "Long shift covering business hours and evening operations."

**Tier 6: Long Shift**
- **Duration:** 18 hours
- **Cost:** 250 Silver (or 2.5 Gold)
- **Description:** "Extended coverage for overnight operations."

**Tier 7: Full Day Shift**
- **Duration:** 24 hours
- **Cost:** 5 Gold + 10 mechanisms
- **Description:** "Round-the-clock management for full-day absences."

**Tier 8: Extended Day Shift**
- **Duration:** 36 hours
- **Cost:** 10 Gold + 25 mechanisms
- **Description:** "Day-and-a-half coverage for weekend trips."

**Tier 9: Two-Day Shift**
- **Duration:** 48 hours
- **Cost:** 20 Gold + 50 mechanisms + 25 components
- **Description:** "Full weekend coverage without player oversight."

**Tier 10: Three-Day Shift**
- **Duration:** 72 hours
- **Cost:** 40 Gold + 100 mechanisms + 50 components
- **Description:** "Extended multi-day management for long absences."

---

### 3. Management Style Slider (Continuous)

A fluid, continuous slider controlling how the overseer treats workers. The slider has **8 descriptive labels** but allows positioning at any point between 0% and 100%.

**What the Player SEES:**
- Single descriptive word based on slider position
- Cost modifier percentage only
- NO productivity information
- NO charisma gain information

**What is HIDDEN from the Player:**
- Production efficiency multipliers
- Charisma gain per hour
- All strategic trade-offs

**Slider Labels (8-point progression):**

| Position | Label | Cost Modifier |
|----------|-------|---------------|
| 0% | Comfortable | -20% |
| 12% | Relaxed | -17% |
| 25% | Orderly | -13% |
| 37% | Structured | -8% |
| 50% | Firm | 0% |
| 62% | Strict | -3% |
| 75% | Demanding | -6% |
| 87% | Ruthless | -9% |

**Hidden Production Multipliers:**

```gdscript
# Hidden from player - they must discover through experimentation
func get_production_multiplier(slider_percent: float) -> float:
    # 0% = 0.50x (Comfortable, workers too relaxed)
    # 30% = 0.65x (Orderly, sweet spot for charisma but lower production)
    # 50% = 0.80x (Firm, baseline)
    # 70% = 1.10x (Strict, pushing hard)
    # 100% = 1.40x (Ruthless, maximum exploitation)

    if slider_percent <= 50.0:
        # 0% to 50%: 0.5x to 0.8x
        return 0.5 + (slider_percent / 50.0) * 0.3
    else:
        # 50% to 100%: 0.8x to 1.4x
        return 0.8 + ((slider_percent - 50.0) / 50.0) * 0.6
```

**Hidden Charisma Gain Per Hour:**

```gdscript
# Completely hidden from player - no UI indication whatsoever
# Peak at ~30% (Orderly position)
func get_charisma_per_hour(slider_percent: float) -> float:
    # 0% = +0.2 charisma/hour (too lenient, workers resent laziness)
    # 30% = +1.0 charisma/hour (PEAK - firm but fair, respected leadership)
    # 50% = +0.5 charisma/hour (balanced but not optimal)
    # 70% = +0.2 charisma/hour (harsh conditions)
    # 100% = +0.0 charisma/hour (brutal, no charisma growth)

    if slider_percent <= 30.0:
        # 0% to 30%: 0.2 to 1.0 (rising to peak)
        return 0.2 + (slider_percent / 30.0) * 0.8
    elif slider_percent <= 50.0:
        # 30% to 50%: 1.0 to 0.5 (falling from peak)
        return 1.0 - ((slider_percent - 30.0) / 20.0) * 0.5
    elif slider_percent <= 70.0:
        # 50% to 70%: 0.5 to 0.2 (continuing to fall)
        return 0.5 - ((slider_percent - 50.0) / 20.0) * 0.3
    else:
        # 70% to 100%: 0.2 to 0.0 (approaching zero, never negative)
        return max(0.0, 0.2 - ((slider_percent - 70.0) / 30.0) * 0.2)
```

**Visible Cost Curve:**

```gdscript
# This IS shown to the player
func get_cost_multiplier(slider_percent: float) -> float:
    # Creates a curve: expensive at comfortable, peaks at firm, cheaper at ruthless
    # 0% = 0.8 (20% discount - comfortable conditions cost more)
    # 50% = 1.0 (full base cost)
    # 100% = 0.9 (10% discount - exploitation saves money)

    if slider_percent <= 50.0:
        # 0% to 50%: 0.8 to 1.0
        return 0.8 + (slider_percent / 50.0) * 0.2
    else:
        # 50% to 100%: 1.0 to 0.9
        return 1.0 - ((slider_percent - 50.0) / 50.0) * 0.1
```

**Label Selection:**

```gdscript
func get_management_label(slider_percent: float) -> String:
    if slider_percent < 8.0:
        return "Comfortable"
    elif slider_percent < 18.0:
        return "Relaxed"
    elif slider_percent < 31.0:
        return "Orderly"
    elif slider_percent < 43.0:
        return "Structured"
    elif slider_percent < 56.0:
        return "Firm"
    elif slider_percent < 68.0:
        return "Strict"
    elif slider_percent < 81.0:
        return "Demanding"
    else:
        return "Ruthless"
```

---

### Overseer UI Design

**Popup Window:** "Hired Overseer Management"

**Location:** Accessed from owned_furnace scene right panel button

**Layout:**
```
+─────────────────────────────────────────+
|  Hired Overseer Management          [X] |
+─────────────────────────────────────────+
| Status: Idle                             |
| (When active: Time Remaining: 17:23:45)  |
|                                          |
| ──────────── QUALITY ──────────────      |
| Current: Senior Overseer (80%)           |
| ↑ Upgrade to Master (90%)                |
|   Cost: 6 Gold + 25 mechanisms           |
|                                          |
| ──────────── DURATION ──────────────     |
| Max Shift Length: 18 hours               |
| ↑ Upgrade to Full Day (24h)              |
|   Cost: 5 Gold + 10 mechanisms           |
|                                          |
| ──────────── MANAGEMENT STYLE ────────── |
|                                          |
| [━━━━●━━━━━━━━━━━━━━━━] 25%            |
|                                          |
|         Orderly                          |
|       Cost: -13%                         |
|                                          |
| ────────────────────────────────────     |
|                                          |
| Shift Cost: 4.5 Silver/hour              |
| Total Cost: 81 Silver for 18h shift      |
|                                          |
| Set Shift Duration: [slider 1h-18h]      |
| Selected: 18 hours                       |
|                                          |
| [Start Overseer Shift]                   |
+─────────────────────────────────────────+
```

**UI Behavior:**
- Slider is **continuous** - can be positioned anywhere from 0-100%
- Word label updates fluidly as slider moves
- Cost percentage updates in real-time
- NO hints about production or charisma effects
- Shift duration slider shows only available range (based on purchased upgrades)
- Start button disabled if cannot afford total cost

---

### Cost Calculation & Payment

**Base Shift Cost Formula:**
```gdscript
# Calculate base hourly cost
var base_hourly_rate = (average_revenue_per_hour * overseer_quality_efficiency)
var cost_multiplier = get_cost_multiplier(management_slider_percent)
var hourly_cost = base_hourly_rate * cost_multiplier

# Total shift cost
var total_shift_cost = hourly_cost * shift_duration_hours
```

**Payment Timing:**
- Cost is **deducted upfront** when shift starts
- If player cannot afford full shift cost, shift cannot be started
- Any revenue earned during shift is added to player's coins
- Net result: `final_coins = starting_coins - shift_cost + revenue_earned`

**Revenue During Shift:**
```gdscript
# Offline revenue calculation (when shift completes)
var quality_efficiency = overseer_quality_percent  # 0.30 to 0.98
var style_efficiency = get_production_multiplier(management_slider_percent)  # 0.5 to 1.4
var total_efficiency = quality_efficiency * style_efficiency

# Apply to normal revenue calculation
var offline_revenue = normal_revenue * total_efficiency * hours_elapsed
```

**Charisma Accumulation:**
```gdscript
# When shift completes (completely silent, no notification)
var charisma_per_hour = get_charisma_per_hour(management_slider_percent)
var total_charisma_gain = charisma_per_hour * shift_duration_hours

Global.add_stat_exp("charisma", total_charisma_gain)
# NO notification - player must discover this through improved worker efficiency
```

---

### Integration with Existing Systems

**With Worker System:**
- Overseer manages existing hired workers (stokers, firemen, engineers)
- Worker effects continue during offline time at reduced efficiency
- Worker heat generation, decay reduction, steam efficiency all apply
- Overseer quality determines how effectively workers are utilized

**With Demand System:**
- Demand continues to fluctuate during offline time
- Overseer attempts to meet demand using available workers/steam
- Performance is tracked and affects revenue multiplier
- Critical demand spikes may cause poor performance if not prepared

**With Charisma System:**
- Charisma gains from overseer management style (hidden)
- Existing charisma bonus to worker efficiency still applies
- Creates compound effect: higher charisma → better workers → better offline gains
- Sweet spot discovery: players eventually learn ~30% slider = best long-term growth

**With Steam Storage System:**
- Storage continues to function during offline time
- Overflow storage captures excess during low demand
- Auto-release (if configured) helps manage high demand spikes
- Storage particularly valuable for longer offline periods

---

### Level1Vars Additions

```gdscript
# Hired Overseer System
var overseer_quality_tier: int = 0  # 0=none, 1=apprentice, 2=junior, ..., 6=executive
var overseer_shift_duration_tier: int = 0  # 0=none, 1=1h, 2=2h, ..., 10=72h
var overseer_management_slider: float = 50.0  # 0.0 to 100.0, continuous

# Overseer Active State
var overseer_shift_active: bool = false
var overseer_shift_start_time: int = 0  # Unix timestamp
var overseer_shift_duration: float = 0.0  # Hours selected for current shift
var overseer_shift_cost_paid: float = 0.0  # Cost deducted at start

# Overseer Unlocks
var overseer_quality_unlocked: Array[bool] = [false, false, false, false, false, false, false]  # 7 tiers (0=none)
var overseer_duration_unlocked: Array[bool] = [false, false, false, false, false, false, false, false, false, false, false]  # 11 tiers (0=none)
```

---

### Implementation Notes

**Offline Time Calculation:**

```gdscript
# In owned_furnace.gd or global offline time processor
func process_offline_overseer_time():
    if not Level1Vars.overseer_shift_active:
        return

    var current_time = Time.get_unix_time_from_system()
    var elapsed_seconds = current_time - Level1Vars.overseer_shift_start_time
    var elapsed_hours = elapsed_seconds / 3600.0

    # Cap at purchased shift duration
    var max_hours = get_shift_duration_hours(Level1Vars.overseer_shift_duration_tier)
    elapsed_hours = min(elapsed_hours, max_hours)

    if elapsed_hours >= Level1Vars.overseer_shift_duration:
        # Shift complete
        complete_overseer_shift(elapsed_hours)
    else:
        # Shift still in progress - show remaining time
        update_overseer_ui(elapsed_hours)

func complete_overseer_shift(hours_elapsed: float):
    # Calculate revenue earned
    var quality_eff = get_quality_efficiency(Level1Vars.overseer_quality_tier)
    var style_eff = get_production_multiplier(Level1Vars.overseer_management_slider)
    var total_eff = quality_eff * style_eff

    # Simulate production
    var revenue_earned = calculate_offline_revenue(hours_elapsed, total_eff)
    Level1Vars.coins += revenue_earned

    # Silently award charisma (no notification!)
    var charisma_gain = get_charisma_per_hour(Level1Vars.overseer_management_slider) * hours_elapsed
    Global.add_stat_exp("charisma", charisma_gain)

    # Reset overseer state
    Level1Vars.overseer_shift_active = false

    # Show completion summary
    show_shift_complete_popup(hours_elapsed, revenue_earned, Level1Vars.overseer_shift_cost_paid)
```

**UI Update Functions:**

```gdscript
func update_management_slider_display():
    var percent = Level1Vars.overseer_management_slider
    var label = get_management_label(percent)
    var cost_mult = get_cost_multiplier(percent)
    var cost_display = "%+.0f%%" % ((cost_mult - 1.0) * 100)

    management_label.text = label
    cost_label.text = "Cost: " + cost_display

    # Update total shift cost estimate
    update_shift_cost_estimate()
```

---

### Strategic Player Discovery Process

**Phase 1: Initial Discovery**
- Player hires first overseer, uses default 50% (Firm) slider position
- Returns to modest revenue, realizes offline progression is possible
- Experiments with slider to see cost differences

**Phase 2: Cost Optimization**
- Player discovers moving slider toward "Ruthless" reduces costs
- May operate at high efficiency (90-100%) for pure profit maximization
- Accumulates coins but misses hidden charisma gains

**Phase 3: Performance Discrepancy**
- Over time, player may notice their workers seem less efficient than other players
- Or notices their own worker efficiency varies between play sessions
- Begins to wonder if management style affects more than cost

**Phase 4: Experimentation**
- Player tries different slider positions over multiple shifts
- Eventually notices worker efficiency improvements after using "Orderly" (~30%)
- Discovers the charisma sweet spot through gameplay, not UI hints
- Realizes long-term optimization ≠ short-term profit

**Phase 5: Mastery**
- Understands the hidden trade-off: short-term revenue vs long-term worker efficiency
- Strategically chooses positions based on current needs:
  - Need coins now? Use Ruthless (100%)
  - Building for endgame? Use Orderly (~30%)
  - Balanced approach? Use Firm-Structured (40-50%)

**Design Goal:** Player never sees explicit mechanics but can discover optimal play through observation and experimentation.

---

### Implementation Checklist Addition

**Phase 5K: Hired Overseer System**

- [ ] **Add overseer variables to Level1Vars**
  - overseer_quality_tier, overseer_shift_duration_tier
  - overseer_management_slider (0-100 continuous)
  - overseer_shift_active, start_time, duration
  - Add to save/load dictionaries

- [ ] **Create overseer management popup**
  - Design popup layout with three sections (quality, duration, style)
  - Add upgrade buttons for quality tiers (6 tiers)
  - Add upgrade buttons for duration tiers (10 tiers)
  - Implement continuous slider for management style (0-100%)
  - Show only cost modifier, hide all other effects

- [ ] **Implement overseer upgrade purchases**
  - Quality tier purchase logic with costs/requirements
  - Duration tier purchase logic with costs/requirements
  - Track unlocks in Level1Vars
  - Log purchases via UpgradeTypesConfig

- [ ] **Implement overseer shift start logic**
  - Calculate total shift cost upfront
  - Deduct cost from player coins
  - Record shift start time (Unix timestamp)
  - Set overseer_shift_active = true
  - Disable start button while shift active

- [ ] **Implement offline time processing**
  - Detect offline time on return to game
  - Calculate hours elapsed (capped at purchased duration)
  - Apply quality efficiency × style efficiency
  - Calculate revenue earned during shift
  - Award charisma (hidden, no notification)
  - Show shift completion summary popup

- [ ] **Create helper functions**
  - get_quality_efficiency(tier) → 0.30 to 0.98
  - get_shift_duration_hours(tier) → 1 to 72
  - get_management_label(percent) → string
  - get_cost_multiplier(percent) → 0.8 to 0.9
  - get_production_multiplier(percent) → 0.5 to 1.4 (hidden)
  - get_charisma_per_hour(percent) → 0.0 to 1.0 (hidden)

- [ ] **Integrate with existing systems**
  - Ensure worker effects apply during offline time
  - Ensure demand system simulates during offline time
  - Ensure storage system functions during offline time
  - Test charisma accumulation and worker efficiency synergy

- [ ] **Update UpgradeTypesConfig**
  - Add "overseer_quality_tier_N" entries (6 tiers)
  - Add "overseer_duration_tier_N" entries (10 tiers)
  - Track for prestige system

- [ ] **Test overseer system**
  - Test shift start with sufficient/insufficient coins
  - Test offline time calculation accuracy
  - Test efficiency multiplier application
  - Test charisma accumulation (verify it's hidden)
  - Test discovery: does slider affect worker efficiency?
  - Test edge case: app killed mid-shift
  - Test maximum duration: 72-hour shift

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
- **Cost:** 80 Silver
- **Requirements:** 20 lifetime furnace runtime hours
- **Unlocks:** Improved steam pressure capabilities

**Tier 3: Mild Steel Shell**
- **Base Temp Limit:** 1,100°C (2,012°F)
- **Historical Context:** Late 1800s standard for industrial boilers
- **Real Limitation:** Steel softens around 600-700°C but modern designs use water cooling and refractory
- **Characteristics:** Strong, consistent, allows pressure vessel operations
- **Cost:** 250 Silver (or 2.5 Gold)
- **Requirements:** Wrought iron shell, 50 lifetime hours
- **Unlocks:** Transition to industrial smelting capabilities

**Tier 4: Cupola Furnace Design** *(Cast Iron Smelting)*
- **Base Temp Limit:** 1,550°C (2,822°F)
- **Historical Context:** Traditional cast iron melting furnace (1700s-present)
- **Real Limitation:** Actual cupola operating temperature
- **Characteristics:** Cylindrical steel shell with thick refractory lining, continuous operation
- **Cost:** 8 Gold + 50 components
- **Requirements:** Mild steel shell, 100 lifetime hours
- **Unlocks:** Cast iron melting, component self-production

**Tier 5: Blast Furnace Design** *(Iron Smelting)*
- **Base Temp Limit:** 1,600°C (2,912°F)
- **Historical Context:** Large-scale iron production (1500s-present)
- **Real Limitation:** Industrial blast furnace operating temperature
- **Characteristics:** Tall design, forced air injection, continuous feed
- **Cost:** 20 Gold + 150 components + 100 mechanisms
- **Requirements:** Cupola design, 200 lifetime hours
- **Unlocks:** Iron ore processing, advanced metallurgy

**Tier 6: Electric Induction Furnace**
- **Base Temp Limit:** 1,800°C (3,272°F)
- **Historical Context:** Modern foundry standard (1900s-present)
- **Real Limitation:** Industrial induction furnace typical operating range
- **Characteristics:** Electromagnetic heating, precise temperature control, clean process
- **Cost:** 50 Gold + 300 components + 200 mechanisms + 100 pipes
- **Requirements:** Blast furnace design, 300 lifetime hours, Power System unlocked
- **Unlocks:** High-grade steel production, rapid melting

**Tier 7: Electric Arc Furnace**
- **Base Temp Limit:** 3,000°C (5,432°F)
- **Historical Context:** Modern steelmaking and specialty alloy production
- **Real Limitation:** Industrial EAF operating temperature
- **Characteristics:** Arc plasma heating, extreme temperatures, alloy production
- **Cost:** 150 Gold + 500 components + 500 mechanisms + 300 pipes
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
- **Cost:** 30 Silver
- **Requirements:** Tier 2+ (Wrought iron shell or better)
- **Effect:** +30% temperature limit
- **Maintenance:** Degrades slowly, needs replacement every 100 hours

**High-Alumina Firebrick** *(Improved Refractory)*
- **Multiplier:** 1.6x
- **Max Operating Temp:** 1,788°C (3,250°F)
- **Historical Context:** 1900s development for high-temperature industry
- **Composition:** 50-90% alumina content
- **Cost:** 120 Silver (or 1.2 Gold)
- **Requirements:** Tier 3+ (Mild steel or better)
- **Effect:** +60% temperature limit, excellent thermal shock resistance
- **Maintenance:** More durable, replacement every 200 hours

**Mullite-Zirconia Lining** *(Advanced Refractory)*
- **Multiplier:** 1.9x
- **Max Operating Temp:** 2,072°C (3,762°F)
- **Historical Context:** Modern advanced ceramics
- **Composition:** Alumina-zirconia composite
- **Cost:** 5 Gold + 20 components
- **Requirements:** Tier 5+ (Blast furnace or better)
- **Effect:** +90% temperature limit, superior slag resistance
- **Maintenance:** Replacement every 300 hours

**Magnesia Lining** *(Super Refractory)*
- **Multiplier:** 2.2x
- **Max Operating Temp:** 2,852°C (5,166°F)
- **Historical Context:** Modern steelmaking standard
- **Composition:** Magnesium oxide (MgO)
- **Cost:** 15 Gold + 100 components + 50 mechanisms
- **Requirements:** Tier 6+ (Electric induction or better)
- **Effect:** +120% temperature limit, extreme heat resistance
- **Maintenance:** Replacement every 400 hours

**Silicon Carbide Lining** *(Extreme Applications)*
- **Multiplier:** 2.5x
- **Max Operating Temp:** 1,650°C (3,002°F) - *Note: Lower than magnesia but better thermal conductivity*
- **Historical Context:** Specialty applications, high thermal stress environments
- **Composition:** SiC ceramic
- **Cost:** 25 Gold + 200 components + 100 mechanisms
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
- Cost: 150 Silver (or 1.5 Gold)
- Effect: Allows higher operating temperatures safely, -30% heat decay
- Requirements: Mild steel shell or better

**Forced Air Injection** *(Tiers 4+)*
- Cost: 3 Gold + 25 mechanisms
- Effect: +25% heat generation from coal, enables blast furnace operations
- Requirements: Cupola design or better

**Temperature Monitoring** *(Quality of Life)*
- Cost: 50 Silver
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

# Steam Storage System
var stored_steam: float = 0.0
var max_stored_steam: float = 0.0  # Starts at 0, increased by storage upgrades
var storage_efficiency: float = 0.8  # 80% base, upgradeable to 90%, then 100%
var storage_tier: int = 0  # 0=none, 1=accumulator, 2=compressed, 3=multi-chamber, 4=hydraulic, 5=battery
var storage_diversion_percentage: float = 0.0  # % of steam production to divert to storage (0-100)
var auto_release_enabled: bool = false  # Unlocked at Tier 3
var auto_release_threshold: float = 1.8  # Auto-release when demand multiplier >= 1.8x (during high/critical demand)

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

# Demand System (Range-Based Multipliers)
var demand_state: String = "medium"  # Current demand state
var demand_multiplier: float = 1.05  # Current interpolated multiplier (starts at medium midpoint)
var target_range_min: float = 0.75  # Min multiplier for current state
var target_range_max: float = 1.35  # Max multiplier for current state
var interpolation_time: float = 0.0  # Time accumulator for sine wave
var interpolation_speed: float = 0.3  # Oscillation speed (~27s period)
var base_demand_rate: float = 5.0  # Base demand in lb/h

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
var demand_timer: float = 120.0  # Start at ~2 min; refreshes with triangular dist (1-5 min, avg ~2.5 min)
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

# (See process_heat implementation below, after morale boost system)

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
        # Triangular distribution: 1-5 minutes, weighted toward 2 minutes
        var rand1 = randf_range(60.0, 180.0)  # 1-3 minutes
        var rand2 = randf_range(60.0, 300.0)  # 1-5 minutes
        demand_timer = (rand1 + rand2) / 2.0  # Averages ~2.5 minutes

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

func _on_lead_by_example_button_pressed():
    # Manager helps workers - gives charisma XP, not strength
    if Level1Vars.stamina >= 1.0:
        Level1Vars.stamina -= 1.0

        # Small heat gain - workers do the heavy lifting now
        var heat_gained = 1.0 + (Global.charisma * 0.05)  # Charisma bonus instead of strength
        Level1Vars.current_heat += heat_gained

        # Charisma XP - you're leading by example, not just laboring
        Global.add_stat_exp("charisma", 0.4)

        # Temporary worker efficiency boost (5% for 30 seconds)
        apply_morale_boost(1.05, 30.0)

        # No explicit notification - let player discover the charisma gain

# Morale boost system (optional enhancement)
var morale_multiplier: float = 1.0
var morale_timer: float = 0.0

func apply_morale_boost(multiplier: float, duration: float):
    # Stacks with current boost, extends timer
    morale_multiplier = max(morale_multiplier, multiplier)
    morale_timer = max(morale_timer, duration)

func process_heat(delta):
    # Update morale timer
    if morale_timer > 0:
        morale_timer -= delta
        if morale_timer <= 0:
            morale_multiplier = 1.0

    # Worker generation (base + upgrades)
    var base_worker_heat = Level1Vars.stoker_count * (1.5 + Level1Vars.stoker_efficiency_lvl * 0.3)

    # Subtle charisma bonus - workers are slightly more efficient with good leadership
    # +1% per charisma level, max +50% at charisma 50 (not shown in UI)
    var charisma_multiplier = 1.0 + (Global.charisma * 0.01)

    # Apply morale boost (from Lead by Example)
    var worker_heat = base_worker_heat * charisma_multiplier * morale_multiplier
    Level1Vars.current_heat += worker_heat * delta

    # Heat decay
    var decay = 0.5 - (Level1Vars.fireman_count * 0.1)
    Level1Vars.current_heat = max(0, Level1Vars.current_heat - decay * delta)

    # Clamp to max
    Level1Vars.current_heat = min(Level1Vars.current_heat, Level1Vars.max_heat)

func update_ui():
    heat_bar.value = (Level1Vars.current_heat / Level1Vars.max_heat) * 100
    steam_bar.value = (Level1Vars.current_steam / Level1Vars.max_steam) * 100

    # Demand panel with color coding
    var demand_colors = {
        "zero": Color(0.2, 0.2, 0.5),  # Dark blue - opportunity to store
        "very_low": Color.CYAN,
        "low": Color.GREEN,
        "normal": Color.YELLOW,
        "high": Color.ORANGE,
        "critical": Color.RED
    }
    demand_panel.modulate = demand_colors[Level1Vars.demand_state]

    # Storage gauge (visible only if storage purchased)
    if Level1Vars.max_stored_steam > 0:
        storage_bar.visible = true
        storage_bar.value = (Level1Vars.stored_steam / Level1Vars.max_stored_steam) * 100
        storage_label.text = "Storage: %d / %d" % [int(Level1Vars.stored_steam), int(Level1Vars.max_stored_steam)]
    else:
        storage_bar.visible = false

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
    # Phase 5 additions - Steam Storage System
    "steam_accumulator_tank",
    "compressed_steam_reservoir",
    "multi_chamber_storage",
    "hydraulic_accumulator",
    "battery_bank",
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
- stored_steam, max_stored_steam, storage_efficiency, storage_tier
- storage_diversion_percentage, auto_release_enabled, auto_release_threshold
- demand_state, demand_multiplier
- Worker counts and levels
- Lifetime tracking variables

---

## Step-by-Step Implementation Checklist

### Phase 5A: Core Infrastructure (Foundation)

- [ ] **Update Level1Vars**
  - Add all furnace ownership variables
  - Add heat/steam variables
  - Add steam storage variables (stored_steam, max_stored_steam, storage_efficiency, storage_tier, storage_diversion_percentage, auto_release settings)
  - Add demand variables (including zero and very_low states)
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

### Phase 5H: Steam Storage System

- [ ] **Add storage variables to Level1Vars**
  - stored_steam, max_stored_steam
  - storage_efficiency, storage_tier
  - storage_diversion_percentage
  - auto_release_enabled, auto_release_threshold
  - Add to save/load dictionaries

- [ ] **Create storage upgrade tab in furnace upgrades popup**
  - Add Tab 5: Steam Storage
  - Add buttons for all 5 storage tiers
  - Show capacity, efficiency, and requirements
  - Implement purchase logic for each tier

- [ ] **Implement storage mechanics in owned_furnace.gd**
  - Add automatic overflow storage when main reservoir full
  - Apply storage efficiency (80%, 90%, 100%)
  - Add storage notification system
  - Test storage fill behavior during zero demand

- [ ] **Create storage control popup** (Tier 3+)
  - Design popup layout with diversion slider, release button, and auto-release controls
  - Add "Divert Production to Storage" slider (0-100%)
  - Connect slider to Level1Vars.storage_diversion_percentage
  - Add "Release 10%" button (clickable multiple times)
  - Add auto-release toggle checkbox
  - Add auto-release threshold slider (0-100%)
  - Implement release_stored_steam() function

- [ ] **Implement auto-release system**
  - Check conditions: high/critical demand + enabled + below threshold
  - Trigger automatic release
  - Show notification when auto-release activates
  - Test with various threshold settings

- [ ] **Add storage gauge to UI**
  - Add storage bar to left panel (visible when storage > 0)
  - Color: Cyan/blue gradient
  - Update in update_ui() function
  - Show efficiency percentage

- [ ] **Update demand state probabilities**
  - Add zero demand (10% chance)
  - Add very_low demand (10% chance)
  - Update demand reasons dictionary
  - Update color coding for zero/very_low states

- [ ] **Test storage system**
  - Test diversion slider at various percentages (0%, 25%, 50%, 100%)
  - Test diversion during different demand states
  - Test that diversion + overflow work together correctly
  - Test overflow during zero demand
  - Test manual release button (single click and multiple clicks)
  - Test auto-release during high demand
  - Test efficiency losses (80%, 90%, 100%)
  - Test with all 5 storage tiers

### Phase 5I: Polish & Balance

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

### Phase 5J: Integration & Testing

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
- Worker morale system (visible or hidden)
- **Worker events** - Leadership decision points that grant charisma XP
  - "Worker is tired" - Be kind vs push harder
  - "Worker injury" - Send to rest vs make them work
  - "Bonus request" - Grant vs refuse
  - Kind choices give charisma XP (still obscure, no explicit notification)
- Hiring screen with worker profiles

### Phase 6: Multiple Furnaces
- Own multiple furnaces
- Manage portfolio of operations
- Train network visualization
- Route optimization

### Integration with Other Systems
- Charisma gain from "Lead by Example" button (✅ included in Phase 5)
- Obscure charisma bonus on worker efficiency (✅ included in Phase 5)
- Worker event system for additional charisma growth (Phase 5.5)
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
- ⏸️ Worker event system (Phase 5.5 - additional charisma gain opportunities)
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
- Maintains leadership action as core mechanic
- Workers augment rather than replace player action
- Provides clear upgrade path
- Allows flexible playstyles (active vs idle)

### Why Obscure Charisma System?
- Encourages player experimentation and discovery
- Rewards engaged players who notice subtle efficiency gains
- Avoids "obvious stat grinding" - feels organic
- "Lead by Example" button gives value without explicit stat display
- Players discover: "My workers seem more efficient when I help them"
- Fits theme: Good leadership is subtle, not flashy

### Why Steam Storage System?
- **Captures the "wasted" potential** of zero/low demand periods
- **Creates strategic depth** - when to divert, when to release, manual vs auto
- **Active resource trading** - diversion slider lets players "buy low, sell high" with steam
- **Dual storage modes**: Passive (overflow) for idle play, Active (diversion) for engaged optimization
- **Rewards planning** - buying storage is an investment in crisis management and profit maximization
- **Thematic progression** - realistic industrial history from simple tanks to batteries
- **Smooth difficulty curve** - storage softens the punishing critical demand spikes
- **Encourages active play** - player can choose to manually optimize diversion and release timing
- **Enables idle play** - overflow + auto-release allows semi-afk gameplay
- **Market dynamics** - low demand periods become opportunities, not just downtime
- **Historical accuracy** - steam accumulators were real technology in Victorian era

### Economic Balance Philosophy
- Early game: "Lead by Example" gives small boost, workers are the main producers
- Mid game: Workers provide strong automation, charisma bonus becomes noticeable, storage becomes available
- Late game: Optimization and efficiency upgrades, high charisma significantly multiplies worker output, large storage buffers allow consistent performance
- Revenue should feel rewarding but not trivial
- Charisma bonus creates a "hidden efficiency curve" that rewards leadership engagement
- Storage system creates a "strategic resource management" layer

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
- High charisma level (from using "Lead by Example" frequently)
- Heat generation exceeds decay
- Steam rapidly fills reservoir
- Exceeds demand even during critical
- Excellent revenue consistently
- Workers produce ~25-50% more than a low-charisma player with same setup

### Scenario 4: Critical Demand Event
- Player has moderate steam reserves
- Critical demand triggered
- Steam drains quickly
- Player must use "Lead by Example" to boost workers
- Gains charisma XP while helping meet the crisis
- High reward if successful, high penalty if not
- Teaches player that active leadership matters

### Scenario 5: Active Diversion - Playing the Market
- Player has Multi-Chamber Storage (1,200 capacity) with diversion slider
- "Very Low Demand" state: trains descending Copper Ridge Pass (0.2x multiplier)
- Current revenue: 0.5 coins/sec (very low pay during downhill run)
- Player recognizes opportunity: "Low demand = cheap steam, time to store!"
- Opens Storage Controls, sets diversion slider to 50%
- Steam production: 20/sec → 10/sec to main (meets demand easily), 10/sec to storage
- Storage accumulates over 3 minutes: 0 → 300 → 600 → 900 steam
- Player continues normal operations, main steam stays healthy at 300-400
- Demand changes to "High" - "Climbing toward High Peak" (1.5x multiplier)
- Revenue jumps to 3.0 coins/sec!
- Player immediately: Sets diversion to 0%, clicks "Release 10%" 7 times
- 840 steam floods main reservoir (7 × 120)
- Player exceeds high demand for full duration, earns premium revenue
- Profit calculation: Stored steam when it was "cheap", sold it when "expensive"
- Player thinks: "I'm not just a furnace operator - I'm a steam trader!"

### Scenario 6: Storage System Mastery - Overflow Capture
- Player has Multi-Chamber Storage (1,200 capacity)
- Zero demand state triggers (train stopped for maintenance)
- Main reservoir fills to 500/500
- Workers continue producing ~8 steam/sec
- Overflow automatically diverts to storage with 80% efficiency
- Storage fills: 200... 400... 600... 800...
- Player sees: "Storage: 800 / 1,200" in cyan gauge
- Zero demand ends, switches to normal demand
- 5 minutes later: Critical demand spike!
- Main steam drops rapidly: 500 → 400 → 300 → 200
- Player has two choices:
  - **Manual:** Opens storage controls, clicks "Release 10%" button ~7 times (each click = 120 steam, 10% of 1,200 max)
  - **Auto:** Auto-release triggers at 60% threshold (300/500), releases all 800 stored steam
- Stored steam floods into main reservoir (all 800 steam released)
- Steam jumps: 200 → 1,000 (capped at 500, immediate consumption of excess)
- Player maintains "Excellent" performance throughout crisis
- Earns 2.5x revenue multiplier during critical demand
- Player thinks: "Storage was worth the 2,000 coin investment!"

---

## Conclusion

Phase 5 represents a major evolution in GoA's gameplay, transitioning from worker to owner and introducing sophisticated resource management. The steam demand system creates engaging moment-to-moment decisions, while worker management provides long-term progression. The steam storage system adds strategic depth and rewards planning, creating a satisfying loop of resource optimization. The obscure charisma system rewards engaged leadership without explicit stat grinding. The implementation is designed to be modular, testable, and extensible for future phases.

**Key Features:**
- Dynamic demand system (6 states: zero to critical, with uphill/downhill environmental factors)
- Triangular timer distribution (1-5 minutes, averaging ~2.5 minutes)
- Worker management (3 types: stokers, firemen, engineers)
- Steam storage system (5 tiers: accumulator to battery bank)
  - Active diversion slider (strategic resource allocation)
  - Passive overflow capture (automatic backup)
  - Manual and auto-release controls
- Obscure charisma progression (leadership rewards)
- Continuous revenue based on performance

**Estimated Implementation Time:** 10-14 hours (increased due to storage system)
**Complexity:** High (new systems, UI, balancing, strategic depth)
**Risk Level:** Medium (requires careful balancing, many integration points)
