extends Node

## Currency Manager - Handles all multi-currency operations for GoA
## Currencies: Copper Pieces (1x) -> Silver Marks (100x) -> Gold Crowns (10,000x) -> Platinum Bonds (1,000,000x)

# Currency type constants
enum CurrencyType {
	COPPER,
	SILVER,
	GOLD,
	PLATINUM
}

# Currency icon paths
const CURRENCY_ICONS = {
	CurrencyType.COPPER: "res://level1/icons/copper_icon.png",
	CurrencyType.SILVER: "res://level1/icons/silver_icon.png",
	CurrencyType.GOLD: "res://level1/icons/gold_icon.png",
	CurrencyType.PLATINUM: "res://level1/icons/platinum_icon.png"
}

# Currency names for display
const CURRENCY_NAMES = {
	CurrencyType.COPPER: "Copper",
	CurrencyType.SILVER: "Silver",
	CurrencyType.GOLD: "Gold",
	CurrencyType.PLATINUM: "Platinum"
}

# Currency names (plural) for display
const CURRENCY_NAMES_PLURAL = {
	CurrencyType.COPPER: "Copper Pieces",
	CurrencyType.SILVER: "Silver Marks",
	CurrencyType.GOLD: "Gold Crowns",
	CurrencyType.PLATINUM: "Platinum Bonds"
}

# Conversion rates (how many of lower tier = 1 of this tier)
const CONVERSION_RATES = {
	CurrencyType.COPPER: 1,
	CurrencyType.SILVER: 100,
	CurrencyType.GOLD: 10000,  # 100 silver = 1 gold
	CurrencyType.PLATINUM: 1000000  # 100 gold = 1 platinum
}

# Variable conversion rates (for dynamic market volatility)
var conversion_rate_modifiers = {
	CurrencyType.COPPER: 1.0,
	CurrencyType.SILVER: 1.0,
	CurrencyType.GOLD: 1.0,
	CurrencyType.PLATINUM: 1.0  # Platinum is stable anchor (always 1.0)
}

# Market volatility system
var market_update_timer: float = 0.0
var next_market_update_interval: float = 900.0  # 15 minutes default
var market_volatility: Dictionary = {
	CurrencyType.COPPER: 0.0,   # Fluctuates vs silver (laborers)
	CurrencyType.SILVER: 0.0,   # Fluctuates vs gold (merchants)
	CurrencyType.GOLD: 0.0      # Fluctuates vs platinum (nobles)
	# Platinum has no volatility (stable anchor)
}

# Unlock thresholds (total copper value needed to unlock each currency tier)
const UNLOCK_THRESHOLDS = {
	CurrencyType.COPPER: 0,
	CurrencyType.SILVER: 500,  # Unlock silver at 500 copper lifetime
	CurrencyType.GOLD: 50000,  # Unlock gold at 50,000 copper lifetime (500 silver)
	CurrencyType.PLATINUM: 2500000  # Unlock platinum at 2.5M copper lifetime (25 gold)
}

# Track unlocked currencies
var unlocked_currencies = {
	CurrencyType.COPPER: true,
	CurrencyType.SILVER: false,
	CurrencyType.GOLD: false,
	CurrencyType.PLATINUM: false
}


## Check if player can afford a cost (supports single currency or multi-currency costs)
## @param cost: Either a float (assumes copper) or a dictionary like {"copper": 10.0, "silver": 2.0}
## @return: bool - true if player can afford it
func can_afford(cost) -> bool:
	if typeof(cost) == TYPE_FLOAT or typeof(cost) == TYPE_INT:
		# Legacy single currency (copper)
		return Level1Vars.currency.copper >= cost
	elif typeof(cost) == TYPE_DICTIONARY:
		# Multi-currency cost
		for currency_name in cost.keys():
			var currency_type = _get_currency_type_from_name(currency_name)
			if currency_type == null:
				push_error("Invalid currency name: " + str(currency_name))
				return false

			var required_amount = cost[currency_name]
			var player_amount = _get_player_currency(currency_type)

			if player_amount < required_amount:
				return false
		return true
	else:
		push_error("Invalid cost type: " + str(typeof(cost)))
		return false


## Deduct currency from player
## @param cost: Either a float (assumes copper) or a dictionary like {"copper": 10.0, "silver": 2.0}
## @return: bool - true if successfully deducted, false if couldn't afford
func deduct_currency(cost) -> bool:
	if not can_afford(cost):
		return false

	if typeof(cost) == TYPE_FLOAT or typeof(cost) == TYPE_INT:
		# Legacy single currency (copper)
		var old_amount = Level1Vars.currency.copper
		Level1Vars.currency.copper -= cost
		Level1Vars.coins = Level1Vars.currency.copper  # Sync legacy variable
		DebugLogger.log_resource_change("copper", old_amount, Level1Vars.currency.copper, "purchase")
		return true
	elif typeof(cost) == TYPE_DICTIONARY:
		# Multi-currency cost - deduct all currencies
		for currency_name in cost.keys():
			var currency_type = _get_currency_type_from_name(currency_name)
			var amount = cost[currency_name]
			var old_amount = _get_player_currency(currency_type)

			_set_player_currency(currency_type, old_amount - amount)
			DebugLogger.log_resource_change(currency_name, old_amount, _get_player_currency(currency_type), "purchase")

		return true

	return false


## Add currency to player
## @param currency_type: CurrencyType enum value (e.g., CurrencyType.COPPER)
## @param amount: float - amount to add
## @param reason: string - reason for logging (optional)
func add_currency(currency_type: int, amount: float, reason: String = "earned") -> void:
	var old_amount = _get_player_currency(currency_type)
	_set_player_currency(currency_type, old_amount + amount)

	# Also add to lifetime currency
	var currency_name = CURRENCY_NAMES[currency_type].to_lower()
	if Level1Vars.lifetime_currency.has(currency_name):
		Level1Vars.lifetime_currency[currency_name] += amount

	# Check if this unlocks new currency tiers (CurrencyManager system)
	_check_currency_unlocks()

	# Check ATM currency tier unlocks (based on current holdings)
	Level1Vars.check_currency_unlocks()

	# Log the change
	DebugLogger.log_resource_change(currency_name, old_amount, _get_player_currency(currency_type), reason)


## Convert currency from one type to another
## @param from_type: CurrencyType enum - currency to convert from
## @param to_type: CurrencyType enum - currency to convert to
## @param amount: float - amount of from_type to convert
## @return: float - amount of to_type received, or -1 if failed
func convert_currency(from_type: int, to_type: int, amount: float) -> float:
	# Check if player has enough
	var player_amount = _get_player_currency(from_type)
	if player_amount < amount:
		push_warning("Not enough currency to convert")
		return -1

	# Check if target currency is unlocked
	if not unlocked_currencies[to_type]:
		push_warning("Target currency not unlocked yet")
		return -1

	# Calculate conversion
	var from_rate = CONVERSION_RATES[from_type] * conversion_rate_modifiers[from_type]
	var to_rate = CONVERSION_RATES[to_type] * conversion_rate_modifiers[to_type]
	var converted_amount = (amount * from_rate) / to_rate

	# Deduct from source
	_set_player_currency(from_type, player_amount - amount)

	# Add to target
	var target_amount = _get_player_currency(to_type)
	_set_player_currency(to_type, target_amount + converted_amount)

	# Log the conversion
	var from_name = CURRENCY_NAMES[from_type].to_lower()
	var to_name = CURRENCY_NAMES[to_type].to_lower()
	DebugLogger.log_resource_change(from_name, player_amount, player_amount - amount, "converted to " + to_name)
	DebugLogger.log_resource_change(to_name, target_amount, target_amount + converted_amount, "converted from " + from_name)

	return converted_amount


## Get total value of all player currency in copper equivalent
## @return: float - total copper value
func get_total_copper_value() -> float:
	var total = 0.0
	total += Level1Vars.currency.copper * CONVERSION_RATES[CurrencyType.COPPER]
	total += Level1Vars.currency.silver * CONVERSION_RATES[CurrencyType.SILVER]
	total += Level1Vars.currency.gold * CONVERSION_RATES[CurrencyType.GOLD]
	total += Level1Vars.currency.platinum * CONVERSION_RATES[CurrencyType.PLATINUM]
	return total


## Get currency icon path for a specific currency type
## @param currency_type: CurrencyType enum value
## @return: String - path to icon file
static func get_currency_icon(currency_type: int) -> String:
	return CURRENCY_ICONS.get(currency_type, "")


## Format currency for icon-based display
## Returns an array of dictionaries suitable for CurrencyPanel.setup_currency_display()
## @param show_all: bool - if true, shows all currency types. If false, only shows non-zero amounts
## @return: Array of {"icon": String, "value": String} dictionaries
func format_currency_for_icons(show_all: bool = false) -> Array:
	var result = []

	var currencies = [
		{"type": CurrencyType.COPPER, "key": "copper"},
		{"type": CurrencyType.SILVER, "key": "silver"},
		{"type": CurrencyType.GOLD, "key": "gold"},
		{"type": CurrencyType.PLATINUM, "key": "platinum"}
	]

	for curr in currencies:
		var amount = Level1Vars.currency[curr.key]

		# Skip if zero and not showing all
		if not show_all and amount <= 0:
			continue

		# Skip if not unlocked and zero
		if not unlocked_currencies[curr.type] and amount <= 0:
			continue

		result.append({
			"icon": CURRENCY_ICONS[curr.type],
			"value": _format_number(amount)
		})

	# If nothing to show, show at least copper with 0
	if result.is_empty():
		result.append({
			"icon": CURRENCY_ICONS[CurrencyType.COPPER],
			"value": "0"
		})

	return result


## Format currency for display (legacy text-based format)
## @param show_all: bool - if true, shows all currency types. If false, only shows non-zero amounts
## @param compact: bool - if true, uses compact format (C: 100 | S: 5). If false, uses full names
## @return: String - formatted currency display
func format_currency_display(show_all: bool = false, compact: bool = false) -> String:
	var parts = []

	var currencies = [
		{"type": CurrencyType.COPPER, "key": "copper"},
		{"type": CurrencyType.SILVER, "key": "silver"},
		{"type": CurrencyType.GOLD, "key": "gold"},
		{"type": CurrencyType.PLATINUM, "key": "platinum"}
	]

	for curr in currencies:
		var amount = Level1Vars.currency[curr.key]

		# Skip if zero and not showing all
		if not show_all and amount <= 0:
			continue

		# Skip if not unlocked and zero
		if not unlocked_currencies[curr.type] and amount <= 0:
			continue

		if compact:
			var abbrev = CURRENCY_NAMES[curr.type].substr(0, 1)  # C, S, G, P
			parts.append(abbrev + ": " + _format_number(amount))
		else:
			parts.append(CURRENCY_NAMES[curr.type] + ": " + _format_number(amount))

	if parts.is_empty():
		return "Copper: 0"

	return " | ".join(parts)


## Format a single currency amount for display
## @param currency_type: CurrencyType enum
## @param amount: float - amount to format
## @param show_name: bool - if true, includes currency name
## @return: String - formatted amount
func format_single_currency(currency_type: int, amount: float, show_name: bool = true) -> String:
	if show_name:
		return CURRENCY_NAMES[currency_type] + ": " + _format_number(amount)
	else:
		return _format_number(amount)


## Helper: Format number with commas for readability
func _format_number(value: float) -> String:
	var num_str = str(int(value))
	var formatted = ""
	var count = 0

	for i in range(num_str.length() - 1, -1, -1):
		if count == 3:
			formatted = "," + formatted
			count = 0
		formatted = num_str[i] + formatted
		count += 1

	return formatted


## Helper: Get currency type from string name
func _get_currency_type_from_name(name: String):
	match name.to_lower():
		"copper":
			return CurrencyType.COPPER
		"silver":
			return CurrencyType.SILVER
		"gold":
			return CurrencyType.GOLD
		"platinum":
			return CurrencyType.PLATINUM
		_:
			return null


## Helper: Get player's current amount of a currency type
func _get_player_currency(currency_type: int) -> float:
	match currency_type:
		CurrencyType.COPPER:
			return Level1Vars.currency.copper
		CurrencyType.SILVER:
			return Level1Vars.currency.silver
		CurrencyType.GOLD:
			return Level1Vars.currency.gold
		CurrencyType.PLATINUM:
			return Level1Vars.currency.platinum
		_:
			return 0.0


## Helper: Set player's currency amount
func _set_player_currency(currency_type: int, amount: float) -> void:
	match currency_type:
		CurrencyType.COPPER:
			Level1Vars.currency.copper = amount
			Level1Vars.coins = amount  # Sync legacy variable
		CurrencyType.SILVER:
			Level1Vars.currency.silver = amount
		CurrencyType.GOLD:
			Level1Vars.currency.gold = amount
		CurrencyType.PLATINUM:
			Level1Vars.currency.platinum = amount


## Check if player has unlocked new currency tiers based on lifetime earnings
func _check_currency_unlocks() -> void:
	var total_lifetime_copper = 0.0
	for currency_name in Level1Vars.lifetime_currency.keys():
		var currency_type = _get_currency_type_from_name(currency_name)
		if currency_type != null:
			total_lifetime_copper += Level1Vars.lifetime_currency[currency_name] * CONVERSION_RATES[currency_type]

	# Check each tier
	for currency_type in UNLOCK_THRESHOLDS.keys():
		if not unlocked_currencies[currency_type] and total_lifetime_copper >= UNLOCK_THRESHOLDS[currency_type]:
			unlocked_currencies[currency_type] = true
			var currency_name = CURRENCY_NAMES_PLURAL[currency_type]
			DebugLogger.log_info("CurrencyUnlock", "Unlocked " + currency_name + "!")
			# Could show notification to player here


## Check if a currency type is unlocked
func is_currency_unlocked(currency_type: int) -> bool:
	return unlocked_currencies.get(currency_type, false)


## Calculate transaction fee for currency exchange
## Fee scales from 8% for small transactions to 1% for large ones
## @param amount: float - amount being exchanged
## @param from_type: CurrencyType enum - currency being converted from
## @return: float - fee amount in same currency as amount
func calculate_transaction_fee(amount: float, from_type: int) -> float:
	var copper_value = amount * CONVERSION_RATES[from_type]
	var base_fee_percent = 0.08  # 8% base fee
	var scaling_factor = log(copper_value + 1) / 100000.0
	var fee_percent = base_fee_percent - (scaling_factor * 0.07)
	fee_percent = clamp(fee_percent, 0.01, 0.08)  # 1% to 8% range

	# Optional: Charisma reduces fees (2% reduction per level)
	if Global.charisma > 1:
		var charisma_reduction = (Global.charisma - 1) * 0.02
		fee_percent *= (1.0 - charisma_reduction)
		fee_percent = max(fee_percent, 0.01)  # Minimum 1% fee

	return amount * fee_percent


## Exchange currency with transaction fee
## @param from_type: CurrencyType enum - currency to convert from
## @param to_type: CurrencyType enum - currency to convert to
## @param amount: float - amount of from_type to exchange
## @return: Dictionary with success, fee, received, and market_rate
func exchange_currency_with_fee(from_type: int, to_type: int, amount: float) -> Dictionary:
	# Validate player has enough
	var player_amount = _get_player_currency(from_type)
	if player_amount < amount:
		return {"success": false, "error": "insufficient_funds"}

	# Check if target currency is unlocked
	if not unlocked_currencies[to_type]:
		return {"success": false, "error": "currency_locked"}

	# Calculate fee
	var fee = calculate_transaction_fee(amount, from_type)
	var net_amount = amount - fee

	# Calculate conversion with market rates
	var from_rate = CONVERSION_RATES[from_type] * conversion_rate_modifiers[from_type]
	var to_rate = CONVERSION_RATES[to_type] * conversion_rate_modifiers[to_type]
	var received = (net_amount * from_rate) / to_rate

	# Deduct full amount from player (including fee)
	_set_player_currency(from_type, player_amount - amount)

	# Add received amount to target currency
	var target_amount = _get_player_currency(to_type)
	_set_player_currency(to_type, target_amount + received)

	# Log the exchange
	var from_name = CURRENCY_NAMES[from_type].to_lower()
	var to_name = CURRENCY_NAMES[to_type].to_lower()
	DebugLogger.log_resource_change(from_name, player_amount, player_amount - amount, "exchanged to " + to_name)
	DebugLogger.log_resource_change(to_name, target_amount, target_amount + received, "exchanged from " + from_name)

	# Award experience based on transaction value
	var xp_amount = fee * CONVERSION_RATES[from_type]
	Global.add_stat_exp("charisma", xp_amount)

	return {
		"success": true,
		"fee": fee,
		"received": received,
		"market_rate": conversion_rate_modifiers[to_type]
	}


## Reset currencies for prestige (decides what persists)
## @param keep_platinum: bool - if true, platinum bonds persist through prestige
func reset_for_prestige(keep_platinum: bool = true) -> void:
	Level1Vars.currency.copper = 0.0
	Level1Vars.currency.silver = 0.0
	Level1Vars.currency.gold = 0.0

	if not keep_platinum:
		Level1Vars.currency.platinum = 0.0

	# Sync legacy variable
	Level1Vars.coins = 0.0

	# Keep lifetime currencies
	# Keep unlocks (once unlocked, always unlocked)


## Initialize market rates on startup
func _ready() -> void:
	update_market_rates()  # Set initial rates


## Update market rates over time
func _process(delta: float) -> void:
	market_update_timer += delta
	if market_update_timer >= next_market_update_interval:
		market_update_timer = 0.0
		update_market_rates()


## Update market exchange rates with bell curve volatility
func update_market_rates() -> void:
	# Set next update interval (15-30 minutes random)
	next_market_update_interval = randf_range(900.0, 1800.0)

	# Update rates with bell curve (Copper, Silver, Gold only)
	# Platinum is the stable anchor (no volatility)
	for currency_type in [CurrencyType.COPPER, CurrencyType.SILVER, CurrencyType.GOLD]:
		var deviation = randfn(0.0, 0.1)  # Normal distribution, std dev 0.1
		deviation = clamp(deviation, -0.3, 0.3)  # Clamp to +/- 30%
		market_volatility[currency_type] = deviation
		conversion_rate_modifiers[currency_type] = 1.0 + deviation

		# Show notification for extremes
		var notification = get_extreme_market_notification(currency_type)
		if notification != "":
			Global.show_stat_notification(notification)

	# Debug logging
	DebugLogger.log_info("MarketUpdate", "Rates: C=%.2f, S=%.2f, G=%.2f, P=1.00" % [
		conversion_rate_modifiers[CurrencyType.COPPER],
		conversion_rate_modifiers[CurrencyType.SILVER],
		conversion_rate_modifiers[CurrencyType.GOLD]
	])


## Get market notification for extreme volatility events
## Returns empty string if not extreme, or grimdark flavor text
func get_extreme_market_notification(currency_type: int) -> String:
	var volatility = market_volatility.get(currency_type, 0.0)

	# Only return text for extremes (+/- 20-30%)
	if abs(volatility) < 0.2:
		return ""

	var is_high = volatility > 0.2
	var variant = randi() % 3  # Random variant (0, 1, or 2)

	match currency_type:
		CurrencyType.COPPER:  # Laborers/destitute (fluctuates vs silver)
			if is_high:  # Laborers doing WELL, copper VALUABLE
				match variant:
					0: return "Furnace accident: labor shortage drives copper rates"
					1: return "Infection culls the workforce: survivors demand more"
					2: return "Mass conscription: fewer hands, higher wages"
			else:  # Laborers DESPERATE, copper WEAK
				match variant:
					0: return "Coal quotas doubled: labor value plummets"
					1: return "New work camp opened: copper floods the vaults"
					2: return "Vagrant roundup successful: desperate hands abundant"

		CurrencyType.SILVER:  # Merchants/artisans (fluctuates vs gold)
			if is_high:  # Merchants doing WELL, silver VALUABLE
				match variant:
					0: return "Supply convoy delayed: merchants hoard reserves"
					1: return "Black market disrupted: silver gains legitimacy"
					2: return "Guild masters bribe the Council: rates improve"
			else:  # Merchants DESPERATE, silver WEAK
				match variant:
					0: return "Guild regulations tightened: merchant desperation grows"
					1: return "Trade permits revoked: silver devalues rapidly"
					2: return "Factory owners demand tribute: middle class squeezed"

		CurrencyType.GOLD:  # Nobles/gentry (fluctuates vs platinum)
			if is_high:  # Nobles doing WELL, gold VALUABLE
				match variant:
					0: return "Military contracts awarded: nobles enriched"
					1: return "Land rights restricted: gold becomes scarce"
					2: return "Royal favor shifts: titled families consolidate"
			else:  # Nobles DESPERATE, gold WEAK
				match variant:
					0: return "Estate taxes raised: nobility liquidating assets"
					1: return "War bonds called: old money bleeds gold"
					2: return "Succession crisis: desperate lords sell holdings"

	return ""
