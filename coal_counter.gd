extends Control

var coal_count: int = 0

@onready var coal_label = $VBoxContainer/CoalLabel


func _on_mine_button_pressed():
	coal_count += 1
	coal_label.text = "Coal: " + str(coal_count)
