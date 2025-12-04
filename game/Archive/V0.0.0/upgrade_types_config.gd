extends Node

# All equipment upgrades across ALL scenes
# Equipment upgrades are purchases that increase the player's production/efficiency capabilities
const EQUIPMENT_UPGRADES = [
	# Shop scene (Crankshaft's) - coin-based
	"shovel",
	"plow",
	"auto_shovel",
	"coal_per_tick",
	"frequency",
	"storage_capacity",  # Currency storage upgrade (affects all currencies)
	"coal_tracking",     # Coal record-keeping upgrade

	# Workshop scene - component-based (future)
	# Example: "forge_hammer", "anvil", etc.

	# Overseer's Office scene - coin-based
	"overtime",  # Offline earnings cap upgrade
]

# Check if an upgrade is classified as equipment
func is_equipment(upgrade_name: String) -> bool:
	return upgrade_name in EQUIPMENT_UPGRADES

# Track equipment purchase using coin-equivalent value
# This function updates the total equipment value in Level1Vars
#
# Parameters:
#   upgrade_name: The name of the upgrade (must be in EQUIPMENT_UPGRADES)
#   coin_equivalent_value: The value in coin-equivalent units
#
# Usage examples:
#   - For coin purchases: pass cost directly (1:1 conversion)
#     UpgradeTypesConfig.track_equipment_purchase("shovel", 8)
#
#   - For component purchases: convert to coin-equivalent first
#     var coin_equiv = component_cost * 5  # 5 coins per component
#     UpgradeTypesConfig.track_equipment_purchase("forge_hammer", coin_equiv)
#
#   - For other currencies: apply your conversion rate
#     var coin_equiv = writ_cost * 50  # 50 coins per writ
#     UpgradeTypesConfig.track_equipment_purchase("office_upgrade", coin_equiv)
func track_equipment_purchase(upgrade_name: String, coin_equivalent_value: int):
	if is_equipment(upgrade_name):
		Level1Vars.equipment_value += coin_equivalent_value
