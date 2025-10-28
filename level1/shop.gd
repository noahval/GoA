extends Control

var break_time = 30.0
var max_break_time = 30.0

@onready var suspicion_panel = $HBoxContainer/LeftVBox/SuspicionPanel
@onready var suspicion_bar = $HBoxContainer/LeftVBox/SuspicionPanel/SuspicionBar
@onready var break_timer_bar = $HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimerBar
@onready var coins_label = $HBoxContainer/LeftVBox/CoinsPanel/CoinsLabel
@onready var shovel_button = $HBoxContainer/RightVBox/ShovelButton
@onready var plow_button = $HBoxContainer/RightVBox/PlowButton
@onready var furnace_upgrade = $HBoxContainer/RightVBox/AutoShovelButton
@onready var bribe_shopkeep_button = $HBoxContainer/RightVBox/BribeShopkeepButton
@onready var workshop_button = $HBoxContainer/RightVBox/WorkshopButton

# Cost calculation functions
func get_shovel_cost() -> int:
	return int(8 * pow(1.8, Level1Vars.shovel_lvl))

func get_plow_cost() -> int:
	return int(50 * pow(1.9, Level1Vars.plow_lvl))

func get_auto_shovel_cost() -> int:
	return int(200 * pow(1.6, Level1Vars.auto_shovel_lvl))

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

func _on_shovel_button_pressed():
	var cost = get_shovel_cost()
	if Level1Vars.coins >= cost:
		Level1Vars.coins -= cost
		Level1Vars.shovel_lvl += 1
		update_labels()

func _on_plow_button_pressed():
	var cost = get_plow_cost()
	if Level1Vars.coins >= cost:
		Level1Vars.coins -= cost
		Level1Vars.plow_lvl += 1
		update_labels()

func _on_furnace_upgrade_pressed():
	var cost = get_auto_shovel_cost()
	if Level1Vars.coins >= cost:
		Level1Vars.coins -= cost
		Level1Vars.auto_shovel_lvl += 1
		update_labels()

func _on_bribe_shopkeep_pressed():
	if Level1Vars.coins >= 10 and not Level1Vars.shopkeep_bribed:
		Level1Vars.coins -= 10
		Level1Vars.shopkeep_bribed = true
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
	if shovel_button:
		shovel_button.text = "Better Shovel: " + str(get_shovel_cost())
	if plow_button:
		plow_button.text = "Coal Plow: " + str(get_plow_cost())
	if furnace_upgrade:
		furnace_upgrade.text = "Auto Shovel: " + str(get_auto_shovel_cost())
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

	# Show/hide plow button based on shovel level
	if plow_button:
		if Level1Vars.shovel_lvl >= 5:
			plow_button.visible = true
		else:
			plow_button.visible = false

	# Show/hide auto shovel button based on shovel level
	if furnace_upgrade:
		if Level1Vars.shovel_lvl >= 2:
			furnace_upgrade.visible = true
		else:
			furnace_upgrade.visible = false

func _on_nap_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/dream.tscn")

func _on_to_coppersmith_carriage_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/coppersmith_carriage.tscn")

func update_suspicion_bar():
	suspicion_panel.visible = Level1Vars.suspicion > 0
	suspicion_bar.value = Level1Vars.suspicion
