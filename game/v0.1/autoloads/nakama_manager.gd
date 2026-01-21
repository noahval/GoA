extends Node

# Nakama Core Client - Foundation for cloud saves and authentication
# See: .claude/plans/1/1.17-nakama/1.17.1-core-client.md

# Nakama objects (untyped to allow parsing when plugin not installed)
var client  # NakamaClient
var session  # NakamaSession

# Server config
const SERVER_HOST = "nakama.goasso.xyz"
const SERVER_PORT = 443
const SERVER_SCHEME = "https"
const SESSION_TOKEN_PATH = "user://nakama_session.dat"

# Server key - loaded from environment variable to keep it out of version control
# Set environment variable NAKAMA_SERVER_KEY before running
# For development: Create nakama_config.gd (gitignored) with get_key() function as fallback
var server_key: String = ""

# Auth state
var is_authenticated: bool = false
var user_id: String = ""
var username: String = ""

# Connection state
var is_connected: bool = false  # False until first successful save
var last_successful_save_timestamp: float = 0.0  # For quit warning (see 1.17.6)

# Signals
signal authentication_succeeded(session_data)
signal authentication_failed(error_message)
signal save_conflict_detected(device_save, account_save)  # Used in 1.17.5-migration.md
signal migration_completed(success: bool)  # Used in 1.17.5-migration.md
signal connection_lost()  # Used in 1.17.3-cloud-storage.md, 1.17.6-connection-ui.md
signal connection_restored()  # Used in 1.17.3-cloud-storage.md, 1.17.6-connection-ui.md


func _ready() -> void:
	if not _load_server_key():
		push_error("NAKAMA: Failed to load server key")
		return

	if not _initialize_client():
		push_error("NAKAMA: Failed to initialize client")
		return

	# Try to restore previous session (implementation in 1.17.2-authentication.md)
	# _restore_session() internally loads stored session data
	await _restore_session()


func _load_server_key() -> bool:
	# Try environment variable first
	server_key = OS.get_environment("NAKAMA_SERVER_KEY")

	if server_key.is_empty():
		# Fallback to gitignored config file (for development)
		if FileAccess.file_exists("res://nakama_config.gd"):
			var config = load("res://nakama_config.gd").new()
			server_key = config.get_key()

	if server_key.is_empty():
		push_error("NAKAMA: Server key not found. Set NAKAMA_SERVER_KEY environment variable or create nakama_config.gd")
		return false

	return true


func _initialize_client() -> bool:
	# Check if Nakama plugin is available (must access dynamically to avoid parse errors)
	var nakama = get_node_or_null("/root/Nakama")
	if not nakama:
		push_error("NAKAMA: Plugin not found. Is addons/com.heroiclabs.nakama/ installed?")
		return false

	client = nakama.create_client(
		server_key,
		SERVER_HOST,
		SERVER_PORT,
		SERVER_SCHEME
	)

	if not client:
		push_error("NAKAMA: Failed to create client")
		return false

	# Set timeout for operations
	client.timeout = 10  # 10 second timeout

	print("[NakamaManager] Client initialized for %s" % SERVER_HOST)
	DebugLogger.info("Nakama client initialized for %s" % SERVER_HOST, "NETWORK")
	return true


# Stub for session restoration - implemented in 1.17.2-authentication.md
func _restore_session() -> void:
	# TODO: Implement in 1.17.2-authentication.md
	# This will:
	# 1. Load stored session token from SESSION_TOKEN_PATH
	# 2. Validate the session with the server
	# 3. Set is_authenticated and session variables
	# 4. Emit authentication_succeeded or authentication_failed
	pass


# Stub methods for later plans - prevents errors if called before implementation
func save_game() -> void:
	# TODO: Implement in 1.17.3-cloud-storage.md
	push_warning("NAKAMA: save_game() not yet implemented")


func load_game() -> void:
	# TODO: Implement in 1.17.3-cloud-storage.md
	push_warning("NAKAMA: load_game() not yet implemented")
