extends Control

@onready var coal_container: Node2D = $AspectContainer/MainContainer/mainarea/PlayArea/CoalContainer
@onready var furnace_wall: Node2D = $AspectContainer/MainContainer/mainarea/PlayArea/FurnaceWall
@onready var playarea: Control = $AspectContainer/MainContainer/mainarea/PlayArea
@onready var shovel_body: RigidBody2D = $AspectContainer/MainContainer/mainarea/PlayArea/Shovel/RigidBody2D
@onready var border_zones: Node2D = $AspectContainer/MainContainer/mainarea/PlayArea/BorderZones
@onready var stamina_bar: ProgressBar = $AspectContainer/MainContainer/mainarea/Menu/StaminaBar
@onready var focus_bar: ProgressBar = $AspectContainer/MainContainer/mainarea/Menu/FocusBar
@onready var delivery_zone_node: Node2D = $AspectContainer/MainContainer/mainarea/PlayArea/FurnaceWall/DeliveryZone
@onready var mind_button: Button = $AspectContainer/MainContainer/mainarea/Menu/ToMindButton

# Combo display UI (single-line layout, centered)
@onready var combo_container: PanelContainer = $AspectContainer/MainContainer/mainarea/Menu/ComboContainer
@onready var clean_streak_label: Label = $AspectContainer/MainContainer/mainarea/Menu/ComboContainer/HBoxContainer/CleanStreakLabel
@onready var forgiveness_label: Label = $AspectContainer/MainContainer/mainarea/Menu/ComboContainer/HBoxContainer/ForgivenessLabel
@onready var heavy_stacks_label: Label = $AspectContainer/MainContainer/mainarea/Menu/ComboContainer/HBoxContainer/HeavyStacksLabel
@onready var heavy_timer_bar: ProgressBar = $AspectContainer/MainContainer/mainarea/Menu/ComboContainer/HBoxContainer/HeavyTimerBar
@onready var benefits_tooltip: PanelContainer = $AspectContainer/MainContainer/mainarea/Menu/BenefitsTooltip
@onready var benefits_list: VBoxContainer = $AspectContainer/MainContainer/mainarea/Menu/BenefitsTooltip/VBoxContainer/BenefitsList

# XP bar created programmatically
var xp_bar: ProgressBar = null

# Camera for shake effects (created programmatically)
var camera: Camera2D = null

# Combo UI constants
const COMBO_CONTAINER_SPACING: int = 6
const TOOLTIP_OFFSET: int = 8
const BENEFIT_FONT_SIZE: int = 14
const PANEL_PADDING: int = 8
const PANEL_CORNER_RADIUS: int = 4

# Color definitions for benefits display
const BENEFIT_COLORS = {
	"reduction": Color(0.4, 0.8, 0.4),  # Green for reductions
	"bonus": Color(1.0, 0.8, 0.2),      # Gold for bonuses
	"mass": Color(0.4, 0.8, 0.8)        # Cyan for mass
}

# Track currently hovered panel for tooltip positioning
var _hovered_panel: PanelContainer = null

const BORDER_THICKNESS: float = 50.0  # Border zone thickness in pixels
const DELIVERY_ZONE_WIDTH: float = 15.0

var container_width_percent: float = 0.25  # 25% of play area width
var container_height_percent: float = 0.15  # 15% of play area height
var left_wall_height_percent: float = 0.35  # 35% of play area height
var right_wall_height_percent: float = 0.22  # 22% of play area height

# Physics wall extension (invisible padding beyond visual walls to prevent tunneling)
const WALL_PHYSICS_EXTENSION: float = 30.0  # Extend physics walls this far beyond visible edges

# Slope configuration for coal container bottom
const CONTAINER_SLOPE_HEIGHT: float = 25.0  # How much higher the left side is than the right

var furnace_line_x: float
var furnace_opening_top: float
var furnace_opening_bottom: float
var furnace_opening_height_percent: float = 0.20  # 20% of playarea height

# Preload coal scene
var coal_piece_scene = preload("res://level1/coal_piece.tscn")

# Preload vignette overlay scene
var vignette_overlay_scene = preload("res://level1/vignette_overlay.tscn")

# Coal tap spawning
var coal_spawn_timer: float = 0.0
const COAL_SPAWN_RATE: float = 0.167  # Spawn every 0.167 seconds (6 per second)
var coal_tap_position: Vector2
var active_coal_count: int = 0
const MAX_COAL_PIECES: int = 100  # Performance limit

# Track which mouse button is held
var left_mouse_held: bool = false
var right_mouse_held: bool = false

# Day end tracking
var day_ended: bool = false

# Work zone boundary visualization (dev mode only)
var work_zone_boundary_line: Line2D

func _ready():
	# Tutorial gate - redirect if not completed
	if not Level1Vars.tutorial_completed:
		get_tree().change_scene_to_file("res://level1/tutorial.tscn")
		return

	# Reset day end flag
	day_ended = false

	ResponsiveLayout.apply_to_scene(self)  # REQUIRED
	connect_navigation()
	connect_settings_button()
	setup_xp_bar()
	connect_resource_bars()
	setup_debug_buttons()
	setup_camera()
	_update_mind_button_visibility()
	# Defer physics setup until after layout is applied
	await get_tree().process_frame
	setup_physics_objects()

	# Connect combo signals for counter updates (NOT tooltip updates)
	Level1Vars.clean_streak_changed.connect(_on_clean_streak_changed)
	Level1Vars.heavy_combo_changed.connect(_on_heavy_combo_changed)
	Level1Vars.technique_updated.connect(_on_technique_updated)

	# Connect mouse events for tooltip (single panel hover)
	if combo_container:
		combo_container.mouse_entered.connect(_on_combo_panel_hover_start.bind(combo_container))
		combo_container.mouse_exited.connect(_on_combo_panel_hover_end)
	else:
		push_warning("Combo container not found - combo display unavailable")

	# Initial visibility setup
	_update_combo_panel_visibility()

	# Initialize train shake system after physics setup
	assert(camera != null, "Camera2D not created - check setup_camera()")
	assert(coal_container != null, "CoalContainer not found")
	TrainShake.initialize(camera, coal_container)

	# Add vignette overlay for rage system visual feedback
	var vignette_overlay = vignette_overlay_scene.instantiate()
	add_child(vignette_overlay)

	# Connect rage system signals
	Level1Vars.rage_warning_triggered.connect(_on_overseer_warning)
	Level1Vars.rage_severe_warning_triggered.connect(_on_overseer_severe_warning)
	Level1Vars.rage_whip_triggered.connect(_on_player_whipped)

func _exit_tree():
	# Clean up signal connections
	if Level1Vars.clean_streak_changed.is_connected(_on_clean_streak_changed):
		Level1Vars.clean_streak_changed.disconnect(_on_clean_streak_changed)
	if Level1Vars.heavy_combo_changed.is_connected(_on_heavy_combo_changed):
		Level1Vars.heavy_combo_changed.disconnect(_on_heavy_combo_changed)
	if Level1Vars.technique_updated.is_connected(_on_technique_updated):
		Level1Vars.technique_updated.disconnect(_on_technique_updated)

	# Clean up rage signal connections
	if Level1Vars.rage_warning_triggered.is_connected(_on_overseer_warning):
		Level1Vars.rage_warning_triggered.disconnect(_on_overseer_warning)
	if Level1Vars.rage_severe_warning_triggered.is_connected(_on_overseer_severe_warning):
		Level1Vars.rage_severe_warning_triggered.disconnect(_on_overseer_severe_warning)
	if Level1Vars.rage_whip_triggered.is_connected(_on_player_whipped):
		Level1Vars.rage_whip_triggered.disconnect(_on_player_whipped)

	if combo_container:
		if combo_container.mouse_entered.is_connected(_on_combo_panel_hover_start):
			combo_container.mouse_entered.disconnect(_on_combo_panel_hover_start)
		if combo_container.mouse_exited.is_connected(_on_combo_panel_hover_end):
			combo_container.mouse_exited.disconnect(_on_combo_panel_hover_end)

func setup_camera():
	# Create Camera2D for shake effects
	camera = Camera2D.new()
	camera.name = "Camera2D"
	camera.enabled = true
	camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	camera.offset = Vector2.ZERO
	add_child(camera)
	print("Camera2D created for shake effects")

func setup_physics_objects():
	# Get playarea size
	var playarea_size = playarea.size

	# Calculate container dimensions
	var container_width = playarea_size.x * container_width_percent
	var container_height = playarea_size.y * container_height_percent
	var left_wall_height = playarea_size.y * left_wall_height_percent
	var wall_thickness = 5.0

	# Off-screen extension: move left side and spawn point off-screen
	var offscreen_extension = 60.0  # How far left the container extends off-screen

	# Slope: left side is higher, right side is at container_height
	# Left Y = container_height - CONTAINER_SLOPE_HEIGHT (higher up)
	# Right Y = container_height (flush with bottom)
	var slope_left_y = container_height - CONTAINER_SLOPE_HEIGHT
	var slope_right_y = container_height

	# Position container at bottom-left, but extend off-screen to the left
	coal_container.position = Vector2(-offscreen_extension, playarea_size.y - container_height)

	# Adjust container width to include off-screen portion
	var total_container_width = container_width + offscreen_extension

	# Setup left wall (extends off-screen, 2x height to catch escaping coal)
	var left_wall = coal_container.get_node("LeftWall")
	var left_collision = left_wall.get_node("CollisionShape2D")
	# Position at left edge (x=0 in container local coords, which is off-screen)
	# Physics wall extends further left by WALL_PHYSICS_EXTENSION
	var left_physics_x = -WALL_PHYSICS_EXTENSION / 2
	left_collision.position = Vector2(left_physics_x, slope_left_y - (left_wall_height / 2))
	var left_shape = RectangleShape2D.new()
	left_shape.size = Vector2(wall_thickness + WALL_PHYSICS_EXTENSION, left_wall_height)
	left_collision.shape = left_shape
	# Visual line: only draw from where it becomes visible (at x = offscreen_extension)
	# Since container starts at -offscreen_extension, visible portion starts at local x = offscreen_extension
	var left_visual = left_wall.get_node("VisualLine")
	left_visual.points = PackedVector2Array()  # Hide visual - wall is off-screen

	# Setup bottom wall as a sloped surface using a rotated rectangle
	var bottom_wall = coal_container.get_node("BottomWall")
	var bottom_collision = bottom_wall.get_node("CollisionShape2D")

	# Calculate slope angle and length
	var slope_dx = total_container_width
	var slope_dy = slope_right_y - slope_left_y  # Positive = going down left to right
	var slope_length = sqrt(slope_dx * slope_dx + slope_dy * slope_dy)
	var slope_angle = atan2(slope_dy, slope_dx)

	# Position at center of slope, with physics extension downward
	var slope_center_x = total_container_width / 2
	var slope_center_y = (slope_left_y + slope_right_y) / 2 + WALL_PHYSICS_EXTENSION / 2
	bottom_collision.position = Vector2(slope_center_x, slope_center_y)
	bottom_collision.rotation = slope_angle
	var bottom_shape = RectangleShape2D.new()
	# Width = slope length, height = wall thickness + downward extension
	bottom_shape.size = Vector2(slope_length + WALL_PHYSICS_EXTENSION, wall_thickness + WALL_PHYSICS_EXTENSION)
	bottom_collision.shape = bottom_shape

	# Visual line: sloped from top-left to bottom-right (only visible portion)
	var bottom_visual = bottom_wall.get_node("VisualLine")
	bottom_visual.points = PackedVector2Array([
		Vector2(offscreen_extension, slope_left_y),  # Where slope becomes visible
		Vector2(total_container_width, slope_right_y)
	])

	# Setup right wall (at the visible right edge of container)
	var right_wall = coal_container.get_node("RightWall")
	var right_collision = right_wall.get_node("CollisionShape2D")
	var right_wall_height = playarea_size.y * right_wall_height_percent
	var right_wall_width = 15.0
	var right_wall_top_slant = 10.0  # How much lower the left-top corner is (creates inward slope)

	# Define wall corners (polygon shape for slanted top)
	var right_wall_top_y = slope_right_y - right_wall_height
	var wall_left_x = total_container_width
	var wall_right_x = total_container_width + right_wall_width

	# Polygon points (clockwise): top-left, top-right, bottom-right, bottom-left
	# Top-left is lower (+ slant) so coal rolls back into container
	var wall_polygon = PackedVector2Array([
		Vector2(wall_left_x, right_wall_top_y + right_wall_top_slant),  # top-left (lower)
		Vector2(wall_right_x, right_wall_top_y),                        # top-right
		Vector2(wall_right_x, slope_right_y),                           # bottom-right
		Vector2(wall_left_x, slope_right_y)                             # bottom-left
	])

	# Use ConvexPolygonShape2D for collision
	var right_shape = ConvexPolygonShape2D.new()
	right_shape.points = wall_polygon
	right_collision.shape = right_shape
	right_collision.position = Vector2.ZERO  # Polygon uses absolute coords

	# Visual: filled polygon for solid wall
	var right_visual = right_wall.get_node("VisualLine")
	right_visual.visible = false  # Hide the Line2D, use Polygon2D instead

	# Create filled polygon if it doesn't exist
	var fill_name = "WallFill"
	var wall_fill: Polygon2D = right_wall.get_node_or_null(fill_name)
	if not wall_fill:
		wall_fill = Polygon2D.new()
		wall_fill.name = fill_name
		right_wall.add_child(wall_fill)
	wall_fill.polygon = wall_polygon
	wall_fill.color = Color.BLACK

	# Calculate coal tap position (off-screen, at top of the slope)
	# Spawn in the off-screen portion so coal rolls in naturally
	coal_tap_position = coal_container.global_position + Vector2(offscreen_extension * 0.3, slope_left_y - 15)

	# Debug output
	print("Container global position: ", coal_container.global_position)
	print("Container dimensions (visible): ", container_width, " x ", container_height)
	print("Container dimensions (total with offscreen): ", total_container_width, " x ", container_height)
	print("Slope: left_y=", slope_left_y, " right_y=", slope_right_y, " angle=", rad_to_deg(slope_angle), " deg")
	print("Coal tap position (off-screen): ", coal_tap_position)
	print("Left wall physics size: ", left_shape.size, " (extended by ", WALL_PHYSICS_EXTENSION, ")")
	print("Bottom wall physics size: ", bottom_shape.size, " (extended by ", WALL_PHYSICS_EXTENSION, ")")
	print("Right wall polygon points: ", right_shape.points)

	# Calculate furnace positions
	var furnace_opening_height = playarea_size.y * furnace_opening_height_percent
	furnace_line_x = playarea_size.x - 50
	furnace_opening_top = (playarea_size.y / 2) - (furnace_opening_height / 2)
	furnace_opening_bottom = furnace_opening_top + furnace_opening_height

	# Position furnace wall
	furnace_wall.position.x = furnace_line_x

	# Setup vertical line visual with gap (draw top and bottom segments)
	var top_line = furnace_wall.get_node("TopLine")
	top_line.points = PackedVector2Array([
		Vector2(0, 0),
		Vector2(0, furnace_opening_top)
	])
	top_line.default_color = Color.BLACK
	top_line.width = 15.0

	var bottom_line = furnace_wall.get_node("BottomLine")
	bottom_line.points = PackedVector2Array([
		Vector2(0, furnace_opening_bottom),
		Vector2(0, playarea_size.y)
	])
	bottom_line.default_color = Color.BLACK
	bottom_line.width = 15.0

	# Position top obstacle
	var top_obstacle = furnace_wall.get_node("TopObstacle/CollisionShape2D")
	var top_height = furnace_opening_top
	top_obstacle.position = Vector2(0, top_height / 2)
	top_obstacle.shape.size = Vector2(15, top_height)

	# Position bottom obstacle
	var bottom_obstacle = furnace_wall.get_node("BottomObstacle/CollisionShape2D")
	var bottom_height = playarea_size.y - furnace_opening_bottom
	bottom_obstacle.position = Vector2(0, furnace_opening_bottom + (bottom_height / 2))
	bottom_obstacle.shape.size = Vector2(15, bottom_height)

	# Setup border zones at end of function
	setup_border_zones()

	# Setup delivery zone at end
	setup_delivery_zone()

	# Setup work zone boundary visualization (dev mode only)
	setup_work_zone_boundary()

func setup_border_zones():
	if not border_zones:
		push_error("BorderZones node not found in scene")
		return

	var playarea_size = playarea.size

	# Offset left border to accommodate off-screen coal container
	# Coal spawns at -60px (offscreen_extension), so left border must be further left
	var left_border_offset = 80.0  # Push left border this far past playarea edge

	# Create borders programmatically (overlapping at corners to prevent gaps)
	var border_configs = [
		{
			"name": "TopBorder",
			"pos": Vector2(playarea_size.x / 2, -BORDER_THICKNESS / 2),
			"size": Vector2(playarea_size.x + BORDER_THICKNESS * 2 + left_border_offset, BORDER_THICKNESS)
		},
		{
			"name": "BottomBorder",
			"pos": Vector2(playarea_size.x / 2, playarea_size.y + BORDER_THICKNESS / 2),
			"size": Vector2(playarea_size.x + BORDER_THICKNESS * 2 + left_border_offset, BORDER_THICKNESS)
		},
		{
			"name": "LeftBorder",
			"pos": Vector2(-left_border_offset - BORDER_THICKNESS / 2, playarea_size.y / 2),
			"size": Vector2(BORDER_THICKNESS, playarea_size.y + BORDER_THICKNESS * 2)
		},
		{
			"name": "RightBorder",
			"pos": Vector2(playarea_size.x + BORDER_THICKNESS / 2, playarea_size.y / 2),
			"size": Vector2(BORDER_THICKNESS, playarea_size.y + BORDER_THICKNESS * 2)
		}
	]

	for config in border_configs:
		var area = Area2D.new()
		area.name = config.name
		area.monitoring = true
		area.monitorable = false
		area.collision_layer = 0
		area.collision_mask = 4  # Layer 3 (coal) = 2^2 = 4

		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = config.size
		shape.shape = rect
		shape.position = config.pos

		area.add_child(shape)
		border_zones.add_child(area)
		area.body_entered.connect(_on_coal_entered_border)

func _on_coal_entered_border(body: Node2D):
	# Check if it's a coal piece using group membership
	if body.is_in_group("coal"):
		# Don't count as dropped if coal is past the furnace line (it went into furnace)
		# This prevents fast-moving coal from triggering both delivered AND dropped
		if body.global_position.x >= furnace_line_x:
			body.has_been_tracked = true
			body.queue_free()
			return
		body._on_entered_drop_zone()

func setup_delivery_zone():
	if not delivery_zone_node:
		push_error("DeliveryZone node not found in scene")
		return

	# Guard against double setup
	if delivery_zone_node.get_child_count() > 0:
		push_warning("Delivery zone already setup, skipping")
		return

	# Validate opening dimensions
	var opening_height = furnace_opening_bottom - furnace_opening_top
	if opening_height <= 0:
		push_error("Invalid furnace opening dimensions: top=%s bottom=%s" % [furnace_opening_top, furnace_opening_bottom])
		return

	# Create Area2D
	var area = Area2D.new()
	area.name = "DeliveryArea"
	area.monitoring = true
	area.monitorable = false
	area.collision_layer = 0
	area.collision_mask = 4  # Layer 3 (coal)

	# Create collision shape
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(DELIVERY_ZONE_WIDTH, opening_height)
	shape.shape = rect

	# Position shape (local coordinates relative to DeliveryZone)
	# DeliveryZone inherits FurnaceWall's X position (furnace_line_x)
	# X: Center the 15px zone (half width from origin)
	# Y: Center vertically in opening
	shape.position = Vector2(
		DELIVERY_ZONE_WIDTH / 2,
		furnace_opening_top + opening_height / 2
	)

	area.add_child(shape)
	delivery_zone_node.add_child(area)
	area.body_entered.connect(_on_coal_entered_delivery_zone)

func _on_coal_entered_delivery_zone(body: Node2D):
	# Only coal can trigger this (collision_mask = 4)
	# Only award XP if coal was actually consumed (not already tracked)
	if body._on_entered_delivery_zone():
		# Award player XP for successful delivery with multiplier
		var base_xp = 1.0
		var xp_with_multiplier = base_xp * Level1Vars.get_xp_multiplier()
		Level1Vars.add_player_exp(xp_with_multiplier)

		# Update mind button visibility on level-up
		_update_mind_button_visibility()

		# Check for heavy load batch (if unlocked)
		if Level1Vars.heavy_combo_unlocked:
			_check_heavy_load_batch()

func _process(delta):
	# Apply continuous tilt torque while mouse buttons are held
	if left_mouse_held:
		shovel_body.tilt_left(delta)
	if right_mouse_held:
		shovel_body.tilt_right(delta)

	# Spawn coal from tap continuously if below max count
	if active_coal_count < MAX_COAL_PIECES:
		coal_spawn_timer += delta
		if coal_spawn_timer >= COAL_SPAWN_RATE:
			coal_spawn_timer = 0.0
			spawn_coal_from_tap()

	# Heavy combo timer countdown (if unlocked)
	if Level1Vars.heavy_combo_unlocked and Level1Vars.heavy_combo_timer > 0.0:
		Level1Vars.heavy_combo_timer -= delta

		# Update timer bar display if visible
		if heavy_timer_bar and heavy_timer_bar.visible:
			heavy_timer_bar.value = max(0.0, Level1Vars.heavy_combo_timer)

		if Level1Vars.heavy_combo_timer <= 0.0:
			# Timer expired - reset stacks
			Level1Vars.heavy_combo_stacks = 0
			Level1Vars.heavy_combo_timer = 0.0
			Level1Vars.emit_signal("heavy_combo_changed", 0, 0.0)
			if Level1Vars.DEBUG_COAL_TRACKING:
				print("[COMBO] Heavy combo expired")

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			left_mouse_held = event.pressed
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			right_mouse_held = event.pressed

func connect_navigation():
	# Connect navigation buttons (adjust based on .mmd connections)
	var to_mind_button = $AspectContainer/MainContainer/mainarea/Menu/ToMindButton
	if to_mind_button:
		to_mind_button.pressed.connect(func(): navigate_to("mind"))

func _update_mind_button_visibility():
	# Show Mind button when player has unspent level-ups
	var has_pending_upgrades = Level1Vars.player_level > Level1Vars.upgrades_qty
	if mind_button:
		mind_button.visible = has_pending_upgrades

func connect_settings_button():
	var settings_button = $AspectContainer/MainContainer/mainarea/Menu/SettingsButton
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)

func _on_settings_pressed():
	# Store current scene for return navigation
	Global.previous_scene = scene_file_path
	Global.change_scene("res://settings.tscn")

func setup_xp_bar():
	# Create XP bar programmatically
	var menu = $AspectContainer/MainContainer/mainarea/Menu
	if not menu:
		push_error("Menu node not found - cannot create XP bar")
		return

	# Create ProgressBar
	xp_bar = ProgressBar.new()
	xp_bar.name = "XPBar"
	xp_bar.custom_minimum_size = Vector2(0, 20)  # Match StaminaBar/FocusBar height
	xp_bar.min_value = 0
	xp_bar.max_value = 100
	xp_bar.value = 0
	xp_bar.show_percentage = false

	# Create and style background
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2, 0)  # Transparent dark grey
	bg_style.border_width_left = 1
	bg_style.border_width_right = 1
	bg_style.border_width_top = 1
	bg_style.border_width_bottom = 1
	bg_style.border_color = Color(0.3, 0.3, 0.3, 0.5)
	bg_style.corner_radius_top_left = 2
	bg_style.corner_radius_top_right = 2
	bg_style.corner_radius_bottom_left = 2
	bg_style.corner_radius_bottom_right = 2

	# Create and style fill (dark orange)
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.7, 0.35, 0.05, 0.3)  # Dark orange, 30% opacity
	fill_style.corner_radius_top_left = 2
	fill_style.corner_radius_top_right = 2
	fill_style.corner_radius_bottom_left = 2
	fill_style.corner_radius_bottom_right = 2

	# Apply styles
	xp_bar.add_theme_stylebox_override("background", bg_style)
	xp_bar.add_theme_stylebox_override("fill", fill_style)

	# Add to menu FIRST (will be positioned by VBoxContainer)
	# Insert after FocusBar (index 1), before ComboContainer
	menu.add_child(xp_bar)
	menu.move_child(xp_bar, 2)  # Position: StaminaBar(0), FocusBar(1), XPBar(2), ComboContainer(3), BenefitsTooltip(4), ToMindButton(5)

	# Add label to XP bar AFTER bar is in scene tree (anchors need parent size)
	var xp_label = Label.new()
	xp_label.name = "Label"
	xp_label.text = "XP"
	xp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	xp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	xp_label.add_theme_font_size_override("font_size", 14)
	xp_bar.add_child(xp_label)
	# Must use set_anchors_and_offsets_preset to reset both anchors AND offsets
	xp_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func connect_resource_bars():
	# Connect to Level1Vars signals
	Level1Vars.stamina_changed.connect(_on_stamina_changed)
	Level1Vars.focus_changed.connect(_on_focus_changed)
	Level1Vars.player_exp_changed.connect(_on_player_exp_changed)

	# Initialize bars with current values
	_on_stamina_changed(Level1Vars.stamina, Level1Vars.stamina_max)
	_on_focus_changed(Level1Vars.focus, Level1Vars.focus_max)
	_on_player_exp_changed(Level1Vars.player_exp, Level1Vars.get_xp_for_next_level())

func _on_stamina_changed(new_value: float, max_value: float):
	stamina_bar.max_value = max_value
	stamina_bar.value = new_value

	# Check for depletion
	if new_value <= 0.0:
		end_day("stamina")

func _on_focus_changed(new_value: int, max_value: int):
	focus_bar.max_value = max_value
	focus_bar.value = new_value

	# Check for depletion (future: when focus drain implemented)
	if new_value <= 0:
		end_day("focus")

func _on_player_exp_changed(new_value: float, xp_for_next_level: float):
	xp_bar.max_value = xp_for_next_level
	xp_bar.value = new_value

func end_day(reason: String):
	# Prevent double-triggering if both resources hit 0 in same frame
	if day_ended:
		return
	day_ended = true

	# Transition to pay scene
	# Note: reason parameter allows future expansion (different messages/bonuses)
	get_tree().change_scene_to_file("res://level1/pay.tscn")

# Check if recent deliveries constitute a heavy load (3+ coal in 1 second)
func _check_heavy_load_batch():
	var current_time = Time.get_ticks_msec() / 1000.0

	# Clean old timestamps (older than batch window)
	var cleaned_timestamps: Array[float] = []
	for timestamp in Level1Vars.recent_delivery_timestamps:
		if current_time - timestamp <= Level1Vars.HEAVY_LOAD_BATCH_WINDOW:
			cleaned_timestamps.append(timestamp)
	Level1Vars.recent_delivery_timestamps = cleaned_timestamps

	# Add current delivery
	Level1Vars.recent_delivery_timestamps.append(current_time)

	# Check if we hit heavy load threshold (3+ deliveries in window)
	if Level1Vars.recent_delivery_timestamps.size() >= 3:
		# Trigger heavy load combo
		Level1Vars.heavy_combo_stacks += 1

		# Refresh timer
		var base_timer = 5.0
		var timer_bonus = Level1Vars.get_heavy_timer_extension()
		Level1Vars.heavy_combo_timer = base_timer + timer_bonus

		# Clear timestamps (batch consumed)
		Level1Vars.recent_delivery_timestamps.clear()

		Level1Vars.emit_signal("heavy_combo_changed", Level1Vars.heavy_combo_stacks, Level1Vars.heavy_combo_timer)

		if Level1Vars.DEBUG_COAL_TRACKING:
			print("[COMBO] Heavy load triggered! Stacks: %d, Timer: %.1fs" % [Level1Vars.heavy_combo_stacks, Level1Vars.heavy_combo_timer])

func navigate_to(scene_id: String):
	var path = SceneNetwork.get_scene_path(scene_id)
	if path.is_empty():
		push_error("Unknown scene ID: " + scene_id)
		return
	Global.change_scene(path)

func spawn_coal_from_tap():
	# Spawn single coal piece at tap position
	var coal = coal_piece_scene.instantiate()
	get_node("AspectContainer/MainContainer/mainarea/PlayArea").add_child(coal)

	# Track coal lifetime
	active_coal_count += 1
	coal.tree_exited.connect(_on_coal_destroyed)

	# Spawn at tap position
	coal.global_position = coal_tap_position

	# Debug first spawn
	if active_coal_count == 1:
		print("First coal spawned at: ", coal.global_position)
		print("Coal collision_layer: ", coal.collision_layer)
		print("Coal collision_mask: ", coal.collision_mask)

func _on_coal_destroyed():
	active_coal_count -= 1

func setup_debug_buttons():
	# Get buttons (use get_node_or_null for safety)
	var coal_btn = get_node_or_null("AspectContainer/MainContainer/mainarea/Menu/Debug25CoalButton")
	var stamina_btn = get_node_or_null("AspectContainer/MainContainer/mainarea/Menu/DebugDrainStaminaButton")

	if not coal_btn or not stamina_btn:
		return  # Buttons don't exist (shouldn't happen)

	# Show buttons only if dev_speed_mode enabled
	var dev_mode = Global.dev_speed_mode
	coal_btn.visible = dev_mode
	stamina_btn.visible = dev_mode

	if dev_mode:
		# Connect signals (only when visible)
		if not coal_btn.pressed.is_connected(_on_debug_25_coal_pressed):
			coal_btn.pressed.connect(_on_debug_25_coal_pressed)
		if not stamina_btn.pressed.is_connected(_on_debug_drain_stamina_pressed):
			stamina_btn.pressed.connect(_on_debug_drain_stamina_pressed)

func _on_debug_25_coal_pressed():
	# Add 25 to delivered coal count
	Level1Vars.coal_delivered += 25
	print("[DEBUG] Added 25 coal - total delivered: %d" % Level1Vars.coal_delivered)

func _on_debug_drain_stamina_pressed():
	# Reduce stamina to 1.0 (triggers day end when next shovel action drains it)
	# Use modify_stamina to ensure signal is emitted and UI updates
	var target_stamina = 1.0
	Level1Vars.modify_stamina(target_stamina - Level1Vars.stamina)
	print("[DEBUG] Stamina drained to 1.0")

func setup_work_zone_boundary():
	# Only show when dev_speed_mode is enabled
	if not Global.dev_speed_mode:
		return

	# Create Line2D for boundary visualization
	work_zone_boundary_line = Line2D.new()
	work_zone_boundary_line.name = "WorkZoneBoundary"
	work_zone_boundary_line.default_color = Color.RED
	work_zone_boundary_line.width = 5.0
	work_zone_boundary_line.z_index = 100  # Draw on top

	# Calculate boundary position (1/3 of playarea width)
	# Line2D is added to playarea, so use local coordinates (just size, not global position)
	var playarea_size = playarea.size
	var boundary_x = playarea_size.x / 3.0

	# Set line points (vertical line from top to bottom of playarea)
	work_zone_boundary_line.points = PackedVector2Array([
		Vector2(boundary_x, 0),
		Vector2(boundary_x, playarea_size.y)
	])

	# Add to playarea
	playarea.add_child(work_zone_boundary_line)

	print("Work zone boundary drawn at x=", boundary_x, " (Global.dev_speed_mode)")

# ============================================================================
# COMBO DISPLAY FUNCTIONS
# ============================================================================

# Helper function for combo color thresholds
func _get_combo_color(count: int, green_threshold: int, gold_threshold: int) -> Color:
	if count >= gold_threshold:
		return Color(1.0, 0.8, 0.2)  # Gold
	elif count >= green_threshold:
		return Color(0.4, 0.8, 0.4)  # Green
	return Color.WHITE

func _update_combo_panel_visibility():
	var clean_unlocked = Level1Vars.clean_streak_unlocked
	var heavy_unlocked = Level1Vars.heavy_combo_unlocked

	# Individual label visibility
	if clean_streak_label:
		clean_streak_label.visible = clean_unlocked
	if heavy_stacks_label:
		heavy_stacks_label.visible = heavy_unlocked
	if heavy_timer_bar:
		heavy_timer_bar.visible = heavy_unlocked and Level1Vars.heavy_combo_timer > 0.0

	# Hide entire combo container if no combos unlocked
	if combo_container:
		combo_container.visible = clean_unlocked or heavy_unlocked

func _update_clean_streak_display(count: int):
	if not clean_streak_label:
		push_warning("Clean streak label not found - streak display unavailable")
		return

	# Build display text: "No-drop: 15/30"
	var max_combo = Level1Vars.get_clean_streak_max()
	clean_streak_label.text = "No-drop: %d/%d" % [count, max_combo]

	# Show forgiveness charges if unlocked
	if forgiveness_label:
		if Level1Vars.forgiveness_max_capacity > 0:
			forgiveness_label.text = "[%d]" % Level1Vars.forgiveness_charges
			forgiveness_label.visible = true
			# Dim the charges display
			forgiveness_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		else:
			forgiveness_label.visible = false

	# Color based on milestones
	var color = _get_combo_color(count, 5, 10)
	clean_streak_label.add_theme_color_override("font_color", color)

func _update_heavy_combo_display(stacks: int, timer: float):
	if not heavy_stacks_label:
		push_warning("Heavy stacks label not found - heavy combo display unavailable")
		return

	heavy_stacks_label.text = "Heavy: %d" % stacks

	# Color based on stack count using helper
	var color = _get_combo_color(stacks, 3, 5)
	heavy_stacks_label.add_theme_color_override("font_color", color)

	if heavy_timer_bar:
		# Calculate max timer (base + extensions)
		var base_timer = 5.0
		var extension = Level1Vars.get_heavy_timer_extension()
		heavy_timer_bar.max_value = base_timer + extension
		heavy_timer_bar.value = max(0.0, timer)  # Prevent negative values

		# Show/hide bar based on active timer
		heavy_timer_bar.visible = timer > 0.0

# Signal handlers
func _on_clean_streak_changed(new_count: int):
	_update_clean_streak_display(new_count)
	# No tooltip update here - only on hover

func _on_heavy_combo_changed(new_stacks: int, timer_remaining: float):
	_update_heavy_combo_display(new_stacks, timer_remaining)
	# No tooltip update here - only on hover

func _on_technique_updated(_technique_id: String, _new_level: int):
	_update_combo_panel_visibility()
	# No tooltip update here - only on hover

# Tooltip hover handlers
func _on_combo_panel_hover_start(panel: PanelContainer):
	if not benefits_tooltip:
		push_warning("Benefits tooltip not found - combo tooltip unavailable")
		return

	_hovered_panel = panel
	_rebuild_benefits_list()  # Calculate and display benefits
	_position_tooltip_near_panel(panel)
	benefits_tooltip.visible = true

func _on_combo_panel_hover_end():
	if benefits_tooltip:
		benefits_tooltip.visible = false
		_hovered_panel = null

func _position_tooltip_near_panel(panel: PanelContainer):
	if not benefits_tooltip or not panel:
		return

	# Position tooltip to the right of the hovered panel
	# Use global_position since tooltip and panel have different parents
	var offset = Vector2(panel.size.x + TOOLTIP_OFFSET, 0)
	var desired_pos = panel.global_position + offset

	# Clamp to viewport to prevent offscreen positioning
	var viewport_size = get_viewport_rect().size
	var tooltip_size = benefits_tooltip.size

	# Prevent going off right edge
	if desired_pos.x + tooltip_size.x > viewport_size.x:
		desired_pos.x = viewport_size.x - tooltip_size.x - TOOLTIP_OFFSET

	# Prevent going off bottom edge
	if desired_pos.y + tooltip_size.y > viewport_size.y:
		desired_pos.y = viewport_size.y - tooltip_size.y - TOOLTIP_OFFSET

	# Prevent going off top edge
	desired_pos.y = max(TOOLTIP_OFFSET, desired_pos.y)

	benefits_tooltip.global_position = desired_pos

func _get_active_benefits() -> Array[Dictionary]:
	var benefits: Array[Dictionary] = []

	# Stamina drain reduction
	var drain_mult = Level1Vars.get_base_stamina_drain_multiplier()
	if drain_mult < 1.0:
		var reduction_pct = (1.0 - drain_mult) * 100
		benefits.append({
			"label": "Stamina Drain",
			"value": "-%d%%" % int(reduction_pct),
			"color": BENEFIT_COLORS["reduction"]
		})

	# XP multiplier
	var xp_mult = Level1Vars.get_xp_multiplier()
	if xp_mult > 1.0:
		var bonus_pct = (xp_mult - 1.0) * 100
		benefits.append({
			"label": "XP Bonus",
			"value": "+%d%%" % int(bonus_pct),
			"color": BENEFIT_COLORS["bonus"]
		})

	# Shovel stability (if player is investing in it)
	var mass_mult = Level1Vars.get_shovel_mass_multiplier()
	if mass_mult > 1.0:
		var bonus_pct = (mass_mult - 1.0) * 100
		benefits.append({
			"label": "Shovel Stability",
			"value": "+%d%%" % int(bonus_pct),
			"color": BENEFIT_COLORS["mass"]
		})

	# Fallback: Show at least that combo system is active
	# This occurs when combo is unlocked but not providing bonuses yet:
	# - Clean streak at 0 (just unlocked or recently dropped coal)
	# - Heavy combo timer expired (stacks = 0)
	# - No passive bonuses from Rhythm/Economy/etc (player only selected combo techniques)
	if benefits.is_empty() and (Level1Vars.clean_streak_unlocked or Level1Vars.heavy_combo_unlocked):
		benefits.append({
			"label": "Combo System Active",
			"value": "(no bonuses yet)",
			"color": Color.WHITE
		})

	return benefits

func _rebuild_benefits_list():
	if not benefits_list:
		push_warning("Benefits list not found - tooltip content unavailable")
		return

	# Clear existing labels (use free() not queue_free() to prevent buildup on rapid hovering)
	for child in benefits_list.get_children():
		child.free()

	var benefits = _get_active_benefits()

	# Show at least header even if no benefits
	for benefit in benefits:
		var label = Label.new()
		label.text = "%s: %s" % [benefit["label"], benefit["value"]]
		label.add_theme_color_override("font_color", benefit["color"])
		label.add_theme_font_size_override("font_size", BENEFIT_FONT_SIZE)
		benefits_list.add_child(label)

# ============================================================================
# RAGE SYSTEM HANDLERS
# ============================================================================

func _on_overseer_warning(message: String):
	Global.show_notification(message, Global.NOTIFICATION_TYPE_WARNING)

func _on_overseer_severe_warning(message: String):
	Global.show_notification(message, Global.NOTIFICATION_TYPE_WARNING)

func _on_player_whipped(stamina_removed: int):
	var msg = "The overseer's whip bites deep. -%d stamina" % stamina_removed
	Global.show_notification(msg, Global.NOTIFICATION_TYPE_WARNING)
