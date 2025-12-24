extends Control

func _ready():
	ResponsiveLayout.apply_to_scene(self)  # REQUIRED
	connect_navigation()
	connect_settings_button()
	add_currency_display()

func add_currency_display():
	# Create currency display for copper (has "c" indicator in .mmd)
	var currency_display = preload("res://ui/currency_display.tscn").instantiate()
	currency_display.currency_type = "copper"

	# Add to menu at the top
	var menu = $AspectContainer/MainContainer/mainarea/Menu
	if menu:
		menu.add_child(currency_display)
		menu.move_child(currency_display, 0)  # Move to top of menu

func connect_navigation():
	# Forward Nav buttons
	var to_crankshafts_button = $AspectContainer/MainContainer/mainarea/Menu/ToCrankshaftsButton
	if to_crankshafts_button:
		to_crankshafts_button.pressed.connect(func(): navigate_to("crankshafts"))

	var to_office_button = $AspectContainer/MainContainer/mainarea/Menu/ToOfficeButton
	if to_office_button:
		to_office_button.pressed.connect(func(): navigate_to("office"))

	var to_frayed_end_button = $AspectContainer/MainContainer/mainarea/Menu/ToFrayedEndButton
	if to_frayed_end_button:
		to_frayed_end_button.pressed.connect(func(): navigate_to("frayed_end"))

	# Back Nav button
	var to_dorm_button = $AspectContainer/MainContainer/mainarea/Menu/ToDormButton
	if to_dorm_button:
		to_dorm_button.pressed.connect(func(): navigate_to("dorm"))

func connect_settings_button():
	var settings_button = $AspectContainer/MainContainer/mainarea/Menu/SettingsButton
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)

func _on_settings_pressed():
	# Store current scene for return navigation
	Global.previous_scene = scene_file_path
	Global.change_scene("res://settings.tscn")

func navigate_to(scene_id: String):
	var path = SceneNetwork.get_scene_path(scene_id)
	if path.is_empty():
		push_error("Unknown scene ID: " + scene_id)
		return
	Global.change_scene(path)
