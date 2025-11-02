extends Node
## Centralized responsive layout configuration
## All scenes can reference this for consistent scaling behavior
## Change values here and all scenes will update automatically

# UNIVERSAL MENU ELEMENT HEIGHTS
# All menu items (buttons, panels, counters, titles) use the same height in each mode
# This creates a consistent, uniform appearance across all UI elements

# Portrait mode - one universal height for ALL menu elements
const PORTRAIT_ELEMENT_HEIGHT = 30
const PORTRAIT_FONT_SCALE = 1.4  # Reduced from 1.75 to save space and prevent overlap
const PORTRAIT_POPUP_BUTTON_FONT_SCALE = 1.4  # Reduced from 1.75 for better fit
const PORTRAIT_TOP_PADDING = 60  # Reduced from 100 to give more space to middle area
const PORTRAIT_BOTTOM_PADDING = 60  # Reduced from 100 to give more space to middle area

# Landscape mode - one universal height for ALL menu elements
const LANDSCAPE_ELEMENT_HEIGHT = 40

# Spacing settings
const BUTTON_MARGIN = 5  # Spacing between buttons
const LANDSCAPE_HBOX_SEPARATION = 20  # Fixed gap between columns in landscape (reduced from dynamic 20-300)
const PORTRAIT_SEPARATION_RATIO = 0.5  # Portrait separation as ratio of scaled element height (50%)

# Column widths (from template)
const LEFT_COLUMN_WIDTH = 220
const RIGHT_COLUMN_WIDTH = 260
const MIN_CENTER_WIDTH = 400  # Minimum width for center play area

# Landscape container dimensions
const LANDSCAPE_CONTAINER_HEIGHT = 700  # Total height of HBoxContainer in landscape (centered vertically)
const NOTIFICATION_BAR_HEIGHT = 100  # Height of the notification bar at bottom (landscape) or between menus (portrait)
const LANDSCAPE_TOP_PADDING = 100  # Optional top padding for center area in landscape (when space available)
const LANDSCAPE_MIN_HEIGHT_FOR_PADDING = 900  # Minimum viewport height to enable top padding

# Popup constraints
const POPUP_MIN_WIDTH_LANDSCAPE = 400  # Min popup width in landscape
const POPUP_WIDTH_RATIO_LANDSCAPE = 0.9  # Use 90% of available CenterArea width
const POPUP_MAX_WIDTH_PORTRAIT = 0.9  # Max popup width as % of viewport in portrait
const POPUP_MARGIN_FROM_MENUS = 20  # Minimum space between popup and side menus (reduced from 40)


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
	var notification_bar = scene_root.get_node_or_null("NotificationBar")

	print("ResponsiveLayout: Found nodes - BG:", background != null, " HBox:", hbox != null, " VBox:", vbox != null,
		  " Center:", center_area != null, " Middle:", middle_area != null, " NotifBar:", notification_bar != null)

	if not hbox or not vbox or not left_vbox or not right_vbox or not top_vbox or not bottom_vbox:
		push_warning("ResponsiveLayout: Scene missing required container nodes")
		return

	# Set mouse filter on play areas and popup container to IGNORE
	# IGNORE means the container itself doesn't handle events, but children can receive them
	_set_mouse_and_clip(center_area, Control.MOUSE_FILTER_IGNORE, not is_portrait, "CenterArea")
	_set_mouse_and_clip(middle_area, Control.MOUSE_FILTER_IGNORE, is_portrait, "MiddleArea")
	if popup_container:
		popup_container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Set padding heights and mouse filters
	_set_padding(scene_root, "VBoxContainer/TopPadding", PORTRAIT_TOP_PADDING if is_portrait else 0)
	_set_padding(scene_root, "VBoxContainer/BottomPadding", PORTRAIT_BOTTOM_PADDING if is_portrait else 0)

	# Set mouse filters: Background/main containers PASS, menu containers STOP
	if background:
		background.mouse_filter = Control.MOUSE_FILTER_PASS
		if background is TextureRect and background.texture == null:
			_auto_load_background(scene_root, background)

	_set_mouse_filters([hbox, vbox], Control.MOUSE_FILTER_PASS)
	_set_mouse_filters([left_vbox, right_vbox, top_vbox, bottom_vbox], Control.MOUSE_FILTER_STOP)

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
			# SHRINK_CENTER allows menus to size based on content, not full width
			left_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			right_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			# Remove custom_minimum_size entirely so containers can expand
			left_vbox.custom_minimum_size = Vector2.ZERO
			right_vbox.custom_minimum_size = Vector2.ZERO
			# Reset any positioning
			left_vbox.position = Vector2.ZERO
			right_vbox.position = Vector2.ZERO

			# CRITICAL: Use reparent() to preserve signal connections
			left_vbox.reparent(top_vbox)
			right_vbox.reparent(bottom_vbox)

			# Reparent NotificationBar into VBoxContainer between TopVBox and MiddleArea
			if notification_bar:
				notification_bar.reparent(vbox)
				if top_vbox:
					vbox.move_child(notification_bar, top_vbox.get_index() + 1)
				notification_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				notification_bar.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

			hbox.visible = false
			vbox.visible = true
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

			# Reparent in correct order: LeftVBox, CenterArea (already there), RightVBox
			if center_area and center_area.get_parent() == hbox:
				left_vbox.reparent(hbox)
				hbox.move_child(left_vbox, center_area.get_index())
				right_vbox.reparent(hbox)
			else:
				left_vbox.reparent(hbox)
				right_vbox.reparent(hbox)

			# Reparent NotificationBar to root for landscape (full-width bottom bar)
			if notification_bar:
				notification_bar.reparent(scene_root)
				notification_bar.anchor_left = 0.0
				notification_bar.anchor_right = 1.0
				notification_bar.anchor_top = 1.0
				notification_bar.anchor_bottom = 1.0
				notification_bar.offset_left = 0
				notification_bar.offset_right = 0
				notification_bar.offset_top = -NOTIFICATION_BAR_HEIGHT
				notification_bar.offset_bottom = 0
				notification_bar.grow_horizontal = Control.GROW_DIRECTION_BOTH
				notification_bar.grow_vertical = Control.GROW_DIRECTION_BEGIN

			hbox.visible = true
			vbox.visible = false

	# Position popups in the appropriate area
	position_popups_in_play_area(scene_root, is_portrait, popup_container, center_area, middle_area, viewport_size)

	# Apply font scaling to popups - search from scene_root to catch popups that were reparented
	apply_popup_font_scaling(scene_root, is_portrait)

	# CRITICAL: Hide PopupContainer after reparenting popups
	# PopupContainer should be empty now (popups moved to CenterArea/MiddleArea)
	# Even with mouse_filter=IGNORE, it's safer to hide it completely
	if popup_container:
		var any_popup_in_container = false
		for child in popup_container.get_children():
			if child is Control and child.visible:
				any_popup_in_container = true
				break

		# Hide PopupContainer if empty OR if popups were reparented to play areas
		# In landscape/portrait modes, popups should be in CenterArea/MiddleArea, not PopupContainer
		if not any_popup_in_container:
			popup_container.visible = false
			print("ResponsiveLayout: Hid PopupContainer (empty - popups reparented to play areas)")
		else:
			popup_container.visible = true
			print("ResponsiveLayout: WARNING - PopupContainer still has visible children!")

	# Remove panel backgrounds to prevent double backgrounds
	_remove_panel_backgrounds(left_vbox)

	# ALWAYS set size_flags based on current orientation (whether we reparented or not)
	if is_portrait:
		# Portrait mode: VBoxContainer fills entire screen
		vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		vbox.anchor_left = 0.0
		vbox.anchor_top = 0.0
		vbox.anchor_right = 1.0
		vbox.anchor_bottom = 1.0
		vbox.offset_left = 0
		vbox.offset_top = 0
		vbox.offset_right = 0
		vbox.offset_bottom = 0

		# Set size_flags on the parent containers too
		top_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bottom_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		# Center the menus within their parent containers
		top_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		bottom_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		# And on the child containers - SHRINK_CENTER allows menus to size based on content
		left_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		right_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		left_vbox.custom_minimum_size = Vector2.ZERO
		right_vbox.custom_minimum_size = Vector2.ZERO
		left_vbox.position = Vector2.ZERO
		right_vbox.position = Vector2.ZERO
		print("ResponsiveLayout: Applied portrait size_flags to TopVBox, BottomVBox, LeftVBox, RightVBox")
	else:
		# Landscape mode: HBoxContainer stretches from top to notification bar
		# Full width horizontally, full height minus notification bar vertically
		hbox.anchor_left = 0.0
		hbox.anchor_right = 1.0
		hbox.anchor_top = 0.0
		hbox.anchor_bottom = 1.0

		# Calculate top offset - add padding if viewport is tall enough
		var top_offset = 10  # Default small margin
		if viewport_size.y >= LANDSCAPE_MIN_HEIGHT_FOR_PADDING:
			top_offset = LANDSCAPE_TOP_PADDING
			print("ResponsiveLayout: Viewport height (", viewport_size.y, ") >= ", LANDSCAPE_MIN_HEIGHT_FOR_PADDING, " - using top padding: ", top_offset)
		else:
			print("ResponsiveLayout: Viewport height (", viewport_size.y, ") < ", LANDSCAPE_MIN_HEIGHT_FOR_PADDING, " - using minimal top offset: ", top_offset)

		# Set offsets
		hbox.offset_left = 0
		hbox.offset_right = 0
		hbox.offset_top = top_offset
		hbox.offset_bottom = -NOTIFICATION_BAR_HEIGHT  # Leave room for notification bar

		hbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
		hbox.grow_vertical = Control.GROW_DIRECTION_BOTH

		left_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		right_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		left_vbox.custom_minimum_size = Vector2(LEFT_COLUMN_WIDTH, 0)
		right_vbox.custom_minimum_size = Vector2(RIGHT_COLUMN_WIDTH, 0)

		# Vertically center menu items in left and right columns
		left_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		right_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		print("ResponsiveLayout: Set left/right menu vertical alignment to CENTER")

		# Ensure CenterArea expands to fill available space vertically
		if center_area:
			center_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
			center_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			print("ResponsiveLayout: Set CenterArea to expand vertically and horizontally")

			# Debug: wait a frame and print CenterArea's actual size
			call_deferred("_debug_print_center_area_size", center_area)

		print("ResponsiveLayout: Applied landscape full-height layout - HBox from top to notification bar")

	# Always apply mode-specific styling and scaling (even if already in correct mode)
	if is_portrait:
		# Calculate dynamic separation based on scaled element height
		var scaled_height = PORTRAIT_ELEMENT_HEIGHT * PORTRAIT_FONT_SCALE
		var dynamic_separation = max(10, int(scaled_height * PORTRAIT_SEPARATION_RATIO))
		print("ResponsiveLayout: Portrait separation = ", dynamic_separation, " (", scaled_height, " * ", PORTRAIT_SEPARATION_RATIO, ")")

		# Apply portrait styling and scaling
		left_vbox.add_theme_constant_override("separation", dynamic_separation)
		right_vbox.add_theme_constant_override("separation", dynamic_separation)
		_scale_for_portrait(left_vbox, right_vbox)
	else:
		# Landscape mode - reset any portrait scaling
		_reset_portrait_scaling(left_vbox, right_vbox)

		# Remove portrait spacing overrides - template has default separation
		left_vbox.remove_theme_constant_override("separation")
		right_vbox.remove_theme_constant_override("separation")

		# Apply landscape HBox separation - use fixed small separation to maximize CenterArea
		hbox.add_theme_constant_override("separation", LANDSCAPE_HBOX_SEPARATION)

		# Apply landscape-specific adjustments (panel sizing, word wrapping, etc.)
		_apply_landscape_adjustments(left_vbox, right_vbox, hbox)

		print("ResponsiveLayout: Landscape mode - applied landscape adjustments")

## Apply landscape-specific adjustments (title expansion, etc.)
func _apply_landscape_adjustments(left_vbox: VBoxContainer, right_vbox: VBoxContainer, _hbox: HBoxContainer) -> void:
	left_vbox.custom_minimum_size = Vector2(LEFT_COLUMN_WIDTH, 0)
	var viewport_width = left_vbox.get_viewport().get_visible_rect().size.x
	var max_width = viewport_width - RIGHT_COLUMN_WIDTH - LANDSCAPE_HBOX_SEPARATION - 100

	# Calculate panel widths
	var max_desired_width = LEFT_COLUMN_WIDTH
	for panel in left_vbox.get_children():
		if panel is Panel:
			panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
			var panel_width = _calculate_panel_width(panel, max_width)
			panel.custom_minimum_size = Vector2(panel_width, LANDSCAPE_ELEMENT_HEIGHT)
			panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			max_desired_width = max(max_desired_width, panel_width)

	# Calculate button widths
	var max_right_width = RIGHT_COLUMN_WIDTH
	for button in right_vbox.get_children():
		if button is Button:
			button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			var button_width = _calculate_text_width(button, max_width, 60)
			max_right_width = max(max_right_width, button_width)

	# Apply final widths
	left_vbox.custom_minimum_size = Vector2(max(LEFT_COLUMN_WIDTH, max_desired_width), 0)
	right_vbox.custom_minimum_size = Vector2(max(RIGHT_COLUMN_WIDTH, max_right_width), 0)

## Scale UI elements for portrait mode with CONSISTENT universal height
func _scale_for_portrait(left_vbox: VBoxContainer, right_vbox: VBoxContainer) -> void:
	# Calculate scaled height once
	var scaled_height = PORTRAIT_ELEMENT_HEIGHT * PORTRAIT_FONT_SCALE
	print("ResponsiveLayout: Portrait scaled height = ", scaled_height, " (", PORTRAIT_ELEMENT_HEIGHT, " * ", PORTRAIT_FONT_SCALE, ")")

	# Calculate max button width
	var max_button_width = _calculate_max_width(right_vbox, Button, PORTRAIT_FONT_SCALE, 60)

	# Set right_vbox to the max button width so it doesn't expand beyond content
	if max_button_width > 0:
		right_vbox.custom_minimum_size = Vector2(max_button_width, 0)

	# SECOND PASS: Apply UNIVERSAL HEIGHT and WIDTH to all buttons
	for button in right_vbox.get_children():
		if button is Button:
			button.custom_minimum_size = Vector2(max_button_width, scaled_height)
			button.size_flags_horizontal = Control.SIZE_FILL  # Fill container width but don't force expansion
			var current_size = button.get_theme_font_size("font_size")
			if current_size <= 0:
				current_size = 25  # Default from theme
			button.add_theme_font_size_override("font_size", int(current_size * PORTRAIT_FONT_SCALE))

	# Calculate max panel width
	var max_panel_width = _calculate_max_panel_width(left_vbox, PORTRAIT_FONT_SCALE, 40)

	# Set left_vbox to the max panel width so it doesn't expand beyond content
	if max_panel_width > 0:
		left_vbox.custom_minimum_size = Vector2(max_panel_width, 0)

	# SECOND PASS: Apply HEIGHT and WIDTH to all panels (all same width for consistency)
	for panel in left_vbox.get_children():
		if panel is Panel:
			# All panels use the same width (widest text) and height for consistent appearance
			panel.custom_minimum_size = Vector2(max_panel_width, scaled_height)

			# Don't constrain size too tightly - let it grow if needed
			panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			panel.size_flags_horizontal = Control.SIZE_FILL  # Fill container width but don't force expansion

			print("ResponsiveLayout: Set panel '", panel.name, "' size to (", max_panel_width, ", ", scaled_height, ")")

			# Scale labels and other children
			for child in panel.get_children():
				if child is Label:
					var label_size = child.get_theme_font_size("font_size")
					if label_size <= 0:
						label_size = 25  # Default from theme
					child.add_theme_font_size_override("font_size", int(label_size * PORTRAIT_FONT_SCALE))

					# Enable word wrapping on title labels but don't force width
					if child.name == "TitleLabel" or child.name == "Title":
						child.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
						# Remove width constraint - let it size naturally within the panel
						child.custom_minimum_size = Vector2(0, 0)
				elif child is ProgressBar:
					# Scale progress bar font size
					var bar_font_size = child.get_theme_font_size("font_size")
					if bar_font_size <= 0:
						bar_font_size = 25  # Default from theme
					child.add_theme_font_size_override("font_size", int(bar_font_size * PORTRAIT_FONT_SCALE))

## Reset portrait scaling to landscape defaults
func _reset_portrait_scaling(left_vbox: VBoxContainer, right_vbox: VBoxContainer) -> void:
	# Reset buttons
	for button in right_vbox.get_children():
		if button is Button:
			button.custom_minimum_size = Vector2(0, LANDSCAPE_ELEMENT_HEIGHT)
			button.size_flags_horizontal = Control.SIZE_FILL
			button.remove_theme_font_size_override("font_size")

	# Reset panels
	for panel in left_vbox.get_children():
		if panel is Panel:
			panel.custom_minimum_size = Vector2(0, LANDSCAPE_ELEMENT_HEIGHT)
			panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			for child in panel.get_children():
				if child is Label:
					child.remove_theme_font_size_override("font_size")
					if child.name in ["TitleLabel", "Title"]:
						child.custom_minimum_size = Vector2(0, 0)
				elif child is ProgressBar:
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
		# Landscape: use most of the center area width (90% by default)
		if center_area:
			play_area_rect = center_area.get_global_rect()
			# Use a percentage of the center area width, respecting margins
			var available_width = play_area_rect.size.x - (POPUP_MARGIN_FROM_MENUS * 2)
			max_popup_width = max(float(POPUP_MIN_WIDTH_LANDSCAPE), available_width * POPUP_WIDTH_RATIO_LANDSCAPE)
			print("ResponsiveLayout: CenterArea width: ", play_area_rect.size.x, " Available width: ", available_width, " Popup max width: ", max_popup_width)
		else:
			# Fallback: viewport width minus side menus
			var available_width = viewport_size.x - LEFT_COLUMN_WIDTH - RIGHT_COLUMN_WIDTH - (POPUP_MARGIN_FROM_MENUS * 2)
			max_popup_width = max(float(POPUP_MIN_WIDTH_LANDSCAPE), available_width * POPUP_WIDTH_RATIO_LANDSCAPE)

	print("ResponsiveLayout: Max popup width: ", max_popup_width, " Play area: ", play_area_rect)

	# Calculate max popup height - MUST fit within actual MiddleArea space
	var max_popup_height = 0.0
	if is_portrait:
		# Portrait: Calculate actual available space in MiddleArea
		# MiddleArea gets the remaining space after TopPadding, TopVBox, NotificationBar, BottomVBox, BottomPadding
		var used_height = PORTRAIT_TOP_PADDING + PORTRAIT_BOTTOM_PADDING + NOTIFICATION_BAR_HEIGHT

		# Get actual heights of TopVBox and BottomVBox
		var scene_root_node = scene_root  # Access the scene_root parameter
		var top_vbox_node = scene_root_node.get_node_or_null("VBoxContainer/TopVBox")
		var bottom_vbox_node = scene_root_node.get_node_or_null("VBoxContainer/BottomVBox")

		if top_vbox_node:
			# Force layout update to get accurate size
			top_vbox_node.force_update_transform()
			used_height += top_vbox_node.size.y

		if bottom_vbox_node:
			# Force layout update to get accurate size
			bottom_vbox_node.force_update_transform()
			used_height += bottom_vbox_node.size.y

		# Available space for MiddleArea
		var middle_area_height = max(100, viewport_size.y - used_height)
		# Use 85% of MiddleArea space to leave margin and prevent overlap
		max_popup_height = middle_area_height * 0.85

		print("ResponsiveLayout: Portrait - used_height: ", used_height, " middle_area_height: ", middle_area_height, " max_popup_height: ", max_popup_height)
	else:
		# Landscape: constrain to center area height with margins
		if center_area:
			max_popup_height = play_area_rect.size.y * 0.9  # 90% of center area
		else:
			# Fallback: 70% of viewport height
			max_popup_height = viewport_size.y * 0.7

	print("ResponsiveLayout: Max popup height: ", max_popup_height)

	# Apply constraints to each popup
	for popup in popups:
		# CRITICAL: Reparent popup to the appropriate play area to physically constrain it
		# Portrait: MiddleArea (between menus) - prevents blocking top/bottom buttons
		# Landscape: CenterArea (between side menus) - prevents blocking left/right buttons
		var target_parent = popup_container  # Default fallback
		if is_portrait and middle_area:
			target_parent = middle_area
			print("ResponsiveLayout: Will reparent popup '", popup.name, "' to MiddleArea for portrait")
		elif not is_portrait and center_area:
			target_parent = center_area
			print("ResponsiveLayout: Will reparent popup '", popup.name, "' to CenterArea for landscape")

		# Reparent if needed
		if popup.get_parent() != target_parent:
			var original_parent = popup.get_parent()
			if original_parent:
				original_parent.remove_child(popup)
			target_parent.add_child(popup)
			# CRITICAL: Boost z_index when reparenting to play areas to ensure popup appears above everything
			# Play areas are nested, so popup needs much higher z_index than SettingsOverlay (200)
			if (is_portrait and target_parent == middle_area) or (not is_portrait and target_parent == center_area):
				popup.z_index = 300
			else:
				popup.z_index = 200  # Default for PopupContainer
			print("ResponsiveLayout: Reparented popup '", popup.name, "' to ", target_parent.name, " with z_index ", popup.z_index)

		# CRITICAL: Ensure popup has STOP mouse filter so it can receive clicks
		# Without this, clicks will pass through the popup
		popup.mouse_filter = Control.MOUSE_FILTER_STOP

		# Debug: print popup state
		print("ResponsiveLayout: Set popup '", popup.name, "' mouse_filter to STOP")
		print("  - Parent: ", popup.get_parent().name if popup.get_parent() else "null")
		print("  - Visible: ", popup.visible)
		print("  - Z-index: ", popup.z_index)

		# Position popup based on parent - center it within its parent container
		if (is_portrait and popup.get_parent() == middle_area) or (not is_portrait and popup.get_parent() == center_area):
			# Popup is child of play area (MiddleArea or CenterArea)
			# Center it within the play area - coordinates are relative to parent
			popup.anchor_left = 0.5
			popup.anchor_right = 0.5
			popup.anchor_top = 0.5
			popup.anchor_bottom = 0.5

			# Set size constraints (offsets from center of play area)
			# Use most of the available width
			var half_width = max_popup_width / 2.0
			var half_height = max_popup_height / 2.0
			popup.offset_left = -half_width
			popup.offset_right = half_width
			popup.offset_top = -half_height
			popup.offset_bottom = half_height

			var parent_name = middle_area.name if popup.get_parent() == middle_area else center_area.name
			print("ResponsiveLayout: Positioned popup '", popup.name, "' in ", parent_name, " - max width: ", max_popup_width, " max height: ", max_popup_height)

			# CRITICAL: Force popup to recalculate its size now that it's in the play area
			# The popup will check its parent and resize to use available space
			if popup.has_method("_check_and_resize_for_play_area"):
				popup.call_deferred("_check_and_resize_for_play_area")
		else:
			# Fallback: popup in PopupContainer - center on viewport
			popup.anchor_left = 0.5
			popup.anchor_right = 0.5
			popup.anchor_top = 0.5
			popup.anchor_bottom = 0.5

			# Constrain popup width and height
			var half_width = max_popup_width / 2.0
			var half_height = max_popup_height / 2.0
			popup.offset_left = -half_width
			popup.offset_right = half_width
			popup.offset_top = -half_height
			popup.offset_bottom = half_height

			print("ResponsiveLayout: Positioned popup '", popup.name, "' centered on viewport (fallback)")

		print("ResponsiveLayout: Constrained popup '", popup.name, "' to size: ", max_popup_width, "x", max_popup_height)

## Debug function to print CenterArea size after layout
func _debug_print_center_area_size(center_area: Control) -> void:
	await get_tree().process_frame
	print("=== DEBUG: CenterArea size after layout ===")
	print("CenterArea size: ", center_area.size)
	print("CenterArea position: ", center_area.position)
	print("CenterArea global_position: ", center_area.global_position)
	print("CenterArea rect: ", center_area.get_rect())
	print("CenterArea global_rect: ", center_area.get_global_rect())
	print("CenterArea size_flags_horizontal: ", center_area.size_flags_horizontal)
	print("CenterArea size_flags_vertical: ", center_area.size_flags_vertical)
	print("===========================================")
	print("")

## Recursively find all popup nodes (excluding PopupContainer itself)
func _find_popups_recursive(node: Node, popups: Array, popup_container: Node) -> void:
	# Check if this node is a popup (Panel with theme_type_variation or script attached)
	# Skip the PopupContainer itself (if specified), but still recurse into its children
	if node is Panel and (popup_container == null or node != popup_container):
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

## Apply font scaling to all popups in the scene
## This ensures popup text is properly sized for portrait mode
## Searches from the given node (usually scene_root) to find all popups
func apply_popup_font_scaling(search_root: Control, is_portrait: bool) -> void:
	if not search_root:
		return

	var popups = []
	# Pass null as popup_container since we want to find all popup panels
	_find_popups_recursive(search_root, popups, null)

	if popups.size() == 0:
		return

	print("ResponsiveLayout: Applying font scaling to ", popups.size(), " popup(s)")

	for popup in popups:
		# Scale ALL labels and buttons recursively in the popup
		_scale_popup_controls_recursive(popup, is_portrait)

## Recursively scale all labels and buttons in a popup
## This works for any popup structure, not just the standard reusable_popup template
func _scale_popup_controls_recursive(node: Node, is_portrait: bool) -> void:
	# Scale labels
	if node is Label:
		if is_portrait:
			var label_font_size = node.get_theme_font_size("font_size")
			if label_font_size <= 0:
				label_font_size = 25  # Default from theme
			node.add_theme_font_size_override("font_size", int(label_font_size * PORTRAIT_FONT_SCALE))
			print("ResponsiveLayout: Scaled popup label '", node.name, "' to ", int(label_font_size * PORTRAIT_FONT_SCALE))

			# Enable word wrapping on title labels to prevent cutoff
			if node.name == "TitleLabel" or node.name == "Title":
				node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				print("ResponsiveLayout: Enabled autowrap on popup title '", node.name, "'")
		else:
			node.remove_theme_font_size_override("font_size")
			# Reset autowrap in landscape mode
			if node.name == "TitleLabel" or node.name == "Title":
				node.autowrap_mode = TextServer.AUTOWRAP_OFF

	# Scale buttons
	elif node is Button:
		# Calculate scaled button height
		var button_height = LANDSCAPE_ELEMENT_HEIGHT
		if is_portrait:
			button_height = PORTRAIT_ELEMENT_HEIGHT * PORTRAIT_POPUP_BUTTON_FONT_SCALE

		node.custom_minimum_size.y = button_height

		if is_portrait:
			var button_font_size = node.get_theme_font_size("font_size")
			if button_font_size <= 0:
				button_font_size = 25  # Default from theme
			node.add_theme_font_size_override("font_size", int(button_font_size * PORTRAIT_POPUP_BUTTON_FONT_SCALE))
		else:
			node.remove_theme_font_size_override("font_size")

		print("ResponsiveLayout: Scaled popup button '", node.name, "' to height ", button_height)

	# Recurse through children
	for child in node.get_children():
		_scale_popup_controls_recursive(child, is_portrait)

## Helper: Set mouse filter and clipping on a control node
func _set_mouse_and_clip(node: Control, mouse_filter: int, enable_clip: bool, node_name: String) -> void:
	if node:
		node.mouse_filter = mouse_filter
		node.clip_contents = enable_clip

## Helper: Set padding height and mouse filter
func _set_padding(scene_root: Control, path: String, height: float) -> void:
	var padding = scene_root.get_node_or_null(path)
	if padding:
		padding.mouse_filter = Control.MOUSE_FILTER_PASS
		padding.custom_minimum_size = Vector2(0, height)

## Helper: Set mouse filters for multiple nodes
func _set_mouse_filters(nodes: Array, filter: int) -> void:
	for node in nodes:
		if node:
			node.mouse_filter = filter

## Helper: Calculate max width for controls of a specific type
func _calculate_max_width(container: VBoxContainer, control_type, font_scale: float, padding: int) -> int:
	var max_width = 0
	for child in container.get_children():
		if is_instance_of(child, control_type):
			var font_size = child.get_theme_font_size("font_size")
			if font_size <= 0:
				font_size = 25
			var scaled_font_size = int(font_size * font_scale)
			var font = child.get_theme_font("font")
			if font:
				var text_width = font.get_string_size(child.text, HORIZONTAL_ALIGNMENT_LEFT, -1, scaled_font_size).x + padding
				max_width = max(max_width, text_width)
	return max_width

## Helper: Calculate max width for panels containing labels
func _calculate_max_panel_width(container: VBoxContainer, font_scale: float, padding: int) -> int:
	var max_width = 0
	for panel in container.get_children():
		if panel is Panel:
			for child in panel.get_children():
				if child is Label:
					var label_size = child.get_theme_font_size("font_size")
					if label_size <= 0:
						label_size = 25
					var scaled_font_size = int(label_size * font_scale)
					var font = child.get_theme_font("font")
					if font:
						var text_width = font.get_string_size(child.text, HORIZONTAL_ALIGNMENT_LEFT, -1, scaled_font_size).x + padding
						max_width = max(max_width, text_width)
	return max_width

## Helper: Remove panel backgrounds to prevent double backgrounds
func _remove_panel_backgrounds(container: VBoxContainer) -> void:
	var empty_style = StyleBoxEmpty.new()
	for panel in container.get_children():
		if panel is Panel:
			panel.add_theme_stylebox_override("panel", empty_style)

## Helper: Calculate panel width based on label content
func _calculate_panel_width(panel: Panel, max_width: int) -> int:
	var panel_width = LEFT_COLUMN_WIDTH
	for child in panel.get_children():
		if child is Label:
			child.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			var width = _calculate_text_width(child, max_width, 40)
			panel_width = max(panel_width, width)
	return panel_width

## Helper: Calculate text width for a control
func _calculate_text_width(control: Control, max_width: int, padding: int) -> int:
	var font = control.get_theme_font("font")
	var font_size = control.get_theme_font_size("font_size")
	if font_size <= 0:
		font_size = 25
	var text_width = 0
	if font and control.has_method("get") and control.get("text"):
		text_width = font.get_string_size(control.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	return clamp(text_width + padding, LEFT_COLUMN_WIDTH if control is Label else RIGHT_COLUMN_WIDTH, max_width)
