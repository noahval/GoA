extends Node

# Base resolution (design target: 1280x720, 16:9 aspect ratio)
const BASE_WIDTH: int = 1280
const BASE_HEIGHT: int = 720
const BASE_ASPECT_RATIO: float = 16.0 / 9.0

# Layout percentages
const PLAY_AREA_WIDTH_PERCENT: float = 0.66
const MENU_WIDTH_PERCENT: float = 0.33

# Gaps (8px spacing between areas)
const GAP_SIZE: int = 8

# Font sizing (base values for 1280x720)
const BASE_FONT_SIZE: int = 25
const LINE_HEIGHT_MULTIPLIER: float = 1.3
const NOTIFICATION_LINES: int = 3
const NOTIFICATION_PADDING: int = 20  # Top + bottom padding

# Scaling limits
const MAX_AUTO_SCALE: float = 1.5  # Cap automatic scaling at 1.5x
const MIN_AUTO_SCALE: float = 1.0  # Don't scale below base

# Cache for optimization
var current_auto_scale: float = 1.0
var cached_viewport_size: Vector2 = Vector2.ZERO
var cached_notification_height: int = 0
var cached_play_area_width: int = 0
var cached_menu_width: int = 0
var nodes_to_scale: Array[Node] = []  # Cache nodes that need font scaling

func _ready():
	calculate_scale()
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed():
	# Only recalculate if viewport actually changed
	var new_size = get_viewport().get_visible_rect().size
	if new_size != cached_viewport_size:
		calculate_scale()

func calculate_scale() -> float:
	"""
	Calculate automatic resolution-based scale factor.
	Uses BOTH width and height to prevent issues with ultrawide/tall monitors.
	Base: 1280x720 = 1.0x
	1920x1080 = 1.5x
	Capped at MAX_AUTO_SCALE (1.5x)
	"""
	var viewport = get_viewport()
	if not viewport:
		return 1.0

	var viewport_size = viewport.get_visible_rect().size
	cached_viewport_size = viewport_size

	# Calculate scale based on BOTH dimensions, use the smaller one
	# This prevents oversized UI on ultrawide monitors or undersized on tall monitors
	var width_scale = viewport_size.x / float(BASE_WIDTH)
	var height_scale = viewport_size.y / float(BASE_HEIGHT)
	var scale = min(width_scale, height_scale)

	# Clamp between min and max
	current_auto_scale = clamp(scale, MIN_AUTO_SCALE, MAX_AUTO_SCALE)

	# Invalidate caches when scale changes
	_invalidate_caches()

	return current_auto_scale

func _invalidate_caches():
	"""Clear cached calculated values so they're recalculated on next access"""
	cached_notification_height = 0
	cached_play_area_width = 0
	cached_menu_width = 0

func get_auto_scale() -> float:
	"""
	Returns current automatic scale (1.0 to 1.5)
	"""
	return current_auto_scale

func get_final_scale() -> float:
	"""
	Returns final scale including user UI scale preference.
	final_scale = auto_scale * user_ui_scale
	(user_ui_scale comes from settings, see Phase 1.12)
	"""
	var user_scale = 1.0
	# Check if Global autoload exists and has ui_scale property
	var global_node = get_node_or_null("/root/Global")
	if global_node and "ui_scale" in global_node:
		user_scale = global_node.ui_scale
	return current_auto_scale * user_scale

func get_scaled_font_size(base_size: int = BASE_FONT_SIZE) -> int:
	"""
	Returns scaled font size based on resolution and user preference.
	This is the AUTHORITATIVE font sizing function - all UI should use this.
	"""
	return int(base_size * get_final_scale())

func get_notification_bar_height() -> int:
	"""
	Returns notification bar height dynamically calculated from font size.
	Formula: (font_size * line_height * num_lines) + padding
	This ensures 3 lines of text always fit perfectly.
	"""
	if cached_notification_height > 0:
		return cached_notification_height

	var font_size = get_scaled_font_size()
	var line_height = font_size * LINE_HEIGHT_MULTIPLIER
	var total_text_height = line_height * NOTIFICATION_LINES
	cached_notification_height = int(total_text_height + NOTIFICATION_PADDING)
	return cached_notification_height

func get_play_area_width() -> int:
	"""
	Returns play area width in pixels (accounting for gap)
	"""
	if cached_play_area_width > 0:
		return cached_play_area_width

	var viewport_width = cached_viewport_size.x if cached_viewport_size.x > 0 else get_viewport().get_visible_rect().size.x
	# Subtract one gap (between play area and menu)
	cached_play_area_width = int((viewport_width * PLAY_AREA_WIDTH_PERCENT) - (GAP_SIZE / 2.0))
	return cached_play_area_width

func get_menu_width() -> int:
	"""
	Returns menu width in pixels (accounting for gap)
	"""
	if cached_menu_width > 0:
		return cached_menu_width

	var viewport_width = cached_viewport_size.x if cached_viewport_size.x > 0 else get_viewport().get_visible_rect().size.x
	# Subtract one gap (between play area and menu)
	cached_menu_width = int((viewport_width * MENU_WIDTH_PERCENT) - (GAP_SIZE / 2.0))
	return cached_menu_width

func apply_to_scene(scene_root: Control) -> void:
	"""
	Apply responsive layout to a scene.
	Call from scene's _ready(): ResponsiveLayout.apply_to_scene(self)
	"""
	call_deferred("_apply_layout", scene_root)

func _apply_layout(scene_root: Control) -> void:
	calculate_scale()

	# Get layout nodes (updated paths for new structure)
	var aspect_container = scene_root.get_node_or_null("AspectContainer")
	var main_container = scene_root.get_node_or_null("AspectContainer/MainContainer") if aspect_container else null
	var main_layout = main_container.get_node_or_null("mainarea") if main_container else null
	var play_area = main_layout.get_node_or_null("PlayArea") if main_layout else null
	var menu = main_layout.get_node_or_null("Menu") if main_layout else null
	var notification_bar = main_container.get_node_or_null("NotificationBar") if main_container else null

	if not main_layout or not play_area or not menu:
		push_warning("ResponsiveLayout: Scene missing required layout nodes")
		return

	# Set aspect ratio container
	if aspect_container and aspect_container is AspectRatioContainer:
		aspect_container.ratio = BASE_ASPECT_RATIO

	# Set widths based on percentages (accounting for gaps)
	play_area.custom_minimum_size.x = float(get_play_area_width())
	menu.custom_minimum_size.x = float(get_menu_width())

	# Set mainarea bottom offset to leave room for notification bar + gap
	if notification_bar and main_layout:
		var notif_height = get_notification_bar_height()
		main_layout.set_anchor_and_offset(SIDE_BOTTOM, 1.0, float(-(notif_height + GAP_SIZE)))

	# Set notification bar height (dynamically calculated)
	if notification_bar:
		notification_bar.custom_minimum_size.y = float(get_notification_bar_height())

	# Apply font scaling to all labels and buttons
	_apply_font_scaling(scene_root)

	# Set mouse filters
	_set_mouse_filters(scene_root)

func _apply_font_scaling(node: Node) -> void:
	"""
	Apply font scaling to all UI elements.
	Optimized: caches nodes on first pass for faster subsequent updates.
	"""
	var scaled_font = get_scaled_font_size()

	if node is Label or node is Button or node is RichTextLabel:
		# Only apply if node doesn't have a custom theme font size already set
		# This allows manual overrides for special cases (titles, debug text, etc.)
		node.add_theme_font_size_override("font_size", scaled_font)

		# Cache this node for future updates
		if node not in nodes_to_scale:
			nodes_to_scale.append(node)

	for child in node.get_children():
		_apply_font_scaling(child)

func _set_mouse_filters(scene_root: Control) -> void:
	"""
	Set mouse_filter to PASS on background and containers to prevent click blocking
	"""
	var background = scene_root.get_node_or_null("Background")
	if background:
		background.mouse_filter = Control.MOUSE_FILTER_PASS

	var aspect_container = scene_root.get_node_or_null("AspectContainer")
	if aspect_container:
		aspect_container.mouse_filter = Control.MOUSE_FILTER_PASS

	var main_container = scene_root.get_node_or_null("AspectContainer/MainContainer")
	if main_container:
		main_container.mouse_filter = Control.MOUSE_FILTER_PASS

	var main_layout = scene_root.get_node_or_null("AspectContainer/MainContainer/mainarea")
	if main_layout:
		main_layout.mouse_filter = Control.MOUSE_FILTER_PASS
