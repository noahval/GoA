extends Control

var minimum_display_time = 3.0  # seconds
var fade_duration = 1.0  # seconds
var elapsed_time = 0.0
var state = "loading"  # States: loading, showing_login, waiting_for_auth, fading_out
var login_shown = false

@onready var fade_overlay = $FadeOverlay
@onready var popup_container = $PopupContainer
@onready var login_popup = $PopupContainer/LoginPopup

func _ready():
	# Start with transparent overlay
	fade_overlay.modulate.a = 0.0

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
