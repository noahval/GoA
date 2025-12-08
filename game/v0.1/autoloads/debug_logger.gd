extends Node

# Stub DebugLogger for testing scene management
# Full implementation in Phase 1.21

func _ready() -> void:
	print("DebugLogger initialized (stub)")

func log_info(category: String, message: String) -> void:
	print("[%s] %s" % [category, message])

func log_warning(category: String, message: String) -> void:
	push_warning("[%s] %s" % [category, message])

func log_error(category: String, message: String) -> void:
	push_error("[%s] %s" % [category, message])

func log_scene_change(from_scene: String, to_scene: String, reason: String) -> void:
	var from_name = _get_scene_name(from_scene)
	var to_name = _get_scene_name(to_scene)
	var message = "Scene: %s -> %s (%s)" % [from_name, to_name, reason]
	log_info("SCENE", message)

func _get_scene_name(scene_path: String) -> String:
	if scene_path.is_empty():
		return "[none]"
	return scene_path.get_file().get_basename()
