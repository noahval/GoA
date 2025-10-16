extends Control

var fade_duration = 1.0  # seconds
var display_time = 3.0  # seconds
var elapsed_time = 0.0
var state = "fading_in"  # States: fading_in, displaying, fading_out

@onready var fade_overlay = $FadeOverlay

func _ready():
	# Start with black overlay fully opaque
	fade_overlay.modulate.a = 1.0
	# Begin fading in
	state = "fading_in"
	elapsed_time = 0.0

func _process(delta):
	elapsed_time += delta

	match state:
		"fading_in":
			# Fade from black to reveal intro image
			var progress = min(elapsed_time / fade_duration, 1.0)
			fade_overlay.modulate.a = 1.0 - progress

			if progress >= 1.0:
				state = "displaying"
				elapsed_time = 0.0

		"displaying":
			# Hold the intro image for display_time seconds
			if elapsed_time >= display_time:
				state = "fading_out"
				elapsed_time = 0.0

		"fading_out":
			# Fade to black
			var progress = min(elapsed_time / fade_duration, 1.0)
			fade_overlay.modulate.a = progress

			if progress >= 1.0:
				# Transition to furnace scene
				get_tree().change_scene_to_file("res://level1/furnace.tscn")
