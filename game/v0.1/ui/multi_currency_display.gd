extends PanelContainer
class_name MultiCurrencyDisplay

# ===== CONFIGURATION =====
# Show zero amounts for all currencies (default: true)
@export var show_zero: bool = true

# Spacing between currency displays (default: 32px)
@export var spacing: int = 32

# ===== NODES =====
var container: HBoxContainer

# ===== LIFECYCLE =====
func _ready():
	# Apply grey background styling (like MutedButton from plan 1.8)
	_apply_background_style()

	# Create HBoxContainer for currency displays
	container = HBoxContainer.new()
	container.add_theme_constant_override("separation", spacing)
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(container)

	# Create displays for all 3 currencies
	_add_currency_display("copper")
	_add_currency_display("holes")
	_add_currency_display("weeps")

# ===== INTERNAL =====
func _apply_background_style():
	# Create StyleBoxFlat for grey background (MutedButton style from plan 1.8)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.25, 0.25, 0.25, 0.3)  # Dark grey, 30% opacity
	style.border_color = Color(0.4, 0.4, 0.4, 0.4)  # Subtle grey border
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 6
	style.content_margin_bottom = 6

	add_theme_stylebox_override("panel", style)

func _add_currency_display(currency_type: String):
	var display = preload("res://ui/currency_display.tscn").instantiate()
	display.currency_type = currency_type
	display.show_zero = show_zero
	container.add_child(display)
