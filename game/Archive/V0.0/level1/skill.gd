extends Control

var selected_skill_node = null  # Currently selected skill node in tree
var break_time = 30.0
var max_break_time = 30.0

@onready var landscape_container = $LandscapeContainer
@onready var portrait_container = $PortraitContainer
@onready var header_bar = $HeaderBar
@onready var notification_bar = $NotificationBar
@onready var reputation_label = $HeaderBar/ReputationLabel
@onready var break_timer_bar = $HeaderBar/BreakTimerPanel/BreakTimerBar
@onready var break_timer_label = $HeaderBar/BreakTimerPanel/BreakTimer

# Skill tree canvas (will be created in landscape container initially)
@onready var skill_tree_canvas = $LandscapeContainer/SkillTreePanel/ScrollContainer/SkillTreeCanvas

# Detail panels (one in each container)
@onready var landscape_detail = $LandscapeContainer/DetailPanel
@onready var portrait_detail = $PortraitContainer/DetailPanel

func _ready():
	# Set the actual maximum break time
	max_break_time = Level1Vars.starting_break_time + Level1Vars.overseer_lvl

	if Level1Vars.break_time_remaining > 0:
		break_time = Level1Vars.break_time_remaining
	else:
		break_time = max_break_time

	# Listen for viewport size changes
	get_viewport().size_changed.connect(_on_viewport_size_changed)

	# Apply initial layout
	_apply_layout()

	# Initialize break timer bar
	if break_timer_bar:
		var progress_percent = (break_time / max_break_time) * 100.0
		break_timer_bar.value = progress_percent

	# Initialize UI
	update_reputation_label()

func _apply_layout():
	var viewport_size = get_viewport_rect().size
	var is_portrait = viewport_size.y > viewport_size.x

	# Show/hide appropriate container
	landscape_container.visible = not is_portrait
	portrait_container.visible = is_portrait

	# Reparent skill tree canvas to active container
	var target_scroll = null
	if is_portrait:
		target_scroll = portrait_container.get_node("SkillTreePanel/ScrollContainer")
	else:
		target_scroll = landscape_container.get_node("SkillTreePanel/ScrollContainer")

	# Only reparent if needed
	if skill_tree_canvas.get_parent() != target_scroll:
		skill_tree_canvas.reparent(target_scroll)

	# Update canvas for orientation
	if skill_tree_canvas.has_method("update_for_orientation"):
		skill_tree_canvas.update_for_orientation(is_portrait)

	# Scale header bar
	if is_portrait:
		header_bar.custom_minimum_size.y = 80
		# Scale header fonts
		var title = header_bar.get_node("TitleLabel")
		var reputation = header_bar.get_node("ReputationLabel")
		var close = header_bar.get_node("CloseButton")
		if title:
			var current_size = title.get_theme_font_size("font_size")
			if current_size <= 0:
				current_size = 25
			title.add_theme_font_size_override("font_size", int(current_size * 1.4))
		if reputation:
			var current_size = reputation.get_theme_font_size("font_size")
			if current_size <= 0:
				current_size = 25
			reputation.add_theme_font_size_override("font_size", int(current_size * 1.4))
		if close:
			close.custom_minimum_size = Vector2(84, 84)
	else:
		header_bar.custom_minimum_size.y = 60
		# Reset fonts
		var title = header_bar.get_node("TitleLabel")
		var reputation = header_bar.get_node("ReputationLabel")
		var close = header_bar.get_node("CloseButton")
		if title:
			title.remove_theme_font_size_override("font_size")
		if reputation:
			reputation.remove_theme_font_size_override("font_size")
		if close:
			close.custom_minimum_size = Vector2(60, 60)

func _process(delta):
	break_time -= delta
	Level1Vars.break_time_remaining = break_time

	# Update break timer progress bar
	if break_timer_bar:
		var progress_percent = (break_time / max_break_time) * 100.0
		break_timer_bar.value = progress_percent

	if break_time <= 0:
		Level1Vars.break_time_remaining = 0.0
		Global.change_scene_with_check(get_tree(), "res://level1/furnace.tscn")

func _on_viewport_size_changed():
	_apply_layout()

func update_reputation_label():
	if reputation_label:
		reputation_label.text = "Reputation: %d" % Global.reputation_points

func show_skill_detail(upgrade_id: String):
	var upgrade = Global.REPUTATION_UPGRADES[upgrade_id]

	# Determine which detail panel is visible
	var detail_panel = landscape_detail if landscape_container.visible else portrait_detail

	# Update skill icon overlay cost
	var cost_overlay = detail_panel.get_node("MarginContainer/VBoxContainer/SkillIconPanel/SkillCostOverlay")
	if cost_overlay:
		cost_overlay.text = str(upgrade.cost)

	# Update detail panel content
	var skill_name = detail_panel.get_node("MarginContainer/VBoxContainer/SkillName")
	if skill_name:
		skill_name.text = upgrade.name

	var cost_label = detail_panel.get_node("MarginContainer/VBoxContainer/CostLabel")
	if cost_label:
		cost_label.text = "Reputation: %d" % upgrade.cost

	var desc_label = detail_panel.get_node("MarginContainer/VBoxContainer/DescriptionLabel")
	if desc_label:
		desc_label.text = upgrade.description

	# Show prerequisites with color coding
	var prereq_label = detail_panel.get_node("MarginContainer/VBoxContainer/PrerequisitesLabel")
	if prereq_label:
		var prereq_mode = upgrade.get("prerequisite_mode", "all")

		if upgrade.prerequisites.is_empty():
			prereq_label.text = "Prerequisites: None"
			prereq_label.add_theme_color_override("default_color", Color.WHITE)
		else:
			# Build BBCode text with color-coded prerequisites
			var prereq_text = "Prerequisites: "
			var prereq_parts = []

			for i in range(upgrade.prerequisites.size()):
				var prereq_id = upgrade.prerequisites[i]
				var prereq_upgrade = Global.REPUTATION_UPGRADES.get(prereq_id, {})
				var prereq_name = prereq_upgrade.get("name", prereq_id)
				var owned = Global.has_reputation_upgrade(prereq_id)

				# Determine color based on ownership status
				var color_code = ""
				if owned:
					color_code = "[color=#CC6619]"  # Orange (owned)
				else:
					var can_purchase = Global.can_purchase_upgrade(prereq_id)
					if can_purchase:
						color_code = "[color=#3366CC]"  # Blue (available)
					else:
						color_code = "[color=#666666]"  # Grey (locked)

				prereq_parts.append(color_code + prereq_name + "[/color]")

			var joiner = " OR " if prereq_mode == "any" else " AND "
			prereq_text += joiner.join(prereq_parts)

			prereq_label.text = prereq_text
			prereq_label.bbcode_enabled = true

	# Update purchase button
	var purchase_button = detail_panel.get_node("MarginContainer/VBoxContainer/PurchaseButton")
	if purchase_button:
		var can_purchase = Global.can_purchase_upgrade(upgrade_id)
		var is_owned = Global.has_reputation_upgrade(upgrade_id)

		# Store the upgrade_id in the button's metadata
		purchase_button.set_meta("current_upgrade_id", upgrade_id)

		if is_owned:
			purchase_button.text = "OWNED"
			purchase_button.disabled = true
		elif can_purchase:
			purchase_button.text = "Purchase"
			purchase_button.disabled = false
		else:
			purchase_button.text = "Cannot Purchase"
			purchase_button.disabled = true

func update_skill_tree_visuals():
	# Update all skill nodes based on current state
	if not skill_tree_canvas:
		return

	# Redraw connection lines
	skill_tree_canvas.queue_redraw()

	# Update all skill node visuals (borders)
	for child in skill_tree_canvas.get_children():
		if child is Panel and child.has_meta("upgrade_id"):
			var upgrade_id = child.get_meta("upgrade_id")
			var border_color = skill_tree_canvas.get_node_border_color(upgrade_id)
			skill_tree_canvas._update_node_border(child, border_color)

	# Update reputation label
	update_reputation_label()

func _on_close_button_pressed():
	# Return to dorm
	Global.change_scene_with_check(get_tree(), "res://level1/dorm.tscn")

func _on_purchase_button_pressed():
	# Get the currently selected upgrade from button metadata
	var detail_panel = landscape_detail if landscape_container.visible else portrait_detail
	var purchase_button = detail_panel.get_node("MarginContainer/VBoxContainer/PurchaseButton")

	if purchase_button and purchase_button.has_meta("current_upgrade_id"):
		var upgrade_id = purchase_button.get_meta("current_upgrade_id")

		if Global.purchase_upgrade(upgrade_id):
			# Refresh visuals
			update_skill_tree_visuals()
			# Refresh detail panel
			show_skill_detail(upgrade_id)
