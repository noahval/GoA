extends Node
## Nakama Connection Test Script
## Tests server connectivity and authentication
## Run this scene to verify Nakama server is accessible

# Server config from v0.0 (verified working)
const SERVER_KEY = "hijbtdhbgiunhyojunbghijnhytgfrde"
const SERVER_HOST = "nakama.goasso.xyz"
const SERVER_PORT = 443
const SERVER_SCHEME = "https"

var client: NakamaClient
var session: NakamaSession

func _ready():
	print("\n" + "=".repeat(60))
	print("NAKAMA CONNECTION TEST")
	print("=".repeat(60))
	print("Server: %s:%d (%s)" % [SERVER_HOST, SERVER_PORT, SERVER_SCHEME])
	print("Key: %s" % SERVER_KEY)
	print("=".repeat(60) + "\n")

	await get_tree().create_timer(0.5).timeout
	_run_tests()

func _run_tests():
	print("[TEST 1] Creating Nakama client...")
	client = Nakama.create_client(SERVER_KEY, SERVER_HOST, SERVER_PORT, SERVER_SCHEME)

	if not client:
		_test_failed("Failed to create Nakama client")
		return

	_test_passed("Client created successfully")

	print("\n[TEST 2] Authenticating with device ID...")
	var device_id = "test_device_" + str(Time.get_unix_time_from_system())
	print("Device ID: %s" % device_id)

	var auth_result = await client.authenticate_device_async(
		device_id,
		null,
		true,  # Create account if doesn't exist
		{}
	)

	if auth_result.is_exception():
		var error = auth_result.get_exception().message
		_test_failed("Authentication failed: %s" % error)
		return

	session = auth_result as NakamaSession
	_test_passed("Authentication successful!")

	print("\n[TEST 3] Verifying session data...")
	print("User ID: %s" % session.user_id)
	print("Username: %s" % session.username)
	print("Session valid: %s" % (not session.is_expired()))
	print("Session token: %s..." % session.token.substr(0, 20))

	if session.user_id.is_empty():
		_test_failed("Session has no user ID")
		return

	_test_passed("Session data verified")

	print("\n[TEST 4] Testing storage write...")
	var test_data = {
		"test_timestamp": Time.get_unix_time_from_system(),
		"test_message": "Nakama connection test successful"
	}

	var write_object = NakamaWriteStorageObject.new(
		"test_data",
		"connection_test",
		2,  # Read permission: owner only
		1,  # Write permission: owner only
		JSON.stringify(test_data),
		""
	)

	var write_result = await client.write_storage_objects_async(session, [write_object])

	if write_result.is_exception():
		var error = write_result.get_exception().message
		_test_failed("Storage write failed: %s" % error)
		return

	_test_passed("Storage write successful")

	print("\n[TEST 5] Testing storage read...")
	var storage_id = NakamaStorageObjectId.new("test_data", "connection_test", session.user_id)
	var read_result = await client.read_storage_objects_async(session, [storage_id])

	if read_result.is_exception():
		var error = read_result.get_exception().message
		_test_failed("Storage read failed: %s" % error)
		return

	if read_result.objects.size() == 0:
		_test_failed("No data returned from storage read")
		return

	var retrieved_data = JSON.parse_string(read_result.objects[0].value)
	print("Retrieved data: %s" % str(retrieved_data))

	if retrieved_data.test_message != test_data.test_message:
		_test_failed("Retrieved data doesn't match written data")
		return

	_test_passed("Storage read successful - data matches")

	print("\n" + "=".repeat(60))
	print("ALL TESTS PASSED!")
	print("=".repeat(60))
	print("\nNakama server is operational and ready for use.")
	print("You can safely implement nakama_client.gd with these credentials.\n")

func _test_passed(message: String):
	print("[PASS] %s" % message)

func _test_failed(message: String):
	print("\n" + "!".repeat(60))
	print("[FAIL] %s" % message)
	print("!".repeat(60))
	print("\nTEST SUITE FAILED")
	print("Check server configuration and network connectivity.\n")
