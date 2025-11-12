extends Node
## test_login_popup_width.gd
## Tests that the login popup width matches the widest content element in landscape mode

var login_popup: Panel
var viewport: Viewport

func setup():
	# Create a viewport for testing
	viewport = Viewport.new()
	viewport.size = Vector2(1438, 817)  # Landscape resolution
	add_child(viewport)

	# Load and instantiate the login popup scene
	var popup_scene = load("res://login_popup.tscn")
	login_popup = popup_scene.instantiate()
	viewport.add_child(login_popup)

	# Wait for nodes to be ready
	await get_tree().process_frame

func teardown():
	if login_popup:
		login_popup.queue_free()
	if viewport:
		viewport.queue_free()

## Test: Popup width should match widest content element
func test_popup_width_matches_content():
	print("\n=== Testing login popup width calculation ===")

	# Get the calculated width from the popup
	var calculated_width = login_popup._calculate_widest_content_width()
	print("Calculated widest content width: %.0fpx" % calculated_width)

	# Apply responsive constraints (this should set the popup width)
	login_popup._apply_responsive_constraints()

	# Get the actual popup width from offsets
	var actual_width = login_popup.offset_right - login_popup.offset_left
	print("Actual popup width from offsets: %.0fpx" % actual_width)

	# Assert that they match
	TestAssertions.assert_equal(actual_width, calculated_width, "Popup width should match calculated content width")

	print("✓ Popup width correctly matches widest content")

## Test: Popup width should be within reasonable bounds
func test_popup_width_bounds():
	print("\n=== Testing login popup width bounds ===")

	var calculated_width = login_popup._calculate_widest_content_width()
	print("Calculated width: %.0fpx" % calculated_width)

	# Width should be at least 400px (minimum)
	TestAssertions.assert_greater_or_equal(calculated_width, 400.0, "Popup width should be at least 400px")

	# Width should be at most 800px (maximum)
	TestAssertions.assert_less_or_equal(calculated_width, 800.0, "Popup width should be at most 800px")

	print("✓ Popup width is within bounds (400-800px)")

## Test: All text elements should be measured
func test_all_text_elements_measured():
	print("\n=== Testing that all text elements are found ===")

	# Find all text controls
	var controls = login_popup._find_text_controls_recursive(login_popup)

	print("Found %d text controls" % controls.size())

	# Should find at least: TitleLabel, SubtitleLabel, GoogleButton, OrLabel,
	# UsernameLabel, UsernameInput, PasswordLabel, PasswordInput,
	# CreateAccountButton, LoginButton, SkipButton, StatusLabel
	# That's at least 12 elements
	TestAssertions.assert_greater_or_equal(controls.size(), 12, "Should find at least 12 text elements")

	# Check that we found specific important elements
	var found_title = false
	var found_subtitle = false
	var found_google = false
	var found_skip = false

	for control in controls:
		if control is Label and control.name == "TitleLabel":
			found_title = true
		elif control is Label and control.name == "SubtitleLabel":
			found_subtitle = true
		elif control is Button and control.name == "GoogleButton":
			found_google = true
		elif control is Button and control.name == "SkipButton":
			found_skip = true

	TestAssertions.assert_true(found_title, "Should find TitleLabel")
	TestAssertions.assert_true(found_subtitle, "Should find SubtitleLabel")
	TestAssertions.assert_true(found_google, "Should find GoogleButton")
	TestAssertions.assert_true(found_skip, "Should find SkipButton")

	print("✓ All important text elements found")

## Test: Portrait mode should use different logic (not content-based width)
func test_portrait_mode_uses_viewport_width():
	print("\n=== Testing portrait mode uses viewport percentage ===")

	# Change viewport to portrait
	viewport.size = Vector2(817, 1438)  # Portrait resolution
	await get_tree().process_frame

	# Apply responsive constraints
	login_popup._apply_responsive_constraints()

	# Get the actual popup width
	var actual_width = login_popup.offset_right - login_popup.offset_left
	print("Portrait popup width: %.0fpx" % actual_width)

	# In portrait, width should be ~98% of viewport width (817 * 0.98 = 800.66)
	var expected_width = viewport.size.x * 0.98
	print("Expected portrait width (98%% of viewport): %.0fpx" % expected_width)

	# Allow 5px tolerance for rounding
	TestAssertions.assert_approx(actual_width, expected_width, 5.0, "Portrait width should be 98% of viewport")

	print("✓ Portrait mode correctly uses viewport percentage")
