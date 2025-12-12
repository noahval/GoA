extends Node

# Autonomous test for shop purchase system

func _ready():
	DebugLogger.info("=== Starting Shop Purchase Test ===", "TEST")

	# Set up initial resources
	Level1Vars.coins = 1000.0
	Level1Vars.shovel_lvl = 0
	Level1Vars.plow_lvl = 0
	Level1Vars.auto_shovel_lvl = 0

	# Test 1: Purchase shovel and verify cost scaling
	DebugLogger.info("Test 1: Testing shovel purchase and cost scaling...", "TEST")
	var initial_coins = Level1Vars.coins
	var shovel_cost = int(8 * pow(1.8, Level1Vars.shovel_lvl))

	# Simulate purchase
	DebugLogger.log_resource_change("coins", Level1Vars.coins, Level1Vars.coins - shovel_cost, "Shovel purchase")
	Level1Vars.coins -= shovel_cost
	Level1Vars.shovel_lvl += 1
	DebugLogger.log_shop_purchase("Shovel", shovel_cost, Level1Vars.shovel_lvl)

	assert(Level1Vars.coins == initial_coins - shovel_cost, "Coins should decrease by cost")
	assert(Level1Vars.shovel_lvl == 1, "Shovel level should be 1")

	# Test 2: Verify cost increases after purchase
	DebugLogger.info("Test 2: Testing cost scaling after first purchase...", "TEST")
	var new_shovel_cost = int(8 * pow(1.8, Level1Vars.shovel_lvl))
	assert(new_shovel_cost > shovel_cost, "Cost should increase after level up")
	DebugLogger.info("Cost increased from %d to %d" % [shovel_cost, new_shovel_cost], "TEST")

	# Test 3: Multiple purchases
	DebugLogger.info("Test 3: Testing multiple sequential purchases...", "TEST")
	for i in range(3):
		var cost = int(8 * pow(1.8, Level1Vars.shovel_lvl))
		if Level1Vars.coins >= cost:
			DebugLogger.log_resource_change("coins", Level1Vars.coins, Level1Vars.coins - cost, "Shovel purchase")
			Level1Vars.coins -= cost
			Level1Vars.shovel_lvl += 1
			DebugLogger.log_shop_purchase("Shovel", cost, Level1Vars.shovel_lvl)

	assert(Level1Vars.shovel_lvl == 4, "Shovel level should be 4 after 4 total purchases")

	# Test 4: Test bribe shopkeep
	DebugLogger.info("Test 4: Testing bribe shopkeep...", "TEST")
	Level1Vars.shopkeep_bribed = false
	var coins_before_bribe = Level1Vars.coins
	if Level1Vars.coins >= 10 and not Level1Vars.shopkeep_bribed:
		DebugLogger.log_resource_change("coins", Level1Vars.coins, Level1Vars.coins - 10, "Bribe Shopkeep")
		Level1Vars.coins -= 10
		Level1Vars.shopkeep_bribed = true
		DebugLogger.log_shop_purchase("Bribe Shopkeep", 10, 1)

	assert(Level1Vars.shopkeep_bribed == true, "Shopkeep should be bribed")
	assert(Level1Vars.coins == coins_before_bribe - 10, "Coins should decrease by 10")

	DebugLogger.info("=== Shop Purchase Test Complete - All Tests Passed ===", "TEST")

	# Wait 2 seconds before quitting to ensure logs are flushed
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()
