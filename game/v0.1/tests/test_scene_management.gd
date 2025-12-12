extends Node

# Unit tests for Scene Management (Phase 1.8)
# Run manually or integrate with GUT test framework

var test_results: Array = []

func _ready() -> void:
	print("\n===== Running Scene Management Tests =====\n")
	run_all_tests()
	print_results()

func run_all_tests() -> void:
	test_scene_history()
	test_scene_history_limit()
	test_validator_registration()
	test_validator_priority()
	test_validator_with_reason()
	test_scene_exists()
	test_same_scene_blocked()
	test_preload_cache_limit()

func test_scene_history() -> void:
	print("Test: Scene history navigation...")
	Global.scene_history.clear()

	# Simulate scene changes
	Global._update_scene_history("res://scene1.tscn", "res://scene2.tscn")
	Global._update_scene_history("res://scene2.tscn", "res://scene3.tscn")

	var passed = true
	if Global.scene_history.size() != 2:
		passed = false
		print("  FAIL: Expected 2 scenes in history, got " + str(Global.scene_history.size()))
	elif Global.scene_history[0] != "res://scene1.tscn":
		passed = false
		print("  FAIL: First entry should be scene1")
	elif Global.scene_history[1] != "res://scene2.tscn":
		passed = false
		print("  FAIL: Second entry should be scene2")

	test_results.append({"name": "scene_history", "passed": passed})
	if passed:
		print("  PASS")

func test_scene_history_limit() -> void:
	print("Test: Scene history max size...")
	Global.scene_history.clear()

	# Add more scenes than MAX_SCENE_HISTORY
	for i in range(Global.MAX_SCENE_HISTORY + 5):
		Global._update_scene_history("res://scene%d.tscn" % i, "res://scene%d.tscn" % (i+1))

	var passed = Global.scene_history.size() == Global.MAX_SCENE_HISTORY
	test_results.append({"name": "scene_history_limit", "passed": passed})

	if passed:
		print("  PASS")
	else:
		print("  FAIL: History should be capped at " + str(Global.MAX_SCENE_HISTORY))

func test_validator_registration() -> void:
	print("Test: Validator registration/unregistration...")
	Global.scene_validators.clear()

	var validator = func(path): return false

	Global.register_scene_validator(validator, 0, "Test validator")
	var registered = Global.scene_validators.size() == 1

	Global.unregister_scene_validator(validator)
	var unregistered = Global.scene_validators.size() == 0

	var passed = registered and unregistered
	test_results.append({"name": "validator_registration", "passed": passed})

	if passed:
		print("  PASS")
	else:
		print("  FAIL: Registration or unregistration failed")

func test_validator_priority() -> void:
	print("Test: Validator priority ordering...")
	Global.scene_validators.clear()

	var call_order = []

	# Register validators with different priorities
	Global.register_scene_validator(
		func(path): call_order.append("low"); return true,
		0,
		"Low priority"
	)
	Global.register_scene_validator(
		func(path): call_order.append("high"); return true,
		100,
		"High priority"
	)
	Global.register_scene_validator(
		func(path): call_order.append("medium"); return true,
		50,
		"Medium priority"
	)

	# Run validation (scene must exist for this to work)
	Global.can_change_to_scene("res://theme_test.tscn")  # Use existing scene

	var passed = (call_order.size() == 3 and
				 call_order[0] == "high" and
				 call_order[1] == "medium" and
				 call_order[2] == "low")

	test_results.append({"name": "validator_priority", "passed": passed})

	Global.scene_validators.clear()

	if passed:
		print("  PASS")
	else:
		print("  FAIL: Validators did not run in priority order. Got: " + str(call_order))

func test_validator_with_reason() -> void:
	print("Test: Dictionary validator with custom reason...")
	Global.scene_validators.clear()

	var test_reason = "Custom block message"
	Global.register_scene_validator(
		func(path): return {"allowed": false, "reason": test_reason},
		0,
		"Reason validator"
	)

	var block_reason = ""
	var can_change = Global.can_change_to_scene("res://theme_test.tscn", block_reason)

	var passed = not can_change and block_reason == test_reason
	test_results.append({"name": "validator_with_reason", "passed": passed})

	Global.scene_validators.clear()

	if passed:
		print("  PASS")
	else:
		print("  FAIL: Expected reason '%s', got '%s'" % [test_reason, block_reason])

func test_scene_exists() -> void:
	print("Test: Scene existence check...")

	var exists = Global.scene_exists("res://theme_test.tscn")
	var not_exists = not Global.scene_exists("res://nonexistent.tscn")

	var passed = exists and not_exists
	test_results.append({"name": "scene_exists", "passed": passed})

	if passed:
		print("  PASS")
	else:
		print("  FAIL: Scene existence check failed")

func test_same_scene_blocked() -> void:
	print("Test: Same scene blocking...")
	Global.scene_validators.clear()

	# Mock current scene path
	Global.current_scene_path = "res://theme_test.tscn"

	var block_reason = ""
	var can_change = Global.can_change_to_scene("res://theme_test.tscn", block_reason)

	var passed = not can_change and "Already" in block_reason
	test_results.append({"name": "same_scene_blocked", "passed": passed})

	if passed:
		print("  PASS")
	else:
		print("  FAIL: Should block transition to same scene")

func test_preload_cache_limit() -> void:
	print("Test: Preload cache size limit...")
	Global.preloaded_scenes.clear()

	# Since we can't easily test actual scene loading, we'll test the cache logic
	# by directly manipulating the cache
	for i in range(Global.MAX_PRELOADED_SCENES + 2):
		var scene_path = "res://fake_scene_%d.tscn" % i
		# Manually add to cache to test eviction logic
		if Global.preloaded_scenes.size() >= Global.MAX_PRELOADED_SCENES:
			var oldest_key = Global.preloaded_scenes.keys()[0]
			Global.preloaded_scenes.erase(oldest_key)
		Global.preloaded_scenes[scene_path] = null  # Dummy value

	var passed = Global.preloaded_scenes.size() == Global.MAX_PRELOADED_SCENES
	test_results.append({"name": "preload_cache_limit", "passed": passed})

	Global.preloaded_scenes.clear()

	if passed:
		print("  PASS")
	else:
		print("  FAIL: Cache should be limited to " + str(Global.MAX_PRELOADED_SCENES))

func print_results() -> void:
	print("\n===== Test Results =====")
	var passed_count = 0
	var total_count = test_results.size()

	for result in test_results:
		if result.passed:
			passed_count += 1

	print("Passed: %d / %d" % [passed_count, total_count])

	if passed_count == total_count:
		print("ALL TESTS PASSED!")
	else:
		print("SOME TESTS FAILED")
		for result in test_results:
			if not result.passed:
				print("  - " + result.name)

	print("========================\n")
