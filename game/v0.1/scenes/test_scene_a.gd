extends Control

func _ready() -> void:
	print("Test Scene A loaded")
	print("Scene history size: ", Global.scene_history.size())

func _on_go_to_b_pressed() -> void:
	Global.change_scene("res://scenes/test_scene_b.tscn")

func _on_go_back_pressed() -> void:
	Global.go_back()

func _on_test_error_pressed() -> void:
	# This should trigger error recovery and load fallback scene
	Global.change_scene("res://scenes/nonexistent_scene.tscn")
