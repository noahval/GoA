extends GutTest

# Test suite for currency system (Plan 1.5)
# Following TDD approach: Tests written FIRST, implementation comes after

# Reset to known state before each test
func before_each():
	# Reset both currency dictionaries to empty state
	Level1Vars.currency = Level1Vars._get_empty_currency_dict()
	Level1Vars.lifetime_currency = Level1Vars._get_empty_currency_dict()

# =============================================================================
# TDD CYCLE 1: Data Structures
# =============================================================================

func test_currency_dictionaries_exist():
	assert_not_null(Level1Vars.currency, "Currency dict exists")
	assert_not_null(Level1Vars.lifetime_currency, "Lifetime dict exists")

func test_currency_has_all_four_types():
	assert_true("copper" in Level1Vars.currency, "Has copper key")
	assert_true("silver" in Level1Vars.currency, "Has silver key")
	assert_true("gold" in Level1Vars.currency, "Has gold key")
	assert_true("platinum" in Level1Vars.currency, "Has platinum key")

func test_lifetime_currency_has_all_four_types():
	assert_true("copper" in Level1Vars.lifetime_currency, "Lifetime has copper")
	assert_true("silver" in Level1Vars.lifetime_currency, "Lifetime has silver")
	assert_true("gold" in Level1Vars.lifetime_currency, "Lifetime has gold")
	assert_true("platinum" in Level1Vars.lifetime_currency, "Lifetime has platinum")

func test_valid_currencies_constant():
	assert_eq(Level1Vars.VALID_CURRENCIES.size(), 4, "Has 4 currency types")
	assert_true("copper" in Level1Vars.VALID_CURRENCIES, "Copper is valid")
	assert_true("silver" in Level1Vars.VALID_CURRENCIES, "Silver is valid")
	assert_true("gold" in Level1Vars.VALID_CURRENCIES, "Gold is valid")
	assert_true("platinum" in Level1Vars.VALID_CURRENCIES, "Platinum is valid")

func test_get_empty_currency_dict_helper():
	var empty = Level1Vars._get_empty_currency_dict()
	assert_eq(empty["copper"], 0.0, "Copper starts at 0")
	assert_eq(empty["silver"], 0.0, "Silver starts at 0")
	assert_eq(empty["gold"], 0.0, "Gold starts at 0")
	assert_eq(empty["platinum"], 0.0, "Platinum starts at 0")

# =============================================================================
# TDD CYCLE 2: Add Currency Function
# =============================================================================

func test_add_currency_basic():
	Level1Vars.add_currency("copper", 100.0)

	assert_eq(Level1Vars.currency["copper"], 100.0, "Copper added correctly")
	assert_eq(Level1Vars.lifetime_currency["copper"], 100.0, "Lifetime tracking works")

func test_add_currency_accumulates():
	Level1Vars.add_currency("copper", 50.0)
	Level1Vars.add_currency("copper", 30.0)

	assert_eq(Level1Vars.currency["copper"], 80.0, "Copper accumulates")
	assert_eq(Level1Vars.lifetime_currency["copper"], 80.0, "Lifetime accumulates")

func test_add_currency_works_for_all_types():
	Level1Vars.add_currency("copper", 10.0)
	Level1Vars.add_currency("silver", 20.0)
	Level1Vars.add_currency("gold", 30.0)
	Level1Vars.add_currency("platinum", 40.0)

	assert_eq(Level1Vars.currency["copper"], 10.0, "Copper added")
	assert_eq(Level1Vars.currency["silver"], 20.0, "Silver added")
	assert_eq(Level1Vars.currency["gold"], 30.0, "Gold added")
	assert_eq(Level1Vars.currency["platinum"], 40.0, "Platinum added")

func test_add_currency_rejects_invalid_type():
	Level1Vars.add_currency("invalid", 10.0)

	# Should not crash, just log error
	# Invalid type should not be added to dictionary
	assert_eq(Level1Vars.currency.get("invalid", -1), -1, "Invalid type not added")

func test_add_currency_rejects_negative():
	var before = Level1Vars.currency["copper"]
	Level1Vars.add_currency("copper", -10.0)

	assert_eq(Level1Vars.currency["copper"], before, "Negative amount rejected")

func test_add_currency_rejects_zero():
	var before = Level1Vars.currency["silver"]
	Level1Vars.add_currency("silver", 0.0)

	assert_eq(Level1Vars.currency["silver"], before, "Zero amount rejected")

func test_add_currency_signal_emission():
	var signal_watcher = watch_signals(Level1Vars)

	Level1Vars.add_currency("gold", 50.0)

	assert_signal_emitted(Level1Vars, "currency_changed", "Signal emitted")
	assert_signal_emit_count(Level1Vars, "currency_changed", 1, "Signal emitted once")

# =============================================================================
# TDD CYCLE 3: Deduct Currency Function
# =============================================================================

func test_deduct_currency_basic():
	Level1Vars.currency["silver"] = 50.0
	var success = Level1Vars.deduct_currency("silver", 30.0)

	assert_true(success, "Deduction succeeded")
	assert_eq(Level1Vars.currency["silver"], 20.0, "Silver deducted correctly")
	assert_eq(Level1Vars.lifetime_currency["silver"], 0.0, "Lifetime unchanged by deduction")

func test_deduct_currency_insufficient_funds():
	Level1Vars.currency["gold"] = 10.0
	var success = Level1Vars.deduct_currency("gold", 20.0)

	assert_false(success, "Deduction failed correctly")
	assert_eq(Level1Vars.currency["gold"], 10.0, "Gold unchanged")

func test_deduct_currency_exact_amount():
	Level1Vars.currency["platinum"] = 5.0
	var success = Level1Vars.deduct_currency("platinum", 5.0)

	assert_true(success, "Exact deduction succeeded")
	assert_eq(Level1Vars.currency["platinum"], 0.0, "Platinum now zero")

func test_deduct_currency_rejects_invalid_type():
	var success = Level1Vars.deduct_currency("invalid", 10.0)

	assert_false(success, "Invalid type rejected")

func test_deduct_currency_rejects_negative():
	Level1Vars.currency["copper"] = 100.0
	var success = Level1Vars.deduct_currency("copper", -10.0)

	assert_false(success, "Negative amount rejected")
	assert_eq(Level1Vars.currency["copper"], 100.0, "Copper unchanged")

func test_deduct_currency_rejects_zero():
	Level1Vars.currency["silver"] = 100.0
	var success = Level1Vars.deduct_currency("silver", 0.0)

	assert_false(success, "Zero amount rejected")
	assert_eq(Level1Vars.currency["silver"], 100.0, "Silver unchanged")

func test_deduct_currency_signal_emission():
	Level1Vars.currency["copper"] = 100.0
	var signal_watcher = watch_signals(Level1Vars)

	Level1Vars.deduct_currency("copper", 50.0)

	assert_signal_emitted(Level1Vars, "currency_changed", "Signal emitted on deduction")

func test_deduct_currency_no_signal_on_failure():
	Level1Vars.currency["gold"] = 10.0
	var signal_watcher = watch_signals(Level1Vars)

	Level1Vars.deduct_currency("gold", 50.0)  # Insufficient funds

	assert_signal_emit_count(Level1Vars, "currency_changed", 0, "No signal when deduction fails")

# =============================================================================
# TDD CYCLE 4: Helper Functions (get_currency, can_afford)
# =============================================================================

func test_get_currency_returns_current_amount():
	Level1Vars.currency["copper"] = 123.0

	assert_eq(Level1Vars.get_currency("copper"), 123.0, "Returns correct amount")

func test_get_currency_returns_zero_for_empty():
	assert_eq(Level1Vars.get_currency("silver"), 0.0, "Returns 0 for empty currency")

func test_get_currency_returns_zero_for_invalid_type():
	assert_eq(Level1Vars.get_currency("invalid"), 0.0, "Returns 0 for invalid type")

func test_can_afford_true_when_sufficient():
	Level1Vars.currency["gold"] = 100.0

	assert_true(Level1Vars.can_afford("gold", 50.0), "Can afford when sufficient")
	assert_true(Level1Vars.can_afford("gold", 100.0), "Can afford exact amount")

func test_can_afford_false_when_insufficient():
	Level1Vars.currency["platinum"] = 10.0

	assert_false(Level1Vars.can_afford("platinum", 50.0), "Cannot afford when insufficient")

func test_can_afford_false_for_invalid_type():
	assert_false(Level1Vars.can_afford("invalid", 10.0), "Cannot afford invalid type")

# =============================================================================
# TDD CYCLE 5: Bulk Operations
# =============================================================================

func test_can_afford_all_success():
	Level1Vars.currency["copper"] = 100.0
	Level1Vars.currency["silver"] = 10.0

	var costs = {"copper": 50.0, "silver": 5.0}
	assert_true(Level1Vars.can_afford_all(costs), "Can afford both currencies")

func test_can_afford_all_failure_one_insufficient():
	Level1Vars.currency["copper"] = 100.0
	Level1Vars.currency["silver"] = 2.0

	var costs = {"copper": 50.0, "silver": 5.0}
	assert_false(Level1Vars.can_afford_all(costs), "Cannot afford when one is insufficient")

func test_can_afford_all_failure_all_insufficient():
	Level1Vars.currency["copper"] = 10.0
	Level1Vars.currency["silver"] = 1.0

	var costs = {"copper": 50.0, "silver": 5.0}
	assert_false(Level1Vars.can_afford_all(costs), "Cannot afford when all are insufficient")

func test_can_afford_all_empty_costs():
	var costs = {}
	assert_true(Level1Vars.can_afford_all(costs), "Can afford empty cost (vacuous truth)")

func test_deduct_currencies_success():
	Level1Vars.currency["copper"] = 100.0
	Level1Vars.currency["silver"] = 10.0

	var costs = {"copper": 50.0, "silver": 5.0}
	var success = Level1Vars.deduct_currencies(costs)

	assert_true(success, "Bulk deduction succeeded")
	assert_eq(Level1Vars.currency["copper"], 50.0, "Copper deducted")
	assert_eq(Level1Vars.currency["silver"], 5.0, "Silver deducted")

func test_deduct_currencies_all_or_nothing():
	Level1Vars.currency["copper"] = 100.0
	Level1Vars.currency["silver"] = 2.0

	var costs = {"copper": 50.0, "silver": 5.0}
	var success = Level1Vars.deduct_currencies(costs)

	assert_false(success, "Transaction failed")
	assert_eq(Level1Vars.currency["copper"], 100.0, "Copper not deducted")
	assert_eq(Level1Vars.currency["silver"], 2.0, "Silver not deducted")

func test_deduct_currencies_multiple_types():
	Level1Vars.currency["copper"] = 1000.0
	Level1Vars.currency["silver"] = 100.0
	Level1Vars.currency["gold"] = 10.0
	Level1Vars.currency["platinum"] = 1.0

	var costs = {
		"copper": 500.0,
		"silver": 50.0,
		"gold": 5.0,
		"platinum": 0.5
	}
	var success = Level1Vars.deduct_currencies(costs)

	assert_true(success, "Multi-currency deduction succeeded")
	assert_eq(Level1Vars.currency["copper"], 500.0, "Copper deducted")
	assert_eq(Level1Vars.currency["silver"], 50.0, "Silver deducted")
	assert_eq(Level1Vars.currency["gold"], 5.0, "Gold deducted")
	assert_eq(Level1Vars.currency["platinum"], 0.5, "Platinum deducted")

# =============================================================================
# TDD CYCLE 6: Reset Functions
# =============================================================================

func test_reset_all_currency_clears_current():
	Level1Vars.currency["copper"] = 100.0
	Level1Vars.currency["silver"] = 50.0
	Level1Vars.currency["gold"] = 25.0
	Level1Vars.currency["platinum"] = 10.0

	Level1Vars.reset_all_currency()

	assert_eq(Level1Vars.currency["copper"], 0.0, "Copper reset")
	assert_eq(Level1Vars.currency["silver"], 0.0, "Silver reset")
	assert_eq(Level1Vars.currency["gold"], 0.0, "Gold reset")
	assert_eq(Level1Vars.currency["platinum"], 0.0, "Platinum reset")

func test_reset_all_currency_clears_lifetime():
	Level1Vars.lifetime_currency["copper"] = 1000.0
	Level1Vars.lifetime_currency["silver"] = 500.0

	Level1Vars.reset_all_currency()

	assert_eq(Level1Vars.lifetime_currency["copper"], 0.0, "Lifetime copper reset")
	assert_eq(Level1Vars.lifetime_currency["silver"], 0.0, "Lifetime silver reset")
	assert_eq(Level1Vars.lifetime_currency["gold"], 0.0, "Lifetime gold reset")
	assert_eq(Level1Vars.lifetime_currency["platinum"], 0.0, "Lifetime platinum reset")

# =============================================================================
# Integration Tests
# =============================================================================

func test_lifetime_never_decreases():
	# Add currency
	Level1Vars.add_currency("copper", 100.0)
	assert_eq(Level1Vars.lifetime_currency["copper"], 100.0, "Lifetime increased")

	# Deduct currency
	Level1Vars.deduct_currency("copper", 50.0)
	assert_eq(Level1Vars.lifetime_currency["copper"], 100.0, "Lifetime unchanged after deduction")

	# Add more
	Level1Vars.add_currency("copper", 25.0)
	assert_eq(Level1Vars.lifetime_currency["copper"], 125.0, "Lifetime increased again")

func test_complex_transaction_flow():
	# Player earns some copper
	Level1Vars.add_currency("copper", 1000.0)

	# Buy something for 500 copper
	assert_true(Level1Vars.can_afford("copper", 500.0), "Can afford purchase")
	Level1Vars.deduct_currency("copper", 500.0)

	# Check final state
	assert_eq(Level1Vars.currency["copper"], 500.0, "Copper remaining correct")
	assert_eq(Level1Vars.lifetime_currency["copper"], 1000.0, "Lifetime shows total earned")

func test_multi_currency_upgrade_scenario():
	# Player has some currencies
	Level1Vars.add_currency("copper", 1000.0)
	Level1Vars.add_currency("silver", 50.0)

	# Upgrade costs 500 copper + 10 silver
	var upgrade_cost = {"copper": 500.0, "silver": 10.0}

	# Check affordability
	assert_true(Level1Vars.can_afford_all(upgrade_cost), "Can afford upgrade")

	# Purchase upgrade
	assert_true(Level1Vars.deduct_currencies(upgrade_cost), "Upgrade purchased")

	# Verify final amounts
	assert_eq(Level1Vars.currency["copper"], 500.0, "Copper spent correctly")
	assert_eq(Level1Vars.currency["silver"], 40.0, "Silver spent correctly")
	assert_eq(Level1Vars.lifetime_currency["copper"], 1000.0, "Lifetime copper tracked")
	assert_eq(Level1Vars.lifetime_currency["silver"], 50.0, "Lifetime silver tracked")
