extends Control

func _ready():
	ResponsiveLayout.apply_to_scene(self)  # REQUIRED
	connect_navigation()
	connect_settings_button()
	add_currency_display()

func add_currency_display():
	# Create multi-currency display showing copper, holes, weeps (Plan 1.26)
	var multi_display = preload("res://ui/multi_currency_display.tscn").instantiate()
	multi_display.show_zero = true  # Show all 3 even if 0

	# Add to menu at the top
	var menu = $AspectContainer/MainContainer/mainarea/Menu
	if menu:
		menu.add_child(multi_display)
		menu.move_child(multi_display, 0)  # Move to top of menu

func connect_navigation():
	# Connect navigation buttons based on .mmd connections
	var to_bar_button = $AspectContainer/MainContainer/mainarea/Menu/ToBarButton
	if to_bar_button:
		to_bar_button.pressed.connect(func(): navigate_to("bar"))

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
