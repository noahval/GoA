extends Control

var break_time = 30.0
var max_break_time = 30.0

# Exchange state
var from_currency_type: int = CurrencyManager.CurrencyType.COPPER
var to_currency_type: int = CurrencyManager.CurrencyType.SILVER
var exchange_amount: float = 0.0

# Node references - existing
@onready var break_timer_bar = $HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimerBar
@onready var break_timer_label = $HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimer
@onready var coins_panel = $HBoxContainer/LeftVBox/CoinsPanel

# Node references - new exchange UI
@onready var market_rates_label = $HBoxContainer/LeftVBox/MarketRatesPanel/MarginContainer/RatesLabel
@onready var from_option = $HBoxContainer/RightVBox/ExchangePanel/MarginContainer/VBox/FromCurrencyOption
@onready var to_option = $HBoxContainer/RightVBox/ExchangePanel/MarginContainer/VBox/ToCurrencyOption
@onready var amount_input = $HBoxContainer/RightVBox/ExchangePanel/MarginContainer/VBox/AmountInput
@onready var preview_label = $HBoxContainer/RightVBox/ExchangePanel/MarginContainer/VBox/PreviewLabel
@onready var exchange_button = $HBoxContainer/RightVBox/ExchangeButton

func _ready():
	# Set the actual maximum break time
	max_break_time = Level1Vars.starting_break_time + Level1Vars.overseer_lvl

	if Level1Vars.break_time_remaining > 0:
		break_time = Level1Vars.break_time_remaining
	else:
		break_time = max_break_time

	# Initialize the progress bar
	if break_timer_bar:
		var progress_percent = (break_time / max_break_time) * 100.0
		break_timer_bar.value = progress_percent

	ResponsiveLayout.apply_to_scene(self)

	# Setup exchange UI
	setup_currency_options()
	update_market_rates_display()
	connect_signals()

	update_labels()
	update_preview()

func _process(delta):
	break_time -= delta
	Level1Vars.break_time_remaining = break_time

	# Update progress bar
	if break_timer_bar:
		var progress_percent = (break_time / max_break_time) * 100.0
		break_timer_bar.value = progress_percent

	# Update timer label
	if break_timer_label:
		break_timer_label.text = "Break Timer"

	if break_time <= 0:
		Level1Vars.break_time_remaining = 0.0
		Global.change_scene_with_check(get_tree(), "res://level1/furnace.tscn")

func _on_to_coppersmith_carriage_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/coppersmith_carriage.tscn")

func update_labels():
	# Update coins display
	_update_currency_display()

## Update currency panel with current currency values
func _update_currency_display():
	if coins_panel:
		var currency_data = CurrencyManager.format_currency_for_icons(false)
		coins_panel.setup_currency_display(currency_data)


## Setup currency dropdown options (only show unlocked currencies)
func setup_currency_options():
	if not from_option or not to_option:
		return

	from_option.clear()
	to_option.clear()

	var currency_names = ["Copper", "Silver", "Gold", "Platinum"]
	var currency_types = [
		CurrencyManager.CurrencyType.COPPER,
		CurrencyManager.CurrencyType.SILVER,
		CurrencyManager.CurrencyType.GOLD,
		CurrencyManager.CurrencyType.PLATINUM
	]

	for i in range(4):
		var can_show = true

		# Filter based on Level1Vars unlocks
		if i == 2:  # Gold
			can_show = Level1Vars.unlocked_gold
		elif i == 3:  # Platinum
			can_show = Level1Vars.unlocked_platinum

		if can_show:
			from_option.add_item(currency_names[i], currency_types[i])
			to_option.add_item(currency_names[i], currency_types[i])

	# Set default selection
	if from_option.item_count > 0:
		from_option.select(0)
	if to_option.item_count > 1:
		to_option.select(1)

	from_currency_type = CurrencyManager.CurrencyType.COPPER
	to_currency_type = CurrencyManager.CurrencyType.SILVER


## Update market rates display panel
func update_market_rates_display():
	if not market_rates_label:
		return

	var rates_text = "Currency Exchange\n\nCurrent Rates:\n"

	# Calculate how much copper for 1 silver
	var copper_modifier = CurrencyManager.conversion_rate_modifiers[CurrencyManager.CurrencyType.COPPER]
	var silver_modifier = CurrencyManager.conversion_rate_modifiers[CurrencyManager.CurrencyType.SILVER]
	var copper_per_silver = (100.0 * copper_modifier) / silver_modifier
	rates_text += "1 silver = %.0f copper" % copper_per_silver

	# Gold (if unlocked)
	if Level1Vars.unlocked_gold:
		var gold_modifier = CurrencyManager.conversion_rate_modifiers[CurrencyManager.CurrencyType.GOLD]
		var silver_per_gold = (100.0 * silver_modifier) / gold_modifier
		rates_text += "\n1 gold = %.0f silver" % silver_per_gold

	# Platinum (if unlocked) - Platinum is stable (modifier always 1.0)
	if Level1Vars.unlocked_platinum:
		var gold_modifier = CurrencyManager.conversion_rate_modifiers[CurrencyManager.CurrencyType.GOLD]
		var gold_per_platinum = 100.0 / gold_modifier  # Gold fluctuates vs stable platinum
		rates_text += "\n1 platinum = %.0f gold" % gold_per_platinum

	market_rates_label.text = rates_text


## Update exchange preview
func update_preview():
	if not preview_label:
		return

	if exchange_amount <= 0:
		preview_label.text = "Enter amount to exchange"
		if exchange_button:
			exchange_button.disabled = true
		return

	# Check if player has enough
	var player_amount = CurrencyManager._get_player_currency(from_currency_type)
	if player_amount < exchange_amount:
		preview_label.text = "Insufficient funds"
		if exchange_button:
			exchange_button.disabled = true
		return

	# Calculate preview
	var fee = CurrencyManager.calculate_transaction_fee(exchange_amount, from_currency_type)
	var net_amount = exchange_amount - fee

	var from_rate = CurrencyManager.CONVERSION_RATES[from_currency_type] * CurrencyManager.conversion_rate_modifiers[from_currency_type]
	var to_rate = CurrencyManager.CONVERSION_RATES[to_currency_type] * CurrencyManager.conversion_rate_modifiers[to_currency_type]

	var received = (net_amount * from_rate) / to_rate

	# Format preview text
	var from_name = get_currency_name(from_currency_type)
	var to_name = get_currency_name(to_currency_type)

	preview_label.text = "%.1f %s -> %.2f %s\n(broker takes %.1f %s)" % [
		exchange_amount, from_name,
		received, to_name,
		fee, from_name
	]

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


## Connect UI signals
func connect_signals():
	if from_option:
		from_option.item_selected.connect(_on_from_currency_selected)
	if to_option:
		to_option.item_selected.connect(_on_to_currency_selected)
	if amount_input:
		amount_input.text_changed.connect(_on_amount_text_changed)
	if exchange_button:
		exchange_button.pressed.connect(_on_exchange_button_pressed)


## Signal handlers
func _on_from_currency_selected(index: int):
	from_currency_type = from_option.get_item_id(index)
	update_preview()


func _on_to_currency_selected(index: int):
	to_currency_type = to_option.get_item_id(index)
	update_preview()


func _on_amount_text_changed(new_text: String):
	exchange_amount = new_text.to_float()
	update_preview()


func _on_exchange_button_pressed():
	var result = CurrencyManager.exchange_currency_with_fee(
		from_currency_type,
		to_currency_type,
		exchange_amount
	)

	if result.success:
		var to_name = get_currency_name(to_currency_type)
		Global.show_stat_notification("Exchange complete: received %.2f %s" % [result.received, to_name])

		# Reset form
		if amount_input:
			amount_input.text = ""
		exchange_amount = 0.0
		update_preview()
		update_labels()
	else:
		match result.get("error", "unknown"):
			"insufficient_funds":
				Global.show_stat_notification("Insufficient funds for exchange")
			"currency_locked":
				Global.show_stat_notification("Currency not yet accessible")
			_:
				Global.show_stat_notification("Exchange failed")
