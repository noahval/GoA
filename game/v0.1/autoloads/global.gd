extends Node

# ===== VERSION MANAGEMENT =====
const GAME_VERSION = "2.0.0"  # Semantic versioning: MAJOR.MINOR.PATCH
const SAVE_VERSION = 1         # Increment when save structure changes

# ===== SIX-STAT SYSTEM =====
# Stats with setters to detect level-ups and show varied notification messages
var strength: int = 1:
	set(value):
		if is_node_ready() and value > strength:
			var message = _get_stat_message("strength")
			show_notification(message, NOTIFICATION_TYPE_STAT)
		strength = value

var dexterity: int = 1:
	set(value):
		if is_node_ready() and value > dexterity:
			var message = _get_stat_message("dexterity")
			show_notification(message, NOTIFICATION_TYPE_STAT)
		dexterity = value

var constitution: int = 1:
	set(value):
		if is_node_ready() and value > constitution:
			var message = _get_stat_message("constitution")
			show_notification(message, NOTIFICATION_TYPE_STAT)
		constitution = value

var intelligence: int = 1:
	set(value):
		if is_node_ready() and value > intelligence:
			var message = _get_stat_message("intelligence")
			show_notification(message, NOTIFICATION_TYPE_STAT)
		intelligence = value

var wisdom: int = 1:
	set(value):
		if is_node_ready() and value > wisdom:
			var message = _get_stat_message("wisdom")
			show_notification(message, NOTIFICATION_TYPE_STAT)
		wisdom = value

var charisma: int = 1:
	set(value):
		if is_node_ready() and value > charisma:
			var message = _get_stat_message("charisma")
			show_notification(message, NOTIFICATION_TYPE_STAT)
		charisma = value

# ===== EXPERIENCE SYSTEM =====
# Experience tracking per stat
var strength_exp: float = 0.0
var dexterity_exp: float = 0.0
var constitution_exp: float = 0.0
var intelligence_exp: float = 0.0
var wisdom_exp: float = 0.0
var charisma_exp: float = 0.0

# Experience curve configuration
const BASE_XP_FOR_LEVEL = 100.0
const EXP_SCALING = 1.8  # 1.5 = gentle, 2.0 = balanced, 2.5 = steep

# ===== SCENE MANAGEMENT =====
# Basic tracking (from Phase 1.3)
var current_scene_path: String = ""
var previous_scene_path: String = ""
var scene_transition_in_progress: bool = false

# Navigation tracking for settings return (Phase 1.15)
var previous_scene: String = ""

# Scene history navigation (Phase 1.8)
var scene_history: Array[String] = []
const MAX_SCENE_HISTORY = 10

# Validation framework (Phase 1.8)
var scene_validators: Array[Dictionary] = []  # {validator: Callable, priority: int, name: String}

# Async loading (Phase 1.8)
var load_progress: Array = []
var is_loading_async: bool = false

# Transition metadata (for future visual effects) (Phase 1.8)
var transition_metadata: Dictionary = {}

# Error recovery (Phase 1.8)
const FALLBACK_SCENE = "res://scenes/main_menu.tscn"  # Safe scene to load on errors
var last_successful_scene: String = ""

# Preloaded scenes cache (Phase 1.8)
var preloaded_scenes: Dictionary = {}  # {scene_path: Resource}
const MAX_PRELOADED_SCENES = 3

# ===== UI SETTINGS =====
# Note: ui_scale is now managed through save_data below (Phase 1.15)

# ===== SAVE SYSTEM (Phase 1.15) =====
# Structured save data (settings/game separation for clean reset logic)
var save_data = {
	"settings": {
		"ui_scale": 1.0,
		"music_volume": 0.8,
		"sfx_volume": 0.8,
		"dev_speed_mode": false,
	},
	"game": {
		"copper_current": 0,
		"copper_lifetime": 0,
		"strength": 1,
		"dexterity": 1,
		"constitution": 1,
		"intelligence": 1,
		"wisdom": 1,
		"charisma": 1,
		"strength_exp": 0.0,
		"dexterity_exp": 0.0,
		"constitution_exp": 0.0,
		"intelligence_exp": 0.0,
		"wisdom_exp": 0.0,
		"charisma_exp": 0.0,
	}
}

# Settings accessors (redirect to save_data for persistence)
var ui_scale: float:
	get: return save_data.settings.ui_scale
	set(value):
		save_data.settings.ui_scale = clampf(value, 0.8, 1.2)

var music_volume: float:
	get: return save_data.settings.music_volume
	set(value): save_data.settings.music_volume = clampf(value, 0.0, 1.0)

var sfx_volume: float:
	get: return save_data.settings.sfx_volume
	set(value): save_data.settings.sfx_volume = clampf(value, 0.0, 1.0)

var dev_speed_mode: bool:
	get: return save_data.settings.dev_speed_mode
	set(value): save_data.settings.dev_speed_mode = value

const SAVE_FILE_PATH = "user://save.json"

# ===== VERSION MANAGEMENT =====

func get_version_string() -> String:
	return GAME_VERSION

func get_save_version() -> int:
	return SAVE_VERSION

func is_save_compatible(save_version: int) -> bool:
	# Same save version = compatible
	# Future versions: add migration logic here
	return save_version == SAVE_VERSION

# ===== EXPERIENCE SYSTEM =====

# Calculate XP needed for a specific level
func get_xp_for_level(level: int) -> float:
	if level <= 1:
		return 0.0
	return BASE_XP_FOR_LEVEL * pow(level - 1, EXP_SCALING)

# Add experience to a stat and handle level-ups
func add_stat_exp(stat_name: String, amount: float) -> void:
	var stat_data = _get_stat_data(stat_name)
	if not stat_data:
		push_error("Invalid stat name: " + stat_name)
		return

	# Add experience
	set(stat_data.exp_var, get(stat_data.exp_var) + amount)

	# Check for level up(s)
	_check_level_up(stat_name)

# Check if stat should level up (can level multiple times)
func _check_level_up(stat_name: String) -> void:
	var stat_data = _get_stat_data(stat_name)
	if not stat_data:
		return

	var current_level = get(stat_data.stat_var)
	var current_exp = get(stat_data.exp_var)

	# Keep leveling up while we have enough XP
	while current_exp >= get_xp_for_level(current_level + 1):
		current_level += 1
		set(stat_data.stat_var, current_level)
		# Setter will trigger notification automatically

# Get progress toward next level (0.0 to 1.0)
func get_stat_level_progress(stat_name: String) -> float:
	var stat_data = _get_stat_data(stat_name)
	if not stat_data:
		return 0.0

	var current_level = get(stat_data.stat_var)
	var current_exp = get(stat_data.exp_var)
	var xp_for_current = get_xp_for_level(current_level)
	var xp_for_next = get_xp_for_level(current_level + 1)
	var xp_in_level = current_exp - xp_for_current
	var xp_needed_in_level = xp_for_next - xp_for_current

	if xp_needed_in_level <= 0:
		return 1.0

	return clamp(xp_in_level / xp_needed_in_level, 0.0, 1.0)

# Helper: Get stat variable names for dynamic access
func _get_stat_data(stat_name: String) -> Dictionary:
	var stat_map = {
		"strength": {"stat_var": "strength", "exp_var": "strength_exp"},
		"dexterity": {"stat_var": "dexterity", "exp_var": "dexterity_exp"},
		"constitution": {"stat_var": "constitution", "exp_var": "constitution_exp"},
		"intelligence": {"stat_var": "intelligence", "exp_var": "intelligence_exp"},
		"wisdom": {"stat_var": "wisdom", "exp_var": "wisdom_exp"},
		"charisma": {"stat_var": "charisma", "exp_var": "charisma_exp"}
	}
	return stat_map.get(stat_name.to_lower(), {})

# ===== SCENE MANAGEMENT (Phase 1.8 Enhanced) =====

# Change to a new scene with validation, async loading, and error recovery
func change_scene(scene_path: String, skip_validation: bool = false, transition_type: String = "default") -> void:
	# Prevent concurrent transitions
	if scene_transition_in_progress:
		push_warning("Scene transition already in progress, ignoring request")
		return

	scene_transition_in_progress = true

	# Validate scene transition (with reason tracking)
	if not skip_validation:
		var validation = can_change_to_scene(scene_path)
		if not validation.allowed:
			# Show user-friendly error message
			var block_reason = validation.reason
			if not block_reason.is_empty():
				show_notification(block_reason)
			push_warning("Scene transition blocked: " + block_reason)
			scene_transition_in_progress = false
			return

	# Get current scene for logging
	var from_scene = get_current_scene_path()

	# Save game state before transition
	_save_before_transition()

	# Store transition metadata (for future visual effects)
	transition_metadata = {
		"type": transition_type,  # "fade", "wipe", "instant", "default"
		"from": from_scene,
		"to": scene_path,
		"timestamp": Time.get_ticks_msec(),
		"skip_validation": skip_validation
	}

	# Log the transition
	DebugLogger.log_scene_change(from_scene, scene_path, "Scene transition (%s)" % transition_type)

	# Update scene history stack (before the change)
	_update_scene_history(from_scene)

	# Execute async scene change with error recovery
	await _change_scene_async(scene_path)

	# Track last successful scene
	last_successful_scene = scene_path

	# Reset flag after scene loads
	scene_transition_in_progress = false

# Helper: Save before transition
func _save_before_transition() -> void:
	if NakamaManager and NakamaManager.is_authenticated:
		NakamaManager.save_game()
		DebugLogger.log_info("SceneChange", "Cloud save before scene transition")
	elif LocalSaveManager:
		LocalSaveManager.save_game()
		DebugLogger.log_info("SceneChange", "Local save before scene transition")
	else:
		push_warning("No save manager available for pre-transition save")

# Async scene loading with error recovery
func _change_scene_async(scene_path: String) -> void:
	# Check if scene is already preloaded
	if scene_path in preloaded_scenes:
		var packed_scene = preloaded_scenes[scene_path]
		var error = get_tree().change_scene_to_packed(packed_scene)
		if error != OK:
			_handle_scene_load_error(scene_path, error)
		else:
			# Remove from cache after use
			preloaded_scenes.erase(scene_path)
		return

	# Use async loading for non-preloaded scenes
	is_loading_async = true
	var error = ResourceLoader.load_threaded_request(scene_path)

	if error != OK:
		_handle_scene_load_error(scene_path, error)
		is_loading_async = false
		return

	# Poll loading progress
	while true:
		var status = ResourceLoader.load_threaded_get_status(scene_path, load_progress)

		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				# Scene loaded successfully
				var packed_scene = ResourceLoader.load_threaded_get(scene_path)
				error = get_tree().change_scene_to_packed(packed_scene)
				if error != OK:
					_handle_scene_load_error(scene_path, error)
				break

			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				# Still loading, wait a frame
				await get_tree().process_frame

			ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				# Load failed
				_handle_scene_load_error(scene_path, ERR_FILE_CANT_OPEN)
				break

	is_loading_async = false

# Handle scene loading errors with fallback
func _handle_scene_load_error(scene_path: String, error_code: int) -> void:
	var error_msg = "Failed to load scene '%s' (error %d)" % [scene_path, error_code]
	ErrorHandler.log_error(error_msg)
	push_error(error_msg)

	# Show user-friendly error
	show_notification("Failed to load scene. Returning to safe location...")

	# Try to load fallback scene
	var fallback = FALLBACK_SCENE if last_successful_scene.is_empty() else last_successful_scene

	if fallback != scene_path:  # Avoid infinite loop
		push_warning("Attempting to load fallback scene: " + fallback)
		var fallback_error = get_tree().change_scene_to_file(fallback)
		if fallback_error != OK:
			push_error("CRITICAL: Fallback scene also failed to load!")
			# Last resort: try to return to previous scene from history
			if scene_history.size() > 0:
				get_tree().change_scene_to_file(scene_history[-1])
	else:
		push_error("CRITICAL: Cannot load fallback scene (it's the scene that failed!)")

# Return to previous scene (from Phase 1.3, enhanced in Phase 1.8)
func go_back() -> void:
	if scene_history.is_empty():
		push_warning("No scene history to go back to")
		return

	var previous = scene_history.pop_back()  # Get and remove last scene
	change_scene(previous, false, "back")  # Don't skip validation

# Go back multiple steps in history
func go_back_steps(steps: int = 1) -> void:
	if steps < 1:
		push_warning("Invalid step count: " + str(steps))
		return

	if scene_history.size() < steps:
		push_warning("Not enough scene history (want %d, have %d)" % [steps, scene_history.size()])
		return

	# Remove intermediate scenes
	for i in range(steps - 1):
		scene_history.pop_back()

	# Navigate to target scene
	var target = scene_history.pop_back()
	change_scene(target, false, "back_%d" % steps)

# Clear scene history (useful for "return to main menu")
func clear_scene_history() -> void:
	scene_history.clear()
	DebugLogger.log_info("SceneHistory", "Scene history cleared")

# Update scene history when changing scenes
func _update_scene_history(from_scene: String) -> void:
	# Don't add empty scenes
	if from_scene.is_empty():
		return

	# Add current scene to history
	scene_history.append(from_scene)

	# Limit history size
	if scene_history.size() > MAX_SCENE_HISTORY:
		scene_history.pop_front()  # Remove oldest

	DebugLogger.log_info("SceneHistory", "History size: %d, Last: %s" % [scene_history.size(), from_scene])

# ===== VALIDATION FRAMEWORK (Phase 1.8) =====

# Register a custom scene validator with priority and name
# Higher priority validators run first (e.g., priority 100 before priority 0)
# Name is used for debugging and error messages
func register_scene_validator(validator: Callable, priority: int = 0, validator_name: String = "") -> void:
	# Check if validator already registered
	for v in scene_validators:
		if v.validator == validator:
			push_warning("Validator already registered: " + validator_name)
			return

	# Add validator with metadata
	var validator_data = {
		"validator": validator,
		"priority": priority,
		"name": validator_name if not validator_name.is_empty() else "Unnamed validator"
	}
	scene_validators.append(validator_data)

	# Sort by priority (highest first)
	scene_validators.sort_custom(func(a, b): return a.priority > b.priority)

	DebugLogger.log_info("Validators", "Registered scene validator: %s (priority %d)" % [validator_data.name, priority])

# Remove a scene validator
func unregister_scene_validator(validator: Callable) -> void:
	for i in range(scene_validators.size()):
		if scene_validators[i].validator == validator:
			var name = scene_validators[i].name
			scene_validators.remove_at(i)
			DebugLogger.log_info("Validators", "Unregistered scene validator: " + name)
			return

# Check if scene transition is allowed (with reason tracking)
# Returns Dictionary: {allowed: bool, reason: String}
func can_change_to_scene(scene_path: String) -> Dictionary:
	# Built-in validation: Scene file must exist
	if not scene_exists(scene_path):
		var reason = "Scene file does not exist: " + scene_path
		push_error(reason)
		return {"allowed": false, "reason": reason}

	# Built-in validation: Don't transition to same scene
	if is_current_scene(scene_path):
		var reason = "Already in this scene"
		push_warning(reason)
		return {"allowed": false, "reason": reason}

	# Run custom validators in priority order
	for validator_data in scene_validators:
		var validator = validator_data.validator
		var validator_name = validator_data.name

		# Call validator (can return bool or Dictionary)
		var result = validator.call(scene_path)

		# Handle bool return (backward compatible)
		if result is bool:
			if not result:
				var reason = "Blocked by validator: " + validator_name
				DebugLogger.log_info("Validators", "Scene transition blocked by: " + validator_name)
				return {"allowed": false, "reason": reason}

		# Handle Dictionary return {allowed: bool, reason: String}
		elif result is Dictionary:
			if not result.get("allowed", false):
				var reason = result.get("reason", "Blocked by " + validator_name)
				DebugLogger.log_info("Validators", "Scene transition blocked: " + reason)
				return {"allowed": false, "reason": reason}
		else:
			push_error("Validator returned invalid type: " + validator_name)

	return {"allowed": true, "reason": ""}  # All validators passed

# ===== SCENE PRELOADING (Phase 1.8) =====

# Preload a scene for instant access
func preload_scene(scene_path: String) -> void:
	if scene_path in preloaded_scenes:
		push_warning("Scene already preloaded: " + scene_path)
		return

	if not ResourceLoader.exists(scene_path):
		push_error("Cannot preload non-existent scene: " + scene_path)
		return

	# Limit cache size
	if preloaded_scenes.size() >= MAX_PRELOADED_SCENES:
		# Remove oldest entry (FIFO)
		var oldest_key = preloaded_scenes.keys()[0]
		preloaded_scenes.erase(oldest_key)
		DebugLogger.log_info("ScenePreload", "Evicted oldest preloaded scene: " + oldest_key)

	# Load scene into cache
	var packed_scene = load(scene_path)
	if packed_scene:
		preloaded_scenes[scene_path] = packed_scene
		DebugLogger.log_info("ScenePreload", "Preloaded scene: " + scene_path)
	else:
		push_error("Failed to preload scene: " + scene_path)

# Unload a preloaded scene
func unload_preloaded_scene(scene_path: String) -> void:
	if scene_path in preloaded_scenes:
		preloaded_scenes.erase(scene_path)
		DebugLogger.log_info("ScenePreload", "Unloaded preloaded scene: " + scene_path)

# Clear all preloaded scenes
func clear_preloaded_scenes() -> void:
	preloaded_scenes.clear()
	DebugLogger.log_info("ScenePreload", "Cleared all preloaded scenes")

# ===== HELPER FUNCTIONS (Phase 1.8) =====

# Validate that a scene file exists
func scene_exists(scene_path: String) -> bool:
	return ResourceLoader.exists(scene_path)

# Get current scene path
func get_current_scene_path() -> String:
	if get_tree() and get_tree().current_scene:
		return get_tree().current_scene.scene_file_path
	return ""

# Check if transitioning to same scene
func is_current_scene(scene_path: String) -> bool:
	return get_current_scene_path() == scene_path

# Get loading progress (0.0 to 1.0) during async load
func get_scene_load_progress() -> float:
	if not is_loading_async or load_progress.is_empty():
		return 0.0
	return load_progress[0] if load_progress.size() > 0 else 0.0

# ===== SAVE SYSTEM FUNCTIONS (Phase 1.15) =====

func save() -> void:
	"""
	Save all settings and game progress.
	Called automatically on setting changes and after game events.
	"""
	# Sync current stats to save_data
	save_data.game.strength = strength
	save_data.game.dexterity = dexterity
	save_data.game.constitution = constitution
	save_data.game.intelligence = intelligence
	save_data.game.wisdom = wisdom
	save_data.game.charisma = charisma
	save_data.game.strength_exp = strength_exp
	save_data.game.dexterity_exp = dexterity_exp
	save_data.game.constitution_exp = constitution_exp
	save_data.game.intelligence_exp = intelligence_exp
	save_data.game.wisdom_exp = wisdom_exp
	save_data.game.charisma_exp = charisma_exp

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Failed to open save file for writing: " + SAVE_FILE_PATH)
		return

	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()

func load_save() -> void:
	"""Load settings and game progress"""
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return  # Use defaults

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not file:
		push_error("Failed to open save file for reading: " + SAVE_FILE_PATH)
		return

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_text)

	if parse_result != OK:
		push_error("Failed to parse save file JSON at line " + str(json.get_error_line()) + ": " + json.get_error_message())
		return

	var loaded_data = json.data
	if typeof(loaded_data) != TYPE_DICTIONARY:
		push_error("Save file does not contain a dictionary")
		return

	# Merge loaded settings with defaults (handles new fields gracefully)
	if loaded_data.has("settings") and typeof(loaded_data.settings) == TYPE_DICTIONARY:
		for key in loaded_data.settings:
			if save_data.settings.has(key):
				save_data.settings[key] = loaded_data.settings[key]

	# Merge loaded game data with defaults
	if loaded_data.has("game") and typeof(loaded_data.game) == TYPE_DICTIONARY:
		for key in loaded_data.game:
			if save_data.game.has(key):
				save_data.game[key] = loaded_data.game[key]

	# Sync loaded stats to instance variables
	strength = save_data.game.get("strength", 1)
	dexterity = save_data.game.get("dexterity", 1)
	constitution = save_data.game.get("constitution", 1)
	intelligence = save_data.game.get("intelligence", 1)
	wisdom = save_data.game.get("wisdom", 1)
	charisma = save_data.game.get("charisma", 1)
	strength_exp = save_data.game.get("strength_exp", 0.0)
	dexterity_exp = save_data.game.get("dexterity_exp", 0.0)
	constitution_exp = save_data.game.get("constitution_exp", 0.0)
	intelligence_exp = save_data.game.get("intelligence_exp", 0.0)
	wisdom_exp = save_data.game.get("wisdom_exp", 0.0)
	charisma_exp = save_data.game.get("charisma_exp", 0.0)

func reset_save() -> void:
	"""Reset game progress, preserve settings (called from settings scene)"""
	# Preserve settings, get fresh game defaults
	var settings_backup = save_data.settings.duplicate(true)

	# Reconstruct save_data with default game data
	save_data.settings = settings_backup
	save_data.game = get_default_game_data()

	# Reset instance variables
	reset_stats()

	save()

	# Return to previous scene and reload
	if not previous_scene.is_empty():
		change_scene(previous_scene)

func get_default_game_data() -> Dictionary:
	"""Returns default game data structure (used by reset_save and prestige)"""
	return {
		"copper_current": 0,
		"copper_lifetime": 0,
		"strength": 1,
		"dexterity": 1,
		"constitution": 1,
		"intelligence": 1,
		"wisdom": 1,
		"charisma": 1,
		"strength_exp": 0.0,
		"dexterity_exp": 0.0,
		"constitution_exp": 0.0,
		"intelligence_exp": 0.0,
		"wisdom_exp": 0.0,
		"charisma_exp": 0.0,
	}

# ===== NOTIFICATION SYSTEM =====

# Currently visible notifications (max 3)
var active_notifications: Array[Dictionary] = []

# Queue for overflow (max 20, FIFO)
var notification_queue: Array[Dictionary] = []
const MAX_NOTIFICATION_QUEUE = 20

# Notification types (stored for future visual differentiation)
const NOTIFICATION_TYPE_INFO = "info"       # General messages
const NOTIFICATION_TYPE_STAT = "stat"       # Stat level-ups
const NOTIFICATION_TYPE_WARNING = "warning" # Warnings/errors
const NOTIFICATION_TYPE_SUCCESS = "success" # Achievements/milestones

# Stat message pools (5 variants each)
const STAT_MESSAGES = {
	"strength": [
		"You feel stronger",
		"Your muscles harden",
		"Power surges through you",
		"You can lift more weight",
		"Raw strength flows into your limbs"
	],
	"dexterity": [
		"You feel more precise",
		"Your movements sharpen",
		"Agility comes naturally",
		"Your hands move with grace",
		"Reflexes quicken"
	],
	"constitution": [
		"You feel more resilient",
		"Your body toughens",
		"Endurance wells up within",
		"You can withstand more",
		"Vitality courses through you"
	],
	"intelligence": [
		"You feel smarter",
		"Clarity fills your mind",
		"Understanding deepens",
		"Patterns become clear",
		"Knowledge expands"
	],
	"wisdom": [
		"You feel more introspective",
		"Insight dawns upon you",
		"Perception sharpens",
		"The world makes more sense",
		"Wisdom settles in"
	],
	"charisma": [
		"You understand people better",
		"Social grace comes easier",
		"Others seem drawn to you",
		"Words flow more smoothly",
		"Presence strengthens"
	]
}

func show_notification(message: String, type: String = NOTIFICATION_TYPE_INFO) -> void:
	# Create notification data
	var notification_data = {
		"message": message,
		"type": type
	}

	# Check if we can display immediately
	if active_notifications.size() < 3:
		_display_notification(notification_data)
	else:
		# Queue for later display (with overflow protection)
		if notification_queue.size() >= MAX_NOTIFICATION_QUEUE:
			notification_queue.pop_front()  # Drop oldest
		notification_queue.append(notification_data)

func _display_notification(notification_data: Dictionary) -> void:
	# Find NotificationBar container (handles both orientations)
	var notification_bar = _find_notification_bar()
	if not notification_bar:
		push_warning("No NotificationBar found in current scene")
		return

	# Create panel
	var notification_panel = Panel.new()
	notification_panel.custom_minimum_size = Vector2(0, 40)  # Base height

	# Style panel (translucent dark background)
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.15, 0.15, 0.15, 0.4)  # Dark grey, 40% opacity
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	style_box.content_margin_top = 5
	style_box.content_margin_bottom = 5
	style_box.content_margin_left = 10
	style_box.content_margin_right = 10
	style_box.expand_margin_top = 3  # Spacing between stacked notifications
	style_box.expand_margin_bottom = 3
	notification_panel.add_theme_stylebox_override("panel", style_box)

	# Create label
	var notification_label = Label.new()
	notification_label.text = notification_data.message
	notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	notification_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))  # White
	notification_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# Fill panel (anchor to all edges)
	notification_label.anchor_left = 0
	notification_label.anchor_right = 1
	notification_label.anchor_top = 0
	notification_label.anchor_bottom = 1

	notification_panel.add_child(notification_label)

	# Create timer (dynamic duration: 1 sec base + 45ms per character)
	var notification_timer = Timer.new()
	notification_timer.one_shot = true
	notification_timer.wait_time = 1.0 + (notification_data.message.length() * 0.045)
	add_child(notification_timer)  # Child of Global (persists across scenes)

	# Update notification_data with UI references
	notification_data["panel"] = notification_panel
	notification_data["label"] = notification_label
	notification_data["timer"] = notification_timer

	# Add to active list
	active_notifications.append(notification_data)

	# Connect timer to removal
	notification_timer.timeout.connect(_remove_notification.bind(notification_data))

	# Add to scene
	notification_bar.add_child(notification_panel)

	# Apply responsive scaling (font size based on resolution and orientation)
	var scaled_font_size = ResponsiveLayout.get_scaled_font_size(25)
	notification_label.add_theme_font_size_override("font_size", scaled_font_size)

	# Scale panel height based on resolution
	var final_scale = ResponsiveLayout.get_final_scale()
	var scaled_height = 40 * final_scale
	notification_panel.custom_minimum_size = Vector2(0, scaled_height)

	# Start timer
	notification_timer.start()

func _remove_notification(notification_data: Dictionary) -> void:
	# Guard against invalid data or double-removal
	if not notification_data:
		return

	# Remove from active list
	var index = active_notifications.find(notification_data)
	if index != -1:
		active_notifications.remove_at(index)

	# Free UI nodes (with validity checks for scene changes)
	if notification_data.has("panel") and is_instance_valid(notification_data.panel):
		notification_data.panel.queue_free()
	if notification_data.has("timer") and is_instance_valid(notification_data.timer):
		notification_data.timer.queue_free()

	# Process queue if notifications waiting
	if notification_queue.size() > 0:
		var next_notification = notification_queue.pop_front()
		_display_notification(next_notification)

func _find_notification_bar() -> Node:
	var current_scene = get_tree().current_scene
	if not current_scene:
		return null

	# Try landscape location (direct child of root)
	var notification_bar = current_scene.get_node_or_null("AspectContainer/MainContainer/NotificationBar")
	if notification_bar:
		return notification_bar

	# Try portrait location (reparented by ResponsiveLayout into VBoxContainer)
	notification_bar = current_scene.get_node_or_null("VBoxContainer/NotificationBar")
	if notification_bar:
		return notification_bar

	# Try direct child as fallback
	notification_bar = current_scene.get_node_or_null("NotificationBar")
	if notification_bar:
		return notification_bar

	return null

func _get_stat_message(stat_name: String) -> String:
	"""Get random message variant for stat level-up."""
	var messages = STAT_MESSAGES.get(stat_name.to_lower(), [])
	if messages.is_empty():
		return "You feel improved"  # Fallback

	# Pick random variant
	return messages[randi() % messages.size()]

# ===== CURRENCY DISPLAY HELPERS =====

## Refresh all CurrencyDisplay instances in the scene tree
## Call this after any currency transaction to update all UI displays
func refresh_all_currency_displays() -> void:
	if not is_instance_valid(get_tree()):
		push_error("Cannot refresh currency displays: scene tree not available")
		return

	get_tree().call_group("currency_displays", "refresh")

# ===== RESET & INITIALIZATION =====

func reset_stats() -> void:
	strength = 1
	dexterity = 1
	constitution = 1
	intelligence = 1
	wisdom = 1
	charisma = 1

	strength_exp = 0.0
	dexterity_exp = 0.0
	constitution_exp = 0.0
	intelligence_exp = 0.0
	wisdom_exp = 0.0
	charisma_exp = 0.0

func _ready() -> void:
	print("Global autoload initialized (v%s)" % GAME_VERSION)
	DebugLogger.info("Game started - version %s" % GAME_VERSION, "GAME")
	DebugLogger.info("Save version: %d" % SAVE_VERSION, "GAME")

	# Load save data (Phase 1.15)
	load_save()
