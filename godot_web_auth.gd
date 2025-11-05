extends Node
## GodotWebAuth
## Handles JavaScript callbacks for web-based Google authentication
## This is registered with JavaScriptBridge so JS can call these methods

func _ready():
	DebugLogger.log_info("GodotWebAuth", "_ready() called - version 2")
	# Only register for web builds
	if OS.has_feature("web"):
		DebugLogger.log_info("GodotWebAuth", "Web build detected, registering interface")
		_register_javascript_interface()
	else:
		DebugLogger.log_info("GodotWebAuth", "Not a web build, skipping registration")

func _register_javascript_interface():
	# Create callbacks that JavaScript can invoke
	# Note: Callbacks receive arguments as an Array from JavaScript
	var token_callback = JavaScriptBridge.create_callback(_on_js_token_received)
	var error_callback = JavaScriptBridge.create_callback(_on_js_auth_failed)

	DebugLogger.log_info("GodotWebAuth", "Created callbacks: token=%s error=%s" % [str(token_callback), str(error_callback)])

	# Get the window object
	var window = JavaScriptBridge.get_interface("window")

	# Store callbacks on window for JavaScript to access
	window.godot_token_callback = token_callback
	window.godot_error_callback = error_callback

	# Create the interface using the stored callbacks
	var js_code = """
		window.godot = window.godot || {};
		window.godot.GodotWebAuth = {
			on_google_token_received: function(token) {
				console.log('[GodotWebAuth] Received token, forwarding to Godot');
				window.godot_token_callback(token);
			},
			on_google_auth_failed: function(error) {
				console.log('[GodotWebAuth] Auth failed, forwarding to Godot:', error);
				window.godot_error_callback(error);
			}
		};
		console.log('[GodotWebAuth] Interface created:', window.godot.GodotWebAuth);
		true;
	"""

	# Execute the setup code
	var result = JavaScriptBridge.eval(js_code, true)
	DebugLogger.log_info("GodotWebAuth", "JavaScript interface registered: " + str(result))

	# Verify the interface was created
	var check_code = "typeof window.godot !== 'undefined' && typeof window.godot.GodotWebAuth !== 'undefined'"
	var interface_exists = JavaScriptBridge.eval(check_code, true)
	DebugLogger.log_info("GodotWebAuth", "Interface exists check: " + str(interface_exists))

## Internal callback wrapper - receives args from JS as Array
func _on_js_token_received(args: Array):
	if args.size() > 0:
		var token = str(args[0])
		on_google_token_received(token)

## Internal callback wrapper - receives args from JS as Array
func _on_js_auth_failed(args: Array):
	if args.size() > 0:
		var error = str(args[0])
		on_google_auth_failed(error)

## Called from JavaScript when Google returns an ID token
func on_google_token_received(token: String):
	DebugLogger.log_info("GodotWebAuth", "Received Google token from JS")

	# Find the login popup and pass the token to it
	var login_popup = _find_login_popup()
	if login_popup:
		login_popup.on_google_token_received(token)
	else:
		DebugLogger.log_error("GodotWebAuth", "Could not find login popup to send token")

## Called from JavaScript when Google auth fails
func on_google_auth_failed(error: String):
	DebugLogger.log_error("GodotWebAuth", "Google auth failed from JS: " + error)

	# Find the login popup and notify it
	var login_popup = _find_login_popup()
	if login_popup:
		login_popup.on_google_auth_failed(error)

func _find_login_popup():
	# Try to find the login popup in the scene tree
	var root = get_tree().root
	var loading_screen = root.get_node_or_null("LoadingScreen")

	if loading_screen:
		var popup = loading_screen.get_node_or_null("PopupContainer/LoginPopup")
		if popup:
			return popup

	# Fallback: search entire tree
	return _find_node_by_script(root, "res://login_popup.gd")

func _find_node_by_script(node: Node, script_path: String):
	if node.get_script() and node.get_script().resource_path == script_path:
		return node

	for child in node.get_children():
		var result = _find_node_by_script(child, script_path)
		if result:
			return result

	return null
