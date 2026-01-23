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
signal connection_recovery_requested()  # Used in 1.17.2-authentication.md (startup retry flow)


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


# Session restoration - calls attempt_startup_connection() from authentication.md
func _restore_session() -> void:
	await attempt_startup_connection()


# === AUTHENTICATION METHODS (1.17.2-authentication.md) ===

# Shared validation helper (used by authenticate_username and link_email)
func _validate_username_password(username_input: String, password: String) -> String:
	if username_input.length() < 3:
		return "Username must be at least 3 characters"
	if password.length() < 8:
		return "Password must be at least 8 characters"
	return ""  # Valid


# Device ID Authentication - Cloud-based auth using device ID
func authenticate_device(device_id: String = "") -> bool:
	if not client:
		authentication_failed.emit("Client not initialized")
		return false

	if device_id.is_empty():
		device_id = _get_device_id()

	var result = await client.authenticate_device_async(device_id, null, true, {})

	if result.is_exception():
		var error = result.get_exception().message
		DebugLogger.error("Device auth failed: " + error, "NAKAMA")
		authentication_failed.emit(_sanitize_auth_error(error))
		return false

	session = result  # No type cast - keeps dynamic loading working
	is_authenticated = true
	user_id = session.user_id
	username = session.username
	_save_session_data(session)
	DebugLogger.info("Authenticated as: " + username, "NAKAMA")
	authentication_succeeded.emit({"user_id": user_id, "username": username})
	return true


func _get_device_id() -> String:
	var id = OS.get_unique_id()
	if id.is_empty():
		# Web builds may return empty - use persistent ID
		id = _load_or_create_web_device_id()
	return id


func _load_or_create_web_device_id() -> String:
	const WEB_ID_PATH = "user://web_device_id.dat"
	if FileAccess.file_exists(WEB_ID_PATH):
		var file = FileAccess.open(WEB_ID_PATH, FileAccess.READ)
		if file:
			return file.get_as_text().strip_edges()

	# Generate new ID using cryptographic randomness (Godot 4)
	var bytes = Crypto.new().generate_random_bytes(16)
	var id = bytes.hex_encode()  # 32-char hex string
	var file = FileAccess.open(WEB_ID_PATH, FileAccess.WRITE)
	if file:
		file.store_string(id)
	return id


# Username/Password Authentication - For portable accounts
func authenticate_username(username_input: String, password: String, create_account: bool) -> bool:
	if not client:
		authentication_failed.emit("Client not initialized")
		return false

	# Validate inputs using shared helper
	var validation_error = _validate_username_password(username_input, password)
	if not validation_error.is_empty():
		authentication_failed.emit(validation_error)
		return false

	# Convert username to email format for Nakama
	var email = username_input.to_lower() + "@goa.game"

	var result = await client.authenticate_email_async(email, password, username_input, create_account, {})

	if result.is_exception():
		var error = result.get_exception().message
		DebugLogger.error("Username auth failed: " + error, "NAKAMA")
		authentication_failed.emit(_sanitize_auth_error(error))
		return false

	session = result  # No type cast - keeps dynamic loading working
	is_authenticated = true
	user_id = session.user_id
	username = session.username
	_save_session_data(session)
	DebugLogger.info("Authenticated as: " + username, "NAKAMA")
	authentication_succeeded.emit({"user_id": user_id, "username": username})
	return true


func _sanitize_auth_error(error: String) -> String:
	# Prevent username enumeration - vague messages for security
	if "already exists" in error.to_lower():
		return "Username already taken"
	if "not found" in error.to_lower() or "invalid" in error.to_lower():
		return "Invalid username or password"
	return "Authentication failed. Please try again."


func logout():
	is_authenticated = false
	user_id = ""
	username = ""
	session = null
	if FileAccess.file_exists(SESSION_TOKEN_PATH):
		var dir = DirAccess.open("user://")
		if dir:
			dir.remove("nakama_session.dat")
	DebugLogger.info("User logged out", "NAKAMA")


# Session Persistence - Store and load session tokens
func _save_session_data(nakama_session) -> void:  # Untyped param for dynamic loading
	var data = {
		"token": nakama_session.token,
		"refresh_token": nakama_session.refresh_token,
		"username": nakama_session.username,
		"user_id": nakama_session.user_id
	}
	var file = FileAccess.open(SESSION_TOKEN_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))


func _load_session_data() -> Dictionary:
	if not FileAccess.file_exists(SESSION_TOKEN_PATH):
		return {}

	var file = FileAccess.open(SESSION_TOKEN_PATH, FileAccess.READ)
	if not file:
		return {}

	var data = JSON.parse_string(file.get_as_text())
	return data if data != null else {}


func restore_session() -> bool:
	if not client:
		return false

	var data = _load_session_data()
	if data.is_empty():
		return false

	var token = data.get("token", "")
	var refresh_token = data.get("refresh_token", "")
	if token.is_empty():
		return false

	# Restore session by creating NakamaSession from stored tokens
	var NakamaSession = load("res://addons/com.heroiclabs.nakama/api/NakamaSession.gd")
	session = NakamaSession.new(token, false, refresh_token)

	if not session or not session.is_valid():
		DebugLogger.info("Stored session invalid", "NAKAMA")
		logout()
		return false

	# Check if expired locally before hitting server
	if session.is_expired():
		DebugLogger.info("Stored session expired", "NAKAMA")
		logout()
		return false

	# Validate with server
	var account = await client.get_account_async(session)
	if account.is_exception():
		DebugLogger.info("Session invalid on server", "NAKAMA")
		logout()
		return false

	# Session valid - restore auth state
	is_authenticated = true
	user_id = data.get("user_id", session.user_id)
	username = data.get("username", account.user.username)
	DebugLogger.info("Session restored for: " + username, "NAKAMA")
	authentication_succeeded.emit({"user_id": user_id, "username": username})
	return true


# Startup Connection & Retry
func attempt_startup_connection() -> bool:
	var data = _load_session_data()
	if data.is_empty():
		return false

	var success = await restore_session()
	if not success:
		connection_recovery_requested.emit()
	return success


func retry_connection() -> bool:
	return await restore_session()


# === ACCOUNT LINKING METHODS (1.17.4-account-linking.md) ===

# Link email to current device account
func link_email(username_input: String, password: String) -> bool:
	if not is_authenticated:
		authentication_failed.emit("Not logged in")
		return false

	# Validate inputs using shared helper
	var validation_error = _validate_username_password(username_input, password)
	if not validation_error.is_empty():
		authentication_failed.emit(validation_error)
		return false

	# Convert username to email format (same as authenticate_username)
	var email = username_input.to_lower() + "@goa.game"

	var result = await client.link_email_async(session, email, password)

	if result.is_exception():
		var error = result.get_exception().message
		DebugLogger.error("Email link failed: " + error, "NAKAMA")

		# Check if username already taken
		if "already in use" in error.to_lower() or "exists" in error.to_lower():
			authentication_failed.emit("That username is already taken. Please choose a different one.")
		else:
			authentication_failed.emit("Failed to link account. Please try again.")
		return false

	DebugLogger.info("Email linked to account", "NAKAMA")
	return true


# Link Google to current device account (stub - implementation in 1.17.7-google-oauth.md)
func link_google(google_token: String) -> bool:
	push_warning("NAKAMA: link_google() not yet implemented")
	authentication_failed.emit("Google linking not available yet")
	return false


# Query which auth methods are linked to current account
func get_linked_auth_methods() -> Array[String]:
	if not is_authenticated or not session:
		return []

	var account = await client.get_account_async(session)
	if account.is_exception():
		DebugLogger.error("Failed to get account info", "NAKAMA")
		return []

	var methods: Array[String] = []
	if account.user.email and not account.user.email.is_empty():
		methods.append("email")
	if account.user.google_id and not account.user.google_id.is_empty():
		methods.append("google")
	if account.user.devices and account.user.devices.size() > 0:
		methods.append("device")

	return methods


# Check if email is linked to current account
func has_email_linked() -> bool:
	var methods = await get_linked_auth_methods()
	return "email" in methods


# Check if Google is linked to current account
func has_google_linked() -> bool:
	var methods = await get_linked_auth_methods()
	return "google" in methods


# Stub methods for later plans - prevents errors if called before implementation
func save_game() -> void:
	# TODO: Implement in 1.17.3-cloud-storage.md
	push_warning("NAKAMA: save_game() not yet implemented")


func load_game() -> void:
	# TODO: Implement in 1.17.3-cloud-storage.md
	push_warning("NAKAMA: load_game() not yet implemented")
