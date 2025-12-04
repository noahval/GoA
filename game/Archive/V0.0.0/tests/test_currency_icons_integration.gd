extends Node
## test_currency_icons_integration.gd
## Integration tests for currency icon system
## Tests: furnace scene integration, responsive layout integration

## Test 1: Verify furnace scene has CurrencyPanel
func test_furnace_has_currency_panel():
	print("\n=== Testing furnace scene has CurrencyPanel ===")

	# Load furnace scene
	var furnace_scene = load("res://level1/furnace.tscn")
	TestAssertions.assert_not_null(furnace_scene, "Furnace scene should load")

	if furnace_scene:
		var furnace = furnace_scene.instantiate()
		TestAssertions.assert_not_null(furnace, "Furnace scene should instantiate")

		if furnace:
			# Check that CoinsPanel exists
			var coins_panel = furnace.get_node_or_null("HBoxContainer/LeftVBox/CoinsPanel")
			TestAssertions.assert_not_null(coins_panel, "CoinsPanel should exist in furnace scene")

			if coins_panel:
				# Check that it has the currency_panel script
				var script = coins_panel.get_script()
				TestAssertions.assert_not_null(script, "CoinsPanel should have a script attached")

				if script:
					var script_path = script.resource_path
					print("  CoinsPanel script: %s" % script_path)
					TestAssertions.assert_true("currency_panel" in script_path, "CoinsPanel should use currency_panel.gd script")

				# Check that it has the setup method
				TestAssertions.assert_true(coins_panel.has_method("setup_currency_display"), "CoinsPanel should have setup_currency_display method")
				TestAssertions.assert_true(coins_panel.has_method("calculate_minimum_width"), "CoinsPanel should have calculate_minimum_width method")

			furnace.queue_free()

	print("✓ Furnace scene has CurrencyPanel correctly configured")

## Test 2: Verify CurrencyPanel integrates with ResponsiveLayout
func test_currency_panel_responsive_integration():
	print("\n=== Testing CurrencyPanel ResponsiveLayout integration ===")

	# Create a simple scene structure to test
	var root = Control.new()
	var left_vbox = VBoxContainer.new()
	left_vbox.name = "LeftVBox"
	root.add_child(left_vbox)

	# Add a regular panel
	var regular_panel = Panel.new()
	regular_panel.name = "RegularPanel"
	var regular_label = Label.new()
	regular_label.text = "Regular Panel"
	regular_panel.add_child(regular_label)
	left_vbox.add_child(regular_panel)

	# Add a CurrencyPanel
	var currency_panel = preload("res://currency_panel.gd").new()
	currency_panel.name = "CurrencyPanel"
	var test_data = [{"icon": "res://level1/icons/copper_icon.png", "value": "1,234"}]
	currency_panel.setup_currency_display(test_data)
	left_vbox.add_child(currency_panel)

	# Test that _calculate_max_panel_width recognizes CurrencyPanel
	var max_width = ResponsiveLayout._calculate_max_panel_width(left_vbox, 1.0, 40)
	print("  Calculated max panel width: %d" % max_width)
	TestAssertions.assert_greater(max_width, 0, "Max panel width should be calculated")

	# Currency panel width should be included
	TestAssertions.assert_greater(max_width, 100, "Max width should include currency panel width")

	# Clean up
	root.queue_free()

	print("✓ CurrencyPanel integrates with ResponsiveLayout")

## Test 3: Verify icon size updates work with ResponsiveLayout
func test_icon_size_updates_with_responsive():
	print("\n=== Testing icon size updates with ResponsiveLayout ===")

	# Create a scene with CurrencyPanel
	var root = Control.new()
	var left_vbox = VBoxContainer.new()
	root.add_child(left_vbox)

	var currency_panel = preload("res://currency_panel.gd").new()
	var test_data = [{"icon": "res://level1/icons/copper_icon.png", "value": "100"}]
	currency_panel.setup_currency_display(test_data)
	left_vbox.add_child(currency_panel)

	# Get icon reference
	var icon = currency_panel.get_node_or_null("MarginContainer/ContentHBox/Icon_0")
	TestAssertions.assert_not_null(icon, "Icon should exist")

	if icon:
		# Check landscape size (32x32)
		var landscape_size = icon.custom_minimum_size
		print("  Initial (landscape) icon size: %s" % str(landscape_size))
		TestAssertions.assert_equal(landscape_size.x, 32.0, "Initial icon width should be 32px (landscape)")

		# Simulate ResponsiveLayout calling update_icon_sizes_for_orientation for portrait
		ResponsiveLayout._scale_for_portrait(left_vbox, VBoxContainer.new())

		# Check that icon size was updated to portrait (34x34)
		var portrait_size = icon.custom_minimum_size
		print("  After portrait update: %s" % str(portrait_size))
		TestAssertions.assert_equal(portrait_size.x, 34.0, "Icon width should be updated to 34px (portrait)")

		# Simulate switching back to landscape
		ResponsiveLayout._reset_portrait_scaling(left_vbox, VBoxContainer.new(), 1438.0)

		# Check that icon size was reset to landscape
		var back_to_landscape = icon.custom_minimum_size
		print("  After landscape reset: %s" % str(back_to_landscape))
		TestAssertions.assert_equal(back_to_landscape.x, 32.0, "Icon width should be reset to 32px (landscape)")

	root.queue_free()

	print("✓ Icon sizes update correctly with ResponsiveLayout")

## Test 4: Verify currency display updates when values change
func test_currency_display_updates():
	print("\n=== Testing currency display updates ===")

	# Set initial currency values
	Level1Vars.currency.copper = 100.0
	Level1Vars.currency.silver = 0.0
	Level1Vars.currency.gold = 0.0
	Level1Vars.currency.platinum = 0.0

	var currency_panel = preload("res://currency_panel.gd").new()

	# Initial display
	var data1 = CurrencyManager.format_currency_for_icons(false)
	currency_panel.setup_currency_display(data1)

	var value_label = currency_panel.get_node_or_null("MarginContainer/ContentHBox/Value_0")
	if value_label:
		print("  Initial copper value: %s" % value_label.text)
		TestAssertions.assert_equal(value_label.text, "100", "Initial copper should be 100")

	# Change currency
	Level1Vars.currency.copper = 5678.0
	Level1Vars.currency.silver = 12.0

	# Update display
	var data2 = CurrencyManager.format_currency_for_icons(false)
	currency_panel.setup_currency_display(data2)

	value_label = currency_panel.get_node_or_null("MarginContainer/ContentHBox/Value_0")
	if value_label:
		print("  Updated copper value: %s" % value_label.text)
		TestAssertions.assert_equal(value_label.text, "5,678", "Updated copper should be 5,678 with comma")

	var value_label_1 = currency_panel.get_node_or_null("MarginContainer/ContentHBox/Value_1")
	if value_label_1:
		print("  Updated silver value: %s" % value_label_1.text)
		TestAssertions.assert_equal(value_label_1.text, "12", "Silver should now be visible with value 12")

	currency_panel.queue_free()

	print("✓ Currency display updates correctly")
