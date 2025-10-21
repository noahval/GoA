extends Control

@onready var bribe_barkeep_button = $HBoxContainer/RightVBox/BribeBarkeepButton
@onready var secret_passage_button = $HBoxContainer/RightVBox/SecretPassageButton

func _ready():
	ResponsiveLayout.apply_to_scene(self)
	update_labels()

func _on_to_coppersmith_carriage_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/coppersmith_carriage.tscn")

func _on_bribe_barkeep_pressed():
	if Level1Vars.coins >= 10 and not Level1Vars.barkeep_bribed:
		Level1Vars.coins -= 10
		Level1Vars.barkeep_bribed = true
		update_labels()

func _on_secret_passage_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/secret_passage_entrance.tscn")

func update_labels():
	if bribe_barkeep_button:
		bribe_barkeep_button.text = "Bribe Barkeep: 10"

	# Show/hide barkeep and secret passage buttons
	if Level1Vars.barkeep_bribed:
		if bribe_barkeep_button:
			bribe_barkeep_button.visible = false
		if secret_passage_button:
			secret_passage_button.visible = true
	else:
		if bribe_barkeep_button:
			bribe_barkeep_button.visible = true
		if secret_passage_button:
			secret_passage_button.visible = false
