# GoA Level 1: Train Escape - Idle/Incremental Enhancement Plan

**Version**: 1.0
**Created**: 2025-11-01
**Status**: Planning Phase

---

## Table of Contents

1. [Core Design Philosophy](#core-design-philosophy)
   - Mysterious Gameplay
   - Sacrifice Theme
   - Desert Train Setting
2. [Narrative Framework (Level 1: The Train)](#narrative-framework-level-1-the-train)
   - Key Story Beats
   - Knowledge-Based Discovery: "The Crystal's Language"
3. [Phase 0: Onboarding & Core Loop Feel](#phase-0-onboarding--core-loop-feel-foundation)
   - First 5 Minutes - Organic Tutorial
   - Game Feel & Feedback (CRITICAL)
   - Goal Visibility System
4. [Phase 1: Overseer's Mood & Conversion System](#phase-1-overseers-mood--conversion-system)
   - Manual vs Auto Conversion Toggle
   - Knowledge-Based Discovery: Hidden Mood Patterns
   - Upgradeable Paths
5. [Phase 2: Offline Earnings & Session Support](#phase-2-offline-earnings--session-support)
   - Tiered Offline Cap System
   - Hybrid Session Length Support
6. [Phase 3: Prestige System - "Donating to the Cause"](#phase-3-prestige-system---donating-to-the-cause)
   - Theme: Oren's Sacrifice
   - Goodwill Upgrades
   - What Resets vs Persists
7. [Phase 4: Stat Milestones](#phase-4-stat-milestones-levels-1-8-for-game-level-1)
   - Strength/Dexterity/Constitution/Intelligence/Wisdom/Charisma Milestones
   - Knowledge-Based Discovery: Stat-Based Environmental Insights
8. [Phase 5: Own Furnace & Worker Management](#phase-5-own-furnace--worker-management)
   - Unlock Timing
   - Worker Treatment System (Poor/Fair/Good)
   - Harmful Furnace Upgrades
9. [Phase 6: Environmental Management Systems](#phase-6-environmental-management-systems-split-into-sub-phases)
   - Phase 6A: Core Furnace Management
   - Phase 6B: Time & Airflow
   - Phase 6C: Dynamic Train Conditions
   - Phase 6D: Weather Events & Crises
   - Phase 6E: Train City Factors
10. [Implementation Roadmap (REVISED)](#implementation-roadmap-revised)
    - Week-by-week Development Plan
11. [Testing & Metrics Strategy](#testing--metrics-strategy)
    - Retention & Engagement Targets
    - Key Analytics & A/B Testing
12. [Complexity Growth Over Time](#complexity-growth-over-time-revised)
    - Prestige Progression (1 through 12+)
13. [Key Design Principles Summary](#key-design-principles-summary)
    - Core Principles & Best Practices
    - Success Criteria

---

## Core Design Philosophy

### Mysterious Gameplay
Players discover mechanics through experimentation rather than explicit numbers. Use qualitative feedback (adjectives, visuals, narrative hints) over quantitative data. or leave information out entirely

### Sacrifice Theme
Meaningful progress requires difficult choices. Treating workers well is morally right but mechanically harder. The player must balance conscience against necessity.

**Core Tension**:
- Poor treatment → easier gameplay, faster coal, moral cost
- Good treatment → harder gameplay, slower coal, moral reward

### Desert Train Setting
A massive train crossing endless desert, drawing electricity from the ground. Only Oren (protected by the green crystal) can survive leaving the train. The train is like a moving city with its own systems and challenges.

---

## Narrative Framework (Level 1: The Train)

**Protagonist**: Oren, a prisoner on a mysterious moving train
**Quest**: Escape with the help of a sentient green crystal sphere
**Setting**: Industrial train powered by coal furnaces crossing endless desert
**Truth**: The electrified ground kills anyone who leaves. Only Oren (with crystal protection) can escape.

**Key Story Beats**:
1. Hear whispers from the front of the train (existing mechanic)
2. Bribe barkeep for secret passage access (existing)
3. Solve puzzles to find the crystal sphere (existing)
4. Crystal reveals escape plan - need to gather items
5. Work your way up from shoveler to furnace overseer
6. Make moral choices about how to treat workers under you
7. Collect all escape items and transition to Level 2

### Knowledge-Based Discovery: "The Crystal's Language"

**Design Goal**: Players gradually understand how the crystal communicates - through observation, not tutorials.

**Progressive Understanding System** (story unfolds through pattern recognition):

#### Stage 1: Fragments (First Hour)
**What Players See**:
- Occasional cryptic whispers: "Keep working... gather your strength"
- Single words or incomplete thoughts
- Seems random, disconnected
- Players confused: "What IS this crystal?"

**What's Actually Happening**:
- Crystal is testing Oren's intelligence/awareness
- Only speaks when Oren demonstrates understanding (clicks efficiently, makes smart choices)
- Wisdom stat determines whisper frequency
- Players don't realize connection yet

#### Stage 2: Patterns (Hours 2-5)
**What Players Notice**:
- Whispers relate to recent actions
- "You learn quickly" (after efficient conversion)
- "Patience... not yet" (when about to make bad choice)
- Crystal seems to be... watching?

**Discovery**:
- Players realize crystal responds to behavior
- Experimentation: "Does it react to what I do?"
- Aha moment: "It's TEACHING me through hints!"
- Wisdom 5+ unlocks more frequent guidance

#### Stage 3: Dialogue (Hours 6-15, Furnace Ownership)
**What Players Experience**:
- Crystal speaks in full sentences now
- "Time to lead, not just follow" (furnace unlock prompt)
- Explains escape plan in broad strokes
- Asks philosophical questions about worker treatment
- Crystal has personality: pragmatic, curious, slightly alien

**Understanding**:
- Crystal respects competence - you've earned its trust
- It comments philosophically on moral choices
- Guidance increases with Wisdom stat investment
- Players feel relationship developing

#### Stage 4: Partnership (Hours 15-30, Environmental Mastery)
**What Players Experience**:
- Crystal offers environmental predictions (if Wisdom 8+)
- "The storm approaches from the west... prepare yourself"
- Shares lore about the train, desert, and why escape is possible
- Crystal reveals more about itself: ancient, not from this world
- Hints at larger mysteries beyond Level 1

**Realization**:
- Crystal and Oren are partners, not master/servant
- Your competence determines crystal's helpfulness
- Story unlocks tied to demonstrating mastery (not arbitrary gates)
- Crystal's respect is earned through skill

#### Stage 5: The Truth (Prestige 10+, Near Escape)
**What Players Learn**:
- Crystal reveals full escape plan details
- Explains why electrified ground exists
- Hints at Level 2's challenges
- Final moral test: "You've proven capable... but are you worthy?"
- Crystal evaluates journey, not just destination

**Climax**:
- Final story revelation tied to player's path (poor/fair/good treatment)
- Crystal's tone reflects how you played:
  - Poor treatment: "You survived. That's all that matters."
  - Fair treatment: "You did what was necessary. I respect that."
  - Good treatment: "You chose compassion despite cost. Rare."
- ALL paths complete story - tone differs, not content

**Knowledge-Based Progression Elements**:

1. **Stat-Gated Story**
   - Wisdom determines whisper frequency
   - Intelligence unlocks environmental hints
   - Charisma affects crystal's tone (friendlier vs. clinical)
   - Stats reveal story, don't block it

2. **Action-Triggered Narrative**
   - First prestige: Crystal explains Goodwill concept
   - Furnace ownership: Crystal questions your leadership style
   - Environmental mastery: Crystal shares desert lore
   - Moral choices: Crystal offers philosophical observations

3. **Discovery Through Attention**
   - Players who ignore crystal miss context (but not progress)
   - Players who listen carefully learn optimization secrets
   - Crystal occasionally hints at hidden mechanics
   - Attentive players discover "easter egg" lore

4. **Community Meta-Discovery**
   - Different Wisdom levels reveal different whispers
   - Players compare notes: "My crystal said X, yours said Y!"
   - Community pieces together full crystal personality
   - Encourages discussion without spoiling core mysteries

**Implementation**:
- NO dialogue trees or explicit story menus
- Whispers appear as ambient notifications (can be dismissed)
- Whisper log available for players who want to re-read
- Crystal never breaks the 4th wall (stays in-world)
- Tone is mysterious, not explanatory
- Players discover crystal's nature through observation

## Phase 0: Onboarding & Core Loop Feel (FOUNDATION)

### First 5 Minutes - Organic Tutorial

**Design Goal**: Players feel competent and understand core loop without explicit instruction.

**Experience Flow**:
1. **Auto-start in action** (no menu)
   - Player wakes up mid-shovel swing
   - Crystal whispers: "Keep working... gather your strength"
   - Clicking feels satisfying immediately (see Feedback section)

2. **First conversion** (after ~20 coal)
   - Overseer appears: "Give me that coal, prisoner. Now."
   - Dramatic animation: coal streams to overseer, coins drop
   - Player discovers: Coal → Coins transformation

3. **First upgrade** (50 coins earned)
   - Crystal: "Better tools will serve you well"
   - Shop button pulses (not intrusive)
   - Purchase feels rewarding (see Feedback section)

4. **Mood discovery** (natural)
   - Second conversion: Overseer reacts differently
   - "The overseer grunts. He seems indifferent."
   - No explanation - player experiments to understand

5. **First stat notification** (Strength Lv 2, ~5 minutes in)
   - "Your grip tightens on the shovel"
   - Player notices clicking power increased
   - Discovery: Working makes you stronger

**Progressive Disclosure**:
- Only show features when relevant (don't dump all UI at once)
- Shop unlocks items one at a time (not full catalog)
- Auto-conversion appears after 3 manual conversions
- Stats explained through milestones, not tutorials

### Game Feel & Feedback (CRITICAL)

**Every action must feel satisfying - this is retention foundation.**

#### Clicking/Shoveling
- **Visual**:
  - Shovel animates (swing arc)
  - Coal chunk flies with particle trail
  - Small screen shake (2-3 pixels, <100ms)
  - +Number popup (floats up, fades)
- **Audio**:
  - Shovel scrape (varies pitch slightly for variety)
  - Coal tumble sound
  - Satisfying "chunk" impact
  - Light grunt every 5th click (effort sound)
- **Timing**: <50ms response (critical for satisfaction)

#### Conversion (Coal → Coins)
- **Visual**:
  - Coal swirls into center (particle vortex)
  - Transforms into coin explosion
  - Coins scatter then collect into counter
  - Screen flash (subtle gold tint, 200ms)
  - Overseer animates (expression changes with mood)
- **Audio**:
  - Whoosh (coal gathering)
  - Mechanical clank (conversion)
  - Coin cascade sound
  - Overseer reaction (grunt/chuckle/laugh based on mood)
- **Text**: "The overseer was pleased! You earned a generous bonus."

#### Upgrade Purchase
- **Visual**:
  - Button glows → expands → contracts (juicy bounce)
  - Sparkle burst from button
  - Item icon flies to equipped slot
  - Character animation changes (better shovel visible)
- **Audio**:
  - Success jingle (tier-based: small/medium/large upgrades)
  - Metallic "click" confirmation
- **Text**: Narrative feedback, e.g., "Your shovel feels lighter in your hands"

#### Stat Level Up
- **Visual**:
  - Screen border flash (color coded: red=STR, green=DEX, etc.)
  - Character silhouette highlight
  - Stat bar fills and "dings"
- **Audio**:
  - Level up chime (rewarding tone)
  - Power-up sound effect
- **Text**: Thematic milestone (see Phase 4)

#### Environmental Changes
- **Visual**:
  - Gradual screen tint (hot=warm orange, cold=cool blue)
  - Particle weather (dust, wind, sand)
  - Background animation shifts
  - 30-second warning pulse before major changes
- **Audio**:
  - Ambient sound shifts (wind picks up, machinery strains)
  - Warning rumble (sandstorms)
- **Text**: Qualitative warnings ("The air feels heavy...")

### Goal Visibility System

**Design Principle**: Players always know what they're working toward.

**Always Visible UI Elements**:
```
┌─────────────────────────────────────┐
│ Current Goal: Auto-Shovel Lv2      │
│ Progress: 320/450 coins             │
│ ■■■■■■■□□□ (71%)                    │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Prestige Progress                   │
│ Equipment Spending: 8,200/10,000    │
│ Next Goodwill: 2 points             │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Escape Plan: 2/7 items found        │
└─────────────────────────────────────┘
```

**Dynamic Goals** (adapt to session type):
- **Short session (5-15 min)**:
  - "Collect offline earnings"
  - "Time 1 conversion with good mood"
  - "Purchase 1 upgrade"

- **Medium session (30-60 min)**:
  - Shows 3-5 step progression path
  - "Reach 1000 coins → Buy Auto-Shovel Lv3 → Approach prestige"

- **Long session (1-3 hours)**:
  - Multi-system optimization goals
  - "Optimize for prestige → Spend remaining coins → Reset for Goodwill"

**Prestige Readiness Indicator** (at 70% progress):
- Crystal begins glowing brighter
- Periodic whispers: "You're learning... soon you'll be ready to sacrifice"
- UI shows: "Prestige available at 10,000 spending"

---

## Phase 1: Overseer's Mood & Conversion System

3. **Historical Mood Memory**
   - answering overseer's questions correctly increases his mood, answering incorrectly decreases it

4. **Environmental Mood Modifiers** (Phase 6+ discovery)
Furnace running too hot or too cold prompts a notification comment from overseer and an adjustment down of mood

**Manual Mode Upgrades**:
- "Your smooth words help ease tensions" (reduces mood fatigue)
- "A generous bribe improves his disposition" (increases mood range)
- "You learn to read his expressions" (shows mood trend)
- "Your charm is undeniable" (faster fatigue recovery)

**Auto Mode Upgrades**:
- "Auto-Converter machine" (unlocks auto mode, 500 coins). button that appears in overseer's office
- "Better gears make smoother operation" (improves efficiency 70%→95%)
- "Silent mechanisms draw less attention" (reduces mood penalty)
- "Bulk processing reduces interruptions" (fewer mood hits)

---

## Phase 2: Offline Earnings & Session Support

### Tiered Offline Cap System

**Starting Cap**: 8 hours
**Quick Progression to 24h** (Levels 0-4, ~2000 total coins):
- Level 0→1: 8h → 12h (300 coins)
- Level 1→2: 12h → 16h (390 coins)
- Level 2→3: 16h → 20h (507 coins)
- Level 3→4: 20h → 24h (659 coins)

**Slower Progression Beyond** (Levels 5+, steeper costs):
- Level 5: 24h → 26h (1000 coins)
- Level 6: 26h → 28h (1500 coins)
- Level 7: 28h → 30h (2250 coins)
- And so on...

**Offline Mechanics**:
- Earns passive coal only (auto-shovels work)
- 50% efficiency penalty (upgradable)
- Shows notification: "You were away for X hours (capped at Y). You earned Z coal."
- If exceeded cap: "You missed N hours of earnings. Upgrade your offline cap!"

### Hybrid Session Length Support

**Short Sessions (5-15 min)**:
- Collect offline earnings
- Time 1-2 manual conversions (watch mood)
- Quick upgrade purchases
- Check worker status

**Medium Sessions (30-60 min)**:
- Active clicking with combos
- Strategic conversion timing
- Multiple upgrades & planning
- Worker management decisions

**Long Sessions (1-3 hours)**:
- Deep optimization
- Environmental factor management
- Push toward prestige
- Story progression

---

## Phase 3: Prestige System - "Donating to the Cause"

### Theme: Oren's Sacrifice

**Narrative**: Oren has learned valuable lessons. He donates his tools to prove his resolve to the crystal, earning its trust and strengthening his spirit/willpower.

**Currency**: **Goodwill Points**

**Calculation**: `floor(sqrt(equipment_coins_spent / 50))` *(adjusted for faster first prestige)*

**Examples**:
- 3,000 coins spent → 7 goodwill (first prestige target)
- 8,000 coins spent → 12 goodwill (second prestige)
- 20,000 coins spent → 20 goodwill (third prestige)
- 50,000 coins spent → 31 goodwill (later prestiges)

**Prestige Timing Philosophy**:
- **First prestige**: 45-60 minutes (teaches prestige loop early, hooks retention)
- **Second prestige**: 90-120 minutes (deeper optimization)
- **Third prestige**: 2-3 hours (meaningful investment)
- **Later prestiges**: 3-5+ hours (mastery content)

**Rationale**: Players need to experience the meta-game quickly to understand the full loop and stay engaged. Industry data shows first-day engagement duration predicts long-term retention.

### Prestige Dialog

```
"You've learned all you can from these tools.
Time to start fresh and push yourself harder.

The voice whispers: 'Sacrifice what you've built.
Prove your determination to escape.'

Reset your progress?"
[Donate Tools] [Keep Working]
```

**After Prestige**:
```
"Your tools are gone, but your resolve is stronger.
The crystal glows brighter - it approves of your sacrifice.

Goodwill Earned: X points"
```

### Goodwill Upgrades (Spirit/Willpower Theme)

**Permanent Bonuses** (qualitative descriptions):
- "Iron Will" (2 goodwill): "Your determination cannot be broken" (+click power)
- "Burning Purpose" (3 goodwill): "The crystal's energy flows through you" (start with coins)
- "Experienced Hand" (4 goodwill): "You know the tricks now" (early unlocks)
- "Resilient Mind" (5 goodwill): "Nothing will stop your escape" (+all production)
- "Leader's Presence" (6 goodwill): "Others follow your example" (better mood start)
- "Clear Vision" (8 goodwill): "You see the path ahead" (+offline cap)
- "Unshakable Resolve" (10 goodwill): "Sacrifice makes you stronger" (mood fatigue resistance)
- "Martyr's Strength" (12 goodwill): "The hardest choices require the strongest wills" (unlock furnace)

### What Resets vs Persists

**RESETS**:
- Coal, coins
- All shop upgrades (shovel, plow, auto-shovel levels)
- Conversion mode settings
- Furnace ownership (if unlocked)
- Workers (if any)

**PERSISTS**:
- All 6 core stats (Str, Dex, Int, Wis, Con, Cha)
- Goodwill points & upgrades
- Escape items (story progress)
- Unlocked areas
- Stat milestones achieved

---

## Phase 4: Stat Milestones (Levels 1-8 for Game Level 1)

### System Overview

**3 milestones per stat** between experience levels 1-8
**Only show in Game Level 1** - once player reaches Level 2, stop showing these notifications
**New milestones for levels 9+** will be created for Level 2 and beyond

### Strength Milestones
- **Lv 2**: "Your grip tightens on the shovel" (+small click power)
- **Lv 5**: "You can work longer without tiring" (stamina cost reduction)
- **Lv 8**: "The guards notice your physique" (unlock: intimidate for small bonuses)

### Dexterity Milestones
- **Lv 2**: "Your movements become more precise"
- **Lv 5**: "You learn to read the overseer's expressions" (see mood trend)
- **Lv 8**: "Quick hands make quick work" (unlock: rapid conversion option)

### Constitution Milestones
- **Lv 2**: "Your endurance improves"
- **Lv 5**: "You barely feel the heat anymore" (temperature tolerance)
- **Lv 8**: "Your body adapts to the harsh conditions" (+max stamina, reduced fatigue)

### Intelligence Milestones
- **Lv 2**: "You notice patterns in the furnace behavior"
- **Lv 5**: "The train's systems make sense now" (unlock: efficiency insights)
- **Lv 8**: "You understand the overseer's moods" (better conversion timing hints)

### Wisdom Milestones
- **Lv 2**: "You sense the crystal's presence growing stronger"
- **Lv 5**: "You can hear whispers in the coal dust"
- **Lv 8**: "The voice speaks clearer - it's guiding you" (story progression)

### Charisma Milestones
- **Lv 2**: "Others begin to listen when you speak"
- **Lv 5**: "You've earned respect among the workers"
- **Lv 8**: "Even the guards treat you differently" (better prices, access)

### Knowledge-Based Discovery: Stat-Based Environmental Insights

**Design Goal**: Higher stats reveal subtle environmental clues, rewarding stat investment with knowledge.

**Stat-Gated Observations** (never explicit, always thematic):

#### Intelligence-Based Insights
- **Int 3+**: Occasional subtle notification
  - "The furnace burns differently today..." (temperature about to shift)
  - "Something feels off about the coal quality..." (mixed batches)
- **Int 6+**: Pattern recognition hints
  - "The train's rhythm changed... we're climbing" (speed variation incoming)
  - "Three days since the last sandstorm... another is due" (weather prediction)
- **Int 8+**: System understanding
  - Better conversion timing hints (mood pattern recognition)
  - Environmental prediction accuracy improves
  - See hidden efficiency factors

#### Wisdom-Based Insights
- **Wis 3+**: Crystal whispers more frequently
  - "The desert remembers patterns..." (seasonal hints)
  - "Listen to the wind... it speaks of change" (weather warnings)
- **Wis 6+**: Environmental intuition
  - "Your instincts warn you..." (30-second early warnings for crises)
  - Subtle visual cues more pronounced (easier to spot patterns)
- **Wis 8+**: Crystal reveals deeper mysteries
  - Story progression unlocks
  - Hidden upgrade paths revealed through crystal guidance
  - Environmental "sweet spots" hinted at

#### Dexterity-Based Insights
- **Dex 3+**: Better timing feedback
  - Conversion button pulses subtly at good mood moments
  - Furnace controls more responsive
- **Dex 6+**: Precision advantages
  - Can fine-tune temperature to exact degrees (others see rough ranges)
  - Airflow adjustments more granular
- **Dex 8+**: Perfect timing mastery
  - Visual "sweet spot" indicators for conversions (very subtle)
  - Critical success opportunities on perfect timing

#### Constitution-Based Insights
- **Con 3+**: Temperature tolerance
  - "You notice the heat less than others" (work in hotter conditions)
  - Longer stamina for active management
- **Con 6+**: Environmental adaptation
  - See worker fatigue before it impacts production
  - Detect air quality issues earlier
- **Con 8+**: Endurance mastery
  - Can push systems harder without breakage
  - Longer optimal temperature ranges

#### Strength-Based Insights
- **Str 3+**: Physical understanding
  - "You feel the shovel's balance... this coal is heavier" (quality detection)
  - Notice equipment wear before failures
- **Str 6+**: Equipment mastery
  - Can operate furnace at higher intensities safely
  - Better understanding of coal consumption rates
- **Str 8+**: Maximum output potential
  - Unlock "overcharge" moments (temporary production bursts)
  - Physical intimidation affects worker morale (both good and bad)

#### Charisma-Based Insights
- **Cha 3+**: Social awareness
  - Workers drop hints about upcoming events
  - Overseer's mood shifts more predictable (body language)
- **Cha 6+**: Leadership intuition
  - Workers warn about guard patrols
  - Better prices in shop (subtle discount)
- **Cha 8+**: Social mastery
  - Workers actively help with optimization tips
  - Guards overlook minor infractions

**Aha Moment**: "My stats aren't just numbers - they're teaching me how to SEE the game's hidden systems!"

**Implementation Philosophy**:
- Stats don't give explicit bonuses - they reveal KNOWLEDGE
- Higher stats = better clues, not direct power
- Players feel smart discovering what stats unlock
- Thematic hints only, never mechanical explanations
- Encourages balanced stat investment (each reveals different secrets)

---

## Phase 5: Own Furnace & Worker Management

### Unlock Timing
**When**: 6-8 hours gameplay, Prestige 3-4
**Requirements**:
- 8+ Goodwill points
- 10,000 coin purchase
- Charisma 8+
- Story beat: "The crystal whispers: Time to lead, not just follow"

### Worker Treatment System (FINAL - Skill-Based Balance)

**Design Goal**: Create meaningful moral choice through difficulty and playstyle, NOT through content gates. Both paths can beat the game.

#### Poor Treatment (Easy Mode - 0 coins/sec upkeep)

**The Pitch**: Immediate power, low skill requirement, reliable but lower ceiling

**Mechanics**:
- **Base Performance**: Constant +20% coal output
- **Reliability**: 75% consistent (occasional worker strikes/escapes cause 5-minute downtime)
- **Effective Average**: **70-75% above baseline** when accounting for interruptions
- **Skill Floor**: LOW - works immediately, no learning curve
- **Skill Ceiling**: LOW - optimize timing around strikes, but limited depth

**Pros**:
- ✅ Zero upkeep costs (pure profit)
- ✅ Immediate power boost (+20% from fear)
- ✅ Simple management (mostly set-and-forget)
- ✅ Great for idle/offline play
- ✅ Forgiving for new players

**Cons**:
- ❌ Random interruptions (5-min production stops from strikes/escapes)
- ❌ Must occasionally rehire workers (costs coins + time)
- ❌ Guard investigations (bribe costs ~200 coins/hour)
- ❌ Lower optimization ceiling (can't push beyond 75%)

**Narrative Consequences** (emotional only, no mechanical gates):
- Guilt notifications: "A worker collapsed. His replacement arrived this morning."
- Dark atmosphere, exhausted worker visuals
- Crystal comments: "Is this who you want to be?" (philosophical, not punishing)

---

#### Fair Treatment (Balanced - 2 coins/sec per worker)

**The Pitch**: Stable middle ground, predictable and safe

**Mechanics**:
- **Base Performance**: Standard baseline output
- **Reliability**: 100% consistent (no interruptions)
- **Effective Average**: **Exactly baseline** (0% bonus)
- **Skill Requirement**: NONE - completely passive

**Pros**:
- ✅ Zero surprises (completely stable)
- ✅ No management overhead
- ✅ Low upkeep costs (affordable)
- ✅ No moral weight

**Cons**:
- ❌ No performance bonuses
- ❌ No unique upgrades or advantages
- ❌ "Safe but boring" - no optimization potential

**Narrative Consequences**: Neutral - workers do their job, nothing special

---

#### Good Treatment (Hard Mode - 5 coins/sec per worker)

**The Pitch**: Brutal early game, highest potential for skilled players

**Mechanics**:
- **Week 1-2**: NEGATIVE RETURNS (-5% efficiency while workers learn to trust you + upkeep costs exceed income)
- **Week 3**: Breaking even (workers now match baseline + upkeep is affordable)
- **Week 4+**: Gradual scaling (+2% per week, caps at +18% at Week 12)
- **Reliability**: 100% consistent (zero interruptions)
- **Effective Average**: **80-85% above baseline** for skilled players who survive early game
- **Skill Floor**: VERY HIGH - many players will fail and switch away
- **Skill Ceiling**: VERY HIGH - timing, upgrade optimization, income management mastery

**Pros**:
- ✅ Highest performance ceiling (+18% coal, 100% reliable = 80-85% average for skilled play)
- ✅ Zero interruptions (workers never strike, never quit, never investigated)
- ✅ Unique loyalty upgrades (efficiency tricks only available here)
- ✅ Crisis assistance (workers auto-fix furnace issues)
- ✅ Environmental warnings (60-second advance notice)
- ✅ Gradual loyalty multiplier (scales with time invested)

**Cons**:
- ❌ **BRUTAL Week 1-2** (actively losing efficiency + paying upkeep = very hard)
- ❌ High upkeep (5 coins/sec requires careful income balancing)
- ❌ Requires active management (not idle-friendly early)
- ❌ Must plan strategically (upgrade timing, conversion optimization)
- ❌ High skill requirement (many players will fail)

**Narrative Consequences** (emotional only, no mechanical gates):
- Satisfaction notifications: "The workers are singing. They trust you."
- Bright atmosphere, healthy worker visuals
- Crystal comments: "Your compassion is rare. I respect it." (approving, not rewarding)

---

### The Skill-Based Dilemma (Design Math)

**Poor Treatment (Easy, 70-75%)**:
- ✅ Immediate results, low skill floor
- ✅ Great for casual/idle players
- ❌ Lower ceiling, random interruptions
- ❌ Can't optimize beyond 75%

**Good Treatment (Hard, 80-85%)**:
- ✅ Highest ceiling for skilled players
- ✅ Zero RNG interruptions (100% reliable)
- ❌ Brutal Weeks 1-2 (many will quit)
- ❌ Requires mastery of income management

**Gap When Both Optimized**: 5-10% advantage for good treatment
- Good treatment rewards skill with slightly better performance
- Poor treatment is easier and performs well (viable for beating game)
- Fair treatment is the safe middle ground (no optimization)

**Crystal's Role**: Pragmatic alien intelligence, not moral judge
- Crystal helps ALL players equally with story progression
- Crystal comments on your choices philosophically (adds narrative weight)
- Crystal does NOT gate content or story based on treatment choice
- All treatment paths can complete the game and see the full story

---

### Story Access: FULL ACCESS FOR ALL PATHS

**CRITICAL DESIGN RULE**: Morality affects narrative tone and mechanical difficulty, NOT content access.

**Story Progression**:
- Crystal provides equal guidance to all treatment paths
- Escape items are accessible regardless of worker treatment
- No "true ending" locked behind good treatment
- No exploration penalties for poor treatment

**Why This Matters**:
- Moral choice is about WHO YOU WANT TO BE, not about unlocking content
- Players choosing poor treatment aren't punished with less game
- Difficulty and emotional weight are the consequences, not story gates
- Both paths feel complete and satisfying

---

### Making the Choice Matter

**Switching Costs** (prevents flip-flopping):
- Changing treatment takes 30 minutes to take effect
- Switching TO good treatment after poor: "Workers don't trust you. Loyalty takes time to rebuild." (restarts Week 1-2 penalty)
- First switch is free, subsequent switches cost coins

**Visual & Atmospheric Feedback**:
- Poor: Workers exhausted, guards patrol, dark/oppressive atmosphere, somber music
- Fair: Workers neutral, normal lighting, ambient sounds
- Good: Workers healthy/happy, lighter atmosphere, uplifting music, crystal glows brighter

### Harmful Furnace Upgrades (Productivity at Cost)

**Examples**:
1. "Overclocked Furnace" (1500 coins)
   - +30% production
   - Workers take heat damage (morale drops faster)

2. "Extended Shifts" (2000 coins)
   - +40% production (20-hour shifts)
   - Worker exhaustion (random failures)

3. "Dust Reclaimer" (2500 coins)
   - Recycles coal dust for bonus production
   - Toxic fumes harm workers (-15% efficiency, health issues)

4. "Pressure Valves Disabled" (3000 coins)
   - Max efficiency (safety removed)
   - Risk of catastrophic failure (random huge losses + deaths)

5. "Starvation Rations" (1000 coins)
   - -50% upkeep costs
   - Workers produce 20% less (malnutrition)
   - Occasional deaths

**Moral Weight**: Each shows consequences
- "Three workers collapsed from heat exhaustion"
- "A worker died in the night. His family will never know."
- "You hear coughing through the furnace walls"

**Crystal's Commentary**: Offers philosophical observations, doesn't punish mechanically
- "Efficiency at any cost... is that your path?"
- "The workers suffer, but the train moves on."
- No mechanical penalties - these are narrative choices with emotional weight only

---

## Phase 6: Environmental Management Systems (SPLIT INTO SUB-PHASES)

**CRITICAL DESIGN CHANGE**: Introduce complexity gradually over multiple prestige cycles to avoid cognitive overload.

---

### Phase 6A: Core Furnace Management (Prestige 4-5, ~10-15 hours)

**Design Goal**: Introduce foundational environmental mechanics (2 systems only)

#### Coal Quality Management
**The System**: Different coal types suit different conditions

**Coal Types**:
- **Regular Coal** (baseline): Balanced burn rate, always available
- **Fine Coal** (burns hot & fast): +30% efficiency for 5 min, then depleted
  - Best for: Cold nights, train speed surges
  - Cost: 2x regular coal price
- **Coarse Coal** (burns slow & steady): -10% power, lasts 3x longer
  - Best for: Stable periods, overnight idle
  - Cost: 1.5x regular coal price

**Player Discovery**:
- Shop unlocks coal types without explanation
- Players experiment to learn optimal usage
- Wisdom stat provides hints: "Fine coal burns brilliantly... but briefly"

**Strategic Depth**:
- Pre-purchase coal for anticipated conditions
- Balance spending vs. efficiency gains
- Learn when each type provides advantage

#### Temperature Regulation
**The System**: Balance furnace heat vs. worker safety vs. train needs

**Temperature States**:
- **Too Cold** (<800°F): Train slows, guards investigate, coal demand increases
- **Optimal** (800-1200°F): Normal operations
- **Too Hot** (>1200°F): Workers suffer (-20% efficiency), injury risk
- **Dangerous** (>1500°F): Equipment damage, worker deaths, crystal warns

**Controls**:
- Furnace intensity dial (player adjusts manually)
- Visual feedback: thermometer + color-coded flames (blue → orange → red)
- Audio feedback: Machinery strain sounds at extremes

**Environmental Interactions**:
- Desert day (120°F outside): Harder to keep cool, workers heat-stressed
- Desert night (40°F outside): Easier cooling, but train needs more heat
- Sandstorms: Temperature fluctuates unpredictably

**Mastery**: Learn optimal temperature curves for different situations

### Knowledge-Based Discovery: Coal Synergy Combinations

**Design Goal**: Players discover that mixing coal types creates emergent effects - never explained, always discovered.

**Hidden Synergy System** (entirely undocumented):

1. **The "Kindling" Combo**
   - Fine coal → Regular coal (rapid transition)
   - Effect: Fine coal "primes" the furnace, next regular coal burns +15% hotter
   - Discovery: Players notice furnace staying hot longer after fine coal
   - Aha moment: "Wait... the order I use coal MATTERS?"

2. **The "Banker" Combo**
   - Coarse coal → Fine coal (slow to fast)
   - Effect: Coarse coal's embers make fine coal last 2x longer
   - Discovery: Experimentation shows fine coal lasting unusually long
   - Aha moment: "I can extend fine coal's duration with prep!"

3. **The "Steady Burn" Combo**
   - Regular → Coarse → Regular (sandwich pattern)
   - Effect: Creates ultra-stable temperature (±5°F variance vs. ±20°F normal)
   - Discovery: Temperature graph shows unusual stability
   - Aha moment: "This pattern creates perfect consistency!"

4. **The "Overdrive" Combo** (Advanced)
   - Fine → Fine → Fine (triple stack)
   - Effect: Temporary +50% output but risks furnace damage (5% chance per use)
   - Discovery: Desperate players spam fine coal, notice huge spike + risk
   - Aha moment: "Huge power... but dangerous. Worth it for prestige push!"

5. **The "Hibernation" Combo** (Offline optimization)
   - Coarse → Coarse → Coarse (before long absence)
   - Effect: Extends offline earnings cap by 2 hours (one-time)
   - Discovery: Players notice offline earnings lasting longer than expected
   - Aha moment: "I can prep the furnace for my absence!"

**Discovery Clues** (never explicit):
- Intelligence 6+: "The furnace remembers the last fuel type..."
- Workers (good treatment): "Mixing coals? Interesting... the old-timers used to do that"
- Crystal whispers: "Fire has memory, prisoner. What you feed it first shapes what follows"
- Wisdom 8+: "You sense patterns in the flames... echoes of previous burns"

**Implementation**:
- NO tutorial, NO documentation in-game
- System is 100% functional but hidden
- Community discovery expected (Reddit/Discord meta)
- Players who discover combos feel like geniuses
- Combos work consistently (not RNG) - patterns are real

### Knowledge-Based Discovery: Hidden Temperature "Sweet Spots"

**Design Goal**: Optimal temperatures vary by conditions - players discover through experimentation, not guides.

**Dynamic Sweet Spot System** (changes based on context):

1. **Time-of-Day Sweet Spots**
   - **Dawn** (6am-12pm): 950-1050°F optimal (cool outside, moderate heat needed)
   - **Midday** (12pm-6pm): 850-950°F optimal (external heat helps, lower furnace temp)
   - **Dusk** (6pm-12am): 1000-1100°F optimal (temperature dropping, need more heat)
   - **Night** (12am-6am): 1100-1200°F optimal (cold desert, maximum safe heat)
   - **Never told** - players discover watching efficiency over time

2. **Coal-Type Sweet Spots**
   - **Fine coal**: Works best at 1100-1200°F (hot and fast)
   - **Regular coal**: Works best at 900-1100°F (baseline)
   - **Coarse coal**: Works best at 800-1000°F (low and slow)
   - Hitting sweet spot: +10% efficiency bonus (not shown, just felt)
   - Missing sweet spot: Penalty (coal wastes or burns wrong)

3. **Worker Treatment Sweet Spots**
   - **Poor treatment**: 1000°F max (workers can't handle heat well)
   - **Fair treatment**: 1100°F max (normal tolerance)
   - **Good treatment**: 1200°F max (healthy workers tolerate more)
   - Good treatment workers also warn: "It's getting too hot in here!"

4. **Train Speed Sweet Spots**
   - **Racing**: 1150-1250°F (high demand, push harder)
   - **Normal**: 900-1100°F (standard operations)
   - **Crawling**: 850-950°F (low demand, save fuel)
   - Players learn to adjust preemptively for speed changes

5. **Weather Sweet Spots**
   - **Sandstorm approaching**: 950°F (stable, safe from fluctuations)
   - **Clear day**: 1050°F (can push harder)
   - **Heat wave**: 800-900°F (external heat compensates)
   - **Cold snap**: 1100-1200°F (compensate for extreme cold)

**Aha Moment**: "Temperature isn't just 'hot enough' - there's a PERFECT temp for every situation!"

**Discovery Clues** (visual, never numerical):
- Flames glow slightly brighter in sweet spot (subtle visual cue)
- Machinery sounds smoother (audio feedback)
- Workers look more comfortable (visual feedback)
- Efficiency graph shows small peaks (requires observation)
- Dexterity 6+: Temperature dial shows very subtle "optimal zone" shading

**Implementation**:
- Sweet spots exist mechanically (+10% efficiency bonus)
- NO explicit notifications or indicators
- Players must observe flames, workers, efficiency over time
- High Dexterity/Intelligence stats make clues slightly more obvious
- Mastery feels rewarding - "I KNOW the perfect temp for every condition!"

---

### Phase 6B: Time & Airflow (Prestige 6-7, ~18-22 hours)

**Design Goal**: Add temporal rhythms and reactive environmental mechanics

#### Time of Day Cycling
**The System**: Worker performance and conditions vary throughout day

**Day Phases** (6-hour cycles in real-time, or accelerated in-game):
- **Dawn** (6am-12pm): Workers fresh (+15% efficiency), cool temperatures
- **Midday** (12pm-6pm): Desert heat peaks, temperature management critical
- **Dusk** (6pm-12am): Workers tiring (-10% efficiency), temperatures dropping
- **Night** (12am-6am): Cold desert, different fuel needs, workers resting

**Strategic Planning**:
- Schedule heavy production during dawn
- Prepare cooling for midday
- Use coarse coal overnight
- Plan conversions around worker efficiency peaks

**Visual Feedback**: Sky color, sun/moon position, ambient lighting changes

#### Airflow Control
**The System**: Adjust ventilation based on air quality

**Airflow States**:
- **Closed Vents**: Protects from external conditions, reduces efficiency (-20%)
- **Partial Flow**: Balanced, moderate efficiency
- **Open Vents**: Maximum oxygen, maximum efficiency (+15%), vulnerable to storms

**Air Quality Conditions**:
- **Clear**: Open vents = optimal
- **Dusty**: Partial flow recommended
- **Sandstorm**: Close vents or suffer equipment damage
- **Toxic** (from other furnaces): Ventilation dilemma (efficiency vs. worker health)

**Player Cues**:
- "The air tastes of sand today"
- Visual: Dust particles in air, workers coughing
- 30-second warnings before storms hit

**Mastery**: Anticipate weather, adjust proactively

### Knowledge-Based Discovery: Environmental Calendar & Desert Seasons

**Design Goal**: The desert has predictable rhythms - players discover patterns through observation over real-time play.

**Hidden Calendar System** (cycles over real-world days/weeks):

1. **Week-Long Weather Patterns** (7-day cycles)
   - **Days 1-2**: Clear, stable (easy mode)
   - **Days 3-4**: Dust increasing (moderate)
   - **Days 5-6**: High sandstorm risk (prepare!)
   - **Day 7**: Post-storm calm (recovery)
   - Pattern repeats, but with variation
   - **Never told** - players notice after 2-3 weeks of play

2. **Monthly Temperature Cycles** (30-day seasons)
   - **Days 1-10**: "Cool Season" (easier temperature management)
   - **Days 11-20**: "Moderate Season" (baseline)
   - **Days 21-30**: "Heat Wave Season" (challenging temperature balance)
   - Subtle gradual transitions (not sudden jumps)
   - Players who track patterns optimize coal purchasing

3. **Ground Electricity Tides** (3-day micro-cycles)
   - Follows predictable pattern: High → Normal → Low → Normal → repeat
   - Synced with in-game "moon phases" (visual clue in sky)
   - Moon full = high electricity, moon new = low electricity
   - Players learn to watch the sky for electricity prediction

4. **Train Route Landmarks** (repeating journey)
   - Train follows circular route, returns to "kilometer 0" every 14 real days
   - Certain landmarks = predictable conditions:
     - "The Red Rocks": Always hot, sandstorm risk
     - "The Salt Flats": Stable temps, high electricity
     - "The Iron Canyon": Cold, echoing (worker morale bonus)
   - Crystal occasionally mentions: "We're approaching the Red Rocks again..."
   - Players learn route = predict conditions days in advance

5. **Worker Morale Cycles** (influenced by train journey)
   - Workers more optimistic near certain landmarks
   - More pessimistic in harsh areas
   - Morale affects good treatment path effectiveness
   - Pattern emerges: good treatment thrives in "home stretch" of route

**Aha Moment**: "This isn't random - the desert has SEASONS! I can plan weeks ahead!"

**Discovery Clues** (extremely subtle):
- Intelligence 8+: "You've seen this pattern before... three days until the storm"
- Wisdom 6+: "The desert breathes in cycles. Learn them, and you'll thrive"
- Crystal whispers: "Time moves in circles here, prisoner. Watch the sky"
- Workers (good treatment): "Storm season's coming. Always does this time of month"
- Visual sky changes: Moon phases, star positions, distant landmark silhouettes

**Implementation**:
- Real-time calendar runs in background (persists across sessions)
- Patterns are consistent and learnable (not RNG)
- Players can't see calendar explicitly - must deduce from observation
- Long-term players (Month 2+) have massive advantage from pattern knowledge
- Community wikis will document patterns (expected and encouraged)
- New players feel overwhelmed, veterans feel masterful

**Meta-Progression Layer**:
- First prestige cycle: Patterns seem random
- Prestige 3-5: Start noticing repetitions
- Prestige 6+: Actively planning around calendar
- Prestige 10+: Mastery - optimize entire week-long cycles

---

### Phase 6C: Dynamic Train Conditions (Prestige 8-9, ~25-30 hours)

**Design Goal**: Add macro-level factors requiring strategic adaptation

#### Train Speed Variations
**The System**: Train speed affects coal demand and scrutiny

**Speed States**:
- **Racing**: +50% coal demand, higher quotas, urgent pressure
  - "The train is racing! Feed the furnace faster!"
- **Normal**: Baseline demands
- **Crawling**: -30% coal demand, but guards are bored (more scrutiny)

**Causes**:
- Ground electricity fluctuations
- Scheduled stops/departures
- Emergency situations
- Terrain (uphill/downhill)

**Strategic Response**: Adjust production goals, manage guard attention

#### Ground Electricity
**The System**: Train draws power from electrified ground (lore mechanic)

**Electricity Levels**:
- **High**: Train moves efficiently, -30% coal demand
  - "The ground crackles with energy"
- **Normal**: Standard demand
- **Low**: More coal needed (+40% demand)
- **Fluctuating**: Constant adjustments needed (active management)

**Visual Feedback**: Lightning arcs under train, electrical hum audio

**Interaction**: Affects train speed, which affects coal demand, which affects worker load

---

### Phase 6D: Weather Events & Crises (Prestige 10-11, ~35-40 hours)

**Design Goal**: Add dramatic events requiring decision-making

#### Sandstorms (Random Events)
**Warning Phase** (5 minutes before):
- "Dark clouds gather on the horizon"
- Sky darkens, wind picks up
- Players can prepare: close vents, switch coal types, brace workers

**Storm Phase** (10-15 minutes):
- **If vents closed**: Production -40%, but no damage
- **If vents open**: Production maintained, but:
  - Equipment damage (costs coins to repair)
  - Workers injured (must rest, hire replacements)
  - Sand infiltration (30-minute efficiency penalty after)

**Aftermath**:
- Cleanup costs/time
- Learning opportunity: prepare better next time

**Mastery**: Optimal preparation minimizes impact

#### Other Crisis Events
**Heat Waves**: Extended midday heat, cooling management critical
**Cold Snaps**: Overnight temperatures plummet, heating challenges
**Electrical Surges**: Ground electricity spikes, train races uncontrollably
**Equipment Failures**: Furnace malfunctions, must adapt while repairing

---

### Phase 6E: Train City Factors (Prestige 12+, ~50+ hours)

**Design Goal**: Add social/political layer for deep endgame complexity

#### Water Supply System
**Affects**: Worker health, morale, production capacity

**States**:
- **Plentiful**: No issues
- **Rationed**: Workers weaker (-10% efficiency), need more rest
- **Scarce**: Health crisis, must choose which workers get water
  - "Water rations are down to half. The workers look parched."

**Management**: Can buy water supplies (costs coins) or accept penalties

#### Population Pressure
**Mechanic**: Train population affects worker availability and coal quotas

- **High Population**: More workers to hire, but higher coal quotas
- **Low Population**: Fewer workers, lower quotas
- **Refugee Events**: "The train took on refugees at the last station" (sudden spike)

#### Food Distribution
**Affects**: Worker availability and treatment effectiveness

- **Well-Fed**: Workers available, normal operations
- **Starving**: Desperate workers accept poor treatment easier
  - "The food cars are running low. People are getting desperate."

#### Guard Patrol Intensity
**Affects**: Freedom to act, suspicion mechanics

- **Light Patrols**: Easy to manage workers, less scrutiny
- **Heavy Patrols**: Must be careful, poor treatment detected faster
- **Corrupt Guards**: Can bribe for freedom (costs coins but worth it)
  - "The guards are bored today. They're watching everything."

**Integration**: These systems interact with worker treatment choices (Phase 5)

### Active Management Loop

**Short Check-in (5-10 min)**:
1. Check environmental conditions
2. Adjust one or two settings
3. React to immediate crisis
4. Quick conversion timing

**Medium Session (30-60 min)**:
1. Monitor multiple factors
2. Plan adjustments for coming conditions
3. Balance worker treatment vs current needs
4. Strategic conversion timing
5. Purchase upgrades

**Long Session (1-3 hours)**:
1. Deep optimization across all systems
2. Respond to multiple overlapping crises
3. Make moral choices under pressure
4. Plan multi-step strategies
5. Push toward prestige goals

**Mastery**: Learning to predict and prepare
- "Sandstorm season coming - stock coarse coal"
- "Night shift needs extra heat - adjust preemptively"
- "Heavy patrols tomorrow - better treat workers well today"

---

## Implementation Roadmap (REVISED)

### Week 1-2: Phase 0 - Onboarding & Core Feel
- [ ] Create auto-start intro sequence (no menus)
- [ ] Implement all clicking feedback (visual/audio/juice)
- [ ] Build conversion animations and feedback
- [ ] Add upgrade purchase feedback
- [ ] Create stat level-up effects
- [ ] Design goal visibility UI system
- [ ] Build progressive disclosure system
- [ ] **PLAYTEST**: Internal (10 players, 30 min) - "Is clicking satisfying?"
  - Measure: Do testers continue past 15 min voluntarily?
  - Goal: 70%+ continue

### Week 3-4: Phase 1 - Mood System + Phase 4 - Stat Milestones
- [ ] Implement mood system with adjective descriptions
- [ ] Remove all explicit multiplier displays
- [ ] Add flavor text for all upgrades
- [ ] Create mood-to-adjective mapping
- [ ] Add trend indicators (no numbers)
- [ ] Build conversion toggle UI
- [ ] Create 18 milestones (3 per stat, levels 1-8)
- [ ] Implement game level tracking
- [ ] Add milestone notification system
- [ ] Connect milestones to mechanical unlocks
- [ ] **PLAYTEST**: Friends/family (15 players, 1 hour) - "Are goals clear?"
  - Track: Confusion points, questions asked, drop-off timing
  - Goal: <3 avg questions per player

### Week 5-6: Phase 3 - Prestige System (ADJUSTED TIMING)
- [ ] Track lifetime equipment spending
- [ ] Implement goodwill calculation (`sqrt(spending/50)`)
- [ ] Create prestige UI and confirmation dialogs
- [ ] Build goodwill upgrade tree
- [ ] Add reset/persist logic
- [ ] Update narrative (sacrifice theme)
- [ ] **Target: 45-60 min to first prestige** (critical!)
- [ ] Add prestige readiness indicator (70% warning)
- [ ] **PLAYTEST**: Target audience (30 players, 2 hours) - "Prestige timing right?"
  - Measure: Prestige completion rate, second run engagement
  - Goal: 60%+ complete first prestige, 80%+ start second run

### Week 7-8: Phase 2 - Offline Earnings & Balance Pass
- [ ] Implement tiered offline cap system
- [ ] Add offline cap upgrades (8h→24h quick, then slower)
- [ ] Create offline earnings calculation
- [ ] Add notifications for cap exceeded
- [ ] **REBALANCE ALL COSTS** (major tuning for 45-60min prestige)
- [ ] Tune overseer mood drift rates
- [ ] Adjust upgrade cost curves
- [ ] Test short/medium/long session flows

### Week 9-10: Phase 5 - Furnace & Workers (REVISED BALANCE)
- [ ] Unlock at 6-8 hours gameplay (Prestige 3-4)
- [ ] Implement three-tier worker treatment system
- [ ] Add poor treatment: sabotage, escapes, guard investigations
- [ ] Add good treatment: unique upgrades, Goodwill bonus, warnings
- [ ] Create harmful upgrade tree with consequences
- [ ] Add moral consequence notifications
- [ ] Implement crystal approval/disapproval system
- [ ] Add treatment switching costs
- [ ] **PLAYTEST**: Alpha test (50 players, 8 hours) - "Treatment balanced?"
  - Measure: Treatment distribution, player sentiment, prestige timing
  - Goal: 30/40/30 split across poor/fair/good

### Week 11-12: Phase 6A - Core Furnace (Prestige 4-5)
- [ ] Implement coal quality types (regular/fine/coarse)
- [ ] Create coal type shop UI
- [ ] Add temperature regulation system
- [ ] Build temperature dial control
- [ ] Create visual feedback (thermometer, flame colors)
- [ ] Add audio feedback (machinery strain)
- [ ] Connect temperature to day/night cycle
- [ ] Add worker injury risk at high temps
- [ ] **2 SYSTEMS ONLY** - no more complexity yet

### Week 13-14: Phase 6B - Time & Airflow (Prestige 6-7)
- [ ] Implement time of day cycling system
- [ ] Add day phase effects (dawn/midday/dusk/night)
- [ ] Create visual feedback (sky colors, lighting)
- [ ] Build airflow control system
- [ ] Add air quality states (clear/dusty/sandstorm/toxic)
- [ ] Create 30-second storm warnings
- [ ] Connect airflow to weather conditions

### Week 15-16: Polish, Accessibility & Beta Test
- [ ] Add screen shake options (accessibility)
- [ ] Implement colorblind modes (shapes + colors)
- [ ] Add reduced motion option
- [ ] Create larger text mode
- [ ] Add auto-clicker assist option
- [ ] Implement save state backup system
- [ ] Write all remaining flavor text
- [ ] **PLAYTEST**: Beta test (100 players, 20+ hours) - "Full systems work?"
  - Measure: Session lengths, drop-off points, progression speed
  - Goal: Day 7 retention >20%
- [ ] Final balancing pass based on beta data

### Week 17-18: Phase 6C - Dynamic Train (Prestige 8-9) [POST-LAUNCH]
- [ ] Implement train speed variations
- [ ] Add ground electricity system
- [ ] Create speed-based coal demand adjustments
- [ ] Add electrical visual/audio feedback

### Week 19-20: Phase 6D - Weather Events (Prestige 10-11) [POST-LAUNCH]
- [ ] Create sandstorm warning system
- [ ] Build sandstorm damage/protection mechanics
- [ ] Add heat waves and cold snaps
- [ ] Implement electrical surges
- [ ] Create equipment failure events

### Week 21-22: Phase 6E - Train City (Prestige 12+) [POST-LAUNCH]
- [ ] Add water supply system
- [ ] Implement population pressure mechanics
- [ ] Create food distribution system
- [ ] Add guard patrol variations
- [ ] Connect all city systems to worker treatment

---

## Testing & Metrics Strategy

### Retention Targets (Must Hit for Success)
- **Day 1**: 40%+ retention
- **Day 7**: 20%+ retention
- **Day 30**: 10%+ retention

### Engagement Targets
- **Session 1**: 15+ minutes average (tutorial + first loop)
- **Session 2**: 20+ minutes average (return for offline earnings)
- **First Prestige**: 45-60 minutes average (CRITICAL METRIC)
- **Second Prestige**: 90-120 minutes average

### Key Analytics to Track
- **Drop-off heatmap**: Where do players quit? (fix friction points)
- **Upgrade purchase distribution**: Which upgrades most popular?
- **Worker treatment split**: Is balance working? (target 30/40/30)
- **Prestige frequency**: Are players cycling or stalling?
- **Session length by prestige count**: Does engagement grow?

### A/B Testing Opportunities (Post-Launch)
- First prestige timing: 45min vs 60min vs 75min
- Offline cap progression: Current vs. faster unlock
- Worker treatment balance: Adjust Goodwill penalties/bonuses
- Mood system: Adjectives only vs. adjectives + visual meter
- Goal visibility: Always-on vs. collapsible UI

---

## Complexity Growth Over Time (REVISED)

### Prestige 1 (45-60 min): Learn Core Loop
**Systems**:
- Clicking + conversion
- Overseer's mood (manual timing)
- Basic upgrades
- First stat milestones (Str/Dex Lv 2)
- Goal: Hook players with satisfying core, teach prestige concept

### Prestige 2-3 (90-180 min): Optimization Depth
**Systems**:
- Auto-conversion unlocked
- Offline earnings active
- More stat milestones (Lv 5 milestones unlock)
- Upgrade optimization strategies
- Goal: Players learn to optimize routes, feel mastery

### Prestige 3-4 (6-8 hours): Strategic Choices
**New Systems**:
- **Own furnace unlocks** (major milestone!)
- Worker management (3 treatment paths)
- Moral consequence systems
- Harmful upgrades (risk/reward)
- Goal: Introduce meaningful dilemmas, moral weight

### Prestige 4-5 (10-15 hours): Environmental Layer 1
**New Systems**:
- **Phase 6A**: Coal quality types (3 types)
- **Phase 6A**: Temperature regulation
- Resource planning (which coal when?)
- Goal: Add tactical decisions, prep for complexity

### Prestige 6-7 (18-22 hours): Environmental Layer 2
**New Systems**:
- **Phase 6B**: Time of day cycling
- **Phase 6B**: Airflow control
- Weather anticipation
- Goal: Temporal rhythms, reactive management

### Prestige 8-9 (25-30 hours): Macro Systems
**New Systems**:
- **Phase 6C**: Train speed variations
- **Phase 6C**: Ground electricity
- System interactions (electricity → speed → demand)
- Goal: Multi-variable optimization

### Prestige 10-11 (35-40 hours): Crisis Management
**New Systems**:
- **Phase 6D**: Sandstorms with preparation
- **Phase 6D**: Heat waves, cold snaps, failures
- Decision-making under pressure
- Goal: Dramatic events, risk mitigation

### Prestige 12+ (50+ hours): Full Simulation
**New Systems**:
- **Phase 6E**: Water supply, population, food, guards
- All systems interacting
- Deep optimization puzzles
- Goal: Mastery content for dedicated players

**Design Philosophy**:
✅ Start simple (just clicking!)
✅ Add ONE layer at a time (never dump multiple systems)
✅ Each layer builds on previous (temperature connects to time, etc.)
✅ Players master each before next unlocks
✅ Complexity feels natural, not overwhelming

---

## Key Design Principles Summary

### Core Game Design Principles Applied
✅ **Easy to Learn, Hard to Master**: Start with simple clicking, layer complexity over 50+ hours
✅ **Immediate Feedback**: Every action has <100ms response with multi-sensory feedback
✅ **Clear Goals**: Always-visible UI shows short/medium/long-term objectives
✅ **Meaningful Agency**: Worker treatment, timing, and resource choices matter
✅ **Consistent Rules**: Systems build on each other predictably
✅ **Reward Investment**: Time + skill + moral choices all yield meaningful rewards

### Idle/Incremental Best Practices
✅ **Simple Core Loop**: Click → Convert → Upgrade (feels good immediately)
✅ **Sophisticated Economy**: Multiple upgrade paths, prestige layers, strategic choices
✅ **Visible Progress**: Goal UI, prestige tracking, milestone celebrations
✅ **Offline Progression**: Tiered caps (8h→24h), respects player time
✅ **Fast First Prestige**: 45-60 minutes (hooks retention early)
✅ **Exponential Growth Management**: Prestige resets pacing, Goodwill provides meta-progression

### Game-Specific Design Pillars
✅ **Qualitative over Quantitative**: Players discover through experimentation (no explicit numbers)
✅ **Narrative Integration**: Every mechanic ties to Oren's escape story and sacrifice theme
✅ **Balanced Moral Dilemma**: Good treatment is mechanically competitive, not just "hard mode"
✅ **Hybrid Sessions**: Supports 5-minute check-ins and 3-hour optimization equally
✅ **Mysterious Mechanics**: No hand-holding, reward curiosity and pattern recognition
✅ **Gradual Complexity**: New systems unlock every 2-3 prestiges (never overwhelming)
✅ **Environmental Depth**: Desert train setting creates dynamic tactical challenges
✅ **Retention-First Design**: Playtesting milestones, metrics tracking, data-driven iteration

### What Changed From Original Plan
**ADDED**:
- ✨ Phase 0: Onboarding & feedback systems (retention foundation)
- ✨ Goal visibility UI (clear objectives always)
- ✨ Comprehensive feedback design (juice, polish, game feel)
- ✨ Playtesting milestones throughout development
- ✨ Retention metrics and success criteria
- ✨ Accessibility features (colorblind, reduced motion, assist modes)

**REVISED**:
- 🔄 First prestige: 45-60 min (was 2-3 hours) - retention critical
- 🔄 Worker treatment: Good path is competitive (was just harder)
- 🔄 Phase 6: Split into 5 sub-phases (was single overwhelming phase)
- 🔄 Roadmap: 22 weeks with testing (was 16 weeks without testing)
- 🔄 Complexity curve: Gradual layering (was dumping systems together)

### Success Criteria
**Retention Targets**:
- Day 1: 40%+ (industry standard)
- Day 7: 20%+ (good engagement)
- Day 30: 10%+ (strong retention)

**Engagement Metrics**:
- First session: 15+ minutes
- First prestige: 45-60 minutes (CRITICAL)
- Worker treatment: 30/40/30 split (balance validated)

**Quality Benchmarks**:
- Clicking feels satisfying (70%+ testers continue voluntarily)
- Goals are clear (<3 avg questions per playtester)
- Prestige feels rewarding (80%+ start second run)
- Treatment feels balanced (30/40/30 distribution)

---

**Document Status**: Complete - Ready for Implementation
**Next Step**: Begin Week 1-2 (Phase 0: Onboarding & Core Loop Feel)
**Philosophy**: Build retention from day one through satisfying core loops, clear goals, and data-driven iteration


