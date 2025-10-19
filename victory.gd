extends Control

func _ready():
	# Update stats display with final values
	$VBoxContainer/StatsContainer/StrengthLabel.text = "Strength: " + str(int(Global.strength))
	$VBoxContainer/StatsContainer/ConstitutionLabel.text = "Constitution: " + str(int(Global.constitution))
	$VBoxContainer/StatsContainer/DexterityLabel.text = "Dexterity: " + str(int(Global.dexterity))
	$VBoxContainer/StatsContainer/WisdomLabel.text = "Wisdom: " + str(int(Global.wisdom))
	$VBoxContainer/StatsContainer/IntelligenceLabel.text = "Intelligence: " + str(int(Global.intelligence))
	$VBoxContainer/StatsContainer/CharismaLabel.text = "Charisma: " + str(int(Global.charisma))

	# Apply mobile scaling if needed
	apply_mobile_scaling()

func apply_mobile_scaling():
	var viewport_size = get_viewport().get_visible_rect().size
	# Check if in portrait mode (taller than wide)
	if viewport_size.y > viewport_size.x:
		# Scale up text for mobile
		$VBoxContainer/VictoryTitle.add_theme_font_size_override("font_size", 48)
		$VBoxContainer/VictoryMessage.add_theme_font_size_override("font_size", 24)
		$VBoxContainer/StatsLabel.add_theme_font_size_override("font_size", 32)

		# Scale stat labels
		for child in $VBoxContainer/StatsContainer.get_children():
			if child is Label:
				child.add_theme_font_size_override("font_size", 22)

func _on_main_menu_button_pressed():
	# Return to intro screen or main menu
	# Adjust the path to your actual main menu scene
	get_tree().change_scene_to_file("res://level1/intro_screen.tscn")

func _on_quit_button_pressed():
	# Quit the game
	get_tree().quit()
