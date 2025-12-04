extends Node

# Autonomous test for stat progression system

func _ready():
	DebugLogger.info("=== Starting Stat Test ===", "TEST")

	# Test each stat with experience
	DebugLogger.info("Testing strength progression...", "TEST")
	Global.add_stat_exp("strength", 150)  # Should level up to 2
	assert(Global.strength >= 2, "Strength should be level 2+")

	DebugLogger.info("Testing constitution progression...", "TEST")
	Global.add_stat_exp("constitution", 200)  # Should level up
	assert(Global.constitution >= 2, "Constitution should be level 2+")

	DebugLogger.info("Testing dexterity progression...", "TEST")
	Global.add_stat_exp("dexterity", 100)  # Should level up to 2
	assert(Global.dexterity >= 2, "Dexterity should be level 2+")

	DebugLogger.info("Testing wisdom progression...", "TEST")
	Global.add_stat_exp("wisdom", 250)  # Should level up past 2
	assert(Global.wisdom >= 2, "Wisdom should be level 2+")

	DebugLogger.info("Testing intelligence progression...", "TEST")
	Global.add_stat_exp("intelligence", 180)  # Should level up to 2
	assert(Global.intelligence >= 2, "Intelligence should be level 2+")

	DebugLogger.info("Testing charisma progression...", "TEST")
	Global.add_stat_exp("charisma", 300)  # Should level up multiple times
	assert(Global.charisma >= 2, "Charisma should be level 2+")

	DebugLogger.info("=== Stat Test Complete - All Tests Passed ===", "TEST")

	# Wait 2 seconds before quitting to ensure logs are flushed
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()
