# Phase 3: Prestige System Implementation Plan

## Overview
Transform dorm into prestige hub with escalating goodwill costs and a **skill tree** of 8 upgrades across 3 branches.

---

## Part 1: Core Prestige Data & Logic

### 1.1 Add Prestige Variables to Global.gd
- `goodwill_points: int = 0` (spendable currency)
- `lifetime_goodwill_earned: int = 0` (affects cost scaling)
- `goodwill_upgrades: Dictionary = {}` (owned upgrades)

### 1.2 Prestige Conversion Formula
- Constants: `GOODWILL_BASE_COST = 1000`, `GOODWILL_SCALING = 1.6`
- 1st goodwill: 1000 equipment
- 2nd goodwill: 1600 equipment
- 3rd goodwill: 2560 equipment
- At 3000 equipment → 2 goodwill ✓

### 1.3 Core Functions
```gdscript
func get_cost_for_next_goodwill() -> int
func calculate_available_goodwill() -> int
func get_progress_to_next_goodwill() -> float  # Returns 0.0-1.0
func execute_prestige()
```

### 1.4 Reset Function in Level1Vars.gd
```gdscript
func reset_for_prestige():
    # RESET:
    coal = 0
    coins = 0
    shovel_lvl = 0
    plow_lvl = 0
    auto_shovel_lvl = 0
    equipment_value = 0

    # Apply Burning Purpose (50 coins)
    if Global.has_goodwill_upgrade("burning_purpose"):
        coins = 50

    # KEEP (DO NOT RESET):
    # - overseer_bribe_count ✓
    # - auto_conversion_enabled ✓
    # - All stats, goodwill, story progress, unlocks
```

### 1.5 Save/Load Integration
- Add 3 fields: `goodwill_points`, `lifetime_goodwill_earned`, `goodwill_upgrades`
- Both LocalSaveManager and NakamaManager

---

## Part 2: Dorm UI - Left/Top Menu

### 2.1 Layout Order:
1. "Worker's Dorm" title panel
2. Break Timer panel (existing)
3. Coins panel (existing, "Coins: X")
4. **Goodwill counter** - NEW: "Goodwill: X" (same style as Coins)
5. **Progress bar** - NEW: Shows % to next goodwill (only when >50%)

### 2.2 Goodwill Counter Implementation
- Simple label (not panel like Break Timer)
- Format: "Goodwill: 0"
- Updates in _process()

### 2.3 Progress Bar Implementation
- Panel with ProgressBar inside
- Title: "Next Goodwill Progress"
- **Visibility**: `visible = progress >= 0.5`
- Shows equipment progress toward next goodwill point
- Example: 1500/2560 = 58% progress

---

## Part 3: Dorm UI - Right/Bottom Menu

### 3.1 Layout Order:
1. **"Donate Equipment"** - Opens prestige confirmation (conditional visibility)
2. **"Goodwill"** - Opens upgrade shop (was "Goodwill Upgrades")
3. "To Blackbore Bar" - Back button (existing)

### 3.2 Donate Equipment Button
- **Visibility**: Only when `calculate_available_goodwill() >= 1`
- **Text**: "Donate Equipment (+X)" where X = available goodwill
- Theme: PrimaryActionButton

### 3.3 Goodwill Button
- Always visible (can browse upgrades anytime)

---

## Part 4: Prestige Confirmation Popup

### 4.1 Content

**Title:** "Donate Your Equipment?"

**Message:**
```
"You've learned all you can from these tools.
Time to start fresh and push yourself harder.

The voice whispers: 'Sacrifice what you've built.
Prove your determination to escape.'

Goodwill you'll earn: X points"
```

**Details:**
```
Will donate all equipment and coins
```
(Simplified - don't list everything)

### 4.2 Buttons
- "Donate Equipment" → Confirm
- "Keep Working" → Cancel

---

## Part 5: Goodwill Skill Tree

### 5.1 Tree Structure (3 Branches)

**Branch 1: Combat/Production (Left)**
```
Iron Will (1)
  └─ Resilient Mind (4)
```

**Branch 2: Economy/Mood (Middle)**
```
Burning Purpose (2)
  └─ Leader's Presence (5)
       └─ Unshakable Resolve (8)
```

**Branch 3: Progression/Unlocks (Right)**
```
Experienced Hand (3)
  └─ Clear Vision (6)
       └─ Martyr's Strength (10)
```

### 5.2 Upgrade Definitions

```gdscript
const GOODWILL_UPGRADES = {
    # Branch 1: Combat/Production
    "iron_will": {
        "name": "Iron Will",
        "cost": 1,
        "description": "+15% mining power per click",
        "prerequisites": []
    },
    "resilient_mind": {
        "name": "Resilient Mind",
        "cost": 4,
        "description": "+15% to all production",
        "prerequisites": ["iron_will"]
    },

    # Branch 2: Economy/Mood
    "burning_purpose": {
        "name": "Burning Purpose",
        "cost": 2,
        "description": "Start each prestige with 50 coins",
        "prerequisites": []
    },
    "leaders_presence": {
        "name": "Leader's Presence",
        "cost": 5,
        "description": "Start with better mood",
        "prerequisites": ["burning_purpose"]
    },
    "unshakable_resolve": {
        "name": "Unshakable Resolve",
        "cost": 8,
        "description": "-25% mood fatigue rate",
        "prerequisites": ["leaders_presence"]
    },

    # Branch 3: Progression/Unlocks
    "experienced_hand": {
        "name": "Experienced Hand",
        "cost": 3,
        "description": "Unlock plow at shovel level 3 (instead of 5)",
        "prerequisites": []
    },
    "clear_vision": {
        "name": "Clear Vision",
        "cost": 6,
        "description": "+50% offline progress cap",
        "prerequisites": ["experienced_hand"]
    },
    "martyrs_strength": {
        "name": "Martyr's Strength",
        "cost": 10,
        "description": "Unlock the furnace",
        "prerequisites": ["clear_vision"]
    }
}
```

### 5.3 Upgrade Shop UI

**Layout: Linear List (Simpler)**
- Show all 8 upgrades in order (by branch)
- Each upgrade shows:
  - Name + Cost
  - Description
  - Prerequisites (if locked)
  - Status button (Purchase/Owned/Locked)
- Locked upgrades are grayed out with red text showing missing prereqs

### 5.4 Purchase Logic
```gdscript
func can_purchase_upgrade(upgrade_id: String) -> bool:
    var upgrade = GOODWILL_UPGRADES[upgrade_id]

    # Already owned?
    if Global.has_goodwill_upgrade(upgrade_id):
        return false

    # Can afford?
    if Global.goodwill_points < upgrade.cost:
        return false

    # Prerequisites met?
    for prereq in upgrade.prerequisites:
        if not Global.has_goodwill_upgrade(prereq):
            return false

    return true

func purchase_upgrade(upgrade_id: String):
    if not can_purchase_upgrade(upgrade_id):
        return

    Global.goodwill_points -= upgrade.cost
    Global.goodwill_upgrades[upgrade_id] = true
    Global.show_notification("Purchased: %s!" % upgrade.name)
    update_ui()
```

### 5.5 Upgrade Display States
- **Owned**: Green checkmark, "OWNED" text
- **Available**: Purchase button enabled, shows cost
- **Locked (Can't Afford)**: Button disabled, shows cost in red
- **Locked (Prerequisites)**: Button disabled, shows "Requires: [Prereq Name]" in red

---

## Part 6: Implement Upgrade Effects

### 6.1 Helper Functions
```gdscript
func has_goodwill_upgrade(upgrade_id: String) -> bool
func get_goodwill_click_bonus() -> float  # Returns 1.15 or 1.0
func get_goodwill_production_bonus() -> float  # Returns 1.15 or 1.0
```

### 6.2 Apply Effects

| Upgrade | Effect Location | Implementation |
|---------|----------------|----------------|
| Iron Will | Mining click code | Multiply by 1.15 |
| Resilient Mind | Auto-shovel production | Multiply by 1.15 |
| Burning Purpose | reset_for_prestige() | Set coins = 50 |
| Leader's Presence | Mood initialization | Increase starting mood |
| Unshakable Resolve | Mood decay | Multiply decay by 0.75 |
| Experienced Hand | shop.gd plow unlock | Change threshold to 3 |
| Clear Vision | Offline progress | Multiply cap by 1.5 |
| Martyr's Strength | Furnace access | Gate on upgrade |

---

## Part 7: Notifications & Polish

### 7.1 Notifications

**Dorm Unlock (at 3000 equipment):**
```
"Conditions are hard on the workers, you should check on them at the dorms."
```

**No Prestige Threshold Notification** (removed)

### 7.2 Progress Bar Behavior
- Calculate: `(current_equipment_since_last_cost) / cost_for_next_goodwill`
- Only show when >= 50%
- Example: At 1300 equipment (first goodwill earned at 1000)
  - Progress toward 2nd: (1300 - 1000) / 1600 = 18.75% → hidden
  - At 1800: (1800 - 1000) / 1600 = 50% → visible
  - At 2200: (2200 - 1000) / 1600 = 75% → visible

### 7.3 dorm.gd _process() Updates
```gdscript
func _process(_delta):
    # Update counters
    coins_label.text = "Coins: %d" % Level1Vars.coins
    goodwill_label.text = "Goodwill: %d" % Global.goodwill_points

    # Update progress bar
    var progress = Global.get_progress_to_next_goodwill()
    next_goodwill_progress.visible = progress >= 0.5
    if next_goodwill_progress.visible:
        progress_bar.value = progress * 100

    # Update donate button
    var available = Global.calculate_available_goodwill()
    donate_button.visible = available >= 1
    if donate_button.visible:
        donate_button.text = "Donate Equipment (+%d)" % available

    # Break timer (existing)
    update_break_timer()
```

### 7.4 Testing Checklist
- [ ] At 1000 equipment: 1 goodwill available
- [ ] At 2600 equipment: 2 goodwill available
- [ ] First prestige awards 2 goodwill, resets correctly
- [ ] overseer_bribe and auto_conversion persist ✓
- [ ] Burning Purpose gives 50 coins ✓
- [ ] Can only purchase upgrades with prerequisites met
- [ ] Tree structure enforced (can't skip tiers)
- [ ] Progress bar shows at 50%+ only
- [ ] Iron Will gives 15% click bonus
- [ ] Each effect applies correctly
- [ ] Save/load preserves everything
- [ ] UI works in portrait/landscape

---

## File Changes Summary

**Modified:**
1. `global.gd` - Add prestige system, skill tree, effects
2. `level1/level_1_vars.gd` - Add reset_for_prestige()
3. `level1/dorm.gd` - Add prestige UI, popups, tree logic
4. `level1/dorm.tscn` - Add goodwill counter, progress bar, 2 popups
5. `local_save_manager.gd` - Add 3 prestige fields
6. `nakama_client.gd` - Add 3 prestige fields
7. `level1/shop.gd` - Modify plow unlock (Experienced Hand)
8. (Mining scene) - Add Iron Will click bonus
9. (Auto-shovel) - Add Resilient Mind production bonus
10. (Mood system) - Add Leader's Presence and Unshakable Resolve
11. (Offline progress) - Add Clear Vision cap bonus
12. (Furnace) - Gate on Martyr's Strength

---

## Visual Skill Tree Reference

```
BRANCH 1          BRANCH 2              BRANCH 3
Combat            Economy               Progression
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Iron Will (1)     Burning Purpose (2)   Experienced Hand (3)
    ↓                    ↓                      ↓
Resilient         Leader's Presence (5)  Clear Vision (6)
Mind (4)                 ↓                      ↓
                  Unshakable             Martyr's Strength (10)
                  Resolve (8)
```

**Entry Points:** 3 starters (1, 2, 3 goodwill)
**Depth:** 2-3 tiers per branch
**Total Cost:** 43 goodwill to max all upgrades

---

## Estimated Effort
- Part 1 (Core Logic): 2.5 hours
- Part 2 (Left Menu + Progress): 1.5 hours
- Part 3 (Right Menu): 0.5 hours
- Part 4 (Confirmation): 1 hour
- Part 5 (Skill Tree Shop): 3 hours (prerequisites add complexity)
- Part 6 (Effects): 3 hours
- Part 7 (Polish): 1.5 hours

**Total: ~13 hours**

---

## Implementation Order
1. Core prestige logic (Part 1)
2. Donate Equipment button (Part 3.1) + confirmation popup (Part 4)
3. Left menu displays (Part 2) - counters and progress bar
4. Skill tree shop UI (Part 5) - tree structure
5. Upgrade effects (Part 6) - mechanics
6. Polish and testing (Part 7)

---

## Notes
- Prestige system uses escalating cost formula for long-term progression
- Skill tree creates meaningful choices and gates powerful upgrades
- Progress bar provides feedback without overwhelming notifications
- System preserves quality-of-life features (overseer bribe, auto-conversion)
- Ready to integrate with Phase 4 (Workers) and Phase 5 (Furnace)
