extends Node
## atm_debug.gd
## Diagnostic script for debugging ATM currency exchange issues
## Attach this to a test scene or call its functions from console

static func print_currency_state():
	print("\n=== CURRENCY STATE DEBUG ===")
	print("\nCurrent Holdings:")
	print("  Copper: ", Level1Vars.currency.copper)
	print("  Silver: ", Level1Vars.currency.silver)
	print("  Gold: ", Level1Vars.currency.gold)
	print("  Platinum: ", Level1Vars.currency.platinum)

	print("\nLifetime Earnings:")
	print("  Copper: ", Level1Vars.lifetime_currency.copper)
	print("  Silver: ", Level1Vars.lifetime_currency.silver)
	print("  Gold: ", Level1Vars.lifetime_currency.gold)
	print("  Platinum: ", Level1Vars.lifetime_currency.platinum)

	print("\nLevel1Vars Unlocks:")
	print("  Gold unlocked: ", Level1Vars.unlocked_gold, " (_unlocked_gold: ", Level1Vars._unlocked_gold, ")")
	print("  Platinum unlocked: ", Level1Vars.unlocked_platinum, " (_unlocked_platinum: ", Level1Vars._unlocked_platinum, ")")

	print("\nCurrencyManager Unlocks:")
	print("  Copper: ", CurrencyManager.unlocked_currencies[CurrencyManager.CurrencyType.COPPER])
	print("  Silver: ", CurrencyManager.unlocked_currencies[CurrencyManager.CurrencyType.SILVER])
	print("  Gold: ", CurrencyManager.unlocked_currencies[CurrencyManager.CurrencyType.GOLD])
	print("  Platinum: ", CurrencyManager.unlocked_currencies[CurrencyManager.CurrencyType.PLATINUM])

	print("\nUnlock Thresholds:")
	print("  Silver: 500 copper lifetime")
	print("  Gold: 50,000 copper lifetime")
	print("  Platinum: 2,500,000 copper lifetime")
	print("  ATM Gold: 60 silver current")
	print("  ATM Platinum: 60 gold current")

	print("\nMarket Rates (modifiers):")
	print("  Copper: ", CurrencyManager.conversion_rate_modifiers[CurrencyManager.CurrencyType.COPPER])
	print("  Silver: ", CurrencyManager.conversion_rate_modifiers[CurrencyManager.CurrencyType.SILVER])
	print("  Gold: ", CurrencyManager.conversion_rate_modifiers[CurrencyManager.CurrencyType.GOLD])
	print("  Platinum: ", CurrencyManager.conversion_rate_modifiers[CurrencyManager.CurrencyType.PLATINUM])
	print("=========================\n")


static func test_exchange(from_currency_name: String, to_currency_name: String, amount: float):
	print("\n=== TESTING EXCHANGE ===")
	print("From: ", from_currency_name, " (", amount, ")")
	print("To: ", to_currency_name)

	var from_type = _get_currency_type(from_currency_name)
	var to_type = _get_currency_type(to_currency_name)

	if from_type == -1 or to_type == -1:
		print("[ERROR] Invalid currency name")
		return

	print("\nBefore exchange:")
	print_currency_state()

	var result = CurrencyManager.exchange_currency_with_fee(from_type, to_type, amount)

	print("\nExchange result:")
	print("  Success: ", result.success)
	if result.success:
		print("  Fee: ", result.fee)
		print("  Received: ", result.received)
	else:
		print("  Error: ", result.get("error", "unknown"))

	print("\nAfter exchange:")
	print_currency_state()


static func _get_currency_type(name: String) -> int:
	match name.to_lower():
		"copper":
			return CurrencyManager.CurrencyType.COPPER
		"silver":
			return CurrencyManager.CurrencyType.SILVER
		"gold":
			return CurrencyManager.CurrencyType.GOLD
		"platinum":
			return CurrencyManager.CurrencyType.PLATINUM
		_:
			return -1


static func give_test_currency():
	print("\n=== GIVING TEST CURRENCY ===")
	CurrencyManager.add_currency(CurrencyManager.CurrencyType.COPPER, 10000.0, "debug")
	CurrencyManager.add_currency(CurrencyManager.CurrencyType.SILVER, 200.0, "debug")
	CurrencyManager.add_currency(CurrencyManager.CurrencyType.GOLD, 100.0, "debug")
	print("Added: 10,000 copper, 200 silver, 100 gold")
	print_currency_state()


static func sync_unlocks():
	print("\n=== SYNCING UNLOCK SYSTEMS ===")
	print("Before sync:")
	print("  Level1Vars gold: ", Level1Vars.unlocked_gold)
	print("  CurrencyManager gold: ", CurrencyManager.unlocked_currencies[CurrencyManager.CurrencyType.GOLD])

	CurrencyManager._sync_unlock_systems()

	print("\nAfter sync:")
	print("  Level1Vars gold: ", Level1Vars.unlocked_gold)
	print("  CurrencyManager gold: ", CurrencyManager.unlocked_currencies[CurrencyManager.CurrencyType.GOLD])
