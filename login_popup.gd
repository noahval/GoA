extends Panel
## Login Popup
## Handles user authentication via Google SSO / username/password

signal authentication_completed(success: bool)
signal skip_login()

@onready var google_button = $MarginContainer/VBoxContainer/GoogleButton
@onready var create_account_button = $MarginContainer/VBoxContainer/ButtonContainer/CreateAccountButton
@onready var login_button = $MarginContainer/VBoxContainer/ButtonContainer/LoginButton
@onready var skip_button = $MarginContainer/VBoxContainer/SkipButton
@onready var username_input = $MarginContainer/VBoxContainer/UsernameContainer/UsernameInput
@onready var password_input = $MarginContainer/VBoxContainer/PasswordContainer/PasswordInput
@onready var status_label = $MarginContainer/VBoxContainer/StatusLabel

func _ready():
	# Connect signals
	google_button.pressed.connect(_on_google_button_pressed)
	create_account_button.pressed.connect(_on_create_account_pressed)
	login_button.pressed.connect(_on_login_pressed)
	skip_button.pressed.connect(_on_skip_pressed)

	# Listen for Nakama authentication events
	NakamaManager.authentication_succeeded.connect(_on_auth_success)
	NakamaManager.authentication_failed.connect(_on_auth_failed)

	# Clear status
	status_label.text = ""

func show_popup():
	# First, hide any other visible popups in the same container
	_hide_other_popups()

	visible = true
	z_index = 200

	# Apply responsive constraints using ResponsiveLayout system
	_apply_responsive_constraints()

	# Test server connection and show appropriate message
	_test_server_connection()

func hide_popup():
	visible = false

func _hide_other_popups() -> void:
	var parent = get_parent()
	if not parent:
		return

	# Hide all sibling popups except this one
	for sibling in parent.get_children():
		# Check if it's a popup (Panel node) and not this popup
		if sibling != self and sibling is Panel and sibling.visible:
			# Hide using hide_popup() if available, otherwise just set visible = false
			if sibling.has_method("hide_popup"):
				sibling.hide_popup()
			else:
				sibling.visible = false

func _test_server_connection():
	# Check if Nakama client is initialized
	if not NakamaManager or not NakamaManager.client:
		_show_status("Initializing server connection...", false)
		await get_tree().create_timer(0.5).timeout

		if not NakamaManager or not NakamaManager.client:
			_show_status("Server unavailable. You can still play offline.", true)
			return

	# For web builds, show optimistic message since JS handles requests better
	if OS.has_feature("web"):
		_show_status("Ready to sign in!", false)
	else:
		# Desktop builds may have SSL issues
		_show_status("Sign in or click Skip to play offline", false)

func _set_buttons_enabled(enabled: bool):
	google_button.disabled = not enabled
	create_account_button.disabled = not enabled
	login_button.disabled = not enabled
	# Skip button should ALWAYS be enabled as a fallback
	skip_button.disabled = false

func _show_status(message: String, is_error: bool = false):
	status_label.text = message
	if is_error:
		status_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	else:
		status_label.add_theme_color_override("font_color", Color(0.3, 1, 0.3))

func _on_google_button_pressed():
	_set_buttons_enabled(false)
	_show_status("Opening Google Sign-In...")

	# For web builds, we need to use JavaScript to trigger Google OAuth
	if OS.has_feature("web"):
		_trigger_web_google_auth()
	else:
		_show_status("Google Sign-In is only available in web builds", true)
		_set_buttons_enabled(true)

func _trigger_web_google_auth():
	# Use JavaScriptBridge to call the Google Sign-In function
	if JavaScriptBridge.eval("typeof window.triggerGoogleSignIn === 'function'", true):
		DebugLogger.log_info("GoogleAuth", "Triggering Google Sign-In via JavaScript")
		JavaScriptBridge.eval("window.triggerGoogleSignIn()", true)
	else:
		_show_status("Google Sign-In not initialized. Check console.", true)
		_set_buttons_enabled(true)
		DebugLogger.log_error("GoogleAuth", "triggerGoogleSignIn function not found in JavaScript")

# Called from JavaScript when Google token is received
func on_google_token_received(token: String):
	DebugLogger.log_info("LoginPopup", "on_google_token_received called")
	DebugLogger.log_info("LoginPopup", "Token length: %d" % token.length())
	_show_status("Authenticating with server...")

	# Authenticate with Nakama using the Google token
	DebugLogger.log_info("LoginPopup", "Calling NakamaManager.authenticate_google")
	var success = await NakamaManager.authenticate_google(token)
	DebugLogger.log_info("LoginPopup", "authenticate_google returned: %s" % str(success))

	if not success:
		DebugLogger.log_error("LoginPopup", "Google authentication failed")
		_set_buttons_enabled(true)

# Called from JavaScript when Google auth fails
func on_google_auth_failed(error: String):
	DebugLogger.log_error("GoogleAuth", "Google auth failed: " + error)
	_show_status("Google Sign-In failed: " + error, true)
	_set_buttons_enabled(true)

func _on_create_account_pressed():
	var username = username_input.text.strip_edges()
	var password = password_input.text

	DebugLogger.log_info("LoginPopup", "Create account button pressed")

	# Validate input
	if username.is_empty():
		_show_status("Please enter a username", true)
		return

	if password.is_empty():
		_show_status("Please enter a password", true)
		return

	if username.length() < 3:
		_show_status("Username must be at least 3 characters", true)
		return

	if password.length() < 6:
		_show_status("Password must be at least 6 characters", true)
		return

	_set_buttons_enabled(false)
	_show_status("Creating account...")

	# Check if NakamaManager is ready
	if not NakamaManager.client:
		DebugLogger.log_error("LoginPopup", "Nakama client not initialized")
		_show_status("Server connection not ready, please try again", true)
		_set_buttons_enabled(true)
		return

	# Authenticate with Nakama (create = true)
	DebugLogger.log_info("LoginPopup", "Calling authenticate_email with username: " + username)
	var success = await NakamaManager.authenticate_email(username, password, true)
	DebugLogger.log_info("LoginPopup", "authenticate_email returned: " + str(success))

	if not success:
		_set_buttons_enabled(true)

func _on_login_pressed():
	var username = username_input.text.strip_edges()
	var password = password_input.text

	DebugLogger.log_info("LoginPopup", "Login button pressed")

	# Validate input
	if username.is_empty():
		_show_status("Please enter a username", true)
		return

	if password.is_empty():
		_show_status("Please enter a password", true)
		return

	_set_buttons_enabled(false)
	_show_status("Logging in...")

	# Check if NakamaManager is ready
	if not NakamaManager.client:
		DebugLogger.log_error("LoginPopup", "Nakama client not initialized")
		_show_status("Server connection not ready, please try again", true)
		_set_buttons_enabled(true)
		return

	# Authenticate with Nakama (create = false)
	DebugLogger.log_info("LoginPopup", "Calling authenticate_email with username: " + username)
	var success = await NakamaManager.authenticate_email(username, password, false)
	DebugLogger.log_info("LoginPopup", "authenticate_email returned: " + str(success))

	if not success:
		_set_buttons_enabled(true)

func _on_skip_pressed():
	DebugLogger.log_info("LoginPopup", "Skip button pressed")
	_show_status("Continuing offline...")

	# Try to load existing local save
	if LocalSaveManager.has_save():
		_show_status("Loading local save...")
		var loaded = LocalSaveManager.load_game()
		if loaded:
			DebugLogger.log_success("LoginPopup", "Local save loaded successfully")
			# Process offline earnings AFTER local save loads
			var loading_screen_script = load("res://level1/loading_screen.gd")
			loading_screen_script.process_offline_earnings()
		else:
			DebugLogger.log_error("LoginPopup", "Failed to load local save")
	else:
		# Save current state for offline play
		LocalSaveManager.save_game()
		DebugLogger.log_info("LoginPopup", "Initial save created for offline play")

	await get_tree().create_timer(0.5).timeout
	skip_login.emit()
	hide_popup()

func _on_auth_success(session_data):
	# Try to load full cloud save (not just stats)
	var loaded = await NakamaManager.load_game()
	if loaded:
		_show_status("Welcome back!")
		DebugLogger.log_success("Login", "Full cloud save loaded (stats + progress)")
		# Process offline earnings AFTER cloud save loads
		var loading_screen_script = load("res://level1/loading_screen.gd")
		loading_screen_script.process_offline_earnings()
	else:
		_show_status("Welcome!")
		DebugLogger.log_info("Login", "No cloud save found, starting fresh")
		# Save initial state to cloud so it's ready for next time
		await NakamaManager.save_game()
		DebugLogger.log_info("Login", "Initial cloud save created")

	await get_tree().create_timer(1.0).timeout
	authentication_completed.emit(true)
	hide_popup()

func _on_auth_failed(error: String):
	DebugLogger.log_error("Login", "Authentication failed: " + error)

	# Parse error message for user-friendly display
	if "already exists" in error.to_lower():
		_show_status("Username already taken. Try logging in instead.", true)
	elif "not found" in error.to_lower() or "invalid" in error.to_lower():
		_show_status("Invalid username or password", true)
	else:
		_show_status("Authentication failed: " + error, true)

	_set_buttons_enabled(true)

## Apply responsive constraints following ResponsiveLayout system patterns
## Uses same constants and logic as ResponsiveLayout.position_popups_in_play_area()
func _apply_responsive_constraints() -> void:
	var viewport_size = get_viewport_rect().size
	var is_portrait = viewport_size.y > viewport_size.x

	# Use ResponsiveLayout constants for popup sizing
	var max_popup_width = 0.0
	var max_popup_height = 0.0

	if is_portrait:
		# Portrait: Use POPUP_MAX_WIDTH_PORTRAIT (98% of viewport)
		max_popup_width = viewport_size.x * ResponsiveLayout.POPUP_MAX_WIDTH_PORTRAIT
		max_popup_height = viewport_size.y * 0.8  # 80% of viewport height for safety
		DebugLogger.log_info("LoginPopup", "Portrait mode - Max size: %.0fx%.0f" % [max_popup_width, max_popup_height])
	else:
		# Landscape: Use same logic as ResponsiveLayout for landscape popups
		# POPUP_WIDTH_RATIO_LANDSCAPE = 0.98 (use 98% of available width)
		var available_width = viewport_size.x - (ResponsiveLayout.POPUP_MARGIN_FROM_MENUS * 2)
		max_popup_width = max(float(ResponsiveLayout.POPUP_MIN_WIDTH_LANDSCAPE),
							   available_width * ResponsiveLayout.POPUP_WIDTH_RATIO_LANDSCAPE)
		max_popup_height = viewport_size.y * 0.7  # 70% of viewport height
		DebugLogger.log_info("LoginPopup", "Landscape mode - Max size: %.0fx%.0f" % [max_popup_width, max_popup_height])

	# Center popup on viewport with constraints
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.5
	anchor_bottom = 0.5

	# Set offsets based on max size (centered)
	var half_width = max_popup_width / 2.0
	var half_height = max_popup_height / 2.0

	offset_left = -half_width
	offset_right = half_width
	offset_top = -half_height
	offset_bottom = half_height

	DebugLogger.log_info("LoginPopup", "Applied constraints - Offsets: L=%.0f R=%.0f T=%.0f B=%.0f" %
						 [offset_left, offset_right, offset_top, offset_bottom])
	DebugLogger.log_info("LoginPopup", "Calculated width: %.0f, height: %.0f" %
						 [offset_right - offset_left, offset_bottom - offset_top])
