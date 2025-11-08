# Phase 3: Prestige System Implementation Plan

## Overview
Transform dorm into prestige hub with escalating Reputation costs and a **visual skill tree** of 16 upgrades with forking paths, convergence nodes, and node-based UI.

---

## Part 1: Core Prestige Data & Logic

### 1.1 Add Prestige Variables to Global.gd
- `reputation_points: int = 0` (spendable currency)
- `lifetime_reputation_earned: int = 0` (affects cost scaling)
- `reputation_upgrades: Dictionary = {}` (owned upgrades)

### 1.2 Prestige Conversion Formula
- Constants: `REPUTATION_BASE_COST = 1000`, `REPUTATION_SCALING = 1.6`

### 1.3 Core Functions
```gdscript
func get_cost_for_next_reputation() -> int
func calculate_available_reputation() -> int
func get_progress_to_next_reputation() -> float  # Returns 0.0-1.0
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

    # Apply starting resource upgrades (example)
    # Replace with actual upgrade IDs when finalized
    # if Global.has_reputation_upgrade("starting_coins_upgrade"):
    #     coins = 50

    # KEEP (DO NOT RESET):
    # - overseer_bribe_count ✓
    # - auto_conversion_enabled ✓
    # - All stats, reputation, story progress, unlocks
```

### 1.5 Save/Load Integration
- Add 3 fields: `reputation_points`, `lifetime_reputation_earned`, `reputation_upgrades`
- Both LocalSaveManager and NakamaManager

---

## Part 2: Dorm UI - Left/Top Menu

### 2.1 Layout Order:
1. "Worker's Dorm" title panel
2. Break Timer panel (existing)
3. Coins panel (existing, "Coins: X")
4. **Reputation counter** - NEW: "Reputation: X" (same style as Coins)
5. **Progress bar** - NEW: Shows % to next reputation (only when >50%)

### 2.2 Reputation Counter Implementation
- Simple label (not panel like Break Timer)
- Format: "Reputation: 0"
- Updates in _process()

### 2.3 Progress Bar Implementation
- Panel with ProgressBar inside
- Title: "Next Reputation Progress"
- **Visibility**: `visible = progress >= 0.5`
- Shows equipment progress toward next reputation point
- Example: 1500/2560 = 58% progress

---

## Part 3: Dorm UI - Right/Bottom Menu

### 3.1 Layout Order:
1. **"Donate Equipment"** - Opens prestige confirmation (conditional visibility)
2. **"Reputation"** - Opens upgrade shop (was "Reputation Upgrades")
3. "To Blackbore Bar" - Back button (existing)

### 3.2 Donate Equipment Button
- **Visibility**: Only when `calculate_available_reputation() >= 1`
- **Text**: "Donate Equipment (+X)" where X = available reputation
- Theme: PrimaryActionButton

### 3.3 Reputation Button
- Always visible (can browse upgrades anytime)

---

## Part 4: Prestige Confirmation Popup

### 4.1 Content

**Title:** "Donate Your Equipment?"

**Message:**
```
"These tools have served you well, the other workers need them more than you. Time to start fresh.
You'll earn X Reputation"
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

## Part 5: Reputation Skill Tree

### 5.1 Tree Structure (16 Nodes, 5 Tiers)

**Forking Path Design:** Multiple entry points with convergence nodes requiring different prerequisite combinations.

```
TIER 1 (Entry Points - Cost 1 each)
├─ Skill_A1 (1) - [Placeholder: Combat/Click path]
├─ Skill_B1 (1) - [Placeholder: Economy/Coins path]
└─ Skill_C1 (1) - [Placeholder: Production/Auto path]

TIER 2 (Cost 2-3)
├─ Skill_A2 (2) ← requires Skill_A1
├─ Skill_B2 (2) ← requires Skill_B1
├─ Skill_C2 (2) ← requires Skill_C1
└─ Skill_AB2 (3) ← requires Skill_A1 OR Skill_B1 [CONVERGENCE]

TIER 3 (Cost 4-6)
├─ Skill_A3 (4) ← requires Skill_A2
├─ Skill_B3 (4) ← requires Skill_B2
├─ Skill_C3 (5) ← requires Skill_C2 AND Skill_AB2 [MULTI-PATH]
└─ Skill_ABC3 (6) ← requires Skill_AB2 AND Skill_C2 [CONVERGENCE]

TIER 4 (Cost 7-9)
├─ Skill_A4 (7) ← requires Skill_A3 OR Skill_B3 [FORK CONVERGENCE]
├─ Skill_B4 (8) ← requires Skill_B3 AND Skill_C3 [MULTI-PATH]
└─ Skill_C4 (9) ← requires Skill_A3 AND Skill_ABC3 [MULTI-PATH]

TIER 5 (Capstones - Cost 10-12)
├─ Skill_Ultimate1 (10) ← requires Skill_A4 AND Skill_B4 [ULTIMATE]
└─ Skill_Ultimate2 (12) ← requires Skill_B4 AND Skill_C4 [ULTIMATE]
```

**Key Features:**
- 3 entry paths (A, B, C)
- 7 convergence nodes with multiple prerequisites
- 2 OR-gate nodes (alternative paths)
- Forces strategic choices and prevents pure linear progression
- **Total Cost:** 77 reputation to unlock all

### 5.2 Upgrade Definitions

**NOTE:** These are placeholder skills. Replace names, descriptions, and effects as needed.

```gdscript
const REPUTATION_UPGRADES = {
    # TIER 1 - Entry Points (Cost 1)
    "skill_a1": {
        "name": "Skill A1",
        "cost": 1,
        "description": "[Placeholder: Combat/Click focus upgrade]",
        "prerequisites": []
    },
    "skill_b1": {
        "name": "Skill B1",
        "cost": 1,
        "description": "[Placeholder: Economy/Coins focus upgrade]",
        "prerequisites": []
    },
    "skill_c1": {
        "name": "Skill C1",
        "cost": 1,
        "description": "[Placeholder: Production/Auto focus upgrade]",
        "prerequisites": []
    },

    # TIER 2 (Cost 2-3)
    "skill_a2": {
        "name": "Skill A2",
        "cost": 2,
        "description": "[Placeholder upgrade]",
        "prerequisites": ["skill_a1"]
    },
    "skill_b2": {
        "name": "Skill B2",
        "cost": 2,
        "description": "[Placeholder upgrade]",
        "prerequisites": ["skill_b1"]
    },
    "skill_c2": {
        "name": "Skill C2",
        "cost": 2,
        "description": "[Placeholder upgrade]",
        "prerequisites": ["skill_c1"]
    },
    "skill_ab2": {
        "name": "Skill AB2",
        "cost": 3,
        "description": "[Placeholder: Convergence skill]",
        "prerequisites": ["skill_a1", "skill_b1"],  # OR logic - needs at least one
        "prerequisite_mode": "any"  # Special flag for OR logic
    },

    # TIER 3 (Cost 4-6)
    "skill_a3": {
        "name": "Skill A3",
        "cost": 4,
        "description": "[Placeholder upgrade]",
        "prerequisites": ["skill_a2"]
    },
    "skill_b3": {
        "name": "Skill B3",
        "cost": 4,
        "description": "[Placeholder upgrade]",
        "prerequisites": ["skill_b2"]
    },
    "skill_c3": {
        "name": "Skill C3",
        "cost": 5,
        "description": "[Placeholder: Multi-path skill]",
        "prerequisites": ["skill_c2", "skill_ab2"]  # AND logic - needs both
    },
    "skill_abc3": {
        "name": "Skill ABC3",
        "cost": 6,
        "description": "[Placeholder: Convergence skill]",
        "prerequisites": ["skill_ab2", "skill_c2"]  # AND logic
    },

    # TIER 4 (Cost 7-9)
    "skill_a4": {
        "name": "Skill A4",
        "cost": 7,
        "description": "[Placeholder: Fork convergence skill]",
        "prerequisites": ["skill_a3", "skill_b3"],  # OR logic
        "prerequisite_mode": "any"
    },
    "skill_b4": {
        "name": "Skill B4",
        "cost": 8,
        "description": "[Placeholder: Multi-path skill]",
        "prerequisites": ["skill_b3", "skill_c3"]  # AND logic
    },
    "skill_c4": {
        "name": "Skill C4",
        "cost": 9,
        "description": "[Placeholder: Multi-path skill]",
        "prerequisites": ["skill_a3", "skill_abc3"]  # AND logic
    },

    # TIER 5 - Capstones (Cost 10-12)
    "skill_ultimate1": {
        "name": "Skill Ultimate 1",
        "cost": 10,
        "description": "[Placeholder: Ultimate capstone]",
        "prerequisites": ["skill_a4", "skill_b4"]  # AND logic
    },
    "skill_ultimate2": {
        "name": "Skill Ultimate 2",
        "cost": 12,
        "description": "[Placeholder: Ultimate capstone]",
        "prerequisites": ["skill_b4", "skill_c4"]  # AND logic
    }
}
```

### 5.3 Visual Skill Tree UI

**Implementation:** Popup panel within dorm.tscn (not separate scene)

#### 5.3.1 Scene Hierarchy
```
dorm.tscn
└─ ReputationSkillTreePopup (Panel - initially hidden)
    ├─ VBoxContainer
    │   ├─ HBoxContainer (header)
    │   │   ├─ Label "Reputation Skills"
    │   │   ├─ Label "Points: X"
    │   │   └─ Button "×" (close)
    │   │
    │   ├─ HBoxContainer/VBoxContainer (main - responsive)
    │   │   ├─ ScrollContainer (skill tree canvas - 60-70%)
    │   │   │   └─ Control (SkillTreeCanvas)
    │   │   │       ├─ Script: skill_tree_canvas.gd (draws connection lines)
    │   │   │       └─ Children: 16 SkillNode panels
    │   │   │
    │   │   └─ Panel (detail panel - 30-40%)
    │   │       └─ VBoxContainer
    │   │           ├─ TextureRect (skill icon - 128x128)
    │   │           ├─ Label (skill name)
    │   │           ├─ Label (cost badge)
    │   │           ├─ Label (description)
    │   │           ├─ VBoxContainer (prerequisites list)
    │   │           └─ Button (purchase) or Label ("OWNED")
    │   │
    │   └─ HBoxContainer (legend)
    │       ├─ ColorRect (gray) + Label "Locked"
    │       ├─ ColorRect (blue) + Label "Available"
    │       └─ ColorRect (orange) + Label "Owned"
```

**Responsive Layout:**
- **Landscape:** HBoxContainer with detail panel on right
- **Portrait:** VBoxContainer with detail panel on bottom

#### 5.3.2 Node Visual Design

**Node Structure (80x80px Panel):**
```
┌────────────────┐
│  [Icon 64x64]  │  ← Skill icon image
│                │
│  Name (small)  │  ← Truncated name
│  Cost: X       │  ← Cost badge (top-right corner)
└────────────────┘
```

**Node States (color-coded borders):**
- **Locked (Gray):** `Color(0.3, 0.3, 0.3)` - Prerequisites not met
- **Available (Dark Blue):** `Color(0.2, 0.4, 0.8)` - Can purchase, shows glow effect
- **Owned (Dark Orange):** `Color(0.8, 0.4, 0.1)` - Purchased, shows checkmark overlay
- **Insufficient Funds (Red):** `Color(0.8, 0.2, 0.0)` - Prerequisites met but can't afford
- **Selected (White):** Additional white border/glow when node is selected

#### 5.3.3 Connection Lines

**Drawing System:** Use `_draw()` in SkillTreeCanvas Control node

```gdscript
# In skill_tree_canvas.gd
func _draw():
    for upgrade_id in REPUTATION_UPGRADES:
        var upgrade = REPUTATION_UPGRADES[upgrade_id]
        var node_pos = get_node_position(upgrade_id)

        for prereq_id in upgrade.prerequisites:
            var prereq_pos = get_node_position(prereq_id)
            var line_color = get_line_color(prereq_id, upgrade_id)
            var line_width = 3.0

            # Draw line from prereq to current
            draw_line(prereq_pos, node_pos, line_color, line_width)

            # Draw arrow head at endpoint
            draw_arrow_head(node_pos, prereq_pos, line_color)
```

**Line States:**
- **Inactive (Gray):** `Color(0.4, 0.4, 0.4)`, width 2 - Parent not owned
- **Active (Dark Blue):** `Color(0.2, 0.4, 0.8)`, width 3 - Parent owned, child locked
- **Complete (Dark Orange):** `Color(0.8, 0.4, 0.1)`, width 2 - Both owned

**Line Types:**
- **Solid lines:** AND prerequisites (all must be met)
- **Dashed lines:** OR prerequisites (at least one must be met)

#### 5.3.4 Layout & Positioning

**Grid-Based System:**
```gdscript
const TIER_X_POSITIONS = [50, 200, 350, 500, 650]  # 5 tiers (columns)
const ROW_Y_POSITIONS = [50, 150, 250, 350]  # 4 rows

var node_positions = {
    # TIER 1
    "skill_a1": Vector2(TIER_X_POSITIONS[0], ROW_Y_POSITIONS[0]),
    "skill_b1": Vector2(TIER_X_POSITIONS[0], ROW_Y_POSITIONS[1]),
    "skill_c1": Vector2(TIER_X_POSITIONS[0], ROW_Y_POSITIONS[3]),

    # TIER 2
    "skill_a2": Vector2(TIER_X_POSITIONS[1], ROW_Y_POSITIONS[0]),
    "skill_b2": Vector2(TIER_X_POSITIONS[1], ROW_Y_POSITIONS[1]),
    "skill_c2": Vector2(TIER_X_POSITIONS[1], ROW_Y_POSITIONS[3]),
    "skill_ab2": Vector2(TIER_X_POSITIONS[1], ROW_Y_POSITIONS[2]),

    # (Continue for all 16 nodes...)
}
```

**Spacing:**
- Horizontal gap: 150px between tiers
- Vertical gap: 100px between rows
- Total tree size: ~700px wide × 400px tall

#### 5.3.5 Interaction (Mobile-Friendly)

**No Hover - Click/Tap Only:**

```gdscript
# On each SkillNode panel
func _on_skill_node_clicked():
    # Deselect previous
    if skill_tree.selected_node:
        skill_tree.selected_node.set_selected(false)

    # Select this node
    skill_tree.selected_node = self
    set_selected(true)

    # Show detail panel
    skill_tree.show_detail_panel(upgrade_id)

func set_selected(is_selected: bool):
    if is_selected:
        # Add white border/glow
        modulate = Color(1.2, 1.2, 1.2)
    else:
        # Normal state
        modulate = Color(1, 1, 1)
```

**Detail Panel Display:**
- Shows when a node is clicked
- Displays: large icon, full description, prerequisites with status, purchase button
- Purchase button only enabled if can_purchase_upgrade() returns true
- Clicking outside tree or on background deselects node

**Path Highlighting (Optional):**
When node selected:
- Highlight all prerequisite paths backward (blue)
- Highlight all dependent paths forward (orange)
- Dim when deselected

### 5.4 Purchase Logic

**Updated to handle OR prerequisites:**

```gdscript
func can_purchase_upgrade(upgrade_id: String) -> bool:
    var upgrade = REPUTATION_UPGRADES[upgrade_id]

    # Already owned?
    if Global.has_reputation_upgrade(upgrade_id):
        return false

    # Can afford?
    if Global.reputation_points < upgrade.cost:
        return false

    # Prerequisites met?
    var prereq_mode = upgrade.get("prerequisite_mode", "all")  # Default to AND logic

    if prereq_mode == "any":
        # OR logic - at least one prerequisite must be met
        if upgrade.prerequisites.is_empty():
            return true

        for prereq in upgrade.prerequisites:
            if Global.has_reputation_upgrade(prereq):
                return true  # Found at least one
        return false  # None met

    else:
        # AND logic - all prerequisites must be met
        for prereq in upgrade.prerequisites:
            if not Global.has_reputation_upgrade(prereq):
                return false
        return true

func purchase_upgrade(upgrade_id: String):
    if not can_purchase_upgrade(upgrade_id):
        return

    Global.reputation_points -= upgrade.cost
    Global.reputation_upgrades[upgrade_id] = true
    Global.show_notification("Purchased: %s!" % upgrade.name)

    # Refresh visual tree
    update_tree_visuals()
```

### 5.5 Node Visual States

**Visual Feedback System:**

```gdscript
func update_node_visual(node: Panel, upgrade_id: String):
    var upgrade = REPUTATION_UPGRADES[upgrade_id]
    var is_owned = Global.has_reputation_upgrade(upgrade_id)
    var can_purchase = can_purchase_upgrade(upgrade_id)
    var prereqs_met = check_prerequisites_met(upgrade_id)

    # Determine state
    if is_owned:
        # OWNED - Dark Orange border + checkmark
        set_node_border(node, Color(0.8, 0.4, 0.1))
        show_checkmark(node, true)
        node.tooltip_text = "Owned"

    elif can_purchase:
        # AVAILABLE - Dark Blue border + glow
        set_node_border(node, Color(0.2, 0.4, 0.8))
        add_glow_effect(node)
        node.tooltip_text = "Click to view"

    elif prereqs_met:
        # INSUFFICIENT FUNDS - Red border
        set_node_border(node, Color(0.8, 0.2, 0.0))
        node.tooltip_text = "Need %d reputation" % upgrade.cost

    else:
        # LOCKED - Gray border
        set_node_border(node, Color(0.3, 0.3, 0.3))
        node.tooltip_text = "Prerequisites not met"
```

**State Progression:** Gray → Blue → Orange (player's natural progression path)

---

## Part 6: Implement Upgrade Effects

**NOTE:** Since upgrades are placeholders, implement specific effects when finalizing skill names and purposes.

### 6.1 Helper Functions
```gdscript
# In Global.gd
func has_reputation_upgrade(upgrade_id: String) -> bool:
    return reputation_upgrades.get(upgrade_id, false)

func get_reputation_multiplier(category: String) -> float:
    # Example: Check for specific upgrades and return multiplier
    # Replace with actual upgrade IDs when finalized
    var multiplier = 1.0

    # if has_reputation_upgrade("skill_a1"):
    #     multiplier *= 1.15

    return multiplier
```

### 6.2 Apply Effects (Template)

When implementing specific upgrades, apply effects in relevant locations:

| Effect Type | Location | Example Implementation |
|-------------|----------|------------------------|
| Click bonus | Mining click code | `value *= Global.get_reputation_multiplier("click")` |
| Production bonus | Auto-production | `value *= Global.get_reputation_multiplier("production")` |
| Starting resources | reset_for_prestige() | Check upgrade and set initial values |
| Unlocks | Shop/UI code | Gate features with `if Global.has_reputation_upgrade()` |
| Stat bonuses | Relevant systems | Apply multipliers or modifiers |

---

## Part 7: Notifications & Polish

### 7.1 Notifications

**Dorm Unlock (at 3000 equipment):**
```
"Conditions are hard on the workers, you should check on them at the dorms."
```

**No Prestige Threshold Notification** (removed)

### 7.2 Progress Bar Behavior
- Calculate: `(current_equipment_since_last_cost) / cost_for_next_reputation`
- Only show when >= 50%
- Example: At 1300 equipment (first reputation earned at 1000)
  - Progress toward 2nd: (1300 - 1000) / 1600 = 18.75% → hidden
  - At 1800: (1800 - 1000) / 1600 = 50% → visible
  - At 2200: (2200 - 1000) / 1600 = 75% → visible

### 7.3 dorm.gd _process() Updates
```gdscript
func _process(_delta):
    # Update counters
    coins_label.text = "Coins: %d" % Level1Vars.coins
    reputation_label.text = "Reputation: %d" % Global.reputation_points

    # Update progress bar
    var progress = Global.get_progress_to_next_reputation()
    next_reputation_progress.visible = progress >= 0.5
    if next_reputation_progress.visible:
        progress_bar.value = progress * 100

    # Update donate button
    var available = Global.calculate_available_reputation()
    donate_button.visible = available >= 1
    if donate_button.visible:
        donate_button.text = "Donate Equipment (+%d)" % available

    # Break timer (existing)
    update_break_timer()
```

### 7.4 Testing Checklist

**Core Prestige:**
- [ ] At 1000 equipment: 1 reputation available
- [ ] At 2600 equipment: 2 reputation available
- [ ] First prestige awards 2 reputation, resets correctly
- [ ] overseer_bribe and auto_conversion persist ✓
- [ ] Progress bar shows at 50%+ only
- [ ] Save/load preserves all reputation data

**Skill Tree Logic:**
- [ ] Can purchase tier-1 skills immediately (A1, B1, C1)
- [ ] Can only purchase skills with prerequisites met
- [ ] OR prerequisites work (can buy AB2 with either A1 or B1)
- [ ] AND prerequisites work (need both prereqs for most nodes)
- [ ] Can't skip tiers or bypass prerequisites
- [ ] Purchasing updates node visuals immediately
- [ ] Connection lines update colors correctly

**Visual Tree UI:**
- [ ] Skill tree popup opens/closes correctly
- [ ] All 16 nodes visible and positioned correctly
- [ ] Connection lines draw between correct nodes
- [ ] Node borders show correct colors (gray/blue/orange/red)
- [ ] Clicking node shows detail panel
- [ ] Detail panel shows correct info (icon, name, cost, prereqs)
- [ ] Purchase button only enabled when can afford
- [ ] UI works in portrait/landscape modes
- [ ] Mobile tap interaction works correctly

**Upgrade Effects (when implemented):**
- [ ] Each placeholder skill can be replaced with real effects
- [ ] Effects apply correctly after prestige
- [ ] Multiple upgrades stack properly

---

## File Changes Summary

**Modified:**
1. `global.gd` - Add prestige system with 16-skill tree, OR/AND prerequisite logic
2. `level1/level_1_vars.gd` - Add reset_for_prestige()
3. `level1/dorm.gd` - Add prestige UI, popup show/hide logic, skill tree interaction
4. `level1/dorm.tscn` - Add reputation counter, progress bar, prestige confirmation popup, visual skill tree popup
5. `local_save_manager.gd` - Add 3 prestige fields (reputation_points, lifetime_reputation_earned, reputation_upgrades)
6. `nakama_client.gd` - Add 3 prestige fields

**Created:**
7. `skill_tree_canvas.gd` - Script for drawing connection lines between skill nodes

**To Be Modified (when finalizing skill effects):**
8. `level1/shop.gd` - Apply any unlock-based upgrades
9. (Mining scene) - Apply click bonus upgrades
10. (Auto-production) - Apply production bonus upgrades
11. (Other systems) - Apply relevant upgrade effects

---

## Visual Skill Tree Reference

```
TIER 1        TIER 2          TIER 3         TIER 4         TIER 5
(Cost 1)      (Cost 2-3)      (Cost 4-6)     (Cost 7-9)     (Cost 10-12)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A1 (1) ────→ A2 (2) ────→ A3 (4) ────┬──→ A4 (7) ────┬──→ Ult1 (10)
                                      │     ╱         │
                                      │    ╱          │
B1 (1) ────→ B2 (2) ────→ B3 (4) ────┼──→╱───→ B4 (8)┼──→ Ult2 (12)
    ╲                         ╲       │           │   │     ╱
     ╲                         ╲      │           │   │    ╱
      ╲─→ AB2 (3) ────┬──→ ABC3 (6)──┘           │   └───┘
                      │                           │
C1 (1) ────→ C2 (2)──┴──→ C3 (5) ────────────────┘

Legend:
─→  Single prerequisite (AND if multiple lines converge)
╱   Alternative prerequisite (OR logic)
```

**Structure:**
- **Entry Points:** 3 independent tier-1 skills (A1, B1, C1)
- **Convergence Nodes:** AB2, C3, ABC3, A4, B4, C4, Ult1, Ult2
- **OR Gates:** AB2 (needs A1 OR B1), A4 (needs A3 OR B3)
- **Total Cost:** 77 reputation to max all upgrades
- **Skill Count:** 16 total nodes

---

## Implementation Order
1. Core prestige logic (Part 1)
2. Donate Equipment button (Part 3.1) + confirmation popup (Part 4)
3. Left menu displays (Part 2) - counters and progress bar
4. Visual skill tree UI (Part 5) - tree structure, nodes, lines, interaction
5. Upgrade effects (Part 6) - placeholder mechanics
6. Polish and testing (Part 7)

---

## Estimated Effort
- Part 1 (Core Logic): 2.5 hours
- Part 2 (Left Menu + Progress): 1.5 hours
- Part 3 (Right Menu): 0.5 hours
- Part 4 (Confirmation): 1 hour
- Part 5 (Visual Skill Tree): 6 hours
  - Tree structure & 16 upgrades: 1.5h
  - Visual UI implementation: 2h
  - Connection line drawing: 1.5h
  - Node interaction & detail panel: 1h
- Part 6 (Effects - Placeholder): 1.5 hours
- Part 7 (Polish): 1.5 hours

**Total: ~15.5 hours**

**Note:** Visual tree adds complexity but creates better UX. Time may vary based on polish level desired.

---

## Notes
- Prestige system uses escalating cost formula for long-term progression
- 16-node skill tree with forking paths creates meaningful strategic choices
- OR/AND prerequisites enable multiple valid progression routes
- Visual node-based UI with color-coded states provides clear feedback
- Mobile-friendly tap interaction (no hover required)
- Progress bar provides feedback without overwhelming notifications
- System preserves quality-of-life features (overseer bribe, auto-conversion)
- Placeholder skills allow easy customization later
- Ready to integrate with Phase 4 (Workers) and Phase 5 (Furnace)

