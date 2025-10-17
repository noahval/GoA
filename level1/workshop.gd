extends Control

var break_time = 30.0
var max_break_time = 30.0

@onready var suspicion_panel = $HBoxContainer/LeftColumn/SuspicionPanel
@onready var suspicion_bar = $HBoxContainer/LeftColumn/SuspicionPanel/SuspicionBar

func _ready():
	# Set the actual maximum break time (not the remaining time)
	max_break_time = Level1Vars.starting_break_time + Level1Vars.overseer_lvl

	if Level1Vars.break_time_remaining > 0:
		break_time = Level1Vars.break_time_remaining
	else:
		break_time = max_break_time

	# Initialize the progress bar to the current percentage
	var progress_percent = (break_time / max_break_time) * 100.0
	$HBoxContainer/LeftColumn/BreakTimerPanel/BreakTimerBar.value = progress_percent

	update_labels()
	update_suspicion_bar()
	add_planning_table_button()
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

	# Update progress bar based on current break time
	var progress_percent = (break_time / max_break_time) * 100.0
	$HBoxContainer/LeftColumn/BreakTimerPanel/BreakTimerBar.value = progress_percent

	if break_time <= 0:
		Level1Vars.break_time_remaining = 0.0
		get_tree().change_scene_to_file("res://level1/furnace.tscn")

	update_labels()
	update_suspicion_bar()

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

func add_planning_table_button():
	if Level1Vars.heart_taken:
		var planning_table_button = Button.new()
		planning_table_button.name = "PlanningTableButton"
		planning_table_button.text = "Planning Table"

		# Get the theme from another button
		var theme_resource = load("res://default_theme.tres")
		planning_table_button.theme = theme_resource

		# Add the button to the right column (before the back button)
		var right_column = $HBoxContainer/RightColumn
		var back_button = $HBoxContainer/RightColumn/BackToPassageButton
		var back_button_index = back_button.get_index()
		right_column.add_child(planning_table_button)
		right_column.move_child(planning_table_button, back_button_index)

		# Connect the signal
		planning_table_button.pressed.connect(_on_planning_table_button_pressed)

func _on_planning_table_button_pressed():
	get_tree().change_scene_to_file("res://level1/planning_table.tscn")

func update_suspicion_bar():
	suspicion_panel.visible = Level1Vars.suspicion > 0
	suspicion_bar.value = Level1Vars.suspicion
