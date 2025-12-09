extends Node

# Stub LocalSaveManager for testing scene management
# Full implementation in Phase 1.x

func _ready() -> void:
	DebugLogger.info("LocalSaveManager initialized (stub)", "SAVE")

func save_game() -> void:
	DebugLogger.info("Saving game locally (stub)", "SAVE")
	# TODO: Implement actual save logic in Phase 1.x

func load_game() -> void:
	DebugLogger.info("Loading game locally (stub)", "SAVE")
	# TODO: Implement actual load logic in Phase 1.x
