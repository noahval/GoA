extends Node

# ===== DEBUG LOGGER AUTOLOAD =====
# Provides comprehensive logging for autonomous testing and debugging
# Usage: DebugLogger.write_log("message", "CATEGORY") or use convenience methods: debug(), info(), warn(), error()

var log_file: FileAccess = null
var log_file_path: String = "user://debug.log"
var enable_console_output: bool = true
var enable_file_output: bool = true
var log_level: int = 0  # 0=DEBUG, 1=INFO, 2=WARN, 3=ERROR

enum LogLevel {
	DEBUG = 0,
	INFO = 1,
	WARN = 2,
	ERROR = 3
}

func _ready():
	# Open log file for writing
	if enable_file_output:
		log_file = FileAccess.open(log_file_path, FileAccess.WRITE)
		if log_file:
			_write_header()
		else:
			push_error("Failed to open debug log file at: " + log_file_path)

func _exit_tree():
	# Close log file on exit
	if log_file:
		_write_footer()
		log_file.close()

func _write_header():
	if log_file:
		log_file.store_line("=" .repeat(80))
		log_file.store_line("GoA Debug Log")
		log_file.store_line("Started: " + Time.get_datetime_string_from_system())
		log_file.store_line("=" .repeat(80))
		log_file.flush()

func _write_footer():
	if log_file:
		log_file.store_line("=" .repeat(80))
		log_file.store_line("Log ended: " + Time.get_datetime_string_from_system())
		log_file.store_line("=" .repeat(80))
		log_file.flush()

# Main logging function
func write_log(message: String, category: String = "DEBUG", level: int = LogLevel.DEBUG):
	if level < log_level:
		return

	var timestamp = Time.get_datetime_string_from_system()
	var level_str = LogLevel.keys()[level]
	var formatted_message = "[%s][%s][%s] %s" % [timestamp, level_str, category, message]

	# Output to console
	if enable_console_output:
		print(formatted_message)

	# Output to file
	if enable_file_output and log_file:
		log_file.store_line(formatted_message)
		log_file.flush()

# Convenience functions for different log levels
func debug(message: String, category: String = "DEBUG"):
	write_log(message, category, LogLevel.DEBUG)

func info(message: String, category: String = "INFO"):
	write_log(message, category, LogLevel.INFO)

func warn(message: String, category: String = "WARN"):
	write_log(message, category, LogLevel.WARN)

func error(message: String, category: String = "ERROR"):
	write_log(message, category, LogLevel.ERROR)

# Alternative log_info with category first (for Nakama integration compatibility)
func log_info(category: String, message: String):
	write_log(message, category, LogLevel.INFO)

# Track stat changes
func log_stat_change(stat_name: String, old_value: float, new_value: float, exp_gained: float):
	var message = "Stat '%s': %.2f -> %.2f (exp: +%.2f)" % [stat_name, old_value, new_value, exp_gained]
	info(message, "STAT_CHANGE")

# Track resource changes
func log_resource_change(resource_name: String, old_value: float, new_value: float, reason: String = ""):
	var change = new_value - old_value
	var change_str = "+%.2f" % change if change >= 0 else "%.2f" % change
	var message = "Resource '%s': %.2f -> %.2f (%s)" % [resource_name, old_value, new_value, change_str]
	if reason != "":
		message += " | Reason: " + reason
	info(message, "RESOURCE")

# Track function calls
func log_function_call(function_name: String, parameters: Dictionary = {}):
	var message = "Called: %s" % function_name
	if not parameters.is_empty():
		message += " | Params: " + str(parameters)
	debug(message, "FUNCTION")

# Track timer events
func log_timer_event(timer_name: String, event: String, time_remaining: float = 0.0):
	var message = "Timer '%s': %s" % [timer_name, event]
	if time_remaining > 0:
		message += " | Time: %.2fs" % time_remaining
	info(message, "TIMER")

# Track scene changes
func log_scene_change(from_scene: String, to_scene: String, reason: String = ""):
	var message = "Scene: %s -> %s" % [from_scene, to_scene]
	if reason != "":
		message += " | Reason: " + reason
	info(message, "SCENE")

# Track shop purchases
func log_shop_purchase(item_name: String, cost: float, level: int):
	var message = "Purchase: %s | Cost: %.0f | New Level: %d" % [item_name, cost, level]
	info(message, "SHOP")

# Track victory checks
func log_victory_check(conditions_met: bool, current_progress: Dictionary):
	var message = "Victory Check: %s | Progress: %s" % ["PASSED" if conditions_met else "NOT MET", str(current_progress)]
	info(message, "VICTORY")
