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

# Storage configuration
const STORAGE_TIMEOUT = 15  # 15 second timeout for storage operations
var _last_error_type: String = ""  # "network", "quota", "auth", "unknown"

# Auto-save configuration
const AUTO_SAVE_INTERVAL = 120.0  # 2 minutes in seconds
var auto_save_timer: Timer = null
var auto_save_enabled: bool = true

# Retry configuration
const MAX_SAVE_RETRIES = 2
const SAVE_RETRY_DELAY = 1.0  # 1 second between retries

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
signal quota_exceeded()  # Emitted when storage quota is full


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

	# === TEMP: Uncomment to test account linking (1.17.4) ===
	#await _test_linking()

	# Setup auto-save timer (1.17.3-cloud-storage.md)
	_setup_auto_save()


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


# === TEMP TEST - Remove after testing ===
# Uncomment the call in _ready() to run: await _test_linking()
func _test_linking():
	# Must be authenticated first
	if not is_authenticated:
		var device_success = await authenticate_device()
		if not device_success:
			print("[TEST] Failed to authenticate with device")
			return

	print("[TEST] Testing account linking...")
	print("[TEST] Current user: ", username)

	# Test 1: Link email with short username (should fail)
	print("[TEST] 1. Short username...")
	var short = await link_email("ab", "password123")
	print("[TEST]    Result: ", "PASS (rejected)" if not short else "FAIL")

	# Test 2: Link email with weak password (should fail)
	print("[TEST] 2. Weak password...")
	var weak = await link_email("testuser", "pass")
	print("[TEST]    Result: ", "PASS (rejected)" if not weak else "FAIL")

	# Test 3: Link email success
	print("[TEST] 3. Valid link...")
	var random_bytes = Crypto.new().generate_random_bytes(8)
	var random_suffix = random_bytes.hex_encode()
	var success = await link_email("linkeduser" + random_suffix, "password123")
	print("[TEST]    Result: ", "PASS" if success else "FAIL")

	# Note: "Username already taken" error cannot be tested here because
	# device auth always returns the same account on the same device.
	# This error path will work correctly when different users try to
	# claim the same username from different accounts.

	print("[TEST] Done.")
# === END TEMP TEST ===


# === CLOUD STORAGE METHODS (1.17.3-cloud-storage.md) ===

# Error classification for appropriate error handling
func _classify_error(error_message: String) -> String:
	var lower_error = error_message.to_lower()

	# Network errors - transient, worth retrying
	var network_keywords = ["network", "timeout", "connection", "unreachable", "dns"]
	for keyword in network_keywords:
		if keyword in lower_error:
			return "network"

	# Quota errors - permanent, user action needed
	var quota_keywords = ["quota", "limit", "storage full", "size exceeded"]
	for keyword in quota_keywords:
		if keyword in lower_error:
			return "quota"

	# Auth errors - session expired, re-auth needed
	var auth_keywords = ["unauthorized", "authentication", "session", "token"]
	for keyword in auth_keywords:
		if keyword in lower_error:
			return "auth"

	return "unknown"


# Generic storage write with timeout and error classification
func write_storage(collection: String, key: String, value: Dictionary):
	if not is_authenticated:
		DebugLogger.error("Cannot write storage: Not authenticated", "NAKAMA")
		return null

	var write_object = NakamaWriteStorageObject.new(
		collection,
		key,
		2,  # Read permission: owner only
		1,  # Write permission: owner only
		JSON.stringify(value),
		""
	)

	# Set timeout for this operation
	var original_timeout = client.timeout
	client.timeout = STORAGE_TIMEOUT

	var result = await client.write_storage_objects_async(session, [write_object])

	# Restore original timeout
	client.timeout = original_timeout

	if result.is_exception():
		var error = result.get_exception().message
		DebugLogger.error("Storage write failed: " + error, "NAKAMA")
		_last_error_type = _classify_error(error)
		return null

	return result


# Generic storage read with timeout
func read_storage(collection: String, key: String):
	if not is_authenticated:
		DebugLogger.error("Cannot read storage: Not authenticated", "NAKAMA")
		return null

	var storage_id = NakamaStorageObjectId.new(collection, key, user_id)

	# Set timeout for this operation
	var original_timeout = client.timeout
	client.timeout = STORAGE_TIMEOUT

	var result = await client.read_storage_objects_async(session, [storage_id])

	# Restore original timeout
	client.timeout = original_timeout

	if result.is_exception():
		var error = result.get_exception().message
		DebugLogger.error("Storage read failed: " + error, "NAKAMA")
		_last_error_type = _classify_error(error)
		return null

	if result.objects.size() > 0:
		return JSON.parse_string(result.objects[0].value)

	return null


# === DATA SERIALIZATION HELPERS ===

func _get_global_data() -> Dictionary:
	return {
		# Settings (preserved during prestige/reset - from 1.14-settings-panel.md)
		"settings": {
			"ui_scale": Global.ui_scale,
			"music_volume": Global.music_volume,
			"sfx_volume": Global.sfx_volume,
		},
		# Note: dev_speed_mode is session-only, not saved to cloud

		# Six-stat system
		"strength": Global.strength,
		"constitution": Global.constitution,
		"dexterity": Global.dexterity,
		"wisdom": Global.wisdom,
		"intelligence": Global.intelligence,
		"charisma": Global.charisma,

		# Experience tracking
		"strength_exp": Global.strength_exp,
		"constitution_exp": Global.constitution_exp,
		"dexterity_exp": Global.dexterity_exp,
		"wisdom_exp": Global.wisdom_exp,
		"intelligence_exp": Global.intelligence_exp,
		"charisma_exp": Global.charisma_exp,

		# Play time tracking (for migration conflict resolution)
		"total_play_length": Global.total_play_length,
	}


func _set_global_data(data: Dictionary) -> void:
	# Settings (preserved during prestige/reset)
	if data.has("settings"):
		var settings = data.settings
		Global.ui_scale = settings.get("ui_scale", 1.0)
		Global.music_volume = settings.get("music_volume", 0.8)
		Global.sfx_volume = settings.get("sfx_volume", 0.8)

	# IMPORTANT: Global stat setters trigger notifications when values increase.
	# Set flag to suppress notifications during cloud save load.
	Global.is_loading_cloud_save = true

	# Six-stat system
	Global.strength = data.get("strength", 1)
	Global.constitution = data.get("constitution", 1)
	Global.dexterity = data.get("dexterity", 1)
	Global.wisdom = data.get("wisdom", 1)
	Global.intelligence = data.get("intelligence", 1)
	Global.charisma = data.get("charisma", 1)

	# Re-enable notifications
	Global.is_loading_cloud_save = false

	# Experience tracking
	Global.strength_exp = data.get("strength_exp", 0.0)
	Global.constitution_exp = data.get("constitution_exp", 0.0)
	Global.dexterity_exp = data.get("dexterity_exp", 0.0)
	Global.wisdom_exp = data.get("wisdom_exp", 0.0)
	Global.intelligence_exp = data.get("intelligence_exp", 0.0)
	Global.charisma_exp = data.get("charisma_exp", 0.0)

	# Play time tracking
	Global.total_play_length = data.get("total_play_length", 0.0)


func _get_level1_vars_data() -> Dictionary:
	# Delegate to existing Level1Vars function (authoritative source)
	# See level1/level_1_vars.gd:get_save_data() for full variable list

	if not Level1Vars:
		DebugLogger.error("Level1Vars autoload not available", "NAKAMA")
		return {}

	var data = Level1Vars.get_save_data()
	if not data or data.is_empty():
		DebugLogger.error("Level1Vars.get_save_data() returned invalid data", "NAKAMA")
		return {}

	return data


func _set_level1_vars_data(data: Dictionary) -> void:
	# Delegate to existing Level1Vars function
	# Handles all variable restoration + emits UI update signals

	if not Level1Vars:
		DebugLogger.error("Level1Vars autoload not available", "NAKAMA")
		return

	if not data or data.is_empty():
		DebugLogger.warning("Empty Level1Vars data provided", "NAKAMA")
		return

	Level1Vars.load_save_data(data)
	DebugLogger.info("Level1Vars data loaded successfully", "NAKAMA")


# === GAME SAVE/LOAD FUNCTIONS ===

func save_game() -> bool:
	if not is_authenticated:
		DebugLogger.error("Cannot save: Not authenticated", "NAKAMA")
		return false

	var current_time = Time.get_unix_time_from_system()
	var save_data = {
		"version": "0.1.0",  # For future migration support (not validated on load)
		"timestamp": current_time,
		"global": _get_global_data(),
		"level1_vars": _get_level1_vars_data()
	}

	var result = await write_storage("player_data", "game_save", save_data)

	if result:
		_mark_connection_success()
		last_successful_save_timestamp = current_time
		DebugLogger.info("Game saved to cloud", "NAKAMA")
		return true
	else:
		# Handle error based on type
		match _last_error_type:
			"quota":
				DebugLogger.error("Storage quota exceeded", "NAKAMA")
				quota_exceeded.emit()
				Global.show_notification("Cloud storage full: save failed", Global.NOTIFICATION_TYPE_WARNING)
			"auth":
				DebugLogger.error("Authentication expired during save", "NAKAMA")
				Global.show_notification("Session expired: please login again", Global.NOTIFICATION_TYPE_WARNING)
			_:  # "network" or "unknown"
				_mark_connection_lost()

		DebugLogger.error("Game save failed: " + _last_error_type, "NAKAMA")
		return false


func load_game() -> bool:
	if not is_authenticated:
		DebugLogger.error("Cannot load: Not authenticated", "NAKAMA")
		return false

	var save_data = await read_storage("player_data", "game_save")

	if not save_data:
		DebugLogger.info("No cloud save found", "NAKAMA")
		return false

	# Validate save structure
	if not save_data.has("global") or not save_data.has("level1_vars"):
		DebugLogger.error("Invalid cloud save: missing data sections", "NAKAMA")
		return false

	# Load data
	_set_global_data(save_data.global)
	_set_level1_vars_data(save_data.level1_vars)

	DebugLogger.info("Game loaded from cloud", "NAKAMA")
	return true


# === CONNECTION STATE TRACKING ===

func _mark_connection_success():
	var was_disconnected = not is_connected
	is_connected = true

	if was_disconnected:
		connection_restored.emit()
		Global.show_notification("Connection restored", Global.NOTIFICATION_TYPE_SUCCESS)


func _mark_connection_lost():
	if is_connected:
		is_connected = false
		connection_lost.emit()
		Global.show_notification("Connection lost: progress not saved", Global.NOTIFICATION_TYPE_WARNING)


# === SAVE RETRY LOGIC ===

func save_game_with_retry() -> bool:
	"""
	Saves game with automatic retry on network failure.
	Returns: true if save succeeded, false otherwise
	"""
	for attempt in range(MAX_SAVE_RETRIES + 1):
		var success = await save_game()

		if success:
			return true

		# Don't retry on auth or quota errors - only network
		if _last_error_type != "network":
			DebugLogger.error("Save failed (non-network error), not retrying", "NAKAMA")
			return false

		# Retry on network errors
		if attempt < MAX_SAVE_RETRIES:
			DebugLogger.info("Save failed, retrying in %d second(s)..." % SAVE_RETRY_DELAY, "NAKAMA")
			await get_tree().create_timer(SAVE_RETRY_DELAY).timeout

	DebugLogger.error("Save failed after %d retries" % MAX_SAVE_RETRIES, "NAKAMA")
	return false


# === AUTO-SAVE SYSTEM ===

func _setup_auto_save():
	"""Call this at end of _ready() after session restoration"""
	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = AUTO_SAVE_INTERVAL
	auto_save_timer.timeout.connect(_on_auto_save_timer_timeout)
	auto_save_timer.autostart = auto_save_enabled
	add_child(auto_save_timer)


func _on_auto_save_timer_timeout():
	if is_authenticated and not Global.is_loading_cloud_save:
		DebugLogger.info("Auto-save triggered", "NAKAMA")
		await save_game_with_retry()


func set_auto_save_enabled(enabled: bool):
	auto_save_enabled = enabled
	if auto_save_timer:
		if enabled:
			auto_save_timer.start()
		else:
			auto_save_timer.stop()
