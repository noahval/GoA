extends AnimatableBody2D

const SHOVEL_WIDTH: float = 80.0
const SHOVEL_PHYSICS_MAT = preload("res://level1/shovel_physics_material.tres")

var shovel_curve: PackedVector2Array
var shovel_previous_position: Vector2
var line_2d: Line2D
var outline_line: Line2D
var scoop_cooldown_timer: float = 0.0
var playarea: Control

func _ready():
	# Get reference to playarea (parent's parent)
	playarea = get_parent().get_parent()

	# Define shovel visual curve (for aesthetics only)
	shovel_curve = PackedVector2Array([
		Vector2(-40, -5),   # Left edge, slightly raised
		Vector2(-20, 5),    # Left-center, deeper
		Vector2(0, 8),      # Center, deepest point
		Vector2(20, 5),     # Right-center, deeper
		Vector2(40, -5)     # Right edge, slightly raised
	])

	# Setup collision shape
	var collision_shape = get_node("CollisionShape2D")
	collision_shape.rotation_degrees = -5  # Slight upward tilt

	# Setup outline (gray, thicker) - draws first (behind)
	outline_line = get_node("OutlineLine2D")
	outline_line.points = shovel_curve
	outline_line.default_color = Color(0.8, 0.8, 0.8)  # 80% gray
	outline_line.width = 10.0
	outline_line.z_index = 0

	# Setup main line (black, thinner) - draws second (in front)
	line_2d = get_node("Line2D")
	line_2d.points = shovel_curve
	line_2d.default_color = Color.BLACK
	line_2d.width = 6.0
	line_2d.z_index = 1

	# Apply shared physics material
	physics_material_override = SHOVEL_PHYSICS_MAT

	# Initialize position tracking
	shovel_previous_position = get_global_mouse_position()
	global_position = shovel_previous_position

func _physics_process(delta):
	# Store previous position for future scoop detection
	shovel_previous_position = global_position

	# Get mouse position and constrain to playarea bounds
	var mouse_pos = get_global_mouse_position()

	if playarea:
		var playarea_rect = playarea.get_global_rect()
		mouse_pos.x = clamp(mouse_pos.x, playarea_rect.position.x, playarea_rect.position.x + playarea_rect.size.x)
		mouse_pos.y = clamp(mouse_pos.y, playarea_rect.position.y, playarea_rect.position.y + playarea_rect.size.y)

	# Move to constrained position (AnimatableBody2D handles physics sync)
	global_position = mouse_pos

	# Update cooldown timer (for future use)
	if scoop_cooldown_timer > 0.0:
		scoop_cooldown_timer -= delta
