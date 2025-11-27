# Roguelite Copper Era - Design Plan

## Overview

GoA is being redesigned as a **roguelite work-shift game** where players work as coal shovelers in a grimdark industrial setting. Each day is a run, with resources resetting but meta-progression persisting.

### Core Loop
1. **Morning**: Pick a furnace from unlocked options
2. **Work Shift**: Click-drag coal to furnace until stamina OR focus depletes
3. **Evening**: Spend copper on upgrades (permanent equipment + temporary consumables)
4. **Night**: Sleep (with choice to eat rations or skip them)
5. Repeat

### Era Progression
- **Copper Era (Labourer)** - Manual coal shoveling (THIS DOCUMENT)
- **Silver Era (Overseer)** - Managing others' furnaces, overseeing labourers
- **Gold Era (Owner)** - Own furnace with machinery/automation

---

## Tone & Theme

**Grimdark, exploitative, frustrating.** Players should feel:
- Underpaid for hard work
- Exploited by the system
- Gradual improvement through persistence
- Industrial dystopia atmosphere

### Narrative Hook: Dream Extraction
Workers' rations are laced with a substance that allows nobility to siphon life force/dreams overnight to fuel selfish indulgences. This explains the daily reset - skills stored in procedural memory are extracted while you sleep.

**Discovered Mechanic**: Players can choose NOT to eat rations:
- **Benefit**: Keep 50% of run-based improvements (techniques/skills)
- **Cost**: Start next day with only 35% stamina/focus
- **Risk**: Overseer notices if performance is 30% better or worse than last 4-day average
  - Force-fed and drugged if detected
  - Lose evening phase, wake up next day "you passed out from not eating"
- **Discovery**: No hints or tutorials, pure player experimentation
- **Warning**: Before sleeping unfed, message: "you're starving, go to mess hall to eat before sleeping"

---

## Core Resources

### Stamina (Physical)
- **Purpose**: Consumed by physical actions (shoveling, carrying)
- **Starting Value**: 100 base
- **End-game Value**: 500 (through stats + upgrades)
- **Scaling**: Linear growth via Constitution stat + equipment purchases
- **Depletion**: Day ends when stamina OR focus hits zero
- **Recovery**: Slow passive recovery during breaks

### Focus (Mental)
- **Purpose**: Consumed by mental actions (precision work, shopping, haggling)
- **Starting Value**: 100 base
- **End-game Value**: 500 (through stats + upgrades)
- **Scaling**: Linear growth via Wisdom stat + equipment purchases
- **Depletion**: Day ends when stamina OR focus hits zero
- **Recovery**: Does NOT drain passively (only from actions)

### Coal
- **Purpose**: Resource shoveled during shift, determines pay
- **Behavior**: Resets every day
- **Mechanics**:
  - Click-drag from pile to furnace
  - Can fall off shovel during transit
  - Environmental hazards (shakes, fatigue) increase spill chance
  - Shovel capacity starts at 1 coal/scoop, upgrades increase this

### Copper (Primary Currency)
- **Purpose**: Main currency, persists between days
- **Earning**: Based on coal shoveled + hidden overseer logic
- **Spending**: Equipment upgrades, consumables, bribes
- **Storage**: Limited by purse capacity (starts 150, expands to 1400+)

---

## Stat System

Stats level up through XP, persist between days:

### Strength
- **Gains XP from**: Shoveling coal
- **Effects**: Reduces stamina drain per shovel
- **Scaling**: Standard XP curve (100 * (level-1)^1.8)

### Constitution
- **Gains XP from**: [TBD - taking damage? Endurance actions?]
- **Effects**: Increases max stamina pool
- **Scaling**: Standard XP curve

### Dexterity
- **Gains XP from**: [TBD - Precise actions? Avoiding spills?]
- **Effects**: Reduces coal spilling off shovel
- **Scaling**: Standard XP curve

### Wisdom
- **Gains XP from**: [TBD - Learning? Reflection?]
- **Effects**: Increases max focus pool
- **Scaling**: Standard XP curve

### Intelligence
- **Gains XP from**: [TBD]
- **Effects**: [NOT DEFINED YET - Ideas needed]
- **Scaling**: Standard XP curve

### Charisma
- **Gains XP from**: Bribing overseer, social interactions
- **Effects**: Bribe effectiveness, overseer mood improvement, shop discounts
- **Scaling**: Standard XP curve

---

## Internal Upgrade System (Run-based Techniques)

**Roguelite "choose-3" levelup system** similar to Vampire Survivors/Megabonk.

### Internal Resources
Four resources earned during a run:
- **Insight**: [EARNING METHOD TBD]
- **Experience**: [EARNING METHOD TBD]
- **Passion**: [EARNING METHOD TBD]
- **Drive**: [EARNING METHOD TBD]

**CRITICAL QUESTION: How/when is each resource earned?**

### Levelup Mechanics
- **When**: [TBD - Every X coal? Every X resources? Fixed per run?]
- **Format**: Choose 1 from 3 randomly offered techniques
- **Rarity**: Common, Rare, Epic, Legendary (like Megabonk)
- **Slots**: Limited number of active techniques per run
- **Upgrades**: Existing techniques can appear again to enhance/evolve
- **Unlock**: Must unlock techniques before they appear in pool

### Access
- **Location**: Easy-access menu from furnace scene
- **UI**: "Go into your own head" to spend internal resources
- **Timing**: Available anytime during shift, at breaks

### Meta-Progression (Between Runs)
- **Slot Increases**: Buy more technique slots [COST TBD]
- **Rerolls**: Reroll the 3 choices [COST TBD]
- **Banishes**: Remove unwanted technique from pool [COST TBD]
- **Currency**: [TBD - Copper? Or separate resource?]

### Technique Categories & Examples

**NEED 5-10 EXAMPLES FOR EACH CATEGORY**

#### Emotional Techniques (Insight + Passion?)
- **Inner Peace** (Rare): [EFFECT TBD - Reduce focus costs?]
- **Acceptance** (Common): [EFFECT TBD - Reduce fatigue buildup?]
- **Determination** (Rare): [EFFECT TBD - Increase stamina?]
- [MORE EXAMPLES NEEDED]

#### Mental Techniques (Insight + Experience?)
- **Pattern Recognition** (Rare): [EFFECT TBD - See shake warnings earlier?]
- **Rhythm** (Common): [EFFECT TBD - Stamina bonus for consistency?]
- **Risk Assessment** (Epic): [EFFECT TBD - See hidden multipliers?]
- [MORE EXAMPLES NEEDED]

#### Proprioceptive Techniques (Experience + Drive?)
- **Balance** (Common): [EFFECT TBD - Reduce spill chance?]
- **Precision** (Rare): [EFFECT TBD - Better coal placement?]
- **Economy of Motion** (Rare): [EFFECT TBD - Reduce stamina per shovel?]
- [MORE EXAMPLES NEEDED]

#### Mixed/Special Techniques
- [UNIQUE CROSS-CATEGORY EXAMPLES NEEDED]

### Technique Persistence
If player skips rations, 50% of technique effects persist to next day (with 35% stamina/focus penalty).

### Questions Remaining:
1. How is each internal resource (Insight/Experience/Passion/Drive) earned?
2. When do levelups occur? (Milestone? Threshold? Fixed?)
3. Starting technique slots? (1? 3?)
4. Max technique slots endgame? (6? 8? 10?)
5. How to unlock new techniques for the pool?
6. Rarity distribution percentages?
7. Do techniques stack, evolve, or just strengthen when picked again?
8. What currency buys meta-progression (slots/rerolls/banishes)?
9. Concrete effects for all technique examples
10. How many levelups per run? (3-5? More?)

---

## Coal Shoveling Mechanics

### Click-Drag System
- **Action**: Click coal pile → shovel loads → drag to furnace → release
- **Capacity**: Start with 1 coal per scoop
- **Upgrades**: Shovel head increases capacity (up to 5?)
- **Stacking**: Can also upgrade "stacking ability" during runs [METHOD TBD]

### Coal Spillage
Environmental factors cause coal to fall off shovel:

#### Train Shakes
- **Cause**: Movement of the train the furnace is on
- **Pattern**:
  - Small shakes can precede big shakes (warning)
  - Sometimes no warning, straight to big shake
  - Varying durations and frequencies
- **Effect**: Screen shake, coal more likely to fall off during drag
- **Mitigation**: Better stability (shovel shaft), dexterity, techniques

#### Lactic Acid Buildup (Muscle Fatigue)
- **Cause**: Frequent fast shoveling
- **Effect**: Arms shake, reduced control, coal more likely to fall
- **Visual**: Arm icon shaking, screen edge blur
- **Recovery**: Purges quickly when not shoveling fast
- **Mitigation**: Better handles (reduce buildup), techniques, pacing

#### Other Factors
- **Overfilling**: More coal on shovel = more likely to spill
- **Speed**: Dragging too fast increases spill chance
- **Sharp turns**: Sudden movements during drag
- **Dexterity stat**: Higher dex = less spillage
- **Gloves**: Reduce precision (increase spills) but save stamina

### Fallen Coal
- **Penalty**: Lost forever (does not count toward pay)
- **No second chances**: Cannot re-scoop spilled coal

---

## Break System

### Frequency
- **Trigger**: Every X coal shoveled [X VALUE TBD - 50? 100?]
- **Alternative**: Bribe to work through break (costs copper)
- **Optional**: Breaks are not mandatory, but overseer prefers if you work through them

### Duration
- **Timing**: Unlimited time (player-controlled)
- **Activities**: All shops accessible (permanent + temporary)
- **Focus Cost**: Shopping, haggling, planning all drain focus (not stamina)
- **Stamina Recovery**: Slow passive recovery during break

### Impact on Pay
- **Hidden Penalty**: Time spent on breaks affects end-of-day copper (not communicated)
- **Overseer Logic**: Less break time = better pay (but player must discover this)

### Bribes During Breaks
- **Work Through Break**: Pay copper to skip break entirely (overseer approval)
- **Extended Break**: Pay copper for longer break time, more stamina recovery
- **Other**: [MORE BRIBE OPTIONS TBD]

---

## Demand Events (Rush Orders)

### Structure
- **Trigger**: Random during shift, varying severity
- **Display**: Request stays on screen until event ends
- **Communication**: Verbal urgency only (NO specific coal amounts shown)
  - Low severity: "Shovel more"
  - Medium: "Pick up the pace!"
  - High: "Shovel like your life depends on it!"
- **Duration**: Timed (60-120 seconds?) [TBD]

### Rewards
- **Mechanism**: Hidden multiplier increases during event
- **Player Knowledge**: NOT told about multiplier, must discover through experimentation
- **Base Value**: Background copper value per coal (e.g., 0.05 copper/coal)
- **Multiplier Examples**:
  - Normal shoveling: 1.0x
  - "Shovel more": 1.5x
  - "Pick up the pace": 2.0x
  - "Life depends on it": 2.5x

### Consequences
- **Success**: Higher pay, overseer mood improvement
- **Failure**: No explicit penalty, just missed bonus opportunity
- **Tradeoffs**: Rush = higher stamina drain, higher fatigue, more spills

---

## Overseer Payment System

### Philosophy
**Intentionally obscure and hard to understand** - rooted in cognitive biases from "Thinking Fast and Slow".

### Hidden Calculation
- **Base Rate**: Copper per coal (varies by furnace, day, overseer mood)
- **Multipliers**: Applied based on numerous factors
- **Final Payment**: Announced with NO explanation

### Cognitive Biases Implemented

#### Recency Bias
- Last 20% of shift weighted more heavily than first 80%
- Recent mistakes more impactful than early ones
- Recent successes boost final payment

#### Peak-End Rule
- Highest performance moment remembered
- Final moments of shift heavily weighted
- Middle performance largely ignored

#### Anchoring
- First impression (early performance) sets baseline expectation
- All future performance compared to this anchor
- Breaking anchor (very good or very bad start) affects entire evaluation

#### Affect Heuristic
- Overseer's current mood colors entire evaluation
- Good mood = interpret performance generously
- Bad mood = interpret performance harshly
- Mood affected by: Bribes, time of day, external events, player behavior

#### Availability Bias
- Recent spills heavily weighted vs total coal
- Visible mistakes more impactful than quiet successes
- Events/anomalies remembered more than steady work

#### Other Factors
- **Blood sugar**: Overseer more generous after meals (time-of-day effects)
- **External pressure**: Factory quotas, noble visitors affect payment
- **Weather**: Hot days make overseer irritable
- **Break time**: Hidden penalty for long breaks

### Player Feedback
- **Vague only**: "Good work" vs "Disappointing" vs "Adequate"
- **No numbers**: Coal count shown, but payment feels arbitrary
- **No explanation**: Just copper amount announced
- **Discovery**: Players experiment to learn patterns

### Furnace Differences
Each furnace has different overseer with different:
- Bias weights (some are recency-focused, others peak-focused)
- Base payment rates
- Mood volatility
- Bribe effectiveness

---

## Equipment Progression

### Shovel System (Modular Components)

#### Shovel Heads (Capacity)
Increase coal quantity per scoop:
- **Basic Head** (1 capacity, free)
- **Iron Head** (2 capacity, [COST TBD])
- **Steel Head** (3 capacity, [COST TBD])
- **Quality Head** (4 capacity, [COST TBD])
- **Master Head** (5 capacity, [COST TBD])

#### Shovel Shafts (Stamina Reduction + Stability)
Lighter and stiffer for efficiency:
- **Wooden Shaft** (free, 0% benefit)
- **Ash Shaft** ([COST TBD], -10% stamina, +10% stability)
- **Hickory Shaft** ([COST TBD], -15% stamina, +20% stability)
- **Reinforced Shaft** ([COST TBD], -25% stamina, +35% stability)

#### Shovel Handles (Stamina + Lactic Acid)
Reduce stamina drain and muscle fatigue:
- **Basic Handle** (free)
- **Wrapped Handle** ([COST TBD], -10% stamina, -15% lactic buildup)
- **Ergonomic Handle** ([COST TBD], -15% stamina, -30% lactic buildup)
- **Master Handle** ([COST TBD], -25% stamina, -50% lactic buildup)

**QUESTION: What are specific copper costs for each component?**

### Other Equipment

#### Gloves (Stamina vs Precision Tradeoff!)
Increase stamina efficiency BUT reduce precision:
- **Bare Hands** (free, 0% stamina, 0% precision loss)
- **Cloth Gloves** ([COST TBD], +10% stamina, -5% precision)
- **Leather Gloves** ([COST TBD], +20% stamina, -10% precision)
- **Padded Gloves** ([COST TBD], +35% stamina, -20% precision)

#### Boots (Stamina Drain + Max Speed)
Help with stamina and how fast you can move before coal falls:
- **Old Shoes** (free)
- **Work Boots** ([COST TBD], -10% stamina drain, +10% max speed)
- **Steel-toe Boots** ([COST TBD], -15% stamina drain, +20% max speed)
- **Comfort Boots** ([COST TBD], -25% stamina drain, +35% max speed)

#### Accessories
- **Water Bottle** ([COST TBD], [EFFECT TBD - Stamina recovery during breaks?])
- **Headlamp** ([COST TBD], [EFFECT TBD - Focus efficiency in dark?])
- **Back Brace** ([COST TBD], [EFFECT TBD - Reduced fatigue buildup?])
- **Whetstone?** (Sharpen shovel mid-run?)
- **Lucky Charm?** (Pay multiplier? Or is this a consumable?)
- [MORE IDEAS NEEDED]

**QUESTIONS:**
- What are costs for all equipment pieces?
- What are exact effects for accessories?
- Any other equipment types needed?

### Purse Progression (Gating System)

Limits copper storage, gates progression:

- **Torn Pocket** (150 cap, free)
- **Small Pouch** (300 cap, costs 125-150 copper)
- **Leather Purse** (500 cap, costs ~275-300 copper)
- **Sturdy Purse** (700 cap, costs ~650 copper)
- **Money Belt** (900 cap, costs ~850 copper)
- **Secure Pouch** (1100 cap, costs ~1050 copper)
- **Lockbox** (1400 cap, costs ~1350 copper)
- **[Future]** Expansions to 3000 cap using SILVER currency (Silver Era)

**Design**: Each upgrade costs ~90-95% of new capacity, forcing strategic saving.

---

## Temporary Consumables

One-time use items purchased during breaks or evening:

### Day 1 Options (Pathetic)
- **Murky Water** (1 copper, [EFFECT TBD])
- **Stale Bread** (1 copper, [EFFECT TBD])

### Other Consumables (1-5 copper range)
- **Weak Coffee** ([COST TBD], [EFFECT TBD - +focus or -focus drain?])
- **Better Bread** ([COST TBD], [EFFECT TBD - +stamina during shift?])
- **Chalk** ([COST TBD], [EFFECT TBD - -X% spill chance this shift only?])
- **Pain Tonic** ([COST TBD], [EFFECT TBD - -X% lactic acid buildup?])
- **Lucky Charm?** ([COST TBD], [EFFECT TBD - +X% pay multiplier?])

**QUESTIONS:**
- What are specific costs (1-5 copper)?
- What are specific effects?
- Any other consumable ideas?

---

## Bribery System

### Purpose
- **Gate to Silver Era**: Must spend 1000 copper total across all bribes
- **Immediate Perks**: Each bribe gives small benefit
- **Relationship Building**: Cumulative spending unlocks trust

### Bribe Options

**NEED SPECIFIC COSTS AND EFFECTS FOR EACH:**

- **Keep Equipment** ([COST TBD], prevents overseer from "reclaiming" 1 item)
- **Work Through Break** ([COST TBD], overseer approval, +X% pay)
- **Extended Break** ([COST TBD], +30s break time, recover more stamina)
- **Look the Other Way** ([COST TBD], [EFFECT TBD - No suspicion while stealing?])
- **Better Mood** ([COST TBD], +10% pay multiplier this shift)
- **Rush Order Tip-off** ([COST TBD], advance warning of demand event)
- [MORE OPTIONS NEEDED]

### Timing
- **Not picky**: Can bribe at start of shift, during breaks, end of day
- **Relative Pricing**: Bribe cost scales with benefit imparted

### Equipment Reclamation
- Overseer can reclaim equipment from workers (new mechanic)
- Bribes can prevent this (adds urgency/loss aversion)

**QUESTIONS:**
- What triggers equipment reclamation? (Random? Performance-based?)
- How often can it happen?
- What items are at risk?

---

## Copper Economy

### Earning Timeline

Based on average performance without exploits:

**Week 1:**
- Day 1: 1-3 copper
- Day 2-3: 3-5 copper
- Day 4-7: 5-10 copper

**Week 2:**
- Days 8-14: 10-20 copper

**Week 3:**
- Days 15-21: 25-50 copper

**Week 4+:**
- Days 22+: 50-100 copper
- Late Copper Era: 100+ copper possible

### Progression Pace

**Day 1 Experience:**
- Earn 1-3 copper
- Can afford ONE pathetic consumable (1 copper item)
- Learn basic mechanics
- Feel exploited and underpaid

**First Week:**
- Save for first permanent upgrade (3-7 days)
- Learn to balance consumables vs savings
- Discover hidden mechanics (rations, overseer logic)

**First Permanent Upgrade:**
- Should be affordable around Day 5-10
- Noticeable improvement in performance
- Positive feedback loop begins

**Mid Copper Era:**
- Multiple permanent upgrades owned
- Strategic consumable purchases
- Experimenting with furnace choices
- Saving for purse upgrades

**Late Copper Era:**
- High-capacity purse (1100-1400)
- Most equipment owned
- Approaching 1000 copper bribe threshold
- Final push to Silver Era transition

**QUESTIONS:**
- Does this pacing feel right?
- Should early days be more/less lucrative?
- When should first technique slot upgrade be affordable?

---

## Silver Era Transition

### Requirements
1. **Pay 1 silver coin** (symbolic rite of passage)
   - Costs 1000 copper (1 silver = 1000 copper exchange rate)
   - Purchased at [LOCATION TBD - Bank? Overseer?]
2. **Bribe threshold met** (1000 copper total spent on bribes)
3. **Purse capacity** of at least 1400 (can hold the silver coin)

### Transition Mechanics
- **Access unlocked**: Can now pick overseer shifts in the morning
- **Performance-based**: Poor performance reduces available shifts
- **Fallback**: Can always return to copper labour shifts if needed
- **Not permanent**: Must maintain performance to keep Silver access

### Failure State (Copper Era)
- **None**: No way to permanently lose or game-over
- Always progress (just slower if performing poorly)

---

## Furnace Selection (Morning Phase)

### Starting State
- 1 furnace available (tutorial/default)

### Unlocking Furnaces
- [METHOD TBD - Copper purchase? Stat requirements? Story progression?]
- Each furnace has different characteristics

### Furnace Differences

**Risk/Reward Spectrum:**
- **Easy Furnaces**: Closer to coal pile, calmer overseer, lower pay
- **Hard Furnaces**: Farther from pile, volatile overseer, higher pay
- **Unlock Gating**: Better furnaces require higher performance to unlock

**Differentiation Factors:**
- **Distance from coal pile**: Affects stamina per trip
- **Temperature**: Hotter = better pay but faster focus drain
- **Quota expectations**: Higher quota = better multiplier but harder
- **Overseer personality**: Different cognitive bias weights
- **Shake frequency**: Some furnaces shake more (train position?)
- **Lighting**: Dark furnaces drain more focus

**QUESTIONS:**
- How many furnaces total in Copper Era? (5? 10?)
- What are specific unlock requirements?
- What are specific stat differences?

---

## Evening Phase

### Structure
- **Unlimited time**: Player controls when to proceed to sleep
- **Activities available**:
  - Shop for permanent equipment
  - Bar for temporary consumables
  - Talk to NPCs (lore, tips, unlock furnaces?)
  - Stats/progress screens
  - Save/quit
  - Eat rations or skip them (critical choice)

### Shops
- **All permanent equipment**: Shovel components, gloves, boots, accessories, purses
- **All temporary consumables**: Drinks, food, tools
- **Bribes**: Can bribe overseer here (or during shift?)

### Ration Choice
- **Rations on table**: Click to eat or ignore
- **Warning before sleep**: "you're starving, go to mess hall to eat before sleeping"
- **No tutorial**: Players must discover consequences themselves

---

## Day Length Scaling

### Starting Point (Day 1)
- 100 stamina, 100 focus
- Minimal technique knowledge
- Poor decisions
- **Result**: ~10 minutes real-time

### Mid-Game (Day 10-20)
- 200 stamina, 150 focus
- Some techniques unlocked
- Better decision-making
- **Result**: ~15-18 minutes real-time

### End-Game (Day 30-50+)
- 400-500 stamina, 300-500 focus
- Many techniques, smart resource management
- Optimal pacing, minimal waste
- **Result**: ~25-30 minutes real-time

### Factors That Extend Runs
- Higher stat pools (Con, Wis)
- Better stamina/focus efficiency (Str, equipment)
- Smart break management (recover before depletion)
- Conservative shoveling (less fatigue buildup)
- Good technique choices (reduce costs)
- Avoiding spills (less wasted effort)

---

## Implementation Priority

**NOT for implementation yet** - this is planning only!

When implementation begins, suggested build order:

### Phase 1: Core Loop MVP
1. Furnace scene basic layout
2. Click-drag coal mechanic (simple version)
3. Stamina/focus bars and depletion
4. Basic end-of-day payment (simple formula)
5. Evening shop (barebones)
6. Day restart

### Phase 2: Feel & Juice
1. Coal spillage physics
2. Screen shake system
3. Lactic acid buildup
4. Visual feedback (UI polish)
5. Sound effects

### Phase 3: Progression Systems
1. Stat XP system
2. Equipment shop (permanent upgrades)
3. Purse gating
4. Consumables shop

### Phase 4: Roguelite Elements
1. Internal resource earning
2. Technique levelup system
3. Technique effects implementation
4. Meta-progression (slots, rerolls, banishes)

### Phase 5: Depth & Discovery
1. Ration choice mechanic
2. Overseer cognitive bias system
3. Demand events
4. Break system
5. Bribery system

### Phase 6: Content & Balance
1. Multiple furnaces
2. All equipment paths
3. All techniques
4. Balance tuning
5. Silver Era transition

---

## Open Questions Summary

### Critical (Need answers to proceed)

**Internal Upgrade System:**
1. How is each resource (Insight/Experience/Passion/Drive) earned?
2. When do technique levelups occur?
3. Starting technique slots? Max slots?
4. How to unlock techniques for the pool?
5. Do techniques stack/evolve/strengthen when picked multiple times?
6. What currency for meta-progression (slots/rerolls)?
7. Concrete effects for 20-30 technique examples across categories
8. Rarity distribution percentages?

**Equipment Costs:**
9. Specific copper costs for all shovel components (heads/shafts/handles)
10. Specific costs for gloves, boots, accessories
11. Specific effects for all accessories (water bottle, headlamp, back brace, etc.)
12. Any other equipment types needed?

**Consumables:**
13. Specific costs (1-5 copper range) for all consumables
14. Specific effects for all consumables
15. What are the pathetic 1-copper Day 1 options?

**Bribes:**
16. Specific costs and effects for all bribe types
17. What triggers equipment reclamation?
18. How often can reclamation happen?

**Economy:**
19. Does the earning timeline feel right? (1-3 copper Day 1 → 50-100 by Week 4)
20. When should first permanent upgrade be affordable? (Day 5-10?)
21. When should first technique slot upgrade be affordable?

**Furnaces:**
22. How many furnaces total in Copper Era?
23. What are unlock requirements for each?
24. Specific stat differences between furnaces?

**Break System:**
25. Break frequency (every X coal - what's X?)
26. Does break frequency scale with progression?
27. Minimum break requirement per shift?

**Demand Events:**
28. Duration of events (60-90 seconds?)
29. Frequency per shift (1-3 times?)
30. Specific multiplier values for each urgency level?

**Other:**
31. How do you upgrade shovel "stacking ability" during runs?
32. What does Intelligence stat do?
33. How do non-Strength stats gain XP?
34. Base copper value per coal (0.05? Variable?)

---

## Design Philosophy Reminders

### For Implementation Team:

**Player Discovery:**
- No hand-holding or tutorials for hidden mechanics
- Ration choice should be pure experimentation
- Overseer logic intentionally obscure
- Hidden multipliers discoverable through play

**Grimdark Tone:**
- Players should feel exploited
- Pay should feel unfair and arbitrary
- Systems should feel stacked against the player
- Progress should feel hard-won

**Roguelite Structure:**
- Each day is a unique run
- Meaningful choices (technique picks, ration choice, furnace choice)
- Meta-progression (stats, equipment, unlocks)
- Discovery and experimentation rewarded

**Balance:**
- Early game should be frustratingly slow
- Mid game should show meaningful progress
- Late game should feel powerful but still challenging
- Silver Era transition should feel like a major achievement

---

## Conversation Context

This document captures a planning conversation between user and Claude about redesigning GoA into a roguelite. We've discussed:

- Core loop structure (work shift as roguelite run)
- Dual resource system (stamina + focus)
- Ration choice mechanic (skip food = keep skills but lose resources)
- Internal technique system (choose-3 levelups with rarities)
- Equipment progression (modular shovels, accessories, purse gating)
- Overseer payment obscurity (cognitive biases)
- Bribery system (cumulative spending unlocks Silver Era)
- Economy pacing (very slow early, faster later)
- Grimdark tone (exploitation, unfairness)

**Next steps when conversation resumes:**
1. Answer remaining questions (especially internal upgrade system details)
2. Fill in specific costs/effects for equipment, consumables, bribes
3. Design 20-30 concrete technique examples
4. Finalize furnace differences and unlock progression
5. Create implementation roadmap

---

**Document Status**: Work in progress, awaiting user input on open questions before finalizing.

**Last Updated**: 2025-11-26
