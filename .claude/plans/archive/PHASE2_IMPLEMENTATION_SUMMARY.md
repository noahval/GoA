# Phase 2: Offline Earnings - Implementation Summary

**Status**: ✅ **IMPLEMENTATION COMPLETE** - Ready for manual testing in Godot editor

---

## Overview

Implemented a comprehensive offline earnings system centered around an "Overtime" upgrade purchasable in the Overseer's Office. Players can now earn coal while offline through auto-shovels, with earnings capped by an upgradable "Overtime" limit that progresses from 8 hours to 36 hours.

---

## ✅ Completed Components

### 1. Core System - OfflineEarningsManager Singleton

**File**: [offline_earnings_manager.gd](../../offline_earnings_manager.gd)

- **Autoload registered** in project.godot
- **9 overtime tiers** (0-8): 8h → 12h → 16h → 20h → 24h → 26h → 28h → 30h → 36h
- **Exponential cost scaling**: 300 → 390 → 507 → 659 → 1000 → 1500 → 2250 → 3375 coins
- **50% offline efficiency penalty** (auto-shovels work slower while unmanned)
- **Thematic upgrade names** with grimdark flavor text

**Key Functions**:
- `get_overtime_cost(level)` - Returns cost for next upgrade
- `get_cap_hours_for_level(level)` - Returns hour cap for level
- `calculate_offline_earnings()` - Calculates coal earned while offline
- `get_offline_summary()` - Generates welcome back message with earnings summary

---

### 2. Data Layer Updates

**File**: [level1/level_1_vars.gd](../../level1/level_1_vars.gd)

**New Variables**:
- `overtime_lvl: int = 0` - Current overtime upgrade level
- `offline_cap_hours: float = 8.0` - Current offline earning cap in hours
- `last_played_timestamp: int = 0` - Unix timestamp of last save

**Helper Function**:
- `get_offline_cap_seconds()` - Converts cap hours to seconds

**Prestige Behavior**: Overtime upgrades **persist through prestige** (quality of life feature)

---

### 3. Save System Integration

**File**: [local_save_manager.gd](../../local_save_manager.gd)

- **Timestamp updated** on every save (autosave every 30 seconds)
- **Overtime data persisted**: overtime_lvl, offline_cap_hours, last_played_timestamp
- **Cloud save compatible** (NakamaManager also updated with timestamp tracking)

---

### 4. Offline Earnings Processing

**File**: [level1/loading_screen.gd](../../level1/loading_screen.gd)

**New Function**: `_process_offline_earnings()`

**Behavior**:
- Initializes timestamp on first play
- Requires **minimum 60 seconds** offline before processing
- Checks for **auto-shovels** (no auto-shovels = no earnings)
- Calculates earnings with **50% efficiency penalty**
- Displays **welcome back notification** with earnings summary
- Shows **missed hours warning** if cap was exceeded

**Earnings Formula**:
```
capped_time = min(elapsed_time, offline_cap_seconds)
coal_earned = auto_shovel_lvl * coal_per_tick * (capped_time / freq) * 0.5
```

---

### 5. Overseer's Office Overtime Upgrade

**File**: [level1/overseers_office.gd](../../level1/overseers_office.gd)

**New Features**:
- **Overtime button** (to be added to scene in Godot editor)
- Dynamic button text: `"Overtime (8h → 12h) - 300 coins"`
- **Disabled** when insufficient coins or max level reached
- **Purchase logic** with validation and equipment tracking
- **Success notification** with upgrade name and flavor text

**Integration**:
- Calls `OfflineEarningsManager` functions
- Updates `Level1Vars` state
- Tracks equipment value for prestige system
- Logs purchases to DebugLogger

---

### 6. Equipment Tracking

**File**: [upgrade_types_config.gd](../../upgrade_types_config.gd)

- Added `"overtime"` to `EQUIPMENT_UPGRADES` array
- Enables prestige system integration (Goodwill calculation)

---

### 7. Test Suite (TDD)

**Files Created**:
- [tests/test_assertions.gd](../../tests/test_assertions.gd) - Assertion framework
- [tests/test_runner.gd](../../tests/test_runner.gd) - Headless test runner
- [tests/test_overtime_system.gd](../../tests/test_overtime_system.gd) - 6 unit tests

**Unit Tests**:
1. `test_overtime_cost_calculation()` - Verifies cost formula
2. `test_overtime_cap_progression()` - Verifies hour caps
3. `test_offline_earnings_formula()` - Tests earnings calculation
4. `test_offline_time_capping()` - Tests cap enforcement
5. `test_offline_summary_message()` - Tests message generation
6. `test_upgrade_info()` - Tests upgrade name/description retrieval

**To Run Tests**:
```bash
godot --headless --script res://tests/test_runner.gd
```

---

## 🎮 Features Implemented

### Player Experience

1. **Offline Earnings**
   - Auto-shovels generate coal while offline at 50% efficiency
   - Capped by overtime limit (default 8 hours)
   - Minimum 60 seconds offline required

2. **Overtime Upgrades**
   - Purchase in Overseer's Office with coins
   - 9 levels (8h → 36h cap)
   - Exponential cost scaling (300 → 3375 coins)
   - Persists through prestige

3. **Welcome Back Notifications**
   - Shows time elapsed and cap
   - Shows coal earned
   - Warns if missed hours (exceeded cap)
   - Encourages overtime upgrades

4. **Equipment Value Tracking**
   - Overtime purchases count toward prestige Goodwill
   - Integrated with existing prestige system

---

## 📋 Manual Testing Checklist

### To complete in Godot Editor:

1. **Add Overtime Button to Overseer's Office Scene**
   - [ ] Open `level1/overseers_office.tscn`
   - [ ] Add new Button node to `HBoxContainer/RightVBox`
   - [ ] Name it `OvertimeButton`
   - [ ] Set initial text: "Negotiate Overtime"
   - [ ] Position below other buttons
   - [ ] Test button hierarchy/ordering

2. **Test Offline Earnings Flow**
   - [ ] Start fresh game, verify no offline earnings (first play)
   - [ ] Buy auto-shovels
   - [ ] Save and close game
   - [ ] Wait 2+ minutes
   - [ ] Reopen game, verify earnings notification appears
   - [ ] Check coal was added correctly

3. **Test Overtime Purchases**
   - [ ] Start with 500+ coins
   - [ ] Buy overtime level 1 (300 coins)
   - [ ] Verify cap increases to 12 hours
   - [ ] Verify equipment_value increases
   - [ ] Test all 8 levels
   - [ ] Verify max level disables button

4. **Test Edge Cases**
   - [ ] Offline < 60 seconds (should skip)
   - [ ] Offline with 0 auto-shovels (should skip)
   - [ ] Offline > cap (should show missed hours warning)
   - [ ] Try to buy with insufficient coins (should fail)
   - [ ] Test prestige (overtime should persist)

5. **Test Save/Load**
   - [ ] Purchase overtime
   - [ ] Save game
   - [ ] Close and reopen
   - [ ] Verify overtime_lvl persisted
   - [ ] Verify offline_cap_hours persisted

---

## 🎯 Design Adherence

### Programming Principles (SOLID, DRY, KISS, YAGNI)

✅ **Single Responsibility**: Each component has one focus
- OfflineEarningsManager: Only handles offline earnings calculations
- LocalSaveManager: Only handles save/load
- Level1Vars: Only stores state

✅ **DRY**: No code duplication
- Shared cost/cap arrays in OfflineEarningsManager
- Reused existing save system infrastructure
- Centralized equipment tracking

✅ **KISS**: Simple, clear implementation
- Straightforward formula: `lvl * tick * (time/freq) * 0.5`
- Clear function names and parameters
- No over-engineering

✅ **YAGNI**: Only implemented what's needed
- No overtime efficiency upgrades (future enhancement)
- No complex UI (just one button)
- No unnecessary features

### Grimdark Theme

✅ **Oppressive atmosphere in flavor text**:
- "Standard shift - the overseer expects you back"
- "Sleep Deprivation - The overseer grows concerned"
- "Inhumane Hours - Even he thinks this is too much"
- "Breaking Point - The absolute maximum before collapse"

✅ **No false hope**:
- 50% efficiency penalty (unmanned work is less efficient)
- Exponential costs (getting harder)
- Hard cap (no infinite offline earnings)

---

## 📊 Implementation Statistics

- **Files Created**: 4 (OfflineEarningsManager, 3 test files)
- **Files Modified**: 6 (Level1Vars, LocalSaveManager, loading_screen, overseers_office, upgrade_types_config, project.godot)
- **Lines of Code Added**: ~450
- **Unit Tests Written**: 6
- **Automated Test Coverage**: Core calculations, cost formulas, cap enforcement

---

## 🚀 Next Steps

### Immediate (Required for Launch)

1. **Add Overtime Button to Scene** (5 minutes)
   - Open overseers_office.tscn in Godot
   - Add Button node as described above
   - Save scene

2. **Manual Testing** (30 minutes)
   - Follow manual testing checklist
   - Test all edge cases
   - Verify UI displays correctly

### Future Enhancements (Phase 3+)

1. **Overtime Efficiency Upgrade**
   - Reduce penalty from 50% → 40% → 30% → 20%
   - Very expensive (1000+ coins per level)
   - Late-game optimization

2. **Prestige Integration**
   - Goodwill slightly increases cap (+0.5h per point)
   - Max bonus: +5 hours at 10 Goodwill

3. **Crystal Commentary**
   - Wisdom 6+: "You push yourself too hard..."
   - Wisdom 8+: "The overseer exploits your dedication..."

---

## 🐛 Known Issues

**None** - Implementation follows plan exactly, all core features complete.

---

## 📝 Notes

- **Timestamp updates**: Every autosave (30 seconds) and on scene changes
- **Equipment tracking**: Overtime purchases count toward prestige Goodwill
- **Persistence**: Overtime upgrades survive prestige (intentional QoL feature)
- **Minimum offline time**: 60 seconds (prevents notification spam)
- **Test compatibility**: All tests designed for headless execution

---

**Implementation completed**: 2025-11-10
**Ready for**: Manual testing and scene UI integration
**Estimated remaining work**: 30-45 minutes (add button + test)
