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

# Player progression (shoveling mastery)
var player_level: int = 1
var player_exp: float = 0.0

# XP curve configuration
const BASE_XP_FOR_LEVEL: float = 12.0
const EXP_SCALING: float = 1.25  # Gentler than Global stats (1.8) for faster early progression

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

# ===== UPGRADE SYSTEM (Technique Pool) =====

# TechniquesData is globally available via class_name
const TECHNIQUES = TechniquesData.TECHNIQUES

# Upgrade tracking
var upgrades_qty: int = 0  # Total upgrades selected this run (for Mind button visibility)

# Technique selection tracking
var selected_techniques: Dictionary = {}
# Structure: { technique_id: { "level": int, "qualities": Array[String] } }

# Combo system unlock flags
var clean_streak_unlocked: bool = false
var heavy_combo_unlocked: bool = false

# UI display settings
var show_exact_technique_values: bool = true  # Show exact percentages in descriptions

# Clean streak state
var clean_streak_count: int = 0
var clean_streak_max: int = 20  # Increased by Streak Ceiling technique
var forgiveness_charges: int = 0  # Charges available to save streak from drops
var forgiveness_coal_counter: int = 0  # Coal delivered since last charge earned
var forgiveness_threshold: int = 0  # Coal needed to earn 1 charge (set by first selection quality)
var forgiveness_max_capacity: int = 0  # Maximum charges that can be banked

# Heavy load combo state
var heavy_combo_stacks: int = 0
var heavy_combo_timer: float = 0.0  # Counts down from 5.0s + bonuses
var recent_delivery_timestamps: Array[float] = []  # Timestamps of recent deliveries for batch detection
const HEAVY_LOAD_BATCH_WINDOW: float = 1.0  # Time window for detecting 3+ coal deliveries (seconds)

# Signals
signal stamina_changed(new_value: float, max_value: float)
signal focus_changed(new_value: int, max_value: int)
signal resource_depleted(resource_name: String)
signal currency_changed(currency_type: String, old_amount: float, new_amount: float)
signal player_exp_changed(new_exp: float, xp_for_next_level: float)
signal technique_updated(technique_id: String, new_level: int)
signal clean_streak_changed(new_count: int)
signal heavy_combo_changed(new_stacks: int, timer_remaining: float)

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

# ===== PLAYER PROGRESSION (XP SYSTEM) =====

# Award experience and check for level-ups
func add_player_exp(amount: float) -> void:
	if amount <= 0:
		return  # Reject zero/negative XP

	player_exp += amount
	emit_signal("player_exp_changed", player_exp, get_xp_for_next_level())

	# Check for level-up(s)
	while player_exp >= get_xp_for_next_level():
		# Deduct XP for current level
		player_exp -= get_xp_for_next_level()

		# Level up
		player_level += 1

		# Show notification
		_show_levelup_notification()

		# Emit after level-up to update bar with new max value
		emit_signal("player_exp_changed", player_exp, get_xp_for_next_level())

# Calculate total cumulative XP needed to reach a specific level from level 1
# Returns TOTAL XP, not incremental (e.g., level 3 returns sum of all XP from 1->2->3)
func get_xp_for_level(level: int) -> float:
	if level <= 1:
		return 0.0

	# Sum XP for all levels from 2 to target level
	var total_xp = 0.0
	for lvl in range(2, level + 1):
		# Each level's XP requirement: BASE_XP * (level - 1) ^ EXP_SCALING
		total_xp += BASE_XP_FOR_LEVEL * pow(lvl - 1, EXP_SCALING)

	return total_xp

# Get XP needed for next level from current level
func get_xp_for_next_level() -> float:
	return get_xp_for_level(player_level + 1) - get_xp_for_level(player_level)

# Get progress toward next level (0.0 to 1.0)
func get_level_progress() -> float:
	var xp_needed = get_xp_for_next_level()
	if xp_needed <= 0:
		return 0.0
	return clampf(player_exp / xp_needed, 0.0, 1.0)

# Show level-up notification
func _show_levelup_notification() -> void:
	if Global.has_method("show_notification"):
		Global.show_notification("Level up! You are now level %d" % player_level)
	else:
		print("LEVEL UP: Player is now level %d" % player_level)

# ===== TECHNIQUE SYSTEM FUNCTIONS =====

func add_technique(technique_id: String, draw_quality: String) -> void:
	if technique_id not in selected_techniques:
		selected_techniques[technique_id] = {
			"level": 1,
			"qualities": [draw_quality]
		}
	else:
		selected_techniques[technique_id]["level"] += 1
		selected_techniques[technique_id]["qualities"].append(draw_quality)

	# Check if this technique unlocks a combo system
	if technique_id in TECHNIQUES:
		var tech_data = TECHNIQUES[technique_id]
		if tech_data.has("unlocks_combo") and tech_data["unlocks_combo"]:
			if tech_data["category"] == "clean_streak":
				clean_streak_unlocked = true
			elif tech_data["category"] == "heavy_combo":
				heavy_combo_unlocked = true

	emit_signal("technique_updated", technique_id, selected_techniques[technique_id]["level"])

func get_technique_level(technique_id: String) -> int:
	if technique_id not in selected_techniques:
		return 0
	return selected_techniques[technique_id]["level"]

func reset_techniques() -> void:
	upgrades_qty = 0
	selected_techniques.clear()
	clean_streak_unlocked = false
	heavy_combo_unlocked = false
	clean_streak_count = 0
	clean_streak_max = 20
	forgiveness_charges = 0
	forgiveness_coal_counter = 0
	forgiveness_threshold = 0
	forgiveness_max_capacity = 0
	heavy_combo_stacks = 0
	heavy_combo_timer = 0.0
	recent_delivery_timestamps.clear()

# ============================================================================
# TECHNIQUE EFFECT HELPERS
# ============================================================================

# Core calculation function - sums all quality-scaled bonuses for a technique
# Used for additive effects (XP bonuses, mass bonuses, combo stacking)
func get_technique_total_bonus(technique_id: String) -> float:
	if technique_id not in selected_techniques:
		return 0.0

	# Validate technique exists in definition
	if technique_id not in TECHNIQUES:
		push_warning("Unknown technique: " + technique_id)
		return 0.0

	# Handle boolean techniques (like Perfect Form)
	var effect_data = TECHNIQUES[technique_id]["effect"]
	if effect_data.has("type") and effect_data["type"] == "boolean":
		return 0.0  # Boolean techniques checked with has_technique(), not bonus calculation

	var base_bonus = effect_data["base_bonus"]
	var qualities = selected_techniques[technique_id]["qualities"]
	var total = 0.0

	for quality in qualities:
		var quality_mult = get_quality_multiplier(quality)
		total += base_bonus * quality_mult

	return total

func get_quality_multiplier(quality: String) -> float:
	match quality:
		"common": return 1.0
		"uncommon": return 1.1
		"rare": return 1.2
		"epic": return 1.4
		"legendary": return 1.6
		_:
			push_warning("Unknown quality tier: " + quality)
			return 1.0

# Returns multiplier for base stamina drain (from holding shovel)
# Affected by: Rhythm, Determination, Cadence, Perfect Form
# Uses MULTIPLICATIVE stacking - each effect reduces current drain, not base drain
func get_base_stamina_drain_multiplier() -> float:
	var mult = 1.0

	# Rhythm: Each selection reduces current drain by 20% (multiplicative)
	if "rhythm" in selected_techniques:
		var qualities = selected_techniques["rhythm"]["qualities"]
		for quality in qualities:
			var quality_mult = get_quality_multiplier(quality)
			var reduction = 0.20 * quality_mult  # 20% base, 22-32% with quality
			mult *= (1.0 - reduction)

	# Determination: Each selection reduces current drain by 12% (multiplicative)
	if "determination" in selected_techniques:
		var qualities = selected_techniques["determination"]["qualities"]
		for quality in qualities:
			var quality_mult = get_quality_multiplier(quality)
			var reduction = 0.12 * quality_mult  # 12% base, 13-19% with quality
			mult *= (1.0 - reduction)

	# Cadence: Clean streak applies additive reduction (total from all selections x streak count)
	if "cadence" in selected_techniques and clean_streak_unlocked:
		var cadence_total = get_technique_total_bonus("cadence")  # Sum all selections
		var combo_reduction = cadence_total * clean_streak_count  # 3% per stack per selection
		mult *= max(0.0, 1.0 - combo_reduction)  # Apply as single multiplier

	# Perfect Form: -50% at 10+ streak (boolean)
	if "perfect_form" in selected_techniques and clean_streak_count >= 10:
		mult *= 0.50  # Reduces to 50% of current drain

	return mult  # No floor cap - natural diminishing returns from multiplicative stacking

# Returns multiplier for coal carrying stamina drain
# Affected by: Economy of Motion, Determination, Power Surge
# Uses MULTIPLICATIVE stacking - each effect reduces current drain, not base drain
func get_coal_stamina_drain_multiplier() -> float:
	var mult = 1.0

	# Economy of Motion: Each selection reduces current drain by 15% (multiplicative)
	if "economy_of_motion" in selected_techniques:
		var qualities = selected_techniques["economy_of_motion"]["qualities"]
		for quality in qualities:
			var quality_mult = get_quality_multiplier(quality)
			var reduction = 0.15 * quality_mult  # 15% base, 17-24% with quality
			mult *= (1.0 - reduction)

	# Determination: Each selection reduces current drain by 12% (multiplicative)
	if "determination" in selected_techniques:
		var qualities = selected_techniques["determination"]["qualities"]
		for quality in qualities:
			var quality_mult = get_quality_multiplier(quality)
			var reduction = 0.12 * quality_mult  # 12% base, 13-19% with quality
			mult *= (1.0 - reduction)

	# Power Surge: Heavy stacks apply additive reduction (total from all selections x stack count)
	if "power_surge" in selected_techniques and heavy_combo_unlocked and heavy_combo_timer > 0.0:
		var surge_total = get_technique_total_bonus("power_surge")  # Sum all selections
		var heavy_reduction = surge_total * heavy_combo_stacks  # 5% per stack per selection
		mult *= max(0.0, 1.0 - heavy_reduction)  # Apply as single multiplier

	return mult  # No floor cap - coal drain can be heavily reduced with investment

# Returns XP multiplier based on combo states
# Affected by: Repetition Learning, Pressure Training
func get_xp_multiplier() -> float:
	var mult = 1.0

	# Repetition Learning: +10% XP per streak per selection
	if "repetition_learning" in selected_techniques and clean_streak_unlocked:
		var learning_bonus = get_technique_total_bonus("repetition_learning")
		mult += learning_bonus * clean_streak_count

	# Pressure Training: +20% XP per heavy stack per selection
	if "pressure_training" in selected_techniques and heavy_combo_unlocked:
		var pressure_bonus = get_technique_total_bonus("pressure_training")
		mult += pressure_bonus * heavy_combo_stacks

	return mult

# Returns shovel mass multiplier
# Affected by: Firm Grip, Mass Training
func get_shovel_mass_multiplier() -> float:
	var mult = 1.0

	# Firm Grip: Each selection increases current mass by 15% (multiplicative)
	if "firm_grip" in selected_techniques:
		var qualities = selected_techniques["firm_grip"]["qualities"]
		for quality in qualities:
			var quality_mult = get_quality_multiplier(quality)
			var increase = 0.15 * quality_mult  # 15% base, 17-24% with quality
			mult *= (1.0 + increase)

	# Mass Training: +2% per streak per selection
	if "mass_training" in selected_techniques and clean_streak_unlocked:
		var mass_bonus = get_technique_total_bonus("mass_training")
		mult += mass_bonus * clean_streak_count

	return mult

# Returns maximum clean streak count (base 20 + Streak Ceiling bonuses)
func get_clean_streak_max() -> int:
	var base_max = 20
	if "streak_ceiling" not in selected_techniques:
		return base_max

	var bonus = get_technique_total_bonus("streak_ceiling")
	return base_max + int(bonus)

# Returns coal threshold for earning 1 forgiveness charge
# First selection sets base threshold (20/18/16/14/12 based on quality)
# Subsequent C/U/R selections reduce threshold (-2/-3/-4)
# Epic/Legendary selections don't affect threshold (they add capacity instead)
func get_forgiveness_threshold() -> int:
	if "forgiveness" not in selected_techniques:
		return 0

	var qualities = selected_techniques["forgiveness"]["qualities"]
	if qualities.size() == 0:
		return 0

	# First selection sets base threshold
	var first_quality = qualities[0]
	var threshold = 20  # Base
	match first_quality:
		"common": threshold = 20
		"uncommon": threshold = 18
		"rare": threshold = 16
		"epic": threshold = 14
		"legendary": threshold = 12

	# Subsequent C/U/R selections reduce threshold
	for i in range(1, qualities.size()):
		var quality = qualities[i]
		match quality:
			"common": threshold -= 2
			"uncommon": threshold -= 3
			"rare": threshold -= 4
			# Epic and legendary don't reduce threshold

	return max(1, threshold)  # Never go below 1

# Returns maximum forgiveness charges that can be banked
# First selection grants 1 capacity
# Subsequent Epic selections grant +1, Legendary grant +2
func get_forgiveness_max_capacity() -> int:
	if "forgiveness" not in selected_techniques:
		return 0

	var qualities = selected_techniques["forgiveness"]["qualities"]
	if qualities.size() == 0:
		return 0

	# First selection always grants 1 capacity
	var capacity = 1

	# Subsequent Epic/Legendary selections add capacity
	for i in range(1, qualities.size()):
		var quality = qualities[i]
		match quality:
			"epic": capacity += 1
			"legendary": capacity += 2
			# Common, uncommon, rare don't add capacity

	return capacity

# Returns heavy load timer extension in seconds
func get_heavy_timer_extension() -> float:
	if "extended_window" not in selected_techniques:
		return 0.0

	return get_technique_total_bonus("extended_window")

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
		# Player progression
		"player_level": player_level,
		"player_exp": player_exp,
		# Currency (4-tier system)
		"currency": currency,
		"lifetime_currency": lifetime_currency,
		# Combo state (persists during same-day saves, resets on new day)
		# NOTE: Techniques are NOT saved - they reset each run (per-run progression)
		"show_exact_technique_values": show_exact_technique_values,
		"clean_streak_count": clean_streak_count,
		"clean_streak_max": clean_streak_max,
		"forgiveness_charges": forgiveness_charges,
		"forgiveness_coal_counter": forgiveness_coal_counter,
		"forgiveness_threshold": forgiveness_threshold,
		"forgiveness_max_capacity": forgiveness_max_capacity,
		"heavy_combo_stacks": heavy_combo_stacks,
		"heavy_combo_timer": heavy_combo_timer,
		"recent_delivery_timestamps": recent_delivery_timestamps.duplicate(),
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

	# Player progression
	player_level = data.get("player_level", 1)
	player_exp = data.get("player_exp", 0.0)

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

	# Combo state (persists during same-day saves, resets on new day)
	# NOTE: Techniques NOT loaded - reset each run (per-run design)
	show_exact_technique_values = data.get("show_exact_technique_values", true)
	clean_streak_count = data.get("clean_streak_count", 0)
	clean_streak_max = data.get("clean_streak_max", 20)
	forgiveness_charges = data.get("forgiveness_charges", 0)
	forgiveness_coal_counter = data.get("forgiveness_coal_counter", 0)
	forgiveness_threshold = data.get("forgiveness_threshold", 0)
	forgiveness_max_capacity = data.get("forgiveness_max_capacity", 0)
	heavy_combo_stacks = data.get("heavy_combo_stacks", 0)
	heavy_combo_timer = data.get("heavy_combo_timer", 0.0)
	recent_delivery_timestamps = data.get("recent_delivery_timestamps", [])

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

	# Player progression (reset for new run - run-specific)
	player_level = 1
	player_exp = 0.0

	# Currency
	reset_all_currency()

	# Technique system (reset for new run)
	reset_techniques()

	# Emit signals
	emit_signal("stamina_changed", stamina, stamina_max)
	emit_signal("focus_changed", focus, focus_max)
