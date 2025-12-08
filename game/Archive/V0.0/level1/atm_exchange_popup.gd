extends Panel

# Signal emitted when a successful exchange occurs
signal exchange_completed

# Exchange state
var selected_currency_type: int = CurrencyManager.CurrencyType.SILVER
var is_buying: bool = true
var exchange_amount: int = 0

# Node references (rates_label removed - redundant with left panel display)
@onready var currency_static_label = $MarginContainer/VBox/CurrencyRow/CurrencyStaticLabel
@onready var currency_option = $MarginContainer/VBox/CurrencyRow/CurrencyOption
@onready var buy_sell_toggle = $MarginContainer/VBox/CurrencyRow/BuySellToggle
@onready var amount_input = $MarginContainer/VBox/AmountRow/AmountInput
@onready var minus_button = $MarginContainer/VBox/AmountRow/MinusButton
@onready var plus_button = $MarginContainer/VBox/AmountRow/PlusButton
@onready var plus10_button = $MarginContainer/VBox/AmountRow/Plus10Button
@onready var max_button = $MarginContainer/VBox/AmountRow/MaxButton
@onready var preview_label = $MarginContainer/VBox/PreviewLabel
@onready var exchange_button = $MarginContainer/VBox/ButtonRow/ExchangeButton

func _ready():
	# Setup exchange UI
	setup_currency_options()
	connect_signals()
	update_preview()

## Setup currency selector (dynamic label/dropdown based on unlocks)
func setup_currency_options():
	if not currency_static_label or not currency_option:
		return

	# Check if we have multiple currencies unlocked
	var has_gold = Level1Vars.unlocked_gold
	var has_platinum = Level1Vars.unlocked_platinum

	if has_gold or has_platinum:
		# Show dropdown, hide label
		currency_static_label.visible = false
		currency_option.visible = true

		# Populate dropdown with unlocked currencies
		currency_option.clear()
		currency_option.add_item("Silver", CurrencyManager.CurrencyType.SILVER)

		if has_gold:
			currency_option.add_item("Gold", CurrencyManager.CurrencyType.GOLD)

		if has_platinum:
			currency_option.add_item("Platinum", CurrencyManager.CurrencyType.PLATINUM)

		# Set default selection to first item (Silver)
		currency_option.select(0)
		selected_currency_type = CurrencyManager.CurrencyType.SILVER
	else:
		# Only Silver unlocked - show label, hide dropdown
		currency_static_label.visible = true
		currency_static_label.text = "Silver"
		currency_option.visible = false
		selected_currency_type = CurrencyManager.CurrencyType.SILVER




## Update exchange preview
func update_preview():
	if not preview_label:
		return

	if exchange_amount <= 0:
		preview_label.text = "Enter amount"
		if exchange_button:
			exchange_button.disabled = true
		return

	# Determine the lower currency (what we pay/receive)
	var lower_currency_type: int
	match selected_currency_type:
		CurrencyManager.CurrencyType.SILVER:
			lower_currency_type = CurrencyManager.CurrencyType.COPPER
		CurrencyManager.CurrencyType.GOLD:
			lower_currency_type = CurrencyManager.CurrencyType.SILVER
		CurrencyManager.CurrencyType.PLATINUM:
			lower_currency_type = CurrencyManager.CurrencyType.GOLD
		_:
			lower_currency_type = CurrencyManager.CurrencyType.COPPER

	var lower_name = get_currency_name(lower_currency_type)

	if is_buying:
		# BUY mode: Pay lower currency to get selected currency
		var selected_rate = CurrencyManager.CONVERSION_RATES[selected_currency_type] * CurrencyManager.conversion_rate_modifiers[selected_currency_type]
		var lower_rate = CurrencyManager.CONVERSION_RATES[lower_currency_type] * CurrencyManager.conversion_rate_modifiers[lower_currency_type]

		# Estimate amount of lower currency needed
		var target_received = float(exchange_amount)
		var base_estimate = (target_received * selected_rate) / lower_rate

		# Use iterative refinement for accurate cost calculation
		var estimated_amount = base_estimate / 0.92  # Initial guess accounting for ~8% fee
		for i in range(3):
			var test_fee = CurrencyManager.calculate_transaction_fee(estimated_amount, lower_currency_type)
			var test_net = estimated_amount - test_fee
			var test_received = (test_net * lower_rate) / selected_rate

			if test_received < target_received:
				var ratio = target_received / test_received
				estimated_amount *= ratio
			else:
				break

		# Final cost and fee calculation
		var final_fee = CurrencyManager.calculate_transaction_fee(estimated_amount, lower_currency_type)
		var fee_percent = (final_fee / estimated_amount) if estimated_amount > 0 else 0.08
		var total_cost = int(ceil(estimated_amount))

		# Check if player has enough lower currency
		var player_lower = CurrencyManager._get_player_currency(lower_currency_type)
		if player_lower < total_cost:
			preview_label.text = "Insufficient funds"
			if exchange_button:
				exchange_button.disabled = true
			return

		preview_label.text = "Cost: %d %s\n(includes %.1f%% brokerage fee)" % [total_cost, lower_name, fee_percent * 100]

		if exchange_button:
			exchange_button.disabled = false
	else:
		# SELL mode: Sell selected currency to get lower currency
		var selected_name = get_currency_name(selected_currency_type)
		var player_selected = CurrencyManager._get_player_currency(selected_currency_type)
		if player_selected < exchange_amount:
			preview_label.text = "Insufficient funds"
			if exchange_button:
				exchange_button.disabled = true
			return

		# Calculate proceeds in lower currency
		var selected_rate = CurrencyManager.CONVERSION_RATES[selected_currency_type] * CurrencyManager.conversion_rate_modifiers[selected_currency_type]
		var lower_rate = CurrencyManager.CONVERSION_RATES[lower_currency_type] * CurrencyManager.conversion_rate_modifiers[lower_currency_type]

		# Calculate fee
		var fee_percent = get_fee_percent(exchange_amount, selected_currency_type)
		var net_amount = exchange_amount * (1.0 - fee_percent)

		# Proceeds (rounded down)
		var proceeds = int(floor((net_amount * selected_rate) / lower_rate))

		preview_label.text = "You'll receive: %d %s\n(includes %.1f%% brokerage fee)" % [proceeds, lower_name, fee_percent * 100]

		if exchange_button:
			exchange_button.disabled = false


## Get currency name from type
func get_currency_name(type: int) -> String:
	match type:
		CurrencyManager.CurrencyType.COPPER:
			return "copper"
		CurrencyManager.CurrencyType.SILVER:
			return "silver"
		CurrencyManager.CurrencyType.GOLD:
			return "gold"
		CurrencyManager.CurrencyType.PLATINUM:
			return "platinum"
	return ""


## Calculate fee percentage for a transaction
func get_fee_percent(amount: float, currency_type: int) -> float:
	var copper_value = amount * CurrencyManager.CONVERSION_RATES[currency_type]
	var base_fee_percent = 0.08  # 8% base
	var scaling_factor = log(copper_value + 1) / 100000.0
	var fee_percent = base_fee_percent - (scaling_factor * 0.07)
	fee_percent = clamp(fee_percent, 0.01, 0.08)  # 1%-8% range

	# Charisma reduces fees (2% per level)
	if Global.charisma > 1:
		var charisma_reduction = (Global.charisma - 1) * 0.02
		fee_percent *= (1.0 - charisma_reduction)
		fee_percent = max(fee_percent, 0.01)  # Minimum 1%

	return fee_percent


## Connect UI signals
func connect_signals():
	if currency_option:
		currency_option.item_selected.connect(_on_currency_selected)
	if buy_sell_toggle:
		buy_sell_toggle.pressed.connect(_on_buy_sell_toggle_pressed)
	if amount_input:
		amount_input.text_changed.connect(_on_amount_text_changed)
	if minus_button:
		minus_button.pressed.connect(_on_minus_pressed)
	if plus_button:
		plus_button.pressed.connect(_on_plus_pressed)
	if plus10_button:
		plus10_button.pressed.connect(_on_plus10_pressed)
	if max_button:
		max_button.pressed.connect(_on_max_pressed)
	if exchange_button:
		exchange_button.pressed.connect(_on_exchange_button_pressed)


## Signal handlers
func _on_currency_selected(index: int):
	selected_currency_type = currency_option.get_item_id(index)
	update_preview()


func _on_buy_sell_toggle_pressed():
	is_buying = not is_buying
	if buy_sell_toggle:
		buy_sell_toggle.text = "BUY" if is_buying else "SELL"
	update_preview()


func _on_amount_text_changed(new_text: String):
	exchange_amount = max(0, new_text.to_int())
	update_preview()


func _on_minus_pressed():
	exchange_amount = max(0, exchange_amount - 1)
	if amount_input:
		amount_input.text = str(exchange_amount)
	update_preview()


func _on_plus_pressed():
	exchange_amount += 1
	if amount_input:
		amount_input.text = str(exchange_amount)
	update_preview()


func _on_plus10_pressed():
	exchange_amount += 10
	if amount_input:
		amount_input.text = str(exchange_amount)
	update_preview()


func _on_max_pressed():
	# Determine lower currency
	var lower_currency_type: int
	match selected_currency_type:
		CurrencyManager.CurrencyType.SILVER:
			lower_currency_type = CurrencyManager.CurrencyType.COPPER
		CurrencyManager.CurrencyType.GOLD:
			lower_currency_type = CurrencyManager.CurrencyType.SILVER
		CurrencyManager.CurrencyType.PLATINUM:
			lower_currency_type = CurrencyManager.CurrencyType.GOLD
		_:
			lower_currency_type = CurrencyManager.CurrencyType.COPPER

	if is_buying:
		# Calculate max affordable amount of selected currency
		var player_lower = CurrencyManager._get_player_currency(lower_currency_type)
		var selected_rate = CurrencyManager.CONVERSION_RATES[selected_currency_type] * CurrencyManager.conversion_rate_modifiers[selected_currency_type]
		var lower_rate = CurrencyManager.CONVERSION_RATES[lower_currency_type] * CurrencyManager.conversion_rate_modifiers[lower_currency_type]

		# Estimate max affordable (accounting for ~8% fee)
		var base_max = (player_lower * lower_rate) / selected_rate
		var estimated_max = int(floor(base_max * 0.92))

		# Binary search to find exact max
		var low = 0
		var high = estimated_max
		var best = 0

		while low <= high:
			var mid = int((low + high) / 2.0)
			var fee_percent = get_fee_percent(mid, selected_currency_type)
			var fee_in_selected = mid * fee_percent
			var base_cost = (mid * selected_rate) / lower_rate
			var fee_in_lower = (fee_in_selected * selected_rate) / lower_rate
			var total_cost = int(ceil(base_cost + fee_in_lower))

			if total_cost <= player_lower:
				best = mid
				low = mid + 1
			else:
				high = mid - 1

		exchange_amount = best
	else:
		# Sell mode: Max is current balance of selected currency
		exchange_amount = int(CurrencyManager._get_player_currency(selected_currency_type))

	if amount_input:
		amount_input.text = str(exchange_amount)
	update_preview()


func _on_exchange_button_pressed():
	# Determine currencies involved
	var lower_currency_type: int
	match selected_currency_type:
		CurrencyManager.CurrencyType.SILVER:
			lower_currency_type = CurrencyManager.CurrencyType.COPPER
		CurrencyManager.CurrencyType.GOLD:
			lower_currency_type = CurrencyManager.CurrencyType.SILVER
		CurrencyManager.CurrencyType.PLATINUM:
			lower_currency_type = CurrencyManager.CurrencyType.GOLD
		_:
			lower_currency_type = CurrencyManager.CurrencyType.COPPER

	var from_type: int
	var to_type: int
	var amount_to_exchange: float

	if is_buying:
		# Buying: Exchange lower currency for selected currency
		from_type = lower_currency_type
		to_type = selected_currency_type

		var selected_rate = CurrencyManager.CONVERSION_RATES[selected_currency_type] * CurrencyManager.conversion_rate_modifiers[selected_currency_type]
		var lower_rate = CurrencyManager.CONVERSION_RATES[lower_currency_type] * CurrencyManager.conversion_rate_modifiers[lower_currency_type]

		# Use binary search to find exact amount of lower currency needed
		var target_received = float(exchange_amount)
		var low = 0.0
		var high = CurrencyManager._get_player_currency(lower_currency_type) * 2.0
		var best_amount = 0.0
		var iterations = 0
		var max_iterations = 50

		while iterations < max_iterations and high - low > 0.01:
			var mid = (low + high) / 2.0
			var test_fee = CurrencyManager.calculate_transaction_fee(mid, lower_currency_type)
			var test_net = mid - test_fee
			var test_received = (test_net * lower_rate) / selected_rate

			if abs(test_received - target_received) < 0.01:
				best_amount = mid
				break
			elif test_received < target_received:
				low = mid
			else:
				high = mid

			iterations += 1

		# If binary search didn't converge, use approximation
		if best_amount == 0.0:
			var base_needed = (target_received * selected_rate) / lower_rate
			best_amount = base_needed / 0.92

		amount_to_exchange = best_amount
	else:
		# Selling: Exchange selected currency for lower currency
		from_type = selected_currency_type
		to_type = lower_currency_type
		amount_to_exchange = float(exchange_amount)

	var result = CurrencyManager.exchange_currency_with_fee(
		from_type,
		to_type,
		amount_to_exchange
	)

	if result.success:
		if is_buying:
			Global.show_stat_notification("Purchased %d %s" % [exchange_amount, get_currency_name(selected_currency_type)])
		else:
			Global.show_stat_notification("Sold %d %s for %d %s" % [exchange_amount, get_currency_name(selected_currency_type), int(result.received), get_currency_name(lower_currency_type)])

		# Update preview with current amount (keep the entered value for convenience)
		update_preview()

		# Store current selection before refreshing
		var previous_selection = selected_currency_type

		# Refresh currency options in case of unlocks
		setup_currency_options()

		# Restore previous selection if it's still available
		if currency_option and currency_option.visible:
			for i in range(currency_option.item_count):
				if currency_option.get_item_id(i) == previous_selection:
					currency_option.select(i)
					selected_currency_type = previous_selection
					break

		# Emit signal to notify parent scene
		exchange_completed.emit()

		# Fallback: Try direct parent method call
		var parent = get_parent()
		if parent and parent.has_method("_update_currency_display"):
			parent._update_currency_display()
	else:
		match result.get("error", "unknown"):
			"insufficient_funds":
				Global.show_stat_notification("Insufficient funds for exchange")
			"currency_locked":
				Global.show_stat_notification("Currency not yet accessible")
			_:
				Global.show_stat_notification("Exchange failed")
