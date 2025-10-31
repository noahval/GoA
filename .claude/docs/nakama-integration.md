# Nakama Integration Documentation

**Purpose**: Online backend for authentication, cloud saves, and multiplayer features
**Server**: `https://nakama.goasso.xyz`
**Autoload**: `NakamaClient`

---

## Table of Contents

1. [Server Architecture](#server-architecture)
2. [NakamaClient API](#nakamaclient-api)
3. [Authentication](#authentication)
4. [Cloud Storage](#cloud-storage)
5. [Common Patterns](#common-patterns)
6. [Error Handling](#error-handling)
7. [Testing](#testing)

---

## Server Architecture

### Infrastructure

```
GitHub Pages (noahval.github.io/GoA)
    ↓ HTTPS
Cloudflare Tunnel
    ↓ Secure Tunnel
Unraid Server (192.168.1.1)
    ↓ Docker
Nakama Server (nakama.goasso.xyz)
    ↓
PostgreSQL Database
```

**Key Components:**
- **Domain**: `goasso.xyz` (Porkbun + Cloudflare DNS)
- **SSL**: Automatic via Cloudflare Tunnel
- **Server**: Nakama 3.latest (Docker)
- **Database**: PostgreSQL 12.2-alpine
- **Tunnel**: Cloudflare Argo Tunnel (no port forwarding needed)

### Configuration Files

**Server Config**: `z:\appdata\nakama\data\config.yml`
- Server key: `hijbtdhbgiunhyojunbghijnhytgfrde`
- CORS: Allows `https://noahval.github.io` and `https://nakama.goasso.xyz`
- Google OAuth: Configured with client credentials

**Docker Compose**: `z:\appdata\nakama\docker-compose.yml`

---

## NakamaClient API

### Autoload Script

Location: `res://nakama_client.gd`

The `NakamaClient` autoload provides centralized access to Nakama features.

### Properties

```gdscript
# Connection state
NakamaClient.is_authenticated: bool
NakamaClient.user_id: String
NakamaClient.username: String

# Nakama objects
NakamaClient.client: NakamaClient
NakamaClient.session: NakamaSession
NakamaClient.socket: NakamaSocket
```

### Signals

```gdscript
signal authentication_succeeded(session_data: Dictionary)
signal authentication_failed(error: String)
signal connection_established()
signal connection_failed(error: String)
```

---

## Authentication

### Method 1: Device ID (Development/Testing)

**Use case**: Quick testing, local development, single-device users

```gdscript
func authenticate_with_device():
    var success = await NakamaClient.authenticate_device()
    if success:
        print("Authenticated! User ID: ", NakamaClient.user_id)
    else:
        print("Authentication failed")
```

**How it works:**
- Uses `OS.get_unique_id()` as device identifier
- Creates account automatically if doesn't exist
- Same device = same account

### Method 2: Google OAuth (Production)

**Use case**: Production, cross-device sync, social features

```gdscript
func authenticate_with_google():
    # 1. Get Google ID token from Google Sign-In plugin
    var google_token = await get_google_id_token()

    # 2. Authenticate with Nakama
    var success = await NakamaClient.authenticate_google(google_token)

    if success:
        print("Google auth successful!")
        print("User: ", NakamaClient.username)
```

**Requirements:**
- Google Sign-In plugin for Godot/HTML5
- Token must be ID token (not access token)
- OAuth client configured in Google Cloud Console

### Listening for Auth Events

```gdscript
func _ready():
    NakamaClient.authentication_succeeded.connect(_on_auth_success)
    NakamaClient.authentication_failed.connect(_on_auth_failed)

func _on_auth_success(session_data):
    print("Logged in as: ", session_data.username)
    # Load player data from cloud
    await NakamaClient.load_player_stats()

func _on_auth_failed(error):
    print("Login failed: ", error)
    # Show error popup to user
```

---

## Cloud Storage

### Storage Structure

Nakama storage uses a **collection/key/value** model:

```
Collection: "player_data"
    ├── Key: "stats" → { strength, constitution, etc. }
    ├── Key: "progress" → { current_level, completed_quests }
    └── Key: "inventory" → { items, coins }
```

### Writing Data

```gdscript
# Generic write
var data = {"level": 5, "coins": 1000}
await NakamaClient.write_storage("player_data", "progress", data)

# Helper for player stats
await NakamaClient.save_player_stats()
```

**What `save_player_stats()` saves:**
- All stat values (strength, constitution, etc.)
- All stat experience values
- Timestamp of last save

### Reading Data

```gdscript
# Generic read
var progress = await NakamaClient.read_storage("player_data", "progress")
if progress:
    print("Level: ", progress.level)
    print("Coins: ", progress.coins)

# Helper for player stats
var loaded = await NakamaClient.load_player_stats()
if loaded:
    print("Stats loaded from cloud!")
    # Global stats are now updated
```

### Storage Permissions

- **Read**: 2 (Owner read)
- **Write**: 1 (Owner write)
- User can only access their own data

---

## Common Patterns

### Pattern 1: Auto-Save on Stat Change

```gdscript
# In any script that modifies stats
func purchase_upgrade():
    Global.add_stat_exp("strength", 50)

    # Save to cloud after significant changes
    if NakamaClient.is_authenticated:
        await NakamaClient.save_player_stats()
```

### Pattern 2: Load on Game Start

```gdscript
# In loading_screen.gd or main menu
func _ready():
    # Authenticate first
    var auth_success = await NakamaClient.authenticate_device()

    if auth_success:
        # Try to load cloud save
        var loaded = await NakamaClient.load_player_stats()

        if loaded:
            print("Cloud save loaded!")
        else:
            print("No cloud save found, using local data")

    # Continue to game
    get_tree().change_scene_to_file("res://level1/scene.tscn")
```

### Pattern 3: Sync Before Scene Change

```gdscript
func go_to_next_level():
    # Save current progress before changing scenes
    if NakamaClient.is_authenticated:
        await NakamaClient.save_player_stats()

    Global.change_scene_with_check("res://level2/scene.tscn")
```

### Pattern 4: Periodic Auto-Save

```gdscript
# In an autoload or main game controller
func _ready():
    # Auto-save every 5 minutes
    var timer = Timer.new()
    timer.wait_time = 300.0  # 5 minutes
    timer.autostart = true
    timer.timeout.connect(_auto_save)
    add_child(timer)

func _auto_save():
    if NakamaClient.is_authenticated:
        await NakamaClient.save_player_stats()
        DebugLogger.log_info("AutoSave", "Progress saved to cloud")
```

---

## Error Handling

### Authentication Errors

```gdscript
func safe_authenticate():
    var success = await NakamaClient.authenticate_device()

    if not success:
        # Show user-friendly error
        show_error_popup("Could not connect to server. Playing offline.")
        # Continue with local save only
        return false

    return true
```

### Storage Errors

```gdscript
func safe_save():
    var result = await NakamaClient.save_player_stats()

    if result == null:
        # Save failed - data not authenticated or network issue
        DebugLogger.log_warning("CloudSave", "Save failed, will retry later")
        # Queue for retry or save locally
        return false

    return true
```

### Network Timeouts

```gdscript
# Set timeout for operations
func save_with_timeout():
    var save_task = NakamaClient.save_player_stats()
    var timeout_task = get_tree().create_timer(10.0).timeout

    var result = await race([save_task, timeout_task])

    if result == timeout_task:
        print("Save timed out!")
        return false

    return true
```

---

## Testing

### Local Testing

1. **Install Nakama plugin** from AssetLib
2. **Run game** in Godot editor
3. **Check console** for Nakama connection logs

```
[NakamaClient] Initializing Nakama client
[NakamaClient] Client created successfully
[NakamaClient] Server: nakama.goasso.xyz:443 (https)
[NakamaClient] Authenticating with device ID: abc123...
[NakamaClient] Authenticated successfully!
[NakamaClient] User ID: 7e5d5492-21c4-4eb4-9075-25a717ab9cc9
```

### Web Testing

1. **Export to HTML5**
2. **Upload to GitHub Pages**
3. **Test authentication** via browser console
4. **Verify CORS** is working (check browser Network tab)

### Debug Commands

```gdscript
# Force authentication
await NakamaClient.authenticate_device("test-user-123")

# Manually trigger save
await NakamaClient.save_player_stats()

# Check auth status
print("Authenticated: ", NakamaClient.is_authenticated)
print("User ID: ", NakamaClient.user_id)

# Test storage read/write
var test_data = {"test": "value", "number": 42}
await NakamaClient.write_storage("test", "data", test_data)
var loaded = await NakamaClient.read_storage("test", "data")
print("Loaded: ", loaded)
```

### Headless Testing

```bash
# Test Nakama connection without GUI
godot --headless --script res://test_scenes/nakama_test.gd
```

---

## Server Maintenance

### Restart Nakama Server

```bash
# On Unraid server
cd /mnt/user/appdata/nakama
docker-compose restart nakama
```

### View Logs

```bash
# Nakama logs
docker logs nakama-nakama-1 --tail 100 --follow

# Tunnel logs
docker logs nakama-tunnel --tail 50
```

### Check Server Health

```bash
# From any terminal
curl https://nakama.goasso.xyz/healthcheck
# Should return: {}

# Check API status
curl https://nakama.goasso.xyz/v2/status
```

### Update Config

1. Edit `z:\appdata\nakama\data\config.yml`
2. Restart containers via Compose Manager in Unraid
3. Verify changes in logs

---

## Security Notes

### DO NOT

❌ Commit server keys to Git
❌ Use production keys in debug builds
❌ Store sensitive data unencrypted in Nakama storage
❌ Trust client-side validation for important game logic

### DO

✅ Use environment variables for keys in CI/CD
✅ Validate all server-side operations
✅ Use Nakama's built-in permissions system
✅ Monitor server logs for suspicious activity
✅ Keep Nakama and dependencies updated

---

## API Reference

### NakamaClient Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `authenticate_device(device_id)` | `String` (optional) | `bool` | Auth with device ID |
| `authenticate_google(token)` | `String` | `bool` | Auth with Google OAuth |
| `connect_socket()` | - | `bool` | Connect realtime socket |
| `write_storage(collection, key, value)` | `String, String, Dictionary` | `Object` | Write data |
| `read_storage(collection, key)` | `String, String` | `Dictionary` | Read data |
| `save_player_stats()` | - | `Object` | Save all stats to cloud |
| `load_player_stats()` | - | `bool` | Load stats from cloud |

---

## Troubleshooting

### "Client created failed" / Cannot connect

**Check:**
1. Nakama plugin installed in `addons/` folder?
2. Server running? Test: `https://nakama.goasso.xyz/healthcheck`
3. Correct server key in `nakama_client.gd`?
4. CORS configured in server config?

### Authentication fails

**Check:**
1. Device ID generated correctly?
2. Google token valid (if using Google auth)?
3. Server logs for error details
4. Network connectivity

### Storage read/write fails

**Check:**
1. Authenticated before storage operation?
2. Correct collection/key names?
3. Data is valid JSON?
4. Check `NakamaClient.is_authenticated` before operations

---

**Version**: 1.0
**Last Updated**: 2025-10-31
**Maintainer**: Claude + Noah
