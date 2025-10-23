extends Control

func _ready():
	# Apply mobile scaling if needed
	apply_mobile_scaling()

func apply_mobile_scaling():
	var viewport_size = get_viewport().get_visible_rect().size
	# Check if in portrait mode (taller than wide)
	if viewport_size.y > viewport_size.x:
		# Scale up text for mobile
		if has_node("VBoxContainer/VictoryTitle"):
			$VBoxContainer/VictoryTitle.add_theme_font_size_override("font_size", 48)
		if has_node("VBoxContainer/VictoryMessage"):
			$VBoxContainer/VictoryMessage.add_theme_font_size_override("font_size", 24)
		if has_node("VBoxContainer/StatsLabel"):
			$VBoxContainer/StatsLabel.add_theme_font_size_override("font_size", 32)

		# Scale stat labels if they exist
		if has_node("VBoxContainer/StatsContainer"):
			for child in $VBoxContainer/StatsContainer.get_children():
				if child is Label:
					child.add_theme_font_size_override("font_size", 22)
