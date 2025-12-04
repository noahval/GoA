extends Panel

## Error panel displayed in PlayArea
## Shows user-friendly error messages with technical details on demand
## Integrates with bug reporting system

signal panel_closed

@onready var user_message_label = $MarginContainer/VBoxContainer/UserMessageLabel
@onready var recovery_label = $MarginContainer/VBoxContainer/RecoveryActionLabel
@onready var close_button = $MarginContainer/VBoxContainer/HeaderHBox/CloseButton
@onready var continue_button = $MarginContainer/VBoxContainer/ButtonContainer/ContinueButton
@onready var show_details_button = $MarginContainer/VBoxContainer/ButtonContainer/ShowDetailsButton
@onready var report_bug_button = $MarginContainer/VBoxContainer/ButtonContainer/ReportBugButton
@onready var detail_panel = $MarginContainer/VBoxContainer/DetailPanel
@onready var context_label = $MarginContainer/VBoxContainer/DetailPanel/ScrollContainer/VBoxContainer/ContextLabel
@onready var technical_label = $MarginContainer/VBoxContainer/DetailPanel/ScrollContainer/VBoxContainer/TechnicalLabel
@onready var severity_label = $MarginContainer/VBoxContainer/DetailPanel/ScrollContainer/VBoxContainer/SeverityLabel
@onready var copy_button = $MarginContainer/VBoxContainer/DetailPanel/CopyButton

var current_context: String = ""
var current_technical: String = ""
var current_severity: int = 0

func _ready():
	detail_panel.visible = false
	close_button.pressed.connect(_on_close_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	show_details_button.pressed.connect(_on_show_details_pressed)
	report_bug_button.pressed.connect(_on_report_bug_pressed)
	copy_button.pressed.connect(_on_copy_error_pressed)

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # Escape key
		_close_panel()
		get_viewport().set_input_as_handled()

func show_error(user_message: String, recovery_text: String, context: String, technical_msg: String, severity: int) -> void:
	user_message_label.text = user_message
	recovery_label.text = recovery_text

	current_context = context
	current_technical = technical_msg
	current_severity = severity

	context_label.text = "Where: " + context
	technical_label.text = "Details: " + technical_msg
	severity_label.text = "Severity: " + ErrorHandler.ErrorSeverity.keys()[severity]

	detail_panel.visible = false
	show()

func _on_close_pressed():
	_close_panel()

func _on_continue_pressed():
	_close_panel()

func _close_panel():
	panel_closed.emit()
	queue_free()

func _on_show_details_pressed():
	detail_panel.visible = not detail_panel.visible

func _on_report_bug_pressed():
	# Close error panel and open bug report panel
	_close_panel()
	_open_debug_panel()

func _open_debug_panel():
	var debug_panel_scene = load("res://debug_panel.tscn")
	if not debug_panel_scene:
		DebugLogger.error("Failed to load debug panel scene", "ErrorPanel")
		return

	var debug_panel = debug_panel_scene.instantiate()

	var play_area = ErrorHandler.safe_get_node(get_tree().current_scene, "MainLayout/PlayArea")
	if not play_area:
		DebugLogger.error("Could not find PlayArea for debug panel", "ErrorPanel")
		return

	# Hide current content
	for child in play_area.get_children():
		child.visible = false

	# Add debug panel
	play_area.add_child(debug_panel)

	# Pre-populate with error info
	if debug_panel.has_method("show_for_error_report"):
		debug_panel.show_for_error_report(current_context, current_technical)

	# Restore visibility when closed
	debug_panel.panel_closed.connect(func():
		for child in play_area.get_children():
			if child != debug_panel:
				child.visible = true
	)

func _on_copy_error_pressed():
	var error_text = "Context: %s\nMessage: %s\nSeverity: %s" % [
		current_context,
		current_technical,
		ErrorHandler.ErrorSeverity.keys()[current_severity]
	]
	DisplayServer.clipboard_set(error_text)
	Global.show_stat_notification("Error details copied to clipboard")
