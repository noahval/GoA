extends Node

# References set by scene
var camera: Camera2D = null
var coal_container: Node2D = null  # Parent node containing all coal RigidBody2D children

# Shake state
enum ShakeState { IDLE, WARNING, BIG_SHAKE }
var current_state: ShakeState = ShakeState.IDLE
var next_shake_timer: float = 0.0
var current_shake_timer: float = 0.0

# Camera shake offset tracking
var shake_offset: Vector2 = Vector2.ZERO

func _ready():
	randomize()
	schedule_next_shake()

func _process(delta):
	match current_state:
		ShakeState.IDLE:
			process_idle(delta)
		ShakeState.WARNING:
			process_warning(delta)
		ShakeState.BIG_SHAKE:
			process_big_shake(delta)

func process_idle(delta):
	if not Level1Vars.shake_enabled:
		return

	next_shake_timer -= delta

	if next_shake_timer <= 0.0:
		start_warning_shake()

func process_warning(delta):
	# Force cleanup if disabled mid-shake
	if not Level1Vars.shake_enabled:
		end_shake()
		return

	current_shake_timer -= delta

	# Apply warning shake to camera
	apply_camera_shake(Level1Vars.shake_warning_intensity)

	if current_shake_timer <= 0.0:
		start_big_shake()

func process_big_shake(delta):
	# Force cleanup if disabled mid-shake
	if not Level1Vars.shake_enabled:
		end_shake()
		return

	current_shake_timer -= delta

	# Apply big shake to camera
	apply_camera_shake(Level1Vars.shake_big_intensity)

	if current_shake_timer <= 0.0:
		end_shake()

func start_warning_shake():
	# Ignore if shake already active
	if current_state != ShakeState.IDLE:
		return

	current_state = ShakeState.WARNING
	current_shake_timer = Level1Vars.shake_warning_duration

	# Play warning sound
	play_warning_sound()

func start_big_shake():
	current_state = ShakeState.BIG_SHAKE

	# Random duration between min and max
	var duration = randf_range(Level1Vars.shake_big_duration_min, Level1Vars.shake_big_duration_max)
	current_shake_timer = duration

	# Apply coal shake impulse ONCE at shake start (not every frame to avoid accumulation)
	apply_coal_shake()

func end_shake():
	current_state = ShakeState.IDLE
	shake_offset = Vector2.ZERO

	# Reset camera offset
	if camera:
		camera.offset = Vector2.ZERO

	# Schedule next shake
	schedule_next_shake()

func schedule_next_shake():
	next_shake_timer = randf_range(Level1Vars.shake_interval_min, Level1Vars.shake_interval_max)

func apply_camera_shake(intensity: float):
	if not camera:
		return

	# Generate random target offset, then interpolate for smooth shake (prevents nauseating jitter)
	var target_angle = randf() * TAU
	var target_offset = Vector2(cos(target_angle), sin(target_angle)) * intensity
	shake_offset = shake_offset.lerp(target_offset, 0.3)  # Smooth interpolation

	camera.offset = shake_offset

func apply_coal_shake():
	# Get all coal pieces using the "coal" group (they're not children of coal_container)
	var coal_pieces = get_tree().get_nodes_in_group("coal")

	for coal in coal_pieces:
		if coal is RigidBody2D:
			# Apply random impulse in random direction
			var angle = randf() * TAU
			var impulse = Vector2(cos(angle), sin(angle)) * Level1Vars.shake_coal_impulse_strength
			coal.apply_central_impulse(impulse)

func play_warning_sound():
	# TODO: Implement audio system integration
	# AudioManager.play_sfx("train_rumble_warning")
	print("[SHAKE] Warning sound would play here")

# Called by scene to provide references
func initialize(cam: Camera2D, coal_parent: Node2D):
	camera = cam
	coal_container = coal_parent
