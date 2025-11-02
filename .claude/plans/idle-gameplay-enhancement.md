# GoA Level 1: Train Escape - Idle/Incremental Enhancement Plan

**Version**: 1.0
**Created**: 2025-11-01
**Status**: Planning Phase

---

## Core Design Philosophy

### Mysterious Gameplay
Players discover mechanics through experimentation rather than explicit numbers. Use qualitative feedback (adjectives, visuals, narrative hints) over quantitative data.

**Examples**:
- ❌ "Overseer's Mood: 1.42x multiplier"
- ✅ "The overseer seems pleased" (with ↗ trend arrow)

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

---

## Phase 1: Overseer's Mood & Conversion System

### Manual vs Auto Conversion Toggle

**Core Mechanic**: Player chooses between manual timing (skill-based, high reward) or auto (convenience, lower reward).

### Manual Conversion Mode

**What Player Sees**:
- Mood indicator with adjectives (not numbers):
  - "furious" (very bad)
  - "irritated" (bad)
  - "indifferent" (neutral)
  - "pleased" (good)
  - "delighted" (very good)
  - "ecstatic" (excellent)
- Trend arrow: ↗ (improving), → (stable), ↘ (declining)
- After conversion: "The overseer was pleased with your work. You earned a generous bonus!"

**Hidden Mechanics** (player discovers):
- Mood drifts randomly over time (creates uncertainty)
- Converting too often makes overseer grumpy (mood fatigue)
- Must learn optimal timing through experimentation
- Mood multiplier range: 0.5x to 2.0x (upgradable to 0.7x-2.5x)

**Strategic Depth**:
- Watch mood, time conversions at peaks
- Balance greed (wait for better mood) vs safety (convert before it drops)
- Mood fatigue punishes spam-converting

### Auto Conversion Mode

**What Player Sees**:
- "Auto-Converting... efficiency unknown"
- After time away: "While you were away, the overseer's mood varied. You earned X coins."
- NO indication of efficiency penalty

**Hidden Mechanics**:
- Uses current mood but applies 70% efficiency penalty (upgradable to 95%)
- Mood still fluctuates and fatigues (but slower)
- Never optimal but provides offline progression

**Discovery Process**: Players notice auto gives less, must experiment to understand tradeoff.

### Upgradeable Paths

**Manual Mode Upgrades**:
- "Your smooth words help ease tensions" (reduces mood fatigue)
- "A generous bribe improves his disposition" (increases mood range)
- "You learn to read his expressions" (shows mood trend)
- "Your charm is undeniable" (faster fatigue recovery)

**Auto Mode Upgrades**:
- "Auto-Converter" (unlocks auto mode, 500 coins)
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

**Calculation**: `floor(sqrt(equipment_coins_spent / 100))`

**Examples**:
- 10,000 coins spent → 10 goodwill
- 40,000 coins spent → 20 goodwill
- 90,000 coins spent → 30 goodwill

**Target**: First prestige at ~10,000-15,000 equipment spending (2-3 hours active play)

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

---

## Phase 5: Own Furnace & Worker Management

### Unlock Timing
**When**: 6-8 hours gameplay, Prestige 3-4
**Requirements**:
- 8+ Goodwill points
- 10,000 coin purchase
- Charisma 8+
- Story beat: "The crystal whispers: Time to lead, not just follow"

### Worker Treatment System (Moral Complexity)

#### Poor Treatment (0 coins/sec upkeep)
**PROS**:
- ✅ Higher coal output (fear-driven productivity)
- ✅ Simpler gameplay (less management)
- ✅ Cheaper operation
- ✅ Faster progression

**CONS**:
- ❌ Workers can sabotage (random production drops)
- ❌ Guards investigate (suspicion increases)
- ❌ Moral weight ("A worker collapsed today")
- ❌ Crystal disapproves (goodwill penalty on prestige)

#### Fair Treatment (2 coins/sec per worker)
**PROS**:
- ✅ Stable production
- ✅ No sabotage risk
- ✅ Balanced difficulty

**CONS**:
- ❌ Medium coal output (not optimal either way)
- ❌ Ongoing costs
- ❌ No special benefits

#### Good Treatment (5 coins/sec per worker)
**PROS**:
- ✅ Workers share tips (unlock efficiency insights)
- ✅ Loyalty (workers help during crises)
- ✅ Crystal approves (+goodwill bonus on prestige)
- ✅ Moral satisfaction (positive notifications)
- ✅ Workers cover for you (reduce suspicion)

**CONS**:
- ❌ LOWER coal output (sustainable pace, not pushed)
- ❌ Higher costs drain profits
- ❌ HARDER gameplay (more active management needed)
- ❌ Requires strategic planning to stay profitable

**The Dilemma**: Neither is "optimal" - balance conscience against necessity

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

**Crystal's Judgment**: Harmful upgrades reduce goodwill gains

---

## Phase 6: Environmental Management Systems

### Furnace Tuning (Mid-Long Session Gameplay)

**Coal Quality Management**:
- Regular coal (baseline)
- Fine coal (burns hot but fast - good for cold nights)
- Coarse coal (burns slow and steady - stable periods)
- Must match coal type to conditions

**Airflow Control**:
- Adjust intake vents based on air quality
- Sandstorm = close vents (less oxygen, slower burn, protect workers)
- Clear day = open vents (maximum efficiency)
- "The air tastes of sand today"

**Temperature Regulation**:
- Balance heat vs worker safety vs efficiency
- Too hot: workers suffer, crystal warns
- Too cold: train slows, guards investigate
- Desert day: 120°F outside, need cooling
- Desert night: 40°F outside, need heating

### Environmental Factors (Dynamic Challenges)

**Train Speed**:
- Fast: More coal needed, higher quotas
- Slow: Less demand, but guards are bored (more scrutiny)
- "The train is racing. Feed the furnace faster!"

**Air Quality**:
- Clear: Normal operations
- Dusty: Reduce airflow, protect workers
- Sandstorm: Emergency protocols, production drops
- Toxic (from other furnaces): Ventilation decisions

**Time of Day**:
- Morning: Workers fresh, higher efficiency
- Afternoon: Desert heat, temperature management needed
- Evening: Workers tired, lower output
- Night: Cold desert, different fuel needs

**Ground Electricity**:
- High: Train moves efficiently, less coal needed
- Low: More coal needed to maintain speed
- Fluctuating: Requires constant adjustment
- "The ground crackles with energy"

**Sandstorms** (Random Events):
- "A massive storm approaches from the east!"
- Decision: Close vents (protect workers, less production) vs keep open (risk damage)
- Aftermath: Sand in machinery, efficiency reduced until cleaned

### Train City Management

**Water Supply** (Affects Workers):
- Plentiful: Workers healthy, normal morale
- Rationed: Workers weaker, need more rest
- Scarce: Health crisis, must decide who gets water
- "Water rations are down to half. The workers look parched."

**Water Quality**:
- Clean: No issues
- Contaminated: Workers get sick, random absences
- Purified (upgrade): Better morale, costs coins

**Population Pressure**:
- More people = more workers available to hire
- But also: more demand for coal (higher quotas)
- "The train took on refugees at the last station."

**Food Distribution**:
- Well-fed train: Workers available, good morale
- Starving train: Desperate workers accept poor treatment
- "The food cars are running low. People are getting desperate."

**Guard Patrols**:
- Light: Easy to steal, manage workers freely
- Heavy: Must be careful, suspicion builds faster
- Corrupt: Can bribe for freedom (costs coins)
- "The guards are bored today. They're watching everything."

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

## Implementation Roadmap

### Week 1-2: Manual/Auto Conversion (Qualitative)
- [ ] Implement mood system with adjective descriptions
- [ ] Remove all explicit multiplier displays
- [ ] Add flavor text for all upgrades
- [ ] Create mood-to-adjective mapping
- [ ] Add trend indicators (no numbers)
- [ ] Build conversion toggle UI

### Week 3-4: Early Stat Milestones
- [ ] Create 18 milestones (3 per stat, levels 1-8)
- [ ] Implement game level tracking
- [ ] Add milestone notification system
- [ ] Write thematic flavor text for each
- [ ] Connect milestones to mechanical unlocks
- [ ] Stop showing Lv1 milestones at Lv2

### Week 5-6: Revised Prestige System
- [ ] Track lifetime equipment spending
- [ ] Implement goodwill calculation
- [ ] Create prestige UI and confirmation
- [ ] Build goodwill upgrade tree
- [ ] Add reset/persist logic
- [ ] Update narrative (sacrifice theme)
- [ ] Test 2-3 hour prestige timing

### Week 7-8: Offline Earnings & Balance
- [ ] Implement tiered offline cap system
- [ ] Add offline cap upgrades (8h→24h quick, then slower)
- [ ] Create offline earnings calculation
- [ ] Add notifications for cap exceeded
- [ ] Rebalance all existing upgrade costs
- [ ] Tune overseer mood drift rates

### Week 9-10: Furnace & Workers (6-8 hours, Prestige 3-4)
- [ ] Push unlock to 6-8 hours gameplay
- [ ] Implement worker treatment system
- [ ] Add poor treatment advantages
- [ ] Add good treatment disadvantages
- [ ] Create harmful upgrade tree
- [ ] Add moral consequence notifications
- [ ] Implement crystal approval/disapproval

### Week 11-12: Environmental Systems (Phase 1)
- [ ] Implement coal quality types
- [ ] Add airflow controls
- [ ] Create temperature management
- [ ] Add time of day cycling
- [ ] Implement basic environmental factors

### Week 13-14: Environmental Systems (Phase 2)
- [ ] Add train speed variations
- [ ] Implement ground electricity
- [ ] Create sandstorm events
- [ ] Add water supply/quality systems
- [ ] Implement population/city factors
- [ ] Add guard patrol variations

### Week 15-16: Integration & Balance
- [ ] Connect all systems together
- [ ] Balance difficulty across treatment choices
- [ ] Tune environmental challenge levels
- [ ] Write all remaining flavor text
- [ ] Full playtest and iteration
- [ ] Final balancing pass

---

## Complexity Growth Over Time

### Prestige 1 (2-3 hours): Core Systems
- Manual/Auto conversion
- Overseer's mood
- Offline earnings
- Basic upgrades
- Stat milestones

### Prestige 2-3 (5-8 hours): Strategic Depth
- Unlock own furnace
- Worker management
- Treatment choices
- More stat milestones

### Prestige 4-5 (10-15 hours): Advanced Systems
- Multiple resource types (coal quality)
- Temperature management
- Environmental events
- Train city factors

### Prestige 6+ (20+ hours): Mastery
- Complex optimization puzzles
- Multiple furnaces
- Advanced worker specializations
- Prestige-only upgrades
- Full environmental simulation

**Design Goal**: Start simple, naturally introduce complexity as player masters systems

---

## Key Design Principles Summary

✅ **Qualitative over Quantitative**: Players discover through experimentation
✅ **Narrative Integration**: Every mechanic ties to Oren's escape story
✅ **Moral Complexity**: Good treatment is harder but morally right
✅ **Sacrifice Theme**: Progress requires difficult choices
✅ **Hybrid Sessions**: Supports 5-minute and 3-hour play equally
✅ **Mysterious Mechanics**: No hand-holding, reward curiosity
✅ **Environmental Depth**: Desert train setting creates dynamic challenges
✅ **Long Prestige**: 2-3 hour cycles maintain engagement

---

**Document Status**: Complete - Ready for Implementation
**Next Step**: Begin Week 1-2 (Manual/Auto Conversion System)


