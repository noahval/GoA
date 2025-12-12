# Zone Out & Focus System - Copper Era Idle Mechanics

**Status:** Planning
**Created:** 2025-11-25
**Phase:** Phase 1 (Copper Era)
**Goal:** Enable transition from active clicking to idle mechanics within 1-2 hours of gameplay

---

## Overview

The player represents conscious effort. The character develops the ability to work on "autopilot" through psychological adaptation to repetitive labor - **"zoning out"**.

---

## Core Mechanics

### 1. Repetitions (Unlock Currency)

**Purpose:** Tracks lifetime shoveling experience

```gdscript
# In level-1-vars.gd
var shovel_repetitions = 0  # Increments with every shovel action
```

**Properties:**
- Increments on every manual shovel click
- Increments on every zone out shovel
- Never decreases
- Permanent progression metric
- Used to unlock zone out abilities

**Display:** Small counter - `Shovels: 3,847`

---

### 2. Zone Out (Passive Generation)

**Purpose:** Automatic coal generation that happens in background

**Key Characteristics:**
- ✅ Always active once unlocked (no toggling)
- ✅ Invisible to player (no UI elements)
- ✅ No management required
- ✅ Stacks with manual clicking
- ✅ Scales with stats (STR, CON, DEX, WIS)

**Implementation:**
```gdscript
# Calculate total zone out rate based on unlocks
func get_zone_out_rate() -> float:
    var rate = 0.0

    # Rhythm path (speed)
    if shovel_repetitions >= 500:
        rate += 0.5
    if shovel_repetitions >= 2000:
        rate += 1.5 + (0.3 * Global.dexterity)
    if shovel_repetitions >= 5000:
        rate += 3.0 + (0.5 * Global.dexterity)

    # Endurance path (sustainability)
    if shovel_repetitions >= 750:
        rate += 1.0
    if shovel_repetitions >= 3000:
        rate += 2.0 + (0.3 * Global.constitution)
    if shovel_repetitions >= 7500:
        rate += 4.0 + (0.5 * Global.constitution)

    # Dissociation path (efficiency)
    if shovel_repetitions >= 1000:
        rate += 0.5
    if shovel_repetitions >= 4000:
        rate += 2.0 + (0.8 * Global.wisdom)
    if shovel_repetitions >= 10000:
        rate += 4.0 + (1.2 * Global.wisdom)

    return rate

# In _process(delta)
func _process(delta):
    # Zone out generates coal automatically
    coal += get_zone_out_rate() * delta
```

---

### 3. Focus (Offline Earnings)

**Purpose:** Resource that enables offline progression

```gdscript
# In level_1_vars.gd
var focus = 0.0           # Current accumulated focus
var last_session_time = 0 # Unix timestamp of last session
```

**Mechanics:**
- Accumulates while playing (passive)
- Consumed when offline to generate coal
- Enables respectful offline earnings
- No UI display during gameplay (silent accumulation)
- Only visible in offline earnings popup

**Focus Generation Rate:**
```gdscript
func get_focus_rate() -> float:
    var base = 0.5  # Base: 0.5 focus per second

    # Dissociation path increases focus generation
    if shovel_repetitions >= 1000:
        base *= 1.5
    if shovel_repetitions >= 4000:
        base *= 2.0
    if shovel_repetitions >= 10000:
        base *= 3.0

    return base
```

**Max Focus Cap:**
```gdscript
func get_max_focus() -> float:
    var cap = 0.0

    # Endurance path increases focus capacity
    if shovel_repetitions >= 750:
        cap = 50.0
    if shovel_repetitions >= 3000:
        cap = 100.0
    if shovel_repetitions >= 7500:
        cap = 200.0

    return cap
```

**Offline Earnings Calculation:**
```gdscript
func calculate_offline_earnings():
    var time_away_seconds = Time.get_unix_time_from_system() - last_session_time
    var time_away_hours = time_away_seconds / 3600.0

    # Focus determines how long we earned offline
    var max_focus_val = get_max_focus()
    if max_focus_val == 0:
        return  # No offline earnings yet

    # 100 focus = 2 hours of offline earnings
    var focus_hours = (focus / 100.0) * 2.0
    var effective_hours = min(time_away_hours, focus_hours)

    if effective_hours < 0.1:
        return  # Less than 6 minutes, skip popup

    # Calculate earnings with efficiency modifier
    var offline_efficiency = 0.5  # Base 50% efficiency
    if shovel_repetitions >= 10000:
        offline_efficiency = 0.75  # 75% efficiency at max tier

    var coal_earned = get_zone_out_rate() * effective_hours * 3600 * offline_efficiency

    # Show simple popup
    show_offline_popup(effective_hours, coal_earned)

    # Add coal and consume focus
    coal += coal_earned
    focus = max(0, focus - (effective_hours / 2.0 * 100.0))
```

---

## Progression Unlocks

### The Three Paths

Zone out abilities unlock automatically based on repetitions. No player choice required - all paths unlock naturally through play.

#### Path 1: RHYTHM (Speed-Focused)
*"Your body knows the tempo."*

| Repetitions | Tier | Effect | Flavor Text |
|-------------|------|--------|-------------|
| 500 | Rhythm I | +0.5 coal/sec | "Your hands move without thought..." |
| 2,000 | Rhythm II | +1.5 coal/sec + (0.3 × DEX) | "Lift, turn, throw. The rhythm is eternal." |
| 5,000 | Rhythm III | +3 coal/sec + (0.5 × DEX) | "The motion is perfect. Mechanical. Inhuman." |

**Scales with:** Dexterity
**Theme:** Speed and precision through repetition

---

#### Path 2: ENDURANCE (Sustainability-Focused)
*"You can do this forever."*

| Repetitions | Tier | Effect | Flavor Text |
|-------------|------|--------|-------------|
| 750 | Endurance I | +1 coal/sec, max focus: 50 | "The work feels easier now..." |
| 3,000 | Endurance II | +2 coal/sec + (0.3 × CON), max focus: 100 | "There is no end. Only continuation." |
| 7,500 | Endurance III | +4 coal/sec + (0.5 × CON), max focus: 200 | "You could do this in your sleep. Maybe you are." |

**Scales with:** Constitution
**Theme:** Tireless endurance, enables offline earnings
**Special:** Increases max focus capacity

---

#### Path 3: DISSOCIATION (Efficiency-Focused)
*"You are no longer required."*

| Repetitions | Tier | Effect | Flavor Text |
|-------------|------|--------|-------------|
| 1,000 | Dissociation I | +0.5 coal/sec, focus rate: 1.5x | "Your mind wanders..." |
| 4,000 | Dissociation II | +2 coal/sec + (0.8 × WIS), focus rate: 2x | "Sometimes you forget you exist. The quota is always met." |
| 10,000 | Dissociation III | +4 coal/sec + (1.2 × WIS), focus rate: 3x, offline efficiency: 75% | "There is no you. There is only the work." |

**Scales with:** Wisdom (ironically - wisdom to detach)
**Theme:** Mental separation from labor
**Special:** Increases focus generation rate and offline efficiency

---

## Complete Unlock Table

| Reps | Unlock | Coal/Sec | Focus Effect | Approximate Time |
|------|--------|----------|--------------|------------------|
| 500 | Rhythm I | +0.5 | - | ~1 hour |
| 750 | Endurance I | +1.0 | Max: 50 | ~1.5 hours |
| 1,000 | Dissociation I | +0.5 | Rate: 1.5x | ~2 hours |
| 2,000 | Rhythm II | +1.5 + DEX×0.3 | - | ~3-4 hours |
| 3,000 | Endurance II | +2.0 + CON×0.3 | Max: 100 | ~5-6 hours |
| 4,000 | Dissociation II | +2.0 + WIS×0.8 | Rate: 2x | ~7-8 hours |
| 5,000 | Rhythm III | +3.0 + DEX×0.5 | - | ~9-10 hours |
| 7,500 | Endurance III | +4.0 + CON×0.5 | Max: 200 | ~12-15 hours |
| 10,000 | Dissociation III | +4.0 + WIS×1.2 | Rate: 3x, Offline: 75% | ~15-20 hours |

**Note:** Time estimates assume mix of active and passive play

---

## UI/UX Requirements

### Minimal UI Approach

**Philosophy:** System should feel good but stay invisible. Players discover it naturally.

#### What To Show:
1. **Repetitions counter** (small, unobtrusive)
   - Location: Top corner of furnace scene
   - Format: `Shovels: 3,847`
   - Purpose: Track progression, sense of mastery

2. **Offline earnings popup** (only on return from being offline)
   - Simple message with hours and coal earned
   - Auto-dismisses after a few seconds

#### What NOT To Show:
- ❌ Zone out rate display
- ❌ Focus meter during gameplay
- ❌ Path status/progression bars
- ❌ Detailed breakdowns
- ❌ "Enable/disable" toggles
- ❌ Zone out status indicator

### Offline Earnings Popup

**Format:**
```
╔════════════════════════════════════╗
║  You focused on shovelling for    ║
║  2 hours and shovelled 14,400     ║
║  coal while away.                 ║
╚════════════════════════════════════╝
```

**Alternative (more concise):**
```
╔════════════════════════════════════╗
║  While you were gone:             ║
║  +14,400 coal (2 hours focused)   ║
╚════════════════════════════════════╝
```

**Requirements:**
- Show effective hours focused (not total time away)
- Show coal earned
- Simple, clean, non-intrusive
- Auto-dismiss after 5 seconds or on click

---

## Notifications (Optional Flavor)

Subtle notifications when major tiers unlock. Keep minimal and atmospheric.

### Tier I Unlocks (Introduction)
- Rhythm I (500): *"Your hands move without thought..."*
- Endurance I (750): *"The work feels easier now..."*
- Dissociation I (1,000): *"Your mind wanders..."*

### Tier II Unlocks (Progression)
- Rhythm II (2,000): *"Lift, turn, throw. The rhythm is eternal."*
- Endurance II (3,000): *"There is no end. Only continuation."*
- Dissociation II (4,000): *"Sometimes you forget you exist."*

### Tier III Unlocks (Mastery)
- Rhythm III (5,000): *"The motion is perfect. Mechanical."*
- Endurance III (7,500): *"You could do this in your sleep."*
- Dissociation III (10,000): *"There is no you. There is only the work."*

**Implementation Note:** These are optional. Could be completely silent unlocks.

---

## Integration with Existing Systems

### Stats Integration

All zone out paths scale with different stats:

| Stat | Path | Effect |
|------|------|--------|
| **Dexterity** | Rhythm | Faster shoveling tempo |
| **Constitution** | Endurance | Sustained effort, longer focus |
| **Wisdom** | Dissociation | Efficient detachment, better focus generation |
| **Strength** | - | Could affect manual shovel power (not zone out) |

**Design Goal:** Make all stats valuable for different playstyles

### Existing Variables

Zone out affects existing coal economy:

```gdscript
# In level_1_vars.gd
var coal = 0.0  # Zone out adds to this automatically

# New variables to add:
var shovel_repetitions = 0
var focus = 0.0
var last_session_time = 0
```

### Scene Integration

**Furnace Scene ([level1/loading_screen.tscn](../level1/loading_screen.tscn)):**
- Add repetitions counter UI element
- Hook manual shovel actions to increment repetitions
- Process zone out generation in `_process(delta)`
- Process focus accumulation in `_process(delta)`

**Shop Scene ([level1/shop.gd](../level1/shop.gd)):**
- No changes needed (zone out doesn't require shop purchases)
- Could add optional "training" info panel (not upgrades)

**Global ([global.gd](../global.gd)):**
- Offline earnings calculation on game load
- Display offline earnings popup

---

## Player Experience Timeline

### Hour 0-1: Pure Manual Labor
- **Repetitions:** 0 → ~500
- **Experience:** Pure clicking, building muscle memory
- **Coal rate:** Manual only (~0.5-1 per click)
- **Realization:** "I'm getting better at this"

### Hour 1-2: First Zone Out
- **Repetitions:** 500 → ~1,000
- **Experience:** Notice coal increasing without clicking
- **Coal rate:** ~0.5-1.5/sec automatic + manual
- **Realization:** "Wait, my coal is going up on its own?"

### Hour 2-5: Multiple Paths Opening
- **Repetitions:** 1,000 → ~3,000
- **Experience:** Noticeable passive generation, first offline earnings
- **Coal rate:** ~3-5/sec automatic + manual
- **Realization:** "I can leave and come back to progress"

### Hour 5-10: Acceleration
- **Repetitions:** 3,000 → ~7,500
- **Experience:** Significant idle capability, stats matter
- **Coal rate:** ~8-12/sec automatic + manual
- **Realization:** "This is becoming an idle game"

### Hour 10-20: Full Idle
- **Repetitions:** 7,500 → 10,000+
- **Experience:** Can play passively, strong offline earnings
- **Coal rate:** ~15-25/sec automatic (stat dependent)
- **Realization:** "I've mastered the shovel"

---

## Implementation Checklist

### Phase 1: Core Mechanics
- [ ] Add `shovel_repetitions` variable to Level1Vars
- [ ] Add `focus` and `last_session_time` variables
- [ ] Implement `get_zone_out_rate()` function
- [ ] Implement `get_focus_rate()` and `get_max_focus()` functions
- [ ] Hook manual shovel clicks to increment repetitions
- [ ] Add zone out coal generation to `_process(delta)`
- [ ] Add focus accumulation to `_process(delta)`

### Phase 2: Offline Earnings
- [ ] Implement `calculate_offline_earnings()` function
- [ ] Save `last_session_time` on game exit
- [ ] Call offline calculation on game load
- [ ] Create offline earnings popup UI
- [ ] Test offline earnings with various time gaps

### Phase 3: UI Elements
- [ ] Add repetitions counter to furnace scene
- [ ] Style repetitions counter (subtle, non-intrusive)
- [ ] Create offline popup notification panel
- [ ] Test UI responsiveness (portrait/landscape)

### Phase 4: Notifications (Optional)
- [ ] Implement tier unlock notifications
- [ ] Write final flavor text for all tiers
- [ ] Test notification timing and display
- [ ] Option to disable notifications in settings

### Phase 5: Balance & Polish
- [ ] Playtest unlock timing (is 500 reps ~1 hour?)
- [ ] Balance zone out rates (not too fast, not too slow)
- [ ] Balance focus accumulation and offline efficiency
- [ ] Test stat scaling (DEX/CON/WIS bonuses feel meaningful?)
- [ ] Verify integration with existing coal economy

### Phase 6: Save/Load
- [ ] Ensure `shovel_repetitions` persists
- [ ] Ensure `focus` persists
- [ ] Ensure `last_session_time` persists
- [ ] Test save/load cycle
- [ ] Test offline earnings across sessions

---

## Technical Notes

### Performance Considerations
- Zone out calculation is simple addition, negligible performance impact
- Focus accumulation is passive, no complex calculations
- Offline earnings only calculated once on load

### Edge Cases to Handle
1. **Player closes game immediately after opening**
   - Check if `time_away < 0.1 hours`, skip popup

2. **System time manipulation**
   - Could add sanity checks for unrealistic time gaps
   - Cap offline earnings to reasonable maximum (e.g., 24 hours)

3. **First session (no last_session_time)**
   - Initialize to current time on first play
   - No offline earnings on first load

4. **Focus cap changes mid-session**
   - If focus > new max cap, don't clamp (let it stay)
   - Natural decay will bring it down

### Save Data Structure
```gdscript
# Example save data
{
    "shovel_repetitions": 3847,
    "focus": 67.4,
    "last_session_time": 1732550400,
    # ... other existing save data
}
```

---

## Balance Tuning Values

### Tuneable Constants

```gdscript
# Focus conversion rate
const FOCUS_TO_HOURS_RATIO = 2.0  # 100 focus = 2 hours offline

# Base offline efficiency
const BASE_OFFLINE_EFFICIENCY = 0.5  # 50%
const MAX_OFFLINE_EFFICIENCY = 0.75  # 75% at Dissociation III

# Base focus generation
const BASE_FOCUS_PER_SECOND = 0.5

# Minimum offline time to show popup
const MIN_OFFLINE_HOURS = 0.1  # 6 minutes
```

**These can be adjusted during playtesting for balance.**

---

## Thematic Design Goals

### Grimdark Themes
1. **Dehumanization of labor** - Becoming a machine through repetition
2. **Coping mechanisms** - Dissociation as survival strategy
3. **Loss of agency** - Body works while mind absent
4. **Psychological toll** - The cost of repetitive work
5. **No escape** - Even "improvement" is dystopian

### Why This Works Thematically
- ✅ No machines (would break lore)
- ✅ Internal character development (mental adaptation)
- ✅ Fits grimdark setting (psychological horror of labor)
- ✅ Maintains power dynamic (still a laborer)
- ✅ Smooth transition to idle mechanics
- ✅ Respectful of player time (offline earnings)

---

## Future Considerations

### Potential Expansions
1. **Prestige interaction:** Do repetitions persist through prestige?
2. **Silver era transition:** How does zone out affect shift work?
3. **Own furnace phase:** Do these skills transfer or become obsolete?
4. **Additional paths:** Could add more specialized paths later

### Questions for Later
- Should repetitions reset on prestige or persist?
- Do zone out skills apply to other labor (or just shoveling)?
- Could "mastery" of shoveling affect story/dialogue?
- Should there be achievements for repetition milestones?

---

## Summary

**Zone Out + Focus system enables idle mechanics while maintaining thematic consistency.**

**Key Points:**
- Unlocks naturally through play (~1 hour to first tier)
- Invisible background system (minimal UI)
- Scales with stats (DEX/CON/WIS)
- Enables offline earnings respectfully
- Fits grimdark themes of dehumanized labor
- No currency cost (internal character development)

**Player Value:**
- Smooth transition from active to idle gameplay
- Rewards time investment
- Respects player time with offline earnings
- Makes all stats valuable
- Maintains engagement through discovery

---

**Version:** 1.0
**Last Updated:** 2025-11-25
**Status:** Ready for Implementation
