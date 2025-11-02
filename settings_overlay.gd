extends Control

@onready var settings_button = $SettingsButton
@onready var menu_overlay = $MenuOverlay
@onready var dev_speed_toggle = $MenuOverlay/VBoxContainer/DevSpeedToggle

func _ready():
	# Initialize the toggle button text based on current state
	_update_toggle_text()
	# Make sure overlay is hidden on start
	menu_overlay.visible = false
	# Set overlay opacity to 80%
	menu_overlay.modulate = Color(1, 1, 1, 0.8)
	# Apply responsive sizing
	_apply_responsive_sizing()

func _apply_responsive_sizing():
	var viewport_size = get_viewport().get_visible_rect().size
	var is_portrait = viewport_size.y > viewport_size.x

	# Make settings button larger on mobile
	if is_portrait or viewport_size.x < 800:
		# Larger button for mobile/portrait
		settings_button.offset_left = -80.0
		settings_button.offset_top = -80.0
		settings_button.offset_right = -10.0
		settings_button.offset_bottom = -10.0
		settings_button.add_theme_font_size_override("font_size", 40)

		# Larger menu overlay (25% bigger in portrait mode)
		menu_overlay.offset_left = -425.0
		menu_overlay.offset_top = -350.0
		menu_overlay.offset_right = -10.0
		menu_overlay.offset_bottom = -10.0

		# Make fonts 25% bigger in portrait mode (default_theme.tres base is 25)
		var base_font_size = 25  # Default font size from theme
		var scaled_font_size = int(base_font_size * 1.25)  # 25% bigger = 31
		for child in menu_overlay.get_node("VBoxContainer").get_children():
			if child is Label or child is Button:
				child.add_theme_font_size_override("font_size", scaled_font_size)
	else:
		# Desktop size
		settings_button.offset_left = -40.0
		settings_button.offset_top = -40.0
		settings_button.offset_right = -10.0
		settings_button.offset_bottom = -10.0
		settings_button.remove_theme_font_size_override("font_size")

		# Smaller menu overlay
		menu_overlay.offset_left = -310.0
		menu_overlay.offset_top = -210.0
		menu_overlay.offset_right = -10.0
		menu_overlay.offset_bottom = -10.0

		# Reset fonts to default size in desktop mode
		for child in menu_overlay.get_node("VBoxContainer").get_children():
			if child is Label or child is Button:
				child.remove_theme_font_size_override("font_size")

func _on_settings_button_pressed():
	# Toggle the menu overlay visibility
	menu_overlay.visible = !menu_overlay.visible

func _on_dev_speed_toggle_pressed():
	# Toggle the dev_speed_mode variable in Global
	Global.dev_speed_mode = !Global.dev_speed_mode
	# Update the button text to reflect the new state
	_update_toggle_text()

func _on_close_button_pressed():
	# Hide the menu overlay
	menu_overlay.visible = false

func _update_toggle_text():
	# Update button text based on Global.dev_speed_mode state
	if Global.dev_speed_mode:
		dev_speed_toggle.text = "Dev Speed Mode: ON"
	else:
		dev_speed_toggle.text = "Dev Speed Mode: OFF"
