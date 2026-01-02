extends Control

@onready var coal_delivered_label: Label = $AspectContainer/MainContainer/mainarea/PlayArea/StatsPanel/VBoxContainer/CoalDeliveredLabel
@onready var coal_dropped_label: Label = $AspectContainer/MainContainer/mainarea/PlayArea/StatsPanel/VBoxContainer/CoalDroppedLabel
@onready var pay_label: Label = $AspectContainer/MainContainer/mainarea/PlayArea/StatsPanel/VBoxContainer/PayLabel
@onready var dorm_button: Button = $AspectContainer/MainContainer/mainarea/Menu/DormButton

var pay_amount: int = 0

func _ready():
	# Apply responsive layout (handles background auto-loading, font scaling)
	ResponsiveLayout.apply_to_scene(self)

	# Player is hungry after a day's work
	Level1Vars.hungry = true
	Level1Vars.hunger_changed.emit(true)

	# Calculate pay from run stats
	pay_amount = Level1Vars.calculate_pay()

	# Award pay to player
	Level1Vars.award_pay(pay_amount)

	# Update UI labels
	update_stats_display()

	# Connect navigation
	dorm_button.pressed.connect(_on_dorm_button_pressed)

func update_stats_display():
	# Display raw stats only - keep pay calculation mysterious
	coal_delivered_label.text = "Coal Delivered: %d" % Level1Vars.coal_delivered
	coal_dropped_label.text = "Coal Dropped: %d" % Level1Vars.coal_dropped

	# Just show final pay amount - no formula explanation
	pay_label.text = "Pay: %d copper" % pay_amount

func _on_dorm_button_pressed():
	# Stats will be reset when furnace scene starts next run
	# NOT reset here - dorm scene may want to display last run stats

	# Transition to dorm scene
	get_tree().change_scene_to_file("res://level1/dorm.tscn")
