extends Control

var break_time = 30.0
var max_break_time = 30.0

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

func _on_to_coppersmith_carriage_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/coppersmith_carriage.tscn")

func update_labels():
	# Update coins display
	if coins_label:
		coins_label.text = CurrencyManager.format_currency_display(false, true)
