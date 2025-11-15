extends Control

var break_time = 30.0
var max_break_time = 30.0

@onready var suspicion_panel = $HBoxContainer/LeftVBox/SuspicionPanel
@onready var suspicion_bar = $HBoxContainer/LeftVBox/SuspicionPanel/SuspicionBar
@onready var break_timer_bar = $HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimerBar
@onready var coins_panel = $HBoxContainer/LeftVBox/CoinsPanel
@onready var shovels_button = $HBoxContainer/RightVBox/ShovelsButton
@onready var auto_shovels_button = $HBoxContainer/RightVBox/AutoShovelsButton
@onready var bribe_shopkeep_button = $HBoxContainer/RightVBox/BribeShopkeepButton
@onready var workshop_button = $HBoxContainer/RightVBox/WorkshopButton
@onready var popup_container = $PopupContainer
@onready var shovels_popup = $PopupContainer/ShovelsPopup
@onready var shovel_button = $PopupContainer/ShovelsPopup/MarginContainer/VBoxContainer/ShovelButton
@onready var plow_button = $PopupContainer/ShovelsPopup/MarginContainer/VBoxContainer/PlowButton
@onready var auto_shovels_popup = $PopupContainer/AutoShovelsPopup
@onready var furnace_upgrade = $PopupContainer/AutoShovelsPopup/MarginContainer/VBoxContainer/AutoShovelButton
@onready var coal_per_tick_button = $PopupContainer/AutoShovelsPopup/MarginContainer/VBoxContainer/CoalPerTickButton
@onready var frequency_button = $PopupContainer/AutoShovelsPopup/MarginContainer/VBoxContainer/FrequencyButton

# Cost calculation functions
func get_shovel_cost() -> int:
	return int(8 * pow(1.8, Level1Vars.shovel_lvl))

func get_plow_cost() -> int:
	return int(50 * pow(1.9, Level1Vars.plow_lvl))

func get_auto_shovel_cost() -> int:
	return int(200 * pow(1.6, Level1Vars.auto_shovel_lvl))

func get_coal_per_tick_upgrade_cost() -> int:
	return int(50 * pow(1.7, Level1Vars.auto_shovel_coal_upgrade_lvl))

func get_frequency_upgrade_cost() -> int:
	return int(75 * pow(1.8, Level1Vars.auto_shovel_freq_upgrade_lvl))

# Storage capacity upgrade data and costs
const STORAGE_UPGRADE_NAMES = [
	"Belt Pouch",
	"Leather Purse",
	"Reinforced Pouch",
	"Heavy Coin Bag",
	"Merchant's Satchel",
	"Trader's Case",
	"Banker's Chest",
	"Strongbox Key",
	"Vault Access",
	"Private Vault",
	"Master Vault",
	"Noble's Treasury"
]

const STORAGE_UPGRADE_COSTS = [
	{"copper": 175},
	{"copper": 250},
	{"copper": 400},
	{"copper": 800},
	{"silver": 2},
	{"silver": 6},
	{"silver": 20},
	{"silver": 70},
	{"silver": 250},
	{"gold": 1},
	{"gold": 5},
	{"gold": 50}
]

# Coal tracking upgrade data and costs
const COAL_TRACKING_NAMES = [
	"Chalk Marks",
	"Wax Tablet",
	"Ledger Book",
	"Accounting System",
	"Master Records",
	"Overseer's Trust"
]

const COAL_TRACKING_COSTS = [
	50,
	150,
	400,
	1000,
	3000,
	8000
]

func get_storage_upgrade_cost():
	var level = Level1Vars.storage_capacity_level
	if level >= STORAGE_UPGRADE_COSTS.size():
		return null  # Max level reached
	return STORAGE_UPGRADE_COSTS[level]

func get_storage_upgrade_name() -> String:
	var level = Level1Vars.storage_capacity_level
	if level >= STORAGE_UPGRADE_NAMES.size():
		return "Max Capacity"
	return STORAGE_UPGRADE_NAMES[level]

func get_coal_tracking_cost() -> int:
	var level = Level1Vars.coal_tracking_level
	if level >= COAL_TRACKING_COSTS.size():
		return -1  # Max level reached
	return COAL_TRACKING_COSTS[level]

func get_coal_tracking_name() -> String:
	var level = Level1Vars.coal_tracking_level
	if level >= COAL_TRACKING_NAMES.size():
		return "Overseer's Trust (Max)"
	return COAL_TRACKING_NAMES[level]

func _ready():
	# Set the actual maximum break time (not the remaining time)
	max_break_time = Level1Vars.starting_break_time + Level1Vars.overseer_lvl

	if Level1Vars.break_time_remaining > 0:
		break_time = Level1Vars.break_time_remaining
	else:
		break_time = max_break_time

	# Initialize the progress bar to the current percentage
	if break_timer_bar:
		var progress_percent = (break_time / max_break_time) * 100.0
		break_timer_bar.value = progress_percent

	# Hide popup container by default (best practice from popup-system.md)
	popup_container.visible = false
	shovels_popup.visible = false
	auto_shovels_popup.visible = false

	update_labels()
	update_suspicion_bar()
	ResponsiveLayout.apply_to_scene(self)

func _process(delta):
	break_time -= delta
	Level1Vars.break_time_remaining = break_time

	# Update progress bar based on current break time
	if break_timer_bar:
		var progress_percent = (break_time / max_break_time) * 100.0
		break_timer_bar.value = progress_percent

	if break_time <= 0:
		Level1Vars.break_time_remaining = 0.0
		Global.change_scene_with_check(get_tree(), "res://level1/furnace.tscn")

	update_labels()
	update_suspicion_bar()

	# Update popup labels if popups are visible
	if shovels_popup.visible:
		update_shovels_popup_labels()
	if auto_shovels_popup.visible:
		update_auto_shovels_popup_labels()

func _on_shovel_button_pressed():
	var cost = get_shovel_cost()
	if CurrencyManager.can_afford(cost):
		if CurrencyManager.deduct_currency(cost):
			Level1Vars.shovel_lvl += 1
			UpgradeTypesConfig.track_equipment_purchase("shovel", cost)
			DebugLogger.log_shop_purchase("Shovel", cost, Level1Vars.shovel_lvl)
			update_labels()
			update_shovels_popup_labels()

func _on_plow_button_pressed():
	var cost = get_plow_cost()
	if CurrencyManager.can_afford(cost):
		if CurrencyManager.deduct_currency(cost):
			Level1Vars.plow_lvl += 1
			UpgradeTypesConfig.track_equipment_purchase("plow", cost)
			DebugLogger.log_shop_purchase("Coal Plow", cost, Level1Vars.plow_lvl)
			update_labels()
			update_shovels_popup_labels()

func _on_furnace_upgrade_pressed():
	var cost = get_auto_shovel_cost()
	if CurrencyManager.can_afford(cost):
		if CurrencyManager.deduct_currency(cost):
			Level1Vars.auto_shovel_lvl += 1
			UpgradeTypesConfig.track_equipment_purchase("auto_shovel", cost)
			DebugLogger.log_shop_purchase("Auto Shovel", cost, Level1Vars.auto_shovel_lvl)
			update_labels()
			update_auto_shovels_popup_labels()

func _on_bribe_shopkeep_pressed():
	if CurrencyManager.can_afford(10) and not Level1Vars.shopkeep_bribed:
		if CurrencyManager.deduct_currency(10):
			Level1Vars.shopkeep_bribed = true
			DebugLogger.log_shop_purchase("Bribe Shopkeep", 10, 1)
			update_labels()

func _on_workshop_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/workshop.tscn")

func _on_get_coin_button_pressed():
	CurrencyManager.add_currency(CurrencyManager.CurrencyType.COPPER, 1, "debug/cheat")
	Level1Vars.lifetimecoins += 1  # Legacy tracking (can be removed later)
	Global.show_stat_notification("developer notification: coins")
	update_labels()

func update_labels():
	# Update coins display
	_update_currency_display()

## Update currency panel with current currency values
func _update_currency_display():
	if coins_panel:
		var currency_data = CurrencyManager.format_currency_for_icons(false)
		coins_panel.setup_currency_display(currency_data)
	if bribe_shopkeep_button:
		bribe_shopkeep_button.text = "Bribe Shopkeep: 10"
		# Hide if already bribed, otherwise disable if not enough coins
		if Level1Vars.shopkeep_bribed:
			bribe_shopkeep_button.visible = false
		else:
			bribe_shopkeep_button.visible = true
			bribe_shopkeep_button.disabled = not CurrencyManager.can_afford(10)

	# Show/hide workshop button based on bribe status
	if workshop_button:
		workshop_button.visible = Level1Vars.shopkeep_bribed

func _on_nap_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/dream.tscn")

func _on_to_coppersmith_carriage_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/coppersmith_carriage.tscn")

func _on_shovels_button_pressed():
	popup_container.visible = true
	shovels_popup.visible = true
	update_shovels_popup_labels()

func _on_close_shovels_popup_pressed():
	shovels_popup.visible = false
	popup_container.visible = false

func _on_auto_shovels_button_pressed():
	popup_container.visible = true
	auto_shovels_popup.visible = true
	update_auto_shovels_popup_labels()

func _on_close_auto_shovels_popup_pressed():
	auto_shovels_popup.visible = false
	popup_container.visible = false

func _on_coal_per_tick_upgrade_pressed():
	var cost = get_coal_per_tick_upgrade_cost()
	if CurrencyManager.can_afford(cost):
		if CurrencyManager.deduct_currency(cost):
			Level1Vars.auto_shovel_coal_upgrade_lvl += 1
			Level1Vars.auto_shovel_coal_per_tick = 4.0 + (0.5 * Level1Vars.auto_shovel_coal_upgrade_lvl)
			UpgradeTypesConfig.track_equipment_purchase("coal_per_tick", cost)
			DebugLogger.log_shop_purchase("Coal Per Tick Upgrade", cost, Level1Vars.auto_shovel_coal_upgrade_lvl)
			update_labels()
			update_auto_shovels_popup_labels()

func _on_frequency_upgrade_pressed():
	var cost = get_frequency_upgrade_cost()
	if CurrencyManager.can_afford(cost):
		if CurrencyManager.deduct_currency(cost):
			Level1Vars.auto_shovel_freq_upgrade_lvl += 1
			Level1Vars.auto_shovel_freq = max(0.5, 3.0 - (0.2 * Level1Vars.auto_shovel_freq_upgrade_lvl))
			UpgradeTypesConfig.track_equipment_purchase("frequency", cost)
			DebugLogger.log_shop_purchase("Frequency Upgrade", cost, Level1Vars.auto_shovel_freq_upgrade_lvl)
			update_labels()
			update_auto_shovels_popup_labels()

func _on_storage_upgrade_pressed():
	var cost = get_storage_upgrade_cost()
	if cost == null:
		Global.show_stat_notification("Storage capacity already maxed")
		return

	if CurrencyManager.can_afford(cost):
		if CurrencyManager.deduct_currency(cost):
			Level1Vars.storage_capacity_level += 1
			var new_cap = Level1Vars.get_currency_cap()
			var upgrade_name = get_storage_upgrade_name()

			# Track equipment value (convert to copper equivalent)
			var copper_equiv = 0
			if cost.has("copper"):
				copper_equiv = cost.copper
			elif cost.has("silver"):
				copper_equiv = cost.silver * 1000
			elif cost.has("gold"):
				copper_equiv = cost.gold * 1000000

			UpgradeTypesConfig.track_equipment_purchase("storage_capacity", copper_equiv)
			DebugLogger.log_shop_purchase(upgrade_name, copper_equiv, Level1Vars.storage_capacity_level)
			Global.show_stat_notification("Currency capacity increased to " + str(new_cap))
			update_labels()

func _on_coal_tracking_upgrade_pressed():
	var cost = get_coal_tracking_cost()
	if cost < 0:
		Global.show_stat_notification("Coal tracking already maxed")
		return

	if CurrencyManager.can_afford(cost):
		if CurrencyManager.deduct_currency(cost):
			Level1Vars.coal_tracking_level += 1
			var new_cap = Level1Vars.get_coal_cap()
			var upgrade_name = get_coal_tracking_name()

			UpgradeTypesConfig.track_equipment_purchase("coal_tracking", cost)
			DebugLogger.log_shop_purchase(upgrade_name, cost, Level1Vars.coal_tracking_level)
			Global.show_stat_notification("Coal tracking capacity increased to " + str(new_cap))
			update_labels()

func update_shovels_popup_labels():
	if shovel_button:
		var cost = get_shovel_cost()
		var level_text = ""
		if Level1Vars.shovel_lvl == 0:
			level_text = "A sturdy shovel"
		elif Level1Vars.shovel_lvl < 3:
			level_text = "A reinforced shovel"
		else:
			level_text = "A masterwork shovel"
		shovel_button.text = level_text + ": " + str(cost)
		shovel_button.disabled = not CurrencyManager.can_afford(cost)
	if plow_button:
		var cost = get_plow_cost()
		var level_text = ""
		if Level1Vars.plow_lvl == 0:
			level_text = "Heavy coal plow"
		else:
			level_text = "Upgraded plow"
		plow_button.text = level_text + ": " + str(cost)
		# Show/hide plow button based on shovel level
		if Level1Vars.shovel_lvl >= 5:
			plow_button.visible = true
		else:
			plow_button.visible = false
		plow_button.disabled = not CurrencyManager.can_afford(cost)

func update_auto_shovels_popup_labels():
	if furnace_upgrade:
		var cost = get_auto_shovel_cost()
		var level_text = "Mechanical shoveler"
		if Level1Vars.auto_shovel_lvl > 0:
			level_text = "Another shoveler (" + str(Level1Vars.auto_shovel_lvl) + ")"
		furnace_upgrade.text = level_text + ": " + str(cost)
		furnace_upgrade.disabled = not CurrencyManager.can_afford(cost)
	if coal_per_tick_button:
		var cost = get_coal_per_tick_upgrade_cost()
		coal_per_tick_button.text = "Better gears: " + str(cost)
		coal_per_tick_button.disabled = not CurrencyManager.can_afford(cost)
	if frequency_button:
		var cost = get_frequency_upgrade_cost()
		frequency_button.text = "Fine-tuned clockwork: " + str(cost)
		frequency_button.disabled = not CurrencyManager.can_afford(cost)

func update_suspicion_bar():
	suspicion_panel.visible = Level1Vars.suspicion > 0
	suspicion_bar.value = Level1Vars.suspicion
