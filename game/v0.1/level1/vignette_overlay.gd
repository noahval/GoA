extends ColorRect

const FLASH_DURATION: float = 0.3  # 300ms

func _ready():
	add_to_group("vignette")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Shader is assigned in scene, just ensure full screen coverage
	anchors_preset = Control.PRESET_FULL_RECT
	# Reset intensity to 0 in case scene was reloaded mid-flash
	_set_intensity(0.0)

func flash_red():
	var tween = create_tween()
	tween.tween_method(_set_intensity, 0.0, 0.5, 0.05)  # Fade in fast
	tween.tween_method(_set_intensity, 0.5, 0.0, 0.25)  # Fade out slower

func _set_intensity(value: float):
	material.set_shader_parameter("intensity", value)
