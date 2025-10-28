extends Control

# Scene follows formatting guidelines from:
# - RESPONSIVE_LAYOUT_GUIDE.md (element heights, spacing, responsive behavior)
# - SCENE_TEMPLATE_GUIDE.md (three-panel layout structure)
# - POPUP_SYSTEM_GUIDE.md (popup usage if needed)
# All menu elements use LANDSCAPE_ELEMENT_HEIGHT = 40px (see RESPONSIVE_LAYOUT_GUIDE.md)

var break_time = 0.0
var max_break_time = 30.0

# Pipe puzzle variables
const GRID_SIZE = 5
const CELL_SIZE = 80
var grid = []  # 2D array of pipe pieces
var puzzle_container = null
var puzzle_solved = false
var energized_cells = {}  # Tracks which cells are connected to the power source
var is_destination_energized = false  # Tracks if destination is powered

# Pipe types: 0=empty, 1=straight, 2=corner
# Rotation: 0=0°, 1=90°, 2=180°, 3=270°
var pipe_data = []

func _ready():
	# Set the actual maximum break time (not the remaining time)
	max_break_time = Level1Vars.starting_break_time + Level1Vars.overseer_lvl

	if Level1Vars.break_time_remaining > 0:
		break_time = Level1Vars.break_time_remaining
	else:
		break_time = max_break_time

	# Initialize the progress bar to the current percentage
	var progress_percent = (break_time / max_break_time) * 100.0
	var break_timer_bar = find_node_recursive(self, "BreakTimerBar")
	if break_timer_bar:
		break_timer_bar.value = progress_percent

	# Use ResponsiveLayout for orientation handling
	ResponsiveLayout.apply_to_scene(self)

	# Setup puzzle after layout is applied
	call_deferred("_delayed_setup")


func _delayed_setup():
	print("=== Secret Passage Puzzle Setup ===")

	# Get reference to puzzle container (it's now in CenterArea or MiddleArea depending on orientation)
	var viewport_size = get_viewport().get_visible_rect().size
	var is_portrait = viewport_size.y > viewport_size.x

	# Calculate puzzle base size (grid + indicators)
	var puzzle_base_size = GRID_SIZE * CELL_SIZE + 80  # 480px total

	# Find puzzle container in the appropriate location and scale it
	if is_portrait:
		# In portrait, reparent to MiddleArea if not already there
		puzzle_container = get_node_or_null("VBoxContainer/MiddleArea/PuzzleContainer")
		if not puzzle_container:
			# It's still in CenterArea, need to move it
			puzzle_container = get_node_or_null("HBoxContainer/CenterArea/PuzzleContainer")
			if puzzle_container:
				var middle_area = get_node_or_null("VBoxContainer/MiddleArea")
				if middle_area:
					# Reset all transforms BEFORE reparenting to avoid accumulated offsets
					puzzle_container.rotation = 0
					puzzle_container.scale = Vector2.ONE
					puzzle_container.position = Vector2.ZERO
					puzzle_container.pivot_offset = Vector2.ZERO

					puzzle_container.reparent(middle_area)
					print("Reparented PuzzleContainer to MiddleArea for portrait mode")

		# Calculate available space in portrait mode
		# Use 85% of smaller dimension (width or available height) to leave margin
		var available_width = viewport_size.x * 0.85
		var available_height = viewport_size.y * 0.5  # Rough estimate of MiddleArea height
		var available_size = min(available_width, available_height)

		# Calculate scale factor
		var scale_factor = available_size / puzzle_base_size
		scale_factor = clamp(scale_factor, 0.8, 2.0)  # Min 0.8x, max 2x

		# Completely reset layout mode to manual positioning
		puzzle_container.set_anchors_preset(Control.PRESET_CENTER, false)  # false = don't resize

		# Manually set all anchors to 0.5 (center)
		puzzle_container.anchor_left = 0.5
		puzzle_container.anchor_top = 0.5
		puzzle_container.anchor_right = 0.5
		puzzle_container.anchor_bottom = 0.5

		# The visual content spans from (-40,-40) to (440, 440) inside the container
		# Visual center is at (200, 200), container geometric center would be at (240, 240)
		# Total offset needed: -40 in both directions

		# Set the container size to match puzzle_base_size
		var half_base = puzzle_base_size / 2.0
		puzzle_container.offset_left = -half_base
		puzzle_container.offset_top = -half_base
		puzzle_container.offset_right = half_base
		puzzle_container.offset_bottom = half_base

		# Set pivot for scaling from the geometric center of the container
		puzzle_container.pivot_offset = Vector2(half_base, half_base)

		# Apply scale
		puzzle_container.scale = Vector2(scale_factor, scale_factor)

		# Adjust position to compensate for off-center visual content
		# Visual center is at (200, 200) but container center is at (240, 240)
		# Experimenting with offset - if still too far right, increase the negative X value
		var x_offset = -60.0  # Try more leftward shift
		var y_offset = -40.0
		puzzle_container.position = Vector2(x_offset, y_offset) * scale_factor
		puzzle_container.rotation = 0

		puzzle_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
		puzzle_container.grow_vertical = Control.GROW_DIRECTION_BOTH

		print("Portrait mode: scale factor = ", scale_factor, " (available: ", available_size, "px)")
		print("Portrait mode: anchors = ", puzzle_container.anchor_left, ",", puzzle_container.anchor_top)
		print("Portrait mode: offsets = ", puzzle_container.offset_left, ",", puzzle_container.offset_top, " to ", puzzle_container.offset_right, ",", puzzle_container.offset_bottom)
		print("Portrait mode: position = ", puzzle_container.position)
		print("Portrait mode: scale = ", puzzle_container.scale)
	else:
		# In landscape, make sure it's in CenterArea
		puzzle_container = get_node_or_null("HBoxContainer/CenterArea/PuzzleContainer")
		if not puzzle_container:
			# It's in MiddleArea, need to move it back
			puzzle_container = get_node_or_null("VBoxContainer/MiddleArea/PuzzleContainer")
			if puzzle_container:
				var center_area = get_node_or_null("HBoxContainer/CenterArea")
				if center_area:
					puzzle_container.reparent(center_area)
					print("Reparented PuzzleContainer to CenterArea for landscape mode")

		# Use PRESET_CENTER to properly center the container
		puzzle_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)

		# Set size directly
		puzzle_container.size = Vector2(puzzle_base_size, puzzle_base_size)
		puzzle_container.custom_minimum_size = Vector2(puzzle_base_size, puzzle_base_size)

		# Set pivot for scaling from the geometric center
		puzzle_container.pivot_offset = Vector2(puzzle_base_size / 2.0, puzzle_base_size / 2.0)

		# In landscape, use CenterArea size to determine scale
		var center_area = get_node_or_null("HBoxContainer/CenterArea")
		var scale_factor = 1.0
		if center_area:
			# Wait one frame for layout to settle
			await get_tree().process_frame
			var center_rect = center_area.get_rect()
			var available_size = min(center_rect.size.x, center_rect.size.y) * 0.85
			scale_factor = available_size / puzzle_base_size
			scale_factor = clamp(scale_factor, 0.8, 1.5)  # Smaller max for landscape

			print("Landscape mode: scale factor = ", scale_factor, " (center area: ", center_rect.size, ")")
		else:
			# Fallback: use default scale
			scale_factor = 1.0

		# Apply scale
		puzzle_container.scale = Vector2(scale_factor, scale_factor)

		# Adjust position to compensate for off-center visual content
		puzzle_container.position = Vector2(-40, -40) * scale_factor
		puzzle_container.rotation = 0

		puzzle_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
		puzzle_container.grow_vertical = Control.GROW_DIRECTION_BOTH

	print("Puzzle container exists: ", puzzle_container != null)
	if puzzle_container:
		print("Puzzle container parent: ", puzzle_container.get_parent().name)
		print("Puzzle container scale: ", puzzle_container.scale)
		print("Puzzle container anchors: ", puzzle_container.anchor_left, ", ", puzzle_container.anchor_top)
		print("Puzzle container offsets: ", puzzle_container.offset_left, ", ", puzzle_container.offset_top)

	# Setup puzzle (creates the visual elements)
	setup_puzzle()
	update_place_pipe_button()
	add_developer_skip_button()

# Removed manual positioning - puzzle now uses anchors in CenterArea/MiddleArea for automatic centering

func find_node_recursive(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	for child in node.get_children():
		var result = find_node_recursive(child, node_name)
		if result:
			return result
	return null

func _process(delta):
	break_time -= delta
	Level1Vars.break_time_remaining = break_time

	# Update progress bar based on current break time
	var progress_percent = (break_time / max_break_time) * 100.0
	var break_timer_bar = find_node_recursive(self, "BreakTimerBar")
	if break_timer_bar:
		break_timer_bar.value = progress_percent

	if break_time <= 0:
		Level1Vars.break_time_remaining = 0.0
		Global.change_scene_with_check(get_tree(), "res://level1/furnace.tscn")

	# Update developer button visibility
	var dev_button = find_node_recursive(self, "DeveloperSkipButton")
	if dev_button:
		dev_button.visible = Global.dev_speed_mode

func setup_puzzle():
	# Initialize grid - load from saved state or start with no pipes
	if Level1Vars.pipe_puzzle_grid.size() > 0:
		# Load saved grid
		grid = []
		for y in range(GRID_SIZE):
			var row = []
			for x in range(GRID_SIZE):
				# Deep copy the saved data
				var saved_cell = Level1Vars.pipe_puzzle_grid[y][x]
				row.append({"type": saved_cell["type"], "rotation": saved_cell["rotation"]})
			grid.append(row)
	else:
		# Initialize empty grid
		for y in range(GRID_SIZE):
			var row = []
			for x in range(GRID_SIZE):
				row.append({"type": 0, "rotation": 0})
			grid.append(row)

	# Create visual grid
	create_visual_grid()

	# Add orange indicators outside the grid
	create_corner_indicators()

	# Update pipes label
	update_pipes_label()

	# Update energized state for initial grid
	update_energized_cells()

func update_pipes_label():
	var pipes_label = find_node_recursive(self, "PipesLabel")
	if pipes_label:
		pipes_label.text = "Pipes: " + str(Level1Vars.pipes)
	else:
		print("WARNING: PipesLabel not found")

func save_grid_state():
	# Deep copy the grid to Level1Vars
	Level1Vars.pipe_puzzle_grid = []
	for y in range(GRID_SIZE):
		var row = []
		for x in range(GRID_SIZE):
			row.append({"type": grid[y][x]["type"], "rotation": grid[y][x]["rotation"]})
		Level1Vars.pipe_puzzle_grid.append(row)

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

func create_corner_indicators():
	# Create top-left indicator (outside the grid)
	var top_left_indicator = Control.new()
	top_left_indicator.custom_minimum_size = Vector2(30, 30)
	top_left_indicator.position = Vector2(-40, -40)  # Outside the grid, top-left
	top_left_indicator.size = Vector2(30, 30)
	top_left_indicator.draw.connect(_draw_top_left_indicator.bind(top_left_indicator))
	puzzle_container.add_child(top_left_indicator)
	top_left_indicator.queue_redraw()

	# Create bottom-right indicator (outside the grid)
	var bottom_right_indicator = Control.new()
	bottom_right_indicator.custom_minimum_size = Vector2(30, 30)
	bottom_right_indicator.position = Vector2(GRID_SIZE * CELL_SIZE + 10, GRID_SIZE * CELL_SIZE + 10)  # Outside the grid, bottom-right
	bottom_right_indicator.size = Vector2(30, 30)
	bottom_right_indicator.draw.connect(_draw_bottom_right_indicator.bind(bottom_right_indicator))
	puzzle_container.add_child(bottom_right_indicator)
	bottom_right_indicator.queue_redraw()

func _draw_top_left_indicator(control: Control):
	# Draw an orange circle/dot indicator
	var center = Vector2(15, 15)
	control.draw_circle(center, 10, Color.ORANGE)
	# Draw a subtle outline
	control.draw_arc(center, 10, 0, TAU, 32, Color.DARK_ORANGE, 2.0)

	# Draw lines connecting to the top-left grid cell
	var line_width = 12.0
	var grid_edge = 40  # Distance to grid edge
	var cell_center = grid_edge + CELL_SIZE / 2 - 2  # Center of top-left cell

	# Horizontal line extending right from circle
	control.draw_line(Vector2(center.x + 10, center.y), Vector2(cell_center, center.y), Color.ORANGE, line_width)
	# Connecting vertical line at the end going down to grid edge
	control.draw_line(Vector2(cell_center, center.y), Vector2(cell_center, grid_edge), Color.ORANGE, line_width)

	# Vertical line extending down from circle
	control.draw_line(Vector2(center.x, center.y + 10), Vector2(center.x, cell_center), Color.ORANGE, line_width)
	# Connecting horizontal line at the end going right to grid edge
	control.draw_line(Vector2(center.x, cell_center), Vector2(grid_edge, cell_center), Color.ORANGE, line_width)

func _draw_bottom_right_indicator(control: Control):
	# Use orange if energized, brown if not
	var main_color = Color.ORANGE if is_destination_energized else Color.SADDLE_BROWN
	var outline_color = Color.DARK_ORANGE if is_destination_energized else Color(0.35, 0.16, 0.08)  # Darker brown

	var center = Vector2(15, 15)
	control.draw_circle(center, 10, main_color)
	# Draw a subtle outline
	control.draw_arc(center, 10, 0, TAU, 32, outline_color, 2.0)

	# Draw lines connecting to the bottom-right grid cell
	var line_width = 12.0
	var grid_edge = -10  # Distance back to grid edge
	var cell_center = -(10 + CELL_SIZE / 2 - 2)  # Center of bottom-right cell

	# Horizontal line extending left from circle
	control.draw_line(Vector2(center.x - 10, center.y), Vector2(cell_center, center.y), main_color, line_width)
	# Connecting vertical line at the end going up to grid edge
	control.draw_line(Vector2(cell_center, center.y), Vector2(cell_center, grid_edge), main_color, line_width)

	# Vertical line extending up from circle
	control.draw_line(Vector2(center.x, center.y - 10), Vector2(center.x, cell_center), main_color, line_width)
	# Connecting horizontal line at the end going left to grid edge
	control.draw_line(Vector2(center.x, cell_center), Vector2(grid_edge, cell_center), main_color, line_width)

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

	# Check if this cell is energized
	var key = str(x) + "," + str(y)
	var is_energized = key in energized_cells
	var color = Color.SADDLE_BROWN if not is_energized else Color.ORANGE
	var width = 12.0

	# Draw based on type and rotation
	if pipe["type"] == 1:  # Straight pipe
		if pipe["rotation"] % 2 == 0:  # Horizontal
			pipe_visual.draw_line(Vector2(0, center.y), Vector2(CELL_SIZE - 4, center.y), color, width)
		else:  # Vertical
			pipe_visual.draw_line(Vector2(center.x, 0), Vector2(center.x, CELL_SIZE - 4), color, width)

	elif pipe["type"] == 2:  # Corner pipe
		var rot = pipe["rotation"]
		if rot == 0:  # connects up and right
			pipe_visual.draw_line(Vector2(center.x, 0), center, color, width)  # up
			pipe_visual.draw_line(center, Vector2(CELL_SIZE - 4, center.y), color, width)  # right
		elif rot == 1:  # connects right and down
			pipe_visual.draw_line(center, Vector2(CELL_SIZE - 4, center.y), color, width)  # right
			pipe_visual.draw_line(center, Vector2(center.x, CELL_SIZE - 4), color, width)  # down
		elif rot == 2:  # connects down and left
			pipe_visual.draw_line(center, Vector2(center.x, CELL_SIZE - 4), color, width)  # down
			pipe_visual.draw_line(center, Vector2(0, center.y), color, width)  # left
		elif rot == 3:  # connects left and up
			pipe_visual.draw_line(center, Vector2(0, center.y), color, width)  # left
			pipe_visual.draw_line(center, Vector2(center.x, 0), color, width)  # up

func _on_pipe_clicked(x: int, y: int):
	if puzzle_solved:
		return

	# Rotate the pipe
	if grid[y][x]["type"] > 0:
		grid[y][x]["rotation"] = (grid[y][x]["rotation"] + 1) % 4
		save_grid_state()

		# Update energized state after rotation
		update_energized_cells()

		# Check if puzzle is solved
		if check_solution():
			puzzle_solved = true
			var title_label = find_node_recursive(self, "TitleLabel")
			if title_label:
				title_label.text = "Puzzle Solved!"
			show_train_heart_button()

func check_solution() -> bool:
	# First check: pipe at (0,0) must connect to the power source (up or left)
	if grid[0][0]["type"] == 0:
		return false
	var start_connections = get_pipe_connections(grid[0][0]["type"], grid[0][0]["rotation"])
	if not (0 in start_connections or 3 in start_connections):
		return false

	# Second check: pipe at (4,4) must connect to the destination (down or right)
	if grid[GRID_SIZE - 1][GRID_SIZE - 1]["type"] == 0:
		return false
	var end_connections = get_pipe_connections(grid[GRID_SIZE - 1][GRID_SIZE - 1]["type"], grid[GRID_SIZE - 1][GRID_SIZE - 1]["rotation"])
	if not (2 in end_connections or 1 in end_connections):
		return false

	# Third check: there must be a valid path from (0,0) to (4,4)
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

func update_energized_cells():
	# Reset energized state
	energized_cells = {}
	is_destination_energized = false

	# Check if the top-left cell (0,0) has a pipe that connects to the power source
	# The power source comes from outside the grid (up and left)
	if grid[0][0]["type"] > 0:
		var connections = get_pipe_connections(grid[0][0]["type"], grid[0][0]["rotation"])
		# Check if the pipe at (0,0) connects up (0) or left (3) to receive power
		if 0 in connections or 3 in connections:
			# Start flood-fill from top-left (0,0)
			mark_energized(0, 0, -1)

	# Check if destination is energized
	var dest_key = str(GRID_SIZE - 1) + "," + str(GRID_SIZE - 1)
	is_destination_energized = dest_key in energized_cells

	# Redraw all pipes to show updated energy state
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			update_pipe_visual(x, y)

	# Redraw bottom-right indicator
	if puzzle_container and puzzle_container.get_child_count() > GRID_SIZE * GRID_SIZE + 1:
		var bottom_right_indicator = puzzle_container.get_child(GRID_SIZE * GRID_SIZE + 1)
		bottom_right_indicator.queue_redraw()

func mark_energized(x: int, y: int, came_from_dir: int):
	# Check if out of bounds
	if x < 0 or x >= GRID_SIZE or y < 0 or y >= GRID_SIZE:
		return

	# Check if already visited
	var key = str(x) + "," + str(y)
	if key in energized_cells:
		return

	# Check if there's a pipe here
	var pipe = grid[y][x]
	if pipe["type"] == 0:
		return

	# Mark as energized
	energized_cells[key] = true

	# Get connections for this pipe
	var connections = get_pipe_connections(pipe["type"], pipe["rotation"])

	# Direction mapping: 0=up, 1=right, 2=down, 3=left
	var dx = [0, 1, 0, -1]
	var dy = [-1, 0, 1, 0]
	var opposite_dir = [2, 3, 0, 1]  # Opposite directions

	# Try each connection
	for dir in connections:
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

		# Recursively mark as energized
		mark_energized(nx, ny, dir)

func show_train_heart_button():
	# Create a button to enter the train heart
	var enter_button = Button.new()
	enter_button.text = "Enter Train Heart"
	enter_button.pressed.connect(_on_enter_train_heart_pressed)

	# Get the theme
	var theme_resource = load("res://default_theme.tres")
	enter_button.theme = theme_resource

	# Apply ResponsiveLayout scaling based on current orientation
	var viewport_size = get_viewport().get_visible_rect().size
	var is_portrait = viewport_size.y > viewport_size.x

	if is_portrait:
		# Match ResponsiveLayout portrait scaling
		var scaled_height = ResponsiveLayout.PORTRAIT_ELEMENT_HEIGHT * ResponsiveLayout.PORTRAIT_FONT_SCALE
		enter_button.custom_minimum_size = Vector2(0, scaled_height)
		enter_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		enter_button.add_theme_font_size_override("font_size", int(25 * ResponsiveLayout.PORTRAIT_FONT_SCALE))
	else:
		# Landscape mode
		enter_button.custom_minimum_size = Vector2(0, ResponsiveLayout.LANDSCAPE_ELEMENT_HEIGHT)

	# Find the appropriate parent container (could be in RightVBox or BottomVBox depending on orientation)
	var back_button = find_node_recursive(self, "BackButton")
	if back_button and back_button.get_parent():
		var parent = back_button.get_parent()
		parent.add_child(enter_button)
		parent.move_child(enter_button, back_button.get_index())  # Place before back button

func _on_enter_train_heart_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/train_heart.tscn")

func _on_back_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/secret_passage_entrance.tscn")

func _on_place_pipe_button_pressed():
	if Level1Vars.pipes > 0:
		# Find all empty cells
		var empty_cells = []
		for y in range(GRID_SIZE):
			for x in range(GRID_SIZE):
				if grid[y][x]["type"] == 0:
					empty_cells.append({"x": x, "y": y})

		var x: int
		var y: int

		# If there are empty cells, place a pipe in a random one
		if empty_cells.size() > 0:
			var random_cell = empty_cells[randi() % empty_cells.size()]
			x = random_cell["x"]
			y = random_cell["y"]
		else:
			# Grid is full, overwrite a random piece
			x = randi() % GRID_SIZE
			y = randi() % GRID_SIZE

		# Randomly choose straight (1) or corner (2) pipe
		var pipe_type = randi() % 2 + 1
		grid[y][x] = {"type": pipe_type, "rotation": randi() % 4}
		Level1Vars.pipes -= 1
		update_pipes_label()
		update_place_pipe_button()
		save_grid_state()

		# Update energized state after placing pipe
		update_energized_cells()

		# Check if puzzle is solved
		if check_solution():
			puzzle_solved = true
			var title_label = find_node_recursive(self, "TitleLabel")
			if title_label:
				title_label.text = "Puzzle Solved!"
			show_train_heart_button()

func update_place_pipe_button():
	var place_pipe_button = find_node_recursive(self, "PlacePipeButton")
	if place_pipe_button:
		place_pipe_button.disabled = Level1Vars.pipes <= 0
		place_pipe_button.text = "Place Pipe"

func add_developer_skip_button():
	# Create a developer button to skip the puzzle
	var skip_button = Button.new()
	skip_button.name = "DeveloperSkipButton"
	skip_button.text = "Developer: Skip Puzzle"
	skip_button.visible = Global.dev_speed_mode
	skip_button.pressed.connect(_on_developer_skip_pressed)

	# Get the theme
	var theme_resource = load("res://default_theme.tres")
	skip_button.theme = theme_resource

	# Apply ResponsiveLayout scaling based on current orientation
	var viewport_size = get_viewport().get_visible_rect().size
	var is_portrait = viewport_size.y > viewport_size.x

	if is_portrait:
		# Match ResponsiveLayout portrait scaling
		var scaled_height = ResponsiveLayout.PORTRAIT_ELEMENT_HEIGHT * ResponsiveLayout.PORTRAIT_FONT_SCALE
		skip_button.custom_minimum_size = Vector2(0, scaled_height)
		skip_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		skip_button.add_theme_font_size_override("font_size", int(25 * ResponsiveLayout.PORTRAIT_FONT_SCALE))
		print("Developer skip button: portrait mode, height=", scaled_height, " font=", int(25 * ResponsiveLayout.PORTRAIT_FONT_SCALE))
	else:
		# Landscape mode
		skip_button.custom_minimum_size = Vector2(0, ResponsiveLayout.LANDSCAPE_ELEMENT_HEIGHT)
		print("Developer skip button: landscape mode, height=", ResponsiveLayout.LANDSCAPE_ELEMENT_HEIGHT)

	# Add the button before the back button (works for any layout)
	var back_button = find_node_recursive(self, "BackButton")
	if back_button and back_button.get_parent():
		var parent = back_button.get_parent()
		var back_button_index = back_button.get_index()
		parent.add_child(skip_button)
		parent.move_child(skip_button, back_button_index)

func _on_developer_skip_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/train_heart.tscn")
