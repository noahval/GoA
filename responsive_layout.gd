extends Node
## Centralized responsive layout configuration
## All scenes can reference this for consistent scaling behavior
## Change values here and all scenes will update automatically

# Portrait mode scaling factors
const PORTRAIT_BUTTON_HEIGHT = 105
const PORTRAIT_PANEL_HEIGHT = 70
const PORTRAIT_FONT_SCALE = 1.75
const PORTRAIT_TOP_PADDING = 90
const PORTRAIT_BOTTOM_PADDING = 90

# Landscape mode defaults
const LANDSCAPE_PANEL_HEIGHT = 24
const LANDSCAPE_BUTTON_HEIGHT = 0  # 0 = auto
const LANDSCAPE_HBOX_SEPARATION_MAX = 300  # Maximum gap between left and right columns
const LANDSCAPE_HBOX_SEPARATION_MIN = 20  # Minimum gap to maintain

# Column widths (from template)
const LEFT_COLUMN_WIDTH = 220
const RIGHT_COLUMN_WIDTH = 260

# Container dimensions (from template)
const CONTAINER_WIDTH = 500
const CONTAINER_HEIGHT = 600

## Calculate dynamic separation based on viewport width
## Shrinks from max (300) to min (20) as viewport width decreases
func get_dynamic_separation(viewport_width: float) -> int:
	# Calculate required width for content
	var content_width = LEFT_COLUMN_WIDTH + RIGHT_COLUMN_WIDTH
	# Available space for separation
	var available_space = viewport_width - content_width
	# Calculate separation (clamped between min and max)
	var separation = clamp(available_space / 2.0, LANDSCAPE_HBOX_SEPARATION_MIN, LANDSCAPE_HBOX_SEPARATION_MAX)
	return int(separation)

## Apply responsive layout to a scene
## Call this from _ready() in your scene script
func apply_to_scene(scene_root: Control) -> void:
	# Add settings overlay if it doesn't exist
	if not scene_root.has_node("SettingsOverlay"):
		var settings_scene = load("res://settings_overlay.tscn")
		if settings_scene:
			var settings_instance = settings_scene.instantiate()
			settings_instance.name = "SettingsOverlay"
			scene_root.add_child(settings_instance)

	var viewport_size = scene_root.get_viewport().get_visible_rect().size
	var is_portrait = viewport_size.y > viewport_size.x

	var hbox = scene_root.get_node_or_null("HBoxContainer")
	var vbox = scene_root.get_node_or_null("VBoxContainer")
	var left_vbox = scene_root.get_node_or_null("HBoxContainer/LeftVBox")
	var right_vbox = scene_root.get_node_or_null("HBoxContainer/RightVBox")
	var top_vbox = scene_root.get_node_or_null("VBoxContainer/TopVBox")
	var bottom_vbox = scene_root.get_node_or_null("VBoxContainer/BottomVBox")

	if not hbox or not vbox or not left_vbox or not right_vbox or not top_vbox or not bottom_vbox:
		push_warning("ResponsiveLayout: Scene missing required container nodes")
		return

	# Always apply separation to landscape HBox with dynamic calculation
	if not is_portrait:
		var separation = get_dynamic_separation(viewport_size.x)
		hbox.add_theme_constant_override("separation", separation)

	# Check if already in correct mode
	var currently_portrait = vbox.visible
	if currently_portrait == is_portrait:
		return  # Already in correct mode

	# Reparent columns
	if left_vbox.get_parent():
		left_vbox.get_parent().remove_child(left_vbox)
	if right_vbox.get_parent():
		right_vbox.get_parent().remove_child(right_vbox)

	if is_portrait:
		# Portrait: stack vertically
		top_vbox.add_child(left_vbox)
		bottom_vbox.add_child(right_vbox)
		hbox.visible = false
		vbox.visible = true
		_reverse_button_order(right_vbox)
		_scale_for_portrait(left_vbox, right_vbox)
	else:
		# Landscape: side by side
		hbox.add_child(left_vbox)
		hbox.add_child(right_vbox)
		hbox.visible = true
		vbox.visible = false
		# Add separation between columns (dynamic based on viewport width)
		var separation = get_dynamic_separation(viewport_size.x)
		hbox.add_theme_constant_override("separation", separation)
		_reset_scale(left_vbox, right_vbox)

## Scale UI elements for portrait mode
func _scale_for_portrait(left_vbox: VBoxContainer, right_vbox: VBoxContainer) -> void:
	# Scale buttons in right column
	for button in right_vbox.get_children():
		if button is Button:
			button.custom_minimum_size = Vector2(0, PORTRAIT_BUTTON_HEIGHT)
			var current_size = button.get_theme_font_size("font_size")
			if current_size <= 0:
				current_size = 25  # Default from theme
			button.add_theme_font_size_override("font_size", int(current_size * PORTRAIT_FONT_SCALE))

	# Scale panels in left column
	for panel in left_vbox.get_children():
		if panel is Panel:
			panel.custom_minimum_size = Vector2(0, PORTRAIT_PANEL_HEIGHT)
			# Scale labels and other children
			for child in panel.get_children():
				if child is Label:
					var label_size = child.get_theme_font_size("font_size")
					if label_size <= 0:
						label_size = 25  # Default from theme
					child.add_theme_font_size_override("font_size", int(label_size * PORTRAIT_FONT_SCALE))

## Reset UI elements to landscape/desktop defaults
func _reset_scale(left_vbox: VBoxContainer, right_vbox: VBoxContainer) -> void:
	# Reset buttons
	for button in right_vbox.get_children():
		if button is Button:
			button.custom_minimum_size = Vector2(0, LANDSCAPE_BUTTON_HEIGHT)
			button.remove_theme_font_size_override("font_size")

	# Reset panels
	for panel in left_vbox.get_children():
		if panel is Panel:
			panel.custom_minimum_size = Vector2(0, LANDSCAPE_PANEL_HEIGHT)
			for child in panel.get_children():
				if child is Label:
					child.remove_theme_font_size_override("font_size")

## Check if viewport is in portrait orientation
static func is_portrait_mode(viewport: Viewport) -> bool:
	var size = viewport.get_visible_rect().size
	return size.y > size.x

## Get current scaling factor based on orientation
static func get_font_scale(viewport: Viewport) -> float:
	return PORTRAIT_FONT_SCALE if is_portrait_mode(viewport) else 1.0

## Reverse the order of buttons in a container (for portrait mode)
func _reverse_button_order(container: VBoxContainer) -> void:
	var children = container.get_children()
	var buttons = []

	# Collect all buttons
	for child in children:
		if child is Button:
			buttons.append(child)

	# Remove and re-add in reverse order
	for button in buttons:
		container.remove_child(button)

	buttons.reverse()

	for button in buttons:
		container.add_child(button)
