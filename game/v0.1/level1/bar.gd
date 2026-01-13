extends Control

# Dishwash minigame references (use scene-unique names)
@onready var wash_mugs_button: Button = %WashMugsButton
@onready var stop_washing_button: Button = %StopWashingButton
@onready var dishwash_minigame = $AspectContainer/MainContainer/mainarea/PlayArea/DishwashMinigame

func _ready():
	ResponsiveLayout.apply_to_scene(self)  # REQUIRED
	connect_navigation()
	connect_settings_button()
	connect_dishwash_buttons()
	add_currency_display()

func add_currency_display():
	# Create currency display (Plan 1.27)
	var currency_display = preload("res://ui/currency_display.tscn").instantiate()
	currency_display.currency_type = "copper"

	# Add to menu at the top
	var menu = $AspectContainer/MainContainer/mainarea/Menu
	if menu:
		menu.add_child(currency_display)
		menu.move_child(currency_display, 0)  # Move to top of menu

	# Also add holes display for dishwash earnings
	var holes_display = preload("res://ui/currency_display.tscn").instantiate()
	holes_display.currency_type = "holes"
	if menu:
		menu.add_child(holes_display)
		menu.move_child(holes_display, 1)  # After copper

func connect_navigation():
	# Connect navigation buttons based on .mmd connections
	var to_gambling_button = $AspectContainer/MainContainer/mainarea/Menu/ToGamblingButton
	if to_gambling_button:
		to_gambling_button.pressed.connect(func(): navigate_to("gambling"))

	var to_dorm_button = $AspectContainer/MainContainer/mainarea/Menu/ToDormButton
	if to_dorm_button:
		to_dorm_button.pressed.connect(func(): navigate_to("dorm"))

func connect_settings_button():
	var settings_button = $AspectContainer/MainContainer/mainarea/Menu/SettingsButton
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)

func connect_dishwash_buttons():
	if wash_mugs_button:
		wash_mugs_button.pressed.connect(_on_wash_mugs_pressed)
	if stop_washing_button:
		stop_washing_button.pressed.connect(_on_stop_washing_pressed)

func _on_wash_mugs_pressed():
	if dishwash_minigame:
		dishwash_minigame.start_washing()
		wash_mugs_button.disabled = true
		stop_washing_button.visible = true

func _on_stop_washing_pressed():
	if dishwash_minigame:
		dishwash_minigame.stop_washing()
		wash_mugs_button.disabled = false
		stop_washing_button.visible = false

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
