extends Control

func _ready():
	apply_mobile_scaling()

func apply_mobile_scaling():
	var viewport_size = get_viewport().get_visible_rect().size
	# Check if in portrait mode (taller than wide)
	if viewport_size.y > viewport_size.x:
		# Scale up buttons for mobile - check for buttons in the scene
		for child in get_children():
			if child is Button:
				child.custom_minimum_size = Vector2(0, 60)
				if child.get("theme_override_font_sizes/font_size") == null:
					child.add_theme_font_size_override("font_size", 24)
			elif child is VBoxContainer or child is HBoxContainer:
				for button in child.get_children():
					if button is Button:
						button.custom_minimum_size = Vector2(0, 60)
						if button.get("theme_override_font_sizes/font_size") == null:
							button.add_theme_font_size_override("font_size", 24)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://level1/secret_passage_entrance.tscn")
