extends Control

var break_time = 30.0
var max_break_time = 30.0

@onready var anthracite_delight_button = $HBoxContainer/RightVBox/AnthraciteDelightButton
@onready var bribe_barkeep_button = $HBoxContainer/RightVBox/BribeBarkeepButton
@onready var secret_passage_button = $HBoxContainer/RightVBox/SecretPassageButton
@onready var developer_free_coins_button = $HBoxContainer/RightVBox/DeveloperFreeCoinsButton
@onready var break_timer_bar = $HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimerBar
@onready var break_timer_label = $HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimer
@onready var coins_label = $HBoxContainer/LeftVBox/CoinsPanel/CoinsLabel

func _ready():
	# Set the actual maximum break time
	max_break_time = Level1Vars.starting_break_time + Level1Vars.overseer_lvl

	if Level1Vars.break_time_remaining > 0:
		break_time = Level1Vars.break_time_remaining
	else:
		break_time = max_break_time

	# Initialize the progress bar
	if break_timer_bar:
		var progress_percent = (break_time / max_break_time) * 100.0
		break_timer_bar.value = progress_percent

	ResponsiveLayout.apply_to_scene(self)
	update_labels()

func _process(delta):
	break_time -= delta
	Level1Vars.break_time_remaining = break_time

	# Update progress bar
	if break_timer_bar:
		var progress_percent = (break_time / max_break_time) * 100.0
		break_timer_bar.value = progress_percent

	# Update timer label
	if break_timer_label:
		break_timer_label.text = "Break Timer"

	if break_time <= 0:
		Level1Vars.break_time_remaining = 0.0
		Global.change_scene_with_check(get_tree(), "res://level1/furnace.tscn")

func _on_to_blackbore_furnace_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/furnace.tscn")

func _on_to_coppersmith_carriage_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/coppersmith_carriage.tscn")

func _on_bribe_barkeep_pressed():
	if Level1Vars.coins >= 10 and not Level1Vars.barkeep_bribed:
		Level1Vars.coins -= 10
		Level1Vars.barkeep_bribed = true
		update_labels()

func _on_secret_passage_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/secret_passage_entrance.tscn")

func _on_anthracite_delight_pressed():
	if Level1Vars.coins >= 1:
		Level1Vars.coins -= 1
		Level1Vars.stimulated_remaining += 60
		Level1Vars.shown_tired_notification = false  # Reset the flag for next time
		Global.show_stat_notification("You feel invigorated")
		update_labels()

func _on_developer_free_coins_button_pressed():
	Level1Vars.coins += 10
	update_labels()

func update_labels():
	# Update coins display
	if coins_label:
		coins_label.text = "Coins: " + str(int(Level1Vars.coins))

	if bribe_barkeep_button:
		bribe_barkeep_button.text = "Bribe Barkeep: 10"

	# Show/hide developer button based on dev_speed_mode
	if developer_free_coins_button:
		developer_free_coins_button.visible = Global.dev_speed_mode

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
