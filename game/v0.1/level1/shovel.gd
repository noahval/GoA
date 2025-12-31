extends RigidBody2D

const SHOVEL_WIDTH: float = 80.0

# Coal detection shape dimensions
const COAL_DETECTION_WIDTH: float = 80.0
const COAL_DETECTION_HEIGHT: float = 20.0

var shovel_curve: PackedVector2Array
var line_2d: Line2D
var outline_line: Line2D
var scoop_cooldown_timer: float = 0.0
var playarea: Control

# Coal tracking
var coal_bodies_on_shovel: Array[RigidBody2D] = []

# Work zone tracking
var in_work_zone: bool = false
var work_zone_boundary_x: float = 0.0

# Debug settings (toggle manually - not automatic)
var show_debug_overlay: bool = false

func _ready():
	# Get reference to playarea (parent's parent)
	playarea = get_parent().get_parent()

	# RigidBody2D physics setup (use Level1Vars for upgradable values)
	lock_rotation = false  # Allow rotation for tilt mechanic
	gravity_scale = 0.0  # No gravity
	linear_damp = Level1Vars.shovel_linear_damp
	angular_damp = Level1Vars.shovel_angular_damp

	# Set initial mass with technique multiplier
	update_shovel_mass()

	# Connect to clean streak signal for dynamic mass updates (Mass Training technique)
	Level1Vars.clean_streak_changed.connect(_on_clean_streak_changed)

	# Collision layers
	collision_layer = 2
	collision_mask = 1 | 4  # World (layer 1) + coal (layer 3)

	# Define shovel visual curve (for aesthetics only)
	# Pivot point is at y=0, which is halfway up the slanted sides
	shovel_curve = PackedVector2Array([
		Vector2(-40, -6),   # Left edge, slightly raised
		Vector2(-20, 4),    # Left-center, deeper
		Vector2(0, 7),      # Center, deepest point
		Vector2(20, 4),     # Right-center, deeper
		Vector2(40, -6)     # Right edge, slightly raised
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

	# Setup coal detection area
	setup_coal_detection()

	# Defer work zone boundary calculation until after layout is applied
	await get_tree().process_frame
	calculate_work_zone_boundary()

	# Recalculate boundary when viewport resizes
	get_viewport().size_changed.connect(_on_viewport_size_changed)

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

	# Update work zone status (use cached boundary)
	in_work_zone = global_position.x > work_zone_boundary_x

	# Calculate and apply stamina drain
	update_stamina_drain(delta)

	# Queue redraw for debug overlay
	if show_debug_overlay:
		queue_redraw()

	# Update cooldown timer
	if scoop_cooldown_timer > 0.0:
		scoop_cooldown_timer -= delta

func _input(event):
	# Toggle debug overlay with F3 key
	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		show_debug_overlay = !show_debug_overlay
		queue_redraw()

func _draw():
	if not show_debug_overlay:
		return

	# Draw coal count and drain rate
	var coal_count = coal_bodies_on_shovel.size()
	var debug_text = "Coal: %d" % coal_count

	if coal_count > 0 and in_work_zone:
		var drain_rate = Level1Vars.stamina_drain_base + (coal_count * Level1Vars.stamina_drain_per_coal)
		debug_text += " | Drain: %.2f/s" % drain_rate

	# Draw text above shovel
	draw_string(ThemeDB.fallback_font, Vector2(-20, -30), debug_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.RED)

func tilt_left(delta: float):
	# Apply counter-clockwise torque (negative in Godot)
	# Scale by delta for consistent speed regardless of framerate
	apply_torque_impulse(-Level1Vars.shovel_tilt_torque * delta)

func tilt_right(delta: float):
	# Apply clockwise torque (positive in Godot)
	# Scale by delta for consistent speed regardless of framerate
	apply_torque_impulse(Level1Vars.shovel_tilt_torque * delta)

func setup_coal_detection():
	# Create Area2D to detect coal pieces
	var detection_area = Area2D.new()
	detection_area.name = "CoalDetectionArea"
	add_child(detection_area)

	# Set collision layers: detect layer 3 (coal)
	detection_area.collision_layer = 0
	detection_area.collision_mask = 4  # Layer 3 (coal pieces)

	# Create CollisionShape2D matching shovel bowl
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(COAL_DETECTION_WIDTH, COAL_DETECTION_HEIGHT)
	collision_shape.shape = rect_shape
	collision_shape.position = Vector2(0, 5)  # Offset down from pivot point
	detection_area.add_child(collision_shape)

	# Connect signals
	detection_area.body_entered.connect(_on_coal_entered)
	detection_area.body_exited.connect(_on_coal_exited)

func _on_coal_entered(body: Node2D):
	if body is RigidBody2D and body.collision_layer & 4:  # Verify it's coal (layer 3)
		if body not in coal_bodies_on_shovel:
			coal_bodies_on_shovel.append(body)

func _on_coal_exited(body: Node2D):
	if body in coal_bodies_on_shovel:
		coal_bodies_on_shovel.erase(body)

func calculate_work_zone_boundary():
	if playarea:
		var playarea_rect = playarea.get_global_rect()
		work_zone_boundary_x = playarea_rect.position.x + (playarea_rect.size.x / 3.0)
		if Global.dev_speed_mode:
			print("Shovel work zone boundary calculated: x=", work_zone_boundary_x)
			print("  Playarea global pos: ", playarea_rect.position)
			print("  Playarea size: ", playarea_rect.size)

func _on_viewport_size_changed():
	# Recalculate boundary when window is resized
	# Defer one frame to ensure ResponsiveLayout and Control repositioning finishes
	await get_tree().process_frame
	calculate_work_zone_boundary()

func update_stamina_drain(delta: float):
	# Get current coal count
	var coal_count = coal_bodies_on_shovel.size()

	# Early exit if no coal on shovel
	if coal_count == 0:
		return

	# Check drain condition: has coal AND in work zone
	if in_work_zone:
		# Calculate drain rate with technique multipliers
		var base_drain = Level1Vars.stamina_drain_base * Level1Vars.get_base_stamina_drain_multiplier()
		var coal_drain = coal_count * Level1Vars.stamina_drain_per_coal * Level1Vars.get_coal_stamina_drain_multiplier()
		var total_drain = base_drain + coal_drain
		Level1Vars.modify_stamina(-total_drain * delta)

func update_shovel_mass():
	var base_mass = Level1Vars.shovel_mass  # Use base value from Level1Vars
	var mass_mult = Level1Vars.get_shovel_mass_multiplier()
	mass = base_mass * mass_mult

# Signal handler for clean streak changes
func _on_clean_streak_changed(_new_count: int):
	# If Mass Training is active, update shovel mass dynamically
	if "mass_training" in Level1Vars.selected_techniques:
		update_shovel_mass()
