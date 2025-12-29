extends GutTest

var train_shake: Node

func before_each():
	train_shake = load("res://autoloads/train_shake.gd").new()
	add_child(train_shake)
	Level1Vars.shake_enabled = true
	Level1Vars.shake_warning_duration = 0.5
	Level1Vars.shake_big_duration_min = 0.5
	Level1Vars.shake_big_duration_max = 2.0

func after_each():
	train_shake.queue_free()

func test_initial_state_is_idle():
	assert_eq(train_shake.current_state, train_shake.ShakeState.IDLE)

func test_shake_disabled_prevents_activation():
	Level1Vars.shake_enabled = false
	train_shake.next_shake_timer = 0.0
	train_shake.process_idle(0.1)
	assert_eq(train_shake.current_state, train_shake.ShakeState.IDLE)

func test_warning_shake_starts_after_timer():
	train_shake.next_shake_timer = 0.0
	train_shake.process_idle(0.1)
	assert_eq(train_shake.current_state, train_shake.ShakeState.WARNING)

func test_warning_transitions_to_big_shake():
	train_shake.start_warning_shake()
	train_shake.current_shake_timer = 0.0
	train_shake.process_warning(0.1)
	assert_eq(train_shake.current_state, train_shake.ShakeState.BIG_SHAKE)

func test_big_shake_transitions_to_idle():
	train_shake.start_big_shake()
	train_shake.current_shake_timer = 0.0
	train_shake.process_big_shake(0.1)
	assert_eq(train_shake.current_state, train_shake.ShakeState.IDLE)

func test_overlapping_shake_ignored():
	train_shake.start_warning_shake()
	var timer_before = train_shake.current_shake_timer
	train_shake.start_warning_shake()  # Should be ignored
	assert_eq(train_shake.current_shake_timer, timer_before)

func test_shake_duration_randomized():
	var durations = []
	for i in range(10):
		train_shake.start_big_shake()
		durations.append(train_shake.current_shake_timer)

	# Check that not all durations are identical (random variance exists)
	var all_same = true
	for i in range(1, durations.size()):
		if durations[i] != durations[0]:
			all_same = false
			break
	assert_false(all_same, "Shake durations should vary")

func test_shake_disabled_mid_shake_cleanup():
	train_shake.start_warning_shake()
	Level1Vars.shake_enabled = false
	train_shake.process_warning(0.1)
	assert_eq(train_shake.current_state, train_shake.ShakeState.IDLE, "Should force cleanup when disabled mid-shake")
