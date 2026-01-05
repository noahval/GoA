extends Control

@onready var sleep_button: Button = $AspectContainer/MainContainer/mainarea/Menu/SleepButton
@onready var play_area: Control = $AspectContainer/MainContainer/mainarea/PlayArea

# Hungry warning popup (created programmatically)
var hunger_warning_popup: PanelContainer = null

func _ready():
	ResponsiveLayout.apply_to_scene(self)  # REQUIRED
	connect_navigation()
	connect_settings_button()
	add_currency_display()
	connect_sleep_button()

func add_currency_display():
	# Create currency display for testing (Plan 1.27)
	var currency_display = preload("res://ui/currency_display.tscn").instantiate()
	currency_display.currency_type = "copper"

	# Add to menu at the top
	var menu = $AspectContainer/MainContainer/mainarea/Menu
	if menu:
		menu.add_child(currency_display)
		menu.move_child(currency_display, 0)  # Move to top of menu

func connect_navigation():
	# Connect navigation buttons based on .mmd connections
	var to_bar_button = $AspectContainer/MainContainer/mainarea/Menu/ToBarButton
	if to_bar_button:
		to_bar_button.pressed.connect(func(): navigate_to("bar"))

	var to_carriage_button = $AspectContainer/MainContainer/mainarea/Menu/ToCarriageButton
	if to_carriage_button:
		to_carriage_button.pressed.connect(func(): navigate_to("coppersmith"))

	var to_mess_hall_button = $AspectContainer/MainContainer/mainarea/Menu/ToMessHallButton
	if to_mess_hall_button:
		to_mess_hall_button.pressed.connect(func(): navigate_to("mess"))

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

func connect_sleep_button():
	if sleep_button:
		sleep_button.pressed.connect(_on_sleep_pressed)

func _on_sleep_pressed():
	# Check if player is hungry and hasn't dismissed the warning yet
	if Level1Vars.hungry and not Level1Vars.hunger_skip:
		show_hunger_warning_popup()
		return

	# Proceed with sleep
	do_sleep()

func do_sleep():
	# Restore some stamina from rest using tuneable value
	Level1Vars.modify_stamina(Level1Vars.stamina_restore_sleeping)

	# Perform daily reset (centralized in Level1Vars)
	Level1Vars.perform_daily_reset()

	# Transition to dream scene
	Global.change_scene("res://level1/dream.tscn")

func show_hunger_warning_popup():
	# Create popup if not already created
	if hunger_warning_popup:
		hunger_warning_popup.visible = true
		return

	# Create panel container
	hunger_warning_popup = PanelContainer.new()
	hunger_warning_popup.name = "HungerWarningPopup"

	# Style the panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.12, 0.1, 0.95)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.6, 0.4, 0.2)
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.content_margin_left = 20
	panel_style.content_margin_right = 20
	panel_style.content_margin_top = 20
	panel_style.content_margin_bottom = 20
	hunger_warning_popup.add_theme_stylebox_override("panel", panel_style)

	# Create content container
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)

	# Warning title
	var title = Label.new()
	title.text = "You're Hungry"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)

	# Warning message
	var message = Label.new()
	message.text = "Going to sleep hungry means you won't\nbe as effective at shoveling tomorrow.\n\nGo to the mess hall to eat first."
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(message)

	# OK button
	var ok_button = Button.new()
	ok_button.text = "OK"
	ok_button.custom_minimum_size = Vector2(100, 40)
	ok_button.pressed.connect(_on_hunger_warning_ok)

	# Center button
	var button_container = HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	button_container.add_child(ok_button)
	vbox.add_child(button_container)

	hunger_warning_popup.add_child(vbox)

	# Add to play area and center it
	play_area.add_child(hunger_warning_popup)

	# Center popup in play area (defer to allow size calculation)
	await get_tree().process_frame
	hunger_warning_popup.position = (play_area.size - hunger_warning_popup.size) / 2

func _on_hunger_warning_ok():
	# Set skip flag so player can sleep if they want
	Level1Vars.hunger_skip = true

	# Hide popup
	if hunger_warning_popup:
		hunger_warning_popup.visible = false
