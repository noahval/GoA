extends Node
## test_overtime_system.gd
## Unit tests for OfflineEarningsManager
## Tests: cost calculation, cap progression, offline time calc, earnings formula, purchase logic

var manager: Node  # OfflineEarningsManager singleton

func setup():
	# Load the OfflineEarningsManager script
	manager = load("res://offline_earnings_manager.gd").new()

func teardown():
	if manager:
		manager.free()

## Test 1: Verify overtime cost calculation
func test_overtime_cost_calculation():
	# Test progression through all levels
	TestAssertions.assert_equal(manager.get_overtime_cost(0), 300, "Level 0→1 cost")
	TestAssertions.assert_equal(manager.get_overtime_cost(1), 390, "Level 1→2 cost")
	TestAssertions.assert_equal(manager.get_overtime_cost(2), 507, "Level 2→3 cost")
	TestAssertions.assert_equal(manager.get_overtime_cost(3), 659, "Level 3→4 cost")
	TestAssertions.assert_equal(manager.get_overtime_cost(4), 1000, "Level 4→5 cost")
	TestAssertions.assert_equal(manager.get_overtime_cost(5), 1500, "Level 5→6 cost")
	TestAssertions.assert_equal(manager.get_overtime_cost(6), 2250, "Level 6→7 cost")
	TestAssertions.assert_equal(manager.get_overtime_cost(7), 3375, "Level 7→8 cost")

	# Test max level
	TestAssertions.assert_equal(manager.get_overtime_cost(8), -1, "Max level returns -1")
	TestAssertions.assert_equal(manager.get_overtime_cost(99), -1, "Beyond max returns -1")

## Test 2: Verify overtime cap hour progression
func test_overtime_cap_progression():
	# Test all levels
	TestAssertions.assert_equal(manager.get_cap_hours_for_level(0), 8.0, "Level 0 = 8 hours")
	TestAssertions.assert_equal(manager.get_cap_hours_for_level(1), 12.0, "Level 1 = 12 hours")
	TestAssertions.assert_equal(manager.get_cap_hours_for_level(2), 16.0, "Level 2 = 16 hours")
	TestAssertions.assert_equal(manager.get_cap_hours_for_level(3), 20.0, "Level 3 = 20 hours")
	TestAssertions.assert_equal(manager.get_cap_hours_for_level(4), 24.0, "Level 4 = 24 hours")
	TestAssertions.assert_equal(manager.get_cap_hours_for_level(5), 26.0, "Level 5 = 26 hours")
	TestAssertions.assert_equal(manager.get_cap_hours_for_level(6), 28.0, "Level 6 = 28 hours")
	TestAssertions.assert_equal(manager.get_cap_hours_for_level(7), 30.0, "Level 7 = 30 hours")
	TestAssertions.assert_equal(manager.get_cap_hours_for_level(8), 36.0, "Level 8 = 36 hours")

	# Test beyond max returns max value
	TestAssertions.assert_equal(manager.get_cap_hours_for_level(99), 36.0, "Beyond max returns 36 hours")

## Test 3: Verify offline earnings formula
func test_offline_earnings_formula():
	# Test case 1: Basic calculation
	# auto_shovel_lvl=2, coal_per_tick=4, freq=3, elapsed=3600 (1 hour)
	# Expected: 2 * 4 * (3600/3) * 0.5 = 4800 coal
	var result1 = manager.calculate_offline_earnings(3600, 3600, 2, 4.0, 3.0)
	TestAssertions.assert_equal(result1, 4800, "1 hour with 2 auto-shovels")

	# Test case 2: No auto-shovels = no earnings
	var result2 = manager.calculate_offline_earnings(3600, 3600, 0, 4.0, 3.0)
	TestAssertions.assert_equal(result2, 0, "No auto-shovels = 0 coal")

	# Test case 3: Upgraded coal per tick
	# auto_shovel_lvl=3, coal_per_tick=8, freq=3, elapsed=7200 (2 hours)
	# Expected: 3 * 8 * (7200/3) * 0.5 = 28800 coal
	var result3 = manager.calculate_offline_earnings(7200, 7200, 3, 8.0, 3.0)
	TestAssertions.assert_equal(result3, 28800, "2 hours with upgraded coal_per_tick")  # This one is already correct!

	# Test case 4: Upgraded frequency (faster shoveling)
	# auto_shovel_lvl=2, coal_per_tick=4, freq=2 (faster), elapsed=3600 (1 hour)
	# Expected: 2 * 4 * (3600/2) * 0.5 = 7200 coal
	var result4 = manager.calculate_offline_earnings(3600, 3600, 2, 4.0, 2.0)
	TestAssertions.assert_equal(result4, 7200, "1 hour with upgraded frequency")

	# Test case 5: Test 50% efficiency penalty is applied
	# If efficiency was 100%, result would be 9600 instead of 4800
	var result5 = manager.calculate_offline_earnings(3600, 3600, 2, 4.0, 3.0)
	TestAssertions.assert_equal(result5, 4800, "Verify 50% efficiency penalty")

## Test 4: Verify capping logic (earnings capped when elapsed > cap)
func test_offline_time_capping():
	# Test case 1: Elapsed time less than cap
	# 1 hour elapsed, 8 hour cap -> should get full 1 hour earnings
	var result1 = manager.calculate_offline_earnings(3600, 28800, 2, 4.0, 3.0)
	TestAssertions.assert_equal(result1, 4800, "Elapsed < cap: full earnings")

	# Test case 2: Elapsed time equals cap
	# 8 hour elapsed, 8 hour cap -> should get full 8 hour earnings (8x the 1 hour amount)
	var result2 = manager.calculate_offline_earnings(28800, 28800, 2, 4.0, 3.0)
	TestAssertions.assert_equal(result2, 38400, "Elapsed = cap: full earnings")

	# Test case 3: Elapsed time greater than cap
	# 12 hour elapsed, 8 hour cap -> should get only 8 hour earnings
	var result3 = manager.calculate_offline_earnings(43200, 28800, 2, 4.0, 3.0)
	TestAssertions.assert_equal(result3, 38400, "Elapsed > cap: capped earnings")

## Test 5: Verify summary message generation
func test_offline_summary_message():
	# Test case 1: No missed hours (1h elapsed, 8h cap)
	var msg1 = manager.get_offline_summary(3600, 28800, 4800)
	TestAssertions.assert_true(msg1.contains("1.0 hours"), "Should show elapsed time")
	TestAssertions.assert_true(msg1.contains("capped at 8 hours"), "Should show cap")
	TestAssertions.assert_true(msg1.contains("4800 coal"), "Should show coal earned")
	TestAssertions.assert_false(msg1.contains("missed"), "Should NOT show missed hours")

	# Test case 2: Missed hours (12h elapsed, 8h cap)
	var msg2 = manager.get_offline_summary(43200, 28800, 38400)
	TestAssertions.assert_true(msg2.contains("12.0 hours"), "Should show elapsed time")
	TestAssertions.assert_true(msg2.contains("capped at 8 hours"), "Should show cap")
	TestAssertions.assert_true(msg2.contains("38400 coal"), "Should show coal earned")
	TestAssertions.assert_true(msg2.contains("missed"), "Should show missed hours warning")
	TestAssertions.assert_true(msg2.contains("4.0 hours"), "Should show 4 hours missed")

## Test 6: Verify upgrade info retrieval
func test_upgrade_info():
	var info1 = manager.get_upgrade_info(1)
	TestAssertions.assert_equal(info1.name, "Standard Overtime", "Level 1 name")
	TestAssertions.assert_true(info1.desc.length() > 0, "Level 1 has description")

	var info8 = manager.get_upgrade_info(8)
	TestAssertions.assert_equal(info8.name, "Breaking Point", "Level 8 name")

	# Test invalid level
	var info_invalid = manager.get_upgrade_info(0)
	TestAssertions.assert_equal(info_invalid.name, "Unknown", "Invalid level returns Unknown")
