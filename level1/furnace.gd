extends Control

var click_count = 0
var steal_click_count = 0
@onready var left_vbox = $HBoxContainer/LeftVBox
@onready var right_vbox = $HBoxContainer/RightVBox
@onready var coal_label = $HBoxContainer/LeftVBox/CoalPanel/CoalLabel
@onready var coins_label = $HBoxContainer/LeftVBox/CoinsPanel/CoinsLabel
@onready var shop_button = $HBoxContainer/RightVBox/ShopButton
@onready var stamina_bar = $HBoxContainer/LeftVBox/StaminaPanel/StaminaBar
@onready var suspicion_panel = $HBoxContainer/LeftVBox/SuspicionPanel
@onready var suspicion_bar = $HBoxContainer/LeftVBox/SuspicionPanel/SuspicionBar
@onready var steal_coal_button = $HBoxContainer/RightVBox/StealCoalButton
@onready var take_break_button = $HBoxContainer/RightVBox/ShopButton

func _ready():
	ResponsiveLayout.apply_to_scene(self)
	coal_label.text = "Coal Shoveled: " + str(Level1Vars.coal)
	coins_label.text = "Coins: " + str(int(Level1Vars.coins))
	update_stamina_bar()
	update_suspicion_bar()

func _process(delta):
	if Level1Vars.auto_shovel_lvl > 0:
		Level1Vars.coal += Level1Vars.auto_shovel_lvl * delta

	# Decrease stimulated_remaining by 1 per second
	if Level1Vars.stimulated_remaining > 0:
		Level1Vars.stimulated_remaining -= delta
		if Level1Vars.stimulated_remaining < 0:
			Level1Vars.stimulated_remaining = 0

		# Show "tired again" notification when dropping below 2
		if Level1Vars.stimulated_remaining < 2 and not Level1Vars.shown_tired_notification:
			Global.show_stat_notification("You feel tired again")
			Level1Vars.shown_tired_notification = true

	# Decrease resilient_remaining by 1 per second
	if Level1Vars.resilient_remaining > 0:
		Level1Vars.resilient_remaining -= delta
		if Level1Vars.resilient_remaining < 0:
			Level1Vars.resilient_remaining = 0

		# Show "lazy again" notification when dropping below 2
		if Level1Vars.resilient_remaining < 2 and not Level1Vars.shown_lazy_notification:
			Global.show_stat_notification("You feel lazy again")
			Level1Vars.shown_lazy_notification = true

	# Check if coal reaches coin_cost threshold
	if Level1Vars.coal >= Level1Vars.coin_cost:
		Level1Vars.coal -= Level1Vars.coin_cost
		Level1Vars.coins += 1.0
		Level1Vars.coin_cost *= 1.05

	coal_label.text = "Coal Shoveled: " + str(int(Level1Vars.coal))
	coins_label.text = "Coins: " + str(int(Level1Vars.coins))
	update_stamina_bar()
	update_suspicion_bar()
	update_dev_buttons()

func _on_shovel_coal_button_pressed():
	# Reduce stamina (less if resilient)
	if Level1Vars.resilient_remaining > 1.0:
		Level1Vars.stamina -= 0.4
	else:
		Level1Vars.stamina -= 1
	update_stamina_bar()

	# Check if stamina is depleted
	if Level1Vars.stamina <= 0:
		Global.change_scene_with_check(get_tree(), "res://level1/dream.tscn")
		return

	# Increase global strength exp
	Global.add_stat_exp("strength", 1)

	var coal_gained = 1 + (Level1Vars.shovel_lvl * 0.7) + (Level1Vars.plow_lvl * 3)

	# Apply stimulated bonus if timer is active
	if Level1Vars.stimulated_remaining > 1.0:
		coal_gained *= 1.4

	Level1Vars.coal += coal_gained

	# 3% chance per strength point to get a second coal
	var bonus_coal_chance = Global.strength * 0.03
	if randf() < bonus_coal_chance:
		Level1Vars.coal += coal_gained

	# Check if coal reaches coin_cost threshold
	if Level1Vars.coal >= Level1Vars.coin_cost:
		Level1Vars.coal -= Level1Vars.coin_cost
		Level1Vars.coins += 1.0
		Level1Vars.coin_cost *= 1.04

	coal_label.text = "Coal Shoveled: " + str(int(Level1Vars.coal))
	click_count += 1
	if click_count >= 50:
		shop_button.visible = true

	# Count clicks for steal coal button
	if Level1Vars.heart_taken:
		steal_click_count += 1
		if steal_click_count >= 100:
			steal_coal_button.visible = true

func _on_shop_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/bar.tscn")

func _on_steal_coal_button_pressed():
	Level1Vars.stolen_coal += 1
	steal_coal_button.visible = false
	steal_click_count = 0

	# Raise suspicion by random amount (5-15) minus a third of dexterity
	var suspicion_increase = randf_range(5.0, 15.0) - (Global.dexterity / 3.0)
	Level1Vars.suspicion += max(0, suspicion_increase)  # Ensure it doesn't go negative

func update_stamina_bar():
	var stamina_percent = (Level1Vars.stamina / Level1Vars.max_stamina) * 100.0
	stamina_bar.value = stamina_percent

func update_suspicion_bar():
	suspicion_panel.visible = Level1Vars.suspicion > 0
	suspicion_bar.value = Level1Vars.suspicion

func update_dev_buttons():
	# Show/hide take break button based on dev_speed_mode
	if take_break_button:
		if Global.dev_speed_mode:
			take_break_button.visible = true
		elif click_count < 50:
			take_break_button.visible = false
