extends Control

func _ready():
	# Apply responsive layout to this scene
	ResponsiveLayout.apply_to_scene(self)

	# Add debug info to show scale and dimensions
	var debug_info = Label.new()
	debug_info.name = "DebugInfo"
	debug_info.position = Vector2(10, 10)
	debug_info.add_theme_color_override("font_color", Color.WHITE)
	debug_info.add_theme_color_override("font_outline_color", Color.BLACK)
	debug_info.add_theme_constant_override("outline_size", 2)
	$AspectContainer/MainContainer.add_child(debug_info)

	# Update debug info every frame
	set_process(true)

func _process(_delta):
	var debug_info = $AspectContainer/MainContainer.get_node_or_null("DebugInfo")
	if debug_info:
		var viewport_size = get_viewport().get_visible_rect().size
		var auto_scale = ResponsiveLayout.get_auto_scale()
		var font_size = ResponsiveLayout.get_scaled_font_size()
		var notif_height = ResponsiveLayout.get_notification_bar_height()

		debug_info.text = "Viewport: %dx%d | Scale: %.2fx | Font: %dpx | NotifBar: %dpx" % [
			viewport_size.x, viewport_size.y,
			auto_scale,
			font_size,
			notif_height
		]
