extends Control

var break_time = 30.0

func _ready():
	if Level1Vars.break_time_remaining > 0:
		break_time = Level1Vars.break_time_remaining
	else:
		break_time = 56.0 + Level1Vars.overseer_lvl
	update_labels()

func _process(delta):
	break_time -= delta
	Level1Vars.break_time_remaining = break_time
	if break_time <= 0:
		Level1Vars.break_time_remaining = 0.0
		get_tree().change_scene_to_file("res://level1/furnace.tscn")
	else:
		$VBoxContainer/BreakTimerPanel/BreakTimer.text = "Break Timer: " + str(ceil(break_time))
	update_labels()

func update_labels():
	$VBoxContainer/ComponentsPanel/ComponentsLabel.text = "Components: " + str(Level1Vars.components)
	$VBoxContainer/MechanismsPanel/MechanismsLabel.text = "Mechanisms: " + str(Level1Vars.mechanisms)
	$VBoxContainer/PipesPanel/PipesLabel.text = "Pipes: " + str(Level1Vars.pipes)

func _on_assemble_component_button_pressed():
	Level1Vars.components += 1
	update_labels()

func _on_buy_pipe_button_pressed():
	if Level1Vars.components >= 10:
		Level1Vars.components -= 10
		Level1Vars.pipes += 1
		update_labels()

func _on_buy_mechanism_button_pressed():
	if Level1Vars.components >= 10:
		Level1Vars.components -= 10
		Level1Vars.mechanisms += 1
		update_labels()

func _on_back_to_passage_button_pressed():
	get_tree().change_scene_to_file("res://level1/secret_passage_entrance.tscn")
