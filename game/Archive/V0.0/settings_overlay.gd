extends Control

# Confirmation state enum
enum ConfirmationState {
	NONE,
	FIRST_CONFIRM,
	SECOND_CONFIRM
}

@onready var settings_button = $SettingsButton
@onready var menu_overlay = $MenuOverlay
@onready var dev_speed_toggle = $MenuOverlay/VBoxContainer/DevSpeedToggle
@onready var reset_save_button = $MenuOverlay/VBoxContainer/ResetSaveButton
@onready var confirmation_container = $MenuOverlay/VBoxContainer/ConfirmationContainer
@onready var confirmation_label = $MenuOverlay/VBoxContainer/ConfirmationContainer/ConfirmationLabel
@onready var button_container = $MenuOverlay/VBoxContainer/ConfirmationContainer/ButtonContainer
@onready var confirm_yes_button = $MenuOverlay/VBoxContainer/ConfirmationContainer/ButtonContainer/ConfirmYesButton
@onready var confirm_no_button = $MenuOverlay/VBoxContainer/ConfirmationContainer/ButtonContainer/ConfirmNoButton
@onready var close_button = $MenuOverlay/VBoxContainer/CloseButton

# Current confirmation state
var current_confirmation_state: ConfirmationState = ConfirmationState.NONE

func _ready():
	# Initialize the toggle button text based on current state
	_update_toggle_text()
	# Make sure overlay is hidden on start
	menu_overlay.visible = false
	# Set overlay opacity to 80%
	menu_overlay.modulate = Color(1, 1, 1, 0.8)
	# Apply responsive sizing
	_apply_responsive_sizing()

func _apply_responsive_sizing():
	var viewport_size = get_viewport().get_visible_rect().size
	var is_portrait = viewport_size.y > viewport_size.x

	# Make settings button larger on mobile
	if is_portrait or viewport_size.x < 800:
		# Larger button for mobile/portrait
		settings_button.offset_left = -80.0
		settings_button.offset_top = -80.0
		settings_button.offset_right = -10.0
		settings_button.offset_bottom = -10.0
		settings_button.add_theme_font_size_override("font_size", 40)

		# Larger menu overlay (25% bigger in portrait mode)
		menu_overlay.offset_left = -425.0
		menu_overlay.offset_top = -350.0
		menu_overlay.offset_right = -10.0
		menu_overlay.offset_bottom = -10.0

		# Make fonts 25% bigger in portrait mode (default_theme.tres base is 25)
		var base_font_size = 25  # Default font size from theme
		var scaled_font_size = int(base_font_size * 1.25)  # 25% bigger = 31
		for child in menu_overlay.get_node("VBoxContainer").get_children():
			if child is Label or child is Button:
				child.add_theme_font_size_override("font_size", scaled_font_size)
	else:
		# Desktop size
		settings_button.offset_left = -40.0
		settings_button.offset_top = -40.0
		settings_button.offset_right = -10.0
		settings_button.offset_bottom = -10.0
		settings_button.remove_theme_font_size_override("font_size")

		# Smaller menu overlay
		menu_overlay.offset_left = -310.0
		menu_overlay.offset_top = -210.0
		menu_overlay.offset_right = -10.0
		menu_overlay.offset_bottom = -10.0

		# Reset fonts to default size in desktop mode
		for child in menu_overlay.get_node("VBoxContainer").get_children():
			if child is Label or child is Button:
				child.remove_theme_font_size_override("font_size")

func _on_settings_button_pressed():
	# Toggle the menu overlay visibility
	menu_overlay.visible = !menu_overlay.visible

func _on_dev_speed_toggle_pressed():
	# Toggle the dev_speed_mode variable in Global
	Global.dev_speed_mode = !Global.dev_speed_mode
	# Update the button text to reflect the new state
	_update_toggle_text()
	# Close the settings overlay
	menu_overlay.visible = false

func _on_close_button_pressed():
	# Hide the menu overlay
	menu_overlay.visible = false

func _update_toggle_text():
	# Update button text based on Global.dev_speed_mode state
	if Global.dev_speed_mode:
		dev_speed_toggle.text = "Dev Speed Mode: ON"
	else:
		dev_speed_toggle.text = "Dev Speed Mode: OFF"

func _on_reset_save_button_pressed():
	# Show confirmation UI
	current_confirmation_state = ConfirmationState.FIRST_CONFIRM
	confirmation_label.text = "Are you sure?"

	# First confirmation: Yes (left, blue) | No (right, orange)
	button_container.move_child(confirm_yes_button, 0)  # Move Yes to left
	button_container.move_child(confirm_no_button, 1)  # Move No to right
	confirm_yes_button.modulate = Color(0.3, 0.6, 1.0)  # Blue
	confirm_no_button.modulate = Color(1.0, 0.6, 0.3)  # Orange

	# Hide normal menu items, show confirmation
	reset_save_button.visible = false
	dev_speed_toggle.visible = false
	close_button.visible = false
	confirmation_container.visible = true

func _on_confirm_yes_pressed():
	if current_confirmation_state == ConfirmationState.FIRST_CONFIRM:
		# Move to second confirmation
		current_confirmation_state = ConfirmationState.SECOND_CONFIRM
		confirmation_label.text = "Are you still sure?"

		# Second confirmation: No (left, orange) | Yes (right, blue)
		button_container.move_child(confirm_no_button, 0)  # Move No to left
		button_container.move_child(confirm_yes_button, 1)  # Move Yes to right
		confirm_no_button.modulate = Color(1.0, 0.6, 0.3)  # Orange
		confirm_yes_button.modulate = Color(0.3, 0.6, 1.0)  # Blue

	elif current_confirmation_state == ConfirmationState.SECOND_CONFIRM:
		# Perform the reset
		_perform_save_reset()

func _on_confirm_no_pressed():
	# Hide confirmation UI, restore normal menu
	_hide_confirmation_ui()
	# Close the overlay
	menu_overlay.visible = false

func _hide_confirmation_ui():
	# Hide confirmation, show normal menu items
	confirmation_container.visible = false
	reset_save_button.visible = true
	dev_speed_toggle.visible = true
	close_button.visible = true
	current_confirmation_state = ConfirmationState.NONE

func _perform_save_reset():
	# 1. Delete local save file
	LocalSaveManager.delete_save()

	# 2. Delete cloud save (if authenticated)
	if NakamaManager.is_authenticated:
		# Create the storage object ID for deletion
		var storage_delete = NakamaStorageObjectId.new("player_data", "game_save", NakamaManager.user_id)

		# Delete from Nakama storage (async)
		await NakamaManager.client.delete_storage_objects_async(
			NakamaManager.session,
			[storage_delete]
		)

		# Clear authentication session
		NakamaManager.is_authenticated = false
		NakamaManager.session = null
		NakamaManager.user_id = ""
		NakamaManager.username = ""

		# Disconnect socket if it exists
		if NakamaManager.socket:
			NakamaManager.socket.close()

	# 3. Reset all game state (autoloads persist across scene changes)
	Global.reset_all()
	Level1Vars.reset_all()

	# 4. Reload to loading screen
	get_tree().change_scene_to_file("res://level1/loading_screen.tscn")
