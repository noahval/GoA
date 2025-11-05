extends Node

## Button Hierarchy Configuration
##
## This autoload defines the standard button ordering hierarchy for GoA.
## Buttons should be organized by type, with lower-priority types appearing below higher-priority ones.
##
## Documentation: .claude/docs/button-hierarchy.md

## Button Type Categories
enum ButtonType {
	ACTION,       # Primary gameplay actions (Shovel, Buy, Bribe, etc.)
	FORWARD_NAV,  # Navigation to new/deeper scenes (light blue, 2px border)
	BACK_NAV,     # Navigation to previous scenes (dark blue, 1px border)
	DEVELOPER,    # Developer/debug buttons
	UNKNOWN       # Fallback for unrecognized buttons
}

## Button Ordering Priority
##
## LOWER NUMBER = HIGHER ON SCREEN (appears first/top in vertical layouts)
## HIGHER NUMBER = LOWER ON SCREEN (appears last/bottom in vertical layouts)
##
## To reorder button types, simply change these numbers:
## Example: To put Back Nav above Forward Nav, swap their values
const BUTTON_ORDER = {
	ButtonType.ACTION: 0,       # Top - Primary actions
	ButtonType.FORWARD_NAV: 1,  # Middle - Advance forward
	ButtonType.BACK_NAV: 2,     # Bottom - Return/exit
	ButtonType.DEVELOPER: 3     # Very bottom - Dev tools
}

## Left/Top Panel Element Ordering
##
## For LeftVBox/TopVBox panels (info displays)
enum LeftPanelType {
	TITLE,         # Scene title
	TIMER,         # Break timer, stamina, etc.
	RESOURCE,      # Coins, coal, components
	STATUS,        # Overseer mood, suspicion
	NOTIFICATION   # Dynamic notifications
}

const LEFT_PANEL_ORDER = {
	LeftPanelType.TITLE: 0,
	LeftPanelType.TIMER: 1,
	LeftPanelType.RESOURCE: 2,
	LeftPanelType.STATUS: 3,
	LeftPanelType.NOTIFICATION: 4
}

## Get the sort priority for a button
##
## Lower return value = should appear higher in the UI
## Returns: int priority value
func get_button_priority(button: Button) -> int:
	var btn_type = get_button_type(button)
	return BUTTON_ORDER.get(btn_type, 999)  # Default to very low priority

## Determine button type based on properties
##
## Checks theme_type_variation and text to categorize the button
## Returns: ButtonType enum value
func get_button_type(button: Button) -> ButtonType:
	# Check theme variation first
	if button.theme_type_variation == &"ForwardNavButton":
		return ButtonType.FORWARD_NAV
	if button.theme_type_variation == &"BackNavButton":
		return ButtonType.BACK_NAV

	# Check button text for patterns
	var text = button.text.to_lower()

	# Developer buttons
	if text.begins_with("developer") or text.begins_with("dev "):
		return ButtonType.DEVELOPER

	# Forward navigation patterns
	if _is_forward_nav_text(text):
		return ButtonType.FORWARD_NAV

	# Back navigation patterns
	if _is_back_nav_text(text):
		return ButtonType.BACK_NAV

	# Default to action button
	return ButtonType.ACTION

## Check if button text indicates forward navigation
func _is_forward_nav_text(text: String) -> bool:
	var forward_keywords = [
		"enter ",
		"approach ",
		"explore ",
		"to workshop",
		"to overseer's",
		"to crankshaft",
		"to currency",
		"take break"  # Going on break = advancing to new location
	]

	for keyword in forward_keywords:
		if text.contains(keyword):
			return true

	return false

## Check if button text indicates back navigation
func _is_back_nav_text(text: String) -> bool:
	var back_keywords = [
		"back to",
		"return to",
		"to bar",
		"to blackbore",
		"to coppersmith carriage",
		"to secret passage"
	]

	for keyword in back_keywords:
		if text.contains(keyword):
			return true

	return false

## Get the sort priority for a left panel element
##
## Based on panel name and type
## Returns: int priority value
func get_left_panel_priority(panel: Control) -> int:
	var panel_type = get_left_panel_type(panel)
	return LEFT_PANEL_ORDER.get(panel_type, 999)

## Determine left panel type
func get_left_panel_type(panel: Control) -> LeftPanelType:
	var name = panel.name.to_lower()

	if name.contains("title"):
		return LeftPanelType.TITLE
	elif name.contains("timer") or name.contains("stamina"):
		return LeftPanelType.TIMER
	elif name.contains("coin") or name.contains("coal") or name.contains("component") or name.contains("pipe") or name.contains("mechanism"):
		return LeftPanelType.RESOURCE
	elif name.contains("suspicion") or name.contains("mood"):
		return LeftPanelType.STATUS
	elif name.contains("notification"):
		return LeftPanelType.NOTIFICATION

	return LeftPanelType.NOTIFICATION  # Default

## Sort an array of buttons by hierarchy
##
## Modifies the array in-place to match the defined hierarchy
## Usage: ButtonHierarchy.sort_buttons_by_hierarchy(button_array)
func sort_buttons_by_hierarchy(buttons: Array) -> void:
	buttons.sort_custom(func(a, b): return get_button_priority(a) < get_button_priority(b))

## Sort an array of left panels by hierarchy
##
## Modifies the array in-place to match the defined hierarchy
func sort_left_panels_by_hierarchy(panels: Array) -> void:
	panels.sort_custom(func(a, b): return get_left_panel_priority(a) < get_left_panel_priority(b))

## Validate button order in a container
##
## Checks if buttons in a VBoxContainer/HBoxContainer follow the hierarchy
## Returns: Dictionary with { "valid": bool, "issues": Array[String] }
func validate_button_order(container: Container) -> Dictionary:
	var buttons = []
	for child in container.get_children():
		if child is Button:
			buttons.append(child)

	var issues = []
	var last_priority = -1

	for button in buttons:
		var priority = get_button_priority(button)
		if priority < last_priority:
			issues.append("Button '%s' (priority %d) appears after lower priority button" % [button.text, priority])
		last_priority = priority

	return {
		"valid": issues.size() == 0,
		"issues": issues
	}

## Print the hierarchy configuration
##
## Useful for debugging
func print_hierarchy() -> void:
	print("=== Button Hierarchy Configuration ===")
	print("Button Order (0 = top, higher = lower):")
	for type in BUTTON_ORDER:
		print("  %s: %d" % [ButtonType.keys()[type], BUTTON_ORDER[type]])

	print("\nLeft Panel Order:")
	for type in LEFT_PANEL_ORDER:
		print("  %s: %d" % [LeftPanelType.keys()[type], LEFT_PANEL_ORDER[type]])
