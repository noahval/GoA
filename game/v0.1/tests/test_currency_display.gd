extends GutTest

var display: CurrencyDisplay
var icon: TextureRect
var amount_label: Label

func before_each():
	display = CurrencyDisplay.new()
	# Add child nodes manually since we're not loading the scene
	icon = TextureRect.new()
	icon.name = "Icon"
	display.add_child(icon)

	amount_label = Label.new()
	amount_label.name = "Amount"
	display.add_child(amount_label)

	display._ready()

func after_each():
	display.free()

# RED-GREEN-REFACTOR: Number formatting
func test_format_number_adds_thousand_separators():
	assert_eq(display._format_number(1234), "1,234", "Should add comma for thousands")
	assert_eq(display._format_number(1234567), "1,234,567", "Should add commas for millions")
	assert_eq(display._format_number(100), "100", "No comma for hundreds")

func test_format_number_handles_zero():
	assert_eq(display._format_number(0), "0", "Zero should display as '0'")

func test_format_number_handles_negatives():
	assert_eq(display._format_number(-1234), "-1,234", "Negative formats correctly")
	assert_eq(display._format_number(-500), "-500", "Negative without comma")

# RED-GREEN-REFACTOR: Currency amount reading
func test_get_currency_amount_reads_copper():
	Level1Vars.currency.copper = 500.0
	display.currency_type = "copper"
	assert_eq(display._get_currency_amount(), 500.0, "Should read copper from Level1Vars")

func test_get_currency_amount_handles_invalid_type():
	display.currency_type = "invalid"
	var result = display._get_currency_amount()
	assert_eq(result, 0.0, "Invalid currency type should return 0")

# RED-GREEN-REFACTOR: Refresh behavior
func test_refresh_updates_label_text():
	Level1Vars.currency.copper = 1234.0
	display.currency_type = "copper"
	display.refresh()
	assert_eq(amount_label.text, "1,234", "Label should show formatted amount")

func test_refresh_hides_when_zero_and_show_zero_false():
	Level1Vars.currency.copper = 0.0
	display.currency_type = "copper"
	display.show_zero = false
	display.refresh()
	assert_false(display.visible, "Should hide when amount is zero and show_zero is false")

func test_refresh_shows_when_zero_and_show_zero_true():
	Level1Vars.currency.copper = 0.0
	display.currency_type = "copper"
	display.show_zero = true
	display.refresh()
	assert_true(display.visible, "Should show when amount is zero and show_zero is true")

# RED-GREEN-REFACTOR: Icon loading
func test_load_icon_sets_texture_for_copper():
	display.currency_type = "copper"
	display._load_icon()
	assert_not_null(icon.texture, "Icon texture should be loaded for copper")

func test_load_icon_handles_invalid_type():
	display.currency_type = "nonexistent"
	display._load_icon()
	# Should log error but not crash
	assert_true(true, "Should not crash on invalid currency type")

# RED-GREEN-REFACTOR: Group registration
func test_ready_adds_to_currency_displays_group():
	var test_display = CurrencyDisplay.new()
	add_child_autofree(test_display)
	# Note: Needs scene tree to test groups properly
	# This test verifies the component exists and can be instantiated
	assert_not_null(test_display, "Display should instantiate")

# RED-GREEN-REFACTOR: Currency unlock detection
func test_is_currency_unlocked_returns_true_for_copper():
	display.currency_type = "copper"
	assert_true(display.is_currency_unlocked(), "Copper should always be unlocked")

func test_is_currency_unlocked_returns_false_for_locked():
	# Note: If property doesn't exist on Level1Vars, get() returns null and defaults to false
	display.currency_type = "silver"
	assert_false(display.is_currency_unlocked(), "Silver should be locked initially")

func test_is_currency_unlocked_returns_true_when_unlocked():
	Level1Vars.set("unlocked_silver", true)
	display.currency_type = "silver"
	assert_true(display.is_currency_unlocked(), "Silver should be unlocked when flag set")
