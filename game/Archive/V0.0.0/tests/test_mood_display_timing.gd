extends Node
## test_mood_display_timing.gd
## Unit tests for mood display timing system in furnace.gd
## Tests: random delayed updates, actual mood vs displayed mood, timing intervals

const TestAssertions = preload("res://tests/test_assertions.gd")

var furnace_scene: Node  # The loaded furnace scene instance
var overseer_mood: Node  # OverseerMood singleton

func setup():
	# Load OverseerMood autoload
	overseer_mood = load("res://level1/overseer_mood.gd").new()
	overseer_mood.name = "OverseerMood"
	add_child(overseer_mood)
	# Initialize OverseerMood
	overseer_mood._ready()

	# Load Level1Vars autoload
	var level1_vars = load("res://level1/level_1_vars.gd").new()
	level1_vars.name = "Level1Vars"
	add_child(level1_vars)

	# Unlock mood system so it's visible
	level1_vars.mood_system_unlocked = true

	# Load furnace scene (this will call _ready which initializes mood display)
	var furnace_packed = load("res://level1/furnace.tscn")
	furnace_scene = furnace_packed.instantiate()
	add_child(furnace_scene)

	# Manually call _ready to ensure initialization (scene tree might not auto-call it in tests)
	if furnace_scene.has_method("_ready"):
		furnace_scene._ready()

func teardown():
	if furnace_scene:
		furnace_scene.queue_free()
	if overseer_mood:
		overseer_mood.queue_free()

## Test 1: Verify actual mood changes immediately (mechanics preserved)
func test_actual_mood_changes_immediately():
	var initial_fatigue = overseer_mood.fatigue_level

	# Trigger a manual conversion (which adds fatigue)
	overseer_mood.manual_convert_coal(40.0)

	# Verify fatigue increased immediately
	TestAssertions.assert_greater(overseer_mood.fatigue_level, initial_fatigue,
		"Fatigue should increase immediately after conversion")

	print("    → Fatigue increased from %.2f to %.2f (immediate)" % [initial_fatigue, overseer_mood.fatigue_level])

## Test 2: Verify display doesn't update immediately after conversion
func test_display_not_immediate():
	# Store initial cached mood
	var initial_cached_mood = furnace_scene.cached_mood_text

	# Get current actual mood
	var actual_mood_before = overseer_mood.get_mood_adjective()

	# Force a fatigue spike to change actual mood
	overseer_mood.fatigue_level = 0.8  # High fatigue should make mood worse

	# Verify actual mood changed
	var actual_mood_after = overseer_mood.get_mood_adjective()
	print("    → Actual mood: %s → %s" % [actual_mood_before, actual_mood_after])

	# Cached mood should remain unchanged (no time has passed)
	TestAssertions.assert_equal(furnace_scene.cached_mood_text, initial_cached_mood,
		"Cached mood should not change immediately")

	print("    → Cached mood unchanged: %s (delayed update system working)" % initial_cached_mood)

## Test 3: Verify updates occur at 4-10 second intervals
func test_random_interval_timing():
	var update_intervals = []
	var last_cached_mood = furnace_scene.cached_mood_text
	var last_update_time = 0.0
	var elapsed_time = 0.0
	var delta = 0.016  # Simulate 60 FPS (16ms per frame)

	# Run for 60 seconds, track when mood display updates
	while elapsed_time < 60.0:
		furnace_scene._process(delta)
		overseer_mood._process(delta)
		elapsed_time += delta

		# Check if cached mood changed
		if furnace_scene.cached_mood_text != last_cached_mood:
			var interval = elapsed_time - last_update_time
			update_intervals.append(interval)
			print("    → Update at %.2fs (interval: %.2fs)" % [elapsed_time, interval])
			last_cached_mood = furnace_scene.cached_mood_text
			last_update_time = elapsed_time

	# Verify we got multiple updates
	TestAssertions.assert_greater_or_equal(update_intervals.size(), 5,
		"Should have at least 5 updates in 60 seconds")

	# Verify all intervals are within 4-10 second range
	for i in range(update_intervals.size()):
		var interval = update_intervals[i]
		if i == 0:
			# First interval starts from 0, so it uses the initial random delay
			TestAssertions.assert_greater_or_equal(interval, 4.0,
				"Interval %d should be >= 4 seconds" % i)
			TestAssertions.assert_less_or_equal(interval, 10.0,
				"Interval %d should be <= 10 seconds" % i)
		else:
			# Subsequent intervals should be in range
			TestAssertions.assert_greater_or_equal(interval, 4.0,
				"Interval %d should be >= 4 seconds" % i)
			TestAssertions.assert_less_or_equal(interval, 10.0,
				"Interval %d should be <= 10 seconds" % i)

	print("    → All %d intervals within 4-10 second range ✓" % update_intervals.size())

## Test 4: Verify cached display eventually syncs with actual mood
func test_cached_mood_syncs_eventually():
	var delta = 0.016  # 60 FPS

	# Set a distinctive actual mood by manipulating fatigue
	overseer_mood.fatigue_level = 0.0
	overseer_mood.mood_value = 0.9  # Should be "delighted"

	var target_mood = overseer_mood.get_mood_adjective()
	TestAssertions.assert_equal(target_mood, "delighted", "Setup: actual mood should be delighted")

	# Wait for next update (up to 10 seconds)
	var elapsed = 0.0
	var synced = false
	while elapsed < 11.0:  # Wait slightly longer than max delay
		furnace_scene._process(delta)
		overseer_mood._process(delta)
		elapsed += delta

		if furnace_scene.cached_mood_text == target_mood:
			synced = true
			print("    → Synced after %.2f seconds" % elapsed)
			break

	TestAssertions.assert_true(synced, "Cached mood should sync with actual mood within 10 seconds")
	TestAssertions.assert_equal(furnace_scene.cached_mood_text, target_mood,
		"Cached mood should match actual mood after update")

## Test 5: Spam conversions - display remains stable
func test_spam_conversions_stable_display():
	# Store initial cached mood
	var initial_cached_mood = furnace_scene.cached_mood_text

	# Spam conversions rapidly
	for i in range(20):
		overseer_mood.manual_convert_coal(40.0)

	# Verify actual mood changed (fatigue accumulated)
	TestAssertions.assert_greater(overseer_mood.fatigue_level, 0.5,
		"Fatigue should be high after spam conversions")

	# Cached mood should still be the same (no time passed)
	TestAssertions.assert_equal(furnace_scene.cached_mood_text, initial_cached_mood,
		"Display should not update during spam conversions")

	print("    → Display stable during 20 rapid conversions ✓")

	# Now simulate time passing and verify update occurs
	var delta = 0.016
	var elapsed = 0.0
	var updated = false

	while elapsed < 11.0:
		furnace_scene._process(delta)
		overseer_mood._process(delta)
		elapsed += delta

		if furnace_scene.cached_mood_text != initial_cached_mood:
			updated = true
			print("    → Display updated after %.2f seconds (as expected)" % elapsed)
			break

	TestAssertions.assert_true(updated, "Display should update at next scheduled interval")

## Test 6: Verify timer persistence and independence from game actions
func test_timer_independence():
	# Record initial state
	var initial_timer = furnace_scene.mood_display_timer
	var initial_delay = furnace_scene.next_mood_update_delay

	# Perform various game actions
	overseer_mood.manual_convert_coal(40.0)
	overseer_mood.apply_mood_drift()

	# Advance time slightly
	var delta = 0.016
	for i in range(10):  # 0.16 seconds
		furnace_scene._process(delta)
		overseer_mood._process(delta)

	# Timer should have advanced by ~0.16 seconds
	var expected_timer = initial_timer + (delta * 10)
	TestAssertions.assert_approx(furnace_scene.mood_display_timer, expected_timer, 0.01,
		"Timer should advance consistently regardless of game actions")

	# Next delay should remain unchanged
	TestAssertions.assert_equal(furnace_scene.next_mood_update_delay, initial_delay,
		"Next update delay should not change until timer triggers")

	print("    → Timer advanced by %.3f seconds (independent of conversions) ✓" % (delta * 10))
