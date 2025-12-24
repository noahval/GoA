extends HBoxContainer
class_name CurrencyDisplay

# ===== CONFIGURATION =====
# Which currency to display (default: copper)
@export var currency_type: String = "copper"

# Whether to show zero amounts (default: true)
@export var show_zero: bool = true

# ===== NODES =====
@onready var icon: TextureRect = $Icon
@onready var amount_label: Label = $Amount

# ===== ICON PATHS =====
const CURRENCY_ICONS = {
	"copper": "res://level1/icons/copper.png",
	# Add later when currencies unlock:
	# "silver": "res://level1/icons/silver.png",
	# "gold": "res://level1/icons/gold.png",
	# "platinum": "res://level1/icons/platinum.png",
}

# ===== LIFECYCLE =====
func _ready():
	# Add to refresh group for Global.refresh_all_currency_displays()
	add_to_group("currency_displays")

	# Load currency icon
	_load_icon()

	# Apply responsive scaling to icon (ResponsiveLayout doesn't scale TextureRect)
	var scale_factor = ResponsiveLayout.get_auto_scale()
	icon.custom_minimum_size = Vector2(32, 32) * scale_factor

	# Initial display
	refresh()

# ===== ICON LOADING =====
func _load_icon():
	if currency_type not in CURRENCY_ICONS:
		push_error("Unknown currency type: " + currency_type)
		return

	var icon_path = CURRENCY_ICONS[currency_type]

	# Validate file exists before loading
	if not ResourceLoader.exists(icon_path):
		push_error("Icon file missing: " + icon_path)
		return

	var texture = load(icon_path)
	if texture:
		icon.texture = texture
	else:
		push_error("Failed to load currency icon: " + icon_path)

# ===== GROUP-BASED REFRESH =====
# Component is added to "currency_displays" group in _ready()
# Global.refresh_all_currency_displays() calls refresh() on all group members
# This is triggered after any currency transaction

# ===== DISPLAY UPDATE =====
func refresh():
	"""Update display to show current currency amount"""
	var amount = _get_currency_amount()

	# Hide if zero and show_zero is false
	if amount == 0 and not show_zero:
		visible = false
		return

	visible = true
	amount_label.text = _format_number(amount)

# ===== CURRENCY ACCESS =====
func _get_currency_amount() -> float:
	# Simplified using dictionary.get() instead of match statement
	return Level1Vars.currency.get(currency_type, 0.0)

# ===== NUMBER FORMATTING =====
func _format_number(value: float) -> String:
	var int_value = int(value)

	# Custom thousand separator implementation
	# (Godot 4.5 String.format() doesn't support thousand separators)
	var num_str = str(int_value)
	var result = ""
	var count = 0

	# Handle negative numbers
	var is_negative = int_value < 0
	if is_negative:
		num_str = num_str.substr(1)  # Remove minus sign for processing

	# Iterate from right to left, add commas every 3 digits
	for i in range(num_str.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = num_str[i] + result
		count += 1

	# Re-add minus sign if negative
	if is_negative:
		result = "-" + result

	return result

# ===== PUBLIC API =====
# Change currency type dynamically
func set_currency_type(new_type: String):
	if new_type not in CURRENCY_ICONS:
		push_error("Invalid currency type: " + new_type)
		return
	currency_type = new_type
	_load_icon()
	refresh()

# Check if currency is unlocked
func is_currency_unlocked() -> bool:
	# Integrate with Level1Vars unlock system
	match currency_type:
		"copper":
			return true  # Always unlocked
		"silver":
			return Level1Vars.get("unlocked_silver") if Level1Vars.get("unlocked_silver") != null else false
		"gold":
			return Level1Vars.get("unlocked_gold") if Level1Vars.get("unlocked_gold") != null else false
		"platinum":
			return Level1Vars.get("unlocked_platinum") if Level1Vars.get("unlocked_platinum") != null else false
		_:
			return false
