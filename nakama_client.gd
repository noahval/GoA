extends Node
## Nakama Client Manager
## Handles connection to Nakama server and authentication

# Nakama client and session
var client: NakamaClient
var session: NakamaSession
var socket: NakamaSocket

# Server configuration
const SERVER_KEY = "hijbtdhbgiunhyojunbghijnhytgfrde"  # Match your config.yml
const SERVER_HOST = "nakama.goasso.xyz"
const SERVER_PORT = 443
const SERVER_SCHEME = "https"  # Using HTTPS with unsafe TLS (accepts self-signed certs)

# Authentication state
var is_authenticated = false
var user_id = ""
var username = ""

# Signals
signal authentication_succeeded(session_data)
signal authentication_failed(error)
signal connection_established()
signal connection_failed(error)

func _ready():
	DebugLogger.log_info("NakamaClient", "Initializing Nakama client")
	_initialize_client()

func _initialize_client():
	# Create Nakama client
	client = Nakama.create_client(SERVER_KEY, SERVER_HOST, SERVER_PORT, SERVER_SCHEME)

	if client:
		DebugLogger.log_info("NakamaClient", "Client created successfully")
		DebugLogger.log_info("NakamaClient", "Server: %s:%d (%s)" % [SERVER_HOST, SERVER_PORT, SERVER_SCHEME])
	else:
		DebugLogger.log_error("NakamaClient", "Failed to create Nakama client")

## Authenticate with device ID (for testing/development)
func authenticate_device(device_id: String = ""):
	if device_id.is_empty():
		device_id = OS.get_unique_id()

	DebugLogger.log_info("NakamaClient", "Authenticating with device ID: %s" % device_id)

	var auth_result = await client.authenticate_device_async(device_id, null, true, {})

	if auth_result.is_exception():
		var error = auth_result.get_exception().message
		DebugLogger.log_error("NakamaClient", "Authentication failed: %s" % error)
		authentication_failed.emit(error)
		return false

	session = auth_result as NakamaSession
	is_authenticated = true
	user_id = session.user_id
	username = session.username

	DebugLogger.log_success("NakamaClient", "Authenticated successfully!")
	DebugLogger.log_info("NakamaClient", "User ID: %s" % user_id)
	DebugLogger.log_info("NakamaClient", "Username: %s" % username)

	authentication_succeeded.emit({
		"user_id": user_id,
		"username": username,
		"session": session
	})

	return true

## Authenticate with Google (for production)
func authenticate_google(google_token: String):
	DebugLogger.log_info("NakamaClient", "Authenticating with Google")

	var auth_result = await client.authenticate_google_async(google_token, null, true, {})

	if auth_result.is_exception():
		var error = auth_result.get_exception().message
		DebugLogger.log_error("NakamaClient", "Google authentication failed: %s" % error)
		authentication_failed.emit(error)
		return false

	session = auth_result as NakamaSession
	is_authenticated = true
	user_id = session.user_id
	username = session.username

	DebugLogger.log_success("NakamaClient", "Google authentication successful!")
	DebugLogger.log_info("NakamaClient", "User ID: %s" % user_id)
	DebugLogger.log_info("NakamaClient", "Username: %s" % username)

	authentication_succeeded.emit({
		"user_id": user_id,
		"username": username,
		"session": session
	})

	return true

## Authenticate with username and password using custom authentication
func authenticate_email(username_input: String, password: String, create: bool = false):
	if not client:
		DebugLogger.log_error("NakamaClient", "Client not initialized")
		authentication_failed.emit("Server connection not initialized")
		return false

	if create:
		DebugLogger.log_info("NakamaClient", "Creating account with username: %s" % username_input)
	else:
		DebugLogger.log_info("NakamaClient", "Authenticating with username: %s" % username_input)

	# Use custom authentication which accepts any username format
	# Custom ID format: username:password_hash for uniqueness
	var custom_id = username_input + ":" + password.sha256_text()

	DebugLogger.log_info("NakamaClient", "Calling authenticate_custom_async...")

	# authenticate_custom_async(id, username, create)
	var auth_result = await client.authenticate_custom_async(custom_id, username_input, create)

	DebugLogger.log_info("NakamaClient", "Received auth response")

	if auth_result.is_exception():
		var error = auth_result.get_exception().message
		DebugLogger.log_error("NakamaClient", "Authentication failed: %s" % error)
		authentication_failed.emit(error)
		return false

	session = auth_result as NakamaSession
	is_authenticated = true
	user_id = session.user_id
	username = session.username

	if create:
		DebugLogger.log_success("NakamaClient", "Account created successfully!")
	else:
		DebugLogger.log_success("NakamaClient", "Authentication successful!")

	DebugLogger.log_info("NakamaClient", "User ID: %s" % user_id)
	DebugLogger.log_info("NakamaClient", "Username: %s" % username)

	authentication_succeeded.emit({
		"user_id": user_id,
		"username": username,
		"session": session
	})

	return true

## Connect to realtime socket
func connect_socket():
	if not is_authenticated:
		DebugLogger.log_error("NakamaClient", "Cannot connect socket: Not authenticated")
		return false

	DebugLogger.log_info("NakamaClient", "Connecting to realtime socket...")

	socket = Nakama.create_socket_from(client)
	var connect_result = await socket.connect_async(session)

	if connect_result.is_exception():
		var error = connect_result.get_exception().message
		DebugLogger.log_error("NakamaClient", "Socket connection failed: %s" % error)
		connection_failed.emit(error)
		return false

	DebugLogger.log_success("NakamaClient", "Socket connected!")
	connection_established.emit()
	return true

## Store player data
func write_storage(collection: String, key: String, value: Dictionary):
	if not is_authenticated:
		DebugLogger.log_error("NakamaClient", "Cannot write storage: Not authenticated")
		return null

	var acks = await client.write_storage_objects_async(session, [
		NakamaWriteStorageObject.new(collection, key, 2, 1, JSON.stringify(value), "")
	])

	if acks.is_exception():
		DebugLogger.log_error("NakamaClient", "Storage write failed: %s" % acks.get_exception().message)
		return null

	DebugLogger.log_success("NakamaClient", "Data written to storage: %s/%s" % [collection, key])
	return acks

## Read player data
func read_storage(collection: String, key: String):
	if not is_authenticated:
		DebugLogger.log_error("NakamaClient", "Cannot read storage: Not authenticated")
		return null

	var result = await client.read_storage_objects_async(session, [
		NakamaStorageObjectId.new(collection, key, user_id)
	])

	if result.is_exception():
		DebugLogger.log_error("NakamaClient", "Storage read failed: %s" % result.get_exception().message)
		return null

	if result.objects.size() > 0:
		var data = JSON.parse_string(result.objects[0].value)
		DebugLogger.log_info("NakamaClient", "Data read from storage: %s/%s" % [collection, key])
		return data

	DebugLogger.log_info("NakamaClient", "No data found at %s/%s" % [collection, key])
	return null

## Save full game state to cloud (similar to LocalSaveManager)
func save_game() -> bool:
	if not is_authenticated:
		DebugLogger.log_error("NakamaClient", "Cannot save: Not authenticated")
		return false

	# Update last_played_timestamp before saving
	Level1Vars.last_played_timestamp = Time.get_unix_time_from_system()

	var save_data = {
		"version": "1.0",
		"timestamp": Time.get_unix_time_from_system(),
		"global": _get_global_data(),
		"level1_vars": _get_level1_vars_data()
	}

	var result = await write_storage("player_data", "game_save", save_data)
	if result:
		DebugLogger.log_success("NakamaClient", "Full game state saved to cloud")
		return true
	return false

## Load full game state from cloud
func load_game() -> bool:
	if not is_authenticated:
		DebugLogger.log_error("NakamaClient", "Cannot load: Not authenticated")
		return false

	var save_data = await read_storage("player_data", "game_save")

	if save_data:
		# Validate save data structure
		if not save_data.has("global") or not save_data.has("level1_vars"):
			DebugLogger.log_error("NakamaClient", "Invalid cloud save structure")
			return false

		# Load Global data
		_set_global_data(save_data.global)

		# Load Level1Vars data
		_set_level1_vars_data(save_data.level1_vars)

		DebugLogger.log_success("NakamaClient", "Full game state loaded from cloud")
		return true

	DebugLogger.log_info("NakamaClient", "No cloud save found")
	return false

## Get all Global variables to save (matching LocalSaveManager)
func _get_global_data() -> Dictionary:
	return {
		# Stats
		"strength": Global.strength,
		"constitution": Global.constitution,
		"dexterity": Global.dexterity,
		"wisdom": Global.wisdom,
		"intelligence": Global.intelligence,
		"charisma": Global.charisma,

		# Experience
		"strength_exp": Global.strength_exp,
		"constitution_exp": Global.constitution_exp,
		"dexterity_exp": Global.dexterity_exp,
		"wisdom_exp": Global.wisdom_exp,
		"intelligence_exp": Global.intelligence_exp,
		"charisma_exp": Global.charisma_exp,

		# Prestige system
		"reputation_points": Global.reputation_points,
		"lifetime_reputation_earned": Global.lifetime_reputation_earned,
		"reputation_upgrades": Global.reputation_upgrades,

		# Dev mode
		"dev_speed_mode": Global.dev_speed_mode
	}

## Get all Level1Vars variables to save (matching LocalSaveManager)
func _get_level1_vars_data() -> Dictionary:
	return {
		# Resources
		"coal": Level1Vars.coal,
		"coins": Level1Vars.coins,  # Legacy - kept for backward compatibility
		"currency": Level1Vars.currency,  # New multi-currency system
		"lifetime_currency": Level1Vars.lifetime_currency,  # Lifetime earnings per currency
		"components": Level1Vars.components,
		"mechanisms": Level1Vars.mechanisms,
		"pipes": Level1Vars.pipes,

		# Upgrades
		"shovel_lvl": Level1Vars.shovel_lvl,
		"plow_lvl": Level1Vars.plow_lvl,
		"auto_shovel_lvl": Level1Vars.auto_shovel_lvl,
		"auto_shovel_freq": Level1Vars.auto_shovel_freq,
		"auto_shovel_coal_per_tick": Level1Vars.auto_shovel_coal_per_tick,
		"auto_shovel_coal_upgrade_lvl": Level1Vars.auto_shovel_coal_upgrade_lvl,
		"auto_shovel_freq_upgrade_lvl": Level1Vars.auto_shovel_freq_upgrade_lvl,
		"overseer_lvl": Level1Vars.overseer_lvl,

		# Story/State flags
		"barkeep_bribed": Level1Vars.barkeep_bribed,
		"shopkeep_bribed": Level1Vars.shopkeep_bribed,
		"heart_taken": Level1Vars.heart_taken,
		"whisper_triggered": Level1Vars.whisper_triggered,
		"door_discovered": Level1Vars.door_discovered,

		# Phase 1: Overseer & Conversion
		"auto_conversion_enabled": Level1Vars.auto_conversion_enabled,
		"overseer_bribe_count": Level1Vars.overseer_bribe_count,
		"mood_system_unlocked": Level1Vars.mood_system_unlocked,
		"lifetimecoins": Level1Vars.lifetimecoins,
		"dorm_unlocked": Level1Vars.dorm_unlocked,
		"coinslot_machine_unlocked": Level1Vars.coinslot_machine_unlocked,

		# Progress
		"stolen_coal": Level1Vars.stolen_coal,
		"stolen_writs": Level1Vars.stolen_writs,
		"correct_answers": Level1Vars.correct_answers,
		"suspicion": Level1Vars.suspicion,
		"equipment_value": Level1Vars.equipment_value,

		# Timers/Buffs
		"break_time_remaining": Level1Vars.break_time_remaining,
		"starting_break_time": Level1Vars.starting_break_time,
		"coin_cost": Level1Vars.coin_cost,
		"stamina": Level1Vars.stamina,
		"talk_button_cooldown": Level1Vars.talk_button_cooldown,
		"stimulated_remaining": Level1Vars.stimulated_remaining,
		"shown_tired_notification": Level1Vars.shown_tired_notification,
		"resilient_remaining": Level1Vars.resilient_remaining,
		"shown_lazy_notification": Level1Vars.shown_lazy_notification,

		# Pipe puzzle state
		"pipe_puzzle_grid": Level1Vars.pipe_puzzle_grid,

		# Phase 2: Offline Earnings
		"overtime_lvl": Level1Vars.overtime_lvl,
		"offline_cap_hours": Level1Vars.offline_cap_hours,
		"last_played_timestamp": Level1Vars.last_played_timestamp
	}

## Set Global variables from cloud save data (matching LocalSaveManager)
func _set_global_data(data: Dictionary) -> void:
	# Stats
	Global.strength = data.get("strength", 1.0)
	Global.constitution = data.get("constitution", 1.0)
	Global.dexterity = data.get("dexterity", 1.0)
	Global.wisdom = data.get("wisdom", 1.0)
	Global.intelligence = data.get("intelligence", 1.0)
	Global.charisma = data.get("charisma", 1.0)

	# Experience
	Global.strength_exp = data.get("strength_exp", 0.0)
	Global.constitution_exp = data.get("constitution_exp", 0.0)
	Global.dexterity_exp = data.get("dexterity_exp", 0.0)
	Global.wisdom_exp = data.get("wisdom_exp", 0.0)
	Global.intelligence_exp = data.get("intelligence_exp", 0.0)
	Global.charisma_exp = data.get("charisma_exp", 0.0)

	# Prestige system
	Global.reputation_points = data.get("reputation_points", 0)
	Global.lifetime_reputation_earned = data.get("lifetime_reputation_earned", 0)
	Global.reputation_upgrades = data.get("reputation_upgrades", {})

	# Dev mode
	Global.dev_speed_mode = data.get("dev_speed_mode", false)

## Set Level1Vars variables from cloud save data (matching LocalSaveManager)
func _set_level1_vars_data(data: Dictionary) -> void:
	# Resources
	Level1Vars.coal = data.get("coal", 0.0)

	# Currency migration: Check if save has new multi-currency format
	if data.has("currency") and data.has("lifetime_currency"):
		# New format - load currency dictionaries directly
		Level1Vars.currency = data.get("currency", {"copper": 0.0, "silver": 0.0, "gold": 0.0, "platinum": 0.0})
		Level1Vars.lifetime_currency = data.get("lifetime_currency", {"copper": 0.0, "silver": 0.0, "gold": 0.0, "platinum": 0.0})
		Level1Vars.coins = Level1Vars.currency.copper  # Sync legacy variable
	else:
		# Old format - migrate single "coins" value to new multi-currency system
		var old_coins = data.get("coins", 0.0)
		Level1Vars.currency.copper = old_coins
		Level1Vars.currency.silver = 0.0
		Level1Vars.currency.gold = 0.0
		Level1Vars.currency.platinum = 0.0
		Level1Vars.coins = old_coins  # Sync legacy variable

		# Migrate lifetimecoins to lifetime_currency
		var old_lifetimecoins = data.get("lifetimecoins", 0.0)
		Level1Vars.lifetime_currency.copper = old_lifetimecoins
		Level1Vars.lifetime_currency.silver = 0.0
		Level1Vars.lifetime_currency.gold = 0.0
		Level1Vars.lifetime_currency.platinum = 0.0

		DebugLogger.log_info("CloudSaveMigration", "Migrated old cloud save from single currency to multi-currency")

	Level1Vars.components = data.get("components", 0)
	Level1Vars.mechanisms = data.get("mechanisms", 0)
	Level1Vars.pipes = data.get("pipes", 5)

	# Upgrades
	Level1Vars.shovel_lvl = data.get("shovel_lvl", 0)
	Level1Vars.plow_lvl = data.get("plow_lvl", 0)
	Level1Vars.auto_shovel_lvl = data.get("auto_shovel_lvl", 1)
	Level1Vars.auto_shovel_freq = data.get("auto_shovel_freq", 3.0)
	Level1Vars.auto_shovel_coal_per_tick = data.get("auto_shovel_coal_per_tick", 4.0)
	Level1Vars.auto_shovel_coal_upgrade_lvl = data.get("auto_shovel_coal_upgrade_lvl", 0)
	Level1Vars.auto_shovel_freq_upgrade_lvl = data.get("auto_shovel_freq_upgrade_lvl", 0)
	Level1Vars.overseer_lvl = data.get("overseer_lvl", 0)

	# Story/State flags
	Level1Vars.barkeep_bribed = data.get("barkeep_bribed", false)
	Level1Vars.shopkeep_bribed = data.get("shopkeep_bribed", false)
	Level1Vars.heart_taken = data.get("heart_taken", true)
	Level1Vars.whisper_triggered = data.get("whisper_triggered", false)
	Level1Vars.door_discovered = data.get("door_discovered", false)

	# Phase 1: Overseer & Conversion
	Level1Vars.auto_conversion_enabled = data.get("auto_conversion_enabled", false)
	Level1Vars.overseer_bribe_count = data.get("overseer_bribe_count", 0)
	Level1Vars.mood_system_unlocked = data.get("mood_system_unlocked", false)
	Level1Vars.lifetimecoins = data.get("lifetimecoins", 0.0)
	Level1Vars.dorm_unlocked = data.get("dorm_unlocked", false)
	Level1Vars.coinslot_machine_unlocked = data.get("coinslot_machine_unlocked", false)

	# Progress
	Level1Vars.stolen_coal = data.get("stolen_coal", 0)
	Level1Vars.stolen_writs = data.get("stolen_writs", 0)
	Level1Vars.correct_answers = data.get("correct_answers", 0)
	Level1Vars.suspicion = data.get("suspicion", 0)
	Level1Vars.equipment_value = data.get("equipment_value", 0)

	# Timers/Buffs
	Level1Vars.break_time_remaining = data.get("break_time_remaining", 0.0)
	Level1Vars.starting_break_time = data.get("starting_break_time", 23)
	Level1Vars.coin_cost = data.get("coin_cost", 30.0)
	Level1Vars.stamina = data.get("stamina", 125.0)
	Level1Vars.talk_button_cooldown = data.get("talk_button_cooldown", 0.0)
	Level1Vars.stimulated_remaining = data.get("stimulated_remaining", 0.0)
	Level1Vars.shown_tired_notification = data.get("shown_tired_notification", false)
	Level1Vars.resilient_remaining = data.get("resilient_remaining", 0.0)
	Level1Vars.shown_lazy_notification = data.get("shown_lazy_notification", false)

	# Pipe puzzle state
	Level1Vars.pipe_puzzle_grid = data.get("pipe_puzzle_grid", [])

	# Phase 2: Offline Earnings
	Level1Vars.overtime_lvl = data.get("overtime_lvl", 0)
	Level1Vars.offline_cap_hours = data.get("offline_cap_hours", 8.0)
	Level1Vars.last_played_timestamp = data.get("last_played_timestamp", 0)

## DEPRECATED: Use save_game() instead for full game state
## Save player stats to cloud
func save_player_stats():
	DebugLogger.log_warn("NakamaClient", "save_player_stats() is deprecated. Use save_game() instead")
	return await save_game()

## DEPRECATED: Use load_game() instead for full game state
## Load player stats from cloud
func load_player_stats():
	DebugLogger.log_warn("NakamaClient", "load_player_stats() is deprecated. Use load_game() instead")
	return await load_game()
