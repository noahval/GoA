extends Node
## LocalSaveManager
## Handles local browser-based save/load functionality for offline play
## Uses Godot's FileAccess API which stores data in IndexedDB for web builds

const SAVE_FILE_PATH = "user://local_save.json"

## Save all game state to local browser storage
func save_game() -> bool:
	var save_data = {
		"version": "1.0",
		"timestamp": Time.get_unix_time_from_system(),
		"global": _get_global_data(),
		"level1_vars": _get_level1_vars_data()
	}

	var json_string = JSON.stringify(save_data, "\t")
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)

	if file == null:
		var error = FileAccess.get_open_error()
		DebugLogger.log_error("LocalSave", "Failed to open save file for writing. Error: %d" % error)
		return false

	file.store_string(json_string)
	file.close()

	DebugLogger.log_success("LocalSave", "Game saved successfully to local storage")
	return true

## Load game state from local browser storage
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		DebugLogger.log_info("LocalSave", "No local save file found")
		return false

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)

	if file == null:
		var error = FileAccess.get_open_error()
		DebugLogger.log_error("LocalSave", "Failed to open save file for reading. Error: %d" % error)
		return false

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result != OK:
		DebugLogger.log_error("LocalSave", "Failed to parse save file JSON")
		return false

	var save_data = json.data

	# Validate save data
	if not save_data.has("global") or not save_data.has("level1_vars"):
		DebugLogger.log_error("LocalSave", "Invalid save file structure")
		return false

	# Load Global data
	_set_global_data(save_data.global)

	# Load Level1Vars data
	_set_level1_vars_data(save_data.level1_vars)

	DebugLogger.log_success("LocalSave", "Game loaded successfully from local storage")
	return true

## Check if a local save exists
func has_save() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

## Delete the local save file
func delete_save() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return true

	var dir = DirAccess.open("user://")
	if dir:
		var result = dir.remove(SAVE_FILE_PATH.get_file())
		if result == OK:
			DebugLogger.log_info("LocalSave", "Save file deleted successfully")
			return true
		else:
			DebugLogger.log_error("LocalSave", "Failed to delete save file")
			return false

	return false

## Get all Global variables to save
func _get_global_data() -> Dictionary:
	return {
		# Stats
		"strength": Global.strength,
		"constitution": Global.constitution,
		"dexterity": Global.dexterity,
		"wisdom": Global.wisdom,
		"intelligence": Global.intelligence,
		"charisma": Global.charisma,

		# Experience
		"strength_exp": Global.strength_exp,
		"constitution_exp": Global.constitution_exp,
		"dexterity_exp": Global.dexterity_exp,
		"wisdom_exp": Global.wisdom_exp,
		"intelligence_exp": Global.intelligence_exp,
		"charisma_exp": Global.charisma_exp,

		# Dev mode
		"dev_speed_mode": Global.dev_speed_mode
	}

## Get all Level1Vars variables to save
func _get_level1_vars_data() -> Dictionary:
	return {
		# Resources
		"coal": Level1Vars.coal,
		"coins": Level1Vars.coins,
		"components": Level1Vars.components,
		"mechanisms": Level1Vars.mechanisms,
		"pipes": Level1Vars.pipes,

		# Upgrades
		"shovel_lvl": Level1Vars.shovel_lvl,
		"plow_lvl": Level1Vars.plow_lvl,
		"auto_shovel_lvl": Level1Vars.auto_shovel_lvl,
		"auto_shovel_freq": Level1Vars.auto_shovel_freq,
		"auto_shovel_coal_per_tick": Level1Vars.auto_shovel_coal_per_tick,
		"auto_shovel_coal_upgrade_lvl": Level1Vars.auto_shovel_coal_upgrade_lvl,
		"auto_shovel_freq_upgrade_lvl": Level1Vars.auto_shovel_freq_upgrade_lvl,
		"overseer_lvl": Level1Vars.overseer_lvl,

		# Story/State flags
		"barkeep_bribed": Level1Vars.barkeep_bribed,
		"shopkeep_bribed": Level1Vars.shopkeep_bribed,
		"heart_taken": Level1Vars.heart_taken,
		"whisper_triggered": Level1Vars.whisper_triggered,
		"door_discovered": Level1Vars.door_discovered,

		# Progress
		"stolen_coal": Level1Vars.stolen_coal,
		"stolen_writs": Level1Vars.stolen_writs,
		"correct_answers": Level1Vars.correct_answers,
		"suspicion": Level1Vars.suspicion,

		# Timers/Buffs
		"break_time_remaining": Level1Vars.break_time_remaining,
		"starting_break_time": Level1Vars.starting_break_time,
		"coin_cost": Level1Vars.coin_cost,
		"stamina": Level1Vars.stamina,
		"talk_button_cooldown": Level1Vars.talk_button_cooldown,
		"stimulated_remaining": Level1Vars.stimulated_remaining,
		"shown_tired_notification": Level1Vars.shown_tired_notification,
		"resilient_remaining": Level1Vars.resilient_remaining,
		"shown_lazy_notification": Level1Vars.shown_lazy_notification,

		# Pipe puzzle state
		"pipe_puzzle_grid": Level1Vars.pipe_puzzle_grid
	}

## Set Global variables from save data
func _set_global_data(data: Dictionary) -> void:
	# Stats
	Global.strength = data.get("strength", 1.0)
	Global.constitution = data.get("constitution", 1.0)
	Global.dexterity = data.get("dexterity", 1.0)
	Global.wisdom = data.get("wisdom", 1.0)
	Global.intelligence = data.get("intelligence", 1.0)
	Global.charisma = data.get("charisma", 1.0)

	# Experience
	Global.strength_exp = data.get("strength_exp", 0.0)
	Global.constitution_exp = data.get("constitution_exp", 0.0)
	Global.dexterity_exp = data.get("dexterity_exp", 0.0)
	Global.wisdom_exp = data.get("wisdom_exp", 0.0)
	Global.intelligence_exp = data.get("intelligence_exp", 0.0)
	Global.charisma_exp = data.get("charisma_exp", 0.0)

	# Dev mode
	Global.dev_speed_mode = data.get("dev_speed_mode", false)

## Set Level1Vars variables from save data
func _set_level1_vars_data(data: Dictionary) -> void:
	# Resources
	Level1Vars.coal = data.get("coal", 0.0)
	Level1Vars.coins = data.get("coins", 0.0)
	Level1Vars.components = data.get("components", 0)
	Level1Vars.mechanisms = data.get("mechanisms", 0)
	Level1Vars.pipes = data.get("pipes", 5)

	# Upgrades
	Level1Vars.shovel_lvl = data.get("shovel_lvl", 0)
	Level1Vars.plow_lvl = data.get("plow_lvl", 0)
	Level1Vars.auto_shovel_lvl = data.get("auto_shovel_lvl", 1)
	Level1Vars.auto_shovel_freq = data.get("auto_shovel_freq", 3.0)
	Level1Vars.auto_shovel_coal_per_tick = data.get("auto_shovel_coal_per_tick", 4.0)
	Level1Vars.auto_shovel_coal_upgrade_lvl = data.get("auto_shovel_coal_upgrade_lvl", 0)
	Level1Vars.auto_shovel_freq_upgrade_lvl = data.get("auto_shovel_freq_upgrade_lvl", 0)
	Level1Vars.overseer_lvl = data.get("overseer_lvl", 0)

	# Story/State flags
	Level1Vars.barkeep_bribed = data.get("barkeep_bribed", false)
	Level1Vars.shopkeep_bribed = data.get("shopkeep_bribed", false)
	Level1Vars.heart_taken = data.get("heart_taken", true)
	Level1Vars.whisper_triggered = data.get("whisper_triggered", false)
	Level1Vars.door_discovered = data.get("door_discovered", false)

	# Progress
	Level1Vars.stolen_coal = data.get("stolen_coal", 0)
	Level1Vars.stolen_writs = data.get("stolen_writs", 0)
	Level1Vars.correct_answers = data.get("correct_answers", 0)
	Level1Vars.suspicion = data.get("suspicion", 0)

	# Timers/Buffs
	Level1Vars.break_time_remaining = data.get("break_time_remaining", 0.0)
	Level1Vars.starting_break_time = data.get("starting_break_time", 23)
	Level1Vars.coin_cost = data.get("coin_cost", 30.0)
	Level1Vars.stamina = data.get("stamina", 125.0)
	Level1Vars.talk_button_cooldown = data.get("talk_button_cooldown", 0.0)
	Level1Vars.stimulated_remaining = data.get("stimulated_remaining", 0.0)
	Level1Vars.shown_tired_notification = data.get("shown_tired_notification", false)
	Level1Vars.resilient_remaining = data.get("resilient_remaining", 0.0)
	Level1Vars.shown_lazy_notification = data.get("shown_lazy_notification", false)

	# Pipe puzzle state
	Level1Vars.pipe_puzzle_grid = data.get("pipe_puzzle_grid", [])
