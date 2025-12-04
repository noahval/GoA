extends Control
## Auto-managing popup container
## Automatically ensures only one popup is visible at a time
## Works with any popup (reusable_popup.gd, custom popups, etc.)
## NOTE: Also checks CenterArea and MiddleArea since ResponsiveLayout may reparent popups there

var _last_visible_popup: Panel = null

func _process(_delta):
	# Collect all currently visible popups from multiple locations
	# ResponsiveLayout may move popups to CenterArea (landscape) or MiddleArea (portrait)
	var visible_popups: Array[Panel] = []

	# Check PopupContainer children (this node)
	_collect_visible_popups(self, visible_popups)

	# Check CenterArea children (landscape mode)
	var center_area = get_node_or_null("../HBoxContainer/CenterArea")
	if center_area:
		_collect_visible_popups(center_area, visible_popups)

	# Check MiddleArea children (portrait mode)
	var middle_area = get_node_or_null("../VBoxContainer/MiddleArea")
	if middle_area:
		_collect_visible_popups(middle_area, visible_popups)

	# If multiple popups are visible, hide all except the newest one
	if visible_popups.size() > 1:
		# Determine which is the new popup
		var new_popup: Panel = null
		for popup in visible_popups:
			if popup != _last_visible_popup:
				new_popup = popup
				break

		# Hide all popups except the new one
		for popup in visible_popups:
			if popup != new_popup:
				if popup.has_method("hide_popup"):
					popup.hide_popup()
				else:
					popup.visible = false

		_last_visible_popup = new_popup
	elif visible_popups.size() == 1:
		# Only one popup visible - track it
		_last_visible_popup = visible_popups[0]
	else:
		# No popups visible
		_last_visible_popup = null

## Helper: Collect all visible Panel nodes from a container
func _collect_visible_popups(container: Node, visible_popups: Array[Panel]) -> void:
	if not container:
		return

	for child in container.get_children():
		# Only check Panel nodes (all popups are Panels)
		if child is Panel and child.visible:
			visible_popups.append(child)
