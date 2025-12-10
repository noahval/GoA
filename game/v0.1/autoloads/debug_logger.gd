extends Node

# Log levels enum
enum LogLevel {
	DEBUG = 0,
	INFO = 1,
	WARN = 2,
	ERROR = 3
}

# Configuration
var disk_log_level: int = LogLevel.INFO
var enable_logging: bool = true
var log_directory: String = "user://logs/"
var current_log_file: String = ""
var session_id: String = ""

# File management
var log_file: FileAccess = null
var current_log_size: int = 0
const MAX_LOG_FILE_SIZE: int = 5 * 1024 * 1024  # 5MB per session
const MAX_TOTAL_LOG_SIZE: int = 50 * 1024 * 1024  # 50MB total
const MAX_LOG_FILES: int = 10

# Memory buffer for bug reports (always captures everything)
var recent_logs: Array[Dictionary] = []
const MAX_RECENT_LOGS: int = 300

# Level names for formatting
const LEVEL_NAMES = ["DEBUG", "INFO", "WARN", "ERROR"]

func _ready():
	if enable_logging:
		_load_settings()
		_setup_log_directory()
		_rotate_old_logs()
		_open_new_session_log()

func _exit_tree():
	_close_log_file()

func _load_settings():
	# Load from project settings if available
	disk_log_level = ProjectSettings.get_setting("debug/disk_log_level", LogLevel.INFO)
	enable_logging = ProjectSettings.get_setting("debug/enable_logging", true)

func _setup_log_directory():
	var dir = DirAccess.open("user://")
	if not dir:
		push_error("Failed to access user:// directory")
		enable_logging = false
		return

	if not dir.dir_exists("logs"):
		var err = dir.make_dir("logs")
		if err != OK:
			push_error("Failed to create logs directory: " + str(err))
			enable_logging = false

func _open_new_session_log():
	# Generate unique session ID
	session_id = _generate_session_id()

	# Create session log file: goa_2025-12-09_14-30-45_abc123.log
	var datetime = Time.get_datetime_dict_from_system()
	current_log_file = log_directory + "goa_%04d-%02d-%02d_%02d-%02d-%02d_%s.log" % [
		datetime.year, datetime.month, datetime.day,
		datetime.hour, datetime.minute, datetime.second,
		session_id
	]

	log_file = FileAccess.open(current_log_file, FileAccess.WRITE)
	if not log_file:
		push_error("Failed to create log file: " + current_log_file)
		enable_logging = false
		return

	current_log_size = 0

	# Write header
	var separator = "=".repeat(60)
	var header = [
		separator,
		"GoA Debug Log - Session Started",
		"Session ID: " + session_id,
		"Time: " + Time.get_datetime_string_from_system(),
		"Platform: " + OS.get_name(),
		"OS Version: " + OS.get_version(),
		"Godot Version: " + Engine.get_version_info().string,
		"Disk Log Level: " + LEVEL_NAMES[disk_log_level],
		separator
	]

	for line in header:
		log_file.store_line(line)
		current_log_size += line.length() + 1

	log_file.flush()

func _close_log_file():
	if log_file:
		var separator = "=".repeat(60)
		log_file.store_line(separator)
		log_file.store_line("Session Ended: " + Time.get_datetime_string_from_system())
		log_file.store_line(separator)
		log_file.flush()
		log_file.close()
		log_file = null

func _generate_session_id() -> String:
	# Generate short unique ID: 6 random hex chars
	var chars = "0123456789abcdef"
	var result = ""
	for i in range(6):
		result += chars[randi() % chars.length()]
	return result

func _rotate_old_logs():
	var dir = DirAccess.open(log_directory)
	if not dir:
		return

	# Collect all log files with metadata
	var log_files: Array[Dictionary] = []
	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.begins_with("goa_") and file_name.ends_with(".log"):
			var file_path = log_directory + file_name
			var mod_time = FileAccess.get_modified_time(file_path)
			var file_size = FileAccess.open(file_path, FileAccess.READ).get_length()

			log_files.append({
				"name": file_name,
				"path": file_path,
				"modified": mod_time,
				"size": file_size
			})
		file_name = dir.get_next()

	dir.list_dir_end()

	# Sort by modification time (oldest first)
	log_files.sort_custom(func(a, b): return a.modified < b.modified)

	# Calculate total size
	var total_size = 0
	for log_entry in log_files:
		total_size += log_entry.size

	# Delete oldest logs if over total size limit OR over max file count
	while log_files.size() >= MAX_LOG_FILES or total_size > MAX_TOTAL_LOG_SIZE:
		if log_files.is_empty():
			break

		var oldest = log_files.pop_front()
		dir.remove(oldest.name)
		total_size -= oldest.size
		print("Deleted old log file: " + oldest.name + " (size: " + str(oldest.size) + ")")

# Main logging function
func write_log(message: String, level: int = LogLevel.INFO, category: String = "GENERAL"):
	if not enable_logging:
		return

	# Clamp level to valid range
	level = clampi(level, LogLevel.DEBUG, LogLevel.ERROR)

	var level_name = LEVEL_NAMES[level]
	var timestamp = Time.get_datetime_string_from_system()
	var formatted = "[%s] [%s] [%s] %s" % [timestamp, level_name, category, message]

	# Always add to memory buffer (for bug reports in 1.22-advanced-logging)
	recent_logs.append({
		"session_id": session_id,
		"timestamp": timestamp,
		"level": level_name,
		"category": category,
		"message": message,
		"formatted": formatted
	})

	# Trim buffer if too large
	if recent_logs.size() > MAX_RECENT_LOGS:
		recent_logs.pop_front()

	# Write to disk if level is high enough
	if level >= disk_log_level and log_file:
		# Check if we've exceeded max file size
		if current_log_size >= MAX_LOG_FILE_SIZE:
			log_file.store_line("[LOG SIZE LIMIT REACHED - STOPPING SESSION LOG]")
			log_file.flush()
			# Don't close file, just stop writing (keeps session open)
			return

		log_file.store_line(formatted)
		current_log_size += formatted.length() + 1
		log_file.flush()  # Immediate flush - survives crashes

	# Also print to console
	if level >= LogLevel.ERROR:
		push_error(message)
	elif level == LogLevel.WARN:
		push_warning(message)

# Convenience functions
func debug(message: String, category: String = "DEBUG"):
	write_log(message, LogLevel.DEBUG, category)

func info(message: String, category: String = "INFO"):
	write_log(message, LogLevel.INFO, category)

func warn(message: String, category: String = "WARN"):
	write_log(message, LogLevel.WARN, category)

func error(message: String, category: String = "ERROR"):
	write_log(message, LogLevel.ERROR, category)

# Get recent logs for bug reports (used by 1.22-advanced-logging)
func get_recent_logs(count: int = 150) -> Array[Dictionary]:
	var start_index = max(0, recent_logs.size() - count)
	return recent_logs.slice(start_index)

# Get errors and warnings only
func get_error_logs(count: int = 50) -> Array[Dictionary]:
	var errors = recent_logs.filter(func(log_entry): return log_entry.level == "ERROR" or log_entry.level == "WARN")
	var start_index = max(0, errors.size() - count)
	return errors.slice(start_index)

# Get current session ID (used by bug reports to correlate with log files)
func get_session_id() -> String:
	return session_id

# Backward compatibility with old stub API
func log_info(category: String, message: String) -> void:
	info(message, category)

func log_warning(category: String, message: String) -> void:
	warn(message, category)

func log_error(category: String, message: String) -> void:
	error(message, category)

func log_scene_change(from_scene: String, to_scene: String, reason: String) -> void:
	var from_name = _get_scene_name(from_scene)
	var to_name = _get_scene_name(to_scene)
	var message = "Scene: %s -> %s (%s)" % [from_name, to_name, reason]
	info(message, "SCENE")

func _get_scene_name(scene_path: String) -> String:
	if scene_path.is_empty():
		return "[none]"
	return scene_path.get_file().get_basename()
