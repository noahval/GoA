extends PanelContainer

# Unsaved progress warning popup (1.17.5-connection-ui.md)
# Shown when player tries to quit while disconnected from cloud

signal reconnect_pressed
signal close_anyway_pressed

@onready var message_label = $MarginContainer/VBoxContainer/MessageLabel
@onready var reconnect_button = $MarginContainer/VBoxContainer/ButtonHBox/ReconnectButton
@onready var close_anyway_button = $MarginContainer/VBoxContainer/ButtonHBox/CloseAnywayButton


func _ready():
	reconnect_button.pressed.connect(func(): reconnect_pressed.emit())
	close_anyway_button.pressed.connect(func(): close_anyway_pressed.emit())


func set_last_save_time(time_str: String):
	message_label.text = "Last save: %s\nProgress since then will be lost." % time_str
