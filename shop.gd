extends Control

var break_time = 10.0

func _ready():
	update_labels()

func _process(delta):
	break_time -= delta
	if break_time <= 0:
		get_tree().change_scene_to_file("res://furnace.tscn")
	else:
		$VBoxContainer/BreakTimer.text = "Break Timer: " + str(ceil(break_time))
	update_labels()

func _on_claim_button_pressed():
	if Global.coal >= 100:
		Global.coal = int(Global.coal) - 100
		Global.coins = int(Global.coins) + 1
		update_labels()

func _on_shovel_button_pressed():
	var cost = max(1, int(1 * pow(1.5, Global.shovel_lvl)))
	if Global.coins >= cost:
		Global.coins -= cost
		Global.shovel_lvl += 1
		update_labels()

func _on_cart_button_pressed():
	var cost = max(Global.cart_lvl + 5, int(5 * pow(1.5, Global.cart_lvl)))
	if Global.coins >= cost:
		Global.coins -= cost
		Global.cart_lvl += 1
		update_labels()

func _on_furnace_upgrade_pressed():
	var cost = max(Global.furnace_lvl + 10, int(10 * pow(1.15, Global.furnace_lvl)))
	if Global.coins >= cost:
		Global.coins -= cost
		Global.furnace_lvl += 1
		update_labels()

func update_labels():
	$VBoxContainer/CoalLabel.text = "Coal Shoveled: " + str(int(Global.coal))
	$VBoxContainer/CoinsLabel.text = "Coins: " + str(int(Global.coins))
	$VBoxContainer/ShovelButton.text = "Better Shovel (+" + str(Global.shovel_lvl + 1) + " coal) - Cost: " + str(max(1, int(1 * pow(1.5, Global.shovel_lvl))))
	$VBoxContainer/CartButton.text = "Coal Cart (+" + str((Global.cart_lvl + 1) * 5) + " coal) - Cost: " + str(max(Global.cart_lvl + 5, int(5 * pow(1.5, Global.cart_lvl))))
	$VBoxContainer/FurnaceUpgrade.text = "Auto Furnace (+" + str(Global.furnace_lvl + 1) + "/s) - Cost: " + str(max(Global.furnace_lvl + 10, int(10 * pow(1.15, Global.furnace_lvl))))

func _on_furnace_button_pressed():
	get_tree().change_scene_to_file("res://furnace.tscn")
