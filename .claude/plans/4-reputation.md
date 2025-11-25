# Prestige Skill Trees Plan

## Document Version
- **Created**: 2025-01-14
- **Status**: Planning (separated from currency redesign)
- **Context**: Part of larger progression redesign, see [currency-scaling-redesign.md](currency-scaling-redesign.md)

---

## Overview

### Concept
Replace the current single 16-node skill tree with **three separate trees**, each focused on a different phase. Players switch between trees using tabs in the dorm UI.

### Complete Reset Model
**NO currency persists through prestige** (including platinum):
- Reset: All coal, copper, silver, gold, platinum
- Reset: All shop upgrades, equipment value
- **Keep**: Reputation points (spendable), lifetime reputation earned
- **Keep**: Reputation skill tree purchases, overtime level

**Rationale**: Complete resets maintain balance and prevent snowballing. Reputation system provides the permanent progression.

---

## Tab 1: "Working" (Phase 1 Focus)

### Theme
Efficiency improvements for coal shoveling and copper earning

### Example Nodes (8-12 total)
1. **Strong Back** (Cost: 1) - +10% coal per click
2. **Steady Hands** (Cost: 1) - Mood drift reduced by 25%
3. **Quick Learner** (Cost: 2) - +20% XP from all sources
4. **Copper Sense** (Cost: 2) - See exact mood value instead of adjectives
5. **Efficient Shoveling** (Cost: 3) - Auto-shovels work 10% faster
6. **Mood Mastery** (Cost: 3) - Fatigue penalty reduced by 50%
7. **Storage Savvy** (Cost: 4) - Storage upgrades cost 20% less
8. **Early Wealth** (Cost: 5) - Start each prestige with 10 copper

**Cost range**: 1-5 reputation per node

---

## Tab 2: "Supervision" (Phase 2 Focus)

### Theme
Advantages for shift work and silver earning

### Example Nodes (8-12 total)
1. **Shift Awareness** (Cost: 3) - See next 3 available shifts instead of 1
2. **Tireless** (Cost: 3) - +2 shifts per day before exhaustion
3. **Negotiator** (Cost: 4) - Shift pay increased by 15%
4. **License Discount** (Cost: 4) - Certifications cost 25% less
5. **Reputation Builder** (Cost: 5) - Gain reputation 10% faster
6. **Competition Edge** (Cost: 5) - 20% less likely to lose shift to other overseers
7. **Silver Start** (Cost: 6) - Start each prestige with 50 silver
8. **Exam Preparation** (Cost: 8) - Can see 3 exam questions before starting

**Cost range**: 3-8 reputation per node

**Prerequisites**: Some nodes require Phase 2 unlocked

---

## Tab 3: "Ownership" (Phase 3 Focus)

### Theme
Business optimization and nobility credit accumulation

### Example Nodes (8-12 total)
1. **Worker Training** (Cost: 5) - Workers produce 10% more
2. **Maintenance Expert** (Cost: 5) - Equipment degrades 25% slower
3. **Market Insight** (Cost: 6) - See demand forecast 1 day ahead
4. **Wage Efficiency** (Cost: 6) - Worker wages reduced by 15%
5. **Fuel Economy** (Cost: 7) - Operating costs reduced by 20%
6. **Noble Connections** (Cost: 8) - Nobility credit gained 25% faster
7. **Gold Standard** (Cost: 10) - Start prestige with 25 gold
8. **Empire Builder** (Cost: 12) - Unlock second furnace (advanced mechanic)

**Cost range**: 5-12 reputation per node

**Prerequisites**: Most nodes require Phase 3 unlocked

---

## UI Implementation

### Tabbed Interface in Dorm
```
[Laborer's Wisdom] [Overseer's Cunning] [Magnate's Empire]

                  [Skill Node Tree Display]

Reputation Available: 15
Prestige Again: Costs X equipment value, grants Y reputation
```

### Visual Feedback
- **Locked nodes**: Grayed out with prerequisites listed
- **Affordable nodes**: Highlighted, clickable
- **Purchased nodes**: Green checkmark, permanent
- **Tabs**: Phase 1 tab always available, Phase 2/3 tabs unlock with phases

---

## Implementation Files

### Files to Modify
- `level1/dorm.gd` - Replace single tree with tabbed tree system
- `global.gd` - Separate reputation upgrade tracking per tree
- Prestige reset function - Ensure NO currency persists

### New Variables
```gdscript
# In global.gd or level_1_vars.gd
var reputation_upgrades_phase1 = []  # IDs of purchased nodes
var reputation_upgrades_phase2 = []
var reputation_upgrades_phase3 = []
```

---

## Balance Philosophy

### Early Game (Phase 1 Tree)
- Cheap nodes (1-5 reputation) to feel impactful quickly
- Focus on reducing grind, improving efficiency

### Mid Game (Phase 2 Tree)
- Moderate costs (3-8 reputation) require investment
- Unlock quality-of-life features for shift management

### Late Game (Phase 3 Tree)
- Expensive nodes (5-12 reputation) are long-term goals
- Powerful benefits for endgame optimization

---

## Related Systems

### Reputation Earning
Prestige skill trees are purchased with **reputation points**. For reputation earning mechanics, see [currency-scaling-redesign.md](currency-scaling-redesign.md).

### Phase Unlock Requirements
For phase transition gates and requirements, see [currency-scaling-redesign.md](currency-scaling-redesign.md), Section 3.

### Prestige Reset Mechanics
Complete resets (no currency persistence) are core to the prestige system design. Only reputation and skill tree purchases persist across resets.

---

## Future Expansion Ideas

### Additional Nodes (Not Yet Designed)
Each tree could expand to 12-16 nodes with:
- Multiple paths through each tree
- More expensive capstone nodes
- Synergies between different trees
- Phase-specific quality-of-life improvements

### Visual Design
- Skill tree visualization (branching paths vs linear progression)
- Node icons and descriptions
- Tooltip previews of effects
- Visual indication of active bonuses

### Tutorial/Onboarding
- First prestige walkthrough
- Explanation of reputation system
- Guidance on choosing first nodes
- Tips for optimal progression

---

**End of Prestige Skill Trees Plan**
