extends Control

var break_time = 30.0
var max_break_time = 30.0

# Node references
@onready var break_timer_bar = $HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimerBar
@onready var break_timer_label = $HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimer
@onready var coins_panel = $HBoxContainer/LeftVBox/CoinsPanel
@onready var market_rates_vbox = $HBoxContainer/LeftVBox/MarketRatesPanel/MarginContainer/RatesVBox
@onready var dev_free_currency_button = $HBoxContainer/RightVBox/DevFreeCurrencyButton
@onready var exchange_popup = $ExchangePopup

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

	# Show/hide developer button based on dev_speed_mode
	if dev_free_currency_button:
		dev_free_currency_button.visible = Global.dev_speed_mode

	# Connect exchange popup signal
	if exchange_popup:
		exchange_popup.exchange_completed.connect(_on_exchange_completed)

	# Defer currency/market updates to ensure CurrencyManager is fully initialized
	call_deferred("_deferred_ready")

func _deferred_ready():
	# Check currency unlocks based on current holdings
	Level1Vars.check_currency_unlocks()

	# Update market rates display
	update_market_rates_display()

	# Update currency display
	_update_currency_display()

	# Debug: Check popup size after layout (needs further deferral for rendering)
	call_deferred("_debug_check_popup_size")

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

func _on_exchange_completed():
	# Update currency display after exchange
	_update_currency_display()
	# Also update market rates in case new currencies were unlocked
	update_market_rates_display()

func _on_dev_free_currency_button_pressed():
	CurrencyManager.add_currency(CurrencyManager.CurrencyType.SILVER, 150, "debug/cheat")
	CurrencyManager.add_currency(CurrencyManager.CurrencyType.GOLD, 150, "debug/cheat")
	_update_currency_display()

	# Also print debug info
	if Global.dev_speed_mode:
		print("\n[DEV] Free currency added!")
		var atm_debug = load("res://level1/atm_debug.gd")
		atm_debug.print_currency_state()

## Update currency panel with current currency values
func _update_currency_display():
	if coins_panel:
		var currency_data = CurrencyManager.format_currency_for_icons(false)
		coins_panel.setup_currency_display(currency_data)


## Debug function to check popup size
func _debug_check_popup_size():
	await get_tree().process_frame
	await get_tree().process_frame

	var popup = $ExchangePopup
	if popup:
		print("\n=== ATM SCENE: Popup Size Check ===")
		print("Popup size: ", popup.size)
		print("Popup offsets: L=", popup.offset_left, " R=", popup.offset_right, " T=", popup.offset_top, " B=", popup.offset_bottom)
		print("Popup anchors: L=", popup.anchor_left, " R=", popup.anchor_right, " T=", popup.anchor_top, " B=", popup.anchor_bottom)
		print("Popup parent: ", popup.get_parent().name if popup.get_parent() else "null")
		print("Popup clip_contents: ", popup.clip_contents)
		print("Popup size_flags_horizontal: ", popup.size_flags_horizontal)

		# Check widest child
		var widest_child = null
		var widest_width = 0.0
		_find_widest_child(popup, widest_child, widest_width)
		if widest_child:
			print("Widest child: ", widest_child.name, " width: ", widest_width)
		print("=== END Popup Size Check ===\n")

func _find_widest_child(node: Node, widest: Control, widest_width: float):
	if node is Control:
		var control = node as Control
		if control.size.x > widest_width:
			widest = control
			widest_width = control.size.x
			print("  Found wide child: ", control.name, " (", control.get_class(), ") width: ", control.size.x)

	for child in node.get_children():
		_find_widest_child(child, widest, widest_width)

## Update market rates display panel
func update_market_rates_display():
	if not market_rates_vbox:
		return

	# Clear existing children
	for child in market_rates_vbox.get_children():
		child.queue_free()

	# Add subtitle
	var subtitle_label = Label.new()
	subtitle_label.text = "Current Rates:"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	market_rates_vbox.add_child(subtitle_label)

	# Add spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 4)
	market_rates_vbox.add_child(spacer2)

	# Calculate rates
	var copper_modifier = CurrencyManager.conversion_rate_modifiers[CurrencyManager.CurrencyType.COPPER]
	var silver_modifier = CurrencyManager.conversion_rate_modifiers[CurrencyManager.CurrencyType.SILVER]
	var gold_modifier = CurrencyManager.conversion_rate_modifiers[CurrencyManager.CurrencyType.GOLD]
	var platinum_modifier = CurrencyManager.conversion_rate_modifiers[CurrencyManager.CurrencyType.PLATINUM]

	var copper_per_silver = (1000.0 * silver_modifier) / copper_modifier
	var silver_per_gold = (1000.0 * gold_modifier) / silver_modifier
	var gold_per_platinum = (1000.0 * platinum_modifier) / gold_modifier

	# Add rate rows
	market_rates_vbox.add_child(_create_rate_row(copper_per_silver, CurrencyManager.CurrencyType.COPPER, CurrencyManager.CurrencyType.SILVER))
	market_rates_vbox.add_child(_create_rate_row(silver_per_gold, CurrencyManager.CurrencyType.SILVER, CurrencyManager.CurrencyType.GOLD))
	market_rates_vbox.add_child(_create_rate_row(gold_per_platinum, CurrencyManager.CurrencyType.GOLD, CurrencyManager.CurrencyType.PLATINUM))

## Create a rate row with icons
func _create_rate_row(from_amount: float, from_type: int, to_type: int) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER

	# From amount label
	var amount_label = Label.new()
	amount_label.text = "%.0f" % from_amount
	row.add_child(amount_label)

	# From currency icon
	var from_icon = TextureRect.new()
	from_icon.custom_minimum_size = Vector2(32, 32)
	from_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	from_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	from_icon.texture = load(CurrencyManager.get_currency_icon(from_type))
	row.add_child(from_icon)

	# Equals label
	var equals_label = Label.new()
	equals_label.text = " = 1 "
	row.add_child(equals_label)

	# To currency icon
	var to_icon = TextureRect.new()
	to_icon.custom_minimum_size = Vector2(32, 32)
	to_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	to_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	to_icon.texture = load(CurrencyManager.get_currency_icon(to_type))
	row.add_child(to_icon)

	return row
