extends Control

@onready var coal_pile_area: Area2D = $AspectContainer/MainContainer/mainarea/PlayArea/CoalPile/CoalPileArea
@onready var furnace_wall: Node2D = $AspectContainer/MainContainer/mainarea/PlayArea/FurnaceWall
@onready var playarea: Control = $AspectContainer/MainContainer/mainarea/PlayArea

var coal_pile_position: Vector2
var coal_pile_radius: float = 100.0

var furnace_line_x: float
var furnace_opening_top: float
var furnace_opening_bottom: float
var furnace_opening_height_percent: float = 0.20  # 20% of playarea height

func _ready():
	ResponsiveLayout.apply_to_scene(self)  # REQUIRED
	connect_navigation()
	# Defer physics setup until after layout is applied
	await get_tree().process_frame
	setup_physics_objects()

func setup_physics_objects():
	# Get playarea size
	var playarea_size = playarea.size

	# Calculate coal pile position (bottom-left corner)
	coal_pile_position = Vector2(100, playarea_size.y - 100)

	# Position coal pile
	$AspectContainer/MainContainer/mainarea/PlayArea/CoalPile.position = coal_pile_position

	# Calculate furnace positions
	var furnace_opening_height = playarea_size.y * furnace_opening_height_percent
	furnace_line_x = playarea_size.x - 50
	furnace_opening_top = (playarea_size.y / 2) - (furnace_opening_height / 2)
	furnace_opening_bottom = furnace_opening_top + furnace_opening_height

	# Position furnace wall
	furnace_wall.position.x = furnace_line_x

	# Setup vertical line visual with gap (draw top and bottom segments)
	var top_line = furnace_wall.get_node("TopLine")
	top_line.points = PackedVector2Array([
		Vector2(0, 0),
		Vector2(0, furnace_opening_top)
	])
	top_line.default_color = Color.BLACK
	top_line.width = 5.0

	var bottom_line = furnace_wall.get_node("BottomLine")
	bottom_line.points = PackedVector2Array([
		Vector2(0, furnace_opening_bottom),
		Vector2(0, playarea_size.y)
	])
	bottom_line.default_color = Color.BLACK
	bottom_line.width = 5.0

	# Position top obstacle
	var top_obstacle = furnace_wall.get_node("TopObstacle/CollisionShape2D")
	var top_height = furnace_opening_top
	top_obstacle.position = Vector2(0, top_height / 2)
	top_obstacle.shape.size = Vector2(40, top_height)

	# Position bottom obstacle
	var bottom_obstacle = furnace_wall.get_node("BottomObstacle/CollisionShape2D")
	var bottom_height = playarea_size.y - furnace_opening_bottom
	bottom_obstacle.position = Vector2(0, furnace_opening_bottom + (bottom_height / 2))
	bottom_obstacle.shape.size = Vector2(40, bottom_height)

func connect_navigation():
	# Connect navigation buttons (adjust based on .mmd connections)
	var to_mind_button = $AspectContainer/MainContainer/mainarea/Menu/ToMindButton
	if to_mind_button:
		to_mind_button.pressed.connect(func(): navigate_to("mind"))

func navigate_to(scene_id: String):
	var path = SceneNetwork.get_scene_path(scene_id)
	if path.is_empty():
		push_error("Unknown scene ID: " + scene_id)
		return
	Global.change_scene(path)
