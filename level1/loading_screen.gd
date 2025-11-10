extends Control

var minimum_display_time = 3.0  # seconds
var fade_duration = 1.0  # seconds
var elapsed_time = 0.0
var state = "loading"  # States: loading, showing_login, waiting_for_auth, fading_out
var login_shown = false
var _last_viewport_size: Vector2 = Vector2.ZERO

@onready var fade_overlay = $FadeOverlay
@onready var popup_container = $PopupContainer
@onready var login_popup = $PopupContainer/LoginPopup

func _ready():
	# Start with transparent overlay
	fade_overlay.modulate.a = 0.0

	# Process offline earnings (before showing login)
	_process_offline_earnings()

	# Connect login popup signals
	login_popup.authentication_completed.connect(_on_auth_completed)
	login_popup.skip_login.connect(_on_login_skipped)

	# For web builds, we need to use JavaScript to play HTML5 video
	if OS.has_feature("web"):
		_setup_web_video()
	else:
		# Desktop/mobile builds can use VideoStreamPlayer
		if has_node("VideoStreamPlayer"):
			var video_player = $VideoStreamPlayer
			video_player.play()

func _setup_web_video():
	# Video is already handled by custom_shell.html, no need for additional setup
	pass

func _process(delta):
	elapsed_time += delta

	# Monitor viewport resizing and reapply popup constraints
	var current_viewport_size = get_viewport_rect().size
	if login_popup.visible and current_viewport_size != _last_viewport_size:
		_last_viewport_size = current_viewport_size
		DebugLogger.log_info("LoadingScreen", "Viewport resized to %s - reapplying popup constraints" % current_viewport_size)
		if login_popup.has_method("_apply_responsive_constraints"):
			login_popup._apply_responsive_constraints()

	match state:
		"loading":
			if elapsed_time >= minimum_display_time:
				# Show login popup
				state = "showing_login"
				elapsed_time = 0.0
				_show_login_popup()

		"showing_login":
			# Wait for user to interact with login popup
			pass

		"waiting_for_auth":
			# Wait for authentication to complete
			pass

		"fading_out":
			# Fade to black
			var progress = min(elapsed_time / fade_duration, 1.0)
			fade_overlay.modulate.a = progress

			if progress >= 1.0:
				# Transition to intro screen
				Global.change_scene_with_check(get_tree(), "res://level1/intro_screen.tscn")

func _show_login_popup():
	if not login_shown:
		login_shown = true
		popup_container.visible = true
		login_popup.show_popup()
		DebugLogger.log_info("LoadingScreen", "Showing login popup")

func _on_auth_completed(success: bool):
	DebugLogger.log_info("LoadingScreen", "Authentication completed: " + str(success))
	state = "fading_out"
	elapsed_time = 0.0
	popup_container.visible = false

func _on_login_skipped():
	DebugLogger.log_info("LoadingScreen", "Login skipped, continuing offline")
	state = "fading_out"
	elapsed_time = 0.0
	popup_container.visible = false

## Process offline earnings when game loads
func _process_offline_earnings():
	# Initialize timestamp if first time playing
	if Level1Vars.last_played_timestamp == 0:
		Level1Vars.last_played_timestamp = Time.get_unix_time_from_system()
		DebugLogger.log_info("OfflineEarnings", "First time playing - initialized timestamp")
		return

	var current_time = Time.get_unix_time_from_system()
	var elapsed = current_time - Level1Vars.last_played_timestamp

	# Only process if away for at least 60 seconds (1 minute)
	if elapsed < 60:
		Level1Vars.last_played_timestamp = current_time
		DebugLogger.log_info("OfflineEarnings", "Less than 60 seconds elapsed - no offline earnings")
		return

	# Check if player has auto-shovels
	if Level1Vars.auto_shovel_lvl == 0:
		Level1Vars.last_played_timestamp = current_time
		DebugLogger.log_info("OfflineEarnings", "No auto-shovels - no offline earnings")
		return

	var cap_seconds = Level1Vars.get_offline_cap_seconds()
	var coal_earned = OfflineEarningsManager.calculate_offline_earnings(
		elapsed,
		cap_seconds,
		Level1Vars.auto_shovel_lvl,
		Level1Vars.auto_shovel_coal_per_tick,
		Level1Vars.auto_shovel_freq
	)

	if coal_earned > 0:
		Level1Vars.coal += coal_earned
		var message = OfflineEarningsManager.get_offline_summary(elapsed, cap_seconds, coal_earned)
		Global.show_stat_notification(message)
		DebugLogger.log_info("OfflineEarnings", "Earned %d coal while offline (elapsed: %d seconds, cap: %d seconds)" % [coal_earned, elapsed, cap_seconds])

	Level1Vars.last_played_timestamp = current_time
