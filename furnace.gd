extends Control

var click_count = 0
@onready var coal_label = $VBoxContainer/CoalLabel
@onready var coins_label = $VBoxContainer/CoinsLabel
@onready var shop_button = $VBoxContainer/ShopButton

func _ready():
	coal_label.text = "Coal Shoveled: " + str(Level1Vars.coal)
	coins_label.text = "Coins: " + str(int(Level1Vars.coins))

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

func _on_mine_button_pressed():
	Level1Vars.coal += 1 + Level1Vars.shovel_lvl + (Level1Vars.plow_lvl * 5)

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
	get_tree().change_scene_to_file("res://shop.tscn")
