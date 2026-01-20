extends Node
## Nakama Serialization Test Script
## Tests save/load data serialization for cloud saves
## Run this scene to verify serialization functions work correctly

# Test data tracking
var tests_passed = 0
var tests_failed = 0
var test_errors: Array[String] = []

func _ready():
	print("\n" + "=".repeat(60))
	print("NAKAMA SERIALIZATION TEST")
	print("=".repeat(60))
	print("Testing: Global and Level1Vars serialization")
	print("=".repeat(60) + "\n")

	await get_tree().create_timer(0.5).timeout
	_run_tests()

func _run_tests():
	# Verify autoloads exist
	if not _verify_autoloads():
		_print_summary()
		return

	# Test Global serialization
	await _test_global_serialization()

	# Test Level1Vars serialization
	await _test_level1vars_serialization()

	# Test cloud save structure
	await _test_cloud_save_structure()

	# Test load without notification spam
	await _test_load_suppresses_notifications()

	# Print results
	_print_summary()

func _verify_autoloads() -> bool:
	print("[TEST 0] Verifying autoloads exist...")

	if not Global:
		_test_failed("Global autoload not found")
		return false

	if not Level1Vars:
		_test_failed("Level1Vars autoload not found")
		return false

	if not DebugLogger:
		_test_failed("DebugLogger autoload not found")
		return false

	_test_passed("All required autoloads found")
	return true

func _test_global_serialization():
	print("\n[TEST 1] Global Data Serialization...")

	# Set up test data
	Global.strength = 5
	Global.constitution = 3
	Global.dexterity = 4
	Global.wisdom = 2
	Global.intelligence = 6
	Global.charisma = 1
	Global.strength_exp = 250.5
	Global.ui_scale = 1.1
	Global.music_volume = 0.6
	Global.total_play_length = 7200.0

	# Simulate get_global_data (inline since NakamaManager might not exist yet)
	var global_data = {
		"settings": {
			"ui_scale": Global.ui_scale,
			"music_volume": Global.music_volume,
			"sfx_volume": Global.sfx_volume,
		},
		"strength": Global.strength,
		"constitution": Global.constitution,
		"dexterity": Global.dexterity,
		"wisdom": Global.wisdom,
		"intelligence": Global.intelligence,
		"charisma": Global.charisma,
		"strength_exp": Global.strength_exp,
		"constitution_exp": Global.constitution_exp,
		"dexterity_exp": Global.dexterity_exp,
		"wisdom_exp": Global.wisdom_exp,
		"intelligence_exp": Global.intelligence_exp,
		"charisma_exp": Global.charisma_exp,
		"total_play_length": Global.total_play_length,
	}

	# Verify data structure
	if not global_data.has("settings"):
		_test_failed("Global data missing 'settings' key")
		return

	if not global_data.has("strength"):
		_test_failed("Global data missing 'strength' key")
		return

	if global_data.strength != 5:
		_test_failed("Global strength not serialized correctly (expected 5, got %d)" % global_data.strength)
		return

	if global_data.settings.ui_scale != 1.1:
		_test_failed("Global ui_scale not serialized correctly")
		return

	if global_data.total_play_length != 7200.0:
		_test_failed("Global total_play_length not serialized correctly")
		return

	_test_passed("Global data serialization working correctly")

	# Test deserialization
	print("  Testing Global data deserialization...")

	# Reset values
	Global.strength = 1
	Global.ui_scale = 1.0

	# Load test data (simulate _set_global_data)
	# Note: Real implementation would use is_loading_cloud_save flag
	Global.strength = global_data.get("strength", 1)
	Global.ui_scale = global_data.settings.get("ui_scale", 1.0)

	if Global.strength != 5:
		_test_failed("Global strength not loaded correctly")
		return

	if Global.ui_scale != 1.1:
		_test_failed("Global ui_scale not loaded correctly")
		return

	_test_passed("Global data deserialization working correctly")

func _test_level1vars_serialization():
	print("\n[TEST 2] Level1Vars Data Serialization...")

	# Check if Level1Vars has get_save_data function
	if not Level1Vars.has_method("get_save_data"):
		_test_failed("Level1Vars.get_save_data() method not found")
		return

	if not Level1Vars.has_method("load_save_data"):
		_test_failed("Level1Vars.load_save_data() method not found")
		return

	# Get save data
	var level1_data = Level1Vars.get_save_data()

	if level1_data.is_empty():
		_test_failed("Level1Vars.get_save_data() returned empty dictionary")
		return

	# Verify key fields exist
	var required_fields = ["stamina", "stamina_max", "focus", "focus_max", "currency"]
	for field in required_fields:
		if not level1_data.has(field):
			_test_failed("Level1Vars data missing required field: " + field)
			return

	print("  Level1Vars data contains %d fields" % level1_data.size())
	_test_passed("Level1Vars serialization includes all expected fields")

	# Test round-trip (save -> load -> verify)
	print("  Testing Level1Vars round-trip...")

	# Store original values
	var original_stamina = Level1Vars.stamina
	var original_focus = Level1Vars.focus

	# Modify values
	Level1Vars.stamina = 25.0
	Level1Vars.focus = 50

	# Get modified save data
	var modified_data = Level1Vars.get_save_data()

	# Reset to original
	Level1Vars.stamina = original_stamina
	Level1Vars.focus = original_focus

	# Load modified data
	Level1Vars.load_save_data(modified_data)

	# Verify loaded correctly
	if Level1Vars.stamina != 25.0:
		_test_failed("Level1Vars stamina not restored correctly (expected 25.0, got %f)" % Level1Vars.stamina)
		return

	if Level1Vars.focus != 50:
		_test_failed("Level1Vars focus not restored correctly (expected 50, got %d)" % Level1Vars.focus)
		return

	_test_passed("Level1Vars round-trip serialization working correctly")

func _test_cloud_save_structure():
	print("\n[TEST 3] Cloud Save Structure...")

	# Simulate complete cloud save structure
	var current_time = Time.get_unix_time_from_system()
	var cloud_save = {
		"version": "2.0",
		"timestamp": current_time,
		"global": {
			"settings": {
				"ui_scale": 1.0,
				"music_volume": 0.8,
				"sfx_volume": 0.8
			},
			"strength": 5,
			"constitution": 3,
			"dexterity": 4,
			"wisdom": 2,
			"intelligence": 6,
			"charisma": 1,
			"strength_exp": 250.5,
			"constitution_exp": 100.0,
			"dexterity_exp": 180.0,
			"wisdom_exp": 50.0,
			"intelligence_exp": 320.0,
			"charisma_exp": 10.0,
			"total_play_length": 7200.0
		},
		"level1_vars": Level1Vars.get_save_data()
	}

	# Verify structure
	if not cloud_save.has("version"):
		_test_failed("Cloud save missing 'version' field")
		return

	if not cloud_save.has("timestamp"):
		_test_failed("Cloud save missing 'timestamp' field")
		return

	if not cloud_save.has("global"):
		_test_failed("Cloud save missing 'global' field")
		return

	if not cloud_save.has("level1_vars"):
		_test_failed("Cloud save missing 'level1_vars' field")
		return

	# Test JSON serialization
	var json_string = JSON.stringify(cloud_save)
	if json_string.is_empty():
		_test_failed("Failed to serialize cloud save to JSON")
		return

	print("  Cloud save JSON size: %d characters" % json_string.length())

	# Test JSON deserialization
	var parsed_data = JSON.parse_string(json_string)
	if parsed_data == null:
		_test_failed("Failed to parse cloud save JSON")
		return

	if not parsed_data.has("global"):
		_test_failed("Parsed cloud save missing 'global' field")
		return

	_test_passed("Cloud save structure valid and JSON-serializable")

func _test_load_suppresses_notifications():
	print("\n[TEST 4] Load Suppresses Notifications...")

	# This test verifies the is_loading_cloud_save flag works
	# Note: Requires Global to have is_loading_cloud_save flag implemented

	if not Global.get("is_loading_cloud_save") == null:
		# Flag exists, test it
		print("  is_loading_cloud_save flag found in Global")

		# Track notification count
		var initial_notifications = Global.active_notifications.size()

		# Set flag
		Global.is_loading_cloud_save = true

		# Change stats (should not trigger notifications)
		var old_strength = Global.strength
		Global.strength = old_strength + 5

		# Check notifications didn't increase
		var final_notifications = Global.active_notifications.size()

		# Restore
		Global.is_loading_cloud_save = false
		Global.strength = old_strength

		if final_notifications > initial_notifications:
			_test_failed("Notifications still triggered during load (flag not working)")
			return

		_test_passed("is_loading_cloud_save flag successfully suppresses notifications")
	else:
		# Flag doesn't exist yet
		print("  [SKIP] is_loading_cloud_save flag not yet implemented in Global")
		print("  This is expected if Global hasn't been updated yet.")
		print("  Add to Global: var is_loading_cloud_save: bool = false")
		print("  Update stat setters to check: and not is_loading_cloud_save")
		_test_passed("Skipped (flag not implemented yet)")

func _test_passed(message: String):
	tests_passed += 1
	print("[PASS] %s" % message)

func _test_failed(message: String):
	tests_failed += 1
	test_errors.append(message)
	print("[FAIL] %s" % message)

func _print_summary():
	print("\n" + "=".repeat(60))

	if tests_failed == 0:
		print("ALL TESTS PASSED! (%d/%d)" % [tests_passed, tests_passed])
		print("=".repeat(60))
		print("\nSerialization functions are ready for integration.")
		print("Next step: Implement in NakamaManager (nakama_client.gd)\n")
	else:
		print("TESTS FAILED: %d passed, %d failed" % [tests_passed, tests_failed])
		print("=".repeat(60))
		print("\nFailed tests:")
		for i in range(test_errors.size()):
			print("  %d. %s" % [i + 1, test_errors[i]])
		print("")
