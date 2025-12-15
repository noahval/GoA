extends Control

func _ready():
	ResponsiveLayout.apply_to_scene(self)  # REQUIRED
	connect_navigation()

func connect_navigation():
	# Connect Back Nav button to return to Furnace
	var to_furnace_button = $AspectContainer/MainContainer/mainarea/Menu/ToFurnaceButton
	if to_furnace_button:
		to_furnace_button.pressed.connect(func(): navigate_to("furnace"))

func navigate_to(scene_id: String):
	var path = SceneNetwork.get_scene_path(scene_id)
	if path.is_empty():
		push_error("Unknown scene ID: " + scene_id)
		return
	Global.change_scene(path)
