extends Control

var break_time = 30.0
var max_break_time = 30.0

@onready var break_timer_bar = $HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimerBar
@onready var title_label = $HBoxContainer/LeftVBox/TitlePanel/TitleLabel
@onready var background = $Background
@onready var take_heart_button = $HBoxContainer/RightVBox/TakeHeartButton

func _ready():
	# Apply responsive layout first
	ResponsiveLayout.apply_to_scene(self)

	# Set the actual maximum break time (not the remaining time)
	max_break_time = Level1Vars.starting_break_time + Level1Vars.overseer_lvl

	if Level1Vars.break_time_remaining > 0:
		break_time = Level1Vars.break_time_remaining
	else:
		break_time = max_break_time

	# Initialize the progress bar to the current percentage
	var progress_percent = (break_time / max_break_time) * 100.0
	break_timer_bar.value = progress_percent

	update_scene_state()

func _process(delta):
	break_time -= delta
	Level1Vars.break_time_remaining = break_time

	# Update progress bar based on current break time
	var progress_percent = (break_time / max_break_time) * 100.0
	break_timer_bar.value = progress_percent

	if break_time <= 0:
		Level1Vars.break_time_remaining = 0.0
		Global.change_scene_with_check(get_tree(), "res://level1/furnace.tscn")

func update_scene_state():
	# Check if heart has already been taken
	if Level1Vars.heart_taken:
		# Change label to "Empty Mechanism"
		title_label.text = "Empty Mechanism"
		# Change background to empty heart
		var empty_heart_texture = load("res://level1/empty_heart.jpg")
		background.texture = empty_heart_texture
		# Hide the take heart button
		take_heart_button.visible = false

func _on_back_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/secret_passage_entrance.tscn")

func _on_take_heart_button_pressed():
	Level1Vars.heart_taken = true
	# Change label to "Empty Mechanism"
	title_label.text = "Empty Mechanism"
	# Change background to empty heart
	var empty_heart_texture = load("res://level1/empty_heart.jpg")
	background.texture = empty_heart_texture
	# Hide the take heart button
	take_heart_button.visible = false
