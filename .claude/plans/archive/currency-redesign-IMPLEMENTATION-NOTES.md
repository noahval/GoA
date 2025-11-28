# Currency Scaling Redesign - Implementation Status

**Date**: 2025-01-14
**Status**: Core systems implemented (Priority 1-3 complete)
**Based on**: [currency-scaling-redesign.md](currency-scaling-redesign.md)

---

## Implementation Summary

### COMPLETED: Priority 1 - Core Currency Changes

**Files Modified:**
- [currency_manager.gd](../../currency_manager.gd)
- [level1/level_1_vars.gd](../../level1/level_1_vars.gd)
- [level1/atm.gd](../../level1/atm.gd)

**Changes:**
1. Updated `CONVERSION_RATES` from 100:1 to 1000:1
   - Silver: 1000 copper = 1 silver
   - Gold: 1000 silver = 1 gold
   - Platinum: 1000 gold = 1 platinum

2. Updated currency unlock thresholds:
   - Silver: 500 copper (lifetime earnings) - UNCHANGED
   - Gold: 50 silver in hand (was 60)
   - Platinum: 50 gold in hand (was 60)

3. Updated ATM market rates display to use 1000:1 ratios

4. Created migration function `migrate_to_new_currency_scale()` in CurrencyManager
   - Multiplies all existing currency by 10x
   - Multiplies lifetime currency by 10x
   - One-time migration on first load

---

### COMPLETED: Priority 2 - Storage System

**Files Modified:**
- [level1/level_1_vars.gd](../../level1/level_1_vars.gd)
- [level1/shop.gd](../../level1/shop.gd)
- [upgrade_types_config.gd](../../upgrade_types_config.gd)
- [currency_manager.gd](../../currency_manager.gd)
- [level1/furnace.gd](../../level1/furnace.gd)

**New Variables Added to Level1Vars:**
```gdscript
# Storage capacity system (unified for all currencies)
var storage_capacity_level: int = 0
var storage_capacity_caps: Array[int] = [200, 300, 450, 650, 900, 1250, 1750, 2500, 3500, 5000, 7000, 8500, 10000]

# Coal record-keeping system
var coal_tracking_level: int = 0
var coal_tracking_caps: Array[int] = [1000, 2000, 4000, 7000, 12000, 20000, 35000]

# ATM deposit system (stored currency beyond pocket capacity)
var atm_deposits = {
    "copper": 0.0,
    "silver": 0.0,
    "gold": 0.0,
    "platinum": 0.0
}

# Phase progression system
var current_phase: int = 1  # 1, 2, or 3
var phase_2_unlocked: bool = false
var phase_3_unlocked: bool = false
var leadership_exam_passed: bool = false
var leadership_exam_attempts: int = 0
var leadership_exam_cooldown_until: int = 0
```

**New Helper Functions in Level1Vars:**
- `get_currency_cap() -> int` - Returns current currency storage cap
- `get_coal_cap() -> int` - Returns current coal tracking cap
- `would_exceed_currency_cap(currency_type, amount) -> bool`
- `would_exceed_coal_cap(amount) -> bool`
- `get_combined_stats_level() -> int` - For phase gate checks

**Storage Upgrades Added to Shop:**
| Tier | Name | Capacity | Cost |
|------|------|----------|------|
| 0 | Base | 200 | Free |
| 1 | Belt Pouch | 300 | 175 copper |
| 2 | Leather Purse | 450 | 250 copper |
| 3 | Reinforced Pouch | 650 | 400 copper |
| 4 | Heavy Coin Bag | 900 | 800 copper |
| 5 | Merchant's Satchel | 1,250 | 2 silver |
| 6 | Trader's Case | 1,750 | 6 silver |
| 7 | Banker's Chest | 2,500 | 20 silver |
| 8 | Strongbox Key | 3,500 | 70 silver |
| 9 | Vault Access | 5,000 | 250 silver |
| 10 | Private Vault | 7,000 | 1 gold |
| 11 | Master Vault | 8,500 | 5 gold |
| 12 | Noble's Treasury | 10,000 | 50 gold |

**Coal Tracking Upgrades Added to Shop:**
| Tier | Name | Capacity | Cost |
|------|------|----------|------|
| 0 | Mental Tally | 1,000 | Free |
| 1 | Chalk Marks | 2,000 | 50 copper |
| 2 | Wax Tablet | 4,000 | 150 copper |
| 3 | Ledger Book | 7,000 | 400 copper |
| 4 | Accounting System | 12,000 | 1,000 copper |
| 5 | Master Records | 20,000 | 3,000 copper |
| 6 | Overseer's Trust | 35,000 | 8,000 copper |

**Cap Checking Implemented:**
1. Currency earning caps enforced in `CurrencyManager.add_currency()`
   - Shows notification when pockets are full
   - Returns actual amount added

2. Coal earning caps enforced in `furnace.gd`:
   - Auto-shovel coal generation capped
   - Manual shoveling capped
   - Shows notification when coal tracking limit reached

---

### COMPLETED: Priority 3 - ATM Deposit System

**Files Modified:**
- [currency_manager.gd](../../currency_manager.gd)

**New Functions Added:**
1. `calculate_deposit_fee() -> float`
   - Base fee: 12%
   - Reduces by 0.5% per charisma level
   - Minimum: 1% fee

2. `deposit_to_atm(currency_type, amount) -> Dictionary`
   - Deducts currency from pocket
   - Applies deposit fee
   - Stores net amount in ATM
   - Awards charisma XP based on fee

3. `withdraw_from_atm(currency_type, amount) -> Dictionary`
   - Instant withdrawal (no fee)
   - Checks pocket capacity before withdrawing
   - Returns error if pocket full

4. `get_atm_balance(currency_type) -> float`
   - Returns current ATM storage for currency type

**Exchange Enhancement:**
- `exchange_currency_with_fee()` now uses BOTH pocket + ATM deposits
- Deducts from pocket first, then ATM if needed
- Allows exchanging deposited currency without withdrawing first

---

### COMPLETED: Priority 4 - Phase Gate System (Variables Only)

**Files Modified:**
- [level1/level_1_vars.gd](../../level1/level_1_vars.gd)

**Phase Variables Added:**
- `current_phase` - Tracks player's current phase (1, 2, or 3)
- `phase_2_unlocked` - Gate to Phase 2 (Overseer for Hire)
- `phase_3_unlocked` - Gate to Phase 3 (Own Furnace)
- `leadership_exam_passed` - Required for Phase 3
- `leadership_exam_attempts` - Track exam retries
- `leadership_exam_cooldown_until` - Prevent exam spam

**Phase Gate Requirements (from plan):**
- **Phase 1 → Phase 2**: 800 copper + Rep 5 + Stats 30 + Quest + Overseer Relations
- **Phase 2 → Phase 3**: 800 silver + Rep 15 + Stats 45 + Leadership Exam + Furnace Deed

**Note**: Gate checking logic NOT YET IMPLEMENTED. Variables are ready but need to be integrated into:
- Overseer's Office scene (Phase 2 unlock)
- Magistrate scene (Phase 3 unlock) - may need to create this scene

---

## Prestige System Updates

**Modified Files:**
- [level1/level_1_vars.gd](../../level1/level_1_vars.gd)

**Items that PERSIST through prestige:**
- storage_capacity_level (persistent upgrade)
- coal_tracking_level (persistent upgrade)
- atm_deposits (banked currency persists)
- phase unlocks and progression
- currency.platinum (Platinum Bonds - as before)
- All lifetime currency tracking

**Items that RESET on prestige:**
- currency.copper, .silver, .gold (pocket money)
- coal, equipment_value, upgrades
- All standard Phase 1 progress

---

## Testing Guide

### Test 1: Currency Ratios
```gdscript
# In debug console or dev mode
Level1Vars.currency.copper = 1000
# Should unlock silver when you have 500 copper lifetime

Level1Vars.currency.silver = 50
# Should unlock gold at ATM

Level1Vars.currency.gold = 50
# Should unlock platinum at ATM
```

### Test 2: Storage Caps
```gdscript
# Start with 200 cap
Level1Vars.currency.copper = 200
# Try to earn more - should cap and show notification

# Purchase storage upgrade from shop
# New cap should be 300
```

### Test 3: Coal Caps
```gdscript
# Start with 1000 cap
Level1Vars.coal = 1000
# Try to shovel - should show notification

# Purchase coal tracking upgrade from shop
# New cap should be 2000
```

### Test 4: ATM Deposits
```gdscript
# In CurrencyManager
CurrencyManager.deposit_to_atm(CurrencyManager.CurrencyType.COPPER, 100)
# Should deduct 100 + 12% fee from pocket
# Should add ~88 to ATM deposits

CurrencyManager.withdraw_from_atm(CurrencyManager.CurrencyType.COPPER, 50)
# Should move 50 from ATM to pocket (no fee)
```

### Test 5: Currency Exchange with ATM
```gdscript
# Put 500 copper in pocket, 600 in ATM
Level1Vars.currency.copper = 500
Level1Vars.atm_deposits.copper = 600.0

# Try to exchange 1000 copper to silver
# Should pull 500 from pocket + 500 from ATM
# Should receive ~1 silver (minus fees)
```

---

## TODO: Remaining Implementation

### UI Integration Needed:
1. **Shop Scene**:
   - Add "Storage Capacity" button to shop UI
   - Add "Coal Tracking" button to shop UI
   - Connect to `_on_storage_upgrade_pressed()` and `_on_coal_tracking_upgrade_pressed()`
   - Display current caps and next upgrade info

2. **ATM Scene**:
   - Add Deposit/Withdraw buttons for each currency
   - Add input fields for deposit/withdraw amounts
   - Display ATM balances alongside pocket balances
   - Show deposit fee calculation preview
   - Connect to CurrencyManager functions

3. **Status Displays**:
   - Show "X / CAP" for currency displays
   - Show "X / CAP" for coal display
   - Warning indicators when approaching cap

### Phase Gate Integration:
1. **Overseer's Office**:
   - Add Phase 2 unlock check and UI
   - Display requirements (800 copper, Rep 5, Stats 30)
   - Show unlock dialog when requirements met

2. **Magistrate Scene** (may need to create):
   - Add Phase 3 unlock check and UI
   - Implement leadership examination system
   - Display requirements (800 silver, Rep 15, Stats 45, exam)
   - Furnace deed purchase

### Save System:
1. Add migration flag to save data structure
2. Call `CurrencyManager.migrate_to_new_currency_scale()` on load
3. Ensure ATM deposits save/load correctly
4. Ensure phase variables save/load correctly

---

## Known Issues / Notes

1. **Migration**: The `migrate_to_new_currency_scale()` function needs to be called on save load. The migration flag check currently uses `currency.get("_migration_v2_done")` which won't persist - need to add proper flag to save system.

2. **UI Not Connected**: All the backend logic is implemented but UI elements (buttons, labels, popups) need to be added to the scene files (.tscn). This requires Godot editor work.

3. **Phase Gates**: Variables are ready but gate checking logic needs to be implemented in specific scenes (Overseer's Office, Magistrate).

4. **Balance Testing**: Currency and upgrade costs haven't been playtested yet. May need adjustment based on actual gameplay feel.

5. **Deposit Fee UI**: Users should see the fee calculation BEFORE depositing (preview). Currently only shown after transaction.

---

## Files Modified Summary

**Core Systems:**
- `currency_manager.gd` - Ratios, caps, ATM deposit/withdraw, migration
- `level1/level_1_vars.gd` - Storage variables, helper functions, phase tracking
- `upgrade_types_config.gd` - Added storage upgrade types

**Game Scenes:**
- `level1/atm.gd` - Updated market rates display
- `level1/shop.gd` - Added storage/coal tracking upgrade logic
- `level1/furnace.gd` - Added coal cap checking

**Documentation:**
- `.claude/plans/currency-redesign-IMPLEMENTATION-NOTES.md` - This file

---

## Next Steps

**Priority:**
1. Add storage upgrade buttons to shop.tscn UI
2. Add deposit/withdraw UI to atm.tscn
3. Test migration function with real save data
4. Add migration call to save/load system
5. Playtest and balance costs

**Future (Phase 2 & 3 content):**
- Implement Phase 2 mechanics (shift system, exhaustion, certs)
- Implement Phase 3 mechanics (furnace management, workers, expenses)
- Create prestige skill trees (see skill-trees.md)
- Implement leadership examination system
- Create Magistrate scene and furnace deed system

---

**End of Implementation Notes**
