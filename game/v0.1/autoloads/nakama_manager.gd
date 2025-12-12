extends Node

# Stub NakamaManager for testing scene management
# Full implementation in Phase 1.19

var is_authenticated: bool = false

func _ready() -> void:
	print("NakamaManager initialized (stub)")
	DebugLogger.info("NakamaManager initialized (stub)", "NETWORK")

func save_game() -> void:
	print("[NakamaManager] Saving game to cloud (stub)")
	DebugLogger.info("Saving game to cloud (stub)", "NETWORK")
	# TODO: Implement actual cloud save logic in Phase 1.19

func load_game() -> void:
	print("[NakamaManager] Loading game from cloud (stub)")
	DebugLogger.info("Loading game from cloud (stub)", "NETWORK")
	# TODO: Implement actual cloud load logic in Phase 1.19
