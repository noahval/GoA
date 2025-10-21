extends Control

var break_time = 30.0
var max_break_time = 30.0

@onready var suspicion_panel = $HBoxContainer/LeftVBox/SuspicionPanel
@onready var suspicion_bar = $HBoxContainer/LeftVBox/SuspicionPanel/SuspicionBar
@onready var stolen_coal_panel = $HBoxContainer/LeftVBox/StolenCoalPanel
@onready var stolen_writs_panel = $HBoxContainer/LeftVBox/StolenWritsPanel
@onready var mechanisms_panel = $HBoxContainer/LeftVBox/MechanismsPanel

func _ready():
	# CRITICAL: Apply responsive layout FIRST before accessing any UI elements
	# This ensures the scene tree is fully initialized and in the correct state
	ResponsiveLayout.apply_to_scene(self)

	# Wait one frame to ensure responsive layout has completed
	await get_tree().process_frame

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

func update_labels():
	stolen_coal_panel.visible = Level1Vars.stolen_coal > 0
	$HBoxContainer/LeftVBox/StolenCoalPanel/StolenCoalLabel.text = "Stolen Coal: " + str(Level1Vars.stolen_coal)

	stolen_writs_panel.visible = Level1Vars.stolen_writs > 0
	$HBoxContainer/LeftVBox/StolenWritsPanel/StolenWritsLabel.text = "Stolen Writs: " + str(Level1Vars.stolen_writs)

	mechanisms_panel.visible = Level1Vars.mechanisms > 0
	$HBoxContainer/LeftVBox/MechanismsPanel/MechanismsLabel.text = "Mechanisms: " + str(Level1Vars.mechanisms)

func _on_back_to_workshop_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/workshop.tscn")

func update_suspicion_bar():
	suspicion_panel.visible = Level1Vars.suspicion > 0
	suspicion_bar.value = Level1Vars.suspicion
