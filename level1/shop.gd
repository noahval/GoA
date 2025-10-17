extends Control

var break_time = 30.0
var max_break_time = 30.0

@onready var suspicion_panel = $HBoxContainer/LeftVBox/SuspicionPanel
@onready var suspicion_bar = $HBoxContainer/LeftVBox/SuspicionPanel/SuspicionBar

func _ready():
	# Set the actual maximum break time (not the remaining time)
	max_break_time = Level1Vars.starting_break_time + Level1Vars.overseer_lvl

	if Level1Vars.break_time_remaining > 0:
		break_time = Level1Vars.break_time_remaining
	else:
		break_time = max_break_time

	# Initialize the progress bar to the current percentage
	var progress_percent = (break_time / max_break_time) * 100.0
	$HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimerBar.value = progress_percent

	update_labels()
	update_suspicion_bar()
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

	# Update progress bar based on current break time
	var progress_percent = (break_time / max_break_time) * 100.0
	$HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimerBar.value = progress_percent

	if break_time <= 0:
		Level1Vars.break_time_remaining = 0.0
		Global.change_scene_with_check(get_tree(), "res://level1/furnace.tscn")

	update_labels()
	update_suspicion_bar()

func _on_shovel_button_pressed():
	var cost = max(1, int(1 * pow(1.5, Level1Vars.shovel_lvl)))
	if Level1Vars.coins >= cost:
		Level1Vars.coins -= cost
		Level1Vars.shovel_lvl += 1
		update_labels()

func _on_plow_button_pressed():
	var cost = max(Level1Vars.plow_lvl + 5, int(5 * pow(1.5, Level1Vars.plow_lvl)))
	if Level1Vars.coins >= cost:
		Level1Vars.coins -= cost
		Level1Vars.plow_lvl += 1
		update_labels()

func _on_furnace_upgrade_pressed():
	var cost = max(Level1Vars.auto_shovel_lvl + 10, int(10 * pow(1.15, Level1Vars.auto_shovel_lvl)))
	if Level1Vars.coins >= cost:
		Level1Vars.coins -= cost
		Level1Vars.auto_shovel_lvl += 1
		update_labels()

func _on_bribe_overseer_pressed():
	var cost = max(3, int(3 * pow(1.3, Level1Vars.overseer_lvl)))
	if Level1Vars.coins >= cost:
		Level1Vars.coins -= cost
		Level1Vars.overseer_lvl += 2
		update_labels()

func _on_overseers_office_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/overseers_office.tscn")

func _on_bribe_barkeep_pressed():
	if Level1Vars.coins >= 10 and not Level1Vars.barkeep_bribed:
		Level1Vars.coins -= 10
		Level1Vars.barkeep_bribed = true
		update_labels()

func _on_secret_passage_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/secret_passage_entrance.tscn")

func _on_get_coin_button_pressed():
	Level1Vars.coins += 1
	Global.show_stat_notification("developer notification: coins")
	update_labels()

func _on_developer_free_coins_button_pressed():
	Level1Vars.coins += 10
	update_labels()

func update_labels():
	$HBoxContainer/LeftVBox/CoinsPanel/CoinsLabel.text = "Coins: " + str(int(Level1Vars.coins))
	$HBoxContainer/RightVBox/ShovelButton.text = "Better Shovel: " + str(max(1, int(1 * pow(1.5, Level1Vars.shovel_lvl))))
	$HBoxContainer/RightVBox/PlowButton.text = "Coal Plow: " + str(max(Level1Vars.plow_lvl + 5, int(5 * pow(1.5, Level1Vars.plow_lvl))))
	$HBoxContainer/RightVBox/FurnaceUpgrade.text = "Auto Shovel: " + str(max(Level1Vars.auto_shovel_lvl + 10, int(10 * pow(1.15, Level1Vars.auto_shovel_lvl))))
	$HBoxContainer/RightVBox/BribeOverseerButton.text = "Bribe Overseer: " + str(max(3, int(3 * pow(1.3, Level1Vars.overseer_lvl))))
	$HBoxContainer/RightVBox/BribeBarkeepButton.text = "Bribe Barkeep: 10"

	# Show/hide barkeep and secret passage buttons
	if Level1Vars.barkeep_bribed:
		$HBoxContainer/RightVBox/BribeBarkeepButton.visible = false
		$HBoxContainer/RightVBox/SecretPassageButton.visible = true
	else:
		$HBoxContainer/RightVBox/BribeBarkeepButton.visible = true
		$HBoxContainer/RightVBox/SecretPassageButton.visible = false

	# Show/hide overseer buttons based on level
	if Level1Vars.overseer_lvl >= 12:
		$HBoxContainer/RightVBox/BribeOverseerButton.visible = false
		$HBoxContainer/RightVBox/OverseersOfficeButton.visible = true
	else:
		$HBoxContainer/RightVBox/BribeOverseerButton.visible = true
		$HBoxContainer/RightVBox/OverseersOfficeButton.visible = false

func _on_nap_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/dream.tscn")

func _on_furnace_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/furnace.tscn")

func update_suspicion_bar():
	suspicion_panel.visible = Level1Vars.suspicion > 0
	suspicion_bar.value = Level1Vars.suspicion
