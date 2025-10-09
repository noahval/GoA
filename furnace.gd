extends Control

var click_count = 0
@onready var coal_label = $VBoxContainer/CoalLabel
@onready var shop_button = $VBoxContainer/ShopButton

func _ready():
	coal_label.text = "Coal Shoveled: " + str(Global.coal)

func _process(delta):
	if Global.furnace_lvl > 0:
		Global.coal += Global.furnace_lvl * delta
		coal_label.text = "Coal Shoveled: " + str(int(Global.coal))

func _on_mine_button_pressed():
	Global.coal += 1 + Global.shovel_lvl + (Global.cart_lvl * 5)
	coal_label.text = "Coal Shoveled: " + str(int(Global.coal))
	click_count += 1
	if click_count >= 20:
		shop_button.visible = true

func _on_shovel_1000_button_pressed():
	Global.coal += 1000
	coal_label.text = "Coal Shoveled: " + str(int(Global.coal))

func _on_shop_button_pressed():
	get_tree().change_scene_to_file("res://shop.tscn")
