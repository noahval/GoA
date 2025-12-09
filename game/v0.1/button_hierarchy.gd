extends Node

enum ButtonType {
	ACTION,      # Gameplay actions (shovel, buy, bribe)
	FORWARD_NAV, # Navigate deeper (To Shop, Enter Passage)
	BACK_NAV,    # Return to previous (To Bar, Back)
	SETTINGS,    # Settings button (always at bottom)
}

# Lower number = higher priority = appears higher in menu
# 10-unit increments allow adding new types between existing ones
const BUTTON_ORDER = {
	ButtonType.ACTION: 3,
	ButtonType.FORWARD_NAV: 6,
	ButtonType.BACK_NAV: 8,
	ButtonType.SETTINGS: 15,  # Way at bottom, lots of room for new types
}

func get_button_type(button: Button) -> ButtonType:
	"""
	Detect button type based on theme variation and text patterns
	"""
	var theme_var = button.theme_type_variation
	var text = button.text.to_lower()

	# Check theme variation first (most reliable)
	if theme_var == &"ForwardNavButton":
		return ButtonType.FORWARD_NAV
	elif theme_var == &"BackNavButton":
		return ButtonType.BACK_NAV

	# Check text patterns for navigation
	if text.begins_with("to ") or text.begins_with("enter ") or text.begins_with("approach "):
		return ButtonType.FORWARD_NAV
	elif text.begins_with("back to ") or text.contains("return"):
		return ButtonType.BACK_NAV

	# Check for settings button
	if text == "settings" or button.name.to_lower().contains("settings"):
		return ButtonType.SETTINGS

	# Default: action button
	return ButtonType.ACTION

func get_sort_priority(button: Button) -> int:
	"""
	Returns sort priority for button (lower = higher priority)
	"""
	var type = get_button_type(button)
	return BUTTON_ORDER.get(type, 999)

func apply_theme_variations(container: Node) -> void:
	"""
	Apply theme variations based on button type
	Called after sorting
	"""
	for child in container.get_children():
		if not child is Button:
			continue

		var button = child as Button
		var type = get_button_type(button)

		# Apply theme variation if not already set
		if type == ButtonType.FORWARD_NAV and button.theme_type_variation != &"ForwardNavButton":
			button.theme_type_variation = &"ForwardNavButton"
		elif type == ButtonType.BACK_NAV and button.theme_type_variation != &"BackNavButton":
			button.theme_type_variation = &"BackNavButton"

func sort_buttons_in_container(container: Node) -> void:
	"""
	Sort all button children of container by hierarchy
	Called by ResponsiveLayout.apply_to_scene()
	"""
	if not container:
		return

	# Get all button children
	var buttons: Array[Button] = []
	for child in container.get_children():
		if child is Button:
			buttons.append(child)

	# Sort by priority
	buttons.sort_custom(func(a, b): return get_sort_priority(a) < get_sort_priority(b))

	# Reorder in scene tree
	for i in range(buttons.size()):
		container.move_child(buttons[i], i)

	# Apply theme variations after sorting
	apply_theme_variations(container)
