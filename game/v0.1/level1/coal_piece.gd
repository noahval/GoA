extends RigidBody2D

func _ready():
	# Setup physics properties
	mass = 0.3
	gravity_scale = 1.0
	linear_damp = 1.5  # Balanced damping - slows horizontal movement without affecting fall speed too much
	angular_damp = 3.0  # Increased from 1.5 to reduce spinning

	# Collision layers
	collision_layer = 3  # Coal on layer 3
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
