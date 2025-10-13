extends Control

var click_count = 0
@onready var coal_label = $HBoxContainer/LeftVBox/CoalLabel
@onready var coins_label = $HBoxContainer/LeftVBox/CoinsLabel
@onready var shop_button = $HBoxContainer/RightVBox/ShopButton
@onready var stamina_bar = $HBoxContainer/LeftVBox/StaminaPanel/StaminaBar

func _ready():
	coal_label.text = "Coal Shoveled: " + str(Level1Vars.coal)
	coins_label.text = "Coins: " + str(int(Level1Vars.coins))
	update_stamina_bar()

func _process(delta):
	if Level1Vars.auto_shovel_lvl > 0:
		Level1Vars.coal += Level1Vars.auto_shovel_lvl * delta

	# Check if coal reaches coin_cost threshold
	if Level1Vars.coal >= Level1Vars.coin_cost:
		Level1Vars.coal = 0.0
		Level1Vars.coins += 1.0
		Level1Vars.coin_cost += 1.0

	coal_label.text = "Coal Shoveled: " + str(int(Level1Vars.coal))
	coins_label.text = "Coins: " + str(int(Level1Vars.coins))

func _on_shovel_coal_button_pressed():
	# Reduce stamina by 1
	Level1Vars.stamina -= 1
	update_stamina_bar()

	# Check if stamina is depleted
	if Level1Vars.stamina <= 0:
		get_tree().change_scene_to_file("res://level1/dream.tscn")
		return

	# Increase global strength
	Global.strength += 0.003

	var coal_gained = 1 + Level1Vars.shovel_lvl + (Level1Vars.plow_lvl * 5)
	Level1Vars.coal += coal_gained

	# 3% chance per strength point to get a second coal
	var bonus_coal_chance = Global.strength * 0.03
	if randf() < bonus_coal_chance:
		Level1Vars.coal += coal_gained

	# Check if coal reaches coin_cost threshold
	if Level1Vars.coal >= Level1Vars.coin_cost:
		Level1Vars.coal = 0.0
		Level1Vars.coins += 1.0
		Level1Vars.coin_cost += 1.0

	coal_label.text = "Coal Shoveled: " + str(int(Level1Vars.coal))
	click_count += 1
	if click_count >= 20:
		shop_button.visible = true

func _on_shop_button_pressed():
	get_tree().change_scene_to_file("res://level1/shop.tscn")

func update_stamina_bar():
	var stamina_percent = (Level1Vars.stamina / Level1Vars.max_stamina) * 100.0
	stamina_bar.value = stamina_percent
