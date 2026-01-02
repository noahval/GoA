extends Control

@onready var wake_button: Button = $AspectContainer/MainContainer/mainarea/Menu/WakeButton

func _ready():
	ResponsiveLayout.apply_to_scene(self)
	connect_settings_button()
	connect_wake_button()

func connect_settings_button():
	var settings_button = $AspectContainer/MainContainer/mainarea/Menu/SettingsButton
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)

func _on_settings_pressed():
	Global.previous_scene = scene_file_path
	Global.change_scene("res://settings.tscn")

func connect_wake_button():
	if wake_button:
		wake_button.pressed.connect(_on_wake_pressed)

func _on_wake_pressed():
	# Transition to furnace scene for new work day
	Global.change_scene("res://level1/furnace.tscn")
