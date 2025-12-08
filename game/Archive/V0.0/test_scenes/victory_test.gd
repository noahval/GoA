extends Node

# Autonomous test for victory condition system

func _ready():
	DebugLogger.info("=== Starting Victory Condition Test ===", "TEST")

	# Test 1: No conditions met initially
	DebugLogger.info("Test 1: Checking initial state (should fail)...", "TEST")
	var result = Global.check_victory_conditions()
	assert(result == false, "Victory conditions should not be met initially")

	# Test 2: Set partial conditions
	DebugLogger.info("Test 2: Setting partial conditions (should still fail)...", "TEST")
	Level1Vars.stolen_coal = 2
	Level1Vars.stolen_writs = 1
	Level1Vars.mechanisms = 0
	result = Global.check_victory_conditions()
	assert(result == false, "Victory conditions should not be met with partial completion")

	# Test 3: Meet all conditions
	DebugLogger.info("Test 3: Meeting all conditions (should pass)...", "TEST")
	Level1Vars.stolen_coal = 3
	Level1Vars.stolen_writs = 3
	Level1Vars.mechanisms = 3
	result = Global.check_victory_conditions()
	assert(result == true, "Victory conditions should be met")

	# Test 4: Exceed conditions (should still pass)
	DebugLogger.info("Test 4: Exceeding conditions (should still pass)...", "TEST")
	Level1Vars.stolen_coal = 5
	Level1Vars.stolen_writs = 4
	Level1Vars.mechanisms = 6
	result = Global.check_victory_conditions()
	assert(result == true, "Victory conditions should still be met when exceeded")

	DebugLogger.info("=== Victory Condition Test Complete - All Tests Passed ===", "TEST")

	# Wait 2 seconds before quitting to ensure logs are flushed
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()
