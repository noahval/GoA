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

# Adaptive scaling settings
const MIN_BUTTON_HEIGHT = 50  # Minimum height for buttons when squeezed
const MIN_FONT_SCALE = 0.8    # Minimum font scale when squeezed
const BUTTON_MARGIN = 5        # Spacing between buttons

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
	# Use call_deferred to ensure the scene tree is fully ready
	# This is CRITICAL for inherited scenes where nodes may not be fully initialized yet
	call_deferred("_apply_responsive_layout_internal", scene_root)

## Internal function that actually applies the layout
## Do not call directly - use apply_to_scene() instead
func _apply_responsive_layout_internal(scene_root: Control) -> void:
	print("ResponsiveLayout: Starting layout application for ", scene_root.name)

	# Add settings overlay if it doesn't exist
	if not scene_root.has_node("SettingsOverlay"):
		var settings_scene = load("res://settings_overlay.tscn")
		if settings_scene:
			var settings_instance = settings_scene.instantiate()
			settings_instance.name = "SettingsOverlay"
			scene_root.add_child(settings_instance)
			print("ResponsiveLayout: Added settings overlay")

	var viewport_size = scene_root.get_viewport().get_visible_rect().size
	var is_portrait = viewport_size.y > viewport_size.x
	print("ResponsiveLayout: Viewport size: ", viewport_size, " Portrait: ", is_portrait)

	var background = scene_root.get_node_or_null("Background")
	var hbox = scene_root.get_node_or_null("HBoxContainer")
	var vbox = scene_root.get_node_or_null("VBoxContainer")
	var left_vbox = scene_root.get_node_or_null("HBoxContainer/LeftVBox")
	var right_vbox = scene_root.get_node_or_null("HBoxContainer/RightVBox")
	var top_vbox = scene_root.get_node_or_null("VBoxContainer/TopVBox")
	var bottom_vbox = scene_root.get_node_or_null("VBoxContainer/BottomVBox")

	print("ResponsiveLayout: Found nodes - Background: ", background != null, " HBox: ", hbox != null,
		  " VBox: ", vbox != null, " LeftVBox: ", left_vbox != null, " RightVBox: ", right_vbox != null)

	if not hbox or not vbox or not left_vbox or not right_vbox or not top_vbox or not bottom_vbox:
		push_warning("ResponsiveLayout: Scene missing required container nodes")
		return

	# CRITICAL: Ensure mouse_filter is set to PASS (2) on all containers and background
	# This allows mouse events to reach buttons even if scenes were created before template was updated
	if background:
		background.mouse_filter = Control.MOUSE_FILTER_PASS
		print("ResponsiveLayout: Set Background mouse_filter to PASS")
		if background is TextureRect:
			print("ResponsiveLayout: Background texture: ", background.texture)
			# If texture is null, try to load it from the scene's expected path
			if background.texture == null:
				print("ResponsiveLayout: WARNING - Background texture is null!")
				print("ResponsiveLayout: Attempting to auto-load background based on scene name...")
				_auto_load_background(scene_root, background)
	else:
		print("ResponsiveLayout: WARNING - No Background node found!")

	hbox.mouse_filter = Control.MOUSE_FILTER_PASS
	vbox.mouse_filter = Control.MOUSE_FILTER_PASS
	left_vbox.mouse_filter = Control.MOUSE_FILTER_PASS
	right_vbox.mouse_filter = Control.MOUSE_FILTER_PASS
	print("ResponsiveLayout: Set all container mouse_filters to PASS")

	# Debug: Print buttons found
	var button_count = 0
	for child in right_vbox.get_children():
		if child is Button:
			button_count += 1
			print("ResponsiveLayout: Found button: ", child.name, " Text: ", child.text)
	print("ResponsiveLayout: Total buttons found: ", button_count)

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
	var viewport_size = left_vbox.get_viewport().get_visible_rect().size

	# Calculate adaptive scaling for buttons
	var buttons = []
	for button in right_vbox.get_children():
		if button is Button:
			buttons.append(button)

	if buttons.size() > 0:
		var available_height = viewport_size.y - PORTRAIT_TOP_PADDING - PORTRAIT_BOTTOM_PADDING
		var total_margin = BUTTON_MARGIN * (buttons.size() - 1)
		var ideal_total_height = PORTRAIT_BUTTON_HEIGHT * buttons.size() + total_margin

		# Determine if we need to squeeze
		var scale_factor = 1.0
		if ideal_total_height > available_height:
			scale_factor = available_height / ideal_total_height
			scale_factor = max(scale_factor, MIN_BUTTON_HEIGHT / float(PORTRAIT_BUTTON_HEIGHT))

		# Apply progressive scaling - buttons get progressively smaller from top to bottom
		for i in range(buttons.size()):
			var button = buttons[i]
			# Progressive reduction factor (0.0 at top, 1.0 at bottom)
			var progress = float(i) / max(1, buttons.size() - 1)

			# Calculate button height with progressive thinning
			var base_height = PORTRAIT_BUTTON_HEIGHT * scale_factor
			var reduction = (1.0 - scale_factor) * progress * 0.3  # Up to 30% additional reduction at bottom
			var button_height = base_height * (1.0 - reduction)
			button_height = max(button_height, MIN_BUTTON_HEIGHT)

			# Calculate font scale with progressive reduction
			var font_scale = PORTRAIT_FONT_SCALE * scale_factor * (1.0 - reduction * 0.5)
			font_scale = max(font_scale, MIN_FONT_SCALE)

			# Apply scaling
			button.custom_minimum_size = Vector2(0, button_height)
			var current_size = button.get_theme_font_size("font_size")
			if current_size <= 0:
				current_size = 25  # Default from theme
			button.add_theme_font_size_override("font_size", int(current_size * font_scale))

	# Scale panels in left column with adaptive scaling
	var panels = []
	for panel in left_vbox.get_children():
		if panel is Panel:
			panels.append(panel)

	if panels.size() > 0:
		var available_height = viewport_size.y - PORTRAIT_TOP_PADDING - PORTRAIT_BOTTOM_PADDING
		var total_margin = BUTTON_MARGIN * (panels.size() - 1)
		var ideal_total_height = PORTRAIT_PANEL_HEIGHT * panels.size() + total_margin

		var scale_factor = 1.0
		if ideal_total_height > available_height:
			scale_factor = available_height / ideal_total_height
			scale_factor = max(scale_factor, 0.6)  # Don't shrink panels below 60%

		for i in range(panels.size()):
			var panel = panels[i]
			var progress = float(i) / max(1, panels.size() - 1)
			var reduction = (1.0 - scale_factor) * progress * 0.2
			var panel_height = PORTRAIT_PANEL_HEIGHT * scale_factor * (1.0 - reduction)

			panel.custom_minimum_size = Vector2(0, panel_height)

			# Scale labels and other children
			for child in panel.get_children():
				if child is Label:
					var label_size = child.get_theme_font_size("font_size")
					if label_size <= 0:
						label_size = 25  # Default from theme
					var font_scale = PORTRAIT_FONT_SCALE * scale_factor * (1.0 - reduction * 0.5)
					font_scale = max(font_scale, MIN_FONT_SCALE)
					child.add_theme_font_size_override("font_size", int(label_size * font_scale))

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

## Automatically load background texture based on scene root name
## Converts scene root name (e.g. "Bar", "CoppersmithCarriage") to snake_case
## and attempts to load the corresponding .jpg file from level1 directory
func _auto_load_background(scene_root: Control, background: TextureRect) -> void:
	var scene_name = scene_root.name

	# Convert PascalCase/CamelCase to snake_case
	var snake_case_name = _to_snake_case(scene_name)

	# Try to load from level1 directory
	var image_path = "res://level1/" + snake_case_name + ".jpg"

	print("ResponsiveLayout: Trying to load background from: ", image_path)

	if ResourceLoader.exists(image_path):
		var texture = load(image_path)
		if texture:
			background.texture = texture
			print("ResponsiveLayout: Successfully auto-loaded background texture!")
		else:
			print("ResponsiveLayout: ERROR - Failed to load texture at path: ", image_path)
	else:
		print("ResponsiveLayout: No background image found at: ", image_path)

## Convert PascalCase or CamelCase string to snake_case
## Examples: "Bar" -> "bar", "CoppersmithCarriage" -> "coppersmith_carriage"
func _to_snake_case(text: String) -> String:
	var result = ""
	for i in range(text.length()):
		var c = text[i]
		# If uppercase and not first character, add underscore before it
		if c == c.to_upper() and c != c.to_lower() and i > 0:
			result += "_"
		result += c.to_lower()
	return result
