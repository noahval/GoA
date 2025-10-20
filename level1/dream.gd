extends Control

@onready var hbox_container = $HBoxContainer
@onready var vbox_container = $VBoxContainer
@onready var top_vbox = $VBoxContainer/TopVBox
@onready var bottom_vbox = $VBoxContainer/BottomVBox
@onready var left_vbox = $HBoxContainer/LeftVBox
@onready var right_vbox = $HBoxContainer/RightVBox
@onready var stamina_bar = $HBoxContainer/LeftVBox/StaminaPanel/StaminaBar
var stamina_timer = 0.0
var is_portrait_mode = false

func _ready():
	update_stamina_bar()
	apply_mobile_scaling()

func apply_mobile_scaling():
	var viewport_size = get_viewport().get_visible_rect().size
	# Check if in portrait mode (taller than wide)
	var is_portrait = viewport_size.y > viewport_size.x

	# Only reparent if we're switching modes
	if is_portrait_mode != is_portrait:
		# Remove children from current parent
		if left_vbox.get_parent():
			left_vbox.get_parent().remove_child(left_vbox)
		if right_vbox.get_parent():
			right_vbox.get_parent().remove_child(right_vbox)

		if is_portrait:
			# Portrait: left items go to top, right items go to bottom
			top_vbox.add_child(left_vbox)
			bottom_vbox.add_child(right_vbox)
		else:
			# Landscape: both go to hbox container
			hbox_container.add_child(left_vbox)
			hbox_container.add_child(right_vbox)

		# Show/hide containers
		hbox_container.visible = not is_portrait
		vbox_container.visible = is_portrait

		is_portrait_mode = is_portrait

	# Scale up UI for mobile/portrait
	if is_portrait:
		# Scale buttons
		var buttons = right_vbox.get_children()
		for button in buttons:
			if button is Button:
				button.custom_minimum_size = Vector2(0, 105)  # 60 * 1.75 = 105
				# Get current font size and increase by 75%
				var current_size = button.get_theme_font_size("font_size")
				if current_size <= 0:
					current_size = 16  # Default size
				button.add_theme_font_size_override("font_size", int(current_size * 1.75))

		# Scale panels and labels in left vbox (title and stamina)
		var title_panel = left_vbox.get_node_or_null("TitlePanel")
		var title_label = left_vbox.get_node_or_null("TitlePanel/TitleLabel")
		var stamina_panel = left_vbox.get_node_or_null("StaminaPanel")
		var stamina_label = left_vbox.get_node_or_null("StaminaPanel/StaminaLabel")

		if title_panel:
			title_panel.custom_minimum_size = Vector2(0, 70)  # Almost as tall as buttons (105)
		if title_label:
			var title_size = title_label.get_theme_font_size("font_size")
			if title_size <= 0:
				title_size = 16
			title_label.add_theme_font_size_override("font_size", int(title_size * 1.75))

		if stamina_panel:
			stamina_panel.custom_minimum_size = Vector2(0, 70)  # Almost as tall as buttons (105)
		if stamina_label:
			var stamina_size = stamina_label.get_theme_font_size("font_size")
			if stamina_size <= 0:
				stamina_size = 16
			stamina_label.add_theme_font_size_override("font_size", int(stamina_size * 1.75))
	else:
		# Reset UI sizes for desktop
		var buttons = right_vbox.get_children()
		for button in buttons:
			if button is Button:
				button.custom_minimum_size = Vector2(0, 0)
				button.remove_theme_font_size_override("font_size")

		# Reset panel and label sizes
		var title_panel = left_vbox.get_node_or_null("TitlePanel")
		var title_label = left_vbox.get_node_or_null("TitlePanel/TitleLabel")
		var stamina_panel = left_vbox.get_node_or_null("StaminaPanel")
		var stamina_label = left_vbox.get_node_or_null("StaminaPanel/StaminaLabel")

		if title_panel:
			title_panel.custom_minimum_size = Vector2(0, 24)  # Reset to original size
		if title_label:
			title_label.remove_theme_font_size_override("font_size")

		if stamina_panel:
			stamina_panel.custom_minimum_size = Vector2(0, 24)  # Reset to original size
		if stamina_label:
			stamina_label.remove_theme_font_size_override("font_size")

func _process(delta):
	# Increase stamina by 1 every second
	stamina_timer += delta
	if stamina_timer >= 1.0:
		stamina_timer -= 1.0
		if Level1Vars.stamina < Level1Vars.max_stamina:
			Level1Vars.stamina += 1
			update_stamina_bar()

	# Return to furnace when stamina is full
	if Level1Vars.stamina >= Level1Vars.max_stamina:
		Global.change_scene_with_check(get_tree(), "res://level1/furnace.tscn")

func update_stamina_bar():
	var stamina_percent = (Level1Vars.stamina / Level1Vars.max_stamina) * 100.0
	stamina_bar.value = stamina_percent

func _on_willpower_button_pressed():
	Global.add_stat_exp("constitution", 1)

func _on_back_button_pressed():
	# Increase stamina by 3
	if Level1Vars.stamina < Level1Vars.max_stamina:
		Level1Vars.stamina = min(Level1Vars.stamina + 3, Level1Vars.max_stamina)
		update_stamina_bar()
