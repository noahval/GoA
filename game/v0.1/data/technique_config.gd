extends Node

# Technique Configuration
# Central location for all technique-related tuning values

# ============================================================================
# BASE RARITY (Appearance Rate in Level-Up Pools)
# ============================================================================
# Controls how often techniques appear when leveling up
# Visual: Border color on technique card

const BASE_RARITY_WEIGHTS = {
	"common": 50.0,
	"uncommon": 0.0,      # Not used for base rarity
	"rare": 35.0,
	"epic": 12.0,
	"legendary": 3.0
}

# ============================================================================
# DRAW QUALITY (Power Per Level)
# ============================================================================
# Controls how strong each individual pick is
# Visual: Color of the effect number on card

# Base weights (intelligence level 0)
const BASE_DRAW_QUALITY_WEIGHTS = {
	"common": 60.0,       # Grey number
	"uncommon": 25.0,     # Green number
	"rare": 12.0,         # Blue number
	"epic": 2.5,          # Pink number
	"legendary": 0.5      # Yellow number
}

# Intelligence scaling per level
# Each intelligence level shifts probability toward higher rarities
const INTELLIGENCE_DRAW_BONUS = {
	"common": -2.0,       # -2% per intelligence level
	"uncommon": 1.0,      # +1% per intelligence level
	"rare": 0.6,          # +0.6% per intelligence level
	"epic": 0.3,          # +0.3% per intelligence level
	"legendary": 0.1      # +0.1% per intelligence level
}

# Effect multipliers per draw quality
const DRAW_QUALITY_MULTIPLIERS = {
	"common": 0.20,       # +20% per level
	"uncommon": 0.22,     # +22% per level
	"rare": 0.24,         # +24% per level
	"epic": 0.26,         # +26% per level
	"legendary": 0.28     # +28% per level
}

# ============================================================================
# COLOR DEFINITIONS
# ============================================================================

const RARITY_COLORS = {
	"common": Color(0.6, 0.6, 0.6),        # Grey
	"uncommon": Color(0.3, 0.8, 0.3),      # Green
	"rare": Color(0.3, 0.5, 1.0),          # Blue
	"epic": Color(1.0, 0.4, 0.8),          # Pink
	"legendary": Color(1.0, 0.9, 0.2)      # Yellow
}

# ============================================================================
# TECHNIQUE LIMITS
# ============================================================================

const MAX_TECHNIQUE_LEVEL = 5

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Calculate draw quality weights adjusted for intelligence level
static func get_adjusted_draw_weights(intelligence_level: int) -> Dictionary:
	var adjusted = {}

	for quality in BASE_DRAW_QUALITY_WEIGHTS.keys():
		var base_weight = BASE_DRAW_QUALITY_WEIGHTS[quality]
		var bonus = INTELLIGENCE_DRAW_BONUS[quality] * intelligence_level
		adjusted[quality] = max(0.0, base_weight + bonus)

	return adjusted

# Get total effect multiplier for a technique given its draw quality history
static func calculate_total_multiplier(qualities: Array) -> float:
	var total_bonus = 0.0

	for quality in qualities:
		if quality in DRAW_QUALITY_MULTIPLIERS:
			total_bonus += DRAW_QUALITY_MULTIPLIERS[quality]

	return 1.0 + total_bonus

# Example intelligence scaling at different levels:
# Intelligence 0:  Common 60%, Uncommon 25%, Rare 12%, Epic 2.5%, Legendary 0.5%
# Intelligence 5:  Common 50%, Uncommon 30%, Rare 15%, Epic 4.0%, Legendary 1.0%
# Intelligence 10: Common 40%, Uncommon 35%, Rare 18%, Epic 5.5%, Legendary 1.5%
# Intelligence 20: Common 20%, Uncommon 45%, Rare 24%, Epic 8.5%, Legendary 2.5%
