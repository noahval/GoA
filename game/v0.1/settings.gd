extends Control

const UI_SCALE_MIN = 0.8
const UI_SCALE_MAX = 1.2
const VOLUME_MIN = 0
const VOLUME_MAX = 100

@onready var ui_scale_slider = $Background/AspectContainer/MainContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/UIScaleContainer/UIScaleSlider
@onready var ui_scale_value = $Background/AspectContainer/MainContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/UIScaleContainer/UIScaleValueLabel
@onready var music_slider = $Background/AspectContainer/MainContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MusicVolumeContainer/MusicVolumeSlider
@onready var music_value = $Background/AspectContainer/MainContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MusicVolumeContainer/MusicVolumeValueLabel
@onready var sfx_slider = $Background/AspectContainer/MainContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SFXVolumeContainer/SFXVolumeSlider
@onready var sfx_value = $Background/AspectContainer/MainContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SFXVolumeContainer/SFXVolumeValueLabel
@onready var dev_speed_checkbox = $Background/AspectContainer/MainContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/DevSpeedContainer/DevSpeedCheckBox
@onready var save_reset_button = $Background/AspectContainer/MainContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SaveResetButton
@onready var back_button = $Background/AspectContainer/MainContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/BackButton

# Connection status UI (1.17.5-connection-ui.md)
@onready var connection_dot = $Background/AspectContainer/MainContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HeaderHBox/ConnectionStatus/ConnectionDot
@onready var connection_label = $Background/AspectContainer/MainContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HeaderHBox/ConnectionStatus/ConnectionLabel
@onready var retry_button = $Background/AspectContainer/MainContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HeaderHBox/ConnectionStatus/RetryButton
@onready var last_save_label = $Background/AspectContainer/MainContainer/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/LastSaveLabel

func _ready():
	ResponsiveLayout.apply_to_scene(self)

	# Load and validate current settings
	ui_scale_slider.min_value = UI_SCALE_MIN
	ui_scale_slider.max_value = UI_SCALE_MAX
	ui_scale_slider.step = 0.05
	ui_scale_slider.value = clampf(Global.ui_scale, UI_SCALE_MIN, UI_SCALE_MAX)

	music_slider.min_value = VOLUME_MIN
	music_slider.max_value = VOLUME_MAX
	music_slider.value = clampf(Global.music_volume * 100, VOLUME_MIN, VOLUME_MAX)

	sfx_slider.min_value = VOLUME_MIN
	sfx_slider.max_value = VOLUME_MAX
	sfx_slider.value = clampf(Global.sfx_volume * 100, VOLUME_MIN, VOLUME_MAX)

	dev_speed_checkbox.button_pressed = Global.dev_speed_mode

	update_value_labels()

	# Connect signals
	back_button.pressed.connect(_on_back_pressed)
	ui_scale_slider.value_changed.connect(_on_ui_scale_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	dev_speed_checkbox.toggled.connect(_on_dev_speed_toggled)
	save_reset_button.pressed.connect(_on_save_reset_pressed)

	# Connection status (1.17.5-connection-ui.md)
	NakamaManager.connection_lost.connect(_update_connection_display)
	NakamaManager.connection_restored.connect(_update_connection_display)
	retry_button.pressed.connect(_on_retry_pressed)
	_update_connection_display()


func _process(_delta):
	_update_last_save_display()

func _on_back_pressed():
	# Return to previous scene
	if Global.previous_scene.is_empty():
		push_error("No previous scene stored, cannot navigate back")
		return
	Global.change_scene(Global.previous_scene)

func _on_ui_scale_changed(value: float):
	var clamped_value = clampf(value, UI_SCALE_MIN, UI_SCALE_MAX)
	Global.ui_scale = clamped_value
	update_value_labels()
	Global.save()

	# Apply to current scene immediately
	ResponsiveLayout.apply_to_scene(self)

func _on_music_volume_changed(value: float):
	var clamped_value = clampf(value, VOLUME_MIN, VOLUME_MAX)
	Global.music_volume = clamped_value / 100.0
	update_value_labels()
	Global.save()

	# Apply audio change if AudioManager exists
	# TODO: Implement when AudioManager is added

func _on_sfx_volume_changed(value: float):
	var clamped_value = clampf(value, VOLUME_MIN, VOLUME_MAX)
	Global.sfx_volume = clamped_value / 100.0
	update_value_labels()
	Global.save()

	# Apply audio change if AudioManager exists
	# TODO: Implement when AudioManager is added

func _on_dev_speed_toggled(pressed: bool):
	Global.dev_speed_mode = pressed
	Global.save()

func _on_save_reset_pressed():
	# Confirmation dialog
	var confirm = ConfirmationDialog.new()
	confirm.dialog_text = "Reset all game progress? Settings will be preserved."
	confirm.confirmed.connect(_perform_save_reset)
	add_child(confirm)
	confirm.popup_centered()

func _perform_save_reset():
	Global.reset_save()
	# After reset, return to previous scene (which will reload)

func update_value_labels():
	ui_scale_value.text = "%d%%" % int(Global.ui_scale * 100)
	music_value.text = "%d%%" % int(Global.music_volume * 100)
	sfx_value.text = "%d%%" % int(Global.sfx_volume * 100)


# === CONNECTION STATUS (1.17.5-connection-ui.md) ===

func _update_connection_display():
	if not NakamaManager.is_authenticated:
		connection_dot.color = Color(1.0, 0.5, 0.0)  # Orange
		connection_label.text = "Not authenticated"
		retry_button.visible = false
		last_save_label.visible = false
	elif NakamaManager.is_connected:
		connection_dot.color = Color(0.2, 0.8, 0.3)  # Green
		connection_label.text = "Connected"
		retry_button.visible = false
		last_save_label.visible = true
	else:
		connection_dot.color = Color(1.0, 0.5, 0.0)  # Orange
		connection_label.text = "Disconnected"
		retry_button.visible = true
		last_save_label.visible = true


func _update_last_save_display():
	# Skip if not authenticated
	if not NakamaManager.is_authenticated:
		return

	if NakamaManager.last_successful_save_timestamp > 0:
		var elapsed = Time.get_unix_time_from_system() - NakamaManager.last_successful_save_timestamp
		var minutes = int(elapsed / 60)

		if minutes == 0:
			last_save_label.text = "Last saved: just now"
		elif minutes == 1:
			last_save_label.text = "Last saved: 1 minute ago"
		else:
			last_save_label.text = "Last saved: %d minutes ago" % minutes
	else:
		last_save_label.text = "Last saved: never"


func _on_retry_pressed():
	retry_button.text = "Retrying..."
	retry_button.disabled = true

	var success = await NakamaManager.save_game()

	retry_button.text = "Retry"
	retry_button.disabled = false

	# Update display (notification may not be available on settings scene)
	_update_connection_display()
