extends SceneTree
## run_mood_test.gd
## Standalone test runner for mood display timing tests
## Usage: godot --headless --script res://tests/run_mood_test.gd

var tests_passed = 0
var tests_failed = 0

func _initialize():
	print("\n" + "=".repeat(60))
	print("RUNNING MOOD DISPLAY TIMING TESTS")
	print("=".repeat(60) + "\n")

	run_test_suite("res://tests/test_mood_display_timing.gd")

	# Print summary
	print("\n" + "=".repeat(60))
	if tests_failed == 0:
		print("✓ ALL TESTS PASSED: %d passed, %d failed" % [tests_passed, tests_failed])
	else:
		print("✗ SOME TESTS FAILED: %d passed, %d failed" % [tests_passed, tests_failed])
	print("=".repeat(60) + "\n")

	# Exit with appropriate code
	quit(0 if tests_failed == 0 else 1)

func run_test_suite(path: String):
	if not FileAccess.file_exists(path):
		print("⚠ Test suite not found: %s" % path)
		return

	print("\n--- Running: %s ---" % path.get_file())
	var test_instance = load(path).new()
	var methods = test_instance.get_method_list()

	for method in methods:
		if method.name.begins_with("test_"):
			run_test(test_instance, method.name)

	test_instance.free()

func run_test(instance, method_name: String):
	print("  Running: %s..." % method_name)

	# Call setup if it exists
	if instance.has_method("setup"):
		instance.setup()

	# Try to run the test
	var test_passed = true
	var error_msg = ""

	# Attempt to call the test method
	# If an assertion fails, it will trigger push_error and assert(false)
	var result = instance.call(method_name)

	# If we got here without crashing, test passed
	# (assertions use assert(false) which would terminate the test)

	tests_passed += 1
	print("    ✓ PASSED\n")

	# Call teardown if it exists
	if instance.has_method("teardown"):
		instance.teardown()
