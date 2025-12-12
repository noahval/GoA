# Currency Scaling Redesign Plan

## Document Version
- **Created**: 2025-01-14
- **Status**: Planning
- **Target**: Phases 1, 2, and 3 progression redesign

---

## 1. Overview & Goals

### Problem Statement
The current 100:1 currency conversion ratios (100 copper = 1 silver, 100 silver = 1 gold, etc.) provide only **2 orders of magnitude** per currency tier. With the exponential growth inherent to idle/incremental games, players would progress through each tier too quickly, reaching the next currency before experiencing meaningful progression within the current tier.

### Core Challenge
How do we create distinct currency phases that last:
- **Phase 1 (Furnace Worker)**: 8-15 hours of active play
- **Phase 2 (Overseer for Hire)**: 5-10 hours of active play
- **Phase 3 (Own Furnace)**: 10-25 hours of active play

...while maintaining the satisfying exponential growth that defines idle games?

### Solution Approach
A **multi-layered system** combining:
1. **Increased currency ratios** (1000:1 instead of 100:1)
2. **Storage capacity limitations** forcing economic decisions
3. **Non-currency progression gates** (reputation, stats, examinations)
4. **Phase-specific gameplay limiters** that slow growth
5. **Economic friction** (fees, maintenance costs, operating expenses)
6. **Three separate prestige skill trees** (one per phase) - See [skill-trees.md](skill-trees.md)

### Design Goals
- Each phase should feel distinct with unique mechanics
- Currency tiers should align with thematic class progression (laborer → overseer → magnate)
- Players can specialize stats based on playstyle (flexible builds)
- Testing remains easy (current holdings unlocks, not lifetime)
- Storage pressure creates strategic decisions (spend vs exchange vs upgrade vs deposit)
- True endgame: accumulate nobility credit → escape train → Level 2

---

## 2. Currency Ratio Changes

### Current System (100:1)
```
100 Copper Pieces = 1 Silver Mark
100 Silver Marks = 1 Gold Crown
100 Gold Crowns = 1 Platinum Bond

Conversion to base:
- 1 Silver = 100 Copper
- 1 Gold = 10,000 Copper
- 1 Platinum = 1,000,000 Copper
```

**Problem**: Only 2 orders of magnitude per tier (1→100)

### New System (1000:1)
```
1000 Copper Pieces = 1 Silver Mark
1000 Silver Marks = 1 Gold Crown
1000 Gold Crowns = 1 Platinum Bond

Conversion to base:
- 1 Silver = 1,000 Copper
- 1 Gold = 1,000,000 Copper
- 1 Platinum = 1,000,000,000 Copper
```

**Benefit**: 3 orders of magnitude per tier (1→1000), significantly more room for exponential growth

### Thematic Justification
- **Copper** (Laborer class): Small denominations for daily wages, basic supplies
- **Silver** (Merchant/Artisan class): Mid-tier transactions, equipment, licenses
- **Gold** (Noble/Gentry class): Major purchases, property, business ownership
- **Platinum** (Ruling class): Wealth accumulation, nobility credit, endgame currency

### Implementation Changes Required

**Files to modify:**
- `currency_manager.gd` - Update CONVERSION_RATES constants
- `atm.gd` - Update exchange calculations
- `level1/level_1_vars.gd` - Update unlock thresholds
- All shop item costs - Rebalance for new ratios

**Constants to change:**
```gdscript
# OLD
const COPPER_TO_SILVER = 100
const SILVER_TO_GOLD = 100
const GOLD_TO_PLATINUM = 100

# NEW
const COPPER_TO_SILVER = 1000
const SILVER_TO_GOLD = 1000
const GOLD_TO_PLATINUM = 1000
```

### Migration Strategy
For existing saves:
1. Multiply all current currency by 10 to maintain relative value
2. Update unlock flags to reflect new thresholds
3. Display migration notice: "Currency system updated - values adjusted"

### Testing Checklist
- [ ] ATM exchanges work correctly at 1000:1 ratios
- [ ] Market volatility still applies correctly
- [ ] Currency unlock thresholds trigger properly
- [ ] Shop prices make sense in new scale
- [ ] Display formatting handles larger numbers

---

## 3. Phase Gate Requirements

### Philosophy
Phase transitions should feel **earned**, not just purchased. Multiple requirements ensure players engage with different systems and can't rush through by grinding a single mechanic.

### Phase 1 → Phase 2: Becoming an Overseer for Hire

**Requirements (ALL must be met):**
1. **Currency**: 800 copper in pocket
2. **Reputation**: Level 5+ (forces 1-2 prestige cycles)
3. **Combined Stats**: Total 30 levels across all 6 stats (e.g., 5/5/5/5/5/5 or 10/8/4/3/3/2, player choice)
4. **Quest**: Complete initial overseer trust-building tasks
5. **Overseer Relations**: Sufficiently bribed overseer (overseer_lvl >= 12, unlocks office access + shift referral system)

**Design Rationale:**
- 800 copper ensures player has mastered Phase 1 mechanics
- Reputation 5 encourages prestiging to unlock skill tree benefits
- Combined stats (not specific stats) allows flexible builds
- Quest adds narrative progression
- Overseer bribes (6+ bribes, ~46 copper investment) unlock shift referral system for Phase 2 silver economy

**Unlock Message:**
```
"The Overseer eyes you appraisingly. 'You've proven yourself capable.
Other furnaces need overseers for their shifts. I can put in a word...'"
```

### Phase 2 → Phase 3: Owning Your Own Furnace

**Requirements (ALL must be met):**
1. **Currency**: 800 silver in pocket
2. **Reputation**: Level 15+ (requires multiple prestige cycles)
3. **Combined Stats**: Total 45 levels across all 6 stats
4. **Leadership Examination**: Pass overseer's exam (70% = 7/10 questions)
5. **Quest**: Purchase Furnace Deed from Magistrate

**Leadership Examination Details:**
- Uses existing overseer's office talk questions (no changes needed)
- Randomly selects 10 questions from current pool
- Player must answer 7/10 correctly to pass
- Can retake after cooldown period (e.g., 30 minutes or 1 prestige)
- Passing unlocks ability to purchase Furnace Deed

**Design Rationale:**
- 800 silver ensures mastery of Phase 2 shift management
- Reputation 15 requires significant prestige investment
- Combined stats 45 shows well-developed character
- Examination adds skill-based gate (not just grinding)
- Quest creates ceremonial moment of ownership

**Unlock Message:**
```
"The Magistrate slides the deed across the desk. 'Congratulations.
You now own your own furnace. Manage it well, and the nobility may take notice.'"
```

### True Endgame: Escape to Level 2

**Requirements:**
- Accumulate sufficient **Nobility Credit** through Phase 3 operations
- Gain access to restricted section of train
- Complete final escape sequence

**Note**: Specific Nobility Credit mechanics defined in Phase 3 section

### Currency Unlock Thresholds (Separate from Phase Gates)

These unlock the **ability to see and exchange** currencies, separate from phase transitions:

| Currency | Unlock Requirement |
|----------|-------------------|
| Silver | 500 copper in pocket |
| Gold | 50 silver in pocket + Reputation 3+ |
| Platinum | 50 gold in pocket + Reputation 10+ |

**Testing-Friendly**: Uses current holdings, not lifetime totals
**Console Command**: `Level1Vars.currency.copper = 500` for quick testing

### Implementation Files

**Phase gate checking:**
- `level1/overseers_office.gd` - Add phase unlock UI and examination system
- `level1/shop.gd` or new `level1/magistrate.gd` - Furnace deed purchase
- `global.gd` - Add phase tracking variables

**New variables needed:**
```gdscript
# In global.gd or level_1_vars.gd
var current_phase = 1  # 1, 2, or 3
var phase_2_unlocked = false
var phase_3_unlocked = false
var leadership_exam_passed = false
var leadership_exam_attempts = 0
var leadership_exam_cooldown_until = 0  # timestamp
```

---

## 4. Unified Currency Storage System

### Concept
A single upgrade path that increases the carrying capacity for **all currency types simultaneously**. Thematically, these are physical containers (purses, bags, cases, vaults) that can hold any denomination of coin.

### Starting Caps
All currencies begin with **200 capacity**:
- Copper: 200 pieces
- Silver: 200 marks
- Gold: 200 crowns
- Platinum: 200 bonds

### Storage Upgrade Tiers

Purchased in shop, each upgrade applies to ALL currency types:

| Tier | Name | Capacity | Cost | Location |
|------|------|----------|------|----------|
| 0 | Base (no upgrade) | 200 | Free | Starting |
| 1 | Belt Pouch | 300 | 175 copper | Shop |
| 2 | Leather Purse | 450 | 250 copper | Shop |
| 3 | Reinforced Pouch | 650 | 400 copper | Shop |
| 4 | Heavy Coin Bag | 900 | 800 copper | Shop |
| 5 | Merchant's Satchel | 1,250 | 2 silver | Shop |
| 6 | Trader's Case | 1,750 | 6 silver | Shop |
| 7 | Banker's Chest | 2,500 | 20 silver | Shop |
| 8 | Strongbox Key | 3,500 | 70 silver | Shop |
| 9 | Vault Access | 5,000 | 0.25 gold (250 silver) | Shop |
| 10 | Private Vault | 7,000 | 1 gold | Shop |
| 11 | Master Vault | 8,500 | 5 gold | Shop |
| 12 | Noble's Treasury | 10,000 | 50 gold | Shop |

**Progression curve**: Early upgrades provide gradual capacity increases (200→300→450→650→900). Mid-game uses silver (2→6→20→70 silver). Late game scales exponentially with gold (0.25→1→5→50 gold), with final tier costing 50 gold for 10,000 max capacity.

### Overflow Behavior

**When capacity reached:**
1. **Earnings stop** - No overflow, no automatic exchange
2. **Visual warning** displays:
   ```
   "Your [purse/bag/vault] is full of [copper/silver/gold/platinum]!"
   ```
3. **Player options presented:**
   - Spend currency in shop
   - Exchange at ATM (convert to higher tier)
   - Deposit at ATM (pay 12% fee for storage)
   - Upgrade storage capacity in shop

**Strategic Pressure**: Storage caps force economic decisions and engagement with exchange systems

### Implementation Files

**New shop upgrade:**
- `level1/shop.gd` - Add "Storage Capacity" upgrade category
- `upgrade_types_config.gd` - Add "storage_capacity" upgrade type

**Variables needed:**
```gdscript
# In level_1_vars.gd
var storage_capacity_level = 0
var storage_capacity_caps = [200, 300, 450, 650, 900, 1250, 1750, 2500, 3500, 5000, 7000, 8500, 10000]

func get_currency_cap() -> int:
    return storage_capacity_caps[storage_capacity_level]
```

**Earning functions to modify:**
- `overseer_mood.gd` - Check copper cap before awarding coins
- Future Phase 2 shift manager - Check silver cap
- Future Phase 3 furnace manager - Check gold/platinum cap

### Visual Feedback

**Shop display:**
```
Storage Capacity: Level 4 (Heavy Coin Bag)
Current: 900 coins | Next: 1,250 coins
Upgrade Cost: 2 silver
```

## 5. Coal Record-Keeping System

### Concept
"Coal shovelled" is a **conceptual metric**, not physical storage. It represents your tracked productivity for the overseer. Upgrades represent better record-keeping methods.

### Starting Cap
**1,000 coal** - Your mental tally limit

### Record-Keeping Upgrade Tiers

| Tier | Name | Capacity | Cost | Thematic Description |
|------|------|----------|------|---------------------|
| 0 | Mental Tally | 1,000 | Free | "You count in your head" |
| 1 | Chalk Marks | 2,000 | 50 copper | "Tally marks on the wall" |
| 2 | Wax Tablet | 4,000 | 150 copper | "Reusable writing surface" |
| 3 | Ledger Book | 7,000 | 400 copper | "Proper bookkeeping" |
| 4 | Accounting System | 12,000 | 1,000 copper | "Organized records" |
| 5 | Master Records | 20,000 | 3,000 copper | "Professional tracking" |
| 6 | Overseer's Trust | 35,000 | 8,000 copper | "They trust your word" |

**Progression rationale**: Coal tracking becomes less important in late Phase 1 as players shift to currency management, so caps can be generous.

### Overflow Behavior

**When coal cap reached:**
1. **Shoveling stops** - Can't earn more coal until converted
2. **Message displays**:
   ```
   "You've lost count of how much coal you've shoveled.
   Convert some to copper before continuing."
   ```
3. **Encourages conversion** to overseer (engages with mood system)

### Implementation

**File to modify:**
- `level1/shop.gd` - Add "Record-Keeping" upgrade category
- `level1/furnace.gd` - Check coal cap before awarding coal from shoveling

**Variables:**
```gdscript
# In level_1_vars.gd
var coal_tracking_level = 0
var coal_tracking_caps = [1000, 2000, 4000, 7000, 12000, 20000, 35000]

func get_coal_cap() -> int:
    return coal_tracking_caps[coal_tracking_level]
```

### Why Separate from Currency Storage?

1. **Thematic distinction**: Coal is tracked productivity, currency is physical wealth
2. **Different progression**: Coal caps can be more generous (less critical late-game)
3. **Narrative flavor**: Reflects improving relationship with overseer (trust-based)
4. **Gameplay variety**: Two different upgrade paths to invest in

---

## 6. ATM Deposit/Banking System

### Concept
The ATM can **store currency** beyond your pocket capacity, functioning as a bank. This creates a strategic choice: pay upgrade costs once, or pay fees repeatedly?

### Mechanics

**Deposits:**
- **Fee**: 12% of deposited amount (one-time charge)
- **No capacity limit**: Can deposit unlimited currency
- **Doesn't count against pocket cap**: Frees up space for earning

**Withdrawals:**
- **Instant**: No waiting period

**Exchange:**
- **Exchange**: deposited money can be used as well as regular currency when exchanging to different currencies

**Charisma Benefit:**
- Reduces fees same as exchange fees (.5% reduction per charisma level)
- Minimum fee: 1% (can't go below)

### Strategic Decision Matrix

**Example scenario**: Player has 200 copper cap, earning 50 copper/minute

**Option A - Buy Storage Upgrade:**
- Cost: 100 copper (one-time)
- New cap: 350 copper
- Long-term benefit: No ongoing fees

**Option B - Use ATM Deposit:**
- Deposit 150 copper, pay 4.5 copper fee (3%)
- Pocket freed for more earning
- Withdraw later, pay 2% fee
- **Total cost: 5% round-trip**

**When to use each:**
- **Upgrades**: Better long-term, permanent solution
- **Deposits**: Short-term liquidity, emergency space, saving for big purchase

### UI Design

**New ATM buttons (per currency):**
```
[Exchange] [Deposit] [Withdraw]

In Pocket: 200 / 200 copper
In ATM: 450 copper

Deposit Amount: [___]
Fee (12%): X copper
[Confirm Deposit]

Withdraw Amount: [___]
[Confirm Withdrawal]
```

### Implementation

**File to modify:**
- `level1/atm.gd` - Add deposit/withdraw functionality

**New variables:**
```gdscript
# In level_1_vars.gd
var atm_deposits = {
    "copper": 0.0,
    "silver": 0.0,
    "gold": 0.0,
    "platinum": 0.0
}
```

**New functions:**
```gdscript
# In currency_manager.gd
func deposit_to_atm(currency_type: String, amount: float):
    var fee_percent = calculate_deposit_fee()  # 3% base, reduced by charisma
    var fee = amount * fee_percent
    if Level1Vars.currency[currency_type] >= amount:
        Level1Vars.currency[currency_type] -= amount
        Level1Vars.atm_deposits[currency_type] += (amount - fee)
        Global.add_stat_exp("charisma", fee)
        return true
    return false

func withdraw_from_atm(currency_type: String, amount: float):
    var fee_percent = calculate_withdrawal_fee()  # 2% base, reduced by charisma
    var fee = amount * fee_percent
    if Level1Vars.atm_deposits[currency_type] >= amount:
        var amount_after_fee = amount - fee
        Level1Vars.atm_deposits[currency_type] -= amount
        Level1Vars.currency[currency_type] += amount_after_fee
        Global.add_stat_exp("charisma", fee)
        return true
    return false
```

## 7. Prestige Skill Trees

**Note**: Prestige skill tree design has been moved to a separate planning document for focused development.

See [skill-trees.md](skill-trees.md) for complete details on:
- Three separate skill trees (Laborer's Wisdom, Overseer's Cunning, Magnate's Empire)
- 24-36 individual skill nodes across all trees
- Tabbed UI implementation in dorm
- Reputation spending and balance philosophy
- Complete prestige reset model (no currency persistence)

---

## 7. Phase-Specific Limiters

These mechanics **slow progression** within each phase, creating the desired playtime targets.

### Phase 1: Furnace Worker (8-15 hours)

**Active limiters:**
1. **Overseer Mood System** (existing) - Variable conversion rates
2. **Price Increases** (existing) - Coal cost per copper rises over time
3. **Coal Storage Cap** - 1000→35000 via upgrades (forces conversions)
4. **Currency Storage Cap** - 200→10000 via upgrades (forces exchanges)
5. **Manual/Auto Conversion** (existing) - Auto mode gives 70% efficiency

**Strategic friction:**
- Can't hoard coal indefinitely (cap forces engagement with mood system)
- Can't hoard copper indefinitely (cap forces ATM engagement)
- Auto-conversion is convenient but less profitable (efficiency trade-off)

**Target income curve:**
- Early: 0.5-2 copper/minute (manual clicking, low upgrades)
- Mid: 5-15 copper/minute (auto-shovels, mood optimization)
- Late: 30-60 copper/minute (full upgrades, hitting caps frequently)

**Phase exit goal**: Accumulate 800 copper + Reputation 5 + Stats 30

### Phase 2: Overseer for Hire (5-10 hours)

**Active limiters:**
1. **Shift Scheduling** - Only certain shifts available at any time
2. **Exhaustion Mechanic** - Can only work X shifts per day
3. **Certification Requirements** - Must purchase licenses to access better shifts
4. **Performance Reviews** - Poor performance reduces future shift availability
5. **Competition** - Other NPCs sometimes take the good shifts (RNG)

**Example shift structure:**
```
Available Shifts:
- Small Furnace #7: 2 silver/hour (Low requirement)
- Medium Furnace #3: 5 silver/hour (Requires Cert Level 1)
- Large Furnace #1: 10 silver/hour (Requires Cert Level 3, Performance 80%+)

Shifts Remaining Today: 4 / 6
Exhaustion: Medium (penalties start at 2 remaining)
```

**Strategic friction:**
- Can't work 24/7 (exhaustion limit)
- Can't always pick best shifts (availability + competition)
- Must invest in certifications (upfront costs)
- Must perform well (quality, not just quantity)

**Target income curve:**
- Early: 2-5 silver/hour (low-tier shifts, few certifications)
- Mid: 15-30 silver/hour (good shift selection, reputation bonuses)
- Late: 50-80 silver/hour (optimal setup, prestige bonuses)

**Phase exit goal**: Accumulate 800 silver + Reputation 15 + Stats 45 + Pass exam

### Phase 3: Own Furnace (10-25 hours)

**Active limiters:**
1. **Worker Wages** - Passive income has maintenance costs
2. **Equipment Degradation** - Furnace requires repairs (costs gold)
3. **Demand Fluctuation** - Revenue varies by market conditions
4. **Worker Morale** - Affects productivity (management required)
5. **Fuel Costs** - Operating expenses scale with production
6. **Nobility Credit Accumulation** - Final gate to endgame

**Example management screen:**
```
Daily Revenue: 15 gold
Daily Expenses:
- Worker Wages: -5 gold
- Fuel Costs: -3 gold
- Maintenance: -2 gold
Net Profit: 5 gold/day

Workers: 8 / 10 (Morale: 75%)
Equipment Durability: 60% (Repair costs increase below 50%)
Current Demand: High (Revenue +25%)

Nobility Credit: 45 / 100 (Unlock train escape at 100)
```

**Strategic friction:**
- Can't just AFK for profit (requires active management)
- Bad decisions reduce profitability (hiring too many workers, ignoring maintenance)
- Market fluctuations create variance (some days are better than others)
- Final goal requires sustained success (nobility credit accumulation)

**Target income curve:**
- Early: 5-10 gold/day (small operation, learning curve)
- Mid: 25-50 gold/day (optimized management, reputation bonuses)
- Late: 100-200 gold/day + platinum accumulation + nobility credit

**Phase exit goal**: Accumulate 100 Nobility Credit → Escape train → Level 2

---

## 8. Economic Friction Summary

All the systems that create **costs and inefficiencies** to slow exponential growth:

### Existing Systems (Keep)
1. **ATM Exchange Fees**: 1-8% based on volume, reduced by charisma
2. **Market Volatility**: ±30% variance on exchange rates
3. **Overseer Price Increases**: +1 coal per conversion made
4. **Manual vs Auto Conversion**: Auto mode gives 70% efficiency

### New Systems (Add)
5. **ATM Deposit Fee**: 3% to deposit currency
6. **ATM Withdrawal Fee**: 2% to withdraw currency
7. **Storage Caps**: 200→10000, forces strategic decisions
8. **Coal Tracking Caps**: 1000→35000, forces conversions
9. **Equipment Maintenance**: Shovels/plows degrade, require repairs
10. **Overseer's Cut**: Takes 10% of coal-to-copper conversions (decreases with reputation)

### Phase 2 Friction (New Phase)
11. **Shift Licensing Fees**: Certifications cost silver, periodic renewal
12. **Exhaustion Limits**: Can only work X shifts per day
13. **Competition RNG**: Sometimes lose shifts to other overseers
14. **Performance Requirements**: Poor performance locks out better shifts

### Phase 3 Friction (New Phase)
15. **Worker Wages**: Daily/hourly costs for employees
16. **Fuel Costs**: Operating expenses scale with production
17. **Equipment Degradation**: Furnace repairs cost gold
18. **Market Fluctuations**: Demand variance affects revenue

### Combined Effect
These friction systems **don't prevent growth**, they **slow it down** in engaging ways:
- Players make trade-offs (spend vs save vs upgrade)
- Multiple paths to optimize (charisma for fees, reputation for discounts, storage for capacity)
- Variance keeps gameplay interesting (not just predictable exponential curves)

---

## 9. Earning Rate Targets & Phase Timing

### Phase 1: Furnace Worker

**Target Duration**: 8-15 hours active play

**Income Progression**:
| Time | Income Rate | Total Earned | Upgrades |
|------|-------------|--------------|----------|
| Hour 1-3 | 1-5 copper/min | ~400 copper | Basic shovel, first auto-shovel |
| Hour 4-8 | 10-25 copper/min | ~2000 copper | Multiple auto-shovels, storage upgrades |
| Hour 9-15 | 30-60 copper/min | ~8000+ copper | Full upgrades, hitting caps, exchanging to silver |

**Phase Exit**: 800 copper + Reputation 5 + Stats 30
**Expected Prestiges**: 1-3 cycles to reach Reputation 5

### Phase 2: Overseer for Hire

**Target Duration**: 5-10 hours active play

**Income Progression**:
| Time | Income Rate | Total Earned | Milestones |
|------|-------------|--------------|------------|
| Hour 1-2 | 2-8 silver/hr | ~20 silver | Low-tier shifts, basic certs |
| Hour 3-6 | 15-35 silver/hr | ~150 silver | Mid-tier shifts, reputation bonuses |
| Hour 7-10 | 50-80 silver/hr | ~600+ silver | High-tier shifts, prestige bonuses |

**Phase Exit**: 800 silver + Reputation 15 + Stats 45 + Pass exam
**Expected Prestiges**: 2-4 cycles to reach Reputation 15

### Phase 3: Own Furnace

**Target Duration**: 10-25 hours active play

**Income Progression**:
| Time | Income Rate | Total Earned | Development |
|------|-------------|--------------|-------------|
| Day 1-3 | 5-15 gold/day | ~50 gold | Learning management, small operation |
| Day 4-10 | 25-60 gold/day | ~400 gold | Optimized management, worker upgrades |
| Day 11-25 | 100-200 gold/day | ~2500+ gold | Multiple furnaces, platinum generation |

**Phase Exit**: 100 Nobility Credit → Train escape → Level 2
**Expected Prestiges**: 3-6 cycles to reach Reputation 25+ and accumulate credit

### Total Playtime to Complete Level 1
**Minimum Path**: 23 hours (8 + 5 + 10)
**Expected Path**: 33 hours (11 + 7 + 15)
**Completionist Path**: 50+ hours (15 + 10 + 25+)

---

## 10. Implementation Roadmap

### Priority 1: Core Currency Changes (Must do first)
- [ ] Update currency ratios to 1000:1 in `currency_manager.gd`
- [ ] Update ATM exchange calculations in `atm.gd`
- [ ] Migrate existing saves (multiply currency by 10)
- [ ] Update currency unlock thresholds (500 copper, 50 silver, 50 gold)
- [ ] Test all currency exchanges and conversions

### Priority 2: Storage System (Foundation for friction)
- [ ] Create unified storage capacity system (200→10000, 12 tiers)
- [ ] Add storage upgrade shop category
- [ ] Implement currency cap checking in earning functions
- [ ] Create coal record-keeping system (1000→35000)
- [ ] Add overflow warnings and UI indicators
- [ ] Test storage caps prevent earning beyond limit

### Priority 3: ATM Deposit System (Adds strategic depth)
- [ ] Add deposit/withdraw functionality to ATM
- [ ] Implement deposit (3%) and withdrawal (2%) fees
- [ ] Create ATM storage variables in `level_1_vars.gd`
- [ ] Design and implement deposit/withdraw UI
- [ ] Test round-trip fee calculations with charisma
- [ ] Add grimdark flavor messages

### Priority 4: Phase Gate System (Progression structure)
- [ ] Add phase tracking variables (`current_phase`, unlock flags)
- [ ] Implement combined stats checking function
- [ ] Create Phase 2 unlock check (800 copper + Rep 5 + Stats 30)
- [ ] Create Phase 3 unlock check (800 silver + Rep 15 + Stats 45)
- [ ] Implement leadership examination system (10 questions, 70% pass)
- [ ] Add phase transition UI and messages
- [ ] Test all gate requirements trigger correctly

### Priority 5: Prestige Skill Trees (Long-term progression)
**See [skill-trees.md](skill-trees.md) for complete design details**
- [ ] Implement tabbed UI in dorm scene
- [ ] Create Phase 1 tree nodes and effects
- [ ] Create Phase 2 tree nodes and effects (Phase 2 mechanics must exist first)
- [ ] Create Phase 3 tree nodes and effects (Phase 3 mechanics must exist first)
- [ ] Ensure complete currency reset (NO persistence)
- [ ] Test reputation spending and node unlocking

### Priority 6: Phase 2 Mechanics (New content)
**Note**: This is NEW functionality, not just balance changes
- [ ] Design shift scheduling system
- [ ] Implement exhaustion mechanic
- [ ] Create certification/license system
- [ ] Add performance review tracking
- [ ] Implement NPC competition for shifts
- [ ] Balance silver earning rates to hit 5-10 hour target

### Priority 7: Phase 3 Enhancements (Extend existing plan)
**Note**: Builds on existing `phase-5-own-furnace.md` plan
- [ ] Implement worker wage system
- [ ] Add equipment degradation
- [ ] Create demand fluctuation
- [ ] Implement worker morale
- [ ] Add fuel costs
- [ ] Create nobility credit system
- [ ] Design train escape sequence to Level 2
- [ ] Balance gold earning to hit 10-25 hour target

### Priority 8: Economic Friction (Polish)
- [ ] Add equipment maintenance costs
- [ ] Implement overseer's cut (10% of conversions)
- [ ] Create Phase 2 licensing fees
- [ ] Add Phase 3 operating costs
- [ ] Balance all friction systems for target playtimes

### Priority 9: Balance Testing (Iteration)
- [ ] Playtest Phase 1 for 8-15 hour target
- [ ] Adjust earning rates and costs as needed
- [ ] Playtest Phase 2 for 5-10 hour target
- [ ] Playtest Phase 3 for 10-25 hour target
- [ ] Test full progression path (all 3 phases)
- [ ] Gather feedback and iterate

---

## 11. Migration Strategy

### For Existing Saves

**Currency Conversion**:
```gdscript
# Multiply all existing currency by 10 to maintain relative value
Level1Vars.currency.copper *= 10
Level1Vars.currency.silver *= 10
Level1Vars.currency.gold *= 10
Level1Vars.currency.platinum *= 10
Level1Vars.lifetime_currency.copper *= 10
Level1Vars.lifetime_currency.silver *= 10
# etc.
```

**New Variables to Initialize**:
```gdscript
# Storage system
Level1Vars.storage_capacity_level = 0
Level1Vars.coal_tracking_level = 0

# ATM deposits
Level1Vars.atm_deposits = {"copper": 0, "silver": 0, "gold": 0, "platinum": 0}

# Phase system
Level1Vars.current_phase = 1
Level1Vars.phase_2_unlocked = false
Level1Vars.phase_3_unlocked = false
Level1Vars.leadership_exam_passed = false

# Reputation trees
Global.reputation_upgrades_phase1 = []
Global.reputation_upgrades_phase2 = []
Global.reputation_upgrades_phase3 = []
```

**Display Migration Notice**:
```
"Currency system updated!
All currency values have been adjusted to the new scale.
New features unlocked: Storage upgrades, ATM deposits, Phase progression."
```

### For New Saves

All new systems start at default values:
- Storage cap: 200 for all currencies
- Coal tracking: 1000
- Phase: 1 (Phase 2 and 3 locked)
- Currency ratios: 1000:1 from the start

---

## 12. Balance Testing Checklist

### Phase 1 Tests
- [ ] New player can earn 800 copper in 8-15 hours
- [ ] Storage caps create pressure without frustration
- [ ] ATM deposit system feels useful (not mandatory)
- [ ] Prestige at Reputation 5 feels natural (not forced)
- [ ] Combined stats 30 achievable through varied playstyles
- [ ] Mood system still engaging with new currency scale

### Phase 2 Tests
- [ ] Phase 2 unlocks feel earned (not arbitrary)
- [ ] Shift system creates interesting decisions
- [ ] Exhaustion limit feels fair (not punishing)
- [ ] Certification costs are balanced
- [ ] Silver earning hits 5-10 hour target
- [ ] Leadership exam is challenging but fair (7/10 pass rate)

### Phase 3 Tests
- [ ] Phase 3 transition feels like major milestone
- [ ] Worker management is engaging (not tedious)
- [ ] Operating costs are meaningful (not trivial)
- [ ] Nobility credit accumulation paces endgame well
- [ ] Gold/platinum earning hits 10-25 hour target
- [ ] Train escape sequence is satisfying conclusion

### System Integration Tests
- [ ] All 3 phases flow smoothly into each other
- [ ] Prestige skill trees provide meaningful bonuses
- [ ] Currency exchange rates make sense at 1000:1
- [ ] Storage upgrade curve feels rewarding
- [ ] Economic friction slows but doesn't stop progress
- [ ] Total playtime (23-50 hours) feels appropriate for Level 1

### Performance Tests
- [ ] Large currency numbers display correctly
- [ ] Calculations don't overflow or lose precision
- [ ] Save/load works with all new systems
- [ ] UI remains responsive with multiple currencies
- [ ] Phase transitions don't cause bugs or data loss

---

## 13. Final Notes

### Design Philosophy Summary
This redesign solves the currency scaling problem through **layered systems**:
1. **More room to grow** (1000:1 ratios)
2. **Strategic friction** (storage caps, fees, costs)
3. **Multiple progression axes** (currency, reputation, stats, phases)
4. **Distinct phase identities** (laborer, overseer, magnate)
5. **Skill-based gates** (exams, management, optimization)

### Key Success Metrics
- Phase 1 completion: 8-15 hours
- Phase 2 completion: 5-10 hours
- Phase 3 completion: 10-25 hours
- Total Level 1 completion: 23-50 hours
- Player retention through prestige cycles
- Engagement with multiple systems (not just grinding one)

### Next Steps
1. Review this plan with stakeholders
2. Prioritize implementation phases
3. Start with Priority 1 (core currency changes)
4. Test incrementally after each priority tier
5. Iterate based on playtesting feedback

### Related Documents
- [skill-trees.md](skill-trees.md) - Prestige skill trees detailed design
- `.claude/plans/phase-5-own-furnace.md` - Phase 3 detailed design
- `.claude/docs/game-systems.md` - Current systems reference
- `.claude/docs/BIBLE.md` - Documentation index
- `.claude/docs/deployment.md` - Deployment and build procedures
- `.claude/docs/game-design-principles.md` - Game design philosophy and principles
- `.claude/docs/programming-principles.md` - Programming standards and best practices

---

**End of Currency Scaling Redesign Plan**

