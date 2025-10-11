extends Control

@onready var stamina_bar = $HBoxContainer/LeftVBox/StaminaContainer/StaminaBarBackground/StaminaBar
var stamina_timer = 0.0

func _ready():
	update_stamina_bar()

func _process(delta):
	# Increase stamina by 1 every second
	stamina_timer += delta
	if stamina_timer >= 1.0:
		stamina_timer -= 1.0
		if Level1Vars.stamina < Level1Vars.max_stamina:
			Level1Vars.stamina += 1
			update_stamina_bar()

	# Return to furnace when stamina is full
	if Level1Vars.stamina >= Level1Vars.max_stamina:
		get_tree().change_scene_to_file("res://level1/furnace.tscn")

func update_stamina_bar():
	var stamina_percent = Level1Vars.stamina / Level1Vars.max_stamina
	stamina_bar.scale.x = stamina_percent

func _on_willpower_button_pressed():
	# Add willpower dream functionality here
	pass

func _on_back_button_pressed():
	# Increase stamina by 3
	if Level1Vars.stamina < Level1Vars.max_stamina:
		Level1Vars.stamina = min(Level1Vars.stamina + 3, Level1Vars.max_stamina)
		update_stamina_bar()
