extends Node

const ERROR_LOG_PATH = "user://error_log.txt"
const MAX_LOG_SIZE = 1024 * 100  # 100 KB

var errors_logged: int = 0
var last_error_time: int = 0

func _ready() -> void:
	# Connect to Godot's error handler
	# Note: Can't fully override engine errors, but can catch script errors
	print("ErrorHandler initialized - logging to " + ERROR_LOG_PATH)

# Log an error to file
func log_error(error_message: String, stack_trace: String = "") -> void:
	errors_logged += 1
	last_error_time = Time.get_unix_time_from_system()

	var timestamp = Time.get_datetime_string_from_system()
	var log_entry = "[%s] ERROR #%d: %s\n" % [timestamp, errors_logged, error_message]

	if not stack_trace.is_empty():
		log_entry += "Stack trace:\n%s\n" % stack_trace

	log_entry += "---\n"

	_append_to_log(log_entry)

	# Also print to console
	push_error(error_message)

# Log a warning (non-critical)
func log_warning(warning_message: String) -> void:
	var timestamp = Time.get_datetime_string_from_system()
	var log_entry = "[%s] WARNING: %s\n" % [timestamp, warning_message]

	_append_to_log(log_entry)
	push_warning(warning_message)

# Append to error log file
func _append_to_log(entry: String) -> void:
	# Check file size, rotate if too large
	if FileAccess.file_exists(ERROR_LOG_PATH):
		var file_size = FileAccess.get_file_as_string(ERROR_LOG_PATH).length()
		if file_size > MAX_LOG_SIZE:
			_rotate_log()

	var file = FileAccess.open(ERROR_LOG_PATH, FileAccess.READ_WRITE)
	if file:
		file.seek_end()
		file.store_string(entry)
		file.close()

# Rotate log file when it gets too large
func _rotate_log() -> void:
	var old_log = ERROR_LOG_PATH.replace(".txt", "_old.txt")

	# Delete old backup if exists
	if FileAccess.file_exists(old_log):
		DirAccess.remove_absolute(old_log)

	# Rename current to old
	DirAccess.rename_absolute(ERROR_LOG_PATH, old_log)

# Get recent errors (for debug UI)
func get_recent_errors(count: int = 10) -> Array:
	if not FileAccess.file_exists(ERROR_LOG_PATH):
		return []

	var file = FileAccess.open(ERROR_LOG_PATH, FileAccess.READ)
	if not file:
		return []

	var lines = file.get_as_text().split("\n")
	file.close()

	# Get last N errors (each error is multiple lines, so this is approximate)
	var recent = []
	for i in range(max(0, lines.size() - count * 5), lines.size()):
		recent.append(lines[i])

	return recent
