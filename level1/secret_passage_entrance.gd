extends Control

var break_time = 0.0
var max_break_time = 30.0

func _ready():
	ResponsiveLayout.apply_to_scene(self)

	# Set the actual maximum break time (not the remaining time)
	max_break_time = Level1Vars.starting_break_time + Level1Vars.overseer_lvl

	if Level1Vars.break_time_remaining > 0:
		break_time = Level1Vars.break_time_remaining
	else:
		break_time = max_break_time

	# Initialize the progress bar to the current percentage
	var progress_percent = (break_time / max_break_time) * 100.0
	$HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimerBar.value = progress_percent

func _process(delta):
	break_time -= delta
	Level1Vars.break_time_remaining = break_time

	# Update progress bar based on current break time
	var progress_percent = (break_time / max_break_time) * 100.0
	$HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimerBar.value = progress_percent

	if break_time <= 0:
		Level1Vars.break_time_remaining = 0.0
		Global.change_scene_with_check(get_tree(), "res://level1/furnace.tscn")

func _on_puzzle_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/secret_passage_puzzle.tscn")

func _on_to_bar_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/bar.tscn")
