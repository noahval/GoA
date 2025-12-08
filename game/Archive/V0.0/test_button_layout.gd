extends SceneTree

# Test script to debug OvertimeButton layout and overlap issues
# Run with: godot --headless --script test_button_layout.gd

func _init():
	print("\n========== BUTTON LAYOUT TEST ==========\n")

	# Load the overseers office scene
	var scene = load("res://level1/overseers_office.tscn").instantiate()
	root.add_child(scene)

	# Wait for scene to be ready
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	print("[!] Scene loaded, checking layout...")

	# Find the RightVBox container
	var hbox_container = scene.get_node_or_null("HBoxContainer")
	if not hbox_container:
		print("[X] ERROR: HBoxContainer not found")
		quit()
		return

	var right_vbox = hbox_container.get_node_or_null("RightVBox")
	if not right_vbox:
		print("[X] ERROR: RightVBox not found")
		quit()
		return

	print("[OK] Found RightVBox")
	print("  - Position: ", right_vbox.position)
	print("  - Size: ", right_vbox.size)
	print("  - Custom min size: ", right_vbox.custom_minimum_size)

	# Get separation setting
	var separation = 10
	if right_vbox.has_theme_constant_override("separation"):
		separation = right_vbox.get_theme_constant("separation", "VBoxContainer")
	print("  - Separation: ", separation, "px\n")

	# Find all buttons in RightVBox
	var buttons = []
	for child in right_vbox.get_children():
		if child is Button:
			buttons.append(child)

	print("[!] Found ", buttons.size(), " buttons in RightVBox\n")

	# Check each button's size and position
	var previous_button_bottom = 0.0
	var overlap_detected = false

	for i in range(buttons.size()):
		var button = buttons[i]
		var button_name = button.text if button.text != "" else button.name

		print("--- Button ", i, ": '", button_name.substr(0, 40), "' ---")
		print("  Position: ", button.position)
		print("  Size: ", button.size)
		print("  Custom min size: ", button.custom_minimum_size)
		print("  Global position: ", button.global_position)

		# Check for metadata
		if button.has_meta("_responsive_layout_preserve_height"):
			print("  [!] Has preserve_height metadata: ", button.get_meta("_responsive_layout_preserve_height"))

		# Calculate button bounds
		var button_top = button.global_position.y
		var button_bottom = button.global_position.y + button.size.y

		print("  Top edge: ", button_top)
		print("  Bottom edge: ", button_bottom)
		print("  Height: ", button.size.y)

		# Check for overlap with previous button
		if i > 0:
			var gap = button_top - previous_button_bottom
			print("  Gap from previous button: ", gap, "px")

			if gap < 0:
				print("  [X] OVERLAP DETECTED! ", abs(gap), "px overlap")
				overlap_detected = true
			elif gap < separation:
				print("  [!] WARNING: Gap (", gap, "px) is less than separation (", separation, "px)")

		# Check for custom children (VBoxContainer layout)
		var has_vbox = false
		for child in button.get_children():
			if child is VBoxContainer:
				has_vbox = true
				print("  [!] Contains VBoxContainer:")
				print("    - VBox size: ", child.size)
				print("    - VBox position: ", child.position)
				print("    - VBox children: ", child.get_child_count())

				# Check VBox size flags
				print("    - size_flags_vertical: ", child.size_flags_vertical)
				print("    - size_flags_horizontal: ", child.size_flags_horizontal)

		if not has_vbox and button_name == "":
			print("  [!] This might be the OvertimeButton (empty text)")

		previous_button_bottom = button_bottom
		print()

	# Final report
	print("\n========== TEST RESULTS ==========")
	print("Total buttons: ", buttons.size())
	print("Overlap detected: ", "YES - FIX NEEDED" if overlap_detected else "NO - Layout OK")

	if overlap_detected:
		print("\n[!] OVERLAP ISSUE CONFIRMED")
		print("Possible causes:")
		print("  1. Button height multiplier too small")
		print("  2. ResponsiveLayout overwriting custom size")
		print("  3. VBoxContainer not respecting button size")
		print("  4. Separation not being applied")

	print("\n========== END TEST ==========\n")

	quit()
