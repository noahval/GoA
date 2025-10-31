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
const SERVER_SCHEME = "https"

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

## Authenticate with email/username and password
func authenticate_email(email: String, password: String, create: bool = false):
	if create:
		DebugLogger.log_info("NakamaClient", "Creating account with username: %s" % email)
	else:
		DebugLogger.log_info("NakamaClient", "Authenticating with username: %s" % email)

	# authenticate_email_async(email, password, username, create)
	var auth_result = await client.authenticate_email_async(email, password, email, create)

	if auth_result.is_exception():
		var error = auth_result.get_exception().message
		DebugLogger.log_error("NakamaClient", "Email authentication failed: %s" % error)
		authentication_failed.emit(error)
		return false

	session = auth_result as NakamaSession
	is_authenticated = true
	user_id = session.user_id
	username = session.username

	if create:
		DebugLogger.log_success("NakamaClient", "Account created successfully!")
	else:
		DebugLogger.log_success("NakamaClient", "Email authentication successful!")

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

## Save player stats to cloud
func save_player_stats():
	var stats_data = {
		"strength": Global.strength,
		"constitution": Global.constitution,
		"dexterity": Global.dexterity,
		"wisdom": Global.wisdom,
		"intelligence": Global.intelligence,
		"charisma": Global.charisma,
		"strength_exp": Global.strength_exp,
		"constitution_exp": Global.constitution_exp,
		"dexterity_exp": Global.dexterity_exp,
		"wisdom_exp": Global.wisdom_exp,
		"intelligence_exp": Global.intelligence_exp,
		"charisma_exp": Global.charisma_exp,
		"last_saved": Time.get_unix_time_from_system()
	}

	return await write_storage("player_data", "stats", stats_data)

## Load player stats from cloud
func load_player_stats():
	var stats_data = await read_storage("player_data", "stats")

	if stats_data:
		Global.strength = stats_data.get("strength", 1.0)
		Global.constitution = stats_data.get("constitution", 1.0)
		Global.dexterity = stats_data.get("dexterity", 1.0)
		Global.wisdom = stats_data.get("wisdom", 1.0)
		Global.intelligence = stats_data.get("intelligence", 1.0)
		Global.charisma = stats_data.get("charisma", 1.0)
		Global.strength_exp = stats_data.get("strength_exp", 0.0)
		Global.constitution_exp = stats_data.get("constitution_exp", 0.0)
		Global.dexterity_exp = stats_data.get("dexterity_exp", 0.0)
		Global.wisdom_exp = stats_data.get("wisdom_exp", 0.0)
		Global.intelligence_exp = stats_data.get("intelligence_exp", 0.0)
		Global.charisma_exp = stats_data.get("charisma_exp", 0.0)

		DebugLogger.log_success("NakamaClient", "Player stats loaded from cloud")
		return true

	return false
