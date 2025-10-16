extends Control

var minimum_display_time = 3.0  # seconds
var elapsed_time = 0.0

func _ready():
	# Ensure the video player is set up correctly
	var video_player = $VideoStreamPlayer
	video_player.play()

func _process(delta):
	elapsed_time += delta
	if elapsed_time >= minimum_display_time:
		# Transition to the main scene
		get_tree().change_scene_to_file("res://level1/furnace.tscn")
