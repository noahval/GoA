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
var whisper_timer: Timer = null
var suspicion_decrease_timer: Timer = null
var get_caught_timer: Timer = null

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

	# Create timer for whisper notifications
	whisper_timer = Timer.new()
	whisper_timer.wait_time = 120.0  # 2 minutes
	whisper_timer.autostart = true
	whisper_timer.timeout.connect(_on_whisper_timer_timeout)
	add_child(whisper_timer)

	# Create timer for suspicion decrease (every 5 seconds)
	suspicion_decrease_timer = Timer.new()
	suspicion_decrease_timer.wait_time = 5.0
	suspicion_decrease_timer.autostart = true
	suspicion_decrease_timer.timeout.connect(_on_suspicion_decrease_timeout)
	add_child(suspicion_decrease_timer)

	# Create timer for get_caught check (every 10 seconds)
	get_caught_timer = Timer.new()
	get_caught_timer.wait_time = 10.0
	get_caught_timer.autostart = true
	get_caught_timer.timeout.connect(_on_get_caught_timeout)
	add_child(get_caught_timer)

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

func _process(delta):
	# Regenerate stamina at 1 per second, up to max_stamina
	if Level1Vars.stamina < Level1Vars.max_stamina:
		Level1Vars.stamina = min(Level1Vars.stamina + delta, Level1Vars.max_stamina)

func _on_whisper_timer_timeout():
	# Only show whisper if heart hasn't been taken
	if not Level1Vars.heart_taken:
		show_stat_notification("A voice whispers in your mind, pleading for your help")

func _on_suspicion_decrease_timeout():
	# Decrease suspicion by 1 every 5 seconds
	if Level1Vars.suspicion > 0:
		Level1Vars.suspicion -= 1

func _on_get_caught_timeout():
	# Only check if there's any suspicion
	if Level1Vars.suspicion > 0:
		# Percentage chance equal to half of suspicion level
		var caught_chance = (Level1Vars.suspicion / 100.0) / 2.0
		if randf() < caught_chance:
			# Player got caught!
			Level1Vars.stolen_coal = 0
			Level1Vars.suspicion = 0
			Level1Vars.coins = 0
			show_stat_notification("You've been caught, your coal and coins have been seized")
