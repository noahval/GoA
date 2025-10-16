extends Control

var minimum_display_time = 3.0  # seconds
var elapsed_time = 0.0

func _ready():
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
	if elapsed_time >= minimum_display_time:
		# Transition to the main scene
		get_tree().change_scene_to_file("res://level1/furnace.tscn")
