extends Control

@onready var coal_container: Node2D = $AspectContainer/MainContainer/mainarea/PlayArea/CoalContainer
@onready var furnace_wall: Node2D = $AspectContainer/MainContainer/mainarea/PlayArea/FurnaceWall
@onready var playarea: Control = $AspectContainer/MainContainer/mainarea/PlayArea
@onready var shovel_body: RigidBody2D = $AspectContainer/MainContainer/mainarea/PlayArea/Shovel/RigidBody2D
@onready var stamina_bar: ProgressBar = $AspectContainer/MainContainer/mainarea/Menu/StaminaBar
@onready var focus_bar: ProgressBar = $AspectContainer/MainContainer/mainarea/Menu/FocusBar

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

func _ready():
	ResponsiveLayout.apply_to_scene(self)  # REQUIRED
	connect_navigation()
	connect_settings_button()
	connect_resource_bars()
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
	top_line.width = 5.0

	var bottom_line = furnace_wall.get_node("BottomLine")
	bottom_line.points = PackedVector2Array([
		Vector2(0, furnace_opening_bottom),
		Vector2(0, playarea_size.y)
	])
	bottom_line.default_color = Color.BLACK
	bottom_line.width = 5.0

	# Position top obstacle
	var top_obstacle = furnace_wall.get_node("TopObstacle/CollisionShape2D")
	var top_height = furnace_opening_top
	top_obstacle.position = Vector2(0, top_height / 2)
	top_obstacle.shape.size = Vector2(40, top_height)

	# Position bottom obstacle
	var bottom_obstacle = furnace_wall.get_node("BottomObstacle/CollisionShape2D")
	var bottom_height = playarea_size.y - furnace_opening_bottom
	bottom_obstacle.position = Vector2(0, furnace_opening_bottom + (bottom_height / 2))
	bottom_obstacle.shape.size = Vector2(40, bottom_height)

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

func _on_stamina_changed(new_value: int, max_value: int):
	stamina_bar.max_value = max_value
	stamina_bar.value = new_value

func _on_focus_changed(new_value: int, max_value: int):
	focus_bar.max_value = max_value
	focus_bar.value = new_value

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
