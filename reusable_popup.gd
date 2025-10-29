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

@onready var message_label = $MarginContainer/VBoxContainer/ScrollContainer/MessageLabel
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

	# Detect portrait mode and get appropriate scaling
	var viewport_size = get_viewport().get_visible_rect().size
	var is_portrait = viewport_size.y > viewport_size.x

	# Calculate scaled button height based on orientation
	var button_height = ResponsiveLayout.LANDSCAPE_ELEMENT_HEIGHT
	if is_portrait:
		button_height = ResponsiveLayout.PORTRAIT_ELEMENT_HEIGHT * ResponsiveLayout.PORTRAIT_FONT_SCALE

	# Create new buttons
	for button_text in button_texts:
		var button = Button.new()
		button.text = button_text
		button.theme_type_variation = &"PopupButton"
		button.custom_minimum_size = Vector2(100, button_height)
		button_container.add_child(button)
		button.pressed.connect(_on_button_pressed.bind(button_text))

		# Apply font scaling in portrait mode
		if is_portrait:
			var default_font_size = button.get_theme_font_size("font_size")
			if default_font_size <= 0:
				default_font_size = 25  # Default from theme
			button.add_theme_font_size_override("font_size", int(default_font_size * ResponsiveLayout.PORTRAIT_FONT_SCALE))

	# Apply font scaling to message label in portrait mode
	if is_portrait:
		var label_font_size = message_label.get_theme_font_size("font_size")
		if label_font_size <= 0:
			label_font_size = 25  # Default from theme
		message_label.add_theme_font_size_override("font_size", int(label_font_size * ResponsiveLayout.PORTRAIT_FONT_SCALE))
	else:
		# Reset font scaling in landscape mode
		message_label.remove_theme_font_size_override("font_size")

	# Auto-resize to fit content
	if auto_resize:
		call_deferred("_resize_to_content")

## Show the popup
func show_popup() -> void:
	visible = true
	# If we're in a play area, resize to use available space
	call_deferred("_check_and_resize_for_play_area")

## Hide the popup
func hide_popup() -> void:
	visible = false

## Internal: Handle button press
func _on_button_pressed(button_text: String) -> void:
	button_pressed.emit(button_text)
	hide_popup()

## Check if popup is in a play area and resize accordingly
func _check_and_resize_for_play_area() -> void:
	print("=== ReusablePopup._check_and_resize_for_play_area START ===")
	var parent_node = get_parent()
	if not parent_node:
		print("ReusablePopup: No parent, aborting resize")
		return

	print("ReusablePopup: Parent name: ", parent_node.name)

	# Check if we're in CenterArea or MiddleArea
	if parent_node.name == "CenterArea" or parent_node.name == "MiddleArea":
		# Wait a frame for parent to calculate its size
		await get_tree().process_frame

		var parent_size = parent_node.size
		print("ReusablePopup: In play area ", parent_node.name, " with size: ", parent_size)
		print("ReusablePopup: Current popup size BEFORE resize: ", size)
		print("ReusablePopup: Current popup offsets BEFORE: L=", offset_left, " R=", offset_right, " T=", offset_top, " B=", offset_bottom)
		print("ReusablePopup: Current popup anchors: L=", anchor_left, " R=", anchor_right, " T=", anchor_top, " B=", anchor_bottom)

		if parent_size.x > 0 and parent_size.y > 0:
			# Use 85% of parent width and 90% of parent height
			var target_width = parent_size.x * 0.85
			var target_height = parent_size.y * 0.90

			print("ReusablePopup: Calculated target size: ", target_width, "x", target_height)

			# Center within parent using offsets (anchors should already be 0.5)
			var half_width = target_width / 2.0
			var half_height = target_height / 2.0
			offset_left = -half_width
			offset_right = half_width
			offset_top = -half_height
			offset_bottom = half_height

			print("ReusablePopup: Set offsets to: L=", offset_left, " R=", offset_right, " T=", offset_top, " B=", offset_bottom)

			# Wait one more frame and verify
			await get_tree().process_frame
			print("ReusablePopup: AFTER resize - actual size: ", size)
			print("ReusablePopup: AFTER resize - actual offsets: L=", offset_left, " R=", offset_right, " T=", offset_top, " B=", offset_bottom)
		else:
			print("ReusablePopup: Parent size invalid: ", parent_size)
	else:
		print("ReusablePopup: Not in play area (parent is ", parent_node.name, "), skipping resize")
	print("=== ReusablePopup._check_and_resize_for_play_area END ===")
	print("")

## Force resize popup to use available space in play area
## Called by ResponsiveLayout after reparenting to CenterArea/MiddleArea
func force_resize_in_play_area(available_width: float, available_height: float) -> void:
	print("ReusablePopup: force_resize_in_play_area called - available: ", available_width, "x", available_height)

	# Use 85% of available width by default
	var target_width = available_width * 0.85
	var target_height = available_height

	# Center within parent using offsets
	var half_width = target_width / 2.0
	var half_height = target_height / 2.0
	offset_left = -half_width
	offset_right = half_width
	offset_top = -half_height
	offset_bottom = half_height

	print("ReusablePopup: Resized to ", target_width, "x", target_height)

## Internal: Resize popup to fit content
func _resize_to_content() -> void:
	print("=== ReusablePopup._resize_to_content START ===")
	print("ReusablePopup: Current parent: ", get_parent().name if get_parent() else "null")

	# Wait for layout to update
	await get_tree().process_frame

	# Get viewport dimensions
	var viewport_size = get_viewport().get_visible_rect().size
	var is_portrait = viewport_size.y > viewport_size.x
	print("ReusablePopup: Viewport size: ", viewport_size, " Portrait: ", is_portrait)

	# Calculate required size based on message and buttons
	var font = message_label.get_theme_font("font")

	# Get the ACTUAL font size being used (after scaling)
	var font_size = message_label.get_theme_font_size("font_size")
	if font_size <= 0:
		font_size = 25

	# Account for portrait mode scaling
	if is_portrait:
		font_size = int(font_size * ResponsiveLayout.PORTRAIT_FONT_SCALE)

	# Calculate text dimensions
	var text_width = 0
	if font:
		# Get approximate width for wrapped text
		@warning_ignore("confusable_local_declaration")
		var max_width = viewport_size.x * 0.8 if is_portrait else viewport_size.x * 0.5
		text_width = min(font.get_string_size(message_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + 60, max_width)

	# Check if popup is inside a play area (CenterArea or MiddleArea)
	# If so, respect the parent's bounds instead of using viewport size
	var parent_node = get_parent()
	var use_parent_bounds = false
	var parent_max_width = 0.0
	var parent_max_height = 0.0

	if parent_node and (parent_node.name == "CenterArea" or parent_node.name == "MiddleArea"):
		use_parent_bounds = true
		# Get parent's size (wait a frame to ensure layout is updated)
		await get_tree().process_frame
		# Use most of the parent's available space
		parent_max_width = parent_node.size.x * 0.95  # Use 95% of parent width (increased from 90%)
		parent_max_height = parent_node.size.y * 0.9  # Use 90% of parent height
		print("ReusablePopup: Using parent bounds - ", parent_node.name, " size: ", parent_node.size, " max width: ", parent_max_width)

	# Ensure minimum and maximum dimensions
	var min_width = 250  # Reduced from 300 to allow more flexibility
	var max_width_landscape = viewport_size.x * 0.6
	var max_width_portrait = viewport_size.x * 0.9
	var max_width = max_width_portrait if is_portrait else max_width_landscape

	# Calculate final width
	var final_width = 0.0

	if use_parent_bounds:
		# When inside a play area (CenterArea/MiddleArea), USE AVAILABLE SPACE
		# The whole point of being in a play area is to fill it, not shrink to text
		max_width = parent_max_width
		final_width = parent_max_width * 0.85  # Use 85% of parent width consistently
		print("ReusablePopup: Using parent bounds - forcing width to 85% of parent: ", final_width, " (parent: ", parent_max_width, ")")
	else:
		# Standard behavior: size to fit text content
		final_width = clamp(text_width, min_width, max_width)
		print("ReusablePopup: Standard sizing - final: ", final_width, " (text: ", text_width, ")")

	# Set popup size - IMPORTANT: Don't change position when inside play area
	# The responsive layout has already centered us within the play area
	if not use_parent_bounds:
		# Standard centering on viewport
		var half_width = final_width / 2.0
		offset_left = -half_width
		offset_right = half_width
	else:
		# Inside play area - keep anchored position, just set size
		# Anchors are already 0.5 (centered) from responsive layout
		var half_width = final_width / 2.0
		offset_left = -half_width
		offset_right = half_width

	# Calculate height constraint to prevent overflow
	var max_height = 0.0
	if use_parent_bounds:
		# Use parent's height constraint
		max_height = parent_max_height
	elif is_portrait:
		# Portrait: Conservative height to avoid overlapping with bottom menu
		# Account for top padding (60) + bottom padding (60) + notification bar (100)
		# Plus estimated menu heights (~300px combined for top and bottom menus)
		var reserved_space = 60 + 60 + 100 + 300  # Total reserved space
		var available_height = viewport_size.y - reserved_space
		max_height = max(200, available_height * 0.8)  # Use 80% of available space with 200px minimum
	else:
		# Landscape: can use more vertical space
		max_height = viewport_size.y * 0.7

	# Constrain popup height
	var half_height = max_height / 2.0
	offset_top = -half_height
	offset_bottom = half_height

	print("ReusablePopup: _resize_to_content set offsets to: L=", offset_left, " R=", offset_right, " T=", offset_top, " B=", offset_bottom)
	print("ReusablePopup: Final width: ", final_width, " max height: ", max_height, " (portrait: ", is_portrait, ", parent_bounds: ", use_parent_bounds, ")")
	print("=== ReusablePopup._resize_to_content END ===")
	print("")
