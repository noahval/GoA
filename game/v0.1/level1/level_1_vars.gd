extends Node

# Resource management
var stamina: float = 50.0      # Current stamina (consumed by physical actions)
var stamina_max: float = 50.0  # Maximum stamina capacity
var focus: int = 50            # Current focus (consumed by mental actions)
var focus_max: int = 100        # Maximum focus capacity

# Stamina drain rates (stamina per second)
var stamina_drain_base: float = 0.2  # Base drain for shovel weight
var stamina_drain_per_coal: float = 0.1  # Additional drain per coal piece

# Shovel physics - upgradable values
var shovel_follow_speed: float = 10.0  # How fast shovel moves toward mouse
var shovel_linear_damp: float = 15.0     # How fast shovel stops moving
var shovel_mass: float = 80.0            # Shovel weight/inertia
var shovel_tilt_torque: float = 108000.0 # How fast shovel rotates when tilting
var shovel_max_rotation_degrees: float = 90.0  # Maximum tilt angle
var shovel_bounce_back_torque: float = 200.0   # Pushback at rotation limit
var shovel_angular_damp: float = 2.0     # How fast rotation dampens

# Physics materials - upgradable values (created programmatically, not .tres)
var coal_friction: float = 0.7    # How coal grips surfaces
var coal_bounce: float = 0.15     # Coal bounciness
var shovel_friction: float = 0.7  # How coal grips shovel
var shovel_bounce: float = 0.1    # Coal bounce off shovel

# Coal properties - upgradable
var coal_radius: float = 5.0      # Coal piece size in pixels (affects collision and visual)

# Furnace difficulty - upgradable
var furnace_opening_height_percent: float = 0.20  # Target size (smaller = harder)

# Coal tracking - gameplay stats
var coal_dropped: int = 0   # Total coal pieces that fell/were dropped
var coal_delivered: int = 0 # Total coal pieces successfully delivered to furnace

# Currency
var copper_current: int = 0  # Current copper pieces owned

# Pay formula variables (tuneable for balance)
var pay_coal_per_copper: int = 25  # How many coal pieces = 1 copper
var pay_drop_penalty_percent: float = 0.0  # Percentage reduction per dropped coal (0-1.0, currently disabled)

# Debug flags
var DEBUG_COAL_TRACKING: bool = false  # Toggle coal drop console prints

# Signals
signal stamina_changed(new_value: float, max_value: float)
signal focus_changed(new_value: int, max_value: int)
signal resource_depleted(resource_name: String)

# Resource management functions
func modify_stamina(amount: float) -> bool:
	stamina = clampf(stamina + amount, 0.0, stamina_max)
	emit_signal("stamina_changed", stamina, stamina_max)
	return true

func modify_focus(amount: int) -> bool:
	var new_value = focus + amount

	# Check if we have enough for consumption (negative amount)
	if amount < 0 and new_value < 0:
		emit_signal("resource_depleted", "focus")
		return false

	# Clamp to valid range
	focus = clampi(new_value, 0, focus_max)
	emit_signal("focus_changed", focus, focus_max)
	return true

func restore_all_resources():
	stamina = stamina_max
	focus = focus_max
	emit_signal("stamina_changed", stamina, stamina_max)
	emit_signal("focus_changed", focus, focus_max)

func calculate_pay() -> int:
	# Validate pay_coal_per_copper to prevent division errors
	if pay_coal_per_copper <= 0:
		push_error("Invalid pay_coal_per_copper: %d" % pay_coal_per_copper)
		return 0

	# Base formula: 1 copper per 25 coal delivered
	# Integer division rounds down (24 coal = 0 copper, 25 coal = 1 copper)
	var base_pay = coal_delivered / pay_coal_per_copper

	# Future modifications can be added here:
	# - Drop penalties (if pay_drop_penalty_percent > 0)
	# - Bonuses from upgrades/equipment
	# - Event modifiers (double pay days, etc.)
	# - Combo/streak bonuses

	# Ensure non-negative result
	return max(0, int(base_pay))

func award_pay(amount: int):
	copper_current += amount
	# Future: emit signal for UI updates if needed

# Save/load integration
func get_save_data() -> Dictionary:
	return {
		"stamina": stamina,
		"stamina_max": stamina_max,
		"focus": focus,
		"focus_max": focus_max,
		# Physics upgrades
		"shovel_follow_speed": shovel_follow_speed,
		"shovel_linear_damp": shovel_linear_damp,
		"shovel_mass": shovel_mass,
		"shovel_tilt_torque": shovel_tilt_torque,
		"shovel_max_rotation_degrees": shovel_max_rotation_degrees,
		"shovel_bounce_back_torque": shovel_bounce_back_torque,
		"shovel_angular_damp": shovel_angular_damp,
		"coal_friction": coal_friction,
		"coal_bounce": coal_bounce,
		"shovel_friction": shovel_friction,
		"shovel_bounce": shovel_bounce,
		"coal_radius": coal_radius,
		"furnace_opening_height_percent": furnace_opening_height_percent,
		# Gameplay stats
		"coal_dropped": coal_dropped,
		"coal_delivered": coal_delivered,
		# Currency
		"copper_current": copper_current
	}

func load_save_data(data: Dictionary):
	# Resources
	stamina = data.get("stamina", 50)
	stamina_max = data.get("stamina_max", 100)
	focus = data.get("focus", 50)
	focus_max = data.get("focus_max", 100)

	# Physics upgrades
	shovel_follow_speed = data.get("shovel_follow_speed", 10.0)
	shovel_linear_damp = data.get("shovel_linear_damp", 15.0)
	shovel_mass = data.get("shovel_mass", 100.0)
	shovel_tilt_torque = data.get("shovel_tilt_torque", 108000.0)
	shovel_max_rotation_degrees = data.get("shovel_max_rotation_degrees", 45.0)
	shovel_bounce_back_torque = data.get("shovel_bounce_back_torque", 200.0)
	shovel_angular_damp = data.get("shovel_angular_damp", 2.0)
	coal_friction = data.get("coal_friction", 0.7)
	coal_bounce = data.get("coal_bounce", 0.15)
	shovel_friction = data.get("shovel_friction", 0.7)
	shovel_bounce = data.get("shovel_bounce", 0.1)
	coal_radius = data.get("coal_radius", 5.0)
	furnace_opening_height_percent = data.get("furnace_opening_height_percent", 0.20)

	# Gameplay stats
	coal_dropped = data.get("coal_dropped", 0)
	coal_delivered = data.get("coal_delivered", 0)

	# Currency
	copper_current = data.get("copper_current", 0)

	# Emit signals to update UI
	emit_signal("stamina_changed", stamina, stamina_max)
	emit_signal("focus_changed", focus, focus_max)

func reset_to_defaults():
	# Resources
	stamina = 50
	stamina_max = 100
	focus = 50
	focus_max = 100

	# Physics (reset to base values, not upgraded values)
	shovel_follow_speed = 10.0
	shovel_linear_damp = 15.0
	shovel_mass = 100.0
	shovel_tilt_torque = 108000.0
	shovel_max_rotation_degrees = 45.0
	shovel_bounce_back_torque = 200.0
	shovel_angular_damp = 2.0
	coal_friction = 0.7
	coal_bounce = 0.15
	shovel_friction = 0.7
	shovel_bounce = 0.1
	coal_radius = 5.0
	furnace_opening_height_percent = 0.20

	# Gameplay stats
	coal_dropped = 0
	coal_delivered = 0

	# Emit signals
	emit_signal("stamina_changed", stamina, stamina_max)
	emit_signal("focus_changed", focus, focus_max)
