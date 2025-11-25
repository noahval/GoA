# Phase 2 Gameplay: Overseer for Hire

## Overview
Phase 2 introduces a silver-based economy where players pick up short shifts covering for other overseers. This phase explores the moral theme "it's very hard to be good" through the cruelty spectrum of overseers.

---

## Core Economy Shift

### Currency Transition
- **Phase 1**: Copper economy (furnace work, coal conversion)
- **Phase 2**: Silver economy (shift work, referrals)
- **ATM**: Minimal conversion needed - Phase 2 upgrades priced in silver

### Income Sources
- **Shift Coverage**: Small silver payments for covering other overseers
- **Difficulty**: Varies by overseer personality (cruel = easier, neutral = harder)
- **Optimization**: Players choose between moral choices and profit

---

## Bribery & Referral System

### Entry Requirements
To access Phase 2, player must have:
- `overseer_lvl >= 12` (6+ copper bribes)
- Access to Overseer's Office unlocked
- Met all Phase 1 → Phase 2 gate requirements (see currency-scaling-redesign.md)

### Progressive Bribery Costs

#### Tier 1: Initial Referrals (Copper)
- **First referral**: X copper (unlock first outside overseer)
- **Second referral**: Y copper (unlock second outside overseer)
- **Purpose**: Transition players into shift work while still in copper economy

#### Tier 2+: Advanced Referrals (Silver)
Once player starts earning silver from shifts:
- **Third referral**: Z silver
- **Fourth referral**: Z * 1.5 silver
- **Fifth+ referrals**: Escalating silver costs (exponential or linear progression TBD)

### "Put in a Good Word" Mechanic
- Player bribes their original overseer to introduce them to other overseers
- Each bribe unlocks access to ONE specific overseer's shift pool
- Cannot access shifts without proper referral/introduction
- Higher-tier overseers require more expensive referrals

---

## Shift Coverage System

### How Shifts Work
1. **Pick-Up Shifts**: Short-term coverage when other overseers are busy/need break
2. **Duration**: Time-limited assignments (5-15 minutes of active work?)
3. **Payment**: Paid in silver upon completion
4. **Location**: Work at other overseer's furnace (different scene or same scene with different variables?)

### Shift Mechanics (Implementation TBD)
- **Performance Tracking**: Quality of work affects future shift availability?
- **Cooldowns**: How often can player take shifts from same overseer?
- **Scheduling**: Random availability vs. player-controlled timing?
- **Failure States**: Can player fail a shift? Consequences?

### Shift Types (Varies by Overseer)
- **Easy Shifts**: Lenient quotas, forgiving conditions (cruel overseers)
- **Hard Shifts**: Strict quotas, challenging conditions (neutral overseers)
- **Special Events**: Unique challenges or bonuses per overseer personality

---

## Overseer Personalities: The Cruelty Spectrum

### Core Theme
**"It's very hard to be good"** - All overseers have become cruel to survive. The system rewards moral compromise and punishes attempts at goodness.

### Cruelty Spectrum Design

#### Inverse Difficulty/Reward Relationship
```
Neutral Overseers          →          Ultra-Cruel Overseers
[Low Pay, Very Hard]       →          [High Pay, Easy Work]
[Moral High Ground]        →          [Moral Compromise]
```

### Overseer Profiles (5-8 Characters)

#### Template Structure
For each overseer, define:
- **Name**: Character name
- **Cruelty Level**: Neutral / Somewhat Cruel / Cruel / Very Cruel / Ultra-Cruel
- **Personality**: Brief description (2-3 sentences)
- **Furnace Conditions**: What makes their shifts unique
- **Difficulty**: Mechanical challenges (quota strictness, time pressure, etc.)
- **Pay Rate**: Silver per shift (inverse to difficulty)
- **Referral Cost**: Bribery cost to unlock access
- **Dialogue Style**: How they talk to player
- **Moral Weight**: Player's ethical consideration

---

### Example Overseer Profiles

#### 1. Overseer Markus (Neutral)
- **Cruelty Level**: Neutral
- **Personality**: One of the last "fair" overseers. Treats workers with basic dignity and enforces rules strictly but without malice. Exhausted by trying to maintain standards in a corrupt system.
- **Furnace Conditions**: Pristine workspace, high safety standards, strict quotas
- **Difficulty**: VERY HARD - Unforgiving quotas, precise timing requirements, quality checks
- **Pay Rate**: 2-3 silver per shift (LOW)
- **Referral Cost**: 15 silver (your overseer hesitates to refer you to someone "soft")
- **Dialogue**: Professional, terse, expects excellence
- **Moral Weight**: Working for Markus = choosing the hard path of integrity
- **Challenge**: Players must be skilled to complete his shifts successfully

#### 2. Overseer Kael (Somewhat Cruel)
- **Cruelty Level**: Somewhat Cruel
- **Personality**: Used to be like Markus, but the system broke him. Now enforces rules harshly to protect himself. Occasionally shows glimpses of the person he was.
- **Furnace Conditions**: Adequate workspace, moderate safety standards
- **Difficulty**: HARD - Tough quotas, limited margin for error
- **Pay Rate**: 4-5 silver per shift (MODERATE)
- **Referral Cost**: 10 silver
- **Dialogue**: Brusque, defensive, occasionally sympathetic
- **Moral Weight**: The "slippery slope" - watch someone become what they hate

#### 3. Overseer Venn (Cruel)
- **Cruelty Level**: Cruel
- **Personality**: Enjoys power over workers. Uses intimidation and humiliation as management tools. Efficient but ruthless.
- **Furnace Conditions**: Poorly maintained, minimal safety, relaxed quotas
- **Difficulty**: MODERATE - Easy quotas, but psychological discomfort
- **Pay Rate**: 7-8 silver per shift (GOOD)
- **Referral Cost**: 6 silver (your overseer knows Venn well)
- **Dialogue**: Mocking, condescending, cruel humor
- **Moral Weight**: Working for Venn = tolerating abuse for money

#### 4. Overseer Thane (Very Cruel)
- **Cruelty Level**: Very Cruel
- **Personality**: Sadistic and calculating. Inflicts suffering methodically. Views workers as tools to be used and discarded. Extremely effective at production.
- **Furnace Conditions**: Dangerous workspace, no safety protocols, very lenient quotas
- **Difficulty**: EASY - Quotas easily met, just endure the environment
- **Pay Rate**: 11-13 silver per shift (HIGH)
- **Referral Cost**: 4 silver (your overseer respects Thane's "effectiveness")
- **Dialogue**: Cold, clinical, casually mentions worker injuries
- **Moral Weight**: Working for Thane = becoming complicit in suffering

#### 5. Overseer Dross (Ultra-Cruel)
- **Cruelty Level**: Ultra-Cruel
- **Personality**: The worst of the worst. Has completely dehumanized workers. Runs the most "profitable" furnace through fear and brutality. Your overseer warns you about him.
- **Furnace Conditions**: Hellish workspace, active danger, laughably easy quotas
- **Difficulty**: VERY EASY - Player barely has to work, just witness horrors
- **Pay Rate**: 18-20 silver per shift (VERY HIGH)
- **Referral Cost**: 3 silver (your overseer knows you're desperate for silver)
- **Dialogue**: Disturbing casualness about violence, dark jokes about worker deaths
- **Moral Weight**: Working for Dross = crossing the moral event horizon
- **Special**: May include unique moral choice events or consequences

#### 6. Overseer Lyra (Cruel but Charismatic)
- **Cruelty Level**: Cruel
- **Personality**: Charming and cruel - a dangerous combination. Makes cruelty seem reasonable. Excellent manipulator who makes workers feel grateful for abuse.
- **Furnace Conditions**: Well-maintained facade, hidden dangers, moderate quotas
- **Difficulty**: MODERATE - Deceptively challenging, gaslighting mechanics?
- **Pay Rate**: 8-9 silver per shift (GOOD)
- **Referral Cost**: 7 silver
- **Dialogue**: Friendly tone, backhanded compliments, subtle threats
- **Moral Weight**: The "nice" cruelty - harder to recognize as wrong

#### 7. Overseer Grit (Cruel, Old Guard)
- **Cruelty Level**: Cruel
- **Personality**: "This is how it's always been done." Traditional, rigid, cruel by habit rather than malice. Sees cruelty as necessary discipline.
- **Furnace Conditions**: Old-fashioned workspace, outdated safety, reasonable quotas
- **Difficulty**: MODERATE-HARD - Old-school strict but predictable
- **Pay Rate**: 6-7 silver per shift (MODERATE)
- **Referral Cost**: 8 silver
- **Dialogue**: Gruff, dismissive, "back in my day" stories
- **Moral Weight**: Institutional cruelty - perpetuating broken systems

#### 8. Overseer Sable (Very Cruel, Ambitious)
- **Cruelty Level**: Very Cruel
- **Personality**: Young and ambitious. Uses cruelty strategically to climb ranks. Sees workers as stepping stones. Efficient and ruthless.
- **Furnace Conditions**: Modern, efficient, minimal safety, very easy quotas
- **Difficulty**: EASY - Streamlined process, just don't question methods
- **Pay Rate**: 13-15 silver per shift (HIGH)
- **Referral Cost**: 5 silver
- **Dialogue**: Professional veneer over callousness, corporate-speak cruelty
- **Moral Weight**: Careerist cruelty - ends justify means

---

## Phase 2 Upgrades & Progression

### Silver-Based Upgrade Economy
To minimize ATM conversions, most Phase 2 content priced in silver:

#### Equipment Upgrades (Silver Costs)
- **Better Tools**: Reduce shift difficulty, increase efficiency
- **Safety Gear**: Unlock access to more dangerous (high-paying) shifts
- **Status Symbols**: Cosmetic items that affect overseer interactions?

#### Skill Unlocks (Silver Costs)
- **Shift Specializations**: Become expert in certain furnace types
- **Negotiation**: Increase pay rates from specific overseers
- **Endurance**: Take longer/multiple consecutive shifts

#### Automation/Passive Income (Silver Costs)
- **Helper Hiring?**: Pay silver to have others cover shifts for you
- **Investment Opportunities?**: Use silver to generate passive copper/silver

### Copper Still Needed For
- Initial 1-2 referral bribes (transition currency)
- Phase 1 equipment/upgrades (if player wants to revisit)
- ATM conversions (emergency/strategic use)

---

## Moral Choice Framework

### Player Agency
- **No Forced Morality**: Player chooses which overseers to work for
- **Consequences?**: Does working for cruel overseers affect anything?
  - Dialogue changes?
  - Stat effects?
  - Story branches?
  - Prestige/reputation implications?

### Thematic Questions
- Is it worth compromising ethics for efficiency?
- Can you afford to be good in a corrupt system?
- Does working for cruel overseers make you complicit?
- What would you sacrifice for progress?

### Potential Moral Systems (TBD)
1. **Pure Choice**: No mechanical consequence, just player's ethical discomfort
2. **Hidden Stat**: Morality/corruption stat that affects future content
3. **Reputation Split**: Separate reputation with workers vs. overseers
4. **Story Branches**: Different endings/content based on choices

---

## Implementation Questions & Design Decisions

### Mechanics to Determine
1. **Shift Duration**: How long is a shift? Real-time or abstract?
2. **Shift Availability**: Random, scheduled, on-demand?
3. **Failure States**: What happens if player fails a shift?
4. **Performance Metrics**: How is shift quality measured?
5. **Cooldowns**: How often can player work for same overseer?
6. **Quota Mechanics**: What defines "easy" vs "hard" quotas?
7. **Scene Design**: New scenes per overseer or modify existing furnace scene?

### Narrative Elements
1. **Overseer Dialogues**: Full conversation trees or brief exchanges?
2. **Character Development**: Do overseers' personalities evolve?
3. **Player Relationship**: Does reputation with individual overseers matter?
4. **Story Integration**: How does this connect to main narrative/endgame?

### Balance Considerations
1. **Pay Rate Tuning**: How much silver should each tier provide?
2. **Bribery Costs**: How steep should silver bribery escalation be?
3. **Difficulty Curve**: Ensure "hard" feels hard and "easy" feels easy
4. **Silver Sinks**: What Phase 2 upgrades prevent silver hoarding?
5. **Copper/Silver Ratio**: ATM conversion rates for strategic use

### Quality of Life
1. **Shift Tracking**: UI showing available shifts, cooldowns, etc.
2. **Overseer Database**: Player reference for personalities, pay rates
3. **Income Tracking**: Clear feedback on silver earnings
4. **Tutorial**: How to introduce shift system to players?

---

## Integration with Existing Systems

### Connections to Phase 1
- **Your Overseer**: Original overseer becomes referral gatekeeper
- **Overseer's Office**: Hub for managing shift opportunities
- **Bribery Progression**: Natural extension of existing bribery system
- **Skill Tree**: Stats affect shift performance?

### Prestige Interactions
- **What Persists Through Prestige?**
  - Referral unlocks? (Keep access to overseers?)
  - Silver currency? (Reset or persist?)
  - Overseer relationships? (Keep or reset?)
  - Moral choices? (Remember or forget?)

### Victory Conditions
- Does Phase 2 lead to Phase 3?
- Is there a Phase 2-specific victory path?
- How does shift work connect to endgame goals?

---

## Development Roadmap

### Phase 2.1: Foundation
- [ ] Implement basic shift mechanics
- [ ] Create first 2-3 overseer personalities
- [ ] Set up silver economy framework
- [ ] Design bribery progression (copper → silver)

### Phase 2.2: Expansion
- [ ] Add remaining overseer personalities
- [ ] Implement cruelty spectrum difficulty scaling
- [ ] Create shift-specific challenges per overseer
- [ ] Build silver upgrade tree

### Phase 2.3: Polish
- [ ] Add overseer dialogue/character depth
- [ ] Implement moral choice consequences (if any)
- [ ] Balance pay rates and difficulty
- [ ] Create UI/UX for shift management

### Phase 2.4: Integration
- [ ] Connect to Phase 3 transition (if applicable)
- [ ] Ensure prestige interactions work correctly
- [ ] Add tutorial/onboarding for new systems
- [ ] Final balancing pass

---

## Notes & Future Considerations

### Theme Reinforcement
The cruelty spectrum should make players genuinely uncomfortable working for the worst overseers, even if it's optimal. Success = players agonizing over whether to take Dross's lucrative shifts.

### Player Types
- **Optimizers**: Will work for cruelest overseers for max silver/hour
- **Roleplayers**: May choose neutral overseers despite difficulty
- **Completionists**: Will want to unlock all overseers regardless of morality
- **Narrative-Focused**: Care about story implications of choices

Design should accommodate all playstyles while maintaining thematic weight.

### Potential Expansions
- **Worker Solidarity**: Help other workers, lose pay but gain different benefits?
- **Sabotage**: Undermine cruel overseers, risk consequences?
- **Mentorship**: Learn from neutral overseers, skill bonuses?
- **Corruption Path**: Become an overseer yourself in Phase 3?

---

## Summary

Phase 2 creates a moral-economic tension where:
- **Goodness is hard**: Neutral overseers pay less and demand more
- **Cruelty is rewarded**: Cruel overseers pay better and require less
- **Player chooses**: No forced path, but thematic weight on decisions
- **Silver economy**: Clean transition from copper-based Phase 1
- **Progressive bribery**: Natural currency evolution (copper → silver)

The shift system should feel like a meaningful choice between ethics and efficiency, reinforcing the game's theme that survival in corrupt systems requires moral compromise.
