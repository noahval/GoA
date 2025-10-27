extends Control

var break_time = 30.0
var max_break_time = 30.0

@onready var anthracite_delight_button = $HBoxContainer/RightVBox/AnthraciteDelightButton
@onready var bribe_barkeep_button = $HBoxContainer/RightVBox/BribeBarkeepButton
@onready var secret_passage_button = $HBoxContainer/RightVBox/SecretPassageButton
@onready var developer_free_coins_button = $HBoxContainer/RightVBox/DeveloperFreeCoinsButton
@onready var follow_voice_button = $HBoxContainer/RightVBox/FollowVoiceButton
@onready var break_timer_bar = $HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimerBar
@onready var break_timer_label = $HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimer
@onready var coins_label = $HBoxContainer/LeftVBox/CoinsPanel/CoinsLabel
@onready var voice_popup = $PopupContainer/VoicePopup
@onready var barkeep_popup = $PopupContainer/BarkeepPopup

func _ready():
	# Set the actual maximum break time
	max_break_time = Level1Vars.starting_break_time + Level1Vars.overseer_lvl

	if Level1Vars.break_time_remaining > 0:
		break_time = Level1Vars.break_time_remaining
	else:
		break_time = max_break_time

	# Initialize the progress bar
	if break_timer_bar:
		var progress_percent = (break_time / max_break_time) * 100.0
		break_timer_bar.value = progress_percent

	# Show bribe barkeep button if door has been discovered and not yet bribed
	if bribe_barkeep_button:
		bribe_barkeep_button.visible = Level1Vars.door_discovered and not Level1Vars.barkeep_bribed

	# Hide follow voice button if door has already been discovered
	if follow_voice_button:
		follow_voice_button.visible = false

	# Setup popups with messages and buttons
	if voice_popup:
		voice_popup.setup(
			"The voice was coming from further up the train. There's a small door behind the bar that leads ahead.",
			["enter door", "turn back"]
		)
		voice_popup.hide_popup()

	if barkeep_popup:
		barkeep_popup.setup(
			"The barkeep sees you. He says \"That's a restricted area, I can't let you pass, although I could be convinced to turn a blind eye...\"",
			["Ok"]
		)
		barkeep_popup.hide_popup()

	# Use ResponsiveLayout for all orientation handling
	ResponsiveLayout.apply_to_scene(self)

	# CRITICAL FIX: Hide PopupContainer when no popups are showing
	# PopupContainer has z_index:100 and was blocking all button clicks even with mouse_filter=PASS
	var popup_container = get_node_or_null("PopupContainer")
	if popup_container:
		var any_popup_visible = false
		for child in popup_container.get_children():
			if child is Control and child.visible:
				any_popup_visible = true
				break

		if not any_popup_visible:
			popup_container.visible = false

	# CRITICAL: Reconnect button signals after ResponsiveLayout may have reparented them
	call_deferred("_reconnect_button_signals")

	update_labels()

	# Debug: Print button states after layout (can remove this later)
	call_deferred("_debug_button_states")


func _process(delta):
	break_time -= delta
	Level1Vars.break_time_remaining = break_time

	# Update progress bar
	if break_timer_bar:
		var progress_percent = (break_time / max_break_time) * 100.0
		break_timer_bar.value = progress_percent

	# Update timer label
	if break_timer_label:
		break_timer_label.text = "Break Timer"

	# Show follow voice button if whisper has triggered (or dev mode) and door hasn't been discovered yet
	if follow_voice_button and not Level1Vars.door_discovered and (Level1Vars.whisper_triggered or Global.dev_speed_mode):
		follow_voice_button.visible = true

	if break_time <= 0:
		Level1Vars.break_time_remaining = 0.0
		Global.change_scene_with_check(get_tree(), "res://level1/furnace.tscn")

func _on_to_blackbore_furnace_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/furnace.tscn")

func _on_to_coppersmith_carriage_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/coppersmith_carriage.tscn")

func _on_bribe_barkeep_pressed():
	if Level1Vars.coins >= 50 and not Level1Vars.barkeep_bribed:
		Level1Vars.coins -= 50
		Level1Vars.barkeep_bribed = true
		update_labels()

func _on_secret_passage_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/secret_passage_entrance.tscn")

func _on_anthracite_delight_pressed():
	if Level1Vars.coins >= 1:
		Level1Vars.coins -= 1
		Level1Vars.stimulated_remaining += 60
		Level1Vars.shown_tired_notification = false  # Reset the flag for next time
		Global.show_stat_notification("You feel invigorated")
		update_labels()

func _on_steel_stout_pressed():
	if Level1Vars.coins >= 1:
		Level1Vars.coins -= 1
		Level1Vars.resilient_remaining += 60
		Level1Vars.shown_lazy_notification = false  # Reset the flag for next time
		Global.show_stat_notification("You feel tenacious")
		update_labels()

func _on_developer_free_coins_button_pressed():
	Level1Vars.coins += 200
	update_labels()

func update_labels():
	# Update coins display
	if coins_label:
		coins_label.text = "Coins: " + str(int(Level1Vars.coins))

	if bribe_barkeep_button:
		bribe_barkeep_button.text = "Bribe Barkeep: 50"

	# Show/hide developer button based on dev_speed_mode
	if developer_free_coins_button:
		developer_free_coins_button.visible = Global.dev_speed_mode

	# Show bribe barkeep button if door discovered and not yet bribed
	if bribe_barkeep_button:
		bribe_barkeep_button.visible = Level1Vars.door_discovered and not Level1Vars.barkeep_bribed

	# Show secret passage button only if barkeep was bribed
	if secret_passage_button:
		secret_passage_button.visible = Level1Vars.barkeep_bribed

func _on_follow_voice_button_pressed():
	# Show the voice popup
	if voice_popup:
		# Make PopupContainer visible when showing a popup
		var popup_container = get_node_or_null("PopupContainer")
		if popup_container:
			popup_container.visible = true
		voice_popup.show_popup()

func _on_voice_popup_button_pressed(button_text: String):
	if button_text == "enter door":
		# Show the barkeep popup
		if barkeep_popup:
			# Make PopupContainer visible when showing a popup
			var popup_container = get_node_or_null("PopupContainer")
			if popup_container:
				popup_container.visible = true
			barkeep_popup.show_popup()
	elif button_text == "turn back":
		# Popup automatically closes, hide PopupContainer since we're done
		var popup_container = get_node_or_null("PopupContainer")
		if popup_container:
			popup_container.visible = false

func _on_barkeep_popup_button_pressed(button_text: String):
	if button_text == "Ok":
		# Set door discovered flag
		Level1Vars.door_discovered = true

		# Make bribe barkeep button visible and hide follow voice button
		if bribe_barkeep_button:
			bribe_barkeep_button.visible = true
		if follow_voice_button:
			follow_voice_button.visible = false

		# CRITICAL: Hide PopupContainer now that popup sequence is complete
		# This allows buttons to be clickable again in portrait mode
		var popup_container = get_node_or_null("PopupContainer")
		if popup_container:
			popup_container.visible = false

func _reconnect_button_signals():
	print("=== RECONNECTING BUTTON SIGNALS ===")

	# Find buttons in their current location (might be portrait or landscape)
	var button_container = null
	var is_portrait = get_viewport().get_visible_rect().size.y > get_viewport().get_visible_rect().size.x

	if has_node("VBoxContainer/BottomVBox/RightVBox"):
		button_container = $"VBoxContainer/BottomVBox/RightVBox"
		print("Found buttons in portrait location")
	elif has_node("HBoxContainer/RightVBox"):
		button_container = $"HBoxContainer/RightVBox"
		print("Found buttons in landscape location")

	if not button_container:
		print("ERROR: Could not find button container!")
		return

	# CRITICAL: Manually force button container and buttons to full width in portrait
	var viewport_size = get_viewport().get_visible_rect().size
	print("DEBUG: is_portrait=", is_portrait, " viewport_size=", viewport_size)
	if is_portrait:
		var viewport_width = viewport_size.x
		print("FORCING portrait button widths to viewport width: ", viewport_width)

		# Force container to full width
		button_container.custom_minimum_size.x = viewport_width
		button_container.size.x = viewport_width

		# Force each button to full width
		for child in button_container.get_children():
			if child is Button:
				child.custom_minimum_size.x = viewport_width
				child.size.x = viewport_width

		print("Set button container width to: ", button_container.size)

	# Disconnect old signals if they exist and reconnect to current button locations
	var anthracite_btn = button_container.get_node_or_null("AnthraciteDelightButton")
	if anthracite_btn:
		if anthracite_btn.pressed.is_connected(_on_anthracite_delight_pressed):
			anthracite_btn.pressed.disconnect(_on_anthracite_delight_pressed)
		anthracite_btn.pressed.connect(_on_anthracite_delight_pressed)
		print("Reconnected AnthraciteDelightButton")

	var steel_btn = button_container.get_node_or_null("SteelStoutButton")
	if steel_btn:
		if steel_btn.pressed.is_connected(_on_steel_stout_pressed):
			steel_btn.pressed.disconnect(_on_steel_stout_pressed)
		steel_btn.pressed.connect(_on_steel_stout_pressed)
		print("Reconnected SteelStoutButton")

	var bribe_btn = button_container.get_node_or_null("BribeBarkeepButton")
	if bribe_btn:
		if bribe_btn.pressed.is_connected(_on_bribe_barkeep_pressed):
			bribe_btn.pressed.disconnect(_on_bribe_barkeep_pressed)
		bribe_btn.pressed.connect(_on_bribe_barkeep_pressed)
		print("Reconnected BribeBarkeepButton")

	var secret_btn = button_container.get_node_or_null("SecretPassageButton")
	if secret_btn:
		if secret_btn.pressed.is_connected(_on_secret_passage_pressed):
			secret_btn.pressed.disconnect(_on_secret_passage_pressed)
		secret_btn.pressed.connect(_on_secret_passage_pressed)
		print("Reconnected SecretPassageButton")

	var dev_btn = button_container.get_node_or_null("DeveloperFreeCoinsButton")
	if dev_btn:
		if dev_btn.pressed.is_connected(_on_developer_free_coins_button_pressed):
			dev_btn.pressed.disconnect(_on_developer_free_coins_button_pressed)
		dev_btn.pressed.connect(_on_developer_free_coins_button_pressed)
		print("Reconnected DeveloperFreeCoinsButton")

	var follow_btn = button_container.get_node_or_null("FollowVoiceButton")
	if follow_btn:
		if follow_btn.pressed.is_connected(_on_follow_voice_button_pressed):
			follow_btn.pressed.disconnect(_on_follow_voice_button_pressed)
		follow_btn.pressed.connect(_on_follow_voice_button_pressed)
		print("Reconnected FollowVoiceButton")

	var furnace_btn = button_container.get_node_or_null("ToBlackboreFurnaceButton")
	if furnace_btn:
		if furnace_btn.pressed.is_connected(_on_to_blackbore_furnace_button_pressed):
			furnace_btn.pressed.disconnect(_on_to_blackbore_furnace_button_pressed)
		furnace_btn.pressed.connect(_on_to_blackbore_furnace_button_pressed)
		print("Reconnected ToBlackboreFurnaceButton")

	var carriage_btn = button_container.get_node_or_null("ToCoppersmithCarriageButton")
	if carriage_btn:
		if carriage_btn.pressed.is_connected(_on_to_coppersmith_carriage_button_pressed):
			carriage_btn.pressed.disconnect(_on_to_coppersmith_carriage_button_pressed)
		carriage_btn.pressed.connect(_on_to_coppersmith_carriage_button_pressed)
		print("Reconnected ToCoppersmithCarriageButton")

func _debug_button_states():
	print("=== BAR SCENE DEBUG ===")
	var viewport_size = get_viewport().get_visible_rect().size
	print("Viewport size: ", viewport_size)
	print("Is portrait: ", viewport_size.y > viewport_size.x)

	# Check which container is visible
	if has_node("HBoxContainer"):
		var hbox = $HBoxContainer
		print("HBoxContainer visible: ", hbox.visible)
		print("HBoxContainer mouse_filter: ", hbox.mouse_filter)

	if has_node("VBoxContainer"):
		var vbox = $VBoxContainer
		print("VBoxContainer visible: ", vbox.visible)
		print("VBoxContainer mouse_filter: ", vbox.mouse_filter)
		print("VBoxContainer global_position: ", vbox.global_position)
		print("VBoxContainer size: ", vbox.size)

	# In portrait mode, buttons are in VBoxContainer/BottomVBox/RightVBox
	var button_container = null
	if has_node("VBoxContainer/BottomVBox/RightVBox"):
		button_container = $"VBoxContainer/BottomVBox/RightVBox"
		print("\n=== PORTRAIT MODE - Buttons in BottomVBox ===")
	elif has_node("HBoxContainer/RightVBox"):
		button_container = $HBoxContainer/RightVBox
		print("\n=== LANDSCAPE MODE - Buttons in HBoxContainer ===")

	if button_container:
		print("Button container path: ", button_container.get_path())
		print("Button container visible: ", button_container.visible)
		print("Button container mouse_filter: ", button_container.mouse_filter)
		print("Button container global_position: ", button_container.global_position)
		print("Button container size: ", button_container.size)

		# Check parent chain
		var parent = button_container.get_parent()
		print("\nParent chain:")
		while parent:
			var filter_text = str(parent.mouse_filter) if parent is Control else "N/A"
			print("  ", parent.name, " - visible: ", parent.visible if parent is CanvasItem else "N/A", ", mouse_filter: ", filter_text)
			parent = parent.get_parent()

		print("\nButton count: ", button_container.get_child_count())
		for i in range(button_container.get_child_count()):
			var child = button_container.get_child(i)
			if child is Button:
				print("  Button ", i, ": ", child.name)
				print("    text: ", child.text)
				print("    visible: ", child.visible)
				print("    disabled: ", child.disabled)
				print("    mouse_filter: ", child.mouse_filter)
				print("    global_position: ", child.global_position)
				print("    size: ", child.size)

	# Check for any nodes that might be on top
	print("\n=== Checking z_index values ===")
	for child in get_children():
		print("  ", child.name, " - z_index: ", child.z_index if "z_index" in child else "N/A")
