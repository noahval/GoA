extends Node

## Central error handling orchestrator
## Provides error catching, recovery, and user notification
## Cloud-native approach - trust Nakama infrastructure, handle connection failures gracefully

# Error categories
enum ErrorSeverity {
	MINOR,      # Log and continue silently
	MODERATE,   # Log, notify user, continue
	MAJOR,      # Log, notify user, attempt recovery
	CRITICAL    # Log, notify user, force safe state
}

enum RecoveryAction {
	CONTINUE,
	RESET_SYSTEM,
	LOAD_BACKUP,
	RESTART_SCENE,
	GOTO_SAFE_SCENE
}

# Error tracking
var error_count: int = 0
var errors_this_session: Array = []
var last_error_time: float = 0.0

# Safe state tracking
var is_in_recovery: bool = false
var recovery_attempts: int = 0
const MAX_RECOVERY_ATTEMPTS = 3

# Connection monitoring
var is_connected_to_server: bool = true
var last_connection_check: float = 0.0
var connection_check_interval: float = 30.0  # Check every 30 seconds

# Error popup reference
var error_popup: Control = null

# === PUBLIC API ===

## Safely execute a function with error catching
## Returns: Dictionary with {success: bool, result: Variant, error: String}
func safe_call(callable: Callable, context: String = "unknown") -> Dictionary:
	if is_in_recovery and recovery_attempts >= MAX_RECOVERY_ATTEMPTS:
		return {
			"success": false,
			"result": null,
			"error": "System in recovery mode"
		}

	# Execute and catch errors
	var result = callable.call()

	# Check for null or error returns
	if result == null:
		_log_error(context, "Function returned null", ErrorSeverity.MINOR)
		return {"success": false, "result": null, "error": "Null result"}

	return {"success": true, "result": result, "error": ""}

## Handle an error with automatic recovery
## @param context: String - where error occurred (e.g., "Shop.purchase_item")
## @param error_msg: String - what went wrong
## @param severity: ErrorSeverity - how serious this is
## @param recovery_data: Dictionary - optional data for recovery
func handle_error(context: String, error_msg: String, severity: int, recovery_data: Dictionary = {}) -> void:
	error_count += 1
	last_error_time = Time.get_unix_time_from_system()

	# Log to DebugLogger
	_log_error(context, error_msg, severity)

	# Track for bug reports
	errors_this_session.append({
		"time": last_error_time,
		"context": context,
		"message": error_msg,
		"severity": ErrorSeverity.keys()[severity]
	})

	# Determine recovery action
	var action = _determine_recovery_action(severity, recovery_data)

	# Show user notification if moderate or higher
	if severity >= ErrorSeverity.MODERATE:
		_show_user_error(context, error_msg, severity, action, recovery_data)

	# Execute recovery
	_execute_recovery(action, recovery_data)

## Safe node access - returns null if not found, never crashes
func safe_get_node(root: Node, path: String) -> Node:
	if not root:
		return null

	if not root.has_node(path):
		return null

	return root.get_node_or_null(path)

## Safe scene loading - returns null if fails
func safe_load_scene(scene_path: String) -> PackedScene:
	if not ResourceLoader.exists(scene_path):
		_log_error("SceneLoad", "Scene does not exist: " + scene_path, ErrorSeverity.MAJOR)
		return null

	var scene = load(scene_path)
	if not scene:
		_log_error("SceneLoad", "Failed to load scene: " + scene_path, ErrorSeverity.MAJOR)
		return null

	return scene

## Safe scene change with fallback to safe scene
func safe_change_scene(tree: SceneTree, scene_path: String, fallback_path: String = "res://level1/loading_screen.tscn") -> bool:
	# Validate scene exists
	if not ResourceLoader.exists(scene_path):
		handle_error("SceneChange", "Scene not found: " + scene_path, ErrorSeverity.MAJOR, {
			"scene_path": scene_path,
			"fallback": fallback_path
		})

		# Try fallback
		if ResourceLoader.exists(fallback_path):
			tree.change_scene_to_file(fallback_path)
			return false
		else:
			# Even fallback failed - critical error
			handle_error("SceneChange", "Fallback scene also missing!", ErrorSeverity.CRITICAL, {})
			return false

	# Attempt scene change
	var error = tree.change_scene_to_file(scene_path)
	if error != OK:
		handle_error("SceneChange", "Failed to change scene: " + str(error), ErrorSeverity.MAJOR, {
			"scene_path": scene_path,
			"fallback": fallback_path
		})

		# Try fallback
		tree.change_scene_to_file(fallback_path)
		return false

	return true

## Notify when save fails due to connection
func handle_save_failure(error_message: String):
	is_connected_to_server = false

	# Show notification
	Global.show_stat_notification("Connection lost - progress not saved")

	# Log error
	DebugLogger.error("Save failed: " + error_message, "CLOUD_SAVE")

	# Update connection indicator (if settings panel is open)
	_update_connection_indicator()

## Notify when connection restored
func handle_save_success():
	if not is_connected_to_server:
		is_connected_to_server = true
		Global.show_stat_notification("Connection restored")

	_update_connection_indicator()

# === INTERNAL FUNCTIONS ===

func _log_error(context: String, message: String, severity: int) -> void:
	var severity_str = ErrorSeverity.keys()[severity]
	var full_message = "[%s] %s: %s" % [context, severity_str, message]

	match severity:
		ErrorSeverity.MINOR:
			DebugLogger.warn(full_message, "ERROR_HANDLER")
		ErrorSeverity.MODERATE:
			DebugLogger.error(full_message, "ERROR_HANDLER")
		ErrorSeverity.MAJOR, ErrorSeverity.CRITICAL:
			DebugLogger.error(full_message, "ERROR_HANDLER")
			push_error(full_message)  # Also push to Godot console

func _determine_recovery_action(severity: int, recovery_data: Dictionary) -> int:
	match severity:
		ErrorSeverity.MINOR:
			return RecoveryAction.CONTINUE
		ErrorSeverity.MODERATE:
			return RecoveryAction.CONTINUE
		ErrorSeverity.MAJOR:
			if recovery_data.has("action"):
				return recovery_data.action
			return RecoveryAction.RESET_SYSTEM
		ErrorSeverity.CRITICAL:
			return RecoveryAction.GOTO_SAFE_SCENE

	return RecoveryAction.CONTINUE

func _execute_recovery(action: int, recovery_data: Dictionary) -> void:
	if is_in_recovery:
		recovery_attempts += 1
		if recovery_attempts >= MAX_RECOVERY_ATTEMPTS:
			_go_to_safe_scene()
			return

	is_in_recovery = true

	match action:
		RecoveryAction.CONTINUE:
			# Do nothing, just continue
			pass

		RecoveryAction.RESET_SYSTEM:
			# Reset the affected system
			_reset_system(recovery_data.get("system", ""))

		RecoveryAction.LOAD_BACKUP:
			# No local backups - would load from cloud if needed
			# In cloud-native approach, just start fresh
			_go_to_safe_scene()

		RecoveryAction.RESTART_SCENE:
			# Reload current scene
			get_tree().reload_current_scene()

		RecoveryAction.GOTO_SAFE_SCENE:
			_go_to_safe_scene()

	is_in_recovery = false
	recovery_attempts = 0

func _reset_system(system_name: String) -> void:
	DebugLogger.info("Resetting system: " + system_name, "ERROR_RECOVERY")

	# System-specific resets
	match system_name:
		"shop":
			# Close shop popups, reset UI state
			pass
		"currency":
			# Validate currency values, fix negatives
			_validate_currency_data()
		"stats":
			# Validate stat values, ensure minimums
			_validate_stat_data()
		_:
			DebugLogger.warn("Unknown system to reset: " + system_name, "ERROR_RECOVERY")

func _validate_currency_data() -> void:
	# Ensure all currency values are non-negative
	if Level1Vars.currency.copper < 0:
		DebugLogger.error("Copper was negative! Resetting to 0", "VALIDATION")
		Level1Vars.currency.copper = 0.0
	if Level1Vars.currency.silver < 0:
		DebugLogger.error("Silver was negative! Resetting to 0", "VALIDATION")
		Level1Vars.currency.silver = 0.0
	if Level1Vars.currency.gold < 0:
		DebugLogger.error("Gold was negative! Resetting to 0", "VALIDATION")
		Level1Vars.currency.gold = 0.0
	if Level1Vars.currency.platinum < 0:
		DebugLogger.error("Platinum was negative! Resetting to 0", "VALIDATION")
		Level1Vars.currency.platinum = 0.0

func _validate_stat_data() -> void:
	# Ensure all stats are at least 1
	if Global.strength < 1.0:
		DebugLogger.error("Strength was below 1! Resetting to 1", "VALIDATION")
		Global.strength = 1.0
	if Global.constitution < 1.0:
		DebugLogger.error("Constitution was below 1! Resetting to 1", "VALIDATION")
		Global.constitution = 1.0
	if Global.dexterity < 1.0:
		DebugLogger.error("Dexterity was below 1! Resetting to 1", "VALIDATION")
		Global.dexterity = 1.0
	if Global.wisdom < 1.0:
		DebugLogger.error("Wisdom was below 1! Resetting to 1", "VALIDATION")
		Global.wisdom = 1.0
	if Global.intelligence < 1.0:
		DebugLogger.error("Intelligence was below 1! Resetting to 1", "VALIDATION")
		Global.intelligence = 1.0
	if Global.charisma < 1.0:
		DebugLogger.error("Charisma was below 1! Resetting to 1", "VALIDATION")
		Global.charisma = 1.0

func _go_to_safe_scene() -> void:
	DebugLogger.error("Going to safe scene", "ERROR_RECOVERY")
	get_tree().change_scene_to_file("res://level1/loading_screen.tscn")

func _show_user_error(context: String, error_msg: String, severity: int, action: int, recovery_data: Dictionary) -> void:
	# Translate technical error to user-friendly message
	var user_message = _translate_error_for_user(context, error_msg, severity)
	var recovery_action_text = _get_recovery_action_text(action)

	# Show in scene template's PlayArea
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.has_method("show_error_in_play_area"):
		current_scene.show_error_in_play_area(user_message, recovery_action_text, context, error_msg, severity)
	else:
		# Fallback: Log to console if scene doesn't support error panel
		DebugLogger.error("No error panel support in current scene", "ERROR_HANDLER")

func _translate_error_for_user(context: String, error_msg: String, severity: int) -> String:
	# Convert technical errors to friendly messages
	var lower_context = context.to_lower()

	if "save" in lower_context or "load" in lower_context:
		return "We had trouble with your save file. Don't worry - we'll try to recover it!"
	elif "scene" in lower_context:
		return "We couldn't load that area. Taking you somewhere safe..."
	elif "currency" in lower_context or "purchase" in lower_context:
		return "Something went wrong with that transaction. Your items are safe!"
	elif "stat" in lower_context:
		return "We noticed an issue with your character. Everything's been fixed!"
	else:
		return "Something unexpected happened, but we're handling it!"

func _get_recovery_action_text(action: int) -> String:
	match action:
		RecoveryAction.CONTINUE:
			return "Continuing..."
		RecoveryAction.RESET_SYSTEM:
			return "Fixing the issue..."
		RecoveryAction.LOAD_BACKUP:
			return "Loading backup..."
		RecoveryAction.RESTART_SCENE:
			return "Reloading area..."
		RecoveryAction.GOTO_SAFE_SCENE:
			return "Returning to safe area..."
	return "Recovering..."

func _update_connection_indicator() -> void:
	# Signal to settings panel (if open) to update indicator
	# Settings panel checks ErrorHandler.is_connected_to_server directly
	pass

# === TESTING FUNCTIONS (REMOVE IN PRODUCTION) ===

func test_connection_failure():
	# Simulate connection failure
	handle_save_failure("Simulated connection timeout")

func test_missing_scene():
	safe_change_scene(get_tree(), "res://nonexistent_scene.tscn")

func test_negative_currency():
	Level1Vars.currency.copper = -100.0
	_validate_currency_data()

func test_invalid_stat():
	Global.strength = 0.0
	_validate_stat_data()
