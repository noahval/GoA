extends Control

func _ready():
	ResponsiveLayout.apply_to_scene(self)  # REQUIRED
	connect_navigation()
	connect_settings_button()

func connect_navigation():
	# Connect navigation buttons based on .mmd connections
	var to_bar_button = $AspectContainer/MainContainer/mainarea/Menu/ToBarButton
	if to_bar_button:
		to_bar_button.pressed.connect(func(): navigate_to("bar"))

	var to_carriage_button = $AspectContainer/MainContainer/mainarea/Menu/ToCarriageButton
	if to_carriage_button:
		to_carriage_button.pressed.connect(func(): navigate_to("coppersmith_carriage"))

	var to_mess_hall_button = $AspectContainer/MainContainer/mainarea/Menu/ToMessHallButton
	if to_mess_hall_button:
		to_mess_hall_button.pressed.connect(func(): navigate_to("mess_hall"))

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
