extends Node
## OfflineEarningsManager
## Singleton autoload for managing offline earnings through the Overtime system
## Calculates earnings from auto-shovels while player is offline, capped by overtime limit

## Overtime upgrade costs (levels 0→1 through 7→8)
const OVERTIME_COSTS = [300, 390, 507, 659, 1000, 1500, 2250, 3375]

## Overtime hour caps (levels 1-8, level 0 is base 8h)
const OVERTIME_HOURS = [12, 16, 20, 24, 26, 28, 30, 36]

## Offline efficiency penalty (auto-shovels work at 50% while unmanned)
const OFFLINE_EFFICIENCY = 0.5

## Upgrade name and descriptions for each level
const OVERTIME_UPGRADES = [
	{"name": "Standard Overtime", "desc": "The overseer allows a few extra hours"},
	{"name": "Extended Shift", "desc": "Working late into the night"},
	{"name": "Double Shift", "desc": "Pushing the limits of endurance"},
	{"name": "Round-the-Clock", "desc": "A full day without rest"},
	{"name": "Marathon Shift", "desc": "Beyond what's reasonable"},
	{"name": "Sleep Deprivation", "desc": "The overseer grows concerned"},
	{"name": "Inhumane Hours", "desc": "Even he thinks this is too much"},
	{"name": "Breaking Point", "desc": "The absolute maximum before collapse"}
]

## Get the coin cost for next overtime upgrade
## Returns -1 if already at max level (8)
func get_overtime_cost(current_level: int) -> int:
	if current_level >= OVERTIME_COSTS.size():
		return -1  # Max level reached
	return OVERTIME_COSTS[current_level]

## Get the hour cap for a given overtime level
## Level 0 = 8 hours (base)
## Level 1-8 = values from OVERTIME_HOURS array
func get_cap_hours_for_level(level: int) -> float:
	if level == 0:
		return 8.0
	if level > OVERTIME_HOURS.size():
		return OVERTIME_HOURS[-1]  # Return max if somehow exceeded
	return OVERTIME_HOURS[level - 1]

## Calculate offline earnings based on elapsed time and offline cap
## Returns the amount of coal earned (integer)
func calculate_offline_earnings(elapsed_seconds: int, cap_seconds: int, auto_shovel_lvl: int, coal_per_tick: float, shovel_freq: float) -> int:
	# No earnings if no auto-shovels
	if auto_shovel_lvl == 0:
		return 0

	# Cap the elapsed time
	var capped_seconds = min(elapsed_seconds, cap_seconds)

	# Calculate ticks that would have occurred
	var ticks = capped_seconds / shovel_freq

	# Calculate coal: auto_shovel_lvl * coal_per_tick * ticks * efficiency
	var coal = auto_shovel_lvl * coal_per_tick * ticks * OFFLINE_EFFICIENCY

	return int(coal)  # Round down to integer

## Get a summary message for offline earnings
## Shows time elapsed, time capped, coal earned, and warning if missed hours
func get_offline_summary(elapsed_seconds: int, cap_seconds: int, coal_earned: int) -> String:
	var elapsed_hours = elapsed_seconds / 3600.0
	var cap_hours = cap_seconds / 3600.0
	var missed_hours = max(0, elapsed_hours - cap_hours)

	var message = "You were away for %.1f hours" % elapsed_hours
	message += " (capped at %.0f hours).\n" % cap_hours
	message += "Your auto-shovels earned %d coal." % coal_earned

	if missed_hours > 0.1:
		message += "\n\nYou missed %.1f hours of potential earnings." % missed_hours
		message += " Upgrade your overtime in the Overseer's Office."

	return message

## Get upgrade info for display (name and description)
func get_upgrade_info(level: int) -> Dictionary:
	if level < 1 or level > OVERTIME_UPGRADES.size():
		return {"name": "Unknown", "desc": ""}
	return OVERTIME_UPGRADES[level - 1]

## DEBUG: Simulate offline time for testing (only in dev mode)
## Call this from console or debug script to test offline earnings without waiting
func debug_simulate_offline_time(hours: float):
	if not Global.dev_speed_mode:
		print("DEBUG: dev_speed_mode must be enabled to simulate offline time")
		return

	var simulated_seconds = int(hours * 3600)
	Level1Vars.last_played_timestamp -= simulated_seconds

	print("DEBUG: Simulated %.1f hours offline" % hours)
	print("DEBUG: Restart the game to see offline earnings notification")
