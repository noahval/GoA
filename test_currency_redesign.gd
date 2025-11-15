extends Node

## Headless test suite for Currency Scaling Redesign
## Tests all Priority 1-3 implementations

var test_results = []
var tests_passed = 0
var tests_failed = 0

func _ready():
	print("\n========================================")
	print("Currency Scaling Redesign - Test Suite")
	print("========================================\n")

	# Reset test environment
	Level1Vars.reset_all()

	# Run all tests
	test_currency_ratios()
	test_currency_unlocks()
	test_storage_caps()
	test_coal_caps()
	test_atm_deposits()
	test_atm_withdrawals()
	test_exchange_with_atm()
	test_helper_functions()
	test_prestige_persistence()

	# Print summary
	print("\n========================================")
	print("Test Summary")
	print("========================================")
	print("Tests Passed: %d" % tests_passed)
	print("Tests Failed: %d" % tests_failed)
	print("Success Rate: %.1f%%" % ((tests_passed / float(tests_passed + tests_failed)) * 100.0))
	print("========================================\n")

	# Exit
	get_tree().quit()

func assert_equal(actual, expected, test_name: String):
	if actual == expected:
		print("[PASS] %s" % test_name)
		tests_passed += 1
		return true
	else:
		print("[FAIL] %s - Expected: %s, Got: %s" % [test_name, str(expected), str(actual)])
		tests_failed += 1
		return false

func assert_true(condition: bool, test_name: String):
	return assert_equal(condition, true, test_name)

func assert_false(condition: bool, test_name: String):
	return assert_equal(condition, false, test_name)

func assert_approx(actual: float, expected: float, test_name: String, epsilon: float = 0.01):
	if abs(actual - expected) < epsilon:
		print("[PASS] %s" % test_name)
		tests_passed += 1
		return true
	else:
		print("[FAIL] %s - Expected: %.2f, Got: %.2f" % [test_name, expected, actual])
		tests_failed += 1
		return false

## Test 1: Currency Ratios
func test_currency_ratios():
	print("\n--- Test 1: Currency Ratios (1000:1) ---")

	# Check conversion rates
	assert_equal(
		CurrencyManager.CONVERSION_RATES[CurrencyManager.CurrencyType.COPPER],
		1,
		"Copper conversion rate = 1"
	)

	assert_equal(
		CurrencyManager.CONVERSION_RATES[CurrencyManager.CurrencyType.SILVER],
		1000,
		"Silver conversion rate = 1000"
	)

	assert_equal(
		CurrencyManager.CONVERSION_RATES[CurrencyManager.CurrencyType.GOLD],
		1000000,
		"Gold conversion rate = 1,000,000"
	)

	assert_equal(
		CurrencyManager.CONVERSION_RATES[CurrencyManager.CurrencyType.PLATINUM],
		1000000000,
		"Platinum conversion rate = 1,000,000,000"
	)

## Test 2: Currency Unlocks
func test_currency_unlocks():
	print("\n--- Test 2: Currency Unlock Thresholds ---")

	# Reset
	Level1Vars.reset_all()
	CurrencyManager.unlocked_currencies[CurrencyManager.CurrencyType.GOLD] = false
	CurrencyManager.unlocked_currencies[CurrencyManager.CurrencyType.PLATINUM] = false
	Level1Vars._unlocked_gold = false
	Level1Vars._unlocked_platinum = false

	# Test silver unlock (500 copper lifetime)
	Level1Vars.lifetime_currency.copper = 500
	CurrencyManager._check_currency_unlocks()
	assert_true(
		CurrencyManager.unlocked_currencies[CurrencyManager.CurrencyType.SILVER],
		"Silver unlocks at 500 copper lifetime"
	)

	# Test gold unlock (50 silver in hand)
	Level1Vars.currency.silver = 50
	Level1Vars.check_currency_unlocks()
	assert_true(
		Level1Vars._unlocked_gold,
		"Gold unlocks at 50 silver in pocket"
	)

	# Test platinum unlock (50 gold in hand)
	Level1Vars.currency.gold = 50
	Level1Vars.check_currency_unlocks()
	assert_true(
		Level1Vars._unlocked_platinum,
		"Platinum unlocks at 50 gold in pocket"
	)

## Test 3: Storage Caps
func test_storage_caps():
	print("\n--- Test 3: Storage Capacity System ---")

	# Reset
	Level1Vars.reset_all()

	# Test initial cap
	assert_equal(
		Level1Vars.get_currency_cap(),
		200,
		"Initial currency cap = 200"
	)

	# Test cap enforcement
	Level1Vars.currency.copper = 0
	var added = CurrencyManager.add_currency(CurrencyManager.CurrencyType.COPPER, 250, "test")
	assert_equal(
		int(added),
		200,
		"Adding 250 copper to empty pocket with 200 cap adds only 200"
	)
	assert_equal(
		int(Level1Vars.currency.copper),
		200,
		"Copper amount capped at 200"
	)

	# Test hitting cap
	var added2 = CurrencyManager.add_currency(CurrencyManager.CurrencyType.COPPER, 100, "test")
	assert_equal(
		int(added2),
		0,
		"Adding to full pocket adds 0"
	)

	# Test upgrade
	Level1Vars.storage_capacity_level = 1
	assert_equal(
		Level1Vars.get_currency_cap(),
		300,
		"Storage level 1 cap = 300"
	)

	# Test max level
	Level1Vars.storage_capacity_level = 12
	assert_equal(
		Level1Vars.get_currency_cap(),
		10000,
		"Storage level 12 (max) cap = 10,000"
	)

## Test 4: Coal Caps
func test_coal_caps():
	print("\n--- Test 4: Coal Tracking System ---")

	# Reset
	Level1Vars.reset_all()

	# Test initial cap
	assert_equal(
		Level1Vars.get_coal_cap(),
		1000,
		"Initial coal cap = 1,000"
	)

	# Test upgrades
	Level1Vars.coal_tracking_level = 1
	assert_equal(
		Level1Vars.get_coal_cap(),
		2000,
		"Coal tracking level 1 cap = 2,000"
	)

	Level1Vars.coal_tracking_level = 6
	assert_equal(
		Level1Vars.get_coal_cap(),
		35000,
		"Coal tracking level 6 (max) cap = 35,000"
	)

	# Test overflow check
	Level1Vars.coal_tracking_level = 0
	Level1Vars.coal = 1000
	assert_true(
		Level1Vars.would_exceed_coal_cap(100),
		"Adding 100 to 1000 coal exceeds cap of 1000"
	)

	assert_false(
		Level1Vars.would_exceed_coal_cap(0),
		"Adding 0 to 1000 coal does not exceed cap"
	)

## Test 5: ATM Deposits
func test_atm_deposits():
	print("\n--- Test 5: ATM Deposit System ---")

	# Reset
	Level1Vars.reset_all()
	Level1Vars.currency.copper = 100
	Global.charisma = 1  # Reset charisma for predictable fees

	# Test deposit fee calculation
	var fee_percent = CurrencyManager.calculate_deposit_fee()
	assert_approx(
		fee_percent,
		0.12,
		"Base deposit fee = 12%",
		0.001
	)

	# Test deposit
	var result = CurrencyManager.deposit_to_atm(CurrencyManager.CurrencyType.COPPER, 100)
	assert_true(
		result.success,
		"Deposit 100 copper succeeds"
	)
	assert_approx(
		result.fee,
		12.0,
		"Deposit fee = 12 copper (12% of 100)",
		0.1
	)
	assert_approx(
		result.deposited,
		88.0,
		"Net deposit = 88 copper (100 - 12 fee)",
		0.1
	)
	assert_equal(
		int(Level1Vars.currency.copper),
		0,
		"Pocket copper = 0 after depositing all"
	)
	assert_approx(
		Level1Vars.atm_deposits.copper,
		88.0,
		"ATM balance = 88 copper",
		0.1
	)

	# Test charisma reduction
	Global.charisma = 5
	var reduced_fee = CurrencyManager.calculate_deposit_fee()
	assert_approx(
		reduced_fee,
		0.10,
		"Deposit fee with charisma 5 = 10% (12% - 4*0.5%)",
		0.001
	)

## Test 6: ATM Withdrawals
func test_atm_withdrawals():
	print("\n--- Test 6: ATM Withdrawal System ---")

	# Reset
	Level1Vars.reset_all()
	Level1Vars.atm_deposits.copper = 100
	Level1Vars.storage_capacity_level = 0  # 200 cap

	# Test withdrawal
	var result = CurrencyManager.withdraw_from_atm(CurrencyManager.CurrencyType.COPPER, 50)
	assert_true(
		result.success,
		"Withdraw 50 copper succeeds"
	)
	assert_equal(
		int(result.withdrawn),
		50,
		"Withdrawn amount = 50"
	)
	assert_equal(
		int(Level1Vars.currency.copper),
		50,
		"Pocket copper = 50 after withdrawal"
	)
	assert_approx(
		Level1Vars.atm_deposits.copper,
		50.0,
		"ATM balance = 50 after withdrawal",
		0.1
	)

	# Test pocket full
	Level1Vars.currency.copper = 200  # At cap
	var result2 = CurrencyManager.withdraw_from_atm(CurrencyManager.CurrencyType.COPPER, 10)
	assert_false(
		result2.success,
		"Withdrawal fails when pocket is full"
	)
	assert_equal(
		result2.error,
		"pocket_full",
		"Error is 'pocket_full'"
	)

## Test 7: Exchange with ATM
func test_exchange_with_atm():
	print("\n--- Test 7: Currency Exchange with ATM ---")

	# Reset
	Level1Vars.reset_all()
	CurrencyManager.unlocked_currencies[CurrencyManager.CurrencyType.SILVER] = true
	Global.charisma = 1  # Predictable fees

	# Setup: 100 in pocket, 400 in ATM
	Level1Vars.currency.copper = 100
	Level1Vars.atm_deposits.copper = 400.0

	# Exchange 500 copper to silver (should pull from both)
	var result = CurrencyManager.exchange_currency_with_fee(
		CurrencyManager.CurrencyType.COPPER,
		CurrencyManager.CurrencyType.SILVER,
		500
	)

	assert_true(
		result.success,
		"Exchange 500 copper succeeds (100 pocket + 400 ATM)"
	)

	assert_equal(
		int(Level1Vars.currency.copper),
		0,
		"Pocket copper = 0 after exchange"
	)

	assert_approx(
		Level1Vars.atm_deposits.copper,
		0.0,
		"ATM copper = 0 after exchange",
		0.1
	)

	# Check silver received (500 copper - fees = ~460, / 1000 = ~0.46 silver)
	assert_true(
		Level1Vars.currency.silver > 0.4 and Level1Vars.currency.silver < 0.5,
		"Received approximately 0.46 silver"
	)

## Test 8: Helper Functions
func test_helper_functions():
	print("\n--- Test 8: Helper Functions ---")

	# Reset
	Level1Vars.reset_all()
	Global.strength = 5
	Global.dexterity = 4
	Global.constitution = 3
	Global.intelligence = 6
	Global.wisdom = 2
	Global.charisma = 1

	# Test combined stats
	assert_equal(
		Level1Vars.get_combined_stats_level(),
		21,
		"Combined stats = 21 (5+4+3+6+2+1)"
	)

	# Test currency overflow check
	Level1Vars.currency.copper = 150
	Level1Vars.storage_capacity_level = 0  # 200 cap

	assert_true(
		Level1Vars.would_exceed_currency_cap("copper", 100),
		"150 + 100 exceeds 200 cap"
	)

	assert_false(
		Level1Vars.would_exceed_currency_cap("copper", 40),
		"150 + 40 does not exceed 200 cap"
	)

## Test 9: Prestige Persistence
func test_prestige_persistence():
	print("\n--- Test 9: Prestige Persistence ---")

	# Setup
	Level1Vars.reset_all()
	Level1Vars.storage_capacity_level = 5
	Level1Vars.coal_tracking_level = 3
	Level1Vars.atm_deposits.copper = 100.0
	Level1Vars.atm_deposits.silver = 50.0
	Level1Vars.currency.copper = 200
	Level1Vars.currency.platinum = 10
	Level1Vars.phase_2_unlocked = true

	# Prestige
	Level1Vars.reset_for_prestige()

	# Check persistence
	assert_equal(
		Level1Vars.storage_capacity_level,
		5,
		"Storage capacity persists through prestige"
	)

	assert_equal(
		Level1Vars.coal_tracking_level,
		3,
		"Coal tracking persists through prestige"
	)

	assert_approx(
		Level1Vars.atm_deposits.copper,
		100.0,
		"ATM copper persists through prestige",
		0.1
	)

	assert_approx(
		Level1Vars.atm_deposits.silver,
		50.0,
		"ATM silver persists through prestige",
		0.1
	)

	assert_equal(
		int(Level1Vars.currency.copper),
		0,
		"Pocket copper resets on prestige"
	)

	assert_equal(
		int(Level1Vars.currency.platinum),
		10,
		"Platinum persists through prestige"
	)

	assert_true(
		Level1Vars.phase_2_unlocked,
		"Phase unlocks persist through prestige"
	)
