extends Control

# TechniquesData is globally available via class_name
const TECHNIQUES = TechniquesData.TECHNIQUES

# Upgrade card references (populated in _ready)
var upgrade_cards: Array[Panel] = []

# Current upgrade options being displayed
var current_options: Array = []

func _ready():
	ResponsiveLayout.apply_to_scene(self)  # REQUIRED
	connect_navigation()
	connect_settings_button()
	setup_upgrade_cards()

	# Generate and display initial upgrade options
	generate_and_display_options()

func connect_navigation():
	# Connect Back Nav button to return to Furnace
	var to_furnace_button = $AspectContainer/MainContainer/mainarea/Menu/ToFurnaceButton
	if to_furnace_button:
		to_furnace_button.pressed.connect(func(): navigate_to("furnace"))

func connect_settings_button():
	var settings_button = $AspectContainer/MainContainer/mainarea/Menu/SettingsButton
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)

func _on_settings_pressed():
	# Store current scene for return navigation
	Global.previous_scene = scene_file_path
	Global.change_scene("res://settings.tscn")

func navigate_to(scene_id: String):
	var path = SceneNetwork.get_scene_path(scene_id)
	if path.is_empty():
		push_error("Unknown scene ID: " + scene_id)
		return
	Global.change_scene(path)

func setup_upgrade_cards():
	# Get references to upgrade card panels
	var container = $AspectContainer/MainContainer/mainarea/PlayArea/UpgradeContainer
	upgrade_cards = [
		container.get_node("UpgradeCard1"),
		container.get_node("UpgradeCard2"),
		container.get_node("UpgradeCard3"),
		container.get_node("UpgradeCard4"),
	]

func generate_and_display_options():
	# Generate 2 upgrade options
	current_options = _generate_upgrade_options(2)
	_display_upgrade_options(current_options)

func _generate_upgrade_options(count: int) -> Array:
	# Returns array of dictionaries: [{"tech_id": "rhythm", "quality": "rare"}, ...]

	var available_techniques = []

	for tech_id in TECHNIQUES.keys():
		var tech = TECHNIQUES[tech_id]

		# Exclude techniques from locked tiers
		var tech_tier = tech.get("tier", 1)
		if tech_tier > Level1Vars.technique_tier:
			continue

		# Exclude maxed techniques
		var current_level = Level1Vars.get_technique_level(tech_id)
		var max_level = tech.get("max_level", 5)
		if current_level >= max_level:
			continue

		# Check if technique requires unlocked clean streak system
		if tech.has("requires"):
			if tech["requires"] == "clean_streak" and not Level1Vars.clean_streak_unlocked:
				continue

		available_techniques.append(tech_id)

	# Shuffle and take first 'count' items
	available_techniques.shuffle()
	var selected = available_techniques.slice(0, count)

	# Roll quality for each selected technique
	var options = []
	for tech_id in selected:
		var quality = _draw_quality_for_technique(tech_id)
		options.append({"tech_id": tech_id, "quality": quality})

	return options

func _display_upgrade_options(options: Array):
	# Hide all cards first
	for card in upgrade_cards:
		card.visible = false

	# Populate visible cards with technique+quality data
	for i in range(min(options.size(), 2)):
		var option = options[i]
		var tech_id = option["tech_id"]
		var quality = option["quality"]
		var tech = TECHNIQUES[tech_id]
		var card = upgrade_cards[i]

		# Set technique name
		card.get_node("VBoxContainer/NameLabel").text = tech["name"]

		# Split description into short and long descriptions
		var description = tech["description"]
		var parts = description.split("\n\n", true, 1)
		var short_desc = parts[0] if parts.size() > 0 else ""
		var long_desc = parts[1] if parts.size() > 1 else ""

		# Calculate quality-modified bonus
		var base_bonus = tech["effect"].get("base_bonus", 0.0)
		var quality_mult = _get_quality_multiplier(quality)
		var actual_bonus = base_bonus * quality_mult

		# Get quality color for BBCode
		var quality_color = _get_quality_color(quality)

		# Build short description with colored value
		var short_label = card.get_node("VBoxContainer/ShortDescriptionLabel")
		if Level1Vars.show_exact_technique_values and base_bonus > 0:
			var value_text = ""
			var category = tech.get("category", "")
			if base_bonus < 1.0:  # Percentage bonus
				# Stability category shows as increase (+), others show as reduction (-)
				if category == "mass":
					value_text = " [color=#%s]+%.0f%%[/color]" % [quality_color, actual_bonus * 100]
				else:
					value_text = " [color=#%s]-%.0f%%[/color]" % [quality_color, actual_bonus * 100]
			else:  # Flat bonus (like Streak Ceiling +10)
				value_text = " [color=#%s]+%.0f[/color]" % [quality_color, actual_bonus]

			short_label.text = "[center]" + short_desc + value_text + "[/center]"
		else:
			short_label.text = "[center]" + short_desc + "[/center]"

		# Set long description (no numbers, left-aligned)
		var long_label = card.get_node("VBoxContainer/LongDescriptionLabel")
		long_label.text = long_desc

		# Show current level or "NEW"
		var current_level = Level1Vars.get_technique_level(tech_id)
		if current_level > 0:
			card.get_node("VBoxContainer/LevelLabel").text = "Level %d" % current_level
		else:
			card.get_node("VBoxContainer/LevelLabel").text = "NEW"

		# Set rarity-based border color and quality-based text color
		_apply_card_styling(card, tech_id, quality)

		# Connect Select button
		var select_btn = card.get_node("VBoxContainer/SelectButton")
		# Disconnect previous signals if any
		for conn in select_btn.pressed.get_connections():
			select_btn.pressed.disconnect(conn["callable"])
		select_btn.pressed.connect(_on_upgrade_selected.bind(tech_id, quality))

		card.visible = true

func _on_upgrade_selected(tech_id: String, quality: String):
	# Add technique to player's selected techniques
	Level1Vars.add_technique(tech_id, quality)

	# Increment total upgrades
	Level1Vars.upgrades_qty += 1

	# Check if more upgrades needed
	if Level1Vars.upgrades_qty < Level1Vars.player_level:
		# Generate new options with fresh quality rolls
		generate_and_display_options()
	else:
		# All caught up, return to furnace
		Global.change_scene("res://level1/furnace.tscn")

func _draw_quality_for_technique(_tech_id: String) -> String:
	# Uniform quality distribution for all techniques (see Part 3)
	var roll = randf()

	# 40% common, 30% uncommon, 20% rare, 8% epic, 2% legendary
	if roll < 0.40:
		return "common"
	elif roll < 0.70:  # 0.40 + 0.30
		return "uncommon"
	elif roll < 0.90:  # 0.70 + 0.20
		return "rare"
	elif roll < 0.98:  # 0.90 + 0.08
		return "epic"
	else:  # 0.98 + 0.02
		return "legendary"

func _apply_card_styling(card: Panel, tech_id: String, quality: String):
	# Border color based on technique rarity (how rare it is to appear)
	var tech_rarity = TECHNIQUES[tech_id]["rarity"]
	var border_color: Color

	match tech_rarity:
		"common":
			border_color = Color(0.6, 0.6, 0.6)  # Gray
		"uncommon":
			border_color = Color(0.4, 0.8, 0.4)  # Green
		"rare":
			border_color = Color(0.2, 0.5, 1.0)  # Blue
		"epic":
			border_color = Color(0.7, 0.3, 1.0)  # Purple
		"legendary":
			border_color = Color(1.0, 0.8, 0.2)  # Gold
		_:
			border_color = Color.WHITE

	# Apply border color to Panel's StyleBox
	var stylebox = card.get_theme_stylebox("panel").duplicate()
	stylebox.border_color = border_color
	card.add_theme_stylebox_override("panel", stylebox)

	# Text color based on quality (how powerful this draw is)
	var quality_color: Color

	match quality:
		"common":
			quality_color = Color(0.6, 0.6, 0.6)  # Gray
		"uncommon":
			quality_color = Color(0.4, 0.8, 0.4)  # Green
		"rare":
			quality_color = Color(0.2, 0.5, 1.0)  # Blue
		"epic":
			quality_color = Color(0.7, 0.3, 1.0)  # Purple
		"legendary":
			quality_color = Color(1.0, 0.8, 0.2)  # Gold
		_:
			quality_color = Color.WHITE

	# Note: Quality color is now applied during _display_upgrade_options
	# No additional styling needed here

func _get_quality_color(quality: String) -> String:
	# Returns hex color string (without #) for BBCode usage
	var color: Color
	match quality:
		"common":
			color = Color(0.6, 0.6, 0.6)  # Gray
		"uncommon":
			color = Color(0.4, 0.8, 0.4)  # Green
		"rare":
			color = Color(0.2, 0.5, 1.0)  # Blue
		"epic":
			color = Color(0.7, 0.3, 1.0)  # Purple
		"legendary":
			color = Color(1.0, 0.8, 0.2)  # Gold
		_:
			color = Color.WHITE

	return color.to_html(false)

func _get_quality_multiplier(quality: String) -> float:
	match quality:
		"common": return 1.0
		"uncommon": return 1.1
		"rare": return 1.2
		"epic": return 1.4
		"legendary": return 1.6
		_: return 1.0
