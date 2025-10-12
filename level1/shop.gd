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
	var cost = max(5, int(5 * pow(1.4, Level1Vars.overseer_lvl)))
	if Level1Vars.coins >= cost:
		Level1Vars.coins -= cost
		Level1Vars.overseer_lvl += 1
		update_labels()

func _on_bribe_barkeep_pressed():
	if Level1Vars.coins >= 10 and not Level1Vars.barkeep_bribed:
		Level1Vars.coins -= 10
		Level1Vars.barkeep_bribed = true
		update_labels()

func _on_secret_passage_pressed():
	get_tree().change_scene_to_file("res://level1/secret_passage_entrance.tscn")

func _on_get_coin_button_pressed():
	Level1Vars.coins += 1
	update_labels()

func update_labels():
	$HBoxContainer/LeftVBox/CoinsPanel/CoinsLabel.text = "Coins: " + str(int(Level1Vars.coins))
	$HBoxContainer/RightVBox/ShovelButton.text = "Better Shovel: " + str(max(1, int(1 * pow(1.5, Level1Vars.shovel_lvl))))
	$HBoxContainer/RightVBox/PlowButton.text = "Coal Plow: " + str(max(Level1Vars.plow_lvl + 5, int(5 * pow(1.5, Level1Vars.plow_lvl))))
	$HBoxContainer/RightVBox/FurnaceUpgrade.text = "Auto Shovel: " + str(max(Level1Vars.auto_shovel_lvl + 10, int(10 * pow(1.15, Level1Vars.auto_shovel_lvl))))
	$HBoxContainer/RightVBox/BribeOverseerButton.text = "Bribe Overseer: " + str(max(5, int(5 * pow(1.4, Level1Vars.overseer_lvl))))
	$HBoxContainer/RightVBox/BribeBarkeepButton.text = "Bribe Barkeep: 10"

	# Show/hide barkeep and secret passage buttons
	if Level1Vars.barkeep_bribed:
		$HBoxContainer/RightVBox/BribeBarkeepButton.visible = false
		$HBoxContainer/RightVBox/SecretPassageButton.visible = true
	else:
		$HBoxContainer/RightVBox/BribeBarkeepButton.visible = true
		$HBoxContainer/RightVBox/SecretPassageButton.visible = false

func _on_nap_button_pressed():
	get_tree().change_scene_to_file("res://level1/dream.tscn")

func _on_furnace_button_pressed():
	get_tree().change_scene_to_file("res://level1/furnace.tscn")
