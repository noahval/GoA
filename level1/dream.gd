extends Control

@onready var stamina_bar = $HBoxContainer/LeftVBox/StaminaPanel/StaminaBar
var stamina_timer = 0.0

func _ready():
	update_stamina_bar()
	apply_mobile_scaling()

func apply_mobile_scaling():
	var viewport_size = get_viewport().get_visible_rect().size
	# Check if in portrait mode (taller than wide)
	if viewport_size.y > viewport_size.x:
		# Scale up buttons for mobile
		var buttons = $HBoxContainer/RightVBox.get_children()
		for button in buttons:
			if button is Button:
				button.custom_minimum_size = Vector2(0, 60)
				if button.get("theme_override_font_sizes/font_size") == null:
					button.add_theme_font_size_override("font_size", 24)

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
	var stamina_percent = (Level1Vars.stamina / Level1Vars.max_stamina) * 100.0
	stamina_bar.value = stamina_percent

func _on_willpower_button_pressed():
	Global.add_stat_exp("constitution", 1)

func _on_back_button_pressed():
	# Increase stamina by 3
	if Level1Vars.stamina < Level1Vars.max_stamina:
		Level1Vars.stamina = min(Level1Vars.stamina + 3, Level1Vars.max_stamina)
		update_stamina_bar()
