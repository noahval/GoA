extends Node

# ===== DEV MODE =====
var dev_mode_enabled: bool = OS.is_debug_build()  # Auto-enable in debug builds

# ===== PERFORMANCE MONITORING =====
var show_performance_overlay: bool = false
var fps_history: Array[float] = []
const FPS_HISTORY_SIZE = 60

var performance_overlay: Control = null

# ===== CHEAT CODES =====
var cheats_enabled: bool = false

func _ready() -> void:
	if not dev_mode_enabled:
		return  # Don't load dev tools in production

	print("DevTools initialized (dev mode)")
	DebugLogger.info("DevTools initialized - dev mode enabled", "DEVTOOLS")

	# Create performance overlay
	_create_performance_overlay()

func _process(_delta: float) -> void:
	if not dev_mode_enabled:
		return

	# Update FPS tracking
	var current_fps = Engine.get_frames_per_second()
	fps_history.append(current_fps)
	if fps_history.size() > FPS_HISTORY_SIZE:
		fps_history.pop_front()

	# Update overlay if visible
	if show_performance_overlay and performance_overlay:
		_update_performance_overlay()

# Toggle performance overlay
func toggle_performance_overlay() -> void:
	show_performance_overlay = not show_performance_overlay
	if performance_overlay:
		performance_overlay.visible = show_performance_overlay

# Create performance overlay UI
func _create_performance_overlay() -> void:
	performance_overlay = Control.new()
	performance_overlay.name = "PerformanceOverlay"
	performance_overlay.visible = show_performance_overlay

	# Position in top-left corner
	performance_overlay.anchor_right = 0
	performance_overlay.anchor_bottom = 0
	performance_overlay.offset_right = 200
	performance_overlay.offset_bottom = 150

	var label = Label.new()
	label.name = "StatsLabel"
	performance_overlay.add_child(label)

	# Add to root (so it appears over all scenes)
	get_tree().root.call_deferred("add_child", performance_overlay)

# Update performance overlay text
func _update_performance_overlay() -> void:
	var label = performance_overlay.get_node("StatsLabel")
	if not label:
		return

	var avg_fps = 0.0
	for fps in fps_history:
		avg_fps += fps
	avg_fps /= fps_history.size()

	var memory_usage = OS.get_static_memory_usage() / 1024.0 / 1024.0  # MB

	label.text = "FPS: %d (avg: %.1f)\n" % [Engine.get_frames_per_second(), avg_fps]
	label.text += "Memory: %.1f MB\n" % memory_usage
	label.text += "Objects: %d\n" % Performance.get_monitor(Performance.OBJECT_COUNT)

# Give experience to stat (cheat)
func cheat_add_stat_exp(stat_name: String, amount: float) -> void:
	if not cheats_enabled:
		return

	Global.add_stat_exp(stat_name, amount)
	print("CHEAT: Added %.1f XP to %s" % [amount, stat_name])
	DebugLogger.warn("CHEAT: Added %.1f XP to %s" % [amount, stat_name], "DEVTOOLS")

# Set stat to specific level (cheat)
func cheat_set_stat_level(stat_name: String, level: int) -> void:
	if not cheats_enabled:
		return

	var stat_data = Global._get_stat_data(stat_name)
	if stat_data:
		Global.set(stat_data.stat_var, level)
		print("CHEAT: Set %s to level %d" % [stat_name, level])
		DebugLogger.warn("CHEAT: Set %s to level %d" % [stat_name, level], "DEVTOOLS")
