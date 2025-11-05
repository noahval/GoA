extends Control

var break_time = 30.0
var max_break_time = 30.0

@onready var bribe_overseer_button = $HBoxContainer/RightVBox/BribeOverseerButton
@onready var overseers_office_button = $HBoxContainer/RightVBox/OverseersOfficeButton
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

func _on_shop_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/shop.tscn")

func _on_to_blackbore_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/bar.tscn")

func _on_to_currency_converter_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/atm.tscn")

func _on_bribe_overseer_pressed():
	var cost = max(3, int(3 * pow(1.3, Level1Vars.overseer_lvl)))
	if Level1Vars.coins >= cost:
		Level1Vars.coins -= cost
		Level1Vars.overseer_lvl += 2
		Level1Vars.overseer_bribe_count += 1

		# First bribe notification
		if Level1Vars.overseer_bribe_count == 1:
			Global.show_stat_notification("Hrmph, you should know I can't be bribed, slave. Although I may turn a blind eye if you're late returning from your break.")

		# Unlock mood system after 4 bribes
		if Level1Vars.overseer_bribe_count >= 4 and not Level1Vars.mood_system_unlocked:
			Level1Vars.mood_system_unlocked = true
			Global.show_stat_notification("you're beginning to understand the overseer")

		update_labels()

func _on_overseers_office_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/overseers_office.tscn")

func update_labels():
	# Update coins display
	if coins_label:
		coins_label.text = "Coins: " + str(int(Level1Vars.coins))

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
