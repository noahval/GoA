extends Control

var break_time = 30.0
var max_break_time = 30.0

func _ready():
	if Level1Vars.break_time_remaining > 0:
		break_time = Level1Vars.break_time_remaining
	else:
		break_time = 56.0 + Level1Vars.overseer_lvl
	max_break_time = break_time
	update_labels()
	apply_mobile_scaling()

func apply_mobile_scaling():
	var viewport_size = get_viewport().get_visible_rect().size
	# Check if in portrait mode (taller than wide)
	if viewport_size.y > viewport_size.x:
		# Scale up buttons for mobile
		var buttons = $HBoxContainer/RightColumn.get_children()
		for button in buttons:
			if button is Button:
				button.custom_minimum_size = Vector2(0, 60)
				if button.get("theme_override_font_sizes/font_size") == null:
					button.add_theme_font_size_override("font_size", 24)

func _process(delta):
	break_time -= delta
	Level1Vars.break_time_remaining = break_time
	if break_time <= 0:
		Level1Vars.break_time_remaining = 0.0
		get_tree().change_scene_to_file("res://level1/furnace.tscn")
	else:
		$HBoxContainer/LeftColumn/BreakTimerPanel/BreakTimer.text = "Break Timer"
		# Update progress bar
		var progress_percent = (break_time / max_break_time) * 100.0
		$HBoxContainer/LeftColumn/BreakTimerPanel/BreakTimerBar.value = progress_percent
	update_labels()

func update_labels():
	$HBoxContainer/LeftColumn/ComponentsPanel/ComponentsLabel.text = "Components: " + str(Level1Vars.components)
	$HBoxContainer/LeftColumn/MechanismsPanel/MechanismsLabel.text = "Mechanisms: " + str(Level1Vars.mechanisms)
	$HBoxContainer/LeftColumn/PipesPanel/PipesLabel.text = "Pipes: " + str(Level1Vars.pipes)

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
