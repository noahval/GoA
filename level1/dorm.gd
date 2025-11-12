extends Control

var break_time = 30.0
var max_break_time = 30.0
var selected_skill_node = null  # Currently selected skill node in tree

@onready var break_timer_bar = $HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimerBar
@onready var break_timer_label = $HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimer
@onready var coins_label = $HBoxContainer/LeftVBox/CoinsPanel/CoinsLabel
@onready var reputation_label = $HBoxContainer/LeftVBox/ReputationPanel/ReputationLabel
@onready var progress_panel = $HBoxContainer/LeftVBox/ProgressPanel
@onready var progress_bar = $HBoxContainer/LeftVBox/ProgressPanel/ProgressBar
@onready var donate_button = $HBoxContainer/RightVBox/DonateEquipmentButton
@onready var reputation_button = $HBoxContainer/RightVBox/ReputationButton
@onready var developer_free_reputation_button = $HBoxContainer/RightVBox/DeveloperFreeReputationButton
@onready var prestige_popup = $PopupContainer/PrestigeConfirmationPopup
@onready var skill_tree_popup = $PopupContainer/SkillTreePopup
@onready var skill_tree_canvas = $PopupContainer/SkillTreePopup/VBoxContainer/MainContainer/ScrollContainer/SkillTreeCanvas

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

	# CRITICAL: Mark SkillTreePopup for minimal ResponsiveLayout processing
	# This popup has complex internal layout (skill tree canvas, detail panel)
	# ResponsiveLayout will position/size it but won't modify internal containers
	if skill_tree_popup:
		skill_tree_popup.set_meta("responsive_minimal", true)

	# Use ResponsiveLayout for all orientation handling
	ResponsiveLayout.apply_to_scene(self)

	# CRITICAL: Ensure PopupContainer starts hidden to prevent click blocking
	var popup_container = get_node_or_null("PopupContainer")
	if popup_container:
		popup_container.visible = false

	update_labels()


func _process(delta):
	break_time -= delta
	Level1Vars.break_time_remaining = break_time

	# Update break timer progress bar
	if break_timer_bar:
		var progress_percent = (break_time / max_break_time) * 100.0
		break_timer_bar.value = progress_percent

	# Update timer label
	if break_timer_label:
		break_timer_label.text = "Break Timer"

	# Update reputation counter
	if reputation_label:
		reputation_label.text = "Reputation: %d" % Global.reputation_points

	# Update progress bar toward next reputation
	if progress_panel and progress_bar:
		var progress = Global.get_progress_to_next_reputation()
		progress_panel.visible = progress >= 0.5
		if progress_panel.visible:
			progress_bar.value = progress * 100.0

	# Update donate button visibility and text
	if donate_button:
		var available = Global.calculate_available_reputation()
		donate_button.visible = available >= 1
		if donate_button.visible:
			donate_button.text = "Donate Equipment (+%d)" % available

	# Show developer button in dev mode
	if developer_free_reputation_button:
		developer_free_reputation_button.visible = Global.dev_speed_mode

	if break_time <= 0:
		Level1Vars.break_time_remaining = 0.0
		Global.change_scene_with_check(get_tree(), "res://level1/furnace.tscn")


func _on_to_blackbore_bar_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/bar.tscn")


func update_labels():
	# Update coins display
	if coins_label:
		coins_label.text = CurrencyManager.format_currency_display(false, true)

# ===== PRESTIGE SYSTEM HANDLERS =====

func _on_donate_equipment_button_pressed():
	# Show prestige confirmation popup
	if prestige_popup:
		var available = Global.calculate_available_reputation()
		# Update popup message with reputation count
		var message_label = prestige_popup.get_node_or_null("VBoxContainer/MessageLabel")
		if message_label:
			message_label.text = "These tools have served you well, the other workers need them more than you. Time to start fresh.\nYou'll earn %d Reputation" % available

		prestige_popup.visible = true
		$PopupContainer.visible = true

func _on_reputation_button_pressed():
	# Navigate to dedicated skill scene
	Global.change_scene_with_check(get_tree(), "res://level1/skill.tscn")

func _on_prestige_confirm_pressed():
	# Execute prestige
	Global.execute_prestige()

	# Hide popup
	if prestige_popup:
		prestige_popup.visible = false
	$PopupContainer.visible = false

func _on_prestige_cancel_pressed():
	# Hide popup without prestiging
	if prestige_popup:
		prestige_popup.visible = false
	$PopupContainer.visible = false

func _on_skill_tree_close_pressed():
	# Hide skill tree popup
	if skill_tree_popup:
		skill_tree_popup.visible = false
	$PopupContainer.visible = false
	selected_skill_node = null

func _on_developer_free_reputation_button_pressed():
	# Give player 100 reputation for testing
	Global.reputation_points += 100
	Global.show_stat_notification("Developer: +100 Reputation")

# ===== DEBUG FUNCTIONS =====

func _debug_skill_tree_layout():
	# Debug layout by printing positions and sizes of all major elements
	print("\n========== SKILL TREE LAYOUT DEBUG ==========")

	if skill_tree_popup:
		print("SkillTreePopup: pos=%s size=%s rect=%s" % [skill_tree_popup.position, skill_tree_popup.size, skill_tree_popup.get_rect()])

		var vbox = skill_tree_popup.get_node_or_null("VBoxContainer")
		if vbox:
			print("  VBoxContainer: pos=%s size=%s rect=%s" % [vbox.position, vbox.size, vbox.get_rect()])

			var header = vbox.get_node_or_null("HeaderContainer")
			if header:
				print("    HeaderContainer: pos=%s size=%s rect=%s" % [header.position, header.size, header.get_rect()])
				for child in header.get_children():
					print("      - %s: pos=%s size=%s" % [child.name, child.position, child.size])

			var main = vbox.get_node_or_null("MainContainer")
			if main:
				print("    MainContainer: pos=%s size=%s rect=%s" % [main.position, main.size, main.get_rect()])

				var scroll = main.get_node_or_null("ScrollContainer")
				if scroll:
					print("      ScrollContainer: pos=%s size=%s rect=%s" % [scroll.position, scroll.size, scroll.get_rect()])
					print("      ScrollContainer: h_flags=%d v_flags=%d stretch_ratio=%s" % [scroll.size_flags_horizontal, scroll.size_flags_vertical, scroll.size_flags_stretch_ratio])

					if skill_tree_canvas:
						print("        SkillTreeCanvas: pos=%s size=%s custom_min=%s" % [skill_tree_canvas.position, skill_tree_canvas.size, skill_tree_canvas.custom_minimum_size])

				var detail = main.get_node_or_null("DetailPanel")
				if detail:
					print("      DetailPanel: pos=%s size=%s visible=%s" % [detail.position, detail.size, detail.visible])
					print("      DetailPanel: h_flags=%d v_flags=%d stretch_ratio=%s" % [detail.size_flags_horizontal, detail.size_flags_vertical, detail.size_flags_stretch_ratio])

			var legend = vbox.get_node_or_null("LegendContainer")
			if legend:
				print("    LegendContainer: pos=%s size=%s rect=%s" % [legend.position, legend.size, legend.get_rect()])
				for child in legend.get_children():
					print("      - %s: pos=%s size=%s" % [child.name, child.position, child.size])

	print("=============================================\n")

# ===== SKILL TREE FUNCTIONS =====

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

	# Update points label in header
	var points_label = skill_tree_popup.get_node_or_null("VBoxContainer/HeaderContainer/PointsLabel")
	if points_label:
		points_label.text = "Points: %d" % Global.reputation_points
