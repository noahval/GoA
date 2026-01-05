extends RigidBody2D

var has_been_tracked: bool = false  # Prevents double-counting

func _ready():
	# Add to coal group for border detection
	add_to_group("coal")

	# Setup physics properties
	mass = 0.3
	gravity_scale = 1.0
	linear_damp = 1.5  # Balanced damping - slows horizontal movement without affecting fall speed too much
	angular_damp = 3.0  # Increased from 1.5 to reduce spinning

	# Collision layers
	collision_layer = 4  # Layer 3 (2^2 = 4)
	collision_mask = 7   # Binary 111 = collides with layers 1, 2, 3

	# Create physics material programmatically (upgradable at runtime)
	var physics_mat = PhysicsMaterial.new()
	physics_mat.friction = Level1Vars.coal_friction
	physics_mat.bounce = Level1Vars.coal_bounce
	physics_material_override = physics_mat

	# Set collision shape radius from Level1Vars
	var collision_shape = $CollisionShape2D
	if collision_shape and collision_shape.shape:
		collision_shape.shape.radius = Level1Vars.coal_radius

	# Scale visual to match collision radius (default polygon is designed for 10px radius)
	var visual = $Visual
	if visual:
		var scale_factor = Level1Vars.coal_radius / 10.0
		visual.scale = Vector2(scale_factor, scale_factor)

# Called by border zone Area2D when coal enters drop zone
func _on_entered_drop_zone():
	# Skip if already counted as delivered
	if has_been_tracked:
		queue_free()  # Still remove it, just don't count
		return

	# Mark as tracked FIRST (before incrementing)
	has_been_tracked = true

	# Track as dropped
	Level1Vars.coal_dropped += 1
	if Level1Vars.DEBUG_COAL_TRACKING:
		print("[COAL] Dropped! Total: ", Level1Vars.coal_dropped)

	# Trigger rage system
	Level1Vars.on_coal_dropped_rage()

	# Flash red vignette
	var tree = get_tree()
	if tree:
		var vignette = tree.get_first_node_in_group("vignette")
		if vignette:
			vignette.flash_red()

	# Clean streak penalty (if unlocked)
	if Level1Vars.clean_streak_unlocked:
		# Check if forgiveness charges available
		if Level1Vars.forgiveness_charges > 0:
			# Use one forgiveness charge - don't break streak
			Level1Vars.forgiveness_charges -= 1
			if Level1Vars.DEBUG_COAL_TRACKING:
				print("[STREAK] Forgiveness saved streak! Charges remaining: %d" % Level1Vars.forgiveness_charges)
		else:
			# No forgiveness available - reset streak
			Level1Vars.clean_streak_count = 0
			Level1Vars.forgiveness_coal_counter = 0
			Level1Vars.emit_signal("clean_streak_changed", 0)

	# Heavy combo penalty (if unlocked) - dropping coal resets heavy stacks
	if Level1Vars.heavy_combo_unlocked:
		Level1Vars.heavy_combo_stacks = 0
		Level1Vars.heavy_combo_timer = 0.0
		Level1Vars.recent_delivery_timestamps.clear()
		Level1Vars.emit_signal("heavy_combo_changed", 0, 0.0)

	queue_free()  # Remove immediately

# Called by delivery zone Area2D when coal enters furnace
# Returns true if coal was successfully delivered, false if already tracked
func _on_entered_delivery_zone() -> bool:
	# Skip if already counted (matches drop handler pattern)
	if has_been_tracked:
		queue_free()  # Still remove it, just don't count
		return false

	# Mark as tracked FIRST (prevents drop zone from counting it during fade)
	has_been_tracked = true

	# Track as delivered
	Level1Vars.coal_delivered += 1
	if Level1Vars.DEBUG_COAL_TRACKING:
		print("[COAL] Delivered! Total: ", Level1Vars.coal_delivered)

	# Notify rage system (integrated in Level1Vars)
	Level1Vars.on_coal_delivered_rage()

	# Clean streak tracking (if unlocked)
	if Level1Vars.clean_streak_unlocked:
		Level1Vars.clean_streak_count = min(
			Level1Vars.clean_streak_count + 1,
			Level1Vars.get_clean_streak_max()
		)

		# Forgiveness charge tracking (hybrid threshold + capacity system)
		if "forgiveness" in Level1Vars.selected_techniques:
			Level1Vars.forgiveness_coal_counter += 1
			var threshold = Level1Vars.get_forgiveness_threshold()
			if Level1Vars.forgiveness_coal_counter >= threshold:
				# Award 1 charge if below capacity
				var max_capacity = Level1Vars.get_forgiveness_max_capacity()
				if Level1Vars.forgiveness_charges < max_capacity:
					Level1Vars.forgiveness_charges += 1
					if Level1Vars.DEBUG_COAL_TRACKING:
						print("[STREAK] Earned forgiveness charge! Total: %d/%d" % [Level1Vars.forgiveness_charges, max_capacity])
				Level1Vars.forgiveness_coal_counter = 0

		Level1Vars.emit_signal("clean_streak_changed", Level1Vars.clean_streak_count)

	# Red fade animation: gradually change color to red over 0.3 seconds, then remove
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.3)
	tween.finished.connect(queue_free)

	return true
