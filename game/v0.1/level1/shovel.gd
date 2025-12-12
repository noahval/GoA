extends RigidBody2D

const SHOVEL_WIDTH: float = 80.0
const SHOVEL_PHYSICS_MAT = preload("res://level1/shovel_physics_material.tres")
const FOLLOW_SPEED: float = 3000.0  # How fast shovel moves toward mouse
const TILT_TORQUE: float = 20000.0  # Torque applied per second when holding
const MAX_ROTATION_DEGREES: float = 45.0  # Maximum tilt angle
const BOUNCE_BACK_TORQUE: float = 200.0  # Torque applied when hitting max tilt
const VELOCITY_SMOOTHING: float = 0.15  # Interpolation factor for smooth movement (lower = smoother)
const MAX_VELOCITY: float = 1200.0  # Maximum shovel speed to prevent explosive collisions

var shovel_curve: PackedVector2Array
var line_2d: Line2D
var outline_line: Line2D
var scoop_cooldown_timer: float = 0.0
var playarea: Control

func _ready():
	# Get reference to playarea (parent's parent)
	playarea = get_parent().get_parent()

	# RigidBody2D physics setup
	lock_rotation = false  # Allow rotation for tilt mechanic
	mass = 60.0  # Heavy enough to resist coal pushing it around
	gravity_scale = 0.0  # No gravity
	linear_damp = 15.0  # High damping for responsive stop
	angular_damp = 2.0  # Dampen rotation over time

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

	# Apply shared physics material
	physics_material_override = SHOVEL_PHYSICS_MAT

func _physics_process(delta):
	# Get mouse position
	var mouse_pos = get_global_mouse_position()

	if playarea:
		var playarea_rect = playarea.get_global_rect()
		mouse_pos.x = clamp(mouse_pos.x, playarea_rect.position.x, playarea_rect.position.x + playarea_rect.size.x)
		mouse_pos.y = clamp(mouse_pos.y, playarea_rect.position.y, playarea_rect.position.y + playarea_rect.size.y)

	# Calculate direction to mouse
	var direction = mouse_pos - global_position

	# Calculate target velocity (where we want to go)
	var target_velocity = direction * FOLLOW_SPEED * delta

	# Smoothly interpolate current velocity toward target velocity
	# This prevents sudden jerky movements when mouse moves quickly
	linear_velocity = linear_velocity.lerp(target_velocity, VELOCITY_SMOOTHING)

	# Cap maximum velocity to prevent explosive collisions
	if linear_velocity.length() > MAX_VELOCITY:
		linear_velocity = linear_velocity.normalized() * MAX_VELOCITY

	# Clamp rotation to max angle
	var current_rotation_deg = rad_to_deg(rotation)
	if abs(current_rotation_deg) > MAX_ROTATION_DEGREES:
		# Clamp rotation
		rotation = deg_to_rad(clamp(current_rotation_deg, -MAX_ROTATION_DEGREES, MAX_ROTATION_DEGREES))
		# Apply bounce back torque in opposite direction
		var bounce_direction = -sign(current_rotation_deg)
		apply_torque_impulse(bounce_direction * BOUNCE_BACK_TORQUE)

	# Update cooldown timer
	if scoop_cooldown_timer > 0.0:
		scoop_cooldown_timer -= delta

func tilt_left(delta: float):
	# Apply counter-clockwise torque (negative in Godot)
	# Scale by delta for consistent speed regardless of framerate
	apply_torque_impulse(-TILT_TORQUE * delta)

func tilt_right(delta: float):
	# Apply clockwise torque (positive in Godot)
	# Scale by delta for consistent speed regardless of framerate
	apply_torque_impulse(TILT_TORQUE * delta)
