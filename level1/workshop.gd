extends Control

var break_time = 30.0
var max_break_time = 30.0

func find_node_recursive(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child in node.get_children():
		var result = find_node_recursive(child, node_name)
		if result:
			return result
	return null

func _ready():
	# Set the actual maximum break time (not the remaining time)
	max_break_time = Level1Vars.starting_break_time + Level1Vars.overseer_lvl

	if Level1Vars.break_time_remaining > 0:
		break_time = Level1Vars.break_time_remaining
	else:
		break_time = max_break_time

	# Initialize the progress bar to the current percentage
	var progress_percent = (break_time / max_break_time) * 100.0
	var break_timer_bar = find_node_recursive(self, "BreakTimerBar")
	if break_timer_bar:
		break_timer_bar.value = progress_percent

	update_labels()
	update_suspicion_bar()
	add_planning_table_button()
	ResponsiveLayout.apply_to_scene(self)

func _process(delta):
	break_time -= delta
	Level1Vars.break_time_remaining = break_time

	# Update progress bar based on current break time
	var progress_percent = (break_time / max_break_time) * 100.0
	var break_timer_bar = find_node_recursive(self, "BreakTimerBar")
	if break_timer_bar:
		break_timer_bar.value = progress_percent

	if break_time <= 0:
		Level1Vars.break_time_remaining = 0.0
		Global.change_scene_with_check(get_tree(), "res://level1/furnace.tscn")

	update_labels()
	update_suspicion_bar()

func update_labels():
	var components_label = find_node_recursive(self, "ComponentsLabel")
	if components_label:
		components_label.text = "Components: " + str(Level1Vars.components)

	var mechanisms_label = find_node_recursive(self, "MechanismsLabel")
	if mechanisms_label:
		mechanisms_label.text = "Mechanisms: " + str(Level1Vars.mechanisms)

	var pipes_label = find_node_recursive(self, "PipesLabel")
	if pipes_label:
		pipes_label.text = "Pipes: " + str(Level1Vars.pipes)

	# Show/hide dev pipes button based on dev_speed_mode
	var dev_pipes_button = find_node_recursive(self, "DevPipesButton")
	if dev_pipes_button:
		dev_pipes_button.visible = Global.dev_speed_mode

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
	Global.change_scene_with_check(get_tree(), "res://level1/shop.tscn")

func _on_dev_pipes_button_pressed():
	Level1Vars.pipes += 30
	update_labels()

func add_planning_table_button():
	if Level1Vars.heart_taken:
		var planning_table_button = Button.new()
		planning_table_button.name = "PlanningTableButton"
		planning_table_button.text = "Planning Table"

		# Get the theme from another button
		var theme_resource = load("res://default_theme.tres")
		planning_table_button.theme = theme_resource

		# Add the button before the back button (works for any layout)
		var back_button = find_node_recursive(self, "BackToPassageButton")
		if back_button and back_button.get_parent():
			var parent = back_button.get_parent()
			var back_button_index = back_button.get_index()
			parent.add_child(planning_table_button)
			parent.move_child(planning_table_button, back_button_index)

			# Connect the signal
			planning_table_button.pressed.connect(_on_planning_table_button_pressed)

func _on_planning_table_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/planning_table.tscn")

func update_suspicion_bar():
	var suspicion_panel = find_node_recursive(self, "SuspicionPanel")
	if suspicion_panel:
		suspicion_panel.visible = Level1Vars.suspicion > 0

	var suspicion_bar = find_node_recursive(self, "SuspicionBar")
	if suspicion_bar:
		suspicion_bar.value = Level1Vars.suspicion
