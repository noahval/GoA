extends Control

func _ready():
	ResponsiveLayout.apply_to_scene(self)  # REQUIRED
	connect_navigation()
	connect_settings_button()

func connect_navigation():
	# Connect Back Nav button to return to Furnace
	var to_furnace_button = $AspectContainer/MainContainer/mainarea/Menu/ToFurnaceButton
	if to_furnace_button:
		to_furnace_button.pressed.connect(func(): navigate_to("furnace"))

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
