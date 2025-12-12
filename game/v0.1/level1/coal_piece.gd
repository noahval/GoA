extends RigidBody2D

const COAL_PHYSICS_MAT = preload("res://level1/coal_physics_material.tres")
const OFFSCREEN_THRESHOLD: float = 2000.0  # Distance from origin before cleanup
const MAX_LIFETIME: float = 30.0  # Seconds before forced cleanup

var lifetime: float = 0.0

func _ready():
	# Setup physics properties
	mass = 0.3
	gravity_scale = 1.0
	linear_damp = 1.5  # Balanced damping - slows horizontal movement without affecting fall speed too much
	angular_damp = 3.0  # Increased from 1.5 to reduce spinning

	# Collision layers
	collision_layer = 3  # Coal on layer 3
	collision_mask = 7   # Binary 111 = collides with layers 1, 2, 3

	# Use shared physics material (friction 0.7, bounce 0.15)
	physics_material_override = COAL_PHYSICS_MAT

func _process(delta):
	lifetime += delta

	# Cleanup if too far from origin or too old
	if global_position.length() > OFFSCREEN_THRESHOLD or lifetime > MAX_LIFETIME:
		queue_free()
