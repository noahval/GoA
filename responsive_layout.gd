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
const MIN_CENTER_WIDTH = 400  # Minimum width for center play area

# Popup constraints
const POPUP_MAX_WIDTH_LANDSCAPE = 600  # Max popup width in landscape
const POPUP_MAX_WIDTH_PORTRAIT = 0.9  # Max popup width as % of viewport in portrait
const POPUP_MARGIN_FROM_MENUS = 40  # Minimum space between popup and side menus

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
	var center_area = scene_root.get_node_or_null("HBoxContainer/CenterArea")
	var right_vbox = scene_root.get_node_or_null("HBoxContainer/RightVBox")
	var top_vbox = scene_root.get_node_or_null("VBoxContainer/TopVBox")
	var middle_area = scene_root.get_node_or_null("VBoxContainer/MiddleArea")
	var bottom_vbox = scene_root.get_node_or_null("VBoxContainer/BottomVBox")
	var popup_container = scene_root.get_node_or_null("PopupContainer")

	print("ResponsiveLayout: Found nodes - Background: ", background != null, " HBox: ", hbox != null,
		  " VBox: ", vbox != null, " CenterArea: ", center_area != null, " MiddleArea: ", middle_area != null)

	if not hbox or not vbox or not left_vbox or not right_vbox or not top_vbox or not bottom_vbox:
		push_warning("ResponsiveLayout: Scene missing required container nodes")
		return

	# Set mouse filter on play areas and popup container to PASS
	if center_area:
		center_area.mouse_filter = Control.MOUSE_FILTER_PASS
	if middle_area:
		middle_area.mouse_filter = Control.MOUSE_FILTER_PASS
	if popup_container:
		popup_container.mouse_filter = Control.MOUSE_FILTER_PASS

	# Set mouse filter on padding controls to PASS (they shouldn't block clicks)
	var top_padding = scene_root.get_node_or_null("VBoxContainer/TopPadding")
	var bottom_padding = scene_root.get_node_or_null("VBoxContainer/BottomPadding")
	if top_padding:
		top_padding.mouse_filter = Control.MOUSE_FILTER_PASS
		print("ResponsiveLayout: Set TopPadding mouse_filter to PASS")
	if bottom_padding:
		bottom_padding.mouse_filter = Control.MOUSE_FILTER_PASS
		print("ResponsiveLayout: Set BottomPadding mouse_filter to PASS")

	# CRITICAL: Set correct mouse_filter values
	# Background and play areas should PASS events through (don't block)
	# But button/panel containers should use STOP (default) to process events for their children
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

	# CRITICAL: Set mouse_filter correctly on containers
	# Main containers (HBox/VBox) should PASS events through (they're full-screen layout containers)
	# This allows SettingsOverlay (z_index: 200) to receive clicks even when VBox is visible in portrait mode
	# But menu containers (LeftVBox/RightVBox/TopVBox/BottomVBox) should STOP to allow their button children to receive events
	if hbox:
		hbox.mouse_filter = Control.MOUSE_FILTER_PASS
	if vbox:
		vbox.mouse_filter = Control.MOUSE_FILTER_PASS
	if left_vbox:
		left_vbox.mouse_filter = Control.MOUSE_FILTER_STOP
	if right_vbox:
		right_vbox.mouse_filter = Control.MOUSE_FILTER_STOP
	if top_vbox:
		top_vbox.mouse_filter = Control.MOUSE_FILTER_STOP
	if bottom_vbox:
		bottom_vbox.mouse_filter = Control.MOUSE_FILTER_STOP
	print("ResponsiveLayout: Set main containers to PASS, menu containers to STOP")

	# Check if already in correct mode
	var currently_portrait = vbox.visible
	var need_reparent = currently_portrait != is_portrait

	print("ResponsiveLayout: currently_portrait=", currently_portrait, " is_portrait=", is_portrait, " need_reparent=", need_reparent)

	if need_reparent:
		# CRITICAL: Use reparent() instead of remove_child/add_child to preserve signal connections
		# This prevents button click signals from breaking when switching orientations
		if is_portrait:
			# Portrait: stack vertically
			# Set size_flags BEFORE reparenting for proper layout
			left_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			# Remove custom_minimum_size entirely so containers can expand
			left_vbox.custom_minimum_size = Vector2.ZERO
			right_vbox.custom_minimum_size = Vector2.ZERO
			# Reset any positioning
			left_vbox.position = Vector2.ZERO
			right_vbox.position = Vector2.ZERO

			# CRITICAL: Use reparent() to preserve signal connections
			left_vbox.reparent(top_vbox)
			right_vbox.reparent(bottom_vbox)

			hbox.visible = false
			vbox.visible = true
			print("ResponsiveLayout: Reparented to portrait using reparent() - signals preserved")

			_reverse_button_order(right_vbox)
		else:
			# Landscape: side by side with CenterArea in middle
			# Restore size_flags for landscape BEFORE reparenting
			left_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			right_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			# Restore minimum widths from template
			left_vbox.custom_minimum_size = Vector2(LEFT_COLUMN_WIDTH, 0)
			right_vbox.custom_minimum_size = Vector2(RIGHT_COLUMN_WIDTH, 0)
			print("ResponsiveLayout: Set landscape size_flags (SHRINK_CENTER)")

			# CRITICAL: Use reparent() to preserve signal connections
			# Reparent in correct order: LeftVBox, CenterArea (already there), RightVBox
			if center_area and center_area.get_parent() == hbox:
				# Reparent LeftVBox first, then move it before CenterArea
				left_vbox.reparent(hbox)
				var center_index = center_area.get_index()
				hbox.move_child(left_vbox, center_index)
				# Reparent RightVBox (it will be at the end after CenterArea)
				right_vbox.reparent(hbox)
			else:
				# Fallback if CenterArea doesn't exist
				left_vbox.reparent(hbox)
				right_vbox.reparent(hbox)

			hbox.visible = true
			vbox.visible = false
			print("ResponsiveLayout: Reparented to landscape using reparent() - signals preserved")

	# Position popups in the appropriate area
	position_popups_in_play_area(scene_root, is_portrait, popup_container, center_area, middle_area, viewport_size)

	# Apply font scaling to popups
	apply_popup_font_scaling(popup_container, is_portrait)

	# CRITICAL: Hide PopupContainer if no popups are visible
	# PopupContainer has z_index:100 and blocks ALL clicks even with mouse_filter=PASS
	if popup_container:
		var any_popup_visible = false
		for child in popup_container.get_children():
			if child is Control and child.visible:
				any_popup_visible = true
				break

		if not any_popup_visible:
			popup_container.visible = false
			print("ResponsiveLayout: Hid PopupContainer (no visible popups)")
		else:
			popup_container.visible = true
			print("ResponsiveLayout: PopupContainer visible (has active popups)")

	# Remove panel backgrounds to prevent double backgrounds
	# Panels use self_modulate for their visual appearance
	var empty_style = StyleBoxEmpty.new()
	for panel in left_vbox.get_children():
		if panel is Panel:
			panel.add_theme_stylebox_override("panel", empty_style)

	# ALWAYS set size_flags based on current orientation (whether we reparented or not)
	if is_portrait:
		# Set size_flags on the parent containers too
		top_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bottom_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		# And on the child containers
		left_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		left_vbox.custom_minimum_size = Vector2.ZERO
		right_vbox.custom_minimum_size = Vector2.ZERO
		left_vbox.position = Vector2.ZERO
		right_vbox.position = Vector2.ZERO
		print("ResponsiveLayout: Applied portrait size_flags to TopVBox, BottomVBox, LeftVBox, RightVBox")
	else:
		left_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		right_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		left_vbox.custom_minimum_size = Vector2(LEFT_COLUMN_WIDTH, 0)
		right_vbox.custom_minimum_size = Vector2(RIGHT_COLUMN_WIDTH, 0)
		print("ResponsiveLayout: Applied landscape size_flags (even if no reparent)")

	# Always apply mode-specific styling and scaling (even if already in correct mode)
	if is_portrait:
		# Calculate dynamic separation based on scaled element height
		var scaled_height = PORTRAIT_ELEMENT_HEIGHT * PORTRAIT_FONT_SCALE
		var dynamic_separation = max(10, int(scaled_height * PORTRAIT_SEPARATION_RATIO))
		print("ResponsiveLayout: Portrait separation = ", dynamic_separation, " (", scaled_height, " * ", PORTRAIT_SEPARATION_RATIO, ")")

		# Apply portrait styling and scaling
		left_vbox.add_theme_constant_override("separation", dynamic_separation)
		right_vbox.add_theme_constant_override("separation", dynamic_separation)
		_apply_portrait_styling()
		_scale_for_portrait(left_vbox, right_vbox)
	else:
		# Landscape mode - reset any portrait scaling
		_reset_portrait_scaling(left_vbox, right_vbox)

		# Remove portrait spacing overrides - template has default separation
		left_vbox.remove_theme_constant_override("separation")
		right_vbox.remove_theme_constant_override("separation")

		# Apply landscape HBox separation
		var separation = get_dynamic_separation(viewport_size.x)
		hbox.add_theme_constant_override("separation", separation)
		print("ResponsiveLayout: Landscape mode - using template defaults")

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

	# NOTE: HBoxContainer is now full-screen (anchor preset 15), NOT centered
	# So we don't manipulate offsets anymore - the container fills the screen
	# and the three panels (LeftVBox, CenterArea, RightVBox) handle their own sizing

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

	# Set final column widths if they need to expand
	var final_left_width = max(LEFT_COLUMN_WIDTH, max_desired_width)
	var final_right_width = max(RIGHT_COLUMN_WIDTH, max_right_width)

	if final_left_width > LEFT_COLUMN_WIDTH or final_right_width > RIGHT_COLUMN_WIDTH:
		left_vbox.custom_minimum_size = Vector2(final_left_width, 0)
		right_vbox.custom_minimum_size = Vector2(final_right_width, 0)
		print("ResponsiveLayout: Final layout - Left: ", final_left_width, " Right: ", final_right_width)
		# NOTE: HBoxContainer is full-screen, no need to adjust offsets

## Apply portrait-specific styling (title backgrounds, etc.)
func _apply_portrait_styling() -> void:
	print("ResponsiveLayout: Applying portrait styling")

	# Panels will use the default theme background, no need to override
	# The theme already provides a semi-transparent background for all panels

## Scale UI elements for portrait mode with CONSISTENT universal height
func _scale_for_portrait(left_vbox: VBoxContainer, right_vbox: VBoxContainer) -> void:
	# Calculate scaled height once
	var scaled_height = PORTRAIT_ELEMENT_HEIGHT * PORTRAIT_FONT_SCALE
	print("ResponsiveLayout: Portrait scaled height = ", scaled_height, " (", PORTRAIT_ELEMENT_HEIGHT, " * ", PORTRAIT_FONT_SCALE, ")")

	# Apply UNIVERSAL HEIGHT to all buttons and make them fill width
	for button in right_vbox.get_children():
		if button is Button:
			button.custom_minimum_size = Vector2(0, scaled_height)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Make buttons fill width
			var current_size = button.get_theme_font_size("font_size")
			if current_size <= 0:
				current_size = 25  # Default from theme
			button.add_theme_font_size_override("font_size", int(current_size * PORTRAIT_FONT_SCALE))

	# Apply HEIGHT to all panels (with special handling for progress bars)
	for panel in left_vbox.get_children():
		if panel is Panel:
			# Check if this panel has a progress bar - if so, make it taller
			var has_progress_bar = false
			for child in panel.get_children():
				if child is ProgressBar:
					has_progress_bar = true
					break

			# Progress bar panels need extra height (1.4x)
			var panel_height = scaled_height * 1.4 if has_progress_bar else scaled_height
			panel.custom_minimum_size = Vector2(0, panel_height)

			# Don't constrain size too tightly - let it grow if needed
			panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

			print("ResponsiveLayout: Set panel '", panel.name, "' size to (width, ", panel_height, ")")

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

## Reset portrait scaling to landscape defaults
func _reset_portrait_scaling(left_vbox: VBoxContainer, right_vbox: VBoxContainer) -> void:
	print("ResponsiveLayout: Resetting portrait scaling to landscape defaults")

	# Reset buttons to landscape defaults
	for button in right_vbox.get_children():
		if button is Button:
			button.custom_minimum_size = Vector2(0, LANDSCAPE_ELEMENT_HEIGHT)
			button.size_flags_horizontal = Control.SIZE_FILL  # Reset to default
			button.remove_theme_font_size_override("font_size")

	# Reset panels to landscape defaults
	for panel in left_vbox.get_children():
		if panel is Panel:
			# Don't reset custom_minimum_size - keep scene-specific heights
			# Just reset the font scaling
			panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

			for child in panel.get_children():
				if child is Label:
					child.remove_theme_font_size_override("font_size")
				elif child is ProgressBar:
					child.remove_theme_font_size_override("font_size")

## Reset UI elements to landscape/desktop defaults
func _reset_scale(left_vbox: VBoxContainer, right_vbox: VBoxContainer) -> void:
	# Reset left column to default width first
	left_vbox.custom_minimum_size = Vector2(LEFT_COLUMN_WIDTH, 0)

	# NOTE: HBoxContainer is now full-screen (anchor preset 15)
	# No need to reset offsets - the container fills the viewport
	# The three panels handle their own sizing via size_flags

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
				var viewport_width_local = left_vbox.get_viewport().get_visible_rect().size.x
				var max_width_local = viewport_width_local - RIGHT_COLUMN_WIDTH - 100  # Leave room for right column
				var desired_width = max(LEFT_COLUMN_WIDTH, text_width)
				desired_width = min(desired_width, max_width_local)

				print("ResponsiveLayout: Desired width: ", desired_width, " (min: ", LEFT_COLUMN_WIDTH, ", max: ", max_width_local, ")")

				# Set panel size with UNIVERSAL HEIGHT
				panel.custom_minimum_size = Vector2(desired_width, LANDSCAPE_ELEMENT_HEIGHT)

				# Also set the left column to match the widest title panel
				if desired_width > left_vbox.custom_minimum_size.x:
					left_vbox.custom_minimum_size = Vector2(desired_width, 0)
					print("ResponsiveLayout: Expanded left column to: ", desired_width)
					# NOTE: HBoxContainer is full-screen, no need to adjust offsets
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

## Position popups within the play area to avoid overlapping with menus
## Reparents all popups to PopupContainer and constrains their size
func position_popups_in_play_area(scene_root: Control, is_portrait: bool, popup_container: Control,
								  center_area: Control, middle_area: Control, viewport_size: Vector2) -> void:
	if not popup_container:
		print("ResponsiveLayout: No PopupContainer found, popups may overlap menus")
		return

	# Find all popup nodes in the scene (look for ReusablePopup instances)
	var popups = []
	_find_popups_recursive(scene_root, popups, popup_container)

	if popups.size() == 0:
		print("ResponsiveLayout: No popups found to position")
		return

	print("ResponsiveLayout: Found ", popups.size(), " popup(s) to position")

	# Calculate available space for popups
	var max_popup_width = 0.0
	var play_area_rect = Rect2()

	if is_portrait:
		# Portrait: use middle area space
		if middle_area:
			play_area_rect = middle_area.get_global_rect()
			max_popup_width = viewport_size.x * POPUP_MAX_WIDTH_PORTRAIT
		else:
			# Fallback to full viewport with margins
			max_popup_width = viewport_size.x * POPUP_MAX_WIDTH_PORTRAIT
	else:
		# Landscape: calculate center area width
		if center_area:
			play_area_rect = center_area.get_global_rect()
			max_popup_width = min(play_area_rect.size.x - (POPUP_MARGIN_FROM_MENUS * 2), float(POPUP_MAX_WIDTH_LANDSCAPE))
		else:
			# Fallback: viewport width minus side menus
			var available_width = viewport_size.x - LEFT_COLUMN_WIDTH - RIGHT_COLUMN_WIDTH - (POPUP_MARGIN_FROM_MENUS * 2)
			max_popup_width = min(available_width, float(POPUP_MAX_WIDTH_LANDSCAPE))

	print("ResponsiveLayout: Max popup width: ", max_popup_width, " Play area: ", play_area_rect)

	# Apply constraints to each popup
	for popup in popups:
		# Reparent to PopupContainer if not already there
		if popup.get_parent() != popup_container:
			var original_parent = popup.get_parent()
			original_parent.remove_child(popup)
			popup_container.add_child(popup)
			print("ResponsiveLayout: Reparented popup '", popup.name, "' to PopupContainer")

		# Constrain popup width
		var half_width = max_popup_width / 2.0
		popup.offset_left = -half_width
		popup.offset_right = half_width

		print("ResponsiveLayout: Constrained popup '", popup.name, "' to width: ", max_popup_width)

## Recursively find all popup nodes (excluding PopupContainer itself)
func _find_popups_recursive(node: Node, popups: Array, popup_container: Node) -> void:
	# Skip the PopupContainer itself
	if node == popup_container:
		return

	# Check if this node is a popup (Panel with theme_type_variation or script attached)
	if node is Panel:
		var is_popup = false

		# Check for PopupPanel theme variation using get method
		if node.theme_type_variation == "StyledPopup":
			is_popup = true

		# Check if it has the reusable_popup script
		var script = node.get_script()
		if script and str(script.resource_path).contains("reusable_popup.gd"):
			is_popup = true

		# Check if name contains "Popup"
		if "Popup" in node.name or "popup" in node.name:
			is_popup = true

		if is_popup:
			popups.append(node)
			print("ResponsiveLayout: Found popup: ", node.name)

	# Recurse through children
	for child in node.get_children():
		_find_popups_recursive(child, popups, popup_container)

## Apply font scaling to all popups in the PopupContainer
## This ensures popup text is properly sized for portrait mode
func apply_popup_font_scaling(popup_container: Control, is_portrait: bool) -> void:
	if not popup_container:
		return

	var popups = []
	_find_popups_recursive(popup_container, popups, popup_container)

	if popups.size() == 0:
		return

	print("ResponsiveLayout: Applying font scaling to ", popups.size(), " popup(s)")

	for popup in popups:
		# Find the message label (typically in MarginContainer/VBoxContainer/MessageLabel)
		var message_label = _find_label_in_popup(popup)
		if message_label:
			if is_portrait:
				var label_font_size = message_label.get_theme_font_size("font_size")
				if label_font_size <= 0:
					label_font_size = 25  # Default from theme
				message_label.add_theme_font_size_override("font_size", int(label_font_size * PORTRAIT_FONT_SCALE))
				print("ResponsiveLayout: Scaled popup label '", message_label.name, "' to ", int(label_font_size * PORTRAIT_FONT_SCALE))
			else:
				message_label.remove_theme_font_size_override("font_size")

		# Find and scale buttons
		_scale_popup_buttons(popup, is_portrait)

## Find the message label in a popup node
func _find_label_in_popup(popup: Node) -> Label:
	# Common path: MarginContainer/VBoxContainer/MessageLabel
	if popup.has_node("MarginContainer/VBoxContainer/MessageLabel"):
		return popup.get_node("MarginContainer/VBoxContainer/MessageLabel")

	# Fallback: search recursively for any Label
	return _find_first_label_recursive(popup)

## Recursively find the first Label node
func _find_first_label_recursive(node: Node) -> Label:
	if node is Label:
		return node

	for child in node.get_children():
		var result = _find_first_label_recursive(child)
		if result:
			return result

	return null

## Scale buttons in a popup
func _scale_popup_buttons(popup: Node, is_portrait: bool) -> void:
	# Find button container (typically MarginContainer/VBoxContainer/ButtonContainer)
	var button_container = null
	if popup.has_node("MarginContainer/VBoxContainer/ButtonContainer"):
		button_container = popup.get_node("MarginContainer/VBoxContainer/ButtonContainer")

	if not button_container:
		return

	# Calculate scaled button height
	var button_height = LANDSCAPE_ELEMENT_HEIGHT
	if is_portrait:
		button_height = PORTRAIT_ELEMENT_HEIGHT * PORTRAIT_FONT_SCALE

	# Scale all buttons
	for child in button_container.get_children():
		if child is Button:
			child.custom_minimum_size.y = button_height

			if is_portrait:
				var button_font_size = child.get_theme_font_size("font_size")
				if button_font_size <= 0:
					button_font_size = 25  # Default from theme
				child.add_theme_font_size_override("font_size", int(button_font_size * PORTRAIT_FONT_SCALE))
			else:
				child.remove_theme_font_size_override("font_size")

			print("ResponsiveLayout: Scaled popup button '", child.name, "' to height ", button_height)
