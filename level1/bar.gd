extends Control

var break_time = 30.0
var max_break_time = 30.0

@onready var anthracite_delight_button = $HBoxContainer/RightVBox/AnthraciteDelightButton
@onready var bribe_barkeep_button = $HBoxContainer/RightVBox/BribeBarkeepButton
@onready var secret_passage_button = $HBoxContainer/RightVBox/SecretPassageButton
@onready var developer_free_coins_button = $HBoxContainer/RightVBox/DeveloperFreeCoinsButton
@onready var follow_voice_button = $HBoxContainer/RightVBox/FollowVoiceButton
@onready var to_dorm_button = $HBoxContainer/RightVBox/ToDormButton
@onready var break_timer_bar = $HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimerBar
@onready var break_timer_label = $HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimer
@onready var coins_panel = $HBoxContainer/LeftVBox/CoinsPanel
@onready var voice_popup = $PopupContainer/VoicePopup
@onready var barkeep_popup = $PopupContainer/BarkeepPopup

func _ready():
	# Set the actual maximum break time
	max_break_time = Level1Vars.starting_break_time + Level1Vars.overseer_lvl

	if Level1Vars.break_time_remaining > 0:
		break_time = Level1Vars.break_time_remaining
	else:
		break_time = max_break_time

	# Initialize the progress bar
	if break_timer_bar:
		var progress_percent = (break_time / max_break_time) * 100.0
		break_timer_bar.value = progress_percent

	# Show bribe barkeep button if door has been discovered and not yet bribed
	if bribe_barkeep_button:
		bribe_barkeep_button.visible = Level1Vars.door_discovered and not Level1Vars.barkeep_bribed

	# Hide follow voice button if door has already been discovered
	if follow_voice_button:
		follow_voice_button.visible = false

	# Show to dorm button if dorm has been unlocked or dev mode
	if to_dorm_button:
		to_dorm_button.visible = Level1Vars.dorm_unlocked or Global.dev_speed_mode

	# Setup popups with messages and buttons
	if voice_popup:
		voice_popup.setup(
			"The voice was coming from further up the train. There's a small door behind the bar that leads ahead.",
			["enter door", "turn back"]
		)
		voice_popup.hide_popup()

	if barkeep_popup:
		barkeep_popup.setup(
			"The barkeep sees you. He says \"That's a restricted area, I can't let you pass, although I could be convinced to turn a blind eye...\"",
			["Ok"]
		)
		barkeep_popup.hide_popup()

	# Use ResponsiveLayout for all orientation handling
	# ResponsiveLayout automatically hides PopupContainer when empty
	ResponsiveLayout.apply_to_scene(self)

	# CRITICAL: Ensure PopupContainer starts hidden to prevent click blocking
	var popup_container = get_node_or_null("PopupContainer")
	if popup_container:
		popup_container.visible = false

	update_labels()


func _process(delta):
	break_time -= delta
	Level1Vars.break_time_remaining = break_time

	# Update progress bar
	if break_timer_bar:
		var progress_percent = (break_time / max_break_time) * 100.0
		break_timer_bar.value = progress_percent

	# Update timer label
	if break_timer_label:
		break_timer_label.text = "Break Timer"

	# Show follow voice button if whisper has triggered (or dev mode) and door hasn't been discovered yet
	if follow_voice_button and not Level1Vars.door_discovered and (Level1Vars.whisper_triggered or Global.dev_speed_mode):
		follow_voice_button.visible = true

	if break_time <= 0:
		Level1Vars.break_time_remaining = 0.0
		Global.change_scene_with_check(get_tree(), "res://level1/furnace.tscn")

func _on_to_blackbore_furnace_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/furnace.tscn")

func _on_to_coppersmith_carriage_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/coppersmith_carriage.tscn")

func _on_to_dorm_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/dorm.tscn")

func _on_bribe_barkeep_pressed():
	if CurrencyManager.can_afford(50) and not Level1Vars.barkeep_bribed:
		if CurrencyManager.deduct_currency(50):
			Level1Vars.barkeep_bribed = true
			update_labels()

func _on_secret_passage_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/secret_passage_entrance.tscn")

func _on_anthracite_delight_pressed():
	if CurrencyManager.can_afford(1):
		if CurrencyManager.deduct_currency(1):
			Level1Vars.stimulated_remaining += 60
			Level1Vars.shown_tired_notification = false  # Reset the flag for next time
			Global.show_stat_notification("You feel invigorated")
			update_labels()

func _on_steel_stout_pressed():
	if CurrencyManager.can_afford(1):
		if CurrencyManager.deduct_currency(1):
			Level1Vars.resilient_remaining += 60
			Level1Vars.shown_lazy_notification = false  # Reset the flag for next time
			Global.show_stat_notification("You feel tenacious")
			update_labels()

func _on_developer_free_coins_button_pressed():
	CurrencyManager.add_currency(CurrencyManager.CurrencyType.COPPER, 200, "debug/cheat")
	Level1Vars.lifetimecoins += 200  # Legacy tracking (can be removed later)
	update_labels()

func update_labels():
	# Update coins display
	_update_currency_display()

## Update currency panel with current currency values
func _update_currency_display():
	if coins_panel:
		var currency_data = CurrencyManager.format_currency_for_icons(false)
		coins_panel.setup_currency_display(currency_data)

	if bribe_barkeep_button:
		bribe_barkeep_button.text = "Bribe Barkeep: 50"

	# Show/hide developer button based on dev_speed_mode
	if developer_free_coins_button:
		developer_free_coins_button.visible = Global.dev_speed_mode

	# Show bribe barkeep button if door discovered and not yet bribed
	if bribe_barkeep_button:
		bribe_barkeep_button.visible = Level1Vars.door_discovered and not Level1Vars.barkeep_bribed

	# Show secret passage button only if barkeep was bribed
	if secret_passage_button:
		secret_passage_button.visible = Level1Vars.barkeep_bribed

	# Check if dorm should be unlocked (equipment_value >= 3000)
	if not Level1Vars.dorm_unlocked and Level1Vars.equipment_value >= 3000:
		Level1Vars.dorm_unlocked = true

	# Show to dorm button if dorm has been unlocked or dev mode
	if to_dorm_button:
		to_dorm_button.visible = Level1Vars.dorm_unlocked or Global.dev_speed_mode

func _on_follow_voice_button_pressed():
	# Show the voice popup
	if voice_popup:
		# CRITICAL: Only show PopupContainer in landscape mode
		# In portrait mode, popups are reparented to MiddleArea, so PopupContainer must stay hidden
		var viewport_size = get_viewport().get_visible_rect().size
		var is_portrait = viewport_size.y > viewport_size.x
		var popup_container = get_node_or_null("PopupContainer")
		if popup_container and not is_portrait:
			popup_container.visible = true
		voice_popup.show_popup()

func _on_voice_popup_button_pressed(button_text: String):
	var viewport_size = get_viewport().get_visible_rect().size
	var is_portrait = viewport_size.y > viewport_size.x
	var popup_container = get_node_or_null("PopupContainer")

	if button_text == "enter door":
		# Show the barkeep popup
		if barkeep_popup:
			# CRITICAL: Only show PopupContainer in landscape mode
			if popup_container and not is_portrait:
				popup_container.visible = true
			barkeep_popup.show_popup()
	elif button_text == "turn back":
		# Popup automatically closes, hide PopupContainer (only matters in landscape)
		if popup_container and not is_portrait:
			popup_container.visible = false

func _on_barkeep_popup_button_pressed(button_text: String):
	if button_text == "Ok":
		# Set door discovered flag
		Level1Vars.door_discovered = true

		# Make bribe barkeep button visible and hide follow voice button
		if bribe_barkeep_button:
			bribe_barkeep_button.visible = true
		if follow_voice_button:
			follow_voice_button.visible = false

		# CRITICAL: Hide PopupContainer now that popup sequence is complete (only matters in landscape)
		var viewport_size = get_viewport().get_visible_rect().size
		var is_portrait = viewport_size.y > viewport_size.x
		var popup_container = get_node_or_null("PopupContainer")
		if popup_container and not is_portrait:
			popup_container.visible = false
