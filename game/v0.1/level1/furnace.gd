extends Control

@onready var coal_container: Node2D = $AspectContainer/MainContainer/mainarea/PlayArea/CoalContainer
@onready var furnace_wall: Node2D = $AspectContainer/MainContainer/mainarea/PlayArea/FurnaceWall
@onready var playarea: Control = $AspectContainer/MainContainer/mainarea/PlayArea
@onready var shovel_body: RigidBody2D = $AspectContainer/MainContainer/mainarea/PlayArea/Shovel/RigidBody2D
@onready var border_zones: Node2D = $AspectContainer/MainContainer/mainarea/PlayArea/BorderZones
@onready var stamina_bar: ProgressBar = $AspectContainer/MainContainer/mainarea/Menu/StaminaBar
@onready var focus_bar: ProgressBar = $AspectContainer/MainContainer/mainarea/Menu/FocusBar
@onready var delivery_zone_node: Node2D = $AspectContainer/MainContainer/mainarea/PlayArea/FurnaceWall/DeliveryZone

const BORDER_THICKNESS: float = 50.0  # Border zone thickness in pixels
const DELIVERY_ZONE_WIDTH: float = 15.0

var container_width_percent: float = 0.25  # 25% of play area width
var container_height_percent: float = 0.15  # 15% of play area height
var left_wall_height_percent: float = 0.30  # 30% of play area height (2x container height to catch escaping coal)

var furnace_line_x: float
var furnace_opening_top: float
var furnace_opening_bottom: float
var furnace_opening_height_percent: float = 0.20  # 20% of playarea height

# Preload coal scene
var coal_piece_scene = preload("res://level1/coal_piece.tscn")

# Coal tap spawning
var coal_spawn_timer: float = 0.0
const COAL_SPAWN_RATE: float = 0.25  # Spawn every 0.25 seconds (4 per second)
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
	# Reset day end flag
	day_ended = false

	ResponsiveLayout.apply_to_scene(self)  # REQUIRED
	connect_navigation()
	connect_settings_button()
	connect_resource_bars()
	setup_debug_buttons()
	# Defer physics setup until after layout is applied
	await get_tree().process_frame
	setup_physics_objects()

func setup_physics_objects():
	# Get playarea size
	var playarea_size = playarea.size

	# Calculate container dimensions
	var container_width = playarea_size.x * container_width_percent
	var container_height = playarea_size.y * container_height_percent
	var left_wall_height = playarea_size.y * left_wall_height_percent
	var wall_thickness = 5.0

	# Position container at bottom-left (flush with edges)
	coal_container.position = Vector2(0, playarea_size.y - container_height)

	# Setup left wall (2x height of container to catch escaping coal)
	var left_wall = coal_container.get_node("LeftWall")
	var left_collision = left_wall.get_node("CollisionShape2D")
	# Position left wall so bottom aligns with container bottom, extends upward
	left_collision.position = Vector2(wall_thickness / 2, container_height - (left_wall_height / 2))
	var left_shape = RectangleShape2D.new()
	left_shape.size = Vector2(wall_thickness, left_wall_height)
	left_collision.shape = left_shape
	var left_visual = left_wall.get_node("VisualLine")
	left_visual.points = PackedVector2Array([
		Vector2(0, container_height - left_wall_height),
		Vector2(0, container_height)
	])

	# Setup bottom wall
	var bottom_wall = coal_container.get_node("BottomWall")
	var bottom_collision = bottom_wall.get_node("CollisionShape2D")
	bottom_collision.position = Vector2(container_width / 2, container_height - wall_thickness / 2)
	var bottom_shape = RectangleShape2D.new()
	bottom_shape.size = Vector2(container_width, wall_thickness)
	bottom_collision.shape = bottom_shape
	var bottom_visual = bottom_wall.get_node("VisualLine")
	bottom_visual.points = PackedVector2Array([
		Vector2(0, container_height),
		Vector2(container_width, container_height)
	])

	# Setup right wall
	var right_wall = coal_container.get_node("RightWall")
	var right_collision = right_wall.get_node("CollisionShape2D")
	right_collision.position = Vector2(container_width - wall_thickness / 2, container_height / 2)
	var right_shape = RectangleShape2D.new()
	right_shape.size = Vector2(wall_thickness, container_height)
	right_collision.shape = right_shape
	var right_visual = right_wall.get_node("VisualLine")
	right_visual.points = PackedVector2Array([
		Vector2(container_width, 0),
		Vector2(container_width, container_height)
	])

	# Calculate coal tap position (just above top-left of container)
	coal_tap_position = coal_container.global_position + Vector2(container_width * 0.15, -10)

	# Debug output
	print("Container global position: ", coal_container.global_position)
	print("Container dimensions: ", container_width, " x ", container_height)
	print("Left wall height (2x container): ", left_wall_height)
	print("Coal tap position: ", coal_tap_position)
	print("Left wall collision position: ", left_collision.global_position)
	print("Left wall collision size: ", left_shape.size)
	print("Bottom wall collision position: ", bottom_collision.global_position)
	print("Bottom wall collision size: ", bottom_shape.size)
	print("Right wall collision position: ", right_collision.global_position)
	print("Right wall collision size: ", right_shape.size)

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

	# Create borders programmatically (overlapping at corners to prevent gaps)
	var border_configs = [
		{
			"name": "TopBorder",
			"pos": Vector2(playarea_size.x / 2, -BORDER_THICKNESS / 2),
			"size": Vector2(playarea_size.x + BORDER_THICKNESS * 2, BORDER_THICKNESS)
		},
		{
			"name": "BottomBorder",
			"pos": Vector2(playarea_size.x / 2, playarea_size.y + BORDER_THICKNESS / 2),
			"size": Vector2(playarea_size.x + BORDER_THICKNESS * 2, BORDER_THICKNESS)
		},
		{
			"name": "LeftBorder",
			"pos": Vector2(-BORDER_THICKNESS / 2, playarea_size.y / 2),
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
	body._on_entered_delivery_zone()

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

func connect_settings_button():
	var settings_button = $AspectContainer/MainContainer/mainarea/Menu/SettingsButton
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)

func _on_settings_pressed():
	# Store current scene for return navigation
	Global.previous_scene = scene_file_path
	Global.change_scene("res://settings.tscn")

func connect_resource_bars():
	# Connect to Level1Vars signals
	Level1Vars.stamina_changed.connect(_on_stamina_changed)
	Level1Vars.focus_changed.connect(_on_focus_changed)

	# Initialize bars with current values
	_on_stamina_changed(Level1Vars.stamina, Level1Vars.stamina_max)
	_on_focus_changed(Level1Vars.focus, Level1Vars.focus_max)

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

func end_day(reason: String):
	# Prevent double-triggering if both resources hit 0 in same frame
	if day_ended:
		return
	day_ended = true

	# Transition to pay scene
	# Note: reason parameter allows future expansion (different messages/bonuses)
	get_tree().change_scene_to_file("res://level1/pay.tscn")

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
