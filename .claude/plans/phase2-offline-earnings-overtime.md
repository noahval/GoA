# Phase 2: Offline Earnings - Overtime System Implementation Plan

## Overview

This plan details the implementation of the offline earnings system centered around an "Overtime" upgrade purchasable in the Overseer's Office. The system will be developed using Test-Driven Development (TDD) with all tests compatible with headless execution for automated testing.

**Core Goal**: Allow players to earn coal while offline through auto-shovels, with earnings capped by an upgradable "Overtime" limit that progresses from 8 hours to 36 hours.

---

## Core Features

### 1. Overtime Upgrade System

**Location**: Overseer's Office scene (`overseers_office.tscn`)

**Theme**: Negotiating extended overtime work limits with the overseer

**Upgrade Tiers** (9 levels total):

| Level | Cap Hours | Cost (coins) | Upgrade Name | Thematic Description |
|-------|-----------|--------------|--------------|---------------------|
| 0 | 8h | - | Base Limit | "Standard shift - the overseer expects you back" |
| 1 | 12h | 300 | Standard Overtime | "The overseer allows a few extra hours" |
| 2 | 16h | 390 | Extended Shift | "Working late into the night" |
| 3 | 20h | 507 | Double Shift | "Pushing the limits of endurance" |
| 4 | 24h | 659 | Round-the-Clock | "A full day without rest" |
| 5 | 26h | 1000 | Marathon Shift | "Beyond what's reasonable" |
| 6 | 28h | 1500 | Sleep Deprivation | "The overseer grows concerned" |
| 7 | 30h | 2250 | Inhumane Hours | "Even he thinks this is too much" |
| 8 | 36h | 3375 | Breaking Point | "The absolute maximum before collapse" |

**Cost Formula**:
- Base costs adjusted per tier for balance
- General pattern follows: `base_cost * (1.3 ^ overtime_lvl)`
- Quick progression to 24h (levels 0-4), then steeper costs

**Mechanics**:
- Purchase button in Overseer's Office UI
- Each purchase increases offline cap by specified hours
- Costs increase exponentially
- Tracks as equipment purchase for prestige system

---

### 2. Offline Earnings Calculation

**Core Algorithm**:
```
elapsed_time = current_time - last_played_timestamp
capped_time = min(elapsed_time, offline_cap_seconds)
coal_earned = auto_shovel_lvl * coal_per_tick * (capped_time / auto_shovel_freq) * 0.5
```

**Key Features**:
- Tracks `last_played_timestamp` (Unix timestamp)
- Calculates elapsed time since last save
- Caps earnings at current overtime limit
- Applies 50% efficiency penalty (auto-shovels work slower unmanned)
- Only auto-shovels generate (manual clicks don't count)
- No offline earnings if auto_shovel_lvl = 0

**Display on Return**:
- Notification: "Welcome back! You were away for X hours (capped at Y hours). Your auto-shovels earned Z coal."
- If exceeded cap: "You missed N hours of potential earnings. Upgrade your overtime limit in the Overseer's Office!"

---

### 3. Overtime Efficiency Upgrade (Future Enhancement)

**Optional Late-Game Upgrade**:
- Reduces offline penalty from 50% → 40% → 30% → 20%
- Very expensive (1000+ coins per level)
- Purchased separately from cap upgrades
- Encourages long-term investment in idle mechanics

---

## TDD Test Plan (Headless Compatible)

All tests designed to run in `--headless` mode without GUI dependencies.

### Unit Tests (`tests/test_overtime_system.gd`)

#### 1. `test_overtime_cost_calculation()`
**Purpose**: Verify cost formula accuracy
```gdscript
# Test cases:
- Level 0→1: Assert cost == 300
- Level 1→2: Assert cost == 390
- Level 2→3: Assert cost == 507
- Level 3→4: Assert cost == 659
- Level 7→8: Assert cost == 3375
- Verify exponential scaling pattern
```

#### 2. `test_overtime_cap_progression()`
**Purpose**: Verify hours increase correctly per level
```gdscript
# Test cases:
- Level 0: Assert cap == 8 hours
- Level 1: Assert cap == 12 hours
- Level 4: Assert cap == 24 hours
- Level 8: Assert cap == 36 hours
- Test boundary: Invalid level returns 8 hours (default)
```

#### 3. `test_offline_time_calculation()`
**Purpose**: Verify elapsed time calculation with mocked system time
```gdscript
# Test cases:
- Mock Time.get_unix_time_from_system()
- Set last_played = 1000, current = 4600 (1 hour elapsed)
- Assert elapsed_seconds == 3600
- Test with various time differences
- Test cap enforcement (elapsed > cap returns cap)
```

#### 4. `test_offline_earnings_formula()`
**Purpose**: Verify coal calculation accuracy
```gdscript
# Test cases:
- auto_shovel_lvl=2, coal_per_tick=4, freq=3, elapsed=3600 (1 hour)
  Expected: 2 * 4 * (3600/3) * 0.5 = 2400 coal
- Test with 0 auto-shovels: Assert 0 coal
- Test with upgraded coal_per_tick and frequency
- Test 50% penalty applied correctly
- Test fractional seconds handled properly
```

#### 5. `test_overtime_purchase_transaction()`
**Purpose**: Verify purchase mechanics
```gdscript
# Test cases:
- coins=500, cost=300: Assert purchase succeeds
  - coins reduced to 200
  - overtime_lvl incremented
  - equipment_value increased by 300
- coins=200, cost=300: Assert purchase fails
  - coins unchanged
  - overtime_lvl unchanged
- Test max level reached (level 8): Assert purchase rejected
```

---

### Integration Tests (`tests/test_overtime_integration.gd`)

#### 6. `test_overtime_button_in_overseers_office()`
**Purpose**: Verify UI integration
```gdscript
# Test cases:
- Load overseers_office scene
- Assert "Negotiate Overtime" button exists
- coins=500, cost=300: Assert button enabled
- coins=100, cost=300: Assert button disabled
- overtime_lvl=8: Assert button shows "Max Level"
```

#### 7. `test_offline_earnings_on_game_load()`
**Purpose**: Verify earnings applied on game start
```gdscript
# Test cases:
- Setup: auto_shovel_lvl=3, coal=100, last_played = 1 hour ago
- Trigger game load sequence
- Assert coal increased by calculated amount
- Assert notification displayed
- Assert last_played_timestamp updated
```

#### 8. `test_offline_cap_exceeded_warning()`
**Purpose**: Verify warning for missed earnings
```gdscript
# Test cases:
- Setup: cap=8 hours, elapsed=12 hours
- Trigger game load
- Assert notification contains "missed 4 hours"
- Assert earnings capped at 8 hours worth
```

#### 9. `test_autosave_timestamp_tracking()`
**Purpose**: Verify timestamp updates
```gdscript
# Test cases:
- Trigger autosave (30s timer)
- Assert last_played_timestamp updated
- Load game, modify state, save again
- Assert timestamp reflects latest save time
```

---

### System Tests (`tests/test_offline_scenarios.gd`)

#### 10. `test_short_offline_period()`
**Purpose**: Test offline < cap
```gdscript
# Scenario:
- offline_cap = 8 hours
- elapsed = 2 hours
- auto_shovel_lvl = 2, coal_per_tick=4, freq=3
- Expected: Full earnings for 2 hours
- Assert no "missed hours" message
```

#### 11. `test_long_offline_period()`
**Purpose**: Test offline > cap
```gdscript
# Scenario:
- offline_cap = 8 hours
- elapsed = 12 hours
- auto_shovel_lvl = 2, coal_per_tick=4, freq=3
- Expected: Earnings capped at 8 hours
- Assert "missed 4 hours" message shown
```

#### 12. `test_no_auto_shovels()`
**Purpose**: Test early game (no auto-shovels)
```gdscript
# Scenario:
- auto_shovel_lvl = 0
- elapsed = 8 hours
- Expected: 0 coal earned
- Assert message: "No auto-shovels to generate offline earnings"
```

#### 13. `test_multiple_auto_shovel_types()`
**Purpose**: Test with various upgrade combinations
```gdscript
# Scenarios:
- Base: auto_shovel_lvl=3, coal_per_tick=4, freq=3
- Upgraded freq: auto_shovel_lvl=3, coal_per_tick=4, freq=2 (faster)
- Upgraded coal: auto_shovel_lvl=3, coal_per_tick=8, freq=3 (more per tick)
- Both upgraded: auto_shovel_lvl=3, coal_per_tick=8, freq=2
- Assert each scenario calculates correctly
```

---

## Implementation Steps

### Step 1: Data Layer (`level1/level_1_vars.gd`)

**Add Variables**:
```gdscript
# Offline earnings state
var overtime_lvl: int = 0
var offline_cap_hours: float = 8.0
var last_played_timestamp: int = 0

# Helper function
func get_offline_cap_seconds() -> int:
    return int(offline_cap_hours * 3600)
```

**Update `_ready()`**:
- Initialize `last_played_timestamp` to current time if 0

---

### Step 2: Offline Earnings Manager (`offline_earnings_manager.gd`)

**Create Singleton Autoload**:
```gdscript
extends Node

const OVERTIME_COSTS = [300, 390, 507, 659, 1000, 1500, 2250, 3375]
const OVERTIME_HOURS = [12, 16, 20, 24, 26, 28, 30, 36]
const OFFLINE_EFFICIENCY = 0.5  # 50% penalty

func get_overtime_cost(current_level: int) -> int:
    if current_level >= OVERTIME_COSTS.size():
        return -1  # Max level
    return OVERTIME_COSTS[current_level]

func get_cap_hours_for_level(level: int) -> float:
    if level == 0:
        return 8.0
    if level > OVERTIME_HOURS.size():
        return OVERTIME_HOURS[-1]
    return OVERTIME_HOURS[level - 1]

func calculate_offline_earnings(elapsed_seconds: int, cap_seconds: int) -> int:
    var capped_seconds = min(elapsed_seconds, cap_seconds)

    if Level1Vars.auto_shovel_lvl == 0:
        return 0

    var ticks = capped_seconds / Level1Vars.auto_shovel_freq
    var coal = Level1Vars.auto_shovel_lvl * Level1Vars.auto_shovel_coal_per_tick * ticks * OFFLINE_EFFICIENCY

    return int(coal)

func get_offline_summary(elapsed_seconds: int, cap_seconds: int, coal_earned: int) -> String:
    var elapsed_hours = elapsed_seconds / 3600.0
    var cap_hours = cap_seconds / 3600.0
    var missed_hours = max(0, elapsed_hours - cap_hours)

    var message = "Welcome back! You were away for %.1f hours" % elapsed_hours
    message += " (capped at %.0f hours).\n" % cap_hours
    message += "Your auto-shovels earned %d coal." % coal_earned

    if missed_hours > 0.1:
        message += "\n\nYou missed %.1f hours of potential earnings!" % missed_hours
        message += " Upgrade your overtime limit in the Overseer's Office."

    return message
```

**Register in `project.godot`**:
```
[autoload]
OfflineEarningsManager="*res://offline_earnings_manager.gd"
```

---

### Step 3: Timestamp Tracking (`save_manager.gd`)

**Update Save Function**:
```gdscript
func save_game():
    # Update timestamp before saving
    Level1Vars.last_played_timestamp = Time.get_unix_time_from_system()

    # ... existing save logic ...
```

**Add to Save Dictionary**:
```gdscript
var save_data = {
    # ... existing data ...
    "overtime_lvl": Level1Vars.overtime_lvl,
    "offline_cap_hours": Level1Vars.offline_cap_hours,
    "last_played_timestamp": Level1Vars.last_played_timestamp,
}
```

**Update Load Function**:
```gdscript
func load_game():
    # ... existing load logic ...

    Level1Vars.overtime_lvl = data.get("overtime_lvl", 0)
    Level1Vars.offline_cap_hours = data.get("offline_cap_hours", 8.0)
    Level1Vars.last_played_timestamp = data.get("last_played_timestamp", 0)
```

---

### Step 4: Game Load Integration (`level1/loading_screen.gd`)

**Add Offline Earnings Check**:
```gdscript
func _ready():
    # Check for offline earnings
    _process_offline_earnings()

    # ... existing loading logic ...

func _process_offline_earnings():
    if Level1Vars.last_played_timestamp == 0:
        Level1Vars.last_played_timestamp = Time.get_unix_time_from_system()
        return  # First time playing

    var current_time = Time.get_unix_time_from_system()
    var elapsed = current_time - Level1Vars.last_played_timestamp

    # Only process if away for at least 60 seconds
    if elapsed < 60:
        Level1Vars.last_played_timestamp = current_time
        return

    var cap_seconds = Level1Vars.get_offline_cap_seconds()
    var coal_earned = OfflineEarningsManager.calculate_offline_earnings(elapsed, cap_seconds)

    if coal_earned > 0:
        Level1Vars.coal += coal_earned
        var message = OfflineEarningsManager.get_offline_summary(elapsed, cap_seconds, coal_earned)
        Global.show_stat_notification(message)

    Level1Vars.last_played_timestamp = current_time
```

---

### Step 5: Overseer's Office UI (`level1/overseers_office.tscn`)

**Add UI Elements**:
- New button: "Negotiate Overtime"
- Position below existing buttons in right panel
- Connect to `_on_overtime_button_pressed()`

**Add Labels** (in popup):
- Current cap display
- Next level preview
- Cost display
- Thematic description

---

### Step 6: Overseer's Office Logic (`level1/overseers_office.gd`)

**Add Purchase Function**:
```gdscript
func _on_overtime_button_pressed():
    var cost = OfflineEarningsManager.get_overtime_cost(Level1Vars.overtime_lvl)

    if cost == -1:
        _show_overtime_popup("Max Overtime Reached", "You've negotiated the absolute maximum overtime the overseer will allow. Even he has limits.")
        return

    if Level1Vars.coins < cost:
        _show_overtime_popup("Insufficient Coins", "You need %d coins to upgrade your overtime limit." % cost)
        return

    # Purchase successful
    Level1Vars.coins -= cost
    Level1Vars.overtime_lvl += 1
    Level1Vars.offline_cap_hours = OfflineEarningsManager.get_cap_hours_for_level(Level1Vars.overtime_lvl)
    UpgradeTypesConfig.track_equipment_purchase("overtime", cost)
    DebugLogger.log_shop_purchase("Overtime", cost, Level1Vars.overtime_lvl)

    var new_cap = Level1Vars.offline_cap_hours
    var message = "Overtime Extended!\n\nYour offline earning cap is now %.0f hours." % new_cap
    _show_overtime_popup("Success", message)

    _update_ui()

func _show_overtime_popup(title: String, message: String):
    # Use existing popup infrastructure
    var popup = get_node("PopupContainer/GenericPopup")
    popup.get_node("Title").text = title
    popup.get_node("Message").text = message
    popup.popup_centered()

func _update_ui():
    var cost = OfflineEarningsManager.get_overtime_cost(Level1Vars.overtime_lvl)
    var overtime_button = get_node("RightPanel/OvertimeButton")

    if cost == -1:
        overtime_button.text = "Overtime (MAX)"
        overtime_button.disabled = true
    else:
        overtime_button.text = "Overtime (%.0fh → %.0fh) - %d coins" % [
            Level1Vars.offline_cap_hours,
            OfflineEarningsManager.get_cap_hours_for_level(Level1Vars.overtime_lvl + 1),
            cost
        ]
        overtime_button.disabled = (Level1Vars.coins < cost)
```

---

### Step 7: Equipment Tracking (`upgrade_types_config.gd`)

**Update Equipment List**:
```gdscript
const EQUIPMENT_UPGRADES = [
    "shovel",
    "plow",
    "auto_shovel",
    "coal_per_tick",
    "frequency",
    "overtime",  # Add this
]
```

---

### Step 8: TDD Test Suite Implementation

**Create Test Runner** (`tests/test_runner.gd`):
```gdscript
extends SceneTree

var tests_passed = 0
var tests_failed = 0

func _initialize():
    # Discover and run all tests
    run_test_suite("res://tests/test_overtime_system.gd")
    run_test_suite("res://tests/test_overtime_integration.gd")
    run_test_suite("res://tests/test_offline_scenarios.gd")

    # Print summary
    print("\n" + "=".repeat(50))
    print("Test Summary: %d passed, %d failed" % [tests_passed, tests_failed])
    print("=".repeat(50))

    # Exit with appropriate code
    quit(0 if tests_failed == 0 else 1)

func run_test_suite(path: String):
    var test_instance = load(path).new()
    var methods = test_instance.get_method_list()

    for method in methods:
        if method.name.begins_with("test_"):
            run_test(test_instance, method.name)

func run_test(instance, method_name: String):
    print("Running: %s..." % method_name)

    try:
        instance.call(method_name)
        tests_passed += 1
        print("  ✓ PASSED")
    except Exception as e:
        tests_failed += 1
        print("  ✗ FAILED: %s" % e.message)
```

**Run Tests**:
```bash
godot --headless --script res://tests/test_runner.gd
```

---

## Technical Architecture

### New Files to Create

1. **`offline_earnings_manager.gd`**
   - Singleton autoload
   - Cost/cap calculations
   - Offline earnings formula
   - Summary message generation

2. **`tests/test_runner.gd`**
   - Headless test executor
   - Test discovery
   - Result reporting

3. **`tests/test_assertions.gd`**
   - Helper functions for assertions
   - `assert_equal()`, `assert_true()`, `assert_approx()`

4. **`tests/test_overtime_system.gd`**
   - Unit tests (5 tests)

5. **`tests/test_overtime_integration.gd`**
   - Integration tests (4 tests)

6. **`tests/test_offline_scenarios.gd`**
   - System tests (4 tests)

7. **`tests/mock_time.gd`**
   - Time mocking utility for tests

---

### Files to Modify

1. **`level1/level_1_vars.gd`**
   - Add overtime state variables
   - Add `get_offline_cap_seconds()` helper

2. **`level1/overseers_office.tscn`**
   - Add "Negotiate Overtime" button
   - Add popup UI elements

3. **`level1/overseers_office.gd`**
   - Add `_on_overtime_button_pressed()`
   - Add `_show_overtime_popup()`
   - Update `_update_ui()` or equivalent

4. **`level1/loading_screen.gd`**
   - Add `_process_offline_earnings()`
   - Call on game load

5. **`save_manager.gd`**
   - Update timestamp on save
   - Add overtime data to save/load

6. **`upgrade_types_config.gd`**
   - Add "overtime" to EQUIPMENT_UPGRADES

7. **`project.godot`**
   - Register OfflineEarningsManager autoload

---

## Headless Testing Strategy

### Test Runner Setup

**Command to Run All Tests**:
```bash
godot --headless --script res://tests/test_runner.gd
```

**Features**:
- No GUI dependencies
- Runs in CI/CD environments
- Exit code 0 (pass) or 1 (fail)
- Automatic test discovery
- Clear pass/fail reporting

---

### Mocking System Time

**Mock Time Class** (`tests/mock_time.gd`):
```gdscript
class_name MockTime

var fake_time: int = 1704067200  # Jan 1, 2024

func get_unix_time() -> int:
    return fake_time

func advance_hours(hours: int):
    fake_time += hours * 3600

func advance_seconds(seconds: int):
    fake_time += seconds
```

**Usage in Tests**:
```gdscript
var mock_time = MockTime.new()
mock_time.fake_time = 1000

# Simulate 2 hours passing
mock_time.advance_hours(2)

# Use in calculations
var elapsed = mock_time.get_unix_time() - 1000
assert_equal(elapsed, 7200, "Should be 2 hours")
```

---

### Assertions Framework

**`tests/test_assertions.gd`**:
```gdscript
extends Node

static func assert_equal(actual, expected, message: String = ""):
    if actual != expected:
        var error = "Assertion failed: Expected %s but got %s" % [expected, actual]
        if message:
            error += " (%s)" % message
        push_error(error)
        assert(false, error)

static func assert_true(condition: bool, message: String = ""):
    if not condition:
        var error = "Assertion failed: Expected true but got false"
        if message:
            error += " (%s)" % message
        push_error(error)
        assert(false, error)

static func assert_approx(actual: float, expected: float, epsilon: float = 0.01, message: String = ""):
    if abs(actual - expected) > epsilon:
        var error = "Assertion failed: Expected ~%f but got %f (epsilon: %f)" % [expected, actual, epsilon]
        if message:
            error += " (%s)" % message
        push_error(error)
        assert(false, error)
```

---

### CI Integration

**GitHub Actions Example** (`.github/workflows/test.yml`):
```yaml
name: Run Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v1
        with:
          version: 4.5
      - name: Run Tests
        run: godot --headless --script res://tests/test_runner.gd
```

---

## Success Criteria

### Functional Requirements
- ✅ All 13 TDD tests pass in headless mode
- ✅ Overtime upgrade purchasable in Overseer's Office with proper UI
- ✅ Offline earnings calculated correctly on game load
- ✅ Notifications display offline earnings summary
- ✅ "Missed hours" warning shown when cap exceeded
- ✅ Cost scaling follows exponential curve (300 → 3375 coins)
- ✅ Equipment value tracking works for prestige system
- ✅ Save/load preserves overtime level and cap

### UI/UX Requirements
- ✅ Button shows current cap → next cap progression
- ✅ Button disabled when max level (8) or insufficient funds
- ✅ Thematic flavor text for each overtime tier
- ✅ Popup explains overtime system on first purchase
- ✅ Notification appears in center screen on game load

### Technical Requirements
- ✅ No offline earnings if auto_shovel_lvl = 0
- ✅ 50% efficiency penalty applied correctly
- ✅ Timestamp updated on every autosave (30s)
- ✅ Minimum 60 seconds offline before processing earnings
- ✅ Fractional coal earnings handled (round down)

### Testing Requirements
- ✅ Tests run without GUI dependencies
- ✅ Tests can run in CI environment
- ✅ All edge cases covered (no auto-shovels, exceeds cap, first play)
- ✅ Mocking system time works reliably
- ✅ Test execution time < 30 seconds

---

## Estimated Effort

| Task | Time Estimate |
|------|---------------|
| **TDD Test Suite** | |
| - Test runner & assertions framework | 1 hour |
| - Unit tests (5 tests) | 1 hour |
| - Integration tests (4 tests) | 1 hour |
| - System tests (4 tests) | 1 hour |
| **Core Implementation** | |
| - Data layer (Level1Vars) | 0.5 hours |
| - OfflineEarningsManager singleton | 1.5 hours |
| - Timestamp tracking (SaveManager) | 0.5 hours |
| - Game load integration | 1 hour |
| - Equipment tracking update | 0.5 hours |
| **UI Integration** | |
| - Overseer's Office UI elements | 1 hour |
| - Purchase logic & popups | 1 hour |
| - Notification system integration | 0.5 hours |
| **Testing & Polish** | |
| - Run TDD suite, fix bugs | 1.5 hours |
| - Balance tuning (costs/caps) | 0.5 hours |
| - Thematic flavor text writing | 0.5 hours |
| - Documentation updates | 0.5 hours |

**Total: 14-16 hours**

---

## Implementation Order (TDD Approach)

### Phase 1: Foundation (4 hours)
1. Create test framework (test_runner, assertions, mock_time)
2. Write unit tests (fail initially)
3. Implement OfflineEarningsManager to pass tests
4. Add data layer (Level1Vars)

### Phase 2: Integration (5 hours)
5. Write integration tests
6. Implement timestamp tracking in SaveManager
7. Implement game load offline earnings check
8. Add equipment tracking

### Phase 3: UI (3 hours)
9. Create Overseer's Office UI elements
10. Implement purchase logic
11. Add notifications

### Phase 4: Polish (3 hours)
12. Run full test suite, fix bugs
13. Balance tuning
14. Flavor text & documentation

---

## Future Enhancements (Post-Phase 2)

### Overtime Efficiency Upgrade
- Reduces 50% penalty → 40% → 30% → 20%
- Cost: 1000, 2000, 4000, 8000 coins
- Late-game optimization for idle players

### Overtime Milestones
- "Workaholic" - Reach 24h overtime
- "Insomniac" - Reach 30h overtime
- "Breaking the System" - Reach 36h overtime

### Crystal Commentary
- Wisdom 6+: "You push yourself too hard, prisoner. Even I need rest."
- Wisdom 8+: "The overseer exploits your dedication. But perhaps you exploit his trust?"

### Prestige Bonus
- Goodwill slightly increases offline cap (0.5 hours per Goodwill point)
- Max bonus: +5 hours at 10 Goodwill

---

## Notes & Considerations

### Design Decisions

**Why 8 hours base?**
- Matches typical sleep duration
- Reasonable for overnight idle
- Quick progression to 24h (4 upgrades) feels good

**Why 50% penalty?**
- Makes active play more valuable
- Incentivizes returning to game
- Balances idle vs. active strategies

**Why Overseer's Office?**
- Thematically appropriate (negotiating work hours)
- Already has break timer system
- Not cluttering Shop UI
- Fits narrative (overseer controls your time)

**Why exponential costs?**
- Matches other upgrade systems
- Quick early progression
- Steeper late-game progression
- Feels fair and balanced

### Edge Cases Handled

1. **First time player** (last_played = 0): No offline earnings, set timestamp
2. **No auto-shovels**: Display message "Need auto-shovels for offline earnings"
3. **Exceeded cap**: Show "missed hours" warning
4. **Less than 60s offline**: Skip processing (avoid spam)
5. **Max overtime level**: Disable button, show "MAX" state
6. **Save/load mid-session**: Timestamp updates on each autosave

### Potential Issues & Solutions

**Issue**: Player manipulates system clock
**Solution**: Accept it (single-player game, not competitive)

**Issue**: Timestamp not updating if game crashes
**Solution**: Autosave every 30s captures most sessions

**Issue**: Very long offline periods (months)
**Solution**: Capped, so max earnings is 36h worth

**Issue**: Fractional coal amounts
**Solution**: Use `int(coal)` to round down, consistent with game

---

## Testing Checklist

Before marking Phase 2 complete:

### Automated Tests
- [ ] All 13 TDD tests pass in headless mode
- [ ] Tests run in < 30 seconds
- [ ] Tests can run in CI environment
- [ ] No false positives/negatives

### Manual Tests
- [ ] Purchase overtime from level 0 → 8
- [ ] Close game for 30 minutes, reopen
- [ ] Close game for 10 hours (exceeds 8h cap), reopen
- [ ] Try to purchase with insufficient coins
- [ ] Try to purchase at max level
- [ ] Verify save/load preserves state
- [ ] Test with 0 auto-shovels
- [ ] Test with various auto-shovel configurations

### Integration Tests
- [ ] Prestige resets don't break overtime
- [ ] Goodwill calculation includes overtime purchases
- [ ] Debug logger captures overtime purchases
- [ ] Notifications display correctly on various screen sizes

---

## Conclusion

This plan provides a comprehensive roadmap for implementing Phase 2: Offline Earnings with the Overtime upgrade system. By following TDD principles and ensuring all tests are headless-compatible, we can maintain high code quality and enable automated testing throughout development.

The Overtime system fits thematically into the Overseer's Office, provides meaningful idle progression, and respects the game's exponential cost scaling patterns. The 50% efficiency penalty balances idle vs. active play, while the 8-36 hour cap progression offers both quick early gains and long-term goals.

**Next Steps**:
1. Create test framework
2. Write failing tests
3. Implement features to pass tests
4. Integrate UI
5. Polish and balance

Estimated completion: **14-16 hours** of focused development.
