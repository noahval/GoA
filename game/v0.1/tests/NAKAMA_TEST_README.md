# Nakama Connection Test

## Purpose
Verifies that the Nakama server at `nakama.goasso.xyz` is operational and accessible.

## How to Run

### In Godot Editor:
1. Open Godot project at `c:\Goa\game\v0.1\project.godot`
2. Navigate to `res://tests/test_nakama_connection.tscn` in FileSystem
3. Double-click to open the scene
4. Press F6 (or Play Scene button) to run the test
5. Watch the Output panel for test results

### Expected Output:
```
============================================================
NAKAMA CONNECTION TEST
============================================================
Server: nakama.goasso.xyz:443 (https)
Key: hijbtdhbgiunhyojunbghijnhytgfrde
============================================================

[TEST 1] Creating Nakama client...
[PASS] Client created successfully

[TEST 2] Authenticating with device ID...
[PASS] Authentication successful!

[TEST 3] Verifying session data...
[PASS] Session data verified

[TEST 4] Testing storage write...
[PASS] Storage write successful

[TEST 5] Testing storage read...
[PASS] Storage read successful - data matches

============================================================
ALL TESTS PASSED!
============================================================

Nakama server is operational and ready for use.
You can safely implement nakama_client.gd with these credentials.
```

## What This Tests:
1. Client creation with server credentials
2. Device ID authentication (creates test account)
3. Session validation
4. Cloud storage write operation
5. Cloud storage read operation

## Requirements:
- Nakama plugin installed at `addons/com.heroiclabs.nakama/`
- Internet connection
- Server at nakama.goasso.xyz must be operational

## Troubleshooting:

### "Failed to create Nakama client"
- Check that Nakama plugin is installed
- Verify plugin is enabled in Project Settings

### "Authentication failed"
- Check internet connection
- Verify server is accessible (ping nakama.goasso.xyz)
- Confirm server key hasn't changed

### "Storage write/read failed"
- Server may be read-only or having issues
- Check server logs for permission errors

## Server Configuration:
These values are confirmed working from v0.0:
```gdscript
const SERVER_KEY = "hijbtdhbgiunhyojunbghijnhytgfrde"
const SERVER_HOST = "nakama.goasso.xyz"
const SERVER_PORT = 443
const SERVER_SCHEME = "https"
```

## Note:
This test creates a temporary account on the server. It will not interfere with existing game data.
