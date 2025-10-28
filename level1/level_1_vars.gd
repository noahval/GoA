extends Node
var coal = 0.0
var coins = 0.0
var shovel_lvl = 0
var plow_lvl = 0
var auto_shovel_lvl = 1
var auto_shovel_freq = 3.0  # How often auto shovel generates coal (in seconds)
var overseer_lvl = 0
var barkeep_bribed = false
var shopkeep_bribed = false
var break_time_remaining = 0.0
var starting_break_time = 23
var coin_cost = 30.0
var components = 0
var mechanisms = 0
var pipes = 5
var stamina = 125.0
var max_stamina:
	get:
		return 125.0 + (20 * Global.constitution)
var pipe_puzzle_grid = []  # Saved grid state for the pipe puzzle
var heart_taken = true
var whisper_triggered = false
var door_discovered = false
var stolen_coal = 0
var stolen_writs = 0
var correct_answers = 0
var suspicion = 0:
	set(value):
		suspicion = clamp(value, 0, 100)
var talk_button_cooldown = 0.0
var stimulated_remaining = 0.0:
	set(value):
		stimulated_remaining = clamp(value, 0, 300)
var shown_tired_notification = false
var resilient_remaining = 0.0:
	set(value):
		resilient_remaining = clamp(value, 0, 300)
var shown_lazy_notification = false
