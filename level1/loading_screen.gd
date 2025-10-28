extends Control

var minimum_display_time = 0.5  # seconds
var fade_duration = 1.0  # seconds
var elapsed_time = 0.0
var state = "loading"  # States: loading, fading_out

@onready var fade_overlay = $FadeOverlay

func _ready():
	# Start with transparent overlay
	fade_overlay.modulate.a = 0.0

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
				state = "fading_out"
				elapsed_time = 0.0

		"fading_out":
			# Fade to black
			var progress = min(elapsed_time / fade_duration, 1.0)
			fade_overlay.modulate.a = progress

			if progress >= 1.0:
				# Transition to intro screen
				Global.change_scene_with_check(get_tree(), "res://level1/intro_screen.tscn")
