extends Node

var dev_speed_mode = false

# ===== VICTORY CONDITION CONFIGURATION =====
# Configure these values to change when the player wins
var victory_conditions = {
	"stolen_coal": 3,
	"stolen_writs": 3,
	"mechanisms": 3
}

# ===== PRESTIGE SYSTEM CONFIGURATION =====
# Reputation points (spendable currency)
var reputation_points: int = 0
# Total reputation earned over all prestiges (affects cost scaling)
var lifetime_reputation_earned: int = 0
# Dictionary of owned reputation upgrades (upgrade_id: true)
var reputation_upgrades: Dictionary = {}

# Prestige conversion formula constants
const REPUTATION_BASE_COST = 1000
const REPUTATION_SCALING = 1.6

# 16-node skill tree with forking paths and convergence nodes
const REPUTATION_UPGRADES = {
	# TIER 1 - Entry Points (Cost 1)
	"skill_a1": {
		"name": "Skill A1",
		"cost": 1,
		"description": "[Placeholder: Combat/Click focus upgrade]",
		"prerequisites": []
	},
	"skill_b1": {
		"name": "Skill B1",
		"cost": 1,
		"description": "[Placeholder: Economy/Coins focus upgrade]",
		"prerequisites": []
	},
	"skill_c1": {
		"name": "Skill C1",
		"cost": 1,
		"description": "[Placeholder: Production/Auto focus upgrade]",
		"prerequisites": []
	},

	# TIER 2 (Cost 2-3)
	"skill_a2": {
		"name": "Skill A2",
		"cost": 2,
		"description": "[Placeholder upgrade]",
		"prerequisites": ["skill_a1"]
	},
	"skill_b2": {
		"name": "Skill B2",
		"cost": 2,
		"description": "[Placeholder upgrade]",
		"prerequisites": ["skill_b1"]
	},
	"skill_c2": {
		"name": "Skill C2",
		"cost": 2,
		"description": "[Placeholder upgrade]",
		"prerequisites": ["skill_c1"]
	},
	"skill_ab2": {
		"name": "Skill AB2",
		"cost": 3,
		"description": "[Placeholder: Convergence skill]",
		"prerequisites": ["skill_a1", "skill_b1"],
		"prerequisite_mode": "any"  # OR logic - needs at least one
	},

	# TIER 3 (Cost 4-6)
	"skill_a3": {
		"name": "Skill A3",
		"cost": 4,
		"description": "[Placeholder upgrade]",
		"prerequisites": ["skill_a2"]
	},
	"skill_b3": {
		"name": "Skill B3",
		"cost": 4,
		"description": "[Placeholder upgrade]",
		"prerequisites": ["skill_b2"]
	},
	"skill_c3": {
		"name": "Skill C3",
		"cost": 5,
		"description": "[Placeholder: Multi-path skill]",
		"prerequisites": ["skill_c2", "skill_ab2"]  # AND logic - needs both
	},
	"skill_abc3": {
		"name": "Skill ABC3",
		"cost": 6,
		"description": "[Placeholder: Convergence skill]",
		"prerequisites": ["skill_ab2", "skill_c2"]  # AND logic
	},

	# TIER 4 (Cost 7-9)
	"skill_a4": {
		"name": "Skill A4",
		"cost": 7,
		"description": "[Placeholder: Fork convergence skill]",
		"prerequisites": ["skill_a3", "skill_b3"],
		"prerequisite_mode": "any"  # OR logic
	},
	"skill_b4": {
		"name": "Skill B4",
		"cost": 8,
		"description": "[Placeholder: Multi-path skill]",
		"prerequisites": ["skill_b3", "skill_c3"]  # AND logic
	},
	"skill_c4": {
		"name": "Skill C4",
		"cost": 9,
		"description": "[Placeholder: Multi-path skill]",
		"prerequisites": ["skill_a3", "skill_abc3"]  # AND logic
	},

	# TIER 5 - Capstones (Cost 10-12)
	"skill_ultimate1": {
		"name": "Skill Ultimate 1",
		"cost": 10,
		"description": "[Placeholder: Ultimate capstone]",
		"prerequisites": ["skill_a4", "skill_b4"]  # AND logic
	},
	"skill_ultimate2": {
		"name": "Skill Ultimate 2",
		"cost": 12,
		"description": "[Placeholder: Ultimate capstone]",
		"prerequisites": ["skill_b4", "skill_c4"]  # AND logic
	}
}

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

# Add experience to a stat and handle level-ups
func add_stat_exp(stat_name: String, amount: float):
	var stat_data = _get_stat_data(stat_name)
	if not stat_data:
		return

	var old_value = get(stat_data.stat_var)
	set(stat_data.exp_var, get(stat_data.exp_var) + amount)
	_check_level_up(stat_name, get(stat_data.stat_var), get(stat_data.exp_var))
	DebugLogger.log_stat_change(stat_name, old_value, get(stat_data.stat_var), amount)

# Check if a stat should level up
func _check_level_up(stat_name: String, current_stat_value: float, current_exp: float):
	var current_level = int(current_stat_value)
	var xp_needed = get_xp_for_level(current_level + 1)

	while current_exp >= xp_needed:
		current_level += 1
		xp_needed = get_xp_for_level(current_level + 1)
		var stat_data = _get_stat_data(stat_name)
		if stat_data:
			set(stat_data.stat_var, current_level)

# Get progress toward next level (0.0 to 1.0)
func get_stat_level_progress(stat_name: String) -> float:
	var stat_data = _get_stat_data(stat_name)
	if not stat_data:
		return 0.0

	var current_level = int(get(stat_data.stat_var))
	var current_exp = get(stat_data.exp_var)
	var xp_for_current = get_xp_for_level(current_level)
	var xp_for_next = get_xp_for_level(current_level + 1)
	var xp_in_level = current_exp - xp_for_current
	var xp_needed_in_level = xp_for_next - xp_for_current

	return 1.0 if xp_needed_in_level <= 0 else clamp(xp_in_level / xp_needed_in_level, 0.0, 1.0)

# ===== END EXPERIENCE SYSTEM =====

# ===== PRESTIGE SYSTEM FUNCTIONS =====

# Get the cost for the next reputation point (based on lifetime earned)
func get_cost_for_next_reputation() -> int:
	return int(REPUTATION_BASE_COST * pow(REPUTATION_SCALING, lifetime_reputation_earned))

# Calculate how many reputation points the player would earn from current equipment value
func calculate_available_reputation() -> int:
	var equipment = Level1Vars.equipment_value
	var total_earned = 0
	var cost = get_cost_for_next_reputation()

	# Keep awarding reputation while we have enough equipment
	while equipment >= cost:
		equipment -= cost
		total_earned += 1
		# Update cost for next reputation (based on lifetime + what we're earning now)
		cost = int(REPUTATION_BASE_COST * pow(REPUTATION_SCALING, lifetime_reputation_earned + total_earned))

	return total_earned

# Get progress toward next reputation point (0.0 to 1.0)
func get_progress_to_next_reputation() -> float:
	var equipment = Level1Vars.equipment_value

	# Calculate how much equipment has been "consumed" for already-earned reputation
	var consumed_equipment = 0
	for i in range(lifetime_reputation_earned):
		consumed_equipment += int(REPUTATION_BASE_COST * pow(REPUTATION_SCALING, i))

	# Remaining equipment after accounting for previous reputation
	var equipment_since_last = equipment - consumed_equipment

	# Cost for the next reputation point
	var cost_for_next = get_cost_for_next_reputation()

	if cost_for_next <= 0:
		return 0.0

	return clamp(float(equipment_since_last) / float(cost_for_next), 0.0, 1.0)

# Execute prestige: award reputation, reset progress
func execute_prestige():
	var reputation_earned = calculate_available_reputation()

	if reputation_earned < 1:
		show_stat_notification("Not enough equipment to donate")
		return

	# Award reputation points
	reputation_points += reputation_earned
	lifetime_reputation_earned += reputation_earned

	# Reset level progress
	Level1Vars.reset_for_prestige()

	# Show notification
	show_stat_notification("Donated equipment. Earned %d Reputation" % reputation_earned)

# ===== REPUTATION UPGRADE FUNCTIONS =====

# Check if player owns a specific upgrade
func has_reputation_upgrade(upgrade_id: String) -> bool:
	return reputation_upgrades.get(upgrade_id, false)

# Check if player can purchase an upgrade (has reputation and prerequisites met)
func can_purchase_upgrade(upgrade_id: String) -> bool:
	if not upgrade_id in REPUTATION_UPGRADES:
		return false

	var upgrade = REPUTATION_UPGRADES[upgrade_id]

	# Already owned?
	if has_reputation_upgrade(upgrade_id):
		return false

	# Can afford?
	if reputation_points < upgrade.cost:
		return false

	# Prerequisites met?
	var prereq_mode = upgrade.get("prerequisite_mode", "all")  # Default to AND logic

	if prereq_mode == "any":
		# OR logic - at least one prerequisite must be met
		if upgrade.prerequisites.is_empty():
			return true

		for prereq in upgrade.prerequisites:
			if has_reputation_upgrade(prereq):
				return true  # Found at least one
		return false  # None met
	else:
		# AND logic - all prerequisites must be met
		for prereq in upgrade.prerequisites:
			if not has_reputation_upgrade(prereq):
				return false
		return true

# Purchase an upgrade
func purchase_upgrade(upgrade_id: String) -> bool:
	if not can_purchase_upgrade(upgrade_id):
		return false

	var upgrade = REPUTATION_UPGRADES[upgrade_id]
	reputation_points -= upgrade.cost
	reputation_upgrades[upgrade_id] = true
	show_stat_notification("Purchased: %s!" % upgrade.name)

	return true

# Get multiplier for a specific category (for future upgrade effects)
func get_reputation_multiplier(category: String) -> float:
	var multiplier = 1.0

	# Placeholder: Add specific upgrade effects here when finalizing skills
	# Example:
	# if has_reputation_upgrade("skill_a1"):
	#     multiplier *= 1.15

	return multiplier

# ===== END PRESTIGE SYSTEM =====

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
var active_notifications: Array = []  # Array of dictionaries with {panel: Panel, label: Label, timer: Timer, container: Node}
var whisper_timer: Timer = null
var suspicion_decrease_timer: Timer = null
var get_caught_timer: Timer = null
var autosave_timer: Timer = null

func _ready():
	# Notification system is now dynamic - panels are created on demand

	# Update TOC.md automatically
	var toc_updater = load("res://toc_updater.gd").new()
	add_child(toc_updater)

	# Create game timers
	whisper_timer = _create_timer(120.0, _on_whisper_timer_timeout)
	suspicion_decrease_timer = _create_timer(3.0, _on_suspicion_decrease_timeout)
	get_caught_timer = _create_timer(45.0, _on_get_caught_timeout)
	autosave_timer = _create_timer(30.0, _on_autosave_timeout)

func show_stat_notification(message: String):
	# Find the NotificationBar in the current scene
	var notification_container = _find_notification_bar()
	if not notification_container:
		print("Warning: No NotificationBar found in current scene")
		return

	# Create a Panel for this notification with translucent background
	var notification_panel = Panel.new()
	notification_panel.custom_minimum_size = Vector2(0, ResponsiveLayout.LANDSCAPE_ELEMENT_HEIGHT)

	# Create a StyleBoxFlat for the grey translucent background
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.15, 0.15, 0.15, 0.4)  # Dark grey with 40% opacity
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8

	# Add margins to prevent overlapping between notifications
	style_box.content_margin_top = 5
	style_box.content_margin_bottom = 5
	style_box.content_margin_left = 10
	style_box.content_margin_right = 10

	# Add expand margins to create space between notifications
	style_box.expand_margin_top = 3
	style_box.expand_margin_bottom = 3

	notification_panel.add_theme_stylebox_override("panel", style_box)

	# Create notification label with word wrap
	var notification_label = Label.new()
	notification_label.text = message
	notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	notification_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))  # White text
	notification_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# Position label to fill the panel (padding is handled by StyleBoxFlat content margins)
	notification_label.anchor_left = 0
	notification_label.anchor_right = 1
	notification_label.anchor_top = 0
	notification_label.anchor_bottom = 1
	notification_label.offset_left = 0
	notification_label.offset_right = 0
	notification_label.offset_top = 0
	notification_label.offset_bottom = 0

	# Add label as child of panel
	notification_panel.add_child(notification_label)

	# Create timer for this notification
	var notification_timer = Timer.new()
	notification_timer.one_shot = true
	notification_timer.wait_time = 1.0 + (len(message) * 0.045)  # 1 sec base + 45ms per character
	add_child(notification_timer)

	# Store notification data
	var notification_data = {
		"panel": notification_panel,
		"label": notification_label,
		"timer": notification_timer,
		"container": notification_container
	}
	active_notifications.append(notification_data)

	# Connect timer to remove this specific notification
	notification_timer.timeout.connect(func(): _remove_notification(notification_data))

	# Add panel to the notification container in the scene
	notification_container.add_child(notification_panel)

	# Apply responsive scaling if in portrait mode
	_apply_notification_scaling(notification_panel, notification_label)

	# Start the timer
	notification_timer.start()

func _find_notification_bar() -> Node:
	# Find the NotificationBar in the current scene
	# In landscape: direct child of SceneRoot
	# In portrait: child of VBoxContainer (reparented by ResponsiveLayout)
	var scene_tree = get_tree()
	if not scene_tree:
		return null

	var current_scene = scene_tree.current_scene
	if not current_scene:
		return null

	# Try landscape location first (direct child of root)
	var notification_bar = current_scene.get_node_or_null("NotificationBar")
	if notification_bar:
		return notification_bar

	# Try portrait location (reparented into VBoxContainer)
	notification_bar = current_scene.get_node_or_null("VBoxContainer/NotificationBar")
	if notification_bar:
		return notification_bar

	return null

func _apply_notification_scaling(notification_panel: Panel, notification_label: Label):
	# Check if we're in portrait mode
	var viewport = get_viewport()
	if not viewport:
		return

	var viewport_size = viewport.get_visible_rect().size
	var is_portrait = viewport_size.y > viewport_size.x

	if is_portrait:
		# Apply portrait scaling from ResponsiveLayout
		var scaled_height = ResponsiveLayout.PORTRAIT_ELEMENT_HEIGHT * ResponsiveLayout.PORTRAIT_FONT_SCALE
		notification_panel.custom_minimum_size = Vector2(0, scaled_height)

		# Scale font size
		var default_font_size = 25  # Default from theme
		notification_label.add_theme_font_size_override("font_size", int(default_font_size * ResponsiveLayout.PORTRAIT_FONT_SCALE))

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
	# Note: No need to reposition - VBoxContainer handles stacking automatically

func _process(delta):
	# Regenerate stamina at 1 per second, up to max_stamina
	if Level1Vars.stamina < Level1Vars.max_stamina:
		Level1Vars.stamina = min(Level1Vars.stamina + delta, Level1Vars.max_stamina)

	# Update talk button cooldown timer
	if Level1Vars.talk_button_cooldown > 0:
		Level1Vars.talk_button_cooldown -= delta

func _on_whisper_timer_timeout():
	DebugLogger.log_timer_event("whisper_timer", "triggered")
	# Set the whisper triggered flag
	Level1Vars.whisper_triggered = true

	# Only show whisper if heart hasn't been taken
	if not Level1Vars.heart_taken:
		show_stat_notification("A voice whispers in your mind, pleading for your help")

func _on_suspicion_decrease_timeout():
	# Decrease suspicion by 1 every 3 seconds
	if Level1Vars.suspicion > 0:
		var _old_suspicion = Level1Vars.suspicion
		Level1Vars.suspicion -= 1
		DebugLogger.log_timer_event("suspicion_decrease", "decreased", Level1Vars.suspicion)

# Check if player gets caught based on suspicion level
# Returns true if player was caught, false otherwise
func check_get_caught() -> bool:
	# Only check if suspicion is 17% or higher
	if Level1Vars.suspicion >= 17:
		# Percentage chance equal to third of suspicion level
		var caught_chance = (Level1Vars.suspicion / 100.0) / 3.0
		if randf() < caught_chance:
			# Player got caught!
			DebugLogger.warn("Player caught! Suspicion: %d" % Level1Vars.suspicion, "GET_CAUGHT")
			Level1Vars.stolen_coal = 0
			Level1Vars.suspicion = 0
			Level1Vars.coins = 0
			show_stat_notification("You've been caught, your coal and coins have been seized")
			return true
	return false

func _on_get_caught_timeout():
	check_get_caught()

func _on_autosave_timeout():
	# Save to cloud if authenticated, otherwise save locally
	if NakamaManager.is_authenticated:
		NakamaManager.save_game()
		DebugLogger.log_info("AutoSave", "Cloud game state saved")
	else:
		LocalSaveManager.save_game()
		DebugLogger.log_info("AutoSave", "Local game state saved")

# Wrapper function for changing scenes with get caught check
func change_scene_with_check(scene_tree: SceneTree, scene_path: String):
	var current_scene = scene_tree.current_scene.scene_file_path if scene_tree.current_scene else "unknown"

	# Save progress before scene change (cloud if authenticated, local if offline)
	if NakamaManager.is_authenticated:
		NakamaManager.save_game()
		DebugLogger.log_info("SceneChange", "Cloud save before scene transition")
	else:
		LocalSaveManager.save_game()
		DebugLogger.log_info("SceneChange", "Local save before scene transition")

	# Check for victory conditions first
	if check_victory_conditions():
		DebugLogger.log_scene_change(current_scene, "res://victory.tscn", "Victory conditions met")
		scene_tree.change_scene_to_file("res://victory.tscn")
		return

	# Check if player gets caught before scene change
	if not check_get_caught():
		# If not caught, proceed with scene change
		DebugLogger.log_scene_change(current_scene, scene_path, "Normal scene transition")
		scene_tree.change_scene_to_file(scene_path)

# Check if victory conditions have been met
func check_victory_conditions() -> bool:
	var current_progress = {}
	# Check all configured victory conditions
	for condition in victory_conditions:
		var required_amount = victory_conditions[condition]
		var current_amount = 0

		# Get the current value from Level1Vars
		if condition in Level1Vars:
			current_amount = Level1Vars.get(condition)

		current_progress[condition] = "%d/%d" % [current_amount, required_amount]

		# If any condition is not met, return false
		if current_amount < required_amount:
			DebugLogger.log_victory_check(false, current_progress)
			return false

	# All conditions met!
	DebugLogger.log_victory_check(true, current_progress)
	return true

# Call this after any change that might trigger victory
func check_and_trigger_victory(scene_tree: SceneTree):
	if check_victory_conditions():
		scene_tree.change_scene_to_file("res://victory.tscn")

## Helper: Get stat data for dynamic stat access
func _get_stat_data(stat_name: String) -> Dictionary:
	var stat_map = {
		"strength": {"stat_var": "strength", "exp_var": "strength_exp"},
		"constitution": {"stat_var": "constitution", "exp_var": "constitution_exp"},
		"dexterity": {"stat_var": "dexterity", "exp_var": "dexterity_exp"},
		"wisdom": {"stat_var": "wisdom", "exp_var": "wisdom_exp"},
		"intelligence": {"stat_var": "intelligence", "exp_var": "intelligence_exp"},
		"charisma": {"stat_var": "charisma", "exp_var": "charisma_exp"}
	}
	return stat_map.get(stat_name, {})

## Helper: Create a timer with callback
func _create_timer(wait_time: float, callback: Callable) -> Timer:
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.autostart = true
	timer.timeout.connect(callback)
	add_child(timer)
	return timer
