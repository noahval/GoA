class_name ErrorBoundaries
extends RefCounted

## Wrap critical operations with error boundaries to prevent cascading failures
## Shop, UI, Stat, and Resource operations are isolated so one failure doesn't crash everything

# Shop purchase with error boundary and refund on failure
static func safe_shop_purchase(item_name: String, cost, purchase_callback: Callable) -> bool:
	# Validate inputs
	if not CurrencyManager.can_afford(cost):
		Global.show_stat_notification("Cannot afford " + item_name)
		return false

	# Execute purchase in boundary
	var result = ErrorHandler.safe_call(func():
		if CurrencyManager.deduct_currency(cost):
			purchase_callback.call()
			return true
		return false
	, "Shop.purchase_" + item_name)

	if not result.success:
		# Purchase failed - refund currency
		ErrorHandler.handle_error("ShopPurchase", "Purchase failed: " + item_name, ErrorHandler.ErrorSeverity.MODERATE, {
			"item": item_name,
			"cost": cost
		})

		# Try to refund
		if typeof(cost) == TYPE_FLOAT or typeof(cost) == TYPE_INT:
			Level1Vars.currency.copper += cost
		elif typeof(cost) == TYPE_DICTIONARY:
			for currency_name in cost.keys():
				Level1Vars.currency[currency_name] += cost[currency_name]

		Global.show_stat_notification("Purchase failed - refunded")
		return false

	return true

# Stat operation with boundary
static func safe_stat_operation(stat_name: String, operation: Callable) -> bool:
	var result = ErrorHandler.safe_call(operation, "Stat." + stat_name)

	if not result.success:
		ErrorHandler.handle_error("StatOperation", "Stat operation failed: " + stat_name, ErrorHandler.ErrorSeverity.MINOR)
		return false

	return true

# UI update with boundary (won't crash if node missing)
static func safe_ui_update(ui_element_name: String, update_callback: Callable) -> void:
	var result = ErrorHandler.safe_call(update_callback, "UI." + ui_element_name)

	if not result.success:
		ErrorHandler.handle_error("UIUpdate", "UI update failed: " + ui_element_name, ErrorHandler.ErrorSeverity.MINOR)

# Resource operation with boundary and validation
static func safe_resource_operation(resource_name: String, operation: Callable, validate_callback: Callable = Callable()) -> bool:
	var result = ErrorHandler.safe_call(operation, "Resource." + resource_name)

	if not result.success:
		ErrorHandler.handle_error("ResourceOperation", "Resource operation failed: " + resource_name, ErrorHandler.ErrorSeverity.MODERATE, {
			"resource": resource_name
		})
		return false

	# Optional validation
	if validate_callback.is_valid():
		var valid = validate_callback.call()
		if not valid:
			ErrorHandler.handle_error("ResourceValidation", "Resource validation failed: " + resource_name, ErrorHandler.ErrorSeverity.MODERATE)
			return false

	return true
