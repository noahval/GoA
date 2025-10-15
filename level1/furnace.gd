extends Control

var click_count = 0
var steal_click_count = 0
@onready var coal_label = $HBoxContainer/LeftVBox/CoalLabel
@onready var coins_label = $HBoxContainer/LeftVBox/CoinsLabel
@onready var shop_button = $HBoxContainer/RightVBox/ShopButton
@onready var stamina_bar = $HBoxContainer/LeftVBox/StaminaPanel/StaminaBar
@onready var suspicion_panel = $HBoxContainer/LeftVBox/SuspicionPanel
@onready var suspicion_bar = $HBoxContainer/LeftVBox/SuspicionPanel/SuspicionBar
@onready var steal_coal_button = $HBoxContainer/RightVBox/StealCoalButton

func _ready():
	coal_label.text = "Coal Shoveled: " + str(Level1Vars.coal)
	coins_label.text = "Coins: " + str(int(Level1Vars.coins))
	update_stamina_bar()
	update_suspicion_bar()
	apply_font_scaling()
	apply_mobile_scaling()

func apply_font_scaling():
	# Make all labels bigger
	var left_labels = $HBoxContainer/LeftVBox.get_children()
	for node in left_labels:
		if node is Label:
			node.add_theme_font_size_override("font_size", 28)
		elif node is Panel:
			# Handle the stamina label inside the panel
			var stamina_label = node.get_node_or_null("StaminaLabel")
			if stamina_label:
				stamina_label.add_theme_font_size_override("font_size", 28)
			# Handle the suspicion label inside the panel
			var suspicion_label = node.get_node_or_null("SuspicionLabel")
			if suspicion_label:
				suspicion_label.add_theme_font_size_override("font_size", 28)

	# Make all buttons bigger
	var buttons = $HBoxContainer/RightVBox.get_children()
	for button in buttons:
		if button is Button:
			button.add_theme_font_size_override("font_size", 28)

func apply_mobile_scaling():
	var viewport_size = get_viewport().get_visible_rect().size
	# Check if in portrait mode (taller than wide)
	if viewport_size.y > viewport_size.x:
		# Make the container wider on mobile (use 90% of screen width)
		var hbox = $HBoxContainer
		var container_width = viewport_size.x * 0.9
		hbox.offset_left = -container_width / 2
		hbox.offset_right = container_width / 2

		# Make both columns wider
		$HBoxContainer/LeftVBox.custom_minimum_size = Vector2(container_width * 0.45, 0)
		$HBoxContainer/RightVBox.custom_minimum_size = Vector2(container_width * 0.45, 0)

		# Scale up buttons for mobile
		var buttons = $HBoxContainer/RightVBox.get_children()
		for button in buttons:
			if button is Button:
				button.custom_minimum_size = Vector2(0, 60)

func _process(delta):
	if Level1Vars.auto_shovel_lvl > 0:
		Level1Vars.coal += Level1Vars.auto_shovel_lvl * delta

	# Check if coal reaches coin_cost threshold
	if Level1Vars.coal >= Level1Vars.coin_cost:
		Level1Vars.coal = 0.0
		Level1Vars.coins += 1.0
		Level1Vars.coin_cost += 1.0

	coal_label.text = "Coal Shoveled: " + str(int(Level1Vars.coal))
	coins_label.text = "Coins: " + str(int(Level1Vars.coins))
	update_stamina_bar()
	update_suspicion_bar()

func _on_shovel_coal_button_pressed():
	# Reduce stamina by 1
	Level1Vars.stamina -= 1
	update_stamina_bar()

	# Check if stamina is depleted
	if Level1Vars.stamina <= 0:
		get_tree().change_scene_to_file("res://level1/dream.tscn")
		return

	# Increase global strength exp
	Global.add_stat_exp("strength", 1)

	var coal_gained = 1 + Level1Vars.shovel_lvl + (Level1Vars.plow_lvl * 5)
	Level1Vars.coal += coal_gained

	# 3% chance per strength point to get a second coal
	var bonus_coal_chance = Global.strength * 0.03
	if randf() < bonus_coal_chance:
		Level1Vars.coal += coal_gained

	# Check if coal reaches coin_cost threshold
	if Level1Vars.coal >= Level1Vars.coin_cost:
		Level1Vars.coal = 0.0
		Level1Vars.coins += 1.0
		Level1Vars.coin_cost += 1.0

	coal_label.text = "Coal Shoveled: " + str(int(Level1Vars.coal))
	click_count += 1
	if click_count >= 20:
		shop_button.visible = true

	# Count clicks for steal coal button
	if Level1Vars.heart_taken:
		steal_click_count += 1
		if steal_click_count >= 30:
			steal_coal_button.visible = true

func _on_shop_button_pressed():
	get_tree().change_scene_to_file("res://level1/shop.tscn")

func _on_steal_coal_button_pressed():
	Level1Vars.stolen_coal += 1
	steal_coal_button.visible = false
	steal_click_count = 0

	# Raise suspicion by random amount (5-15) minus a third of dexterity
	var suspicion_increase = randf_range(5.0, 15.0) - (Global.dexterity / 3.0)
	Level1Vars.suspicion += max(0, suspicion_increase)  # Ensure it doesn't go negative

func update_stamina_bar():
	var stamina_percent = (Level1Vars.stamina / Level1Vars.max_stamina) * 100.0
	stamina_bar.value = stamina_percent

func update_suspicion_bar():
	suspicion_panel.visible = Level1Vars.suspicion > 0
	suspicion_bar.value = Level1Vars.suspicion
