extends Control

var break_time = 30.0
var max_break_time = 30.0

func _ready():
	if Level1Vars.break_time_remaining > 0:
		break_time = Level1Vars.break_time_remaining
	else:
		break_time = Level1Vars.starting_break_time + Level1Vars.overseer_lvl
	max_break_time = break_time
	update_labels()
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
	break_time -= delta
	Level1Vars.break_time_remaining = break_time
	if break_time <= 0:
		Level1Vars.break_time_remaining = 0.0
		get_tree().change_scene_to_file("res://level1/furnace.tscn")
	else:
		$HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimer.text = "Break Timer"
		# Update progress bar
		var progress_percent = (break_time / max_break_time) * 100.0
		$HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimerBar.value = progress_percent
	update_labels()

func update_labels():
	$HBoxContainer/LeftVBox/CoinsPanel/CoinsLabel.text = "Coins: " + str(int(Level1Vars.coins))

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://level1/shop.tscn")
