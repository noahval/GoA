extends Node
var coal = 0.0

# Multi-currency system (Copper -> Silver -> Gold -> Platinum)
var currency = {
	"copper": 0.0,
	"silver": 0.0,
	"gold": 0.0,
	"platinum": 0.0
}

# Lifetime earnings per currency type (never decreases, tracks total earned)
var lifetime_currency = {
	"copper": 0.0,
	"silver": 0.0,
	"gold": 0.0,
	"platinum": 0.0
}

# Currency tier unlocks (ATM exchange feature)
var unlocked_gold: bool:
	get:
		return true if Global.dev_speed_mode else _unlocked_gold
	set(value):
		_unlocked_gold = value
var _unlocked_gold: bool = false  # Unlocks at 60 silver

var unlocked_platinum: bool:
	get:
		return true if Global.dev_speed_mode else _unlocked_platinum
	set(value):
		_unlocked_platinum = value
var _unlocked_platinum: bool = false  # Unlocks at 50 gold

# Storage capacity system (unified for all currencies)
var storage_capacity_level: int = 0
var storage_capacity_caps: Array[int] = [200, 300, 450, 650, 900, 1250, 1750, 2500, 3500, 5000, 7000, 8500, 10000]

# Coal record-keeping system
var coal_tracking_level: int = 0
var coal_tracking_caps: Array[int] = [1000, 2000, 4000, 7000, 12000, 20000, 35000]

# ATM deposit system (stored currency beyond pocket capacity)
var atm_deposits = {
	"copper": 0.0,
	"silver": 0.0,
	"gold": 0.0,
	"platinum": 0.0
}

# Phase progression system
var current_phase: int = 1  # 1, 2, or 3
var phase_2_unlocked: bool = false
var phase_3_unlocked: bool = false
var leadership_exam_passed: bool = false
var leadership_exam_attempts: int = 0
var leadership_exam_cooldown_until: int = 0  # timestamp

# Legacy variable for backward compatibility - syncs with currency.copper
var coins = 0.0:
	set(value):
		coins = value
		currency.copper = value
	get:
		return currency.copper
var shovel_lvl = 0
var plow_lvl = 0
var auto_shovel_lvl = 0  # Quantity of auto-shovels owned
var auto_shovel_freq = 3.0  # How often auto shovel generates coal (in seconds)
var auto_shovel_coal_per_tick = 4.0  # How much coal each auto shovel generates per tick
var auto_shovel_coal_upgrade_lvl = 0  # Upgrade level for coal per tick
var auto_shovel_freq_upgrade_lvl = 0  # Upgrade level for frequency
var overseer_lvl = 0
var barkeep_bribed = false
var shopkeep_bribed = false
var break_time_remaining = 0.0
var starting_break_time:
	get:
		return 120 if Global.dev_speed_mode else 30
var coin_cost = 30.0
var components = 0
var mechanisms = 0
var pipes = 5
var stamina = 125.0
var max_stamina:
	get:
		return 125.0 + (20 * Global.constitution)
var pipe_puzzle_grid = []  # Saved grid state for the pipe puzzle
var heart_taken = false
var whisper_triggered = false
var door_discovered = false
var stolen_coal = 0
var stolen_writs = 0
var correct_answers = 0
var suspicion = 0:
	set(value):
		suspicion = clamp(value, 0, 100)
var talk_button_cooldown = 0.0
var stimulated_remaining = 0.0:
	set(value):
		stimulated_remaining = clamp(value, 0, 300)
var shown_tired_notification = false
var resilient_remaining = 0.0:
	set(value):
		resilient_remaining = clamp(value, 0, 300)
var shown_lazy_notification = false

# Phase 1: Overseer Mood & Conversion System
var auto_conversion_enabled = false  # Manual by default
var coal_conversion_threshold = 30.0  # Amount of coal needed for manual conversion
var overseer_bribe_count = 0  # Track number of times overseer has been bribed
var mood_system_unlocked = false  # Unlocked after 4 bribes
var lifetimecoins = 0.0  # Track total coins earned (never decreases)
var equipment_value = 0  # Total coin-equivalent value spent on equipment upgrades
var coinslot_machine_unlocked = false  # Track if the coin slot machine has been revealed
var dorm_unlocked = false  # Track if dorm has been unlocked (equipment_value >= 3000)

# Phase 2: Offline Earnings - Overtime System
var overtime_lvl: int = 0  # Current overtime upgrade level (0-8)
var offline_cap_hours: float = 8.0  # Current offline earning cap in hours
var last_played_timestamp: int = 0  # Unix timestamp of last save/load

# Reset function for prestige system
func reset_for_prestige():
	# RESET: Clear progress and resources
	coal = 0.0
	coins = 0.0  # This also resets currency.copper via setter
	currency.copper = 0.0
	currency.silver = 0.0
	currency.gold = 0.0
	# Platinum bonds persist through prestige (special currency feature)
	# currency.platinum is NOT reset
	shovel_lvl = 0
	plow_lvl = 0
	auto_shovel_lvl = 0
	auto_shovel_coal_per_tick = 4.0
	auto_shovel_freq = 3.0
	auto_shovel_coal_upgrade_lvl = 0
	auto_shovel_freq_upgrade_lvl = 0
	equipment_value = 0
	components = 0
	mechanisms = 0
	stolen_coal = 0
	stolen_writs = 0
	suspicion = 0
	correct_answers = 0
	barkeep_bribed = false
	shopkeep_bribed = false
	overseer_lvl = 0
	break_time_remaining = 0.0
	stamina = 125.0
	stimulated_remaining = 0.0
	resilient_remaining = 0.0
	shown_tired_notification = false
	shown_lazy_notification = false
	heart_taken = false
	whisper_triggered = false
	door_discovered = false
	mood_system_unlocked = false
	coinslot_machine_unlocked = false
	dorm_unlocked = false

	# KEEP (DO NOT RESET): Quality of life features that persist
	# - overseer_bribe_count (keeps progress on mood system unlock)
	# - auto_conversion_enabled (QoL feature)
	# - lifetimecoins (stat tracking - legacy)
	# - lifetime_currency (all lifetime earnings persist)
	# - currency.platinum (Platinum Bonds persist through prestige!)
	# - pipe_puzzle_grid (puzzle state can persist)
	# - overtime_lvl (persistent upgrade)
	# - offline_cap_hours (based on overtime_lvl)
	# - last_played_timestamp (for offline earnings calculation)
	# - storage_capacity_level (persistent upgrade)
	# - coal_tracking_level (persistent upgrade)
	# - atm_deposits (banked currency persists)
	# - phase unlocks and progression (persistent progress)

	# Apply starting resource upgrades based on reputation upgrades
	# Placeholder: When upgrades are finalized, add checks here
	# Example:
	# if Global.has_reputation_upgrade("starting_coins_upgrade"):
	#     coins = 50

## Complete reset of all variables (for save deletion/reset)
func reset_all():
	# Start with prestige reset (handles most variables)
	reset_for_prestige()

	# Also reset the persistent items that survive prestige
	currency.platinum = 0.0
	lifetimecoins = 0.0
	lifetime_currency = {"copper": 0.0, "silver": 0.0, "gold": 0.0, "platinum": 0.0}
	overseer_bribe_count = 0
	auto_conversion_enabled = false
	overtime_lvl = 0
	offline_cap_hours = 8.0
	last_played_timestamp = 0
	pipe_puzzle_grid = []
	storage_capacity_level = 0
	coal_tracking_level = 0
	atm_deposits = {"copper": 0.0, "silver": 0.0, "gold": 0.0, "platinum": 0.0}
	current_phase = 1
	phase_2_unlocked = false
	phase_3_unlocked = false
	leadership_exam_passed = false
	leadership_exam_attempts = 0
	leadership_exam_cooldown_until = 0

## Helper function: Get offline cap in seconds
func get_offline_cap_seconds() -> int:
	return int(offline_cap_hours * 3600)


## Helper function: Get current currency storage cap
func get_currency_cap() -> int:
	if storage_capacity_level >= storage_capacity_caps.size():
		return storage_capacity_caps[storage_capacity_caps.size() - 1]
	return storage_capacity_caps[storage_capacity_level]


## Helper function: Get current coal tracking cap
func get_coal_cap() -> int:
	if coal_tracking_level >= coal_tracking_caps.size():
		return coal_tracking_caps[coal_tracking_caps.size() - 1]
	return coal_tracking_caps[coal_tracking_level]


## Helper function: Check if currency would overflow cap
func would_exceed_currency_cap(currency_type: String, amount: float) -> bool:
	var cap = get_currency_cap()
	return currency[currency_type] + amount > cap


## Helper function: Check if coal would overflow cap
func would_exceed_coal_cap(amount: float) -> bool:
	var cap = get_coal_cap()
	return coal + amount > cap


## Helper function: Get combined stats level (for phase gates)
func get_combined_stats_level() -> int:
	return Global.strength + Global.dexterity + Global.constitution + Global.intelligence + Global.wisdom + Global.charisma


## Check and unlock currency tiers based on current holdings
## Gold unlocks at 50 silver, Platinum unlocks at 50 gold
func check_currency_unlocks() -> void:
	# Gold unlocks at 50 silver
	if not _unlocked_gold and currency.silver >= 50:
		_unlocked_gold = true
		# Synchronize with CurrencyManager unlock system
		CurrencyManager.unlocked_currencies[CurrencyManager.CurrencyType.GOLD] = true
		Global.show_stat_notification("Trading in gold now permitted")

	# Platinum unlocks at 50 gold
	if not _unlocked_platinum and currency.gold >= 50:
		_unlocked_platinum = true
		# Synchronize with CurrencyManager unlock system
		CurrencyManager.unlocked_currencies[CurrencyManager.CurrencyType.PLATINUM] = true
		Global.show_stat_notification("Trading in platinum bonds now permitted")
