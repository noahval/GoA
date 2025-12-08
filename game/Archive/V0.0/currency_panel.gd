extends Panel
## currency_panel.gd
## Reusable panel component for displaying currency with icons
## Automatically creates icon + label pairs for each visible currency

class_name CurrencyPanel

## Icon size in landscape mode (will be adjusted for portrait)
@export var icon_size_landscape: int = 32
@export var icon_size_portrait: int = 34
@export var show_currency_separator: bool = true
@export var separator_text: String = " | "
@export var icon_label_spacing: int = 4  # Space between icon and its label
@export var currency_spacing: int = 6  # Space between different currencies
@export var currencies_per_row: int = 2  # Number of currencies to show per row (0 = all in one row)

# Internal references
var _margin_container: MarginContainer
var _vbox_container: VBoxContainer
var _current_currencies: Array = []  # Array of {icon: String, value: String}
var _is_portrait: bool = false

func _ready():
	# Set up the base structure if not already set up
	if not _margin_container:
		_initialize_structure()

func _initialize_structure():
	# Clear any existing children
	for child in get_children():
		child.queue_free()

	# Create margin container
	_margin_container = MarginContainer.new()
	_margin_container.name = "MarginContainer"
	_margin_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	_margin_container.add_theme_constant_override("margin_left", 8)
	_margin_container.add_theme_constant_override("margin_top", 4)
	_margin_container.add_theme_constant_override("margin_right", 8)
	_margin_container.add_theme_constant_override("margin_bottom", 4)
	add_child(_margin_container)

	# Create VBox container to hold multiple rows
	_vbox_container = VBoxContainer.new()
	_vbox_container.name = "ContentVBox"
	_vbox_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_vbox_container.add_theme_constant_override("separation", 2)
	_margin_container.add_child(_vbox_container)

	DebugLogger.log_info("CurrencyPanel", "Initialized structure")

## Set up the currency display with icons and values
## @param currencies: Array of dictionaries with keys: "icon" (path), "value" (string)
## Example: [{"icon": "res://level1/icons/copper_icon.png", "value": "1,234"}]
func setup_currency_display(currencies: Array):
	if not _vbox_container:
		_initialize_structure()

	# Clear existing content
	for child in _vbox_container.get_children():
		child.queue_free()

	_current_currencies = currencies.duplicate()

	# Determine orientation
	var viewport_size = get_viewport_rect().size
	_is_portrait = viewport_size.y > viewport_size.x

	# Get current icon size based on orientation
	var current_icon_size = icon_size_portrait if _is_portrait else icon_size_landscape

	# Determine how many rows we need
	var num_rows = 1
	if currencies_per_row > 0:
		num_rows = ceili(float(currencies.size()) / float(currencies_per_row))

	# Create rows
	var currency_index = 0
	for row_idx in range(num_rows):
		# Create HBox for this row
		var row_hbox = HBoxContainer.new()
		row_hbox.name = "Row_%d" % row_idx
		row_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		row_hbox.add_theme_constant_override("separation", 0)
		_vbox_container.add_child(row_hbox)

		# Add currencies to this row
		var currencies_in_row = currencies_per_row if currencies_per_row > 0 else currencies.size()
		for i in range(currencies_in_row):
			if currency_index >= currencies.size():
				break

			var currency = currencies[currency_index]

			# Add separator before this currency (except for first one in the row)
			if i > 0 and show_currency_separator:
				var separator = Label.new()
				separator.name = "Separator_%d" % currency_index
				separator.text = separator_text
				separator.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				row_hbox.add_child(separator)

			# Create icon
			var icon = TextureRect.new()
			icon.name = "Icon_%d" % currency_index
			icon.custom_minimum_size = Vector2(current_icon_size, current_icon_size)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

			# Load texture
			if ResourceLoader.exists(currency.icon):
				icon.texture = load(currency.icon)
			else:
				DebugLogger.log_error("CurrencyPanel", "Icon not found: %s" % currency.icon)

			row_hbox.add_child(icon)

			# Add small spacing between icon and label
			var spacer = Control.new()
			spacer.name = "IconSpacer_%d" % currency_index
			spacer.custom_minimum_size = Vector2(icon_label_spacing, 0)
			row_hbox.add_child(spacer)

			# Create value label
			var label = Label.new()
			label.name = "Value_%d" % currency_index
			label.text = currency.value
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			row_hbox.add_child(label)

			currency_index += 1

	DebugLogger.log_info("CurrencyPanel", "Set up display with %d currencies in %d rows (icon size: %d)" % [currencies.size(), num_rows, current_icon_size])

## Update currency values without rebuilding the entire structure
## @param new_values: Array of strings matching the order of currencies passed to setup_currency_display
func update_currency_values(new_values: Array):
	if new_values.size() != _current_currencies.size():
		DebugLogger.log_error("CurrencyPanel", "update_currency_values: Array size mismatch (%d vs %d)" % [new_values.size(), _current_currencies.size()])
		return

	# Update cached values
	for i in range(new_values.size()):
		_current_currencies[i].value = new_values[i]

	# Update label nodes across all rows
	for i in range(new_values.size()):
		for row in _vbox_container.get_children():
			var label = row.get_node_or_null("Value_%d" % i)
			if label:
				label.text = new_values[i]
				break

## Calculate the minimum width needed for this panel
## Used by ResponsiveLayout for panel sizing
## Returns: width in pixels
func calculate_minimum_width() -> float:
	if not _vbox_container or _current_currencies.is_empty():
		return 100.0  # Minimum fallback

	var max_row_width = 0.0

	# Margins (left + right)
	var margin_width = 16.0  # 8px left + 8px right

	# Determine icon size
	var current_icon_size = icon_size_portrait if _is_portrait else icon_size_landscape

	# Calculate width for each row and find the maximum
	var currencies_in_row = currencies_per_row if currencies_per_row > 0 else _current_currencies.size()
	var num_rows = ceili(float(_current_currencies.size()) / float(currencies_in_row)) if currencies_per_row > 0 else 1

	for row_idx in range(num_rows):
		var row_width = 0.0
		var start_idx = row_idx * currencies_in_row
		var end_idx = min(start_idx + currencies_in_row, _current_currencies.size())

		for i in range(start_idx, end_idx):
			# Separator width (if not first currency in row)
			if i > start_idx and show_currency_separator:
				var font = get_theme_font("font")
				var font_size = get_theme_font_size("font_size")
				if font_size <= 0:
					font_size = 25  # Default
				if font:
					var sep_width = font.get_string_size(separator_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
					row_width += sep_width

			# Icon width
			row_width += current_icon_size

			# Icon-label spacing
			row_width += icon_label_spacing

			# Label width
			var currency = _current_currencies[i]
			var font = get_theme_font("font")
			var font_size = get_theme_font_size("font_size")
			if font_size <= 0:
				font_size = 25
			if font:
				var label_width = font.get_string_size(currency.value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
				row_width += label_width

			# Currency spacing (space before next currency in row)
			if i < end_idx - 1:
				row_width += currency_spacing

		max_row_width = max(max_row_width, row_width)

	var total_width = margin_width + max_row_width
	DebugLogger.log_info("CurrencyPanel", "Calculated minimum width: %.0f px (max row width)" % total_width)
	return total_width

## Update icon sizes when orientation changes
## Called by ResponsiveLayout during orientation changes
func update_icon_sizes_for_orientation(is_portrait: bool):
	_is_portrait = is_portrait
	var new_icon_size = icon_size_portrait if is_portrait else icon_size_landscape

	# Update all icon TextureRect sizes across all rows
	for i in range(_current_currencies.size()):
		for row in _vbox_container.get_children():
			var icon = row.get_node_or_null("Icon_%d" % i)
			if icon:
				icon.custom_minimum_size = Vector2(new_icon_size, new_icon_size)
				break

	DebugLogger.log_info("CurrencyPanel", "Updated icon sizes to %d for %s mode" % [new_icon_size, "portrait" if is_portrait else "landscape"])
