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
@onready var confirmation_popup = $ConfirmationPopup
@onready var talk_questions_panel = $TalkQuestionsPanel
@onready var question_label = $TalkQuestionsPanel/VBoxContainer/QuestionLabel

# Quiz state variables
var current_correct_answer = ""
var questions_data = []
var used_question_indices = []

func _ready():
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
	ResponsiveLayout.apply_to_scene(self)

	# Load questions from file
	load_questions()

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

func update_talk_button_visibility(delta):
	# Update cooldown timer
	if Level1Vars.talk_button_cooldown > 0:
		Level1Vars.talk_button_cooldown -= delta

	# Show Talk button only if heart_taken is true, cooldown is over, and question panel is not visible
	var panel_is_visible = talk_questions_panel != null and talk_questions_panel.visible
	talk_button.visible = Level1Vars.heart_taken and Level1Vars.talk_button_cooldown <= 0 and not panel_is_visible

	# Show Steal Writ button only if correct_answers is 3 or higher
	steal_writ_button.visible = Level1Vars.correct_answers >= 3

func _on_talk_button_pressed():
	# Show confirmation popup
	confirmation_popup.visible = true

func _on_maybe_later_button_pressed():
	# Close the confirmation popup
	confirmation_popup.visible = false

func _on_sure_button_pressed():
	# Close confirmation popup
	confirmation_popup.visible = false

	# Show talk questions panel
	talk_questions_panel.visible = true

	# Fetch first question
	fetch_question()

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
	$TalkQuestionsPanel/VBoxContainer/AnswerA.text = "A) " + question_data["answers"]["A"]
	$TalkQuestionsPanel/VBoxContainer/AnswerB.text = "B) " + question_data["answers"]["B"]
	$TalkQuestionsPanel/VBoxContainer/AnswerC.text = "C) " + question_data["answers"]["C"]
	$TalkQuestionsPanel/VBoxContainer/AnswerD.text = "D) " + question_data["answers"]["D"]

	# Store the correct answer
	current_correct_answer = question_data["correct"]

	# Resize panel to accommodate content
	resize_talk_panel()

	# Enable answer buttons
	set_answer_buttons_enabled(true)

func set_answer_buttons_enabled(enabled: bool):
	$TalkQuestionsPanel/VBoxContainer/AnswerA.disabled = !enabled
	$TalkQuestionsPanel/VBoxContainer/AnswerB.disabled = !enabled
	$TalkQuestionsPanel/VBoxContainer/AnswerC.disabled = !enabled
	$TalkQuestionsPanel/VBoxContainer/AnswerD.disabled = !enabled

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

		# Set cooldown to random time between 2-4 minutes (120-240 seconds)
		Level1Vars.talk_button_cooldown = randf_range(120.0, 240.0)

func resize_talk_panel():
	# Get viewport dimensions
	var viewport_size = get_viewport().get_visible_rect().size
	var viewport_width = viewport_size.x

	# Define constants for panel sizing
	const MIN_PANEL_WIDTH = 300  # Minimum panel width
	const PANEL_PADDING = 60  # Padding for panel content
	const MARGIN_FROM_EDGE = 20  # Margin from screen edges

	# Maximum panel width - leave margin from screen edges
	var max_panel_width = viewport_width - (MARGIN_FROM_EDGE * 2)

	# Calculate required width based on text content
	var max_required_width = MIN_PANEL_WIDTH

	# Check question label width
	var question_width = calculate_text_width(question_label)
	max_required_width = max(max_required_width, question_width)

	# Check all answer button widths
	var answer_buttons = [
		$TalkQuestionsPanel/VBoxContainer/AnswerA,
		$TalkQuestionsPanel/VBoxContainer/AnswerB,
		$TalkQuestionsPanel/VBoxContainer/AnswerC,
		$TalkQuestionsPanel/VBoxContainer/AnswerD
	]

	for button in answer_buttons:
		var button_width = calculate_text_width(button)
		max_required_width = max(max_required_width, button_width)

	# Clamp to min and max bounds
	var desired_width = clamp(max_required_width, MIN_PANEL_WIDTH, max_panel_width)

	# Apply the width to the panel (centered)
	var half_width = desired_width / 2.0
	talk_questions_panel.offset_left = -half_width
	talk_questions_panel.offset_right = half_width

	# Enable word wrapping on question label and buttons
	question_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for button in answer_buttons:
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func calculate_text_width(control: Control) -> float:
	# Get text based on control type
	var text = ""
	if control is Label:
		text = control.text
	elif control is Button:
		text = control.text

	if text.is_empty():
		return 0.0

	# Get font and font size
	var font = control.get_theme_font("font")
	var font_size = control.get_theme_font_size("font_size")
	if font_size <= 0:
		font_size = 25  # Default font size

	# Calculate text width
	var text_width = 0.0
	if font:
		text_width = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x

	# Add padding
	const CONTROL_PADDING = 60
	return text_width + CONTROL_PADDING

func _on_steal_writ_button_pressed():
	# Increase stolen writs by 1
	Level1Vars.stolen_writs += 1

	# Reset correct answers to 0
	Level1Vars.correct_answers = 0

	# Increase suspicion by random amount between 7% and 14%
	var suspicion_increase = randf_range(7.0, 14.0)
	Level1Vars.suspicion += suspicion_increase

	# Keep the same question displayed - don't fetch a new one
