extends Node

# ===== EXPERIENCE SYSTEM CONFIGURATION =====
# Base XP needed for first level up (level 1 -> 2)
const BASE_XP_FOR_LEVEL = 100
# Scaling factor for XP growth (higher = steeper curve)
# Common values: 1.5 (gentle), 2.0 (balanced), 2.5 (steep)
const EXP_SCALING = 1.8

# Experience tracking for each stat
var strength_exp = 0.0
var constitution_exp = 0.0
var dexterity_exp = 0.0
var wisdom_exp = 0.0
var intelligence_exp = 0.0
var charisma_exp = 0.0

# Calculate XP needed for a specific level
func get_xp_for_level(level: int) -> float:
	if level <= 1:
		return 0.0
	return BASE_XP_FOR_LEVEL * pow(level - 1, EXP_SCALING)

# Add experience to a stat and handle level ups
func add_stat_exp(stat_name: String, amount: float):
	match stat_name:
		"strength":
			strength_exp += amount
			_check_level_up("strength", strength, strength_exp)
		"constitution":
			constitution_exp += amount
			_check_level_up("constitution", constitution, constitution_exp)
		"dexterity":
			dexterity_exp += amount
			_check_level_up("dexterity", dexterity, dexterity_exp)
		"wisdom":
			wisdom_exp += amount
			_check_level_up("wisdom", wisdom, wisdom_exp)
		"intelligence":
			intelligence_exp += amount
			_check_level_up("intelligence", intelligence, intelligence_exp)
		"charisma":
			charisma_exp += amount
			_check_level_up("charisma", charisma, charisma_exp)

# Check if a stat should level up
func _check_level_up(stat_name: String, current_stat_value: float, current_exp: float):
	var current_level = int(current_stat_value)
	var xp_needed = get_xp_for_level(current_level + 1)

	while current_exp >= xp_needed:
		current_level += 1
		xp_needed = get_xp_for_level(current_level + 1)

		# Update the actual stat
		match stat_name:
			"strength":
				strength = current_level
			"constitution":
				constitution = current_level
			"dexterity":
				dexterity = current_level
			"wisdom":
				wisdom = current_level
			"intelligence":
				intelligence = current_level
			"charisma":
				charisma = current_level

# Get progress toward next level (0.0 to 1.0)
func get_stat_level_progress(stat_name: String) -> float:
	var current_level: int
	var current_exp: float

	match stat_name:
		"strength":
			current_level = int(strength)
			current_exp = strength_exp
		"constitution":
			current_level = int(constitution)
			current_exp = constitution_exp
		"dexterity":
			current_level = int(dexterity)
			current_exp = dexterity_exp
		"wisdom":
			current_level = int(wisdom)
			current_exp = wisdom_exp
		"intelligence":
			current_level = int(intelligence)
			current_exp = intelligence_exp
		"charisma":
			current_level = int(charisma)
			current_exp = charisma_exp
		_:
			return 0.0

	var xp_for_current = get_xp_for_level(current_level)
	var xp_for_next = get_xp_for_level(current_level + 1)
	var xp_in_level = current_exp - xp_for_current
	var xp_needed_in_level = xp_for_next - xp_for_current

	if xp_needed_in_level <= 0:
		return 1.0

	return clamp(xp_in_level / xp_needed_in_level, 0.0, 1.0)

# ===== END EXPERIENCE SYSTEM =====

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
var active_notifications: Array = []  # Array of dictionaries with {panel: Panel, timer: Timer}
var notification_spacing: float = 10.0  # Space between stacked notifications
var whisper_timer: Timer = null
var suspicion_decrease_timer: Timer = null
var get_caught_timer: Timer = null

func _ready():
	# Notification system is now dynamic - panels are created on demand

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

	# Create timer for get_caught check (every 45 seconds)
	get_caught_timer = Timer.new()
	get_caught_timer.wait_time = 45.0
	get_caught_timer.autostart = true
	get_caught_timer.timeout.connect(_on_get_caught_timeout)
	add_child(get_caught_timer)

func show_stat_notification(message: String):
	# Create a new notification panel
	var notification_panel = Panel.new()
	notification_panel.z_index = 100

	# Create a StyleBoxFlat for the grey translucent background
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.15, 0.15, 0.15, 0.4)  # Dark grey with 40% opacity
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	notification_panel.add_theme_stylebox_override("panel", style_box)

	# Position panel at bottom center of screen using percentage-based width
	notification_panel.anchor_left = 0.1  # 10% from left
	notification_panel.anchor_right = 0.9  # 10% from right (80% width total)
	notification_panel.anchor_top = 1
	notification_panel.anchor_bottom = 1
	notification_panel.offset_left = 0
	notification_panel.offset_right = 0
	notification_panel.offset_top = -80
	notification_panel.offset_bottom = -40

	# Create notification label with word wrap
	var notification_label = Label.new()
	notification_label.text = message
	notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	notification_label.add_theme_font_size_override("font_size", 20)
	notification_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))  # White text
	notification_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notification_label.z_index = 101

	# Position label to fill the panel with padding
	notification_label.anchor_left = 0
	notification_label.anchor_right = 1
	notification_label.anchor_top = 0
	notification_label.anchor_bottom = 1
	notification_label.offset_left = 10  # Left padding
	notification_label.offset_right = -10  # Right padding
	notification_label.offset_top = 5  # Top padding
	notification_label.offset_bottom = -5  # Bottom padding

	# Add label as child of panel
	notification_panel.add_child(notification_label)

	# Create timer for this notification
	var notification_timer = Timer.new()
	notification_timer.one_shot = true
	notification_timer.wait_time = 3.0
	add_child(notification_timer)

	# Store notification data
	var notification_data = {
		"panel": notification_panel,
		"timer": notification_timer
	}
	active_notifications.append(notification_data)

	# Connect timer to remove this specific notification
	notification_timer.timeout.connect(func(): _remove_notification(notification_data))

	# Add panel to scene tree
	add_child(notification_panel)

	# Reposition all notifications to stack them
	_reposition_notifications()

	# Start the timer
	notification_timer.start()

func _remove_notification(notification_data: Dictionary):
	# Find and remove from active notifications
	var index = active_notifications.find(notification_data)
	if index != -1:
		active_notifications.remove_at(index)

	# Remove the panel and timer from scene tree
	if notification_data.panel:
		notification_data.panel.queue_free()
	if notification_data.timer:
		notification_data.timer.queue_free()

	# Reposition remaining notifications
	_reposition_notifications()

func _reposition_notifications():
	# Position notifications from bottom to top
	var base_offset_top = -80
	var notification_height = 40

	for i in range(active_notifications.size()):
		var notif_data = active_notifications[i]
		var panel = notif_data.panel

		# Calculate position - newer notifications push older ones up
		var stack_offset = i * (notification_height + notification_spacing)
		panel.offset_top = base_offset_top - stack_offset
		panel.offset_bottom = base_offset_top - stack_offset + notification_height

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

# Check if player gets caught based on suspicion level
# Returns true if player was caught, false otherwise
func check_get_caught() -> bool:
	# Only check if suspicion is 13% or higher
	if Level1Vars.suspicion >= 13:
		# Percentage chance equal to half of suspicion level
		var caught_chance = (Level1Vars.suspicion / 100.0) / 2.0
		if randf() < caught_chance:
			# Player got caught!
			Level1Vars.stolen_coal = 0
			Level1Vars.suspicion = 0
			Level1Vars.coins = 0
			show_stat_notification("You've been caught, your coal and coins have been seized")
			return true
	return false

func _on_get_caught_timeout():
	check_get_caught()

# Wrapper function for changing scenes with get caught check
func change_scene_with_check(scene_tree: SceneTree, scene_path: String):
	# Check if player gets caught before scene change
	if not check_get_caught():
		# If not caught, proceed with scene change
		scene_tree.change_scene_to_file(scene_path)
