extends Control

@onready var stamina_bar: ProgressBar = $AspectContainer/MainContainer/mainarea/Menu/StaminaBar
@onready var eat_rations_button: Button = $AspectContainer/MainContainer/mainarea/Menu/EatRationsButton

func _ready():
	ResponsiveLayout.apply_to_scene(self)
	connect_navigation()
	connect_settings_button()
	add_currency_display()
	connect_stamina_bar()
	connect_eat_button()

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

func connect_stamina_bar():
	# Connect to Level1Vars signal (same pattern as furnace.gd)
	Level1Vars.stamina_changed.connect(_on_stamina_changed)

	# Initialize with current values
	_on_stamina_changed(Level1Vars.stamina, Level1Vars.stamina_max)

func _on_stamina_changed(new_value: float, max_value: float):
	if stamina_bar:
		stamina_bar.max_value = max_value
		stamina_bar.value = new_value

func connect_eat_button():
	if eat_rations_button:
		eat_rations_button.pressed.connect(_on_eat_rations_pressed)
		# Connect to hunger signal for visibility updates
		Level1Vars.hunger_changed.connect(_on_hunger_changed)
		# Set initial visibility based on hunger state
		_update_eat_button_visibility()

func _update_eat_button_visibility():
	# Show button only when hungry
	if eat_rations_button:
		eat_rations_button.visible = Level1Vars.hungry

func _on_hunger_changed(_is_hungry: bool):
	_update_eat_button_visibility()

func _on_eat_rations_pressed():
	if not Level1Vars.hungry:
		return  # Guard clause (shouldn't happen since button hidden)

	# Restore stamina using tuneable value
	Level1Vars.modify_stamina(Level1Vars.stamina_restore_eating)

	# Clear hunger
	Level1Vars.hungry = false
	Level1Vars.hunger_changed.emit(false)

	# Show notification
	if Global.has_method("show_notification"):
		Global.show_notification("You ate a hearty meal. +%.0f stamina" % Level1Vars.stamina_restore_eating)

func _exit_tree():
	# Disconnect signals to prevent accumulation on repeated visits
	if Level1Vars.stamina_changed.is_connected(_on_stamina_changed):
		Level1Vars.stamina_changed.disconnect(_on_stamina_changed)
	if Level1Vars.hunger_changed.is_connected(_on_hunger_changed):
		Level1Vars.hunger_changed.disconnect(_on_hunger_changed)
