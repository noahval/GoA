extends Node
var coal = 0.0
var coins = 0.0
var shovel_lvl = 0
var plow_lvl = 0
var auto_shovel_lvl = 0
var overseer_lvl = 0
var barkeep_bribed = false
var break_time_remaining = 0.0
var starting_break_time = 20
var coin_cost = 25.0
var components = 0
var mechanisms = 0
var pipes = 5
var stamina = 125.0
var max_stamina:
	get:
		return 125.0 + (4 * Global.constitution)
var pipe_puzzle_grid = []  # Saved grid state for the pipe puzzle
var heart_taken = false
var stolen_coal = 3
var stolen_writs = 3
var correct_answers = 0
var suspicion = 0:
	set(value):
		suspicion = clamp(value, 0, 100)
var talk_button_cooldown = 0.0
