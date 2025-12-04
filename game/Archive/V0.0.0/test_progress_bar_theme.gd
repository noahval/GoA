extends SceneTree

func _init():
	print("\n===== PROGRESS BAR THEME TEST =====\n")

	# Load the furnace scene
	var furnace_scene = load("res://level1/furnace.tscn")
	if not furnace_scene:
		print("ERROR: Could not load furnace scene")
		quit(1)
		return

	var furnace = furnace_scene.instantiate()
	root.add_child(furnace)

	# Find the StaminaPanel and StaminaBar
	var stamina_panel = furnace.get_node_or_null("HBoxContainer/LeftVBox/StaminaPanel")
	if not stamina_panel:
		print("ERROR: Could not find StaminaPanel")
		quit(1)
		return

	var stamina_bar = stamina_panel.get_node_or_null("StaminaBar")
	if not stamina_bar:
		print("ERROR: Could not find StaminaBar")
		quit(1)
		return

	# Check StaminaPanel theme
	print("StaminaPanel theme_type_variation: ", stamina_panel.theme_type_variation)
	var panel_stylebox = stamina_panel.get_theme_stylebox("panel")
	print("StaminaPanel stylebox type: ", panel_stylebox.get_class())

	if panel_stylebox is StyleBoxFlat:
		print("  Panel bg_color: ", panel_stylebox.bg_color)
		print("  Panel draw_center: ", panel_stylebox.draw_center)

	# Check StaminaBar theme
	print("\nStaminaBar info:")
	var bg_stylebox = stamina_bar.get_theme_stylebox("background")
	print("  Background stylebox type: ", bg_stylebox.get_class())

	if bg_stylebox is StyleBoxFlat:
		print("  Background color: ", bg_stylebox.bg_color)

	var fill_stylebox = stamina_bar.get_theme_stylebox("fill")
	print("  Fill stylebox type: ", fill_stylebox.get_class())

	if fill_stylebox is StyleBoxFlat:
		print("  Fill color: ", fill_stylebox.bg_color)

	print("\n===== TEST COMPLETE =====\n")
	quit(0)
