# Zone-Out Integration Summary

**Created:** 2025-11-26
**Status:** Integrated into Phases 2.2, 2.3, and 2.6

---

## Overview

The zone-out mechanic has been successfully integrated into the roguelite copper era design as **BOTH** a permanent progression system AND a powerful technique category. This dual implementation creates interesting build variety and long-term progression.

---

## How It Works

### Core Mechanic: Action-Based (NOT Time-Based)

**Trigger:** After each successful manual shovel action
**Effect:** Chance to automatically perform another shovel action

**Key Properties:**
- Auto-shovels cost less stamina (default 75%, can be reduced to 25%)
- Auto-shovels cost ZERO focus
- Auto-shovels have 50% reduced spill chance (can be eliminated entirely)
- Auto-shovels can chain (trigger additional auto-shovels)
- Auto-shovels use faster animation (slightly transparent sprite)

---

## Two-Tier System

### Tier 1: Permanent Progression (Phase 2.2)

**Unlocked through:** `shovel_repetitions` (lifetime counter, never resets)

**Three Progressive Paths:**

#### RHYTHM (DEX-focused)
- 500 reps: +5% auto-shovel chance
- 2,000 reps: +5% auto-shovel chance, DEX reduces auto-shovel spill by 2%/level
- 5,000 reps: +5% auto-shovel chance, auto-shovels 15% faster animation

#### ENDURANCE (CON-focused)
- 750 reps: +5% auto-shovel chance
- 3,000 reps: +5% auto-shovel chance, auto-shovel costs 60% stamina (vs 75%)
- 7,500 reps: +5% auto-shovel chance, CON reduces auto-shovel stamina by 2%/level

#### DISSOCIATION (WIS-focused)
- 1,000 reps: +5% auto-shovel chance
- 4,000 reps: +5% auto-shovel chance, 10% auto-shovel chain chance
- 10,000 reps: +5% auto-shovel chance, chain chance = 15% + (WIS × 2%)

**Total Permanent:** Up to 45% auto-shovel chance at 10,000+ repetitions

**Timeline:** Unlocks over 15-20 hours of play

---

### Tier 2: Technique System (Phases 2.3 & 2.6)

**Unlocked through:** Levelup choices during work shifts (temporary, run-based)

**Zone-Out Technique Suite:**

#### Core Techniques
- **Zone Out** (Rare): +35% auto-shovel chance
- **Muscle Memory** (Rare): Auto-shovels cost 40% stamina (vs 75%)
- **Efficient Motion** (Common): Auto-shovels 20% faster animation
- **Perfect Form** (Epic): Auto-shovels 75% reduced spill (vs 50%)
- **Autopilot** (Legendary): Auto-shovels NEVER spill, cost 25% stamina

#### Chain & Combo Techniques
- **Flow State** (Epic): Auto-shovels can chain (30% chance each)
- **Trance** (Legendary): Zone-out rolls twice per manual shovel
- **Momentum** (Rare): Each auto-shovel increases next auto-chance by +5% (stacks)
- **Meditation** (Epic): Auto-shovels restore +2 focus (instead of consuming it)

**All techniques reset at end of shift** (roguelite design)

---

## Stacking & Synergy

### Example: Early Game (500 reps)
- Permanent: 5% auto-shovel chance (Rhythm I)
- Get Zone Out technique: +35%
- **Total: 40% auto-shovel chance**
- Transforms gameplay immediately

### Example: Mid Game (5,000 reps)
- Permanent: 25% auto-shovel chance (multiple paths)
- Get Zone Out technique: +35%
- Get Muscle Memory: Auto-shovels cost 40% stamina
- **Total: 60% auto-shovel chance, very efficient**

### Example: Late Game (10,000+ reps, lucky run)
- Permanent: 45% auto-shovel chance (all paths)
- Get Zone Out technique: +35%
- Get Flow State: 30% chain chance per auto
- Get Trance (legendary): Double zone-out rolls
- **Result: Near-constant auto-shoveling with chains**

### Example: Perfect Automation Build
- Permanent: 45%
- Autopilot (legendary): Perfect auto-shovels, 25% stamina
- Flow State: 30% chain
- Meditation: Auto-shovels restore focus
- **Result: Self-sustaining automation loop**

---

## Build Archetypes

### 1. Zone-Out Specialist
**Goal:** Maximum automation, minimal manual input
**Techniques:** Zone Out + Muscle Memory + Flow State + Perfect Form
**Result:** 60-80% auto-shovel chance, efficient chains
**Playstyle:** Relaxed, watch the shovel work for you

### 2. Hybrid Momentum
**Goal:** Snowball effect - starts slow, becomes unstoppable
**Techniques:** Zone Out + Momentum + Trance + Flow State
**Result:** Stacking bonuses lead to 90%+ auto-shovel rate
**Playstyle:** Strategic patience pays off

### 3. Perfect Automation
**Goal:** Flawless auto-shoveling
**Techniques:** Autopilot + Pride + Meditation + Flow State
**Result:** Perfect runs with no spills, focus-positive
**Playstyle:** High-skill requirement to get legendary, huge payoff

### 4. Endurance Hybrid
**Goal:** Long shifts with automation support
**Techniques:** Zone Out + Determination + Endurance + Meditation
**Result:** Sustainable long-term work
**Playstyle:** Outlast the overseer

---

## Integration Points

### Phase 2.1 (Core Loop MVP)
- Add repetition counter to `Global.gd`
- Increment on successful manual shovels
- Display counter in UI

### Phase 2.2 (Permanent Progression)
- Implement three zone-out paths
- Add `get_zone_out_chance()` function
- Add `get_auto_shovel_stamina_mult()` function
- Add `get_auto_shovel_chain_chance()` function
- Create auto-shovel animation/visual

### Phase 2.3 (Roguelite Techniques)
- Add 4 core zone-out techniques
- Add 4 chain/combo techniques
- Implement stacking logic (permanent + technique)
- Cap total chance at 95% (always some manual control)

### Phase 2.4 (Breaks & Demand)
- Auto-shovels work during demand events
- Auto-shovels affected by shake events
- Auto-shovels count toward break triggers

### Phase 2.5 (Discovery)
- Auto-shovels visible to overseer (affect payment biases)
- Technique retention via ration skipping applies to zone-out techniques

### Phase 2.6 (Content & Balance)
- Expand to full 8-technique zone-out suite
- Balance auto-shovel rates vs. manual play
- Ensure builds feel distinct and powerful
- Polish auto-shovel visuals and feedback

---

## Design Philosophy

### Why Action-Based, Not Time-Based?

**Rejected:** Passive coal generation per second (idle game)
**Chosen:** Auto-shovel after manual actions

**Reasons:**
1. **Maintains Active Gameplay:** Still requires player input to trigger automation
2. **Fits Roguelite Design:** Synergizes with run-based technique choices
3. **Feels More Skill-Based:** Automation is reward for efficient play
4. **Better Balance:** Can't just leave game running, must engage
5. **Thematic Fit:** "Muscle memory" after manual actions makes sense

### Why Both Permanent AND Temporary?

**Permanent Progression (Equipment-like):**
- Rewards long-term investment
- Makes stats (DEX/CON/WIS) valuable
- Provides baseline automation for all runs
- Feels like character growth

**Temporary Techniques (Roguelite):**
- Creates run variety (some runs more automated than others)
- High-risk/high-reward (chase legendary Autopilot)
- Enables build experimentation
- Prevents automation from becoming boring

### Balance Philosophy

**Early Game (0-500 reps):**
- No permanent automation yet
- Zone Out technique feels HUGE when you get it
- Teaches mechanic, gets players excited

**Mid Game (500-5000 reps):**
- Permanent automation kicks in (15-25%)
- Combining with techniques creates satisfying synergy
- Multiple build paths emerge

**Late Game (5000+ reps):**
- High permanent automation (30-45%)
- Techniques enhance rather than enable
- Perfect builds possible but rare
- Automation supports, doesn't replace gameplay

---

## Technical Implementation

### Global.gd
```gdscript
var shovel_repetitions = 0  # Persists forever

func get_zone_out_chance() -> float:
    var chance = 0.0
    # Rhythm path (15% max)
    if shovel_repetitions >= 500: chance += 0.05
    if shovel_repetitions >= 2000: chance += 0.05
    if shovel_repetitions >= 5000: chance += 0.05
    # Endurance path (15% max)
    if shovel_repetitions >= 750: chance += 0.05
    if shovel_repetitions >= 3000: chance += 0.05
    if shovel_repetitions >= 7500: chance += 0.05
    # Dissociation path (15% max)
    if shovel_repetitions >= 1000: chance += 0.05
    if shovel_repetitions >= 4000: chance += 0.05
    if shovel_repetitions >= 10000: chance += 0.05
    return chance
```

### furnace_work.gd
```gdscript
func on_manual_shovel_complete():
    # Award coal, XP, increment repetitions
    Global.shovel_repetitions += 1

    # Check for auto-shovel
    var total_chance = Global.get_zone_out_chance()
    if TechniqueManager.has_active_technique("zone_out"):
        total_chance += 0.35

    if randf() < min(total_chance, 0.95):
        perform_auto_shovel()

func perform_auto_shovel():
    # Calculate stamina cost
    var auto_mult = Global.get_auto_shovel_stamina_mult()
    if TechniqueManager.has_active_technique("muscle_memory"):
        auto_mult = 0.40
    if TechniqueManager.has_active_technique("autopilot"):
        auto_mult = 0.25

    # Apply cost, process coal, check for chain
    RunState.stamina -= base_cost * auto_mult
    # ... coal processing logic ...
    check_auto_shovel_chain()
```

---

## Success Metrics

### Permanent Progression Success
- [ ] Players notice first auto-shovel at ~1 hour (500 reps)
- [ ] 25% automation feels significant at 5,000 reps
- [ ] 45% automation at 10,000+ reps feels mastered
- [ ] Stat scaling (DEX/CON/WIS) creates build variety

### Technique System Success
- [ ] Zone Out technique transforms early runs
- [ ] Multiple zone-out build paths viable
- [ ] Legendary Autopilot feels amazing but rare
- [ ] Chains with Flow State create satisfying moments
- [ ] Builds without zone-out techniques still viable

### Integration Success
- [ ] Active + automation gameplay feels balanced
- [ ] Doesn't eliminate manual play (stays roguelite)
- [ ] Creates distinct run experiences
- [ ] Long-term progression rewarding
- [ ] Thematically consistent (muscle memory, dissociation)

---

## Comparison: Original vs. Integrated

### Original Zone-Out Plan (2-zone-out.md)
- Time-based passive coal generation
- Focus system for offline earnings
- Pure idle/incremental design
- 9 tiers across 3 paths
- No run variance (always active)

### Integrated Zone-Out System
- **Action-based automation** (triggers after manual shovels)
- **No offline earnings** (doesn't fit roguelite runs)
- **Hybrid idle/active** design
- **9 permanent tiers** (Phase 2.2) + **8 technique variants** (Phases 2.3/2.6)
- **High run variance** (techniques change each run)

### What Was Kept
- Three paths (Rhythm/Endurance/Dissociation)
- Repetitions tracking
- Stat scaling (DEX/CON/WIS)
- Grimdark theme (muscle memory, dehumanization)
- Gradual unlocks over time

### What Was Changed
- Time-based → Action-based
- Always-on → Chance-based
- Offline earnings → Removed
- Single system → Dual-tier (permanent + temporary)
- Idle focus → Active focus with automation support

---

## Future Considerations

### Prestige/Reset Mechanics
**Question:** Do repetitions persist through prestige?
**Options:**
- A: Full reset (must re-unlock automation)
- B: Partial retention (keep some %, like 50%)
- C: Full persistence (never lose progress)
**Recommendation:** Option B - keeps progression valuable but allows fresh starts

### Silver/Gold Era Integration
**Question:** Do zone-out skills transfer to overseer/owner gameplay?
**Recommendation:** "Shovel mastery" could unlock different automation in later eras

### Technique Pool Expansion
**Potential additions:**
- Hyperfocus: Auto-shovels cost focus but restore stamina
- Reverse Flow: Manual shovels after auto-shovels have bonuses
- Echo: Last 5 shovels repeat automatically at end of shift
- Muscle Failure: Auto-shovels increase in cost each time (anti-spam)

---

## Summary

The zone-out mechanic has been **successfully integrated** as:

1. **Permanent Meta-Progression** (Phase 2.2)
   - Unlocked through lifetime repetitions
   - Three paths with stat scaling
   - Provides baseline 0-45% automation

2. **Powerful Technique Category** (Phases 2.3 & 2.6)
   - 8 zone-out related techniques
   - Run-based temporary bonuses
   - Creates distinct build archetypes

3. **Action-Based System**
   - Triggers after manual shovels (not time)
   - Maintains active gameplay
   - Fits roguelite design

**Result:** A unique hybrid system that combines incremental progression with roguelite variety, preserving the "muscle memory" theme while supporting active, skill-based gameplay.

---

**Integration Status:** Complete
**Next Steps:** Implementation in Phases 2.2, 2.3, and 2.6
**Version:** 1.0
