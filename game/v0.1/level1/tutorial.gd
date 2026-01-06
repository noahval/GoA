extends Control

func _ready():
	ResponsiveLayout.apply_to_scene(self)  # REQUIRED
	connect_settings_button()
	connect_ok_button()
	load_background()

func connect_settings_button():
	var settings_button = $AspectContainer/MainContainer/mainarea/Menu/SettingsButton
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)

func _on_settings_pressed():
	# Store current scene for return navigation
	Global.previous_scene = scene_file_path
	Global.change_scene("res://settings.tscn")

func connect_ok_button():
	var ok_button = $AspectContainer/MainContainer/mainarea/Menu/OkButton
	if ok_button:
		ok_button.pressed.connect(_on_ok_pressed)

func _on_ok_pressed():
	# Mark tutorial as completed
	Level1Vars.tutorial_completed = true

	# Navigate to furnace
	get_tree().change_scene_to_file("res://level1/furnace.tscn")

func load_background():
	var background = $AspectContainer/MainContainer/Background
	if background:
		var texture = load("res://level1/backgrounds/tutorial.png")
		if texture:
			background.texture = texture
