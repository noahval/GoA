extends Node
## Centralized responsive layout configuration
## All scenes can reference this for consistent scaling behavior
## Change values here and all scenes will update automatically

# UNIVERSAL MENU ELEMENT HEIGHTS
# All menu items (buttons, panels, counters, titles) use the same height in each mode
# This creates a consistent, uniform appearance across all UI elements

# Portrait mode - one universal height for ALL menu elements
const PORTRAIT_ELEMENT_HEIGHT = 30
const PORTRAIT_FONT_SCALE = 1.75
const PORTRAIT_TOP_PADDING = 150
const PORTRAIT_BOTTOM_PADDING = 90

# Landscape mode - one universal height for ALL menu elements
const LANDSCAPE_ELEMENT_HEIGHT = 40

# Spacing settings
const BUTTON_MARGIN = 5  # Spacing between buttons
const LANDSCAPE_HBOX_SEPARATION_MAX = 300  # Maximum gap between left and right columns
const LANDSCAPE_HBOX_SEPARATION_MIN = 20  # Minimum gap to maintain
const PORTRAIT_SEPARATION_RATIO = 0.5  # Portrait separation as ratio of scaled element height (50%)

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

	# Check if already in correct mode
	var currently_portrait = vbox.visible
	var need_reparent = currently_portrait != is_portrait

	if need_reparent:
		# Reparent columns when switching modes
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
		else:
			# Landscape: side by side
			hbox.add_child(left_vbox)
			hbox.add_child(right_vbox)
			hbox.visible = true
			vbox.visible = false

	# Always apply mode-specific styling and scaling (even if already in correct mode)
	if is_portrait:
		# Calculate dynamic separation based on scaled element height
		var scaled_height = PORTRAIT_ELEMENT_HEIGHT * PORTRAIT_FONT_SCALE
		var dynamic_separation = max(5, int(scaled_height * PORTRAIT_SEPARATION_RATIO))
		print("ResponsiveLayout: Portrait separation = ", dynamic_separation, " (", scaled_height, " * ", PORTRAIT_SEPARATION_RATIO, ")")

		# Apply portrait styling and scaling
		left_vbox.add_theme_constant_override("separation", dynamic_separation)
		right_vbox.add_theme_constant_override("separation", dynamic_separation)
		_apply_portrait_styling(left_vbox)
		_scale_for_portrait(left_vbox, right_vbox)
	else:
		# Remove portrait spacing overrides and apply landscape spacing
		left_vbox.remove_theme_constant_override("separation")
		right_vbox.remove_theme_constant_override("separation")
		# Add spacing between panels to prevent overlap
		left_vbox.add_theme_constant_override("separation", BUTTON_MARGIN)
		right_vbox.add_theme_constant_override("separation", BUTTON_MARGIN)

		# Apply landscape styling and scaling
		var separation = get_dynamic_separation(viewport_size.x)
		hbox.add_theme_constant_override("separation", separation)
		_apply_landscape_adjustments(left_vbox, right_vbox, hbox)
		_reset_scale(left_vbox, right_vbox)

## Apply landscape-specific adjustments (title expansion, etc.)
## This runs every time a landscape scene is loaded
func _apply_landscape_adjustments(left_vbox: VBoxContainer, right_vbox: VBoxContainer, hbox: HBoxContainer) -> void:
	print("ResponsiveLayout: Applying landscape adjustments")

	# Get current separation value
	var separation = hbox.get_theme_constant("separation")
	if separation == 0:
		separation = 40  # Default from template

	# Reset to default size first
	left_vbox.custom_minimum_size = Vector2(LEFT_COLUMN_WIDTH, 0)
	var default_total_width = LEFT_COLUMN_WIDTH + RIGHT_COLUMN_WIDTH + separation
	var default_half_width = default_total_width / 2.0
	hbox.offset_left = -default_half_width
	hbox.offset_right = default_half_width

	# Check all panels in left column and calculate widths for all labels
	var max_desired_width = LEFT_COLUMN_WIDTH
	var viewport_width = left_vbox.get_viewport().get_visible_rect().size.x
	var max_width = viewport_width - RIGHT_COLUMN_WIDTH - separation - 100

	for panel in left_vbox.get_children():
		if panel is Panel:
			# Remove theme background to prevent double backgrounds
			# Panels have self_modulate in the scene which provides the background
			var empty_style = StyleBoxEmpty.new()
			panel.add_theme_stylebox_override("panel", empty_style)

			var panel_desired_width = LEFT_COLUMN_WIDTH

			# Check all labels in this panel and find the widest one
			for child in panel.get_children():
				if child is Label:
					# Enable word wrapping on all labels
					child.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

					# Calculate required width for this label's text
					var font = child.get_theme_font("font")
					var font_size = child.get_theme_font_size("font_size")
					if font_size <= 0:
						font_size = 25  # Default

					# Get the text width
					var text_width = 0
					if font:
						text_width = font.get_string_size(child.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x

					# Add padding for panel margins
					text_width += 40

					# Calculate desired width for this label
					var label_desired_width = max(LEFT_COLUMN_WIDTH, text_width)
					label_desired_width = min(label_desired_width, max_width)

					# Track the widest label in this panel
					if label_desired_width > panel_desired_width:
						panel_desired_width = label_desired_width

					print("ResponsiveLayout: Panel '", panel.name, "' Label '", child.name, "' text: '", child.text, "' width: ", label_desired_width)

			# Set panel size to UNIVERSAL HEIGHT for all panels
			panel.custom_minimum_size = Vector2(panel_desired_width, LANDSCAPE_ELEMENT_HEIGHT)
			# Allow panel to grow vertically if text wraps
			panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

			# Track the maximum width needed across all panels
			if panel_desired_width > max_desired_width:
				max_desired_width = panel_desired_width

			print("ResponsiveLayout: Panel '", panel.name, "' final width: ", panel_desired_width)

	# Check all buttons in right column and calculate widths
	var max_right_width = RIGHT_COLUMN_WIDTH
	for button in right_vbox.get_children():
		if button is Button:
			# Enable word wrapping on button text
			button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

			# Calculate required width for button text
			var font = button.get_theme_font("font")
			var font_size = button.get_theme_font_size("font_size")
			if font_size <= 0:
				font_size = 25  # Default

			# Get the text width
			var text_width = 0
			if font:
				text_width = font.get_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x

			# Add padding for button margins and icon space
			text_width += 60

			# Calculate desired width for this button
			var button_desired_width = max(RIGHT_COLUMN_WIDTH, text_width)
			button_desired_width = min(button_desired_width, max_width)

			# Track the maximum width needed
			if button_desired_width > max_right_width:
				max_right_width = button_desired_width

			print("ResponsiveLayout: Button '", button.name, "' text: '", button.text, "' width: ", button_desired_width)

	# Set right column width if needed
	if max_right_width > RIGHT_COLUMN_WIDTH:
		right_vbox.custom_minimum_size = Vector2(max_right_width, 0)
		print("ResponsiveLayout: Expanded right column to: ", max_right_width)

	# Expand HBoxContainer if either column needs more space
	var final_left_width = max(LEFT_COLUMN_WIDTH, max_desired_width)
	var final_right_width = max(RIGHT_COLUMN_WIDTH, max_right_width)

	if final_left_width > LEFT_COLUMN_WIDTH or final_right_width > RIGHT_COLUMN_WIDTH:
		left_vbox.custom_minimum_size = Vector2(final_left_width, 0)
		right_vbox.custom_minimum_size = Vector2(final_right_width, 0)
		var total_width = final_left_width + final_right_width + separation
		var half_width = total_width / 2.0
		hbox.offset_left = -half_width
		hbox.offset_right = half_width
		print("ResponsiveLayout: Final layout - Left: ", final_left_width, " Right: ", final_right_width)
		print("ResponsiveLayout: Expanded HBoxContainer offsets to: ", -half_width, " to ", half_width)

## Apply portrait-specific styling (title backgrounds, etc.)
func _apply_portrait_styling(left_vbox: VBoxContainer) -> void:
	print("ResponsiveLayout: Applying portrait styling")

	# Panels will use the default theme background, no need to override
	# The theme already provides a semi-transparent background for all panels

## Scale UI elements for portrait mode with CONSISTENT universal height
func _scale_for_portrait(left_vbox: VBoxContainer, right_vbox: VBoxContainer) -> void:
	# Calculate scaled height once
	var scaled_height = PORTRAIT_ELEMENT_HEIGHT * PORTRAIT_FONT_SCALE
	print("ResponsiveLayout: Portrait scaled height = ", scaled_height, " (", PORTRAIT_ELEMENT_HEIGHT, " * ", PORTRAIT_FONT_SCALE, ")")

	# Apply UNIVERSAL HEIGHT to all buttons
	for button in right_vbox.get_children():
		if button is Button:
			button.custom_minimum_size = Vector2(0, scaled_height)
			var current_size = button.get_theme_font_size("font_size")
			if current_size <= 0:
				current_size = 25  # Default from theme
			button.add_theme_font_size_override("font_size", int(current_size * PORTRAIT_FONT_SCALE))

	# Apply UNIVERSAL HEIGHT to all panels
	for panel in left_vbox.get_children():
		if panel is Panel:
			panel.custom_minimum_size = Vector2(0, scaled_height)
			# Set both minimum AND maximum to prevent expansion
			panel.size_flags_vertical = Control.SIZE_FILL

			# Explicitly constrain the panel size
			panel.size.y = scaled_height

			# Remove theme background to prevent double backgrounds
			# Panels have self_modulate in the scene which provides the background
			var empty_style = StyleBoxEmpty.new()
			panel.add_theme_stylebox_override("panel", empty_style)

			print("ResponsiveLayout: Set panel '", panel.name, "' size to (width, ", scaled_height, ")")

			# Scale labels and other children
			for child in panel.get_children():
				if child is Label:
					var label_size = child.get_theme_font_size("font_size")
					if label_size <= 0:
						label_size = 25  # Default from theme
					child.add_theme_font_size_override("font_size", int(label_size * PORTRAIT_FONT_SCALE))

					# Enable word wrapping on title labels
					if child.name == "TitleLabel" or child.name == "Title":
						child.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
						var viewport_size = left_vbox.get_viewport().get_visible_rect().size
						var viewport_width = viewport_size.x
						# Set max width for wrapping but allow expansion
						child.custom_minimum_size = Vector2(viewport_width - 40, 0)
				elif child is ProgressBar:
					# Scale progress bar font size
					var bar_font_size = child.get_theme_font_size("font_size")
					if bar_font_size <= 0:
						bar_font_size = 25  # Default from theme
					child.add_theme_font_size_override("font_size", int(bar_font_size * PORTRAIT_FONT_SCALE))

## Reset UI elements to landscape/desktop defaults
func _reset_scale(left_vbox: VBoxContainer, right_vbox: VBoxContainer) -> void:
	# Reset left column to default width first
	left_vbox.custom_minimum_size = Vector2(LEFT_COLUMN_WIDTH, 0)

	# Get the HBoxContainer parent
	var hbox = left_vbox.get_parent() as HBoxContainer
	if not hbox:
		print("ResponsiveLayout: ERROR - LeftVBox parent is not HBoxContainer")
		return

	# Reset HBoxContainer to default size (from template: -290 to 290 = 580px total)
	var default_total_width = LEFT_COLUMN_WIDTH + RIGHT_COLUMN_WIDTH + hbox.get_theme_constant("separation")
	var default_half_width = default_total_width / 2.0
	hbox.offset_left = -default_half_width
	hbox.offset_right = default_half_width

	# Reset buttons to UNIVERSAL HEIGHT
	for button in right_vbox.get_children():
		if button is Button:
			button.custom_minimum_size = Vector2(0, LANDSCAPE_ELEMENT_HEIGHT)
			button.remove_theme_font_size_override("font_size")

	# Reset panels
	for panel in left_vbox.get_children():
		if panel is Panel:
			# Check if this is a title panel before resetting size
			var is_title_panel = false
			var title_label = null
			for child in panel.get_children():
				if child is Label and (child.name == "TitleLabel" or child.name == "Title"):
					is_title_panel = true
					title_label = child
					break

			if is_title_panel and title_label:
				# Handle title panel specially - calculate required width
				title_label.remove_theme_font_size_override("font_size")
				title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

				# Calculate required width for the text
				var font = title_label.get_theme_font("font")
				var font_size = title_label.get_theme_font_size("font_size")
				if font_size <= 0:
					font_size = 25  # Default

				print("ResponsiveLayout: Title text: '", title_label.text, "' Font size: ", font_size)

				# Get the text width (with some padding)
				var text_width = 0
				if font:
					text_width = font.get_string_size(title_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
					print("ResponsiveLayout: Calculated text width: ", text_width)

				# Add padding for panel margins
				text_width += 40

				# Expand panel width if text is longer than column width
				# But cap at viewport width minus some margin
				var viewport_width = left_vbox.get_viewport().get_visible_rect().size.x
				var max_width = viewport_width - RIGHT_COLUMN_WIDTH - 100  # Leave room for right column
				var desired_width = max(LEFT_COLUMN_WIDTH, text_width)
				desired_width = min(desired_width, max_width)

				print("ResponsiveLayout: Desired width: ", desired_width, " (min: ", LEFT_COLUMN_WIDTH, ", max: ", max_width, ")")

				# Set panel size with UNIVERSAL HEIGHT
				panel.custom_minimum_size = Vector2(desired_width, LANDSCAPE_ELEMENT_HEIGHT)

				# Also set the left column to match the widest title panel
				if desired_width > left_vbox.custom_minimum_size.x:
					left_vbox.custom_minimum_size = Vector2(desired_width, 0)
					print("ResponsiveLayout: Expanded left column to: ", desired_width)

					# Expand the HBoxContainer to accommodate the new column width
					var total_width = desired_width + RIGHT_COLUMN_WIDTH + hbox.get_theme_constant("separation")
					var half_width = total_width / 2.0
					hbox.offset_left = -half_width
					hbox.offset_right = half_width
					print("ResponsiveLayout: Expanded HBoxContainer offsets to: ", -half_width, " to ", half_width)
			else:
				# Regular panel - use UNIVERSAL HEIGHT
				panel.custom_minimum_size = Vector2(0, LANDSCAPE_ELEMENT_HEIGHT)
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
