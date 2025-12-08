extends Control

# Node positions in the skill tree (defined by tier and row)
# Base positions - TOP TO BOTTOM layout (tiers go down, branches go across)
const TIER_Y_POSITIONS = [50, 200, 350, 500, 650]  # 5 tiers (rows, going down)
const BRANCH_X_POSITIONS = [50, 200, 350, 500]  # 4 branches (columns, going across)

var node_positions = {
	# TIER 1 (top row)
	"skill_a1": Vector2(BRANCH_X_POSITIONS[0], TIER_Y_POSITIONS[0]),
	"skill_b1": Vector2(BRANCH_X_POSITIONS[1], TIER_Y_POSITIONS[0]),
	"skill_c1": Vector2(BRANCH_X_POSITIONS[3], TIER_Y_POSITIONS[0]),

	# TIER 2
	"skill_a2": Vector2(BRANCH_X_POSITIONS[0], TIER_Y_POSITIONS[1]),
	"skill_b2": Vector2(BRANCH_X_POSITIONS[1], TIER_Y_POSITIONS[1]),
	"skill_c2": Vector2(BRANCH_X_POSITIONS[3], TIER_Y_POSITIONS[1]),
	"skill_ab2": Vector2(BRANCH_X_POSITIONS[2], TIER_Y_POSITIONS[1]),

	# TIER 3
	"skill_a3": Vector2(BRANCH_X_POSITIONS[0], TIER_Y_POSITIONS[2]),
	"skill_b3": Vector2(BRANCH_X_POSITIONS[1], TIER_Y_POSITIONS[2]),
	"skill_c3": Vector2(BRANCH_X_POSITIONS[3], TIER_Y_POSITIONS[2]),
	"skill_abc3": Vector2(BRANCH_X_POSITIONS[2], TIER_Y_POSITIONS[2]),

	# TIER 4
	"skill_a4": Vector2(BRANCH_X_POSITIONS[0], TIER_Y_POSITIONS[3]),
	"skill_b4": Vector2(BRANCH_X_POSITIONS[1], TIER_Y_POSITIONS[3]),
	"skill_c4": Vector2(BRANCH_X_POSITIONS[2], TIER_Y_POSITIONS[3]),

	# TIER 5 (ultimate skills at bottom)
	"skill_ultimate1": Vector2(BRANCH_X_POSITIONS[0], TIER_Y_POSITIONS[4]),
	"skill_ultimate2": Vector2(BRANCH_X_POSITIONS[1], TIER_Y_POSITIONS[4])
}

# Scale factor for node positions (set in _ready based on canvas size)
var position_scale = 1.0

func _ready():
	# Set minimum size to contain all nodes
	# Make responsive - scale down in portrait mode
	var viewport = get_viewport()
	if viewport:
		var viewport_size = viewport.get_visible_rect().size
		var is_portrait = viewport_size.y > viewport_size.x
		_apply_orientation_scaling(is_portrait)
	else:
		# Fallback
		custom_minimum_size = Vector2(750, 450)
		position_scale = 1.0

	create_skill_nodes()

## Update canvas for orientation change
## Called by parent scene when orientation changes
func update_for_orientation(is_portrait: bool):
	_apply_orientation_scaling(is_portrait)

	# Recreate nodes with new scaling
	# Clear existing nodes
	for child in get_children():
		child.queue_free()

	# Recreate with new scale
	create_skill_nodes()

	# Trigger redraw for connection lines
	queue_redraw()

func _apply_orientation_scaling(is_portrait: bool):
	# Get viewport size to scale canvas
	var viewport = get_viewport()
	if not viewport:
		custom_minimum_size = Vector2(600, 750)
		position_scale = 1.0
		return

	var viewport_size = viewport.get_visible_rect().size

	# Base dimensions of skill tree content
	const BASE_WIDTH = 600.0
	const BASE_HEIGHT = 750.0  # Max Y (650) + node size (80) + padding (20)

	if is_portrait:
		# Portrait: canvas scales with viewport
		# Use 95% of viewport width and available height
		var available_width = viewport_size.x * 0.95
		var available_height = viewport_size.y * 0.6  # 60% for portrait (detail panel takes 40%)

		# Calculate scale factors for both dimensions
		var width_scale = available_width / BASE_WIDTH
		var height_scale = available_height / BASE_HEIGHT

		# Use the smaller scale to ensure everything fits
		position_scale = min(width_scale, height_scale)

		# Set canvas size based on scaled content
		var target_width = BASE_WIDTH * position_scale
		var target_height = BASE_HEIGHT * position_scale
		custom_minimum_size = Vector2(target_width, target_height)
	else:
		# Landscape: canvas scales with viewport
		# Use percentage of available space
		var available_width = viewport_size.x * 0.65  # 65% of width for landscape (detail panel takes 30%)
		var available_height = viewport_size.y * 0.85  # 85% of height (header/footer take 15%)

		# Calculate scale factors for both dimensions
		var width_scale = available_width / BASE_WIDTH
		var height_scale = available_height / BASE_HEIGHT

		# Use the smaller scale to ensure everything fits
		position_scale = min(width_scale, height_scale)

		# Set canvas size based on scaled content
		var target_width = BASE_WIDTH * position_scale
		var target_height = BASE_HEIGHT * position_scale
		custom_minimum_size = Vector2(target_width, target_height)

func create_skill_nodes():
	# Create all 16 skill nodes
	for upgrade_id in Global.REPUTATION_UPGRADES:
		var node_panel = create_skill_node(upgrade_id)
		add_child(node_panel)

func create_skill_node(upgrade_id: String) -> Panel:
	var upgrade = Global.REPUTATION_UPGRADES[upgrade_id]
	var base_pos = node_positions.get(upgrade_id, Vector2(0, 0))

	# Scale position and size based on canvas size
	var scaled_pos = base_pos * position_scale
	var node_size = 80 * position_scale

	# Create panel with scaled size
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(node_size, node_size)
	panel.position = scaled_pos
	panel.size = Vector2(node_size, node_size)
	panel.set_meta("upgrade_id", upgrade_id)

	# Add skill icon filling the panel (with margin for border)
	var icon = TextureRect.new()
	icon.texture = load("res://level1/skill_placeholder.png")
	# Center the icon with anchors
	icon.anchor_left = 0.5
	icon.anchor_top = 0.5
	icon.anchor_right = 0.5
	icon.anchor_bottom = 0.5
	icon.grow_horizontal = Control.GROW_DIRECTION_BOTH
	icon.grow_vertical = Control.GROW_DIRECTION_BOTH
	# Leave space for border (6px on each side to ensure visibility)
	var border_width = 6
	var icon_size = node_size - (border_width * 2)
	icon.offset_left = -icon_size / 2
	icon.offset_top = -icon_size / 2
	icon.offset_right = icon_size / 2
	icon.offset_bottom = icon_size / 2
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Let clicks pass through
	panel.add_child(icon)

	# Add cost label overlay in top-right corner
	var cost_label = Label.new()
	cost_label.text = str(upgrade.cost)
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	cost_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	cost_label.add_theme_font_size_override("font_size", int(16 * position_scale))
	# Position in top-right corner with some padding
	cost_label.anchor_left = 1.0
	cost_label.anchor_right = 1.0
	cost_label.anchor_top = 0.0
	cost_label.anchor_bottom = 0.0
	cost_label.offset_left = -35 * position_scale
	cost_label.offset_right = -5 * position_scale
	cost_label.offset_top = 5 * position_scale
	cost_label.offset_bottom = 25 * position_scale
	cost_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	# Add shadow for better visibility
	cost_label.add_theme_color_override("font_outline_color", Color.BLACK)
	cost_label.add_theme_constant_override("outline_size", int(2 * position_scale))
	panel.add_child(cost_label)

	# Make clickable
	var button = Button.new()
	button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button.flat = true
	button.pressed.connect(_on_skill_node_clicked.bind(upgrade_id, panel))
	panel.add_child(button)

	# Initialize border
	_update_node_border(panel, get_node_border_color(upgrade_id))

	return panel

func _on_skill_node_clicked(upgrade_id: String, panel: Panel):
	# Deselect previous node
	var parent_scene = get_tree().current_scene
	if parent_scene.selected_skill_node and parent_scene.selected_skill_node != panel:
		_update_node_border(parent_scene.selected_skill_node, get_node_border_color(parent_scene.selected_skill_node.get_meta("upgrade_id")))

	# Select this node
	parent_scene.selected_skill_node = panel
	_update_node_border(panel, Color.WHITE)

	# Show detail panel (call parent scene method)
	if parent_scene.has_method("show_skill_detail"):
		parent_scene.show_skill_detail(upgrade_id)
	else:
		# Fallback for old popup-based system (dorm scene)
		show_detail_panel(upgrade_id)

func show_detail_panel(upgrade_id: String):
	var upgrade = Global.REPUTATION_UPGRADES[upgrade_id]
	var dorm = get_tree().current_scene
	var detail_panel = dorm.skill_tree_popup.get_node_or_null("VBoxContainer/MainContainer/DetailPanel")
	if not detail_panel:
		return

	detail_panel.visible = true

	# Update detail panel content
	var skill_name = detail_panel.get_node_or_null("VBoxContainer/SkillName")
	if skill_name:
		skill_name.text = upgrade.name

	var cost_label = detail_panel.get_node_or_null("VBoxContainer/CostLabel")
	if cost_label:
		cost_label.text = "Cost: %d Reputation" % upgrade.cost

	var desc_label = detail_panel.get_node_or_null("VBoxContainer/DescriptionLabel")
	if desc_label:
		desc_label.text = upgrade.description

	# Show prerequisites
	var prereq_label = detail_panel.get_node_or_null("VBoxContainer/PrerequisitesLabel")
	if prereq_label:
		var prereq_mode = upgrade.get("prerequisite_mode", "all")
		var prereq_text = "Prerequisites: "
		if upgrade.prerequisites.is_empty():
			prereq_text += "None"
		else:
			var prereq_names = []
			for prereq_id in upgrade.prerequisites:
				var prereq_upgrade = Global.REPUTATION_UPGRADES.get(prereq_id, {})
				var owned = Global.has_reputation_upgrade(prereq_id)
				var status = "✓" if owned else "✗"
				prereq_names.append("%s %s" % [status, prereq_upgrade.get("name", prereq_id)])

			var joiner = " OR " if prereq_mode == "any" else " AND "
			prereq_text += joiner.join(prereq_names)
		prereq_label.text = prereq_text

	# Update purchase button
	var purchase_button = detail_panel.get_node_or_null("VBoxContainer/PurchaseButton")
	if purchase_button:
		var can_purchase = Global.can_purchase_upgrade(upgrade_id)
		var is_owned = Global.has_reputation_upgrade(upgrade_id)

		if is_owned:
			purchase_button.text = "OWNED"
			purchase_button.disabled = true
		elif can_purchase:
			purchase_button.text = "Purchase"
			purchase_button.disabled = false
			# Reconnect to ensure correct upgrade_id
			for connection in purchase_button.pressed.get_connections():
				purchase_button.pressed.disconnect(connection["callable"])
			purchase_button.pressed.connect(_on_purchase_skill.bind(upgrade_id))
		else:
			purchase_button.text = "Cannot Purchase"
			purchase_button.disabled = true

func _on_purchase_skill(upgrade_id: String):
	if Global.purchase_upgrade(upgrade_id):
		# Refresh visuals
		var parent_scene = get_tree().current_scene
		if parent_scene.has_method("update_skill_tree_visuals"):
			parent_scene.update_skill_tree_visuals()

		# Refresh detail panel
		if parent_scene.has_method("show_skill_detail"):
			parent_scene.show_skill_detail(upgrade_id)
		else:
			# Fallback for old popup system
			show_detail_panel(upgrade_id)

func get_node_border_color(upgrade_id: String) -> Color:
	var is_owned = Global.has_reputation_upgrade(upgrade_id)
	var can_purchase = Global.can_purchase_upgrade(upgrade_id)
	var upgrade = Global.REPUTATION_UPGRADES[upgrade_id]

	if is_owned:
		return Color(0.8, 0.4, 0.1)  # Owned (dark orange)
	elif can_purchase:
		return Color(0.2, 0.4, 0.8)  # Available (dark blue)
	else:
		# Check if prerequisites met but can't afford
		var prereqs_met = true
		var prereq_mode = upgrade.get("prerequisite_mode", "all")
		if prereq_mode == "any":
			prereqs_met = false
			for prereq in upgrade.prerequisites:
				if Global.has_reputation_upgrade(prereq):
					prereqs_met = true
					break
		else:
			for prereq in upgrade.prerequisites:
				if not Global.has_reputation_upgrade(prereq):
					prereqs_met = false
					break

		if prereqs_met and Global.reputation_points < upgrade.cost:
			return Color(0.8, 0.2, 0.0)  # Insufficient funds (red)
		else:
			return Color(0.3, 0.3, 0.3)  # Locked (gray)

func _update_node_border(panel: Panel, color: Color):
	# Update panel border color
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.2, 0.2, 0.2, 0.9)
	style_box.border_width_left = 3
	style_box.border_width_right = 3
	style_box.border_width_top = 3
	style_box.border_width_bottom = 3
	style_box.border_color = color
	style_box.corner_radius_top_left = 5
	style_box.corner_radius_top_right = 5
	style_box.corner_radius_bottom_left = 5
	style_box.corner_radius_bottom_right = 5
	panel.add_theme_stylebox_override("panel", style_box)

func _draw():
	# Draw connection lines between nodes
	for upgrade_id in Global.REPUTATION_UPGRADES:
		var upgrade = Global.REPUTATION_UPGRADES[upgrade_id]
		var node_pos = get_node_position(upgrade_id)

		# Draw lines to all prerequisites
		for prereq_id in upgrade.prerequisites:
			var prereq_pos = get_node_position(prereq_id)
			var line_color = get_line_color(prereq_id, upgrade_id, upgrade)
			var line_width = get_line_width(prereq_id, upgrade_id)

			# Determine if this is an OR prerequisite (dashed line)
			var is_or_prereq = upgrade.get("prerequisite_mode", "all") == "any"

			if is_or_prereq:
				# Draw dashed line for OR prerequisites
				_draw_dashed_connection_line(prereq_pos, node_pos, line_color, line_width)
			else:
				# Draw solid line for AND prerequisites
				draw_line(prereq_pos, node_pos, line_color, line_width)

			# Draw arrow head at endpoint
			_draw_arrow_head(node_pos, prereq_pos, line_color)

func get_node_position(upgrade_id: String) -> Vector2:
	# Return center of node (scaled position + half node size)
	var base_pos = node_positions.get(upgrade_id, Vector2(0, 0))
	var scaled_pos = base_pos * position_scale
	var half_node = (80 * position_scale) / 2.0
	return scaled_pos + Vector2(half_node, half_node)

func get_line_color(prereq_id: String, upgrade_id: String, upgrade: Dictionary) -> Color:
	var prereq_owned = Global.has_reputation_upgrade(prereq_id)
	var upgrade_owned = Global.has_reputation_upgrade(upgrade_id)

	if prereq_owned and upgrade_owned:
		# Both owned - Complete (dark orange)
		return Color(0.8, 0.4, 0.1)
	elif prereq_owned:
		# Parent owned, child locked - Active (dark blue)
		return Color(0.2, 0.4, 0.8)
	else:
		# Parent not owned - Inactive (gray)
		return Color(0.4, 0.4, 0.4)

func get_line_width(prereq_id: String, upgrade_id: String) -> float:
	var prereq_owned = Global.has_reputation_upgrade(prereq_id)
	var upgrade_owned = Global.has_reputation_upgrade(upgrade_id)

	var base_width = 3.0 if (prereq_owned and not upgrade_owned) else 2.0
	return base_width * position_scale

func _draw_dashed_connection_line(from: Vector2, to: Vector2, color: Color, width: float):
	# Draw dashed line for OR prerequisites
	var direction = (to - from).normalized()
	var distance = from.distance_to(to)
	var dash_length = 10.0 * position_scale
	var gap_length = 5.0 * position_scale
	var current_distance = 0.0

	while current_distance < distance:
		var start = from + direction * current_distance
		var end = from + direction * min(current_distance + dash_length, distance)
		draw_line(start, end, color, width)
		current_distance += dash_length + gap_length

func _draw_arrow_head(tip: Vector2, from: Vector2, color: Color):
	# Draw small arrow head at the tip pointing from 'from'
	var direction = (tip - from).normalized()
	var arrow_size = 8.0 * position_scale
	var arrow_angle = 0.4  # radians

	# Calculate arrow head points
	var left = tip - direction.rotated(arrow_angle) * arrow_size
	var right = tip - direction.rotated(-arrow_angle) * arrow_size

	# Draw filled triangle
	draw_colored_polygon(PackedVector2Array([tip, left, right]), color)
