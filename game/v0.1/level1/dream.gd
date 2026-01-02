extends Control

func _ready():
	ResponsiveLayout.apply_to_scene(self)
	connect_settings_button()

func connect_settings_button():
	var settings_button = $AspectContainer/MainContainer/mainarea/Menu/SettingsButton
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)

func _on_settings_pressed():
	Global.previous_scene = scene_file_path
	Global.change_scene("res://settings.tscn")
