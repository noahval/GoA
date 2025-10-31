extends Control

var break_time = 30.0
var max_break_time = 30.0

@onready var suspicion_panel = $HBoxContainer/LeftVBox/SuspicionPanel
@onready var suspicion_bar = $HBoxContainer/LeftVBox/SuspicionPanel/SuspicionBar
@onready var break_timer_bar = $HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimerBar
@onready var coins_label = $HBoxContainer/LeftVBox/CoinsPanel/CoinsLabel
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
	if Level1Vars.coins >= cost:
		DebugLogger.log_resource_change("coins", Level1Vars.coins, Level1Vars.coins - cost, "Shovel purchase")
		Level1Vars.coins -= cost
		Level1Vars.shovel_lvl += 1
		DebugLogger.log_shop_purchase("Shovel", cost, Level1Vars.shovel_lvl)
		update_labels()
		update_shovels_popup_labels()

func _on_plow_button_pressed():
	var cost = get_plow_cost()
	if Level1Vars.coins >= cost:
		DebugLogger.log_resource_change("coins", Level1Vars.coins, Level1Vars.coins - cost, "Plow purchase")
		Level1Vars.coins -= cost
		Level1Vars.plow_lvl += 1
		DebugLogger.log_shop_purchase("Coal Plow", cost, Level1Vars.plow_lvl)
		update_labels()
		update_shovels_popup_labels()

func _on_furnace_upgrade_pressed():
	var cost = get_auto_shovel_cost()
	if Level1Vars.coins >= cost:
		DebugLogger.log_resource_change("coins", Level1Vars.coins, Level1Vars.coins - cost, "Auto Shovel purchase")
		Level1Vars.coins -= cost
		Level1Vars.auto_shovel_lvl += 1
		DebugLogger.log_shop_purchase("Auto Shovel", cost, Level1Vars.auto_shovel_lvl)
		update_labels()
		update_auto_shovels_popup_labels()

func _on_bribe_shopkeep_pressed():
	if Level1Vars.coins >= 10 and not Level1Vars.shopkeep_bribed:
		DebugLogger.log_resource_change("coins", Level1Vars.coins, Level1Vars.coins - 10, "Bribe Shopkeep")
		Level1Vars.coins -= 10
		Level1Vars.shopkeep_bribed = true
		DebugLogger.log_shop_purchase("Bribe Shopkeep", 10, 1)
		update_labels()

func _on_workshop_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/workshop.tscn")

func _on_get_coin_button_pressed():
	Level1Vars.coins += 1
	Global.show_stat_notification("developer notification: coins")
	update_labels()

func update_labels():
	if coins_label:
		coins_label.text = "Coins: " + str(int(Level1Vars.coins))
	if bribe_shopkeep_button:
		bribe_shopkeep_button.text = "Bribe Shopkeep: 10"
		# Hide if already bribed, otherwise disable if not enough coins
		if Level1Vars.shopkeep_bribed:
			bribe_shopkeep_button.visible = false
		else:
			bribe_shopkeep_button.visible = true
			bribe_shopkeep_button.disabled = Level1Vars.coins < 10

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
	if Level1Vars.coins >= cost:
		DebugLogger.log_resource_change("coins", Level1Vars.coins, Level1Vars.coins - cost, "Coal per tick upgrade")
		Level1Vars.coins -= cost
		Level1Vars.auto_shovel_coal_upgrade_lvl += 1
		Level1Vars.auto_shovel_coal_per_tick = 4.0 + (0.5 * Level1Vars.auto_shovel_coal_upgrade_lvl)
		DebugLogger.log_shop_purchase("Coal Per Tick Upgrade", cost, Level1Vars.auto_shovel_coal_upgrade_lvl)
		update_labels()
		update_auto_shovels_popup_labels()

func _on_frequency_upgrade_pressed():
	var cost = get_frequency_upgrade_cost()
	if Level1Vars.coins >= cost:
		DebugLogger.log_resource_change("coins", Level1Vars.coins, Level1Vars.coins - cost, "Frequency upgrade")
		Level1Vars.coins -= cost
		Level1Vars.auto_shovel_freq_upgrade_lvl += 1
		Level1Vars.auto_shovel_freq = max(0.5, 3.0 - (0.2 * Level1Vars.auto_shovel_freq_upgrade_lvl))
		DebugLogger.log_shop_purchase("Frequency Upgrade", cost, Level1Vars.auto_shovel_freq_upgrade_lvl)
		update_labels()
		update_auto_shovels_popup_labels()

func update_shovels_popup_labels():
	if shovel_button:
		var cost = get_shovel_cost()
		shovel_button.text = "Better Shovel: " + str(cost)
		shovel_button.disabled = Level1Vars.coins < cost
	if plow_button:
		var cost = get_plow_cost()
		plow_button.text = "Coal Plow: " + str(cost)
		# Show/hide plow button based on shovel level
		if Level1Vars.shovel_lvl >= 5:
			plow_button.visible = true
		else:
			plow_button.visible = false
		plow_button.disabled = Level1Vars.coins < cost

func update_auto_shovels_popup_labels():
	if furnace_upgrade:
		var cost = get_auto_shovel_cost()
		furnace_upgrade.text = "Buy Auto Shovel (" + str(Level1Vars.auto_shovel_lvl) + "): " + str(cost)
		furnace_upgrade.disabled = Level1Vars.coins < cost
	if coal_per_tick_button:
		var cost = get_coal_per_tick_upgrade_cost()
		coal_per_tick_button.text = "Enhance Scoop: " + str(cost)
		coal_per_tick_button.disabled = Level1Vars.coins < cost
	if frequency_button:
		var cost = get_frequency_upgrade_cost()
		frequency_button.text = "Tune Clockwork: " + str(cost)
		frequency_button.disabled = Level1Vars.coins < cost

func update_suspicion_bar():
	suspicion_panel.visible = Level1Vars.suspicion > 0
	suspicion_bar.value = Level1Vars.suspicion
