extends Control

var break_time = 30.0
var max_break_time = 30.0

@onready var suspicion_panel = $HBoxContainer/LeftVBox/SuspicionPanel
@onready var suspicion_bar = $HBoxContainer/LeftVBox/SuspicionPanel/SuspicionBar
@onready var break_timer_bar = $HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimerBar
@onready var break_timer_label = $HBoxContainer/LeftVBox/BreakTimerPanel/BreakTimer
@onready var coins_label = $HBoxContainer/LeftVBox/CoinsPanel/CoinsLabel
@onready var talk_button = $HBoxContainer/RightVBox/TalkButton
@onready var steal_writ_button = $HBoxContainer/RightVBox/StealWritButton
@onready var back_button = $HBoxContainer/RightVBox/BackButton
@onready var confirmation_popup = $PopupContainer/ConfirmationPopup
@onready var talk_questions_panel = $PopupContainer/TalkQuestionsPopup
@onready var question_label = $PopupContainer/TalkQuestionsPopup/MarginContainer/ScrollContainer/QuizVBox/QuestionLabel
@onready var popup_container = $PopupContainer
@onready var right_vbox = $HBoxContainer/RightVBox
@onready var left_vbox = $HBoxContainer/LeftVBox

# Quiz state variables
var current_correct_answer = ""
var questions_data = []
var used_question_indices = []

func _ready():
	ResponsiveLayout.apply_to_scene(self)

	# CRITICAL: Ensure PopupContainer is hidden at start
	popup_container.visible = false

	# Setup confirmation popup using reusable popup system
	confirmation_popup.setup(
		"Nothing to do on your break? Want to chat?",
		["Sure", "Maybe Later"]
	)
	confirmation_popup.hide_popup()

	# Set the actual maximum break time (not the remaining time)
	max_break_time = Level1Vars.starting_break_time + Level1Vars.overseer_lvl

	if Level1Vars.break_time_remaining > 0:
		break_time = Level1Vars.break_time_remaining
	else:
		break_time = max_break_time

	# Initialize the progress bar to the current percentage
	var progress_percent = (break_time / max_break_time) * 100.0
	break_timer_bar.value = progress_percent

	update_labels()
	update_suspicion_bar()

	# Load questions from file
	load_questions()

	# Debug: Detailed button and container info
	await get_tree().process_frame
	await get_tree().process_frame
	print("\n=== OVERSEER'S OFFICE DEBUG ===")
	var viewport = get_viewport().get_visible_rect().size
	print("Viewport: ", viewport, " | Portrait: ", viewport.y > viewport.x)
	print("\n--- Container Visibility ---")
	print("VBoxContainer visible: ", $VBoxContainer.visible, " | mouse_filter: ", $VBoxContainer.mouse_filter)
	print("HBoxContainer visible: ", $HBoxContainer.visible, " | mouse_filter: ", $HBoxContainer.mouse_filter)
	print("BottomVBox visible: ", $VBoxContainer/BottomVBox.visible if $VBoxContainer.visible else "N/A", " | mouse_filter: ", $VBoxContainer/BottomVBox.mouse_filter if $VBoxContainer.visible else "N/A")
	print("\n--- Padding Check (from template) ---")
	var top_pad = get_node_or_null("VBoxContainer/TopPadding")
	var bottom_pad = get_node_or_null("VBoxContainer/BottomPadding")
	var middle_area = get_node_or_null("VBoxContainer/MiddleArea")
	print("TopPadding custom_minimum_size: ", top_pad.custom_minimum_size if top_pad else "NULL")
	print("BottomPadding custom_minimum_size: ", bottom_pad.custom_minimum_size if bottom_pad else "NULL")
	print("MiddleArea custom_minimum_size: ", middle_area.custom_minimum_size if middle_area else "NULL")
	print("MiddleArea size: ", middle_area.size if middle_area else "NULL")
	print("\n--- RightVBox Info ---")
	print("RightVBox parent: ", right_vbox.get_parent().name)
	print("RightVBox visible: ", right_vbox.visible)
	print("RightVBox mouse_filter: ", right_vbox.mouse_filter, " (0=STOP, 1=PASS, 2=IGNORE)")
	print("RightVBox global_position: ", right_vbox.global_position)
	print("RightVBox size: ", right_vbox.size)
	print("RightVBox rect (global): ", Rect2(right_vbox.global_position, right_vbox.size))
	print("\n--- Button States ---")
	for i in range(right_vbox.get_child_count()):
		var child = right_vbox.get_child(i)
		if child is Button:
			print("Button [", i, "]: ", child.name)
			print("  - visible: ", child.visible)
			print("  - disabled: ", child.disabled)
			print("  - global_position: ", child.global_position)
			print("  - size: ", child.size)
			print("  - in viewport: ", child.global_position.y >= 0 and child.global_position.y + child.size.y <= viewport.y)
			print("  - mouse_filter: ", child.mouse_filter)
	print("\n--- PopupContainer ---")
	print("PopupContainer visible: ", popup_container.visible)
	print("PopupContainer z_index: ", popup_container.z_index)
	print("PopupContainer mouse_filter: ", popup_container.mouse_filter)
	print("PopupContainer covers buttons: ", popup_container.visible and popup_container.z_index > 0)
	print("\n--- MiddleArea (where popups are in portrait) ---")
	var middle_area_node = get_node_or_null("VBoxContainer/MiddleArea")
	if middle_area_node:
		print("MiddleArea visible: ", middle_area_node.visible)
		print("MiddleArea mouse_filter: ", middle_area_node.mouse_filter)
		print("MiddleArea clip_contents: ", middle_area_node.clip_contents)
		print("MiddleArea global_position: ", middle_area_node.global_position)
		print("MiddleArea size: ", middle_area_node.size)
		print("MiddleArea children count: ", middle_area_node.get_child_count())
		for i in range(middle_area_node.get_child_count()):
			var child = middle_area_node.get_child(i)
			print("  Child[", i, "]: ", child.name, " visible=", child.visible, " z_index=", child.z_index, " mouse_filter=", child.mouse_filter if child is Control else "N/A")
			if "Popup" in child.name and child.visible:
				print("    Popup global_position: ", child.global_position if child is Control else "N/A")
				print("    Popup size: ", child.size if child is Control else "N/A")
	print("\n--- Other Overlays ---")
	var settings = get_node_or_null("SettingsOverlay")
	if settings:
		print("SettingsOverlay z_index: ", settings.z_index)
		print("SettingsOverlay visible: ", settings.visible if settings.has_method("get") else "unknown")
	print("=== END DEBUG ===\n")

func _process(delta):
	break_time -= delta
	Level1Vars.break_time_remaining = break_time

	# Update progress bar based on current break time
	var progress_percent = (break_time / max_break_time) * 100.0
	break_timer_bar.value = progress_percent

	if break_time <= 0:
		Level1Vars.break_time_remaining = 0.0
		Global.change_scene_with_check(get_tree(), "res://level1/furnace.tscn")

	update_labels()
	update_suspicion_bar()
	update_talk_button_visibility(delta)

func update_labels():
	coins_label.text = "Coins: " + str(int(Level1Vars.coins))

	# Update break timer display
	break_timer_label.text = "Break Timer"

func _on_back_button_pressed():
	Global.change_scene_with_check(get_tree(), "res://level1/coppersmith_carriage.tscn")

func update_suspicion_bar():
	suspicion_panel.visible = Level1Vars.suspicion > 0
	suspicion_bar.value = Level1Vars.suspicion

func load_questions():
	# Load questions from JSON file
	var questions_path = "res://level1/questions.json"
	if FileAccess.file_exists(questions_path):
		var file = FileAccess.open(questions_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()

			var json = JSON.new()
			var parse_result = json.parse(json_string)

			if parse_result == OK:
				var data = json.get_data()
				if data.has("questions"):
					questions_data = data["questions"]
					print("Loaded " + str(questions_data.size()) + " questions")
				else:
					print("Error: 'questions' array not found in questions.json")
			else:
				print("Error: Failed to parse questions.json")
		else:
			print("Error: Failed to open questions.json")
	else:
		print("Error: questions.json not found. Quiz feature will not work.")

func update_talk_button_visibility(_delta):
	# Show Talk button only if heart_taken is true, cooldown is over, and question panel is not visible
	var panel_is_visible = talk_questions_panel != null and talk_questions_panel.visible
	talk_button.visible = Level1Vars.heart_taken and Level1Vars.talk_button_cooldown <= 0 and not panel_is_visible

	# Show Steal Writ button only if correct_answers is 3 or higher
	steal_writ_button.visible = Level1Vars.correct_answers >= 3

func _on_talk_button_pressed():
	# Show confirmation popup using reusable popup system
	# NOTE: In portrait mode, popups are reparented to MiddleArea, so don't need to show PopupContainer
	var viewport = get_viewport().get_visible_rect().size
	var is_portrait = viewport.y > viewport.x
	if not is_portrait:
		popup_container.visible = true
	confirmation_popup.show_popup()

	# Debug: Check popup state after showing
	await get_tree().process_frame
	print("\n=== POPUP DEBUG (after Talk button pressed) ===")
	print("PopupContainer visible: ", popup_container.visible)
	print("PopupContainer global_position: ", popup_container.global_position)
	print("PopupContainer size: ", popup_container.size)
	print("PopupContainer mouse_filter: ", popup_container.mouse_filter)
	print("PopupContainer z_index: ", popup_container.z_index)
	print("\nconfirmation_popup parent: ", confirmation_popup.get_parent().name)
	print("confirmation_popup visible: ", confirmation_popup.visible)
	print("confirmation_popup z_index: ", confirmation_popup.z_index)
	print("confirmation_popup mouse_filter: ", confirmation_popup.mouse_filter)
	print("confirmation_popup global_position: ", confirmation_popup.global_position)
	print("confirmation_popup size: ", confirmation_popup.size)
	print("confirmation_popup anchors: L=", confirmation_popup.anchor_left, " T=", confirmation_popup.anchor_top, " R=", confirmation_popup.anchor_right, " B=", confirmation_popup.anchor_bottom)
	print("confirmation_popup offsets: L=", confirmation_popup.offset_left, " T=", confirmation_popup.offset_top, " R=", confirmation_popup.offset_right, " B=", confirmation_popup.offset_bottom)

	# Check buttons inside popup
	var button_container = confirmation_popup.get_node_or_null("MarginContainer/VBoxContainer/ButtonContainer")
	if button_container:
		print("\nButtons in popup:")
		for i in range(button_container.get_child_count()):
			var btn = button_container.get_child(i)
			if btn is Button:
				print("  Button '", btn.text, "': visible=", btn.visible, " disabled=", btn.disabled, " mouse_filter=", btn.mouse_filter)
				print("    global_position=", btn.global_position, " size=", btn.size)
	print("=== END POPUP DEBUG ===\n")

func _on_confirmation_popup_button_pressed(button_text: String):
	if button_text == "Sure":
		# Show talk questions panel
		talk_questions_panel.visible = true

		# Fetch first question
		fetch_question()
	elif button_text == "Maybe Later":
		# Just close the popup (already closed automatically by reusable popup)
		# Hide popup container to ensure buttons remain clickable (only in landscape)
		var viewport = get_viewport().get_visible_rect().size
		var is_portrait = viewport.y > viewport.x
		if not is_portrait:
			popup_container.visible = false

func fetch_question():
	if questions_data.size() == 0:
		question_label.text = "Error: No questions loaded."
		return

	# Disable answer buttons while loading
	set_answer_buttons_enabled(false)

	# If all questions have been used, reset the used list
	if used_question_indices.size() >= questions_data.size():
		used_question_indices.clear()
		Global.show_stat_notification("You've answered all questions! Starting over...")

	# Pick a random question that hasn't been used yet
	var available_indices = []
	for i in range(questions_data.size()):
		if not used_question_indices.has(i):
			available_indices.append(i)

	var random_index = available_indices[randi() % available_indices.size()]
	used_question_indices.append(random_index)

	var question_data = questions_data[random_index]

	# Display the question
	question_label.text = question_data["question"]
	var answer_a = talk_questions_panel.get_node("MarginContainer/ScrollContainer/QuizVBox/AnswerA")
	var answer_b = talk_questions_panel.get_node("MarginContainer/ScrollContainer/QuizVBox/AnswerB")
	var answer_c = talk_questions_panel.get_node("MarginContainer/ScrollContainer/QuizVBox/AnswerC")
	var answer_d = talk_questions_panel.get_node("MarginContainer/ScrollContainer/QuizVBox/AnswerD")

	if answer_a: answer_a.text = "A) " + question_data["answers"]["A"]
	if answer_b: answer_b.text = "B) " + question_data["answers"]["B"]
	if answer_c: answer_c.text = "C) " + question_data["answers"]["C"]
	if answer_d: answer_d.text = "D) " + question_data["answers"]["D"]

	# Store the correct answer
	current_correct_answer = question_data["correct"]

	# Resize panel to accommodate content
	resize_talk_panel()

	# Enable answer buttons
	set_answer_buttons_enabled(true)

func set_answer_buttons_enabled(enabled: bool):
	var answer_a = talk_questions_panel.get_node("MarginContainer/ScrollContainer/QuizVBox/AnswerA")
	var answer_b = talk_questions_panel.get_node("MarginContainer/ScrollContainer/QuizVBox/AnswerB")
	var answer_c = talk_questions_panel.get_node("MarginContainer/ScrollContainer/QuizVBox/AnswerC")
	var answer_d = talk_questions_panel.get_node("MarginContainer/ScrollContainer/QuizVBox/AnswerD")

	if answer_a: answer_a.disabled = !enabled
	if answer_b: answer_b.disabled = !enabled
	if answer_c: answer_c.disabled = !enabled
	if answer_d: answer_d.disabled = !enabled

func _on_answer_selected(selected_answer: String):
	if selected_answer == current_correct_answer:
		# Correct answer!
		Level1Vars.correct_answers += 1

		# Increase break time by 5 seconds
		break_time += 5.0
		Level1Vars.break_time_remaining = break_time

		# Fetch a new question
		fetch_question()
	else:
		# Incorrect answer
		Level1Vars.correct_answers = 0
		Global.show_stat_notification("Well, that was a disappointing answer. I have some work to attend to, begone with you.")

		# Close the talk questions panel
		talk_questions_panel.visible = false

		# Hide popup container to ensure buttons remain clickable (only in landscape)
		var viewport = get_viewport().get_visible_rect().size
		var is_portrait = viewport.y > viewport.x
		if not is_portrait:
			popup_container.visible = false

		# Set cooldown to random time ~1min
		Level1Vars.talk_button_cooldown = randf_range(45.0, 65.0)

func resize_talk_panel():
	# ResponsiveLayout now handles sizing automatically via position_popups_in_play_area()
	# Just ensure word wrapping is enabled for the question label and answer buttons
	question_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var answer_a = talk_questions_panel.get_node_or_null("MarginContainer/ScrollContainer/QuizVBox/AnswerA")
	var answer_b = talk_questions_panel.get_node_or_null("MarginContainer/ScrollContainer/QuizVBox/AnswerB")
	var answer_c = talk_questions_panel.get_node_or_null("MarginContainer/ScrollContainer/QuizVBox/AnswerC")
	var answer_d = talk_questions_panel.get_node_or_null("MarginContainer/ScrollContainer/QuizVBox/AnswerD")

	if answer_a: answer_a.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if answer_b: answer_b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if answer_c: answer_c.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if answer_d: answer_d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _on_steal_writ_button_pressed():
	# Increase stolen writs by 1
	Level1Vars.stolen_writs += 1

	# Reset correct answers to 0
	Level1Vars.correct_answers = 0

	# Increase suspicion by random amount between 7% and 14%
	var suspicion_increase = randf_range(7.0, 14.0)
	Level1Vars.suspicion += suspicion_increase

	# Keep the same question displayed - don't fetch a new one
