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
5. [Local Browser Storage](#local-browser-storage)
6. [Common Patterns](#common-patterns)
7. [Error Handling](#error-handling)
8. [Testing](#testing)

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
NakamaManager.is_authenticated: bool
NakamaManager.user_id: String
NakamaManager.username: String

# Nakama objects
NakamaManager.client: NakamaClient
NakamaManager.session: NakamaSession
NakamaManager.socket: NakamaSocket
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
    var success = await NakamaManager.authenticate_device()
    if success:
        print("Authenticated! User ID: ", NakamaManager.user_id)
    else:
        print("Authentication failed")
```

**How it works:**
- Uses `OS.get_unique_id()` as device identifier
- Creates account automatically if doesn't exist
- Same device = same account

### Method 2: Email/Password (Production)

**Use case**: Simple user accounts, cross-device sync, no external dependencies

```gdscript
func authenticate_with_email():
    # Create new account
    var success = await NakamaManager.authenticate_email("username", "password123", true)
    if success:
        print("Account created!")

    # Login to existing account
    var success = await NakamaManager.authenticate_email("username", "password123", false)
    if success:
        print("Logged in!")
        print("User: ", NakamaManager.username)
```

**How it works:**
- Uses email as username identifier
- Password stored securely by Nakama
- Set `create` parameter to `true` for new accounts, `false` for login
- Username displayed in game comes from email field

**Requirements:**
- Username: 3+ characters
- Password: 6+ characters (recommended)
- No external dependencies needed

### Method 3: Google OAuth (Production)

**Use case**: Social features, web-based authentication

```gdscript
func authenticate_with_google():
    # 1. Get Google ID token from Google Sign-In plugin
    var google_token = await get_google_id_token()

    # 2. Authenticate with Nakama
    var success = await NakamaManager.authenticate_google(google_token)

    if success:
        print("Google auth successful!")
        print("User: ", NakamaManager.username)
```

**Requirements:**
- Google Sign-In plugin for Godot/HTML5
- Token must be ID token (not access token)
- OAuth client configured in Google Cloud Console

### Listening for Auth Events

```gdscript
func _ready():
    NakamaManager.authentication_succeeded.connect(_on_auth_success)
    NakamaManager.authentication_failed.connect(_on_auth_failed)

func _on_auth_success(session_data):
    print("Logged in as: ", session_data.username)
    # Load player data from cloud
    await NakamaManager.load_player_stats()

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
await NakamaManager.write_storage("player_data", "progress", data)

# Helper for player stats
await NakamaManager.save_player_stats()
```

**What `save_player_stats()` saves:**
- All stat values (strength, constitution, etc.)
- All stat experience values
- Timestamp of last save

### Reading Data

```gdscript
# Generic read
var progress = await NakamaManager.read_storage("player_data", "progress")
if progress:
    print("Level: ", progress.level)
    print("Coins: ", progress.coins)

# Helper for player stats
var loaded = await NakamaManager.load_player_stats()
if loaded:
    print("Stats loaded from cloud!")
    # Global stats are now updated
```

### Storage Permissions

- **Read**: 2 (Owner read)
- **Write**: 1 (Owner write)
- User can only access their own data

---

## Local Browser Storage

**Purpose**: Offline save/load system for players who skip cloud authentication
**Autoload**: `LocalSaveManager`
**Storage**: Browser IndexedDB via Godot's FileAccess API
**File**: `user://local_save.json`

### When to Use Local vs Cloud Saves

| Feature | Cloud Saves | Local Browser Saves |
|---------|-------------|---------------------|
| **Cross-device sync** | ✅ Yes | ❌ No |
| **Requires authentication** | ✅ Yes | ❌ No |
| **Survives browser clear** | ✅ Yes | ⚠️ No (clears with IndexedDB) |
| **Works offline** | ❌ No | ✅ Yes |
| **Backend dependency** | ✅ Needs Nakama | ❌ None |
| **Use case** | Online players | Offline/casual players |

### LocalSaveManager API

```gdscript
# Save current game state
LocalSaveManager.save_game() -> bool

# Load saved game state
LocalSaveManager.load_game() -> bool

# Check if save exists
LocalSaveManager.has_save() -> bool

# Delete local save
LocalSaveManager.delete_save() -> bool
```

### What Gets Saved

**Global Stats:**
- All stats (strength, constitution, dexterity, wisdom, intelligence, charisma)
- All experience values (strength_exp, constitution_exp, etc.)
- Dev mode settings

**Level1Vars:**
- Resources (coal, coins, components, mechanisms, pipes)
- Upgrades (shovel_lvl, plow_lvl, auto_shovel upgrades, overseer_lvl)
- Story flags (barkeep_bribed, shopkeep_bribed, heart_taken, whisper_triggered, door_discovered)
- Progress (stolen_coal, stolen_writs, correct_answers, suspicion)
- Timers/Buffs (break_time, stamina, cooldowns, buff durations)
- Puzzle state (pipe_puzzle_grid)

### Usage Patterns

#### Pattern 1: Save on Skip Login

The skip button automatically handles saves:

```gdscript
# In login_popup.gd
func _on_skip_pressed():
    if LocalSaveManager.has_save():
        # Load existing save
        LocalSaveManager.load_game()
    else:
        # Create initial save
        LocalSaveManager.save_game()

    skip_login.emit()
```

#### Pattern 2: Manual Save Button

```gdscript
# In settings or pause menu
func _on_save_button_pressed():
    var success = LocalSaveManager.save_game()

    if success:
        show_notification("Game saved!")
    else:
        show_notification("Save failed!", true)
```

#### Pattern 3: Auto-Save on Scene Change

```gdscript
# In global.gd or scene transition handler
func change_scene_with_save(scene_path: String):
    # Save before transitioning
    LocalSaveManager.save_game()

    # Then change scene
    change_scene_with_check(get_tree(), scene_path)
```

#### Pattern 4: Periodic Auto-Save

```gdscript
# In an autoload or main controller
func _ready():
    var autosave_timer = Timer.new()
    autosave_timer.wait_time = 60.0  # Save every minute
    autosave_timer.autostart = true
    autosave_timer.timeout.connect(_on_autosave)
    add_child(autosave_timer)

func _on_autosave():
    # Only save locally if not using cloud
    if not NakamaManager.is_authenticated:
        LocalSaveManager.save_game()
        DebugLogger.log_info("AutoSave", "Local save created")
```

### Save File Structure

```json
{
    "version": "1.0",
    "timestamp": 1730423042,
    "global": {
        "strength": 5.0,
        "constitution": 3.0,
        "dexterity": 2.0,
        "wisdom": 1.0,
        "intelligence": 4.0,
        "charisma": 1.0,
        "strength_exp": 250.5,
        "constitution_exp": 100.0,
        ...
    },
    "level1_vars": {
        "coal": 1500.0,
        "coins": 750.0,
        "components": 5,
        "mechanisms": 2,
        "stolen_coal": 1,
        "suspicion": 25,
        ...
    }
}
```

### Browser Storage Location

- **Chrome/Edge**: IndexedDB → `godot_fs` → `user://local_save.json`
- **Firefox**: IndexedDB → Application Storage → `user://local_save.json`
- **Safari**: WebKit IndexedDB → `user://local_save.json`

To view in browser dev tools:
1. Open DevTools (F12)
2. Go to **Application** tab (Chrome/Edge) or **Storage** tab (Firefox)
3. Expand **IndexedDB** → **godot_fs** → **files**
4. Look for `/userfs/local_save.json`

### Hybrid Pattern: Cloud + Local Fallback

```gdscript
# Use cloud if authenticated, otherwise local
func save_game_progress():
    if NakamaManager.is_authenticated:
        # Save to cloud
        await NakamaManager.save_player_stats()
        DebugLogger.log_info("SaveGame", "Saved to cloud")
    else:
        # Fall back to local save
        LocalSaveManager.save_game()
        DebugLogger.log_info("SaveGame", "Saved locally")

func load_game_progress():
    if NakamaManager.is_authenticated:
        # Load from cloud
        var loaded = await NakamaManager.load_player_stats()
        if loaded:
            DebugLogger.log_success("LoadGame", "Loaded from cloud")
    else:
        # Load from local save
        if LocalSaveManager.has_save():
            LocalSaveManager.load_game()
            DebugLogger.log_success("LoadGame", "Loaded from local storage")
```

### Migrating Local Save to Cloud

```gdscript
# When user authenticates after playing offline
func migrate_local_to_cloud():
    if LocalSaveManager.has_save():
        # Current stats are already loaded from local save
        # Just save them to cloud
        var success = await NakamaManager.save_player_stats()

        if success:
            show_notification("Progress synced to cloud!")
            # Optionally delete local save
            LocalSaveManager.delete_save()
        else:
            show_notification("Failed to sync. Local save kept.", true)
```

### Error Handling

```gdscript
func safe_local_save():
    var success = LocalSaveManager.save_game()

    if not success:
        # File system error (rare in browsers)
        DebugLogger.log_error("LocalSave", "Save failed - check browser storage quota")
        show_notification("Save failed. Check browser storage settings.", true)
        return false

    return true

func safe_local_load():
    if not LocalSaveManager.has_save():
        DebugLogger.log_info("LocalSave", "No save file found, using defaults")
        return false

    var success = LocalSaveManager.load_game()

    if not success:
        DebugLogger.log_error("LocalSave", "Load failed - corrupt save file?")
        show_notification("Could not load save. Starting fresh.", true)
        # Optionally delete corrupt save
        LocalSaveManager.delete_save()
        return false

    return true
```

### Debugging Local Saves

```gdscript
# Check if save exists
print("Has save: ", LocalSaveManager.has_save())

# Force save current state
LocalSaveManager.save_game()

# Dump save file contents (in browser console)
# 1. Open DevTools → Application → IndexedDB → godot_fs
# 2. Find /userfs/local_save.json
# 3. Click to view JSON contents

# Delete and reset
LocalSaveManager.delete_save()
print("Save deleted, restarting with defaults")
```

---

## Common Patterns

### Pattern 1: Auto-Save on Stat Change

```gdscript
# In any script that modifies stats
func purchase_upgrade():
    Global.add_stat_exp("strength", 50)

    # Save to cloud after significant changes
    if NakamaManager.is_authenticated:
        await NakamaManager.save_player_stats()
```

### Pattern 2: Load on Game Start

```gdscript
# In loading_screen.gd or main menu
func _ready():
    # Authenticate first
    var auth_success = await NakamaManager.authenticate_device()

    if auth_success:
        # Try to load cloud save
        var loaded = await NakamaManager.load_player_stats()

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
    if NakamaManager.is_authenticated:
        await NakamaManager.save_player_stats()

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
    if NakamaManager.is_authenticated:
        await NakamaManager.save_player_stats()
        DebugLogger.log_info("AutoSave", "Progress saved to cloud")
```

---

## Error Handling

### Authentication Errors

```gdscript
func safe_authenticate():
    var success = await NakamaManager.authenticate_device()

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
    var result = await NakamaManager.save_player_stats()

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
    var save_task = NakamaManager.save_player_stats()
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
await NakamaManager.authenticate_device("test-user-123")

# Manually trigger save
await NakamaManager.save_player_stats()

# Check auth status
print("Authenticated: ", NakamaManager.is_authenticated)
print("User ID: ", NakamaManager.user_id)

# Test storage read/write
var test_data = {"test": "value", "number": 42}
await NakamaManager.write_storage("test", "data", test_data)
var loaded = await NakamaManager.read_storage("test", "data")
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
| `authenticate_email(email, password, create)` | `String, String, bool` | `bool` | Auth with username/password |
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
4. Check `NakamaManager.is_authenticated` before operations

---

**Version**: 1.1 (Added Local Browser Storage)
**Last Updated**: 2025-10-31
**Maintainer**: Claude + Noah
