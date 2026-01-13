extends Control

# Dishwash Minigame - Plan 2.18
# Player washes mugs by dunking in basin and drying through movement or waiting

enum MugState { DIRTY, WET, DRY }

var current_mug_state: MugState = MugState.DIRTY
var mug_bound_to_cursor: bool = false
var basin_soak_timer: float = 0.0
var dry_timer_start: float = 0.0
var last_mug_position: Vector2 = Vector2.ZERO
var time_saved_by_movement: float = 0.0
var mug_in_basin: bool = false

# Session tracking
var mugs_this_session: int = 0
var mugs_toward_hole: int = 0

# Constants
const REQUIRED_SOAK_TIME: float = 2.0
const AUTO_DRY_DURATION: float = 7.0
const PIXELS_PER_SECOND_SAVED: float = 200.0
const MUGS_PER_HOLE: int = 3
const MASTERY_THRESHOLD: int = 150

# Texture preloads
const MUG_DIRTY_TEXTURE = preload("res://level1/icons/mug-dirty.png")
const MUG_WET_TEXTURE = preload("res://level1/icons/mug-wet.png")
const MUG_CLEAN_TEXTURE = preload("res://level1/icons/mug-clean.png")

# Shader for gradual texture blending
const MUG_BLEND_SHADER = preload("res://level1/mug_blend.gdshader")
var mug_shader_material: ShaderMaterial

# Node references (set in _ready)
@onready var dirty_stack: Area2D = $DirtyStack
@onready var basin: Area2D = $Basin
@onready var drying_rack: Area2D = $DryingRack
@onready var bound_mug: Area2D = $BoundMug
@onready var mug_sprite: Sprite2D = $BoundMug/MugSprite
@onready var error_notification: Label = $ErrorNotification
@onready var water_particles: CPUParticles2D = $Basin/WaterParticles

func _ready():
	# Enable GUI input on this Control node (required for _gui_input() to work)
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Enable input detection on clickable Area2D nodes
	dirty_stack.input_pickable = true
	drying_rack.input_pickable = true
	bound_mug.input_pickable = false  # BoundMug doesn't need clicks

	# Enable Area2D monitoring for collision detection
	basin.monitoring = true
	basin.monitorable = true
	bound_mug.monitoring = false  # BoundMug doesn't need to monitor
	bound_mug.monitorable = true  # But needs to be detected by Basin

	# Enable physics processing for Area2D nodes
	basin.set_physics_process(true)
	bound_mug.set_physics_process(true)

	# Set collision layers/masks for detection to work
	# Basin: layer 1, mask 2 (detects objects on layer 2)
	# BoundMug: layer 2, mask 0 (doesn't detect anything, just gets detected)
	basin.collision_layer = 1
	basin.collision_mask = 2
	bound_mug.collision_layer = 2
	bound_mug.collision_mask = 0

	# Connect Area2D signals for basin collision
	basin.area_entered.connect(_on_basin_area_entered)
	basin.area_exited.connect(_on_basin_area_exited)

	print("[DISHWASH] Basin monitoring enabled: ", basin.monitoring)
	print("[DISHWASH] Basin collision_mask: ", basin.collision_mask)
	print("[DISHWASH] Basin has CollisionShape2D: ", basin.get_node_or_null("CollisionShape2D") != null)
	print("[DISHWASH] BoundMug monitorable: ", bound_mug.monitorable)
	print("[DISHWASH] BoundMug collision_layer: ", bound_mug.collision_layer)
	print("[DISHWASH] BoundMug has CollisionShape2D: ", bound_mug.get_node_or_null("CollisionShape2D") != null)

	# Note: Area2D.input_event doesn't work inside Control hierarchy
	# We use _gui_input() instead to handle clicks

	# Initialize state
	bound_mug.visible = false
	error_notification.visible = false
	water_particles.emitting = false

	# Set up shader material for gradual texture blending
	mug_shader_material = ShaderMaterial.new()
	mug_shader_material.shader = MUG_BLEND_SHADER
	mug_sprite.material = mug_shader_material
	# Initialize with dirty texture (no blend yet)
	mug_shader_material.set_shader_parameter("texture_a", MUG_DIRTY_TEXTURE)
	mug_shader_material.set_shader_parameter("texture_b", MUG_DIRTY_TEXTURE)
	mug_shader_material.set_shader_parameter("blend_factor", 0.0)

	# Make sure Background doesn't block clicks
	var background = $Background
	if background:
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if Global.dev_speed_mode:
		print("[DISHWASH] mouse_filter set to: ", mouse_filter)
		if background:
			print("[DISHWASH] Background mouse_filter set to: ", background.mouse_filter)

	# Position elements relative to control size (responsive layout)
	_position_elements()
	resized.connect(_position_elements)

	# Enhanced logging
	if Global.dev_speed_mode:
		print("[DISHWASH] Minigame initialized")
		print("[DISHWASH] DirtyStack position: ", dirty_stack.position)
		print("[DISHWASH] DirtyStack input_pickable: ", dirty_stack.input_pickable)
		print("[DISHWASH] Basin position: ", basin.position)
		print("[DISHWASH] DryingRack position: ", drying_rack.position)
		print("[DISHWASH] DryingRack input_pickable: ", drying_rack.input_pickable)

		# Add visual debug shapes for collision areas
		_add_debug_visuals()

func _position_elements():
	var control_size = size
	if control_size == Vector2.ZERO:
		if Global.dev_speed_mode:
			print("[DISHWASH] _position_elements() called but size is zero, returning early")
		return  # Not ready yet

	# Dirty stack: top-left corner
	dirty_stack.position = Vector2(80, 60)  # Fixed position in top-left corner

	# Basin: center-bottom (50% horizontal, 80% vertical)
	basin.position = Vector2(control_size.x * 0.5, control_size.y * 0.80)

	# Drying rack: top-right (85% horizontal, 15% vertical)
	drying_rack.position = Vector2(control_size.x * 0.85, control_size.y * 0.15)

	if Global.dev_speed_mode:
		print("[DISHWASH] _position_elements() completed:")
		print("  DirtyStack.position: ", dirty_stack.position)
		print("  Basin.position: ", basin.position)
		print("  DryingRack.position: ", drying_rack.position)

	# Update debug visuals if they exist
	if Global.dev_speed_mode:
		_update_debug_visuals()

func _add_debug_visuals():
	# Add visual indicators for collision shapes when in debug mode
	_add_debug_rect(dirty_stack, Color(0, 1, 0, 0.3), "DirtyStack")
	_add_debug_rect(basin, Color(0, 0, 1, 0.3), "Basin")
	_add_debug_rect(drying_rack, Color(1, 0, 0, 0.3), "DryingRack")
	_add_debug_rect(bound_mug, Color(1, 1, 0, 0.3), "BoundMug")

func _add_debug_rect(area: Area2D, color: Color, label_text: String):
	# Use sizes that match clickable areas
	var rect_size: Vector2

	if area == dirty_stack:
		rect_size = Vector2(200, 140)  # Match clickable area
	elif area == basin:
		rect_size = Vector2(450, 150)  # 300% wider, 50% taller
	elif area == drying_rack:
		rect_size = Vector2(160, 120)  # Match clickable area
	elif area == bound_mug:
		rect_size = Vector2(40, 50)
	else:
		return

	# Create debug ColorRect
	var debug_rect = ColorRect.new()
	debug_rect.color = color
	debug_rect.size = rect_size
	debug_rect.position = -rect_size / 2  # Center on Area2D
	debug_rect.name = "DebugRect"
	debug_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block clicks
	area.add_child(debug_rect)

	# Add label
	var debug_label = Label.new()
	debug_label.text = label_text + "\n(clickable)" if area.input_pickable else label_text
	debug_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	debug_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	debug_label.size = rect_size
	debug_label.position = -rect_size / 2
	debug_label.name = "DebugLabel"
	debug_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	area.add_child(debug_label)

func _update_debug_visuals():
	# Debug rects are already positioned correctly, no need to update
	pass

func _gui_input(event):
	# Handle clicks on the Control node (Area2D.input_event doesn't work in Control hierarchy)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_pos = event.position

		if Global.dev_speed_mode:
			print("[DISHWASH GUI] Mouse clicked at: ", click_pos)

		# Check if click is within DirtyStack bounds
		if _is_point_in_area(click_pos, dirty_stack):
			_on_dirty_stack_clicked()
			return

		# Check if click is within DryingRack bounds
		if _is_point_in_area(click_pos, drying_rack):
			_on_rack_clicked()
			return

func _is_point_in_area(point: Vector2, area: Area2D) -> bool:
	# Use generous clickable sizes that match or exceed visual sprites
	var half_size: Vector2

	if area == dirty_stack:
		# Make clickable area large to cover the mug sprites generously
		half_size = Vector2(100, 70)  # 200x140 total clickable area
	elif area == drying_rack:
		# Make clickable area large enough to cover the rack sprite
		half_size = Vector2(80, 60)  # 160x120 total clickable area
	else:
		if Global.dev_speed_mode:
			print("[DISHWASH] Unknown area: ", area.name)
		return false

	# Calculate bounds (collision shape is centered on Area2D)
	var area_pos = area.position
	var min_bound = area_pos - half_size
	var max_bound = area_pos + half_size

	# Check if point is within bounds
	var inside = point.x >= min_bound.x and point.x <= max_bound.x and point.y >= min_bound.y and point.y <= max_bound.y

	if Global.dev_speed_mode:
		print("[DISHWASH] Checking ", area.name, ": point=", point, " bounds=[", min_bound, " to ", max_bound, "] inside=", inside)

	return inside

func _process(delta):
	# Don't process when minigame is hidden
	if not visible:
		return

	# Update mug position to follow cursor if bound
	if mug_bound_to_cursor:
		var mouse_pos = get_global_mouse_position()
		bound_mug.global_position = mouse_pos

		# Debug: show positions to check if overlap is happening
		var basin_global = basin.global_position
		var distance_to_basin = mouse_pos.distance_to(basin_global)
		if distance_to_basin < 250:  # Close to basin
			print("[DISHWASH] Near basin - Mouse:", mouse_pos, " Basin:", basin_global, " Distance:", distance_to_basin)
			print("[DISHWASH]   BoundMug global_pos:", bound_mug.global_position, " local_pos:", bound_mug.position)

			# Manual overlap check (basin is 450x150)
			var basin_half_size = Vector2(225, 75)
			var mug_in_basin_manual = (
				abs(mouse_pos.x - basin_global.x) < basin_half_size.x and
				abs(mouse_pos.y - basin_global.y) < basin_half_size.y
			)
			print("[DISHWASH]   Manual overlap check: ", mug_in_basin_manual)
			print("[DISHWASH]   Basin.monitoring=", basin.monitoring, " BoundMug.monitorable=", bound_mug.monitorable)

	# Basin soaking timer (DIRTY -> WET transition)
	if current_mug_state == MugState.DIRTY and mug_in_basin:
		basin_soak_timer += delta
		if int(basin_soak_timer * 10) % 5 == 0:  # Print every 0.5 seconds
			print("[DISHWASH] Soaking progress: ", basin_soak_timer, " / ", REQUIRED_SOAK_TIME)
		if basin_soak_timer >= REQUIRED_SOAK_TIME:
			print("[DISHWASH] Soak complete - transitioning to WET")
			transition_to_wet()

	# Air drying through movement (optional speedup)
	if mug_bound_to_cursor and current_mug_state == MugState.WET:
		var current_pos = get_global_mouse_position()
		var distance_moved = current_pos.distance_to(last_mug_position)

		# Convert distance to time saved
		time_saved_by_movement += distance_moved / PIXELS_PER_SECOND_SAVED

		# Update position for next frame
		last_mug_position = current_pos

	# Auto-dry timer (WET -> DRY transition)
	if current_mug_state == MugState.WET and dry_timer_start > 0.0:
		var elapsed = (Time.get_ticks_msec() / 1000.0) - dry_timer_start
		var adjusted_time = elapsed + time_saved_by_movement

		if adjusted_time >= AUTO_DRY_DURATION:
			transition_to_dry()

	# Update shader blend for gradual visual transitions
	_update_mug_shader_blend()

func _on_basin_area_entered(area: Area2D):
	print("[DISHWASH] Basin area_entered signal fired! Area: ", area.name)
	# Only respond to BoundMug entering basin
	if area == bound_mug and mug_bound_to_cursor and current_mug_state == MugState.DIRTY:
		print("[DISHWASH] BoundMug entered basin - starting soak")
		mug_in_basin = true
		basin_soak_timer = 0.0
		water_particles.emitting = true
	else:
		print("[DISHWASH] Basin entry rejected - area==bound_mug:", area == bound_mug, " mug_bound:", mug_bound_to_cursor, " state:", current_mug_state)

func _on_basin_area_exited(area: Area2D):
	# Only respond to BoundMug leaving basin
	if area == bound_mug:
		mug_in_basin = false
		water_particles.emitting = false
		# Only start drying timer if mug is WET (not DIRTY)
		if current_mug_state == MugState.WET:
			dry_timer_start = Time.get_ticks_msec() / 1000.0
			time_saved_by_movement = 0.0

func transition_to_wet():
	current_mug_state = MugState.WET
	basin_soak_timer = 0.0
	# Shader will handle visual transition now

func transition_to_dry():
	current_mug_state = MugState.DRY
	dry_timer_start = 0.0
	time_saved_by_movement = 0.0
	# Shader will handle visual transition now

func _update_mug_shader_blend():
	# Update shader parameters for gradual texture blending based on state and progress
	match current_mug_state:
		MugState.DIRTY:
			# Blend from dirty to wet based on soak progress
			if mug_in_basin:
				var soak_progress = clamp(basin_soak_timer / REQUIRED_SOAK_TIME, 0.0, 1.0)
				mug_shader_material.set_shader_parameter("texture_a", MUG_DIRTY_TEXTURE)
				mug_shader_material.set_shader_parameter("texture_b", MUG_WET_TEXTURE)
				mug_shader_material.set_shader_parameter("blend_factor", soak_progress)
			else:
				# Not in basin, stay fully dirty
				mug_shader_material.set_shader_parameter("texture_a", MUG_DIRTY_TEXTURE)
				mug_shader_material.set_shader_parameter("texture_b", MUG_DIRTY_TEXTURE)
				mug_shader_material.set_shader_parameter("blend_factor", 0.0)

		MugState.WET:
			# Blend from wet to clean based on dry progress
			if dry_timer_start > 0.0:
				var elapsed = (Time.get_ticks_msec() / 1000.0) - dry_timer_start
				var adjusted_time = elapsed + time_saved_by_movement
				var dry_progress = clamp(adjusted_time / AUTO_DRY_DURATION, 0.0, 1.0)
				mug_shader_material.set_shader_parameter("texture_a", MUG_WET_TEXTURE)
				mug_shader_material.set_shader_parameter("texture_b", MUG_CLEAN_TEXTURE)
				mug_shader_material.set_shader_parameter("blend_factor", dry_progress)
			else:
				# Drying hasn't started yet, stay fully wet
				mug_shader_material.set_shader_parameter("texture_a", MUG_WET_TEXTURE)
				mug_shader_material.set_shader_parameter("texture_b", MUG_WET_TEXTURE)
				mug_shader_material.set_shader_parameter("blend_factor", 0.0)

		MugState.DRY:
			# Fully clean
			mug_shader_material.set_shader_parameter("texture_a", MUG_CLEAN_TEXTURE)
			mug_shader_material.set_shader_parameter("texture_b", MUG_CLEAN_TEXTURE)
			mug_shader_material.set_shader_parameter("blend_factor", 1.0)

func _on_dirty_stack_clicked():
	if Global.dev_speed_mode:
		print("[DISHWASH] DirtyStack clicked")
		print("[DISHWASH] mug_bound_to_cursor: ", mug_bound_to_cursor)

	if not mug_bound_to_cursor:
		bind_mug_to_cursor()
	else:
		show_error_notification("Finish current mug first!")

func _on_rack_clicked():
	if Global.dev_speed_mode:
		print("[DISHWASH] DryingRack clicked")
		print("[DISHWASH] mug_bound_to_cursor: ", mug_bound_to_cursor)

	if mug_bound_to_cursor:
		attempt_rack_placement()

func bind_mug_to_cursor():
	if Global.dev_speed_mode:
		print("[DISHWASH] Binding mug to cursor")

	mug_bound_to_cursor = true
	current_mug_state = MugState.DIRTY
	last_mug_position = get_global_mouse_position()
	time_saved_by_movement = 0.0
	basin_soak_timer = 0.0
	dry_timer_start = 0.0
	mug_in_basin = false
	bound_mug.visible = true

	# Reset shader to fully dirty state
	mug_shader_material.set_shader_parameter("texture_a", MUG_DIRTY_TEXTURE)
	mug_shader_material.set_shader_parameter("texture_b", MUG_DIRTY_TEXTURE)
	mug_shader_material.set_shader_parameter("blend_factor", 0.0)

	if Global.dev_speed_mode:
		print("[DISHWASH] Mug bound - position: ", bound_mug.global_position)

func attempt_rack_placement():
	if current_mug_state == MugState.DIRTY:
		show_error_notification("Clean it first!")
		return
	elif current_mug_state == MugState.WET:
		show_error_notification("Dry it first!")
		return
	elif current_mug_state == MugState.DRY:
		complete_mug()

func show_error_notification(message: String):
	error_notification.text = message
	error_notification.visible = true

	# Create timer to hide notification
	var timer = get_tree().create_timer(1.0)
	timer.timeout.connect(func(): error_notification.visible = false)

func complete_mug():
	mugs_this_session += 1
	mugs_toward_hole += 1
	Level1Vars.mugs_washed += 1

	# Unbind mug
	mug_bound_to_cursor = false
	bound_mug.visible = false
	basin_soak_timer = 0.0
	dry_timer_start = 0.0
	time_saved_by_movement = 0.0
	mug_in_basin = false

	# Award Holes (every 3 mugs)
	if mugs_toward_hole >= MUGS_PER_HOLE:
		mugs_toward_hole = 0
		Level1Vars.add_currency("holes", 1.0)
		Global.show_notification("+1 Hole earned!", Global.NOTIFICATION_TYPE_POSITIVE)

	check_mastery_unlock()

func check_mastery_unlock():
	if Level1Vars.mugs_washed >= MASTERY_THRESHOLD and not Level1Vars.dishwash_mastery_unlocked:
		Level1Vars.dishwash_mastery_unlocked = true
		Global.show_notification("Dishwashing mastered! Passive mode unlocked.", Global.NOTIFICATION_TYPE_POSITIVE)

# Called from bar.gd when starting washing
func start_washing():
	if Global.dev_speed_mode:
		print("[DISHWASH] Starting washing session")

	mugs_this_session = 0
	mugs_toward_hole = 0
	visible = true

	# Position elements now that control is visible and has size
	_position_elements()

	if Global.dev_speed_mode:
		print("[DISHWASH] Minigame visible: ", visible)
		print("[DISHWASH] Control size: ", size)
		print("[DISHWASH] DirtyStack repositioned to: ", dirty_stack.position)
		print("[DISHWASH] Basin repositioned to: ", basin.position)
		print("[DISHWASH] DryingRack repositioned to: ", drying_rack.position)

# Called from bar.gd when stopping washing
func stop_washing():
	# Clean up if mug is currently bound
	if mug_bound_to_cursor:
		mug_bound_to_cursor = false
		bound_mug.visible = false

	# Reset ALL state to prevent corruption between sessions
	current_mug_state = MugState.DIRTY
	basin_soak_timer = 0.0
	dry_timer_start = 0.0
	time_saved_by_movement = 0.0
	mug_in_basin = false
	water_particles.emitting = false

	visible = false
