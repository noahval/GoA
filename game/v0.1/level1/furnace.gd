extends Control

@onready var coal_pile_area: Area2D = $AspectContainer/MainContainer/mainarea/PlayArea/CoalPile/CoalPileArea
@onready var furnace_wall: Node2D = $AspectContainer/MainContainer/mainarea/PlayArea/FurnaceWall
@onready var playarea: Control = $AspectContainer/MainContainer/mainarea/PlayArea
@onready var shovel_body: RigidBody2D = $AspectContainer/MainContainer/mainarea/PlayArea/Shovel/RigidBody2D

var coal_pile_position: Vector2
var coal_pile_radius: float = 100.0

var furnace_line_x: float
var furnace_opening_top: float
var furnace_opening_bottom: float
var furnace_opening_height_percent: float = 0.20  # 20% of playarea height

# Preload coal scene
var coal_piece_scene = preload("res://level1/coal_piece.tscn")

# Scoop detection state
var shovel_was_in_pile: bool = false
var shovel_entry_position: Vector2 = Vector2.ZERO
var scoop_cooldown_timer: float = 0.0
const SCOOP_COOLDOWN_DURATION: float = 0.4
const SCOOP_UPWARD_THRESHOLD: float = 50.0  # Minimum upward pixels for scoop
var active_coal_count: int = 0
const MAX_COAL_PIECES: int = 100  # Performance limit

# Track which mouse button is held
var left_mouse_held: bool = false
var right_mouse_held: bool = false

func _ready():
	ResponsiveLayout.apply_to_scene(self)  # REQUIRED
	connect_navigation()
	# Defer physics setup until after layout is applied
	await get_tree().process_frame
	setup_physics_objects()

	# Connect coal pile area signals
	coal_pile_area.body_entered.connect(_on_coal_pile_entered)
	coal_pile_area.body_exited.connect(_on_coal_pile_exited)

	# Debug: verify shovel_body reference
	print("Shovel body reference: ", shovel_body)
	print("Shovel body name: ", shovel_body.name if shovel_body else "NULL")

	# Wait one more frame for physics to settle
	await get_tree().process_frame

	# Check if shovel started inside coal pile area
	if coal_pile_area.overlaps_body(shovel_body):
		print("Shovel started inside coal pile - initializing flag")
		shovel_was_in_pile = true
		shovel_entry_position = shovel_body.global_position

	# Debug: print coal pile info
	print("Coal pile global position: ", $AspectContainer/MainContainer/mainarea/PlayArea/CoalPile.global_position)
	print("Coal pile area shape radius: ", coal_pile_area.get_node("CollisionShape2D").shape.radius)
	print("Shovel global position: ", shovel_body.global_position)
	print("Shovel collision_layer: ", shovel_body.collision_layer)
	print("Shovel collision_mask: ", shovel_body.collision_mask)
	print("Shovel has collision shape: ", shovel_body.get_node_or_null("CollisionShape2D") != null)

func setup_physics_objects():
	# Get playarea size
	var playarea_size = playarea.size

	# Calculate coal pile position (bottom-left corner)
	coal_pile_position = Vector2(100, playarea_size.y - 100)

	# Position coal pile
	$AspectContainer/MainContainer/mainarea/PlayArea/CoalPile.position = coal_pile_position

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
	# Update scoop cooldown
	if scoop_cooldown_timer > 0.0:
		scoop_cooldown_timer -= delta

	# Apply continuous tilt torque while mouse buttons are held
	if left_mouse_held:
		shovel_body.tilt_left(delta)
	if right_mouse_held:
		shovel_body.tilt_right(delta)

	# Poll for shovel overlap with coal pile (signals don't work with direct position setting)
	# Calculate distance between shovel and coal pile center
	var pile_center = coal_pile_position
	var shovel_pos = shovel_body.global_position
	var distance = pile_center.distance_to(shovel_pos)
	var currently_in_pile = distance <= coal_pile_radius

	# Handle entry
	if currently_in_pile and not shovel_was_in_pile:
		print("Shovel entered coal pile at: ", shovel_body.global_position)
		shovel_was_in_pile = true
		shovel_entry_position = shovel_body.global_position

	# Handle exit
	elif not currently_in_pile and shovel_was_in_pile:
		print("Shovel exited coal pile")
		if scoop_cooldown_timer <= 0.0:
			var y_delta = shovel_entry_position.y - shovel_body.global_position.y
			print("Y delta: ", y_delta, " (threshold: ", SCOOP_UPWARD_THRESHOLD, ")")

			if y_delta >= SCOOP_UPWARD_THRESHOLD:
				print("Scooping coal!")
				spawn_coal_at_shovel()
				scoop_cooldown_timer = SCOOP_COOLDOWN_DURATION
			else:
				print("Not enough upward movement to scoop")

		shovel_was_in_pile = false

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

func navigate_to(scene_id: String):
	var path = SceneNetwork.get_scene_path(scene_id)
	if path.is_empty():
		push_error("Unknown scene ID: " + scene_id)
		return
	Global.change_scene(path)

func _on_coal_pile_entered(body):
	print("Coal pile entered by: ", body.name, " (", body, ")")
	print("Comparing to shovel_body: ", shovel_body)
	print("Are they equal? ", body == shovel_body)
	if body == shovel_body:
		print("Shovel entered coal pile at: ", shovel_body.global_position)
		shovel_was_in_pile = true
		shovel_entry_position = shovel_body.global_position

func _on_coal_pile_exited(body):
	print("Coal pile exited by: ", body.name, " (", body, ")")
	print("shovel_was_in_pile: ", shovel_was_in_pile)
	print("scoop_cooldown_timer: ", scoop_cooldown_timer)

	# Handle case where shovel started inside pile (first exit without enter)
	if body == shovel_body and not shovel_was_in_pile:
		print("Shovel exited but was never in pile - started inside, ignoring this exit")
		return

	if body == shovel_body and shovel_was_in_pile and scoop_cooldown_timer <= 0.0:
		# Calculate upward movement
		# In Godot: Y increases downward, so upward = entry.y - exit.y (positive)
		var y_delta = shovel_entry_position.y - shovel_body.global_position.y
		print("Y delta: ", y_delta, " (threshold: ", SCOOP_UPWARD_THRESHOLD, ")")

		# Scoop if moving upward by at least threshold
		if y_delta >= SCOOP_UPWARD_THRESHOLD:
			print("Scooping coal!")
			spawn_coal_at_shovel()
			scoop_cooldown_timer = SCOOP_COOLDOWN_DURATION
		else:
			print("Not enough upward movement to scoop")

		shovel_was_in_pile = false

func spawn_coal_at_shovel():
	# Enforce performance limit
	if active_coal_count >= MAX_COAL_PIECES:
		return

	# Spawn 5 coal pieces in a row
	var spawn_offsets = [-30, -15, 0, 15, 30]

	for offset_x in spawn_offsets:
		if active_coal_count >= MAX_COAL_PIECES:
			break

		var coal = coal_piece_scene.instantiate()
		get_node("AspectContainer/MainContainer/mainarea/PlayArea").add_child(coal)

		# Track coal lifetime
		active_coal_count += 1
		coal.tree_exited.connect(_on_coal_destroyed)

		# Spawn above shovel to prevent tunneling (increased height for CCD)
		coal.global_position = shovel_body.global_position + Vector2(offset_x, -100)

func _on_coal_destroyed():
	active_coal_count -= 1
