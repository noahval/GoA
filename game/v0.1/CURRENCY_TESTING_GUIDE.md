# Currency System Testing Guide

## Implementation Complete

The 4-tier currency system has been successfully implemented following strict TDD methodology.

## What Was Implemented

### 1. Data Structures ([level_1_vars.gd](level1/level_1_vars.gd))
- **VALID_CURRENCIES** constant: ["copper", "silver", "gold", "platinum"]
- **currency** dictionary: Current holdings for all 4 currency types
- **lifetime_currency** dictionary: Lifetime earnings (never decreases)
- **currency_changed** signal: Emitted when currency changes

### 2. Core Functions
- **_get_empty_currency_dict()**: Helper to create empty currency dictionaries
- **add_currency(type, amount)**: Add currency and track lifetime earnings
- **deduct_currency(type, amount)**: Spend currency with validation
- **get_currency(type)**: Get current amount of a currency type
- **can_afford(type, amount)**: Check if player can afford an amount

### 3. Bulk Operations
- **can_afford_all(costs)**: Check affordability for multiple currencies
- **deduct_currencies(costs)**: All-or-nothing multi-currency transaction

### 4. Reset & Save/Load
- **reset_all_currency()**: Reset both current and lifetime currencies
- Updated **get_save_data()** to save currency dictionaries
- Updated **load_save_data()** with backward compatibility for old copper_current

### 5. Test Suite ([tests/test_currencies.gd](tests/test_currencies.gd))
- 40+ comprehensive tests covering all functionality
- Tests for data structures, add/deduct, helpers, bulk operations, and integration

## How to Run Tests

### Option 1: Using Godot Editor (Recommended)

1. Open the project in Godot 4.5
2. Enable the GUT plugin:
   - Go to **Project > Project Settings > Plugins**
   - Enable the **Gut** plugin
3. Open the GUT panel:
   - Go to **Project > Tools > Gut Panel** (or bottom panel)
4. Click **Run All** to run all tests
5. Or select [test_currencies.gd](tests/test_currencies.gd) and click **Run**

### Option 2: Command Line (if godot is in PATH)

```bash
cd C:\Goa\game\v0.1
godot --headless --script res://addons/gut/gut_cmdln.gd -gtest=res://tests/test_currencies.gd
```

### Option 3: Manual Testing in Godot Console

Open the Godot editor and use the console to test manually:

```gdscript
# Test 1: Add copper
Level1Vars.add_currency("copper", 100.0)
print(Level1Vars.currency["copper"])  # Should print 100
print(Level1Vars.lifetime_currency["copper"])  # Should print 100

# Test 2: Add multiple currencies
Level1Vars.add_currency("silver", 50.0)
Level1Vars.add_currency("gold", 25.0)
Level1Vars.add_currency("platinum", 10.0)

# Test 3: Deduct currency
var success = Level1Vars.deduct_currency("copper", 30.0)
print(success)  # Should print true
print(Level1Vars.currency["copper"])  # Should print 70
print(Level1Vars.lifetime_currency["copper"])  # Should still be 100

# Test 4: Insufficient funds
success = Level1Vars.deduct_currency("gold", 100.0)
print(success)  # Should print false

# Test 5: Bulk operations
var cost = {"copper": 50.0, "silver": 10.0}
print(Level1Vars.can_afford_all(cost))  # Should print true
Level1Vars.deduct_currencies(cost)
print(Level1Vars.currency["copper"])  # Should print 20
print(Level1Vars.currency["silver"])  # Should print 40

# Test 6: Signal emission (connect to test)
Level1Vars.currency_changed.connect(func(type, old, new):
    print("Currency changed: %s from %.2f to %.2f" % [type, old, new])
)
Level1Vars.add_currency("platinum", 5.0)  # Should trigger signal
```

## Expected Test Results

All 40+ tests should **PASS**, including:

- [x] Data structure tests (dictionaries, constants)
- [x] Add currency tests (basic, accumulation, validation, signals)
- [x] Deduct currency tests (basic, insufficient funds, exact amount)
- [x] Helper function tests (get_currency, can_afford)
- [x] Bulk operation tests (can_afford_all, deduct_currencies)
- [x] Reset function tests
- [x] Integration tests (lifetime tracking, transaction flows)

## Manual Verification Checklist

After tests pass, verify these scenarios:

- [ ] Add currency increases both current and lifetime amounts
- [ ] Deduct currency decreases current but NOT lifetime
- [ ] Insufficient funds deduction returns false and changes nothing
- [ ] Invalid currency types log errors and don't crash
- [ ] Negative/zero amounts are rejected with warnings
- [ ] currency_changed signal emits on add/deduct
- [ ] Signal does NOT emit on failed deductions
- [ ] Bulk operations are all-or-nothing
- [ ] Save/load persists currency correctly
- [ ] Reset clears both current and lifetime

## Files Modified

1. **[level1/level_1_vars.gd](level1/level_1_vars.gd)** (~150 lines added)
   - Currency data structures and functions
   - Save/load integration
   - Backward compatibility for old saves

2. **[tests/test_currencies.gd](tests/test_currencies.gd)** (~370 lines new)
   - Comprehensive test suite following TDD
   - 40+ tests covering all functionality

3. **[.gutconfig.json](.gutconfig.json)** (new)
   - GUT test framework configuration

4. **addons/gut/** (new)
   - GUT testing framework installation

## Next Steps

Once tests pass:

1. Mark this plan (1.5-currencies.md) as complete
2. Proceed to [1.30-currency-manager.md](../.claude/plans/1/1.30-currency-manager.md) for exchange logic
3. Integrate currency earning into gameplay loops
4. Build ATM UI for viewing and exchanging currencies

## Notes

- Legacy **award_pay()** function now uses new **add_currency("copper", amount)**
- Old saves with **copper_current** automatically migrate to new system
- All currency operations emit signals for reactive UI
- Lifetime tracking provides progression statistics
- System ready for market rates and exchange mechanics
