extends Control

func _ready():
	ResponsiveLayout.apply_to_scene(self)
	connect_navigation()
	connect_settings_button()
	add_currency_display()

func add_currency_display():
	var currency_display = preload("res://ui/currency_display.tscn").instantiate()
	currency_display.currency_type = "copper"

	var menu = $AspectContainer/MainContainer/mainarea/Menu
	if menu:
		menu.add_child(currency_display)
		menu.move_child(currency_display, 0)

func connect_navigation():
	var to_dorm_button = $AspectContainer/MainContainer/mainarea/Menu/ToDormButton
	if to_dorm_button:
		to_dorm_button.pressed.connect(func(): navigate_to("dorm"))

func connect_settings_button():
	var settings_button = $AspectContainer/MainContainer/mainarea/Menu/SettingsButton
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)

func _on_settings_pressed():
	Global.previous_scene = scene_file_path
	Global.change_scene("res://settings.tscn")

func navigate_to(scene_id: String):
	var path = SceneNetwork.get_scene_path(scene_id)
	if path.is_empty():
		push_error("Unknown scene ID: " + scene_id)
		return
	Global.change_scene(path)
