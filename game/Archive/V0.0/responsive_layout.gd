extends Node
## Centralized responsive layout configuration
## All scenes can reference this for consistent scaling behavior
## Change values here and all scenes will update automatically
##
## PRESERVING CUSTOM PANEL HEIGHTS:
## By default, ResponsiveLayout applies UNIFORM heights to all panels for consistency.
## If a panel needs a different height (e.g., displaying multi-line content), add this metadata:
##   metadata/_responsive_layout_preserve_height = true
## This tells ResponsiveLayout to keep the panel's custom_minimum_size.y value instead of
## applying the universal height. Use sparingly - only for panels with genuinely different
## content requirements (e.g., market rates display, multi-stat panels, etc.)

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

# Column widths (from template) - LEGACY FIXED WIDTHS
const LEFT_COLUMN_WIDTH = 220
const RIGHT_COLUMN_WIDTH = 260
const MIN_CENTER_WIDTH = 400  # Minimum width for center play area

# Landscape percentage-based widths for responsive scaling
const LANDSCAPE_LEFT_WIDTH_PERCENT = 0.25  # 25% of available width
const LANDSCAPE_CENTER_WIDTH_PERCENT = 0.50  # 50% of available width
const LANDSCAPE_RIGHT_WIDTH_PERCENT = 0.25  # 25% of available width
const LANDSCAPE_EDGE_PADDING = 25  # Padding on left and right edges
const LANDSCAPE_BASE_RESOLUTION = 1438  # Base resolution for font scaling reference
const LANDSCAPE_ENABLE_DYNAMIC_WIDTHS = true  # Enable percentage-based widths
const LANDSCAPE_ENABLE_FONT_SCALING = true  # Enable font scaling at higher resolutions
const LANDSCAPE_MIN_FONT_SCALE = 1.0  # Minimum font scale (at base resolution)
const LANDSCAPE_MAX_FONT_SCALE = 2.0  # Maximum font scale (cap for very high resolutions)

# Landscape container dimensions
const LANDSCAPE_CONTAINER_HEIGHT = 700  # Total height of HBoxContainer in landscape (centered vertically)
const NOTIFICATION_BAR_HEIGHT = 100  # Height of the notification bar at bottom (landscape) or between menus (portrait)
const LANDSCAPE_TOP_PADDING = 100  # Optional top padding for center area in landscape (when space available)
const LANDSCAPE_MIN_HEIGHT_FOR_PADDING = 900  # Minimum viewport height to enable top padding

# Popup constraints
const POPUP_MIN_WIDTH_LANDSCAPE = 400  # Min popup width in landscape
const POPUP_WIDTH_RATIO_LANDSCAPE = 0.98  # Use 98% of available CenterArea width
const POPUP_MAX_WIDTH_PORTRAIT = 0.98  # Max popup width as % of viewport in portrait
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

	# Adjust viewport size based on orientation to prevent 2x scaling in landscape
	var window = scene_root.get_window()
	var window_size = window.size if window else Vector2(1000, 2000)
	var is_portrait_window = window_size.y > window_size.x

	if window:
		if is_portrait_window:
			# Portrait: Use 2x scaled viewport
			# Calculate viewport width based on window aspect ratio (maintains 2x scale target)
			# Default 2000 height, width scales to match window aspect ratio
			var portrait_height = 2000
			var portrait_width = int((window_size.x / window_size.y) * portrait_height)
			# Clamp width to reasonable range (800-1200) for phone/tablet layouts
			portrait_width = clampi(portrait_width, 800, 1200)
			window.content_scale_size = Vector2(portrait_width, portrait_height)
			window.content_scale_factor = 1.0
			print("ResponsiveLayout: Portrait - Set viewport to ", portrait_width, "x", portrait_height, " for 2x UI scaling (window: ", window_size, ")")
		else:
			# Landscape: Use native resolution (no 2x scaling)
			# Set viewport to match actual window size
			window.content_scale_size = window_size
			window.content_scale_factor = 1.0
			print("ResponsiveLayout: Landscape - Set viewport to native ", window_size, " (1x scaling)")

	var viewport_size = scene_root.get_viewport().get_visible_rect().size
	var is_portrait = viewport_size.y > viewport_size.x
	print("ResponsiveLayout: Window size: ", window_size, " Viewport size: ", viewport_size, " Portrait: ", is_portrait)

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
		else:
			# Landscape: side by side with CenterArea in middle
			# Restore size_flags for landscape BEFORE reparenting
			# Use SIZE_FILL to ensure menus take their full allocated width (prevents CenterArea from being too wide)
			left_vbox.size_flags_horizontal = Control.SIZE_FILL
			right_vbox.size_flags_horizontal = Control.SIZE_FILL
			# Calculate dynamic widths based on viewport size and percentages
			var dynamic_left_width = LEFT_COLUMN_WIDTH
			var dynamic_right_width = RIGHT_COLUMN_WIDTH
			if LANDSCAPE_ENABLE_DYNAMIC_WIDTHS:
				var available_width = viewport_size.x - (LANDSCAPE_EDGE_PADDING * 2)
				dynamic_left_width = int(available_width * LANDSCAPE_LEFT_WIDTH_PERCENT)
				dynamic_right_width = int(available_width * LANDSCAPE_RIGHT_WIDTH_PERCENT)
				print("ResponsiveLayout: Landscape dynamic widths - Left: ", dynamic_left_width, " Right: ", dynamic_right_width, " (viewport: ", viewport_size.x, ")")
			# Apply calculated widths
			left_vbox.custom_minimum_size = Vector2(dynamic_left_width, 0)
			right_vbox.custom_minimum_size = Vector2(dynamic_right_width, 0)
			print("ResponsiveLayout: Set landscape size_flags (SIZE_FILL)")

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

		# Set offsets with horizontal padding
		var horizontal_padding = LANDSCAPE_EDGE_PADDING if LANDSCAPE_ENABLE_DYNAMIC_WIDTHS else 0
		hbox.offset_left = horizontal_padding
		hbox.offset_right = -horizontal_padding
		hbox.offset_top = top_offset
		hbox.offset_bottom = -NOTIFICATION_BAR_HEIGHT  # Leave room for notification bar
		print("ResponsiveLayout: Applied horizontal padding: ", horizontal_padding)

		hbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
		hbox.grow_vertical = Control.GROW_DIRECTION_BOTH

		# Use SIZE_EXPAND_FILL with stretch ratios to enforce 25-50-25 split
		# This ensures side menus take exactly their allocated percentage
		left_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		left_vbox.size_flags_stretch_ratio = LANDSCAPE_LEFT_WIDTH_PERCENT  # 0.25
		right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		right_vbox.size_flags_stretch_ratio = LANDSCAPE_RIGHT_WIDTH_PERCENT  # 0.25

		# Calculate dynamic widths based on viewport size and percentages (for reference)
		var dynamic_left_width = LEFT_COLUMN_WIDTH
		var dynamic_right_width = RIGHT_COLUMN_WIDTH
		if LANDSCAPE_ENABLE_DYNAMIC_WIDTHS:
			var available_width = viewport_size.x - (LANDSCAPE_EDGE_PADDING * 2)
			dynamic_left_width = int(available_width * LANDSCAPE_LEFT_WIDTH_PERCENT)
			dynamic_right_width = int(available_width * LANDSCAPE_RIGHT_WIDTH_PERCENT)
			print("ResponsiveLayout: === LANDSCAPE WIDTH DEBUG ===")
			print("ResponsiveLayout: Using stretch ratios for 25-50-25 split")
			print("ResponsiveLayout: Viewport size: ", viewport_size)
			print("ResponsiveLayout: Window size: ", scene_root.get_window().size if scene_root.get_window() else "N/A")
			print("ResponsiveLayout: Content scale: ", scene_root.get_window().content_scale_factor if scene_root.get_window() else "N/A")
			print("ResponsiveLayout: Available width: ", available_width, " (viewport minus ", LANDSCAPE_EDGE_PADDING*2, "px padding)")
			print("ResponsiveLayout: Left stretch_ratio: ", LANDSCAPE_LEFT_WIDTH_PERCENT)
			print("ResponsiveLayout: Center stretch_ratio: ", LANDSCAPE_CENTER_WIDTH_PERCENT)
			print("ResponsiveLayout: Right stretch_ratio: ", LANDSCAPE_RIGHT_WIDTH_PERCENT)
			print("ResponsiveLayout: Expected Left: ", dynamic_left_width, " (", LANDSCAPE_LEFT_WIDTH_PERCENT*100, "%)")
			print("ResponsiveLayout: Expected Right: ", dynamic_right_width, " (", LANDSCAPE_RIGHT_WIDTH_PERCENT*100, "%)")
			print("ResponsiveLayout: Expected center: ~", int(available_width * LANDSCAPE_CENTER_WIDTH_PERCENT), " (", LANDSCAPE_CENTER_WIDTH_PERCENT*100, "%)")
			print("ResponsiveLayout: ================================")
		# Keep custom_minimum_size as a fallback, but stretch_ratio is now primary control
		left_vbox.custom_minimum_size = Vector2(dynamic_left_width, 0)
		right_vbox.custom_minimum_size = Vector2(dynamic_right_width, 0)

		# Vertically center menu items in left and right columns
		left_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		right_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		print("ResponsiveLayout: Set left/right menu vertical alignment to CENTER")

		# Ensure CenterArea expands to fill available space with proper stretch ratio
		if center_area:
			center_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
			center_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			center_area.size_flags_stretch_ratio = LANDSCAPE_CENTER_WIDTH_PERCENT  # 0.50
			print("ResponsiveLayout: Set CenterArea to expand with stretch_ratio ", LANDSCAPE_CENTER_WIDTH_PERCENT)

			# Debug: wait a frame and print CenterArea's actual size
			call_deferred("_debug_print_center_area_size", center_area)

		print("ResponsiveLayout: Applied landscape full-height layout - HBox from top to notification bar")

	# Enforce button hierarchy - sort buttons by type (Action, Forward Nav, Back Nav)
	# This ensures buttons are always in the correct order across all scenes
	_sort_buttons_by_hierarchy(left_vbox, right_vbox, top_vbox, bottom_vbox, is_portrait)

	# CRITICAL: Wait for layout to update after setting stretch ratios
	# This ensures CenterArea has the correct 50% width before positioning popups
	if not is_portrait:
		await get_tree().process_frame
		print("ResponsiveLayout: Waited for layout update after stretch ratios")

	# Position popups AFTER layout is configured and has updated
	# This ensures CenterArea/MiddleArea have correct sizes
	position_popups_in_play_area(scene_root, is_portrait, popup_container, center_area, middle_area, viewport_size)

	# Apply font scaling to popups - search from scene_root to catch popups that were reparented
	apply_popup_font_scaling(scene_root, is_portrait, viewport_size)

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
		# Landscape mode - reset any portrait scaling and apply landscape font scaling
		_reset_portrait_scaling(left_vbox, right_vbox, viewport_size.x)

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
	var viewport_width = left_vbox.get_viewport().get_visible_rect().size.x

	print("\n=== LANDSCAPE ADJUSTMENTS DEBUG ===")
	print("RightVBox current size BEFORE adjustments: ", right_vbox.size)
	print("RightVBox current custom_minimum_size BEFORE: ", right_vbox.custom_minimum_size)

	# Calculate base widths (dynamic if enabled, otherwise use legacy constants)
	var base_left_width = LEFT_COLUMN_WIDTH
	var base_right_width = RIGHT_COLUMN_WIDTH
	if LANDSCAPE_ENABLE_DYNAMIC_WIDTHS:
		var available_width = viewport_width - (LANDSCAPE_EDGE_PADDING * 2)
		base_left_width = int(available_width * LANDSCAPE_LEFT_WIDTH_PERCENT)
		base_right_width = int(available_width * LANDSCAPE_RIGHT_WIDTH_PERCENT)
		print("Target right width (25%): ", base_right_width)

	# Calculate landscape font scale and scaled element height
	var landscape_font_scale = get_landscape_font_scale(viewport_width)
	var scaled_element_height = LANDSCAPE_ELEMENT_HEIGHT * landscape_font_scale

	left_vbox.custom_minimum_size = Vector2(base_left_width, 0)
	var max_width = viewport_width - base_right_width - LANDSCAPE_HBOX_SEPARATION - 100

	# Calculate panel widths
	var max_desired_width = base_left_width
	for panel in left_vbox.get_children():
		if panel is Panel:
			panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
			var panel_width = _calculate_panel_width(panel, max_width)

			# Check if panel wants to preserve its custom height
			var panel_height = scaled_element_height
			if panel.has_meta("_responsive_layout_preserve_height") and panel.get_meta("_responsive_layout_preserve_height"):
				panel_height = panel.custom_minimum_size.y
				print("ResponsiveLayout: Preserving custom height ", panel_height, " for panel '", panel.name, "' in landscape initial pass")

			panel.custom_minimum_size = Vector2(panel_width, panel_height)
			panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			max_desired_width = max(max_desired_width, panel_width)

	# Enable button wrapping and constrain to base width (DON'T expand menu)
	# Buttons will wrap to multiple lines instead of pushing menu wider
	for button in right_vbox.get_children():
		if button is Button:
			button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

			# Check if button wants to preserve its custom height
			var button_height = scaled_element_height
			if button.has_meta("_responsive_layout_preserve_height") and button.get_meta("_responsive_layout_preserve_height"):
				button_height = button.custom_minimum_size.y
				print("ResponsiveLayout: Preserving custom height ", button_height, " for button")

			button.custom_minimum_size = Vector2(0, button_height)
			button.size_flags_horizontal = Control.SIZE_FILL
			print("ResponsiveLayout: Button '", button.text.substr(0, 30), "...' autowrap enabled, height: ", button_height)

	# Apply final widths - RESPECT stretch ratios by NOT expanding beyond base widths
	# Left menu can expand for long panel text, but right menu stays at 25% (buttons wrap instead)
	left_vbox.custom_minimum_size = Vector2(max(base_left_width, max_desired_width), 0)
	right_vbox.custom_minimum_size = Vector2(base_right_width, 0)  # DON'T expand - force wrapping

	print("RightVBox final custom_minimum_size: ", right_vbox.custom_minimum_size)
	print("=== END LANDSCAPE ADJUSTMENTS DEBUG ===\n")

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
			# Check if button wants to preserve its custom height
			var button_height = scaled_height
			if button.has_meta("_responsive_layout_preserve_height") and button.get_meta("_responsive_layout_preserve_height"):
				button_height = button.custom_minimum_size.y
				print("ResponsiveLayout: Preserving custom height ", button_height, " for button (portrait)")

			button.custom_minimum_size = Vector2(max_button_width, button_height)
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
			# Check if this is a CurrencyPanel (has custom icon sizing logic)
			if panel.has_method("update_icon_sizes_for_orientation"):
				# CurrencyPanel - let it handle its own icon sizing
				panel.update_icon_sizes_for_orientation(true)  # true = portrait
				print("ResponsiveLayout: Updated CurrencyPanel '", panel.name, "' for portrait mode")

			# Check if panel wants to preserve its custom height
			if panel.has_meta("_responsive_layout_preserve_height") and panel.get_meta("_responsive_layout_preserve_height"):
				print("ResponsiveLayout: Preserving custom height for panel '", panel.name, "'")
				# Only set width, keep existing height
				var current_height = panel.custom_minimum_size.y
				panel.custom_minimum_size = Vector2(max_panel_width, current_height)
			else:
				# All panels use the same width (widest text) and height for consistent appearance
				panel.custom_minimum_size = Vector2(max_panel_width, scaled_height)

			# Don't constrain size too tightly - let it grow if needed
			panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			panel.size_flags_horizontal = Control.SIZE_FILL  # Fill container width but don't force expansion

			print("ResponsiveLayout: Set panel '", panel.name, "' size to (", max_panel_width, ", ", scaled_height, ")")

			# Scale labels and other children (skip CurrencyPanel internals - it handles itself)
			if not panel.has_method("update_icon_sizes_for_orientation"):
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

## Reset portrait scaling to landscape defaults and apply landscape font scaling
func _reset_portrait_scaling(left_vbox: VBoxContainer, right_vbox: VBoxContainer, viewport_width: float = 0) -> void:
	# Calculate landscape font scale
	var landscape_font_scale = get_landscape_font_scale(viewport_width) if viewport_width > 0 else 1.0
	print("ResponsiveLayout: Landscape font scale = ", landscape_font_scale)

	# Calculate scaled element height
	var scaled_element_height = LANDSCAPE_ELEMENT_HEIGHT * landscape_font_scale

	# Reset buttons with landscape font scaling
	for button in right_vbox.get_children():
		if button is Button:
			button.custom_minimum_size = Vector2(0, scaled_element_height)
			button.size_flags_horizontal = Control.SIZE_FILL
			if LANDSCAPE_ENABLE_FONT_SCALING and landscape_font_scale > 1.0:
				var current_size = button.get_theme_font_size("font_size")
				if current_size <= 0:
					current_size = 25  # Default from theme
				button.add_theme_font_size_override("font_size", int(current_size * landscape_font_scale))
			else:
				button.remove_theme_font_size_override("font_size")

	# Reset panels with landscape font scaling
	for panel in left_vbox.get_children():
		if panel is Panel:
			# Check if this is a CurrencyPanel (has custom icon sizing logic)
			if panel.has_method("update_icon_sizes_for_orientation"):
				# CurrencyPanel - let it handle its own icon sizing
				panel.update_icon_sizes_for_orientation(false)  # false = landscape
				print("ResponsiveLayout: Updated CurrencyPanel '", panel.name, "' for landscape mode")

			# Check if panel wants to preserve its custom height
			if panel.has_meta("_responsive_layout_preserve_height") and panel.get_meta("_responsive_layout_preserve_height"):
				print("ResponsiveLayout: Preserving custom height for panel '", panel.name, "' in landscape")
				# Keep existing height, just reset width to 0 (auto)
				var current_height = panel.custom_minimum_size.y
				panel.custom_minimum_size = Vector2(0, current_height)
			else:
				panel.custom_minimum_size = Vector2(0, scaled_element_height)
			panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

			# Scale children (skip CurrencyPanel internals - it handles itself)
			if not panel.has_method("update_icon_sizes_for_orientation"):
				for child in panel.get_children():
					if child is Label:
						if LANDSCAPE_ENABLE_FONT_SCALING and landscape_font_scale > 1.0:
							var label_size = child.get_theme_font_size("font_size")
							if label_size <= 0:
								label_size = 25  # Default from theme
							child.add_theme_font_size_override("font_size", int(label_size * landscape_font_scale))
						else:
							child.remove_theme_font_size_override("font_size")
						if child.name in ["TitleLabel", "Title"]:
							child.custom_minimum_size = Vector2(0, 0)
					elif child is ProgressBar:
						if LANDSCAPE_ENABLE_FONT_SCALING and landscape_font_scale > 1.0:
							var bar_font_size = child.get_theme_font_size("font_size")
							if bar_font_size <= 0:
								bar_font_size = 25  # Default from theme
							child.add_theme_font_size_override("font_size", int(bar_font_size * landscape_font_scale))
						else:
							child.remove_theme_font_size_override("font_size")

## Check if viewport is in portrait orientation
static func is_portrait_mode(viewport: Viewport) -> bool:
	var size = viewport.get_visible_rect().size
	return size.y > size.x

## Get current scaling factor based on orientation
static func get_font_scale(viewport: Viewport) -> float:
	return PORTRAIT_FONT_SCALE if is_portrait_mode(viewport) else 1.0

## Calculate landscape font scale based on viewport width
## Scales proportionally between base resolution and higher resolutions
static func get_landscape_font_scale(viewport_width: float) -> float:
	if not LANDSCAPE_ENABLE_FONT_SCALING:
		return 1.0
	# Calculate scale factor: viewport_width / base_resolution
	var scale = viewport_width / LANDSCAPE_BASE_RESOLUTION
	# Clamp between min and max scale
	return clamp(scale, LANDSCAPE_MIN_FONT_SCALE, LANDSCAPE_MAX_FONT_SCALE)

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

			# DEBUG: Check CenterArea sizing
			print("\n=== LANDSCAPE CENTER AREA DEBUG ===")
			print("Viewport width: ", viewport_size.x)
			print("Expected center width (50%): ", viewport_size.x * 0.5)
			print("CenterArea actual width: ", play_area_rect.size.x)
			print("CenterArea actual width %: ", (play_area_rect.size.x / viewport_size.x) * 100, "%")
			print("CenterArea size_flags_horizontal: ", center_area.size_flags_horizontal)
			print("CenterArea custom_minimum_size: ", center_area.custom_minimum_size)

			# Check sibling menu widths
			var left_vbox = scene_root.get_node_or_null("HBoxContainer/LeftVBox")
			var right_vbox = scene_root.get_node_or_null("HBoxContainer/RightVBox")
			if left_vbox:
				print("LeftVBox actual width: ", left_vbox.size.x, " (", (left_vbox.size.x / viewport_size.x) * 100, "%)")
				print("LeftVBox custom_minimum_size: ", left_vbox.custom_minimum_size)
			if right_vbox:
				print("RightVBox actual width: ", right_vbox.size.x, " (", (right_vbox.size.x / viewport_size.x) * 100, "%)")
				print("RightVBox custom_minimum_size: ", right_vbox.custom_minimum_size)
			print("=== END CENTER AREA DEBUG ===\n")

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
		# Use 98% of MiddleArea space to leave margin and prevent overlap
		max_popup_height = middle_area_height * 0.98

		print("ResponsiveLayout: Portrait - used_height: ", used_height, " middle_area_height: ", middle_area_height, " max_popup_height: ", max_popup_height)
	else:
		# Landscape: constrain to center area height with margins
		if center_area:
			max_popup_height = play_area_rect.size.y * 0.98  # 98% of center area
		else:
			# Fallback: 70% of viewport height
			max_popup_height = viewport_size.y * 0.7

	print("ResponsiveLayout: Max popup height: ", max_popup_height)

	# Apply constraints to each popup
	for popup in popups:
		var is_minimal = popup.has_meta("responsive_minimal") and popup.get_meta("responsive_minimal")
		var debug_prefix = " [MINIMAL]" if is_minimal else ""

		print("\n=== ResponsiveLayout: Processing popup '", popup.name, "'", debug_prefix, " ===")
		print("Max popup width: ", max_popup_width)
		print("Max popup height: ", max_popup_height)
		print("Current popup size: ", popup.size)
		print("Current popup offsets: L=", popup.offset_left, " R=", popup.offset_right, " T=", popup.offset_top, " B=", popup.offset_bottom)

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

		# CRITICAL: Enable clip_contents to enforce size constraints
		# Without this, child controls can push the popup wider than the offsets
		popup.clip_contents = true

		# CRITICAL: Set size flags to prevent expansion beyond offset constraints
		# SIZE_SHRINK_BEGIN prevents the popup from expanding to fit oversized children
		popup.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		popup.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

		# Debug: print popup state
		print("ResponsiveLayout: Set popup '", popup.name, "' mouse_filter to STOP, clip_contents to TRUE")
		print("  - Parent: ", popup.get_parent().name if popup.get_parent() else "null")
		print("  - Visible: ", popup.visible)
		print("  - Z-index: ", popup.z_index)
		print("  - clip_contents: ", popup.clip_contents)
		print("  - custom_minimum_size: ", popup.custom_minimum_size)

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
			print("ResponsiveLayout: Set offsets: L=", popup.offset_left, " R=", popup.offset_right, " T=", popup.offset_top, " B=", popup.offset_bottom)
			print("ResponsiveLayout: Calculated width from offsets: ", popup.offset_right - popup.offset_left)

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
			print("ResponsiveLayout: Set offsets: L=", popup.offset_left, " R=", popup.offset_right, " T=", popup.offset_top, " B=", popup.offset_bottom)
			print("ResponsiveLayout: Calculated width from offsets: ", popup.offset_right - popup.offset_left)

		print("ResponsiveLayout: Constrained popup '", popup.name, "' to size: ", max_popup_width, "x", max_popup_height)

		# Defer width verification to next frame after layout completes
		call_deferred("_verify_popup_width", popup, max_popup_width)

		print("=== END ResponsiveLayout popup processing ===\n")

## Verify popup width matches intended constraints
func _verify_popup_width(popup: Control, intended_width: float) -> void:
	# Wait for layout to complete
	await get_tree().process_frame
	await get_tree().process_frame

	var actual_width = popup.size.x
	var offset_width = popup.offset_right - popup.offset_left
	var width_diff = actual_width - intended_width

	print("\n=== POPUP WIDTH VERIFICATION: ", popup.name, " ===")
	print("Intended width: ", intended_width)
	print("Offset width: ", offset_width)
	print("Actual rendered width: ", actual_width)
	print("Difference: ", width_diff, " pixels")
	print("clip_contents: ", popup.clip_contents)
	print("size_flags_horizontal: ", popup.size_flags_horizontal)

	if abs(width_diff) > 10:  # Allow 10px tolerance
		push_warning("PopupSystem: Popup '", popup.name, "' width mismatch! Intended: ", intended_width, " Actual: ", actual_width, " Diff: ", width_diff)

		# Find widest child
		var widest_child = null
		var widest_width = 0.0
		_find_widest_child_recursive(popup, widest_child, widest_width)

		if widest_child:
			print("Widest child: ", widest_child.name, " (", widest_child.get_class(), ") width: ", widest_width)
	else:
		print("Width verification PASSED!")

	print("=== END POPUP WIDTH VERIFICATION ===\n")

## Helper to find the widest child control recursively
func _find_widest_child_recursive(node: Node, widest: Control, widest_width: float) -> void:
	if node is Control:
		var control = node as Control
		if control.size.x > widest_width:
			widest = control
			widest_width = control.size.x

	for child in node.get_children():
		_find_widest_child_recursive(child, widest, widest_width)

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
## This ensures popup text is properly sized for both portrait and landscape modes
## Searches from the given node (usually scene_root) to find all popups
func apply_popup_font_scaling(search_root: Control, is_portrait: bool, viewport_size: Vector2) -> void:
	if not search_root:
		return

	var popups = []
	# Pass null as popup_container since we want to find all popup panels
	_find_popups_recursive(search_root, popups, null)

	if popups.size() == 0:
		return

	print("ResponsiveLayout: Applying font scaling to ", popups.size(), " popup(s)")

	for popup in popups:
		# Check if popup requests minimal processing
		if popup.has_meta("responsive_minimal") and popup.get_meta("responsive_minimal"):
			print("ResponsiveLayout: Skipping internal processing for '", popup.name, "' (responsive_minimal=true)")
			continue

		# Scale ALL labels and buttons recursively in the popup
		_scale_popup_controls_recursive(popup, is_portrait, viewport_size, popup)
		# Debug: Measure actual sizes after a frame
		if popup.visible:
			call_deferred("_debug_measure_popup_overflow", popup)

## Recursively scale all labels and buttons in a popup
## This works for any popup structure, not just the standard reusable_popup template
func _scale_popup_controls_recursive(node: Node, is_portrait: bool, viewport_size: Vector2, popup_panel: Panel) -> void:
	# Calculate landscape font scale for non-portrait mode
	var landscape_font_scale = 1.0
	if not is_portrait:
		landscape_font_scale = get_landscape_font_scale(viewport_size.x)

	# Calculate available width for label wrapping
	# Use the popup's CONSTRAINED width from offsets (set by responsive layout)
	# NOT the rendered size.x which may have already expanded
	var popup_constrained_width = 400.0  # Default fallback
	if popup_panel:
		# Width from offsets: right - left (both are relative to anchor point at 0.5)
		popup_constrained_width = popup_panel.offset_right - popup_panel.offset_left
		print("ResponsiveLayout: Popup '", popup_panel.name, "' constrained width from offsets: ", popup_constrained_width)

	# Account for MarginContainer margins (10px left + 10px right = 20px)
	# Plus some buffer for ScrollContainer padding and safety (20px)
	var available_width = max(200, popup_constrained_width - 40)  # Minimum 200px
	print("ResponsiveLayout: Available width for labels: ", available_width)

	# Scale labels
	if node is Label:
		# Label behavior depends on parent container
		var label_parent = node.get_parent()
		if label_parent and label_parent is HBoxContainer:
			# Labels in HBoxContainer should display on single line
			# Autowrap causes character-by-character wrapping when constrained
			node.autowrap_mode = TextServer.AUTOWRAP_OFF
			node.size_flags_horizontal = Control.SIZE_SHRINK_CENTER  # Shrink to content width
			node.size_flags_vertical = Control.SIZE_SHRINK_CENTER  # Shrink to content height
			node.clip_text = true  # Clip if too long
			print("ResponsiveLayout: Label '", node.name, "' in HBoxContainer set to single-line mode")
		else:
			# Labels in VBoxContainer should wrap text
			node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			node.custom_minimum_size = Vector2(0, 0)
			node.size_flags_horizontal = Control.SIZE_FILL  # Fill available width
			node.size_flags_vertical = Control.SIZE_EXPAND_FILL  # Expand vertically as text wraps
			node.clip_text = false  # Don't clip - let text wrap

		# CRITICAL: Constrain parent containers to prevent pushing popup wider
		var parent = node.get_parent()
		while parent and parent != popup_panel:
			if parent is ScrollContainer:
				# Ensure horizontal scrolling is disabled
				parent.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
				# Constrain width
				parent.custom_minimum_size.x = 0  # Don't force minimum
				parent.size_flags_horizontal = Control.SIZE_FILL  # Fill available space
				print("ResponsiveLayout: Constrained ScrollContainer to FILL (no horizontal scroll)")
			elif parent is VBoxContainer or parent is MarginContainer or parent is HBoxContainer:
				# Check if this container is a direct child of a ScrollContainer
				var grandparent = parent.get_parent()
				if grandparent is ScrollContainer:
					# Direct child of ScrollContainer needs EXPAND_FILL to fill ScrollContainer width
					parent.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					print("ResponsiveLayout: Set ", parent.get_class(), " to EXPAND_FILL (child of ScrollContainer)")
				else:
					# Other containers: constrain to prevent expansion
					parent.size_flags_horizontal = Control.SIZE_FILL  # Fill available space, don't expand
					print("ResponsiveLayout: Constrained ", parent.get_class(), " to FILL")
			parent = parent.get_parent()

		print("ResponsiveLayout: Constrained label '", node.name, "' and parents to ", available_width, "px width (wrapping enabled)")

		if is_portrait:
			var label_font_size = node.get_theme_font_size("font_size")
			if label_font_size <= 0:
				label_font_size = 25  # Default from theme
			node.add_theme_font_size_override("font_size", int(label_font_size * PORTRAIT_FONT_SCALE))
			print("ResponsiveLayout: Scaled popup label '", node.name, "' to ", int(label_font_size * PORTRAIT_FONT_SCALE), " width: ", available_width, " (autowrap enabled)")
		else:
			# Landscape mode - apply landscape font scaling
			if LANDSCAPE_ENABLE_FONT_SCALING and landscape_font_scale > 1.0:
				var label_font_size = node.get_theme_font_size("font_size")
				if label_font_size <= 0:
					label_font_size = 25  # Default from theme
				node.add_theme_font_size_override("font_size", int(label_font_size * landscape_font_scale))
				print("ResponsiveLayout: Scaled popup label '", node.name, "' to ", int(label_font_size * landscape_font_scale), " width: ", available_width, " (landscape scale: ", landscape_font_scale, ", autowrap enabled)")
			else:
				node.remove_theme_font_size_override("font_size")
				print("ResponsiveLayout: Popup label '", node.name, "' using default font size, width: ", available_width, " (autowrap enabled)")

	# Scale buttons
	elif node is Button:
		# Calculate scaled button height
		var button_height = LANDSCAPE_ELEMENT_HEIGHT
		if is_portrait:
			button_height = PORTRAIT_ELEMENT_HEIGHT * PORTRAIT_POPUP_BUTTON_FONT_SCALE
		else:
			# Apply landscape font scaling to button height
			button_height = LANDSCAPE_ELEMENT_HEIGHT * landscape_font_scale

		node.custom_minimum_size.y = button_height

		# Button width behavior depends on parent container:
		# - Buttons in VBoxContainer (vertical stack, like quiz answers): expand to fill width
		# - Buttons in HBoxContainer (horizontal row, like OK/Cancel): shrink to content
		var button_parent = node.get_parent()
		if button_parent and button_parent is VBoxContainer:
			# Vertically stacked buttons should fill available width
			node.size_flags_horizontal = Control.SIZE_FILL
			# Enable word wrapping for long text (like quiz answers)
			node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			node.clip_text = false
			print("ResponsiveLayout: Button '", node.name, "' in VBoxContainer set to FILL width with word wrap")
		else:
			# Horizontal button rows should shrink to content
			node.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			node.size_flags_stretch_ratio = 0.0

		if is_portrait:
			var button_font_size = node.get_theme_font_size("font_size")
			if button_font_size <= 0:
				button_font_size = 25  # Default from theme
			node.add_theme_font_size_override("font_size", int(button_font_size * PORTRAIT_POPUP_BUTTON_FONT_SCALE))
		else:
			# Landscape mode - apply landscape font scaling
			if LANDSCAPE_ENABLE_FONT_SCALING and landscape_font_scale > 1.0:
				var button_font_size = node.get_theme_font_size("font_size")
				if button_font_size <= 0:
					button_font_size = 25  # Default from theme
				node.add_theme_font_size_override("font_size", int(button_font_size * landscape_font_scale))
				print("ResponsiveLayout: Scaled popup button '", node.name, "' to ", int(button_font_size * landscape_font_scale), " (landscape scale: ", landscape_font_scale, ")")
			else:
				node.remove_theme_font_size_override("font_size")

		print("ResponsiveLayout: Scaled popup button '", node.name, "' to height ", button_height)

	# Handle LineEdit controls to prevent infinite expansion in HBoxContainers
	elif node is LineEdit:
		var lineedit_parent = node.get_parent()
		if lineedit_parent and lineedit_parent is HBoxContainer:
			# LineEdit in HBoxContainer should fill available space but not expand infinitely
			# Remove SIZE_EXPAND flag (value 3) and use SIZE_FILL only (value 1)
			node.size_flags_horizontal = Control.SIZE_FILL
			node.size_flags_stretch_ratio = 1.0
			print("ResponsiveLayout: LineEdit '", node.name, "' in HBoxContainer set to SIZE_FILL (no expand)")

	# Handle OptionButton controls to prevent infinite expansion in HBoxContainers
	elif node is OptionButton:
		var optionbutton_parent = node.get_parent()
		if optionbutton_parent and optionbutton_parent is HBoxContainer:
			# OptionButton in HBoxContainer should fill available space but not expand infinitely
			node.size_flags_horizontal = Control.SIZE_FILL
			node.size_flags_stretch_ratio = 1.0
			print("ResponsiveLayout: OptionButton '", node.name, "' in HBoxContainer set to SIZE_FILL (no expand)")

	# Recurse through children
	for child in node.get_children():
		_scale_popup_controls_recursive(child, is_portrait, viewport_size, popup_panel)

## Debug function to measure popup overflow issues
func _debug_measure_popup_overflow(popup: Panel) -> void:
	await get_tree().process_frame
	await get_tree().process_frame  # Wait 2 frames for layout to settle

	print("\n=== POPUP OVERFLOW DEBUG: ", popup.name, " ===")
	print("Popup constrained width (offsets): ", popup.offset_right - popup.offset_left)
	print("Popup actual rendered size: ", popup.size)
	print("Popup position: ", popup.position)
	print("Popup global_position: ", popup.global_position)

	# Measure all children recursively
	_debug_measure_node_recursive(popup, popup, 0)
	print("=== END POPUP DEBUG ===\n")

## Recursively measure all nodes in popup
func _debug_measure_node_recursive(node: Node, popup: Panel, depth: int) -> void:
	if not node is Control:
		return

	var control = node as Control
	var indent = "  ".repeat(depth)
	var popup_width = popup.offset_right - popup.offset_left
	var overflow = control.size.x - popup_width
	var overflow_marker = " ⚠️ OVERFLOW!" if overflow > 5 else ""

	print(indent, control.get_class(), " '", control.name, "':")
	print(indent, "  Size: ", control.size, overflow_marker)
	print(indent, "  Position: ", control.position)
	print(indent, "  Size flags H: ", control.size_flags_horizontal, " V: ", control.size_flags_vertical)
	print(indent, "  Custom min size: ", control.custom_minimum_size)

	if control is Label:
		print(indent, "  Autowrap: ", control.autowrap_mode)
		print(indent, "  Text length: ", len(control.text))
	elif control is Button:
		print(indent, "  Text: '", control.text, "'")
	elif control is HBoxContainer:
		print(indent, "  Alignment: ", control.alignment)
		print(indent, "  Separation: ", control.get("theme_override_constants/separation"))

	# Recurse
	for child in control.get_children():
		_debug_measure_node_recursive(child, popup, depth + 1)

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
			# Check if this is a CurrencyPanel with custom width calculation
			if panel.has_method("calculate_minimum_width"):
				var panel_width = int(panel.calculate_minimum_width())
				max_width = max(max_width, panel_width)
				print("ResponsiveLayout: CurrencyPanel '", panel.name, "' calculated width: ", panel_width)
			else:
				# Standard panel - measure labels
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

## Sort buttons in containers according to ButtonHierarchy
## This enforces consistent button ordering across all scenes
## Called automatically by apply_to_scene() - no need for individual scenes to implement
func _sort_buttons_by_hierarchy(left_vbox: VBoxContainer, right_vbox: VBoxContainer,
								 top_vbox: VBoxContainer, bottom_vbox: VBoxContainer,
								 is_portrait: bool) -> void:
	# Determine which containers to sort based on orientation
	var containers_to_sort = []
	if is_portrait:
		# Portrait: buttons are in top_vbox and bottom_vbox
		if top_vbox:
			containers_to_sort.append(top_vbox)
		if bottom_vbox:
			containers_to_sort.append(bottom_vbox)
	else:
		# Landscape: buttons are in left_vbox and right_vbox
		if left_vbox:
			containers_to_sort.append(left_vbox)
		if right_vbox:
			containers_to_sort.append(right_vbox)

	# Sort buttons in each container
	for container in containers_to_sort:
		# Collect all buttons
		var buttons = []
		for child in container.get_children():
			if child is Button:
				buttons.append(child)

		if buttons.size() == 0:
			continue

		# Sort by hierarchy (Action -> Forward Nav -> Back Nav -> Developer)
		ButtonHierarchy.sort_buttons_by_hierarchy(buttons)

		# Reorder in container by moving each button to its correct position
		for i in range(buttons.size()):
			container.move_child(buttons[i], i)

		# Validate order in debug mode
		if OS.is_debug_build():
			var validation = ButtonHierarchy.validate_button_order(container)
			if not validation.valid:
				push_warning("ResponsiveLayout: Button order issues in container '", container.name, "':")
				for issue in validation.issues:
					push_warning("  - " + issue)
			else:
				print("ResponsiveLayout: Button hierarchy validated for '", container.name, "' (", buttons.size(), " buttons)")
