extends Control

var break_time = 0.0

func _ready():
	break_time = Level1Vars.break_time_remaining

func _process(delta):
	break_time -= delta
	Level1Vars.break_time_remaining = break_time
	if break_time <= 0:
		Level1Vars.break_time_remaining = 0.0
		get_tree().change_scene_to_file("res://level1/furnace.tscn")
	else:
		$VBoxContainer/BreakTimerPanel/BreakTimer.text = "Break Timer: " + str(ceil(break_time))

func _on_puzzle_button_pressed():
	get_tree().change_scene_to_file("res://level1/secret_passage_puzzle.tscn")

func _on_workshop_button_pressed():
	get_tree().change_scene_to_file("res://level1/workshop.tscn")

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://level1/shop.tscn")
