extends Node

# Stats with setters to detect changes
var strength = 1:
	set(value):
		if is_node_ready() and floor(value) > floor(strength):
			show_stat_notification("You feel stronger")
		strength = value

var constitution = 1:
	set(value):
		if is_node_ready() and floor(value) > floor(constitution):
			show_stat_notification("You feel more resilient")
		constitution = value

var dexterity = 1:
	set(value):
		if is_node_ready() and floor(value) > floor(dexterity):
			show_stat_notification("You feel more precise")
		dexterity = value

var wisdom = 1:
	set(value):
		if is_node_ready() and floor(value) > floor(wisdom):
			show_stat_notification("You feel more introspective")
		wisdom = value

var intelligence = 1:
	set(value):
		if is_node_ready() and floor(value) > floor(intelligence):
			show_stat_notification("You feel smarter")
		intelligence = value

var charisma = 1:
	set(value):
		if is_node_ready() and floor(value) > floor(charisma):
			show_stat_notification("You feel you understand people more")
		charisma = value

# Notification UI
var notification_label: Label = null
var notification_timer: Timer = null

func _ready():
	# Create notification label
	notification_label = Label.new()
	notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	notification_label.add_theme_font_size_override("font_size", 24)
	notification_label.modulate = Color(1, 1, 0.7, 0)  # Yellowish, initially invisible
	notification_label.z_index = 100  # Make sure it's on top

	# Position at bottom of screen
	notification_label.anchor_left = 0
	notification_label.anchor_right = 1
	notification_label.anchor_top = 1
	notification_label.anchor_bottom = 1
	notification_label.offset_top = -80
	notification_label.offset_bottom = -40

	# Create timer for hiding notification
	notification_timer = Timer.new()
	notification_timer.one_shot = true
	notification_timer.timeout.connect(_on_notification_timeout)
	add_child(notification_timer)

	# Add label to the current scene tree
	add_child(notification_label)

func show_stat_notification(message: String):
	if notification_label == null:
		return

	notification_label.text = message
	notification_label.modulate.a = 1.0  # Make visible

	# Restart timer
	if notification_timer.is_stopped():
		notification_timer.start(3.0)
	else:
		notification_timer.stop()
		notification_timer.start(3.0)

func _on_notification_timeout():
	if notification_label:
		notification_label.modulate.a = 0.0  # Make invisible
