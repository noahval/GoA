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
@export var icon_label_spacing: int = 8  # Space between icon and its label
@export var currency_spacing: int = 12  # Space between different currencies

# Internal references
var _margin_container: MarginContainer
var _hbox_container: HBoxContainer
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

	# Create HBox container for icon+label pairs
	_hbox_container = HBoxContainer.new()
	_hbox_container.name = "ContentHBox"
	_hbox_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_margin_container.add_child(_hbox_container)

	DebugLogger.log_info("CurrencyPanel", "Initialized structure")

## Set up the currency display with icons and values
## @param currencies: Array of dictionaries with keys: "icon" (path), "value" (string)
## Example: [{"icon": "res://level1/icons/copper_icon.png", "value": "1,234"}]
func setup_currency_display(currencies: Array):
	if not _hbox_container:
		_initialize_structure()

	# Clear existing content
	for child in _hbox_container.get_children():
		child.queue_free()

	_current_currencies = currencies.duplicate()

	# Determine orientation
	var viewport_size = get_viewport_rect().size
	_is_portrait = viewport_size.y > viewport_size.x

	# Get current icon size based on orientation
	var current_icon_size = icon_size_portrait if _is_portrait else icon_size_landscape

	# Create icon+label pairs
	for i in range(currencies.size()):
		var currency = currencies[i]

		# Add separator before this currency (except for first one)
		if i > 0 and show_currency_separator:
			var separator = Label.new()
			separator.name = "Separator_%d" % i
			separator.text = separator_text
			separator.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			_hbox_container.add_child(separator)

		# Create icon
		var icon = TextureRect.new()
		icon.name = "Icon_%d" % i
		icon.custom_minimum_size = Vector2(current_icon_size, current_icon_size)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		# Load texture
		if ResourceLoader.exists(currency.icon):
			icon.texture = load(currency.icon)
		else:
			DebugLogger.log_error("CurrencyPanel", "Icon not found: %s" % currency.icon)

		_hbox_container.add_child(icon)

		# Add small spacing between icon and label
		var spacer = Control.new()
		spacer.name = "IconSpacer_%d" % i
		spacer.custom_minimum_size = Vector2(icon_label_spacing, 0)
		_hbox_container.add_child(spacer)

		# Create value label
		var label = Label.new()
		label.name = "Value_%d" % i
		label.text = currency.value
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_hbox_container.add_child(label)

	# Set HBox spacing for currency separation
	_hbox_container.add_theme_constant_override("separation", 0)  # We handle spacing manually with spacers

	DebugLogger.log_info("CurrencyPanel", "Set up display with %d currencies (icon size: %d)" % [currencies.size(), current_icon_size])

## Update currency values without rebuilding the entire structure
## @param new_values: Array of strings matching the order of currencies passed to setup_currency_display
func update_currency_values(new_values: Array):
	if new_values.size() != _current_currencies.size():
		DebugLogger.log_error("CurrencyPanel", "update_currency_values: Array size mismatch (%d vs %d)" % [new_values.size(), _current_currencies.size()])
		return

	# Update cached values
	for i in range(new_values.size()):
		_current_currencies[i].value = new_values[i]

	# Update label nodes
	for i in range(new_values.size()):
		var label = _hbox_container.get_node_or_null("Value_%d" % i)
		if label:
			label.text = new_values[i]

## Calculate the minimum width needed for this panel
## Used by ResponsiveLayout for panel sizing
## Returns: width in pixels
func calculate_minimum_width() -> float:
	if not _hbox_container or _current_currencies.is_empty():
		return 100.0  # Minimum fallback

	var total_width = 0.0

	# Margins (left + right)
	total_width += 16.0  # 8px left + 8px right

	# Determine icon size
	var current_icon_size = icon_size_portrait if _is_portrait else icon_size_landscape

	for i in range(_current_currencies.size()):
		# Separator width (if not first currency)
		if i > 0 and show_currency_separator:
			var font = get_theme_font("font")
			var font_size = get_theme_font_size("font_size")
			if font_size <= 0:
				font_size = 25  # Default
			if font:
				var sep_width = font.get_string_size(separator_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
				total_width += sep_width

		# Icon width
		total_width += current_icon_size

		# Icon-label spacing
		total_width += icon_label_spacing

		# Label width
		var currency = _current_currencies[i]
		var font = get_theme_font("font")
		var font_size = get_theme_font_size("font_size")
		if font_size <= 0:
			font_size = 25
		if font:
			var label_width = font.get_string_size(currency.value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			total_width += label_width

		# Currency spacing (space before next currency)
		if i < _current_currencies.size() - 1:
			total_width += currency_spacing

	DebugLogger.log_info("CurrencyPanel", "Calculated minimum width: %.0f px" % total_width)
	return total_width

## Update icon sizes when orientation changes
## Called by ResponsiveLayout during orientation changes
func update_icon_sizes_for_orientation(is_portrait: bool):
	_is_portrait = is_portrait
	var new_icon_size = icon_size_portrait if is_portrait else icon_size_landscape

	# Update all icon TextureRect sizes
	for i in range(_current_currencies.size()):
		var icon = _hbox_container.get_node_or_null("Icon_%d" % i)
		if icon:
			icon.custom_minimum_size = Vector2(new_icon_size, new_icon_size)

	DebugLogger.log_info("CurrencyPanel", "Updated icon sizes to %d for %s mode" % [new_icon_size, "portrait" if is_portrait else "landscape"])
