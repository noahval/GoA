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

# Train shake mechanic
var shake_interval_min: float = 15.0  # Minimum seconds between shakes
var shake_interval_max: float = 60.0  # Maximum seconds between shakes
var shake_warning_duration: float = 0.5  # Warning time in seconds (upgradeable)
var shake_warning_intensity: float = 1.2  # Warning shake camera intensity (15% of big shake = 1.2/8.0)
var shake_big_duration_min: float = 0.5  # Big shake minimum duration
var shake_big_duration_max: float = 2.0  # Big shake maximum duration
var shake_big_intensity: float = 8.0  # Big shake camera intensity (pixels)
var shake_coal_impulse_strength: float = 75.0  # Physics impulse applied to coal (pixels/sec)
var shake_enabled: bool = true  # Master switch to enable/disable shakes

# Coal tracking - gameplay stats
var coal_dropped: int = 0   # Total coal pieces that fell/were dropped
var coal_delivered: int = 0 # Total coal pieces successfully delivered to furnace

# ===== CURRENCY SYSTEM (4-tier economy) =====

# Valid currency types (prevents typos)
const VALID_CURRENCIES = ["copper", "silver", "gold", "platinum"]

# Current currency holdings
var currency = {
	"copper": 0.0,
	"silver": 0.0,
	"gold": 0.0,
	"platinum": 0.0
}

# Lifetime currency earned (never decreases, tracks total ever earned)
var lifetime_currency = {
	"copper": 0.0,
	"silver": 0.0,
	"gold": 0.0,
	"platinum": 0.0
}

# Pay formula variables (tuneable for balance)
var pay_coal_per_copper: int = 25  # How many coal pieces = 1 copper
var pay_drop_penalty_percent: float = 0.0  # Percentage reduction per dropped coal (0-1.0, currently disabled)

# Debug flags
var DEBUG_COAL_TRACKING: bool = false  # Toggle coal drop console prints

# Signals
signal stamina_changed(new_value: float, max_value: float)
signal focus_changed(new_value: int, max_value: int)
signal resource_depleted(resource_name: String)
signal currency_changed(currency_type: String, old_amount: float, new_amount: float)

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
	# Legacy function - now uses new currency system
	add_currency("copper", float(amount))

# ===== CURRENCY SYSTEM FUNCTIONS =====

# Get empty currency dictionary (DRY principle)
func _get_empty_currency_dict() -> Dictionary:
	return {
		"copper": 0.0,
		"silver": 0.0,
		"gold": 0.0,
		"platinum": 0.0
	}

# Add currency of any type
func add_currency(currency_type: String, amount: float) -> void:
	if not currency_type in VALID_CURRENCIES:
		push_error("Invalid currency type: %s. Valid: %s" % [currency_type, VALID_CURRENCIES])
		return

	if amount <= 0:
		push_warning("Attempted to add non-positive amount: %.2f" % amount)
		return

	# Update current holdings
	var old_amount = currency[currency_type]
	currency[currency_type] += amount

	# Update lifetime earnings
	lifetime_currency[currency_type] += amount

	# Emit signal for reactive UI
	emit_signal("currency_changed", currency_type, old_amount, currency[currency_type])

# Deduct currency of any type
func deduct_currency(currency_type: String, amount: float) -> bool:
	if not currency_type in VALID_CURRENCIES:
		push_error("Invalid currency type: %s. Valid: %s" % [currency_type, VALID_CURRENCIES])
		return false

	if amount <= 0:
		push_warning("Attempted to deduct non-positive amount: %.2f" % amount)
		return false

	# Check if player has enough
	if currency[currency_type] < amount:
		return false

	# Deduct the amount
	var old_amount = currency[currency_type]
	currency[currency_type] -= amount

	# Emit signal for reactive UI
	emit_signal("currency_changed", currency_type, old_amount, currency[currency_type])

	return true

# Get current amount of a currency type
func get_currency(currency_type: String) -> float:
	return currency.get(currency_type, 0.0)

# Check if player can afford an amount
func can_afford(currency_type: String, amount: float) -> bool:
	return get_currency(currency_type) >= amount

# Check if player can afford multiple currencies at once
func can_afford_all(costs: Dictionary) -> bool:
	for currency_type in costs:
		if not can_afford(currency_type, costs[currency_type]):
			return false
	return true

# Deduct multiple currencies (all-or-nothing)
func deduct_currencies(costs: Dictionary) -> bool:
	# Check all first
	if not can_afford_all(costs):
		return false

	# Deduct all
	for currency_type in costs:
		if not deduct_currency(currency_type, costs[currency_type]):
			push_error("Failed to deduct %s after can_afford check passed" % currency_type)
			return false

	return true

# Complete reset for new game
func reset_all_currency() -> void:
	currency = _get_empty_currency_dict()
	lifetime_currency = _get_empty_currency_dict()

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
		# Train shake mechanic
		"shake_interval_min": shake_interval_min,
		"shake_interval_max": shake_interval_max,
		"shake_warning_duration": shake_warning_duration,
		"shake_warning_intensity": shake_warning_intensity,
		"shake_big_duration_min": shake_big_duration_min,
		"shake_big_duration_max": shake_big_duration_max,
		"shake_big_intensity": shake_big_intensity,
		"shake_coal_impulse_strength": shake_coal_impulse_strength,
		"shake_enabled": shake_enabled,
		# Gameplay stats
		"coal_dropped": coal_dropped,
		"coal_delivered": coal_delivered,
		# Currency (4-tier system)
		"currency": currency,
		"lifetime_currency": lifetime_currency
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

	# Train shake mechanic
	shake_interval_min = data.get("shake_interval_min", 15.0)
	shake_interval_max = data.get("shake_interval_max", 60.0)
	shake_warning_duration = data.get("shake_warning_duration", 0.5)
	shake_warning_intensity = data.get("shake_warning_intensity", 1.2)
	shake_big_duration_min = data.get("shake_big_duration_min", 0.5)
	shake_big_duration_max = data.get("shake_big_duration_max", 2.0)
	shake_big_intensity = data.get("shake_big_intensity", 8.0)
	shake_coal_impulse_strength = data.get("shake_coal_impulse_strength", 75.0)
	shake_enabled = data.get("shake_enabled", true)

	# Gameplay stats
	coal_dropped = data.get("coal_dropped", 0)
	coal_delivered = data.get("coal_delivered", 0)

	# Currency (4-tier system with backward compatibility)
	if data.has("currency"):
		currency = data.get("currency", _get_empty_currency_dict())
		lifetime_currency = data.get("lifetime_currency", _get_empty_currency_dict())
	else:
		# Backward compatibility: migrate old copper_current to new system
		currency = _get_empty_currency_dict()
		lifetime_currency = _get_empty_currency_dict()
		var old_copper = data.get("copper_current", 0)
		if old_copper > 0:
			currency["copper"] = float(old_copper)
			lifetime_currency["copper"] = float(old_copper)

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

	# Train shake mechanic
	shake_interval_min = 15.0
	shake_interval_max = 60.0
	shake_warning_duration = 0.5
	shake_warning_intensity = 1.2
	shake_big_duration_min = 0.5
	shake_big_duration_max = 2.0
	shake_big_intensity = 8.0
	shake_coal_impulse_strength = 75.0
	shake_enabled = true

	# Gameplay stats
	coal_dropped = 0
	coal_delivered = 0

	# Currency
	reset_all_currency()

	# Emit signals
	emit_signal("stamina_changed", stamina, stamina_max)
	emit_signal("focus_changed", focus, focus_max)
