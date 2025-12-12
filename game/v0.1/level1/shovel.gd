extends RigidBody2D

const SHOVEL_WIDTH: float = 80.0

var shovel_curve: PackedVector2Array
var line_2d: Line2D
var outline_line: Line2D
var scoop_cooldown_timer: float = 0.0
var playarea: Control

func _ready():
	# Get reference to playarea (parent's parent)
	playarea = get_parent().get_parent()

	# RigidBody2D physics setup (use Level1Vars for upgradable values)
	lock_rotation = false  # Allow rotation for tilt mechanic
	mass = Level1Vars.shovel_mass
	gravity_scale = 0.0  # No gravity
	linear_damp = Level1Vars.shovel_linear_damp
	angular_damp = Level1Vars.shovel_angular_damp

	# Collision layers
	collision_layer = 2
	collision_mask = 1 | 4  # World (layer 1) + coal (layer 3)

	# Define shovel visual curve (for aesthetics only)
	shovel_curve = PackedVector2Array([
		Vector2(-40, -5),   # Left edge, slightly raised
		Vector2(-20, 5),    # Left-center, deeper
		Vector2(0, 8),      # Center, deepest point
		Vector2(20, 5),     # Right-center, deeper
		Vector2(40, -5)     # Right edge, slightly raised
	])

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

	# Create physics material programmatically (upgradable at runtime)
	var physics_mat = PhysicsMaterial.new()
	physics_mat.friction = Level1Vars.shovel_friction
	physics_mat.bounce = Level1Vars.shovel_bounce
	physics_material_override = physics_mat

func _physics_process(delta):
	# Get mouse position
	var mouse_pos = get_global_mouse_position()

	if playarea:
		var playarea_rect = playarea.get_global_rect()
		mouse_pos.x = clamp(mouse_pos.x, playarea_rect.position.x, playarea_rect.position.x + playarea_rect.size.x)
		mouse_pos.y = clamp(mouse_pos.y, playarea_rect.position.y, playarea_rect.position.y + playarea_rect.size.y)

	# Calculate direction to mouse
	var direction = mouse_pos - global_position

	# Set velocity toward mouse (CRITICAL: velocity-based, not direct position)
	linear_velocity = direction * Level1Vars.shovel_follow_speed

	# Clamp rotation to max angle (use Level1Vars for upgradable limit)
	var current_rotation_deg = rad_to_deg(rotation)
	if abs(current_rotation_deg) > Level1Vars.shovel_max_rotation_degrees:
		# Clamp rotation
		rotation = deg_to_rad(clamp(current_rotation_deg, -Level1Vars.shovel_max_rotation_degrees, Level1Vars.shovel_max_rotation_degrees))
		# Apply bounce back torque in opposite direction
		var bounce_direction = -sign(current_rotation_deg)
		apply_torque_impulse(bounce_direction * Level1Vars.shovel_bounce_back_torque)

	# Update cooldown timer
	if scoop_cooldown_timer > 0.0:
		scoop_cooldown_timer -= delta

func tilt_left(delta: float):
	# Apply counter-clockwise torque (negative in Godot)
	# Scale by delta for consistent speed regardless of framerate
	apply_torque_impulse(-Level1Vars.shovel_tilt_torque * delta)

func tilt_right(delta: float):
	# Apply clockwise torque (positive in Godot)
	# Scale by delta for consistent speed regardless of framerate
	apply_torque_impulse(Level1Vars.shovel_tilt_torque * delta)
