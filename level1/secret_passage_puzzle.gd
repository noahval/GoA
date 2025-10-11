extends Control

var break_time = 0.0
var max_break_time = 30.0

# Pipe puzzle variables
const GRID_SIZE = 5
const CELL_SIZE = 80
var grid = []  # 2D array of pipe pieces
var puzzle_container = null
var puzzle_solved = false

# Pipe types: 0=empty, 1=straight, 2=corner
# Rotation: 0=0°, 1=90°, 2=180°, 3=270°
var pipe_data = []

func _ready():
	break_time = Level1Vars.break_time_remaining
	max_break_time = break_time
	setup_puzzle()

func _process(delta):
	break_time -= delta
	Level1Vars.break_time_remaining = break_time
	if break_time <= 0:
		Level1Vars.break_time_remaining = 0.0
		get_tree().change_scene_to_file("res://level1/furnace.tscn")
	else:
		$VBoxContainer/BreakTimerPanel/BreakTimer.text = "Break Timer: " + str(ceil(break_time))
		# Update progress bar
		var progress_percent = (break_time / max_break_time) * 100.0
		$VBoxContainer/BreakTimerPanel/BreakTimerBar.value = progress_percent

func setup_puzzle():
	# Create puzzle container
	puzzle_container = Control.new()
	puzzle_container.position = Vector2(320, 200)  # Center of screen area
	add_child(puzzle_container)

	# Initialize grid
	for y in range(GRID_SIZE):
		var row = []
		for x in range(GRID_SIZE):
			row.append({"type": 0, "rotation": 0})
		grid.append(row)

	# Create a simple puzzle path from top-left to bottom-right
	# You can customize this to create different puzzles
	generate_puzzle()

	# Create visual grid
	create_visual_grid()

	# Update solve button
	$VBoxContainer/LabelPanel/Label.text = "Rotate pipes to connect steam!"
	update_pipes_label()

func update_pipes_label():
	$VBoxContainer/PipesPanel/PipesLabel.text = "Pipes: " + str(Level1Vars.pipes)

func generate_puzzle():
	# Simple puzzle: create a path from (0,0) to (4,4)
	# Path: right, down, right, down, right, down, right, down, right
	var path_coords = [
		[0, 0], [1, 0], [2, 0], [2, 1], [2, 2],
		[3, 2], [4, 2], [4, 3], [4, 4]
	]

	# Place corner at (0,0) - start
	grid[0][0] = {"type": 2, "rotation": 0}  # corner pointing right-down

	# Straight pieces
	grid[0][1] = {"type": 1, "rotation": 0}  # horizontal
	grid[0][2] = {"type": 2, "rotation": 1}  # corner down-left
	grid[1][2] = {"type": 1, "rotation": 1}  # vertical
	grid[2][2] = {"type": 2, "rotation": 2}  # corner left-up becomes right-down
	grid[2][3] = {"type": 1, "rotation": 0}  # horizontal
	grid[2][4] = {"type": 2, "rotation": 1}  # corner
	grid[3][4] = {"type": 1, "rotation": 1}  # vertical
	grid[4][4] = {"type": 2, "rotation": 2}  # corner - end

	# Add some random extra pieces
	for i in range(8):
		var rx = randi() % GRID_SIZE
		var ry = randi() % GRID_SIZE
		if grid[ry][rx]["type"] == 0:
			grid[ry][rx] = {"type": randi() % 2 + 1, "rotation": randi() % 4}

	# Randomize all rotations to make it a puzzle
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			if grid[y][x]["type"] > 0:
				grid[y][x]["rotation"] = randi() % 4

func create_visual_grid():
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			var cell = Panel.new()
			cell.custom_minimum_size = Vector2(CELL_SIZE - 4, CELL_SIZE - 4)
			cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
			cell.size = Vector2(CELL_SIZE - 4, CELL_SIZE - 4)

			# Add pipe visual
			var pipe_visual = Control.new()
			pipe_visual.set_meta("grid_x", x)
			pipe_visual.set_meta("grid_y", y)
			pipe_visual.custom_minimum_size = Vector2(CELL_SIZE - 4, CELL_SIZE - 4)
			pipe_visual.size = Vector2(CELL_SIZE - 4, CELL_SIZE - 4)

			# Make it clickable
			var button = Button.new()
			button.custom_minimum_size = Vector2(CELL_SIZE - 4, CELL_SIZE - 4)
			button.flat = true
			button.set_meta("grid_x", x)
			button.set_meta("grid_y", y)
			button.pressed.connect(_on_pipe_clicked.bind(x, y))

			cell.add_child(pipe_visual)
			cell.add_child(button)
			puzzle_container.add_child(cell)

			update_pipe_visual(x, y)

func update_pipe_visual(x, y):
	var cell_index = y * GRID_SIZE + x
	var cell = puzzle_container.get_child(cell_index)
	var pipe_visual = cell.get_child(0)

	# Clear previous drawing
	pipe_visual.queue_redraw()

	# Set up drawing callback
	if not pipe_visual.is_connected("draw", _draw_pipe):
		pipe_visual.draw.connect(_draw_pipe.bind(pipe_visual, x, y))
	pipe_visual.queue_redraw()

func _draw_pipe(pipe_visual: Control, x: int, y: int):
	var pipe = grid[y][x]
	if pipe["type"] == 0:
		return

	var center = Vector2(CELL_SIZE / 2 - 2, CELL_SIZE / 2 - 2)
	var color = Color.STEEL_BLUE
	var width = 12.0

	# Draw based on type and rotation
	if pipe["type"] == 1:  # Straight pipe
		if pipe["rotation"] % 2 == 0:  # Horizontal
			pipe_visual.draw_line(Vector2(0, center.y), Vector2(CELL_SIZE - 4, center.y), color, width)
		else:  # Vertical
			pipe_visual.draw_line(Vector2(center.x, 0), Vector2(center.x, CELL_SIZE - 4), color, width)

	elif pipe["type"] == 2:  # Corner pipe
		var rot = pipe["rotation"]
		if rot == 0:  # Top-left corner (connects right and down)
			pipe_visual.draw_line(Vector2(center.x, 0), center, color, width)
			pipe_visual.draw_line(center, Vector2(CELL_SIZE - 4, center.y), color, width)
		elif rot == 1:  # Top-right corner (connects down and left)
			pipe_visual.draw_line(Vector2(center.x, 0), center, color, width)
			pipe_visual.draw_line(center, Vector2(0, center.y), color, width)
		elif rot == 2:  # Bottom-right corner (connects left and up)
			pipe_visual.draw_line(Vector2(0, center.y), center, color, width)
			pipe_visual.draw_line(center, Vector2(center.x, CELL_SIZE - 4), color, width)
		elif rot == 3:  # Bottom-left corner (connects up and right)
			pipe_visual.draw_line(Vector2(center.x, CELL_SIZE - 4), center, color, width)
			pipe_visual.draw_line(center, Vector2(CELL_SIZE - 4, center.y), color, width)

	# Draw start indicator (green)
	if x == 0 and y == 0:
		pipe_visual.draw_circle(center, 8, Color.GREEN)

	# Draw end indicator (red)
	if x == GRID_SIZE - 1 and y == GRID_SIZE - 1:
		pipe_visual.draw_circle(center, 8, Color.RED)

func _on_pipe_clicked(x: int, y: int):
	if puzzle_solved:
		return

	# Rotate the pipe
	if grid[y][x]["type"] > 0:
		grid[y][x]["rotation"] = (grid[y][x]["rotation"] + 1) % 4
		update_pipe_visual(x, y)

		# Check if puzzle is solved
		if check_solution():
			puzzle_solved = true
			$VBoxContainer/LabelPanel/Label.text = "Puzzle Solved!"
			show_train_heart_button()

func check_solution() -> bool:
	# Start from (0,0) and try to reach (4,4)
	var visited = {}
	return flood_fill(0, 0, -1, visited)

func flood_fill(x: int, y: int, came_from_dir: int, visited: Dictionary) -> bool:
	# Check if we reached the goal
	if x == GRID_SIZE - 1 and y == GRID_SIZE - 1:
		return true

	# Mark as visited
	var key = str(x) + "," + str(y)
	if key in visited:
		return false
	visited[key] = true

	# Get current pipe
	var pipe = grid[y][x]
	if pipe["type"] == 0:
		return false

	# Get connections for this pipe
	var connections = get_pipe_connections(pipe["type"], pipe["rotation"])

	# Direction mapping: 0=up, 1=right, 2=down, 3=left
	var dx = [0, 1, 0, -1]
	var dy = [-1, 0, 1, 0]
	var opposite_dir = [2, 3, 0, 1]  # Opposite directions

	# Try each connection
	for dir in connections:
		# Don't go back where we came from
		if came_from_dir != -1 and dir == opposite_dir[came_from_dir]:
			continue

		var nx = x + dx[dir]
		var ny = y + dy[dir]

		# Check bounds
		if nx < 0 or nx >= GRID_SIZE or ny < 0 or ny >= GRID_SIZE:
			continue

		# Check if next pipe connects back to us
		var next_pipe = grid[ny][nx]
		if next_pipe["type"] == 0:
			continue

		var next_connections = get_pipe_connections(next_pipe["type"], next_pipe["rotation"])
		if not opposite_dir[dir] in next_connections:
			continue

		# Recursively check
		if flood_fill(nx, ny, dir, visited):
			return true

	return false

func get_pipe_connections(type: int, rotation: int) -> Array:
	# Returns array of directions this pipe connects to
	# 0=up, 1=right, 2=down, 3=left
	var connections = []

	if type == 1:  # Straight pipe
		if rotation % 2 == 0:  # Horizontal
			connections = [1, 3]  # right and left
		else:  # Vertical
			connections = [0, 2]  # up and down

	elif type == 2:  # Corner pipe
		if rotation == 0:  # connects up and right
			connections = [0, 1]
		elif rotation == 1:  # connects right and down
			connections = [1, 2]
		elif rotation == 2:  # connects down and left
			connections = [2, 3]
		elif rotation == 3:  # connects left and up
			connections = [3, 0]

	return connections

func show_train_heart_button():
	# Create a button to enter the train heart
	var enter_button = Button.new()
	enter_button.text = "Enter Train Heart"
	enter_button.custom_minimum_size = Vector2(200, 40)
	enter_button.pressed.connect(_on_enter_train_heart_pressed)
	$VBoxContainer.add_child(enter_button)
	$VBoxContainer.move_child(enter_button, $VBoxContainer.get_child_count() - 2)  # Place before back button

func _on_enter_train_heart_pressed():
	get_tree().change_scene_to_file("res://level1/train_heart.tscn")

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://level1/shop.tscn")
