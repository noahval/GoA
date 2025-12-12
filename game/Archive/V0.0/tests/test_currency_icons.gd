extends Node
## test_currency_icons.gd
## Unit tests for currency icon system
## Tests: icon files, CurrencyManager icon functions, CurrencyPanel component

## Test 1: Verify all currency icon files exist
func test_icon_files_exist():
	print("\n=== Testing icon files exist ===")

	var icons = [
		{"name": "copper", "path": "res://level1/icons/copper_icon.png"},
		{"name": "silver", "path": "res://level1/icons/silver_icon.png"},
		{"name": "gold", "path": "res://level1/icons/gold_icon.png"},
		{"name": "platinum", "path": "res://level1/icons/platinum_icon.png"}
	]

	for icon in icons:
		print("  Checking %s icon..." % icon.name)
		TestAssertions.assert_true(ResourceLoader.exists(icon.path), "%s icon file should exist at %s" % [icon.name, icon.path])

		# Try to load the icon
		var texture = load(icon.path)
		TestAssertions.assert_not_null(texture, "%s icon should load successfully" % icon.name)

		if texture:
			var image = texture.get_image()
			if image:
				print("    ✓ Loaded: %dx%d" % [image.get_width(), image.get_height()])
				# Icons should be 64x64
				TestAssertions.assert_equal(image.get_width(), 64, "%s icon width should be 64px" % icon.name)
				TestAssertions.assert_equal(image.get_height(), 64, "%s icon height should be 64px" % icon.name)

	print("✓ All icon files exist and are 64x64")

## Test 2: Verify CurrencyManager.get_currency_icon() returns correct paths
func test_currency_manager_icon_paths():
	print("\n=== Testing CurrencyManager icon paths ===")

	var expected = {
		CurrencyManager.CurrencyType.COPPER: "res://level1/icons/copper_icon.png",
		CurrencyManager.CurrencyType.SILVER: "res://level1/icons/silver_icon.png",
		CurrencyManager.CurrencyType.GOLD: "res://level1/icons/gold_icon.png",
		CurrencyManager.CurrencyType.PLATINUM: "res://level1/icons/platinum_icon.png"
	}

	for currency_type in expected.keys():
		var path = CurrencyManager.get_currency_icon(currency_type)
		print("  Currency type %d: %s" % [currency_type, path])
		TestAssertions.assert_equal(path, expected[currency_type], "Icon path for currency type %d should be correct" % currency_type)

	print("✓ All currency icon paths are correct")

## Test 3: Verify CurrencyManager.format_currency_for_icons() returns correct structure
func test_currency_manager_format_for_icons():
	print("\n=== Testing CurrencyManager.format_currency_for_icons() ===")

	# Set up test currency values
	Level1Vars.currency.copper = 1234.0
	Level1Vars.currency.silver = 56.0
	Level1Vars.currency.gold = 0.0
	Level1Vars.currency.platinum = 0.0

	var result = CurrencyManager.format_currency_for_icons(false)
	print("  Result: %s" % str(result))

	# Should return array with 2 elements (copper and silver, gold/platinum are zero)
	TestAssertions.assert_equal(result.size(), 2, "Should return 2 currencies (copper and silver)")

	# Check first element (copper)
	TestAssertions.assert_equal(result[0].icon, "res://level1/icons/copper_icon.png", "First icon should be copper")
	TestAssertions.assert_equal(result[0].value, "1,234", "Copper value should be formatted with comma")

	# Check second element (silver)
	TestAssertions.assert_equal(result[1].icon, "res://level1/icons/silver_icon.png", "Second icon should be silver")
	TestAssertions.assert_equal(result[1].value, "56", "Silver value should be 56")

	# Test with show_all = true (should show all currencies even if zero)
	var result_all = CurrencyManager.format_currency_for_icons(true)
	print("  Result (show_all): %s" % str(result_all))
	TestAssertions.assert_equal(result_all.size(), 4, "Should return 4 currencies with show_all=true")

	# Test with all currencies at zero
	Level1Vars.currency.copper = 0.0
	Level1Vars.currency.silver = 0.0
	var result_empty = CurrencyManager.format_currency_for_icons(false)
	TestAssertions.assert_equal(result_empty.size(), 1, "Should return at least copper with 0 when all are zero")
	TestAssertions.assert_equal(result_empty[0].value, "0", "Should show 0 when all currencies are zero")

	print("✓ format_currency_for_icons() works correctly")

## Test 4: Verify CurrencyPanel creates correct structure
func test_currency_panel_structure():
	print("\n=== Testing CurrencyPanel structure ===")

	# Create a CurrencyPanel instance
	var panel = preload("res://currency_panel.gd").new()

	# Set up test data
	var test_data = [
		{"icon": "res://level1/icons/copper_icon.png", "value": "1,234"},
		{"icon": "res://level1/icons/silver_icon.png", "value": "56"}
	]

	panel.setup_currency_display(test_data)

	# Check that MarginContainer was created
	var margin = panel.get_node_or_null("MarginContainer")
	TestAssertions.assert_not_null(margin, "MarginContainer should be created")

	# Check that HBoxContainer was created
	var hbox = panel.get_node_or_null("MarginContainer/ContentHBox")
	TestAssertions.assert_not_null(hbox, "ContentHBox should be created")

	if hbox:
		var children_count = hbox.get_child_count()
		print("  HBox has %d children" % children_count)

		# Should have: Icon_0, IconSpacer_0, Value_0, Separator_1, Icon_1, IconSpacer_1, Value_1
		# That's 7 children total
		TestAssertions.assert_equal(children_count, 7, "HBox should have 7 children for 2 currencies")

		# Check first icon
		var icon_0 = hbox.get_node_or_null("Icon_0")
		TestAssertions.assert_not_null(icon_0, "Icon_0 should exist")
		if icon_0:
			TestAssertions.assert_true(icon_0 is TextureRect, "Icon_0 should be TextureRect")

		# Check first value label
		var value_0 = hbox.get_node_or_null("Value_0")
		TestAssertions.assert_not_null(value_0, "Value_0 should exist")
		if value_0:
			TestAssertions.assert_true(value_0 is Label, "Value_0 should be Label")
			TestAssertions.assert_equal(value_0.text, "1,234", "Value_0 text should be '1,234'")

		# Check separator
		var separator = hbox.get_node_or_null("Separator_1")
		TestAssertions.assert_not_null(separator, "Separator_1 should exist")
		if separator:
			TestAssertions.assert_true(separator is Label, "Separator should be Label")
			TestAssertions.assert_equal(separator.text, " | ", "Separator text should be ' | '")

	panel.queue_free()
	print("✓ CurrencyPanel creates correct structure")

## Test 5: Verify icon sizes are correct for portrait/landscape
func test_currency_panel_icon_sizes():
	print("\n=== Testing CurrencyPanel icon sizes ===")

	var panel = preload("res://currency_panel.gd").new()

	# Default should be landscape (32x32)
	var test_data = [{"icon": "res://level1/icons/copper_icon.png", "value": "100"}]
	panel.setup_currency_display(test_data)

	var icon = panel.get_node_or_null("MarginContainer/ContentHBox/Icon_0")
	if icon:
		var size = icon.custom_minimum_size
		print("  Landscape icon size: %s" % str(size))
		TestAssertions.assert_equal(size.x, 32.0, "Landscape icon width should be 32px")
		TestAssertions.assert_equal(size.y, 32.0, "Landscape icon height should be 32px")

	# Update to portrait mode (34x34)
	panel.update_icon_sizes_for_orientation(true)

	if icon:
		var size_portrait = icon.custom_minimum_size
		print("  Portrait icon size: %s" % str(size_portrait))
		TestAssertions.assert_equal(size_portrait.x, 34.0, "Portrait icon width should be 34px")
		TestAssertions.assert_equal(size_portrait.y, 34.0, "Portrait icon height should be 34px")

	panel.queue_free()
	print("✓ Icon sizes are correct for portrait/landscape")

## Test 6: Verify calculate_minimum_width() includes icon widths
func test_currency_panel_width_calculation():
	print("\n=== Testing CurrencyPanel width calculation ===")

	var panel = preload("res://currency_panel.gd").new()

	# Single currency
	var test_data_single = [{"icon": "res://level1/icons/copper_icon.png", "value": "1,234"}]
	panel.setup_currency_display(test_data_single)

	var width_single = panel.calculate_minimum_width()
	print("  Single currency width: %.0f px" % width_single)
	TestAssertions.assert_greater(width_single, 100.0, "Single currency width should be > 100px")
	TestAssertions.assert_greater(width_single, 32.0, "Width should be greater than just the icon size")

	# Multiple currencies
	var test_data_multi = [
		{"icon": "res://level1/icons/copper_icon.png", "value": "1,234"},
		{"icon": "res://level1/icons/silver_icon.png", "value": "56"}
	]
	panel.setup_currency_display(test_data_multi)

	var width_multi = panel.calculate_minimum_width()
	print("  Multi currency width: %.0f px" % width_multi)
	TestAssertions.assert_greater(width_multi, width_single, "Multi currency width should be greater than single")

	# Width should include: 2 icons (32px each), 2 labels, separator, margins, spacing
	# Minimum: 16 (margins) + 32 (icon1) + 8 (spacing) + 50 (label) + separator + 32 (icon2) + 8 (spacing) + 30 (label) = ~176px
	TestAssertions.assert_greater(width_multi, 150.0, "Multi currency width should be > 150px")

	panel.queue_free()
	print("✓ Width calculation includes icons correctly")

## Test 7: Verify update_currency_values() updates labels without rebuilding
func test_currency_panel_update_values():
	print("\n=== Testing CurrencyPanel value updates ===")

	var panel = preload("res://currency_panel.gd").new()

	# Set up initial display
	var test_data = [
		{"icon": "res://level1/icons/copper_icon.png", "value": "100"},
		{"icon": "res://level1/icons/silver_icon.png", "value": "5"}
	]
	panel.setup_currency_display(test_data)

	var value_label_0 = panel.get_node_or_null("MarginContainer/ContentHBox/Value_0")
	TestAssertions.assert_not_null(value_label_0, "Value label 0 should exist")

	if value_label_0:
		TestAssertions.assert_equal(value_label_0.text, "100", "Initial value should be 100")

		# Update values
		panel.update_currency_values(["250", "10"])

		TestAssertions.assert_equal(value_label_0.text, "250", "Updated value should be 250")

		var value_label_1 = panel.get_node_or_null("MarginContainer/ContentHBox/Value_1")
		if value_label_1:
			TestAssertions.assert_equal(value_label_1.text, "10", "Updated value should be 10")

	panel.queue_free()
	print("✓ Value updates work correctly")
