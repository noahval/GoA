extends Control

# Scene follows formatting guidelines from:
# - RESPONSIVE_LAYOUT_GUIDE.md (element heights, spacing, responsive behavior)
# - SCENE_TEMPLATE_GUIDE.md (three-panel layout structure)
# - POPUP_SYSTEM_GUIDE.md (popup usage if needed)
# All menu elements use LANDSCAPE_ELEMENT_HEIGHT = 40px (see RESPONSIVE_LAYOUT_GUIDE.md)
# NOTE: This scene needs migration to scene_template.tscn for proper layout support

var click_count = 0
var steal_click_count = 0
var auto_shovel_timer = 0.0  # Timer for auto shovel interval
var auto_conversion_timer = 0.0  # Timer for auto conversion interval
@onready var left_vbox = $HBoxContainer/LeftVBox
@onready var right_vbox = $HBoxContainer/RightVBox
@onready var coal_label = $HBoxContainer/LeftVBox/CoalPanel/CoalLabel
@onready var coins_label = $HBoxContainer/LeftVBox/CoinsPanel/CoinsLabel
@onready var mood_label = $HBoxContainer/LeftVBox/OverseerMoodPanel/MoodLabel
@onready var shop_button = $HBoxContainer/RightVBox/ShopButton
@onready var convert_coal_button = $HBoxContainer/RightVBox/ConvertCoalButton
@onready var toggle_mode_button = $HBoxContainer/RightVBox/ToggleModeButton
@onready var stamina_bar = $HBoxContainer/LeftVBox/StaminaPanel/StaminaBar
@onready var suspicion_panel = $HBoxContainer/LeftVBox/SuspicionPanel
@onready var suspicion_bar = $HBoxContainer/LeftVBox/SuspicionPanel/SuspicionBar
@onready var steal_coal_button = $HBoxContainer/RightVBox/StealCoalButton
@onready var take_break_button = $HBoxContainer/RightVBox/ShopButton

func _ready():
	ResponsiveLayout.apply_to_scene(self)
	coal_label.text = "Coal Shoveled: " + str(Level1Vars.coal)
	coins_label.text = "Coins: " + str(int(Level1Vars.coins))
	update_stamina_bar()
	update_suspicion_bar()
	toggle_mode_button.visible = false

func _process(delta):
	# Auto shovel interval-based generation
	if Level1Vars.auto_shovel_lvl > 0:
		auto_shovel_timer += delta
		# When timer reaches the frequency interval, generate coal
		if auto_shovel_timer >= Level1Vars.auto_shovel_freq:
			# Multiply quantity of auto-shovels by coal per tick
			Level1Vars.coal += Level1Vars.auto_shovel_lvl * Level1Vars.auto_shovel_coal_per_tick
			auto_shovel_timer -= Level1Vars.auto_shovel_freq  # Preserve excess time for accuracy

	# Decrease stimulated_remaining by 1 per second
	if Level1Vars.stimulated_remaining > 0:
		Level1Vars.stimulated_remaining -= delta
		if Level1Vars.stimulated_remaining < 0:
			Level1Vars.stimulated_remaining = 0

		# Show "tired again" notification when dropping below 2
		if Level1Vars.stimulated_remaining < 2 and not Level1Vars.shown_tired_notification:
			Global.show_stat_notification("You feel tired again")
			Level1Vars.shown_tired_notification = true

	# Decrease resilient_remaining by 1 per second
	if Level1Vars.resilient_remaining > 0:
		Level1Vars.resilient_remaining -= delta
		if Level1Vars.resilient_remaining < 0:
			Level1Vars.resilient_remaining = 0

		# Show "lazy again" notification when dropping below 2
		if Level1Vars.resilient_remaining < 2 and not Level1Vars.shown_lazy_notification:
			Global.show_stat_notification("You feel lazy again")
			Level1Vars.shown_lazy_notification = true

	# Phase 1: Auto-conversion mode
	if Level1Vars.auto_conversion_enabled and Level1Vars.coal >= OverseerMood.get_coal_per_coin():
		auto_conversion_timer += delta
		if auto_conversion_timer >= 5.0:  # Auto-convert every 5 seconds
			auto_conversion_timer = 0.0
			perform_auto_conversion()

	coal_label.text = "Coal Shoveled: " + str(int(Level1Vars.coal))
	coins_label.text = "Coins: " + str(int(Level1Vars.coins))
	update_stamina_bar()
	update_suspicion_bar()
	update_mood_display()
	update_conversion_buttons()
	update_dev_buttons()

func _on_shovel_coal_button_pressed():
	# Reduce stamina (less if resilient)
	if Level1Vars.resilient_remaining > 1.0:
		Level1Vars.stamina -= 0.4
	else:
		Level1Vars.stamina -= 1
	update_stamina_bar()

	# Check if stamina is depleted
	if Level1Vars.stamina <= 0:
		Global.change_scene_with_check(get_tree(), "res://level1/dream.tscn")
		return

	# Increase global strength exp
	Global.add_stat_exp("strength", .4)

	var coal_gained = 1 + (Level1Vars.shovel_lvl * 0.7) + (Level1Vars.plow_lvl * 3)

	# Apply stimulated bonus if timer is active
	if Level1Vars.stimulated_remaining > 1.0:
		coal_gained *= 1.4

	Level1Vars.coal += coal_gained

	# 3% chance per strength point to get a second coal
	var bonus_coal_chance = Global.strength * 0.03
	if randf() < bonus_coal_chance:
		Level1Vars.coal += coal_gained

	coal_label.text = "Coal Shoveled: " + str(int(Level1Vars.coal))
	click_count += 1
	if click_count >= 50:
		shop_button.visible = true

	# Count clicks for steal coal button
	if Level1Vars.heart_taken:
		steal_click_count += 1
		if steal_click_count >= 100:
			steal_coal_button.visible = true

func _on_shop_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/bar.tscn")

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

func update_dev_buttons():
	# Show/hide take break button based on dev_speed_mode
	if take_break_button:
		if Global.dev_speed_mode:
			take_break_button.visible = true
		elif click_count < 50:
			take_break_button.visible = false

# Phase 1: Manual conversion - player chooses when to convert coal
func perform_manual_conversion():
	# Get coal requirement based on current mood (inverse relationship)
	var coal_required = OverseerMood.get_coal_per_coin()

	if Level1Vars.coal < coal_required:
		Global.show_stat_notification("Not enough coal to convert")
		return

	var coins_earned = OverseerMood.manual_convert_coal(coal_required)

	Level1Vars.coal -= coal_required
	Level1Vars.coins += coins_earned

	# Show conversion feedback
	var message = OverseerMood.get_conversion_message()
	Global.show_stat_notification(message)

	# Gain charisma experience for dealing with overseer
	Global.add_stat_exp("charisma", 2.0)

	DebugLogger.log_resource_change("coal", Level1Vars.coal + coal_required, Level1Vars.coal, "Manual conversion")
	DebugLogger.log_resource_change("coins", Level1Vars.coins - coins_earned, Level1Vars.coins, "Manual conversion")

# Phase 1: Auto conversion - happens automatically with penalty
func perform_auto_conversion():
	# Get coal requirement based on current mood (inverse relationship)
	var coal_required = OverseerMood.get_coal_per_coin()
	var coins_earned = OverseerMood.auto_convert_coal(coal_required)

	Level1Vars.coal -= coal_required
	Level1Vars.coins += coins_earned

	# No notification in auto mode (player discovers it's less efficient)
	DebugLogger.log_resource_change("coal", Level1Vars.coal + coal_required, Level1Vars.coal, "Auto conversion")
	DebugLogger.log_resource_change("coins", Level1Vars.coins - coins_earned, Level1Vars.coins, "Auto conversion")

# Toggle between manual and auto conversion
func toggle_conversion_mode():
	Level1Vars.auto_conversion_enabled = not Level1Vars.auto_conversion_enabled
	auto_conversion_timer = 0.0

	if Level1Vars.auto_conversion_enabled:
		Global.show_stat_notification("Auto-converting enabled")
	else:
		Global.show_stat_notification("Manual conversion mode")

# Update mood display with qualitative adjectives (no numbers!)
func update_mood_display():
	if mood_label:
		var adjective = OverseerMood.get_mood_adjective()
		var trend = OverseerMood.get_trend_arrow()
		mood_label.text = "Overseer: " + adjective + " " + trend

# Update conversion button states
func update_conversion_buttons():
	if convert_coal_button:
		var coal_required = OverseerMood.get_coal_per_coin()
		if Level1Vars.auto_conversion_enabled:
			convert_coal_button.text = "Auto-converting..."
			convert_coal_button.disabled = true
		else:
			convert_coal_button.text = "Claim coin"
			convert_coal_button.disabled = Level1Vars.coal < coal_required

	if toggle_mode_button:
		if Level1Vars.auto_conversion_enabled:
			toggle_mode_button.text = "Mode: Auto"
		else:
			toggle_mode_button.text = "Mode: Manual"

# Button handlers
func _on_convert_coal_button_pressed():
	perform_manual_conversion()

func _on_toggle_mode_button_pressed():
	toggle_conversion_mode()
