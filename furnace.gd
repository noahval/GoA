extends Control

@onready var coal_label = $VBoxContainer/CoalLabel

func _on_mine_button_pressed():
	Global.coal += 1
	coal_label.text = "Coal Shoveled: " + str(Global.coal)

func _on_shop_button_pressed():
	get_tree().change_scene_to_file("res://shop.tscn")
