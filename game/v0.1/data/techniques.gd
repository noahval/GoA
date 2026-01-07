# Technique pool definitions for upgrade system
# Referenced by Mind scene and effect application
# Using class_name for global access (no need to preload)
class_name TechniquesData

const TECHNIQUES = {
	# ========================================================================
	# CORE STAT TECHNIQUES
	# ========================================================================

	"rhythm": {
		"name": "Rhythm",
		"rarity": "common",
		"cost": 10,
		"max_level": 5,
		"tier": 1,
		"description": "Base stamina drain\n\nReduces stamina drain from holding the shovel. Your grip becomes more efficient with each selection.",
		"effect": {"base_bonus": 0.20},  # -20% drain per selection (multiplicative)
		"category": "core"
	},
	"determination": {
		"name": "Determination",
		"rarity": "rare",
		"cost": 16,
		"max_level": 5,
		"tier": 2,
		"description": "All stamina drain\n\nPure willpower keeps you going. All sources of stamina drain are reduced - both from the weight of the shovel and the burden of carrying coal. The overseer may push, but you endure.",
		"effect": {"base_bonus": 0.12},  # -12% all drain per selection (multiplicative)
		"category": "core"
	},
	"economy_of_motion": {
		"name": "Economy of Motion",
		"rarity": "uncommon",
		"cost": 20,
		"max_level": 5,
		"tier": 1,
		"description": "Coal carry stamina drain\n\nReduces stamina drain while carrying coal. You learn to move more efficiently under the burden, conserving energy with each delivery.",
		"effect": {"base_bonus": 0.15},  # -15% coal carrying drain per selection (multiplicative)
		"category": "core"
	},

	# ========================================================================
	# CLEAN STREAK TECHNIQUES
	# ========================================================================
	# Selecting any of these unlocks the clean streak mechanic
	# Streak increases by 1 for each coal delivered without dropping
	# Streak resets to 0 when coal is dropped (unless Forgiveness prevents it)

	"cadence": {
		"name": "Cadence",
		"rarity": "uncommon",
		"cost": 15,
		"max_level": 5,
		"tier": 2,
		"description": "Stamina drain per streak\n\nThe overseer notices consistent workers. Each delivery extends your clean streak, and longer streaks mean less stamina lost to stress. Dropping coal resets the count.",
		"effect": {"base_bonus": 0.03},  # -3% per streak per selection (additive across stacks)
		"category": "clean_streak",
		"unlocks_combo": true
	},
	"repetition_learning": {
		"name": "Repetition Learning",
		"rarity": "rare",
		"cost": 18,
		"max_level": 5,
		"tier": 3,
		"description": "XP gain per streak\n\nAvoid mistakes and you learn faster. Each delivery in your clean streak multiplies XP earned - the overseer's watchful eye keeps you focused. One drop and you're back to square one.",
		"effect": {"base_bonus": 0.10},  # +10% XP per streak per selection
		"category": "clean_streak",
		"unlocks_combo": true
	},
	"perfect_form": {
		"name": "Perfect Form",
		"rarity": "legendary",
		"cost": 50,
		"max_level": 1,
		"tier": 4,
		"description": "Stamina drain at 10+ streak\n\nFlawless work goes unnoticed. Maintain a clean streak of 10 or more and the overseer stops watching so closely - stamina drain drops dramatically until you slip up.",
		"effect": {"type": "boolean", "threshold": 10, "reduction": 0.50},
		"category": "clean_streak",
		"unlocks_combo": true
	},
	"forgiveness": {
		"name": "Forgiveness",
		"rarity": "epic",
		"cost": 30,
		"max_level": 5,
		"tier": 4,
		"description": "Earn forgiveness charges\n\nSometimes a dropped coal goes unnoticed. Earn forgiveness charges through consistent deliveries, then spend them when you slip - the overseer looks away and your clean streak survives.",
		"effect": {"base_bonus": 1.0},  # First: sets threshold, Later: C/U/R reduce threshold, E/L add capacity
		"category": "clean_streak",
		"unlocks_combo": true
	},
	"streak_ceiling": {
		"name": "Streak Ceiling",
		"rarity": "uncommon",
		"cost": 20,
		"max_level": 5,
		"tier": 2,
		"description": "Max streak\n\nThe overseer tracks longer counts. Raises the maximum clean streak that matters, letting streak-based benefits scale even higher.",
		"effect": {"base_bonus": 10},  # +10 to max streak per selection
		"category": "clean_streak",
		"unlocks_combo": true
	},

	# ========================================================================
	# HEAVY LOAD COMBO TECHNIQUES
	# ========================================================================
	# Selecting any of these unlocks the heavy load combo mechanic
	# Heavy load = successfully dumping 3+ coal from shovel (all deliveries within 1 second)
	# Each successful heavy delivery increments stacks and refreshes the 5-second decay timer
	# Timer expiration or dropping coal resets stacks to 0
	# Rewards risky play of carrying multiple coal pieces without spilling

	"power_surge": {
		"name": "Power Surge",
		"rarity": "rare",
		"cost": 18,
		"max_level": 5,
		"tier": 3,
		"description": "Stamina drain per heavy stack\n\nMomentum from heavy loads carries you forward. Successfully delivering 3+ coal at once builds power - each heavy delivery in quick succession reduces your stamina drain. Stop delivering and the surge fades.",
		"effect": {"base_bonus": 0.05},  # -5% stamina per heavy stack per selection (additive across stacks)
		"category": "heavy_combo",
		"unlocks_combo": true
	},
	"pressure_training": {
		"name": "Pressure Training",
		"rarity": "rare",
		"cost": 20,
		"max_level": 5,
		"tier": 3,
		"description": "XP gain per heavy stack\n\nThe overseer values efficiency above all. Deliver heavy loads in quick succession and each one teaches you more - XP multiplies with every consecutive heavy delivery. Slow down and the bonus resets.",
		"effect": {"base_bonus": 0.20},  # +20% XP per heavy stack per selection
		"category": "heavy_combo",
		"unlocks_combo": true
	},
	"extended_window": {
		"name": "Extended Window",
		"rarity": "uncommon",
		"cost": 22,
		"max_level": 5,
		"tier": 3,
		"description": "Heavy timer\n\nYou learn to maintain your rhythm longer. The window between heavy deliveries extends, giving you more time to keep your momentum going before the bonus fades.",
		"effect": {"base_bonus": 1.0},  # +1.0s to timer per selection
		"category": "heavy_combo",
		"unlocks_combo": true
	},

	# ========================================================================
	# SHOVEL STABILITY TECHNIQUES
	# ========================================================================

	"firm_grip": {
		"name": "Firm Grip",
		"rarity": "common",
		"cost": 12,
		"max_level": 5,
		"tier": 1,
		"description": "Shovel stability\n\nA steadier hold on the shovel. Coal shifting on the blade has less impact on your balance, giving you more control when carrying heavy loads.",
		"effect": {"base_bonus": 0.15},  # +15% stability per selection (multiplicative)
		"category": "mass"
	},
	"mass_training": {
		"name": "Mass Training",
		"rarity": "epic",
		"cost": 35,
		"max_level": 5,
		"tier": 4,
		"description": "Shovel stability per streak\n\nFear sharpens your grip. As your clean streak builds and the pressure mounts, you hold the shovel tighter - more control, less wobble. Breaking your streak relaxes your grip.",
		"effect": {"base_bonus": 0.02},  # +2% stability per streak per selection
		"category": "mass",
		"requires": "clean_streak"  # Must have unlocked clean streak system
	},
}
