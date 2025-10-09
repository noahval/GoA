extends Control

func _ready():
	update_labels()

func _on_claim_button_pressed():
	if Global.coal >= 100:
		Global.coal -= 100
		Global.coins += 1
		update_labels()

func update_labels():
	$VBoxContainer/CoalLabel.text = "Coal Shoveled: " + str(Global.coal)
	$VBoxContainer/CoinsLabel.text = "Coins: " + str(Global.coins)

func _on_furnace_button_pressed():
	get_tree().change_scene_to_file("res://furnace.tscn")
