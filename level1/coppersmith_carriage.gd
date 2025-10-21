extends Control

@onready var bribe_overseer_button = $HBoxContainer/RightVBox/BribeOverseerButton
@onready var overseers_office_button = $HBoxContainer/RightVBox/OverseersOfficeButton

func _ready():
	ResponsiveLayout.apply_to_scene(self)
	update_labels()

func _on_shop_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/shop.tscn")

func _on_to_blackbore_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/bar.tscn")

func _on_bribe_overseer_pressed():
	var cost = max(3, int(3 * pow(1.3, Level1Vars.overseer_lvl)))
	if Level1Vars.coins >= cost:
		Level1Vars.coins -= cost
		Level1Vars.overseer_lvl += 2
		update_labels()

func _on_overseers_office_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/overseers_office.tscn")

func update_labels():
	if bribe_overseer_button:
		bribe_overseer_button.text = "Bribe Overseer: " + str(max(3, int(3 * pow(1.3, Level1Vars.overseer_lvl))))

	# Show/hide overseer buttons based on level
	if Level1Vars.overseer_lvl >= 12:
		if bribe_overseer_button:
			bribe_overseer_button.visible = false
		if overseers_office_button:
			overseers_office_button.visible = true
	else:
		if bribe_overseer_button:
			bribe_overseer_button.visible = true
		if overseers_office_button:
			overseers_office_button.visible = false
