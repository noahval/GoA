extends Control

@onready var break_timer_bar = $HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimerBar
@onready var suspicion_bar = $HBoxContainer/LeftVBox/SuspicionPanel/SuspicionBar
@onready var stolen_coal_label = $HBoxContainer/LeftVBox/StolenCoalPanel/StolenCoalLabel

func _ready():
	update_ui()
	ResponsiveLayout.apply_to_scene(self)

func _process(_delta):
	# Update break timer display
	update_break_timer()

	# Update suspicion display
	update_suspicion()

func update_ui():
	stolen_coal_label.text = "Stolen Coal: " + str(Level1Vars.stolen_coal)

func update_break_timer():
	if Level1Vars.starting_break_time > 0:
		var percent = (Level1Vars.break_time_remaining / Level1Vars.starting_break_time) * 100.0
		break_timer_bar.value = percent

func update_suspicion():
	suspicion_bar.value = Level1Vars.suspicion

func _on_to_furnace_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/furnace.tscn")

func _on_steal_coal_button_pressed():
	if Level1Vars.break_time_remaining <= 0:
		Global.show_stat_notification("Break time is over! Can't steal coal.")
		return

	# Steal coal - add to Level1Vars
	Level1Vars.stolen_coal += 1

	# Increase suspicion
	Level1Vars.suspicion += 15

	# Update UI
	update_ui()

	# Show notification
	Global.show_stat_notification("Stole 1 coal! Suspicion: " + str(Level1Vars.suspicion))

	# Check if caught
	if Level1Vars.suspicion >= 100:
		Global.show_stat_notification("CAUGHT! Suspicion too high!")
