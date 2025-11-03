# OverseerMood - Phase 1: Mood & Conversion System
# Manages the overseer's mood and coal-to-coin conversion mechanics
# Design: Mysterious gameplay - players discover optimal timing through experimentation

extends Node

# Mood State (hidden multiplier, player sees adjectives)
var mood_value = 0.5  # Range 0.0 to 1.0 (maps to multiplier range)
var mood_trend = 0  # -1 (declining), 0 (stable), 1 (improving)
var last_conversion_time = 0.0
var time_since_last_conversion = 0.0

# Mood drift (creates uncertainty)
var mood_drift_timer = 0.0
var mood_drift_interval = 15.0  # Mood changes every 15 seconds

# Mood fatigue (punishes spam-converting)
var fatigue_level = 0.0  # 0.0 to 1.0, reduces mood
var fatigue_decay_rate = 0.1  # Per second

# Conversion mode
var auto_conversion_enabled = false

# Multiplier configuration (hidden from player)
var min_multiplier = 0.5
var max_multiplier = 2.0
var auto_efficiency = 0.7  # 70% efficiency in auto mode

# Coal requirement for conversion (inverse relationship with mood)
var base_coal_per_coin = 40.0  # Base coal needed for 1 coin at neutral mood
var total_conversions = 0  # Track total number of conversions
var price_increase_per_conversion = 1.0  # Coal price increases by this amount per conversion

func _ready():
	# Initialize mood to neutral-pleasant range
	mood_value = randf_range(0.4, 0.6)
	last_conversion_time = Time.get_ticks_msec() / 1000.0

func _process(delta):
	time_since_last_conversion += delta

	# Mood drift (random changes over time)
	mood_drift_timer += delta
	if mood_drift_timer >= mood_drift_interval:
		mood_drift_timer = 0.0
		apply_mood_drift()

	# Fatigue decay
	if fatigue_level > 0:
		fatigue_level -= fatigue_decay_rate * delta
		fatigue_level = max(0.0, fatigue_level)

# Apply random mood drift
func apply_mood_drift():
	var drift_amount = randf_range(-0.15, 0.15)
	var old_mood = mood_value
	mood_value += drift_amount
	mood_value = clamp(mood_value, 0.0, 1.0)

	# Update trend based on change
	if mood_value > old_mood + 0.02:
		mood_trend = 1  # Improving
	elif mood_value < old_mood - 0.02:
		mood_trend = -1  # Declining
	else:
		mood_trend = 0  # Stable

# Get current mood multiplier (hidden from player)
func get_mood_multiplier() -> float:
	# Apply fatigue penalty
	var effective_mood = mood_value - (fatigue_level * 0.3)
	effective_mood = clamp(effective_mood, 0.0, 1.0)

	# Map 0.0-1.0 to min_multiplier-max_multiplier
	return min_multiplier + (effective_mood * (max_multiplier - min_multiplier))

# Get coal requirement for 1 coin (inverse of mood multiplier)
func get_coal_per_coin() -> float:
	var multiplier = get_mood_multiplier()
	# Calculate increasing base price based on total conversions
	var current_base_price = base_coal_per_coin + (total_conversions * price_increase_per_conversion)
	# Inverse relationship: better mood = less coal needed
	return current_base_price / multiplier

# Get mood as adjective (what player sees)
func get_mood_adjective() -> String:
	var effective_mood = mood_value - (fatigue_level * 0.3)

	if effective_mood < 0.2:
		return "furious"
	elif effective_mood < 0.35:
		return "irritated"
	elif effective_mood < 0.55:
		return "indifferent"
	elif effective_mood < 0.70:
		return "pleased"
	elif effective_mood < 0.85:
		return "delighted"
	else:
		return "ecstatic"

# Get trend arrow (what player sees)
func get_trend_arrow() -> String:
	if mood_trend > 0:
		return "↗"
	elif mood_trend < 0:
		return "↘"
	else:
		return "→"

# Manual conversion - player chooses when to convert
# Returns number of coins earned (always 1 in manual mode)
func manual_convert_coal(coal_amount: float) -> float:
	# Apply mood fatigue (punish frequent conversions)
	var time_delta = time_since_last_conversion
	if time_delta < 10.0:  # Converted within 10 seconds
		fatigue_level += 0.15
		fatigue_level = min(1.0, fatigue_level)
	elif time_delta < 30.0:  # Converted within 30 seconds
		fatigue_level += 0.05
		fatigue_level = min(1.0, fatigue_level)

	time_since_last_conversion = 0.0
	total_conversions += 1  # Increment conversion counter to increase price
	return 1.0  # Always returns 1 coin in manual mode

# Auto conversion - happens automatically with penalty
# Returns number of coins earned (reduced by auto efficiency)
func auto_convert_coal(coal_amount: float) -> float:
	# Less mood fatigue in auto mode (slower accumulation)
	fatigue_level += 0.02
	fatigue_level = min(1.0, fatigue_level)

	total_conversions += 1  # Increment conversion counter to increase price

	return 1.0 * auto_efficiency  # Returns 0.7 coins in auto mode

# Get conversion feedback message (qualitative)
func get_conversion_message() -> String:
	var adjective = get_mood_adjective()
	var coal_needed = int(get_coal_per_coin())

	match adjective:
		"ecstatic":
			return "The overseer was ecstatic! He only demanded " + str(coal_needed) + " coal for 1 coin."
		"delighted":
			return "The overseer was delighted! He accepted " + str(coal_needed) + " coal for 1 coin."
		"pleased":
			return "The overseer was pleased. He took " + str(coal_needed) + " coal for 1 coin."
		"indifferent":
			return "The overseer accepted " + str(coal_needed) + " coal for 1 coin without comment."
		"irritated":
			return "The overseer was irritated. He demanded " + str(coal_needed) + " coal for 1 coin."
		"furious":
			return "The overseer was furious! He took " + str(coal_needed) + " coal for just 1 coin!"
		_:
			return "You converted coal to coins."
