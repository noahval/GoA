class_name CloudSaveValidator
extends RefCounted

## Validate loaded save data - clamp values to valid ranges
## No local backups - trust Nakama infrastructure
## This handles data corruption by resetting invalid values to safe defaults

# Validate loaded save data - clamp to valid ranges
static func validate_loaded_data(data: Dictionary) -> Dictionary:
	var validated = data.duplicate(true)

	# Validate Global stats (>= 1.0)
	if validated.has("global"):
		var g = validated.global
		g.strength = max(g.get("strength", 1.0), 1.0)
		g.constitution = max(g.get("constitution", 1.0), 1.0)
		g.dexterity = max(g.get("dexterity", 1.0), 1.0)
		g.wisdom = max(g.get("wisdom", 1.0), 1.0)
		g.intelligence = max(g.get("intelligence", 1.0), 1.0)
		g.charisma = max(g.get("charisma", 1.0), 1.0)

		# Validate experience (>= 0)
		g.strength_exp = max(g.get("strength_exp", 0.0), 0.0)
		g.constitution_exp = max(g.get("constitution_exp", 0.0), 0.0)
		g.dexterity_exp = max(g.get("dexterity_exp", 0.0), 0.0)
		g.wisdom_exp = max(g.get("wisdom_exp", 0.0), 0.0)
		g.intelligence_exp = max(g.get("intelligence_exp", 0.0), 0.0)
		g.charisma_exp = max(g.get("charisma_exp", 0.0), 0.0)

		# Validate reputation (>= 0)
		g.reputation_points = max(g.get("reputation_points", 0), 0)
		g.lifetime_reputation_earned = max(g.get("lifetime_reputation_earned", 0), 0)

	# Validate Level1Vars currency (>= 0)
	if validated.has("level1_vars") and validated.level1_vars.has("currency"):
		var c = validated.level1_vars.currency
		c.copper = max(c.get("copper", 0.0), 0.0)
		c.silver = max(c.get("silver", 0.0), 0.0)
		c.gold = max(c.get("gold", 0.0), 0.0)
		c.platinum = max(c.get("platinum", 0.0), 0.0)

	# Validate Level1Vars resources (>= 0)
	if validated.has("level1_vars"):
		var lv = validated.level1_vars
		lv.coal = max(lv.get("coal", 0.0), 0.0)
		lv.shovel_lvl = max(lv.get("shovel_lvl", 0), 0)
		lv.plow_lvl = max(lv.get("plow_lvl", 0), 0)
		lv.auto_shovel_lvl = max(lv.get("auto_shovel_lvl", 0), 0)

	return validated

# Check if save data structure is valid
static func is_valid_save_structure(data: Dictionary) -> bool:
	if not data.has("global"):
		return false
	if not data.has("level1_vars"):
		return false
	return true
