extends Node

# ===== AUDIO SETTINGS =====
var music_volume: float = 0.8:  # 0.0 to 1.0
	set(value):
		music_volume = clamp(value, 0.0, 1.0)
		_apply_audio_settings()

var sfx_volume: float = 1.0:  # 0.0 to 1.0
	set(value):
		sfx_volume = clamp(value, 0.0, 1.0)
		_apply_audio_settings()

var music_muted: bool = false:
	set(value):
		music_muted = value
		_apply_audio_settings()

var sfx_muted: bool = false:
	set(value):
		sfx_muted = value
		_apply_audio_settings()

# ===== GRAPHICS SETTINGS =====
var fullscreen: bool = false:
	set(value):
		fullscreen = value
		_apply_graphics_settings()

var vsync_enabled: bool = true:
	set(value):
		vsync_enabled = value
		_apply_graphics_settings()

var quality_preset: String = "medium":  # "low", "medium", "high"
	set(value):
		if value in ["low", "medium", "high"]:
			quality_preset = value
			_apply_graphics_settings()

# ===== SETTINGS FILE =====
const SETTINGS_PATH = "user://settings.json"

func _ready() -> void:
	load_settings()
	_apply_audio_settings()
	_apply_graphics_settings()

# Apply audio settings to audio buses
func _apply_audio_settings() -> void:
	var music_bus = AudioServer.get_bus_index("Music")
	var sfx_bus = AudioServer.get_bus_index("SFX")

	if music_bus >= 0:
		AudioServer.set_bus_mute(music_bus, music_muted)
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))

	if sfx_bus >= 0:
		AudioServer.set_bus_mute(sfx_bus, sfx_muted)
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume))

# Apply graphics settings
func _apply_graphics_settings() -> void:
	# Fullscreen
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	# VSync
	if vsync_enabled:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

	# Quality presets
	match quality_preset:
		"low":
			# Disable shadows, reduce effects
			pass
		"medium":
			# Balanced settings
			pass
		"high":
			# Max quality
			pass

# Save settings to file
func save_settings() -> void:
	var settings_data = {
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"music_muted": music_muted,
		"sfx_muted": sfx_muted,
		"fullscreen": fullscreen,
		"vsync_enabled": vsync_enabled,
		"quality_preset": quality_preset
	}

	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings_data, "\t"))
		file.close()

# Load settings from file
func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return  # Use defaults

	var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_string)

		if parse_result == OK:
			var data = json.data
			music_volume = data.get("music_volume", 0.8)
			sfx_volume = data.get("sfx_volume", 1.0)
			music_muted = data.get("music_muted", false)
			sfx_muted = data.get("sfx_muted", false)
			fullscreen = data.get("fullscreen", false)
			vsync_enabled = data.get("vsync_enabled", true)
			quality_preset = data.get("quality_preset", "medium")
