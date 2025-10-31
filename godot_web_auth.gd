extends Node
## GodotWebAuth
## Handles JavaScript callbacks for web-based Google authentication
## This is registered with JavaScriptBridge so JS can call these methods

func _ready():
	# Only register for web builds
	if OS.has_feature("web"):
		_register_javascript_interface()

func _register_javascript_interface():
	# Register this object so JavaScript can call our methods
	JavaScriptBridge.get_interface("godot").GodotWebAuth = self
	DebugLogger.log_info("GodotWebAuth", "JavaScript interface registered")

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
