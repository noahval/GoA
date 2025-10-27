extends Panel
## Reusable popup dialog system
##
## Usage (Method 1 - Instance in scene):
##   $ReusablePopup.setup("Message", ["OK", "Cancel"])
##   $ReusablePopup.button_pressed.connect(func(button_text): print(button_text))
##   $ReusablePopup.show_popup()
##
## Usage (Method 2 - Create dynamically):
##   var popup_scene = load("res://reusable_popup.tscn")
##   var popup = popup_scene.instantiate()
##   get_tree().root.add_child(popup)
##   popup.setup("Message", ["Button 1", "Button 2"])
##   popup.show_popup()
##   popup.button_pressed.connect(_on_popup_button_pressed)

signal button_pressed(button_text: String)

@onready var message_label = $MarginContainer/VBoxContainer/MessageLabel
@onready var button_container = $MarginContainer/VBoxContainer/ButtonContainer

## Set up the popup with a message and buttons
## message: The text to display
## button_texts: Array of button labels (e.g., ["OK", "Cancel"])
## auto_resize: If true, automatically resize to fit content
func setup(message: String, button_texts: Array, auto_resize: bool = true) -> void:
	# Set message
	message_label.text = message

	# Clear existing buttons
	for child in button_container.get_children():
		child.queue_free()

	# Create new buttons
	for button_text in button_texts:
		var button = Button.new()
		button.text = button_text
		button.theme_type_variation = &"PopupButton"
		button.custom_minimum_size = Vector2(100, 40)
		button_container.add_child(button)
		button.pressed.connect(_on_button_pressed.bind(button_text))

	# Auto-resize to fit content
	if auto_resize:
		call_deferred("_resize_to_content")

## Show the popup
func show_popup() -> void:
	visible = true

## Hide the popup
func hide_popup() -> void:
	visible = false

## Internal: Handle button press
func _on_button_pressed(button_text: String) -> void:
	button_pressed.emit(button_text)
	hide_popup()

## Internal: Resize popup to fit content
func _resize_to_content() -> void:
	# Wait for layout to update
	await get_tree().process_frame

	# Get viewport dimensions
	var viewport_size = get_viewport().get_visible_rect().size
	var is_portrait = viewport_size.y > viewport_size.x

	# Calculate required size based on message and buttons
	var font = message_label.get_theme_font("font")
	var font_size = message_label.get_theme_font_size("font_size")
	if font_size <= 0:
		font_size = 25

	# Calculate text dimensions
	var text_width = 0
	if font:
		# Get approximate width for wrapped text
		@warning_ignore("confusable_local_declaration")
		var max_width = viewport_size.x * 0.8 if is_portrait else viewport_size.x * 0.5
		text_width = min(font.get_string_size(message_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + 60, max_width)

	# Ensure minimum and maximum dimensions
	var min_width = 300
	var max_width_landscape = viewport_size.x * 0.6
	var max_width_portrait = viewport_size.x * 0.9
	var max_width = max_width_portrait if is_portrait else max_width_landscape

	var final_width = clamp(text_width, min_width, max_width)

	# Set popup size
	var half_width = final_width / 2.0
	offset_left = -half_width
	offset_right = half_width

	# Height auto-adjusts based on content
