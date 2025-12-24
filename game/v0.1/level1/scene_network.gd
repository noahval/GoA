extends Node

# Complete navigation map for Level 1
# Built from 2.1-scene-network.mmd
const SCENE_NETWORK = {
	"furnace": {
		"path": "res://level1/furnace.tscn",
		"name": "Furnace",
		"connections": ["mind"],  # From arrows in .mmd
	},

	"mind": {
		"path": "res://level1/mind.tscn",
		"name": "Mind",
		"connections": ["furnace"],
	},

	"dorm": {
		"path": "res://level1/dorm.tscn",
		"name": "Dormitory",
		"connections": ["bar", "coppersmith", "mess"],
	},

	"bar": {
		"path": "res://level1/bar.tscn",
		"name": "Bar",
		"connections": ["dorm"],
	},

	"coppersmith": {
		"path": "res://level1/coppersmith.tscn",
		"name": "Coppersmith Carriage",
		"connections": ["dorm", "crankshafts", "office", "frayed_end"],
	},

	"crankshafts": {
		"path": "res://level1/crankshafts.tscn",
		"name": "Crankshaft's",
		"connections": ["coppersmith"],
	},

	"mess": {
		"path": "res://level1/mess.tscn",
		"name": "Mess Hall",
		"connections": ["dorm"],
	},

	"secret": {
		"path": "res://level1/secret.tscn",
		"name": "Secret Passage",
		"connections": ["carriage", "puzzle"],
	},

	"atm": {
		"path": "res://level1/atm.tscn",
		"name": "ATM",
		"connections": ["carriage"],
	},

	"office": {
		"path": "res://level1/office.tscn",
		"name": "Overseer Office",
		"connections": ["carriage"],
	},

	"shop": {
		"path": "res://level1/shop.tscn",
		"name": "Shop",
		"connections": ["carriage"],
	},

	"puzzle": {
		"path": "res://level1/puzzle.tscn",
		"name": "Secret Puzzle",
		"connections": ["secret"],
	},
}

func _ready():
	# Autoload: Register scene network validator
	if Global and Global.has_method("register_scene_validator"):
		Global.register_scene_validator(_validate_scene_network)

# Check if player can navigate to a scene
func can_navigate_to(scene_id: String) -> bool:
	# Scene not in network? Block it
	if not scene_id in SCENE_NETWORK:
		return false

	# Check if connected from current scene
	var current_id = _path_to_id(Global.get_current_scene_path())

	# If no current scene (initial load), allow any scene in network
	if current_id.is_empty():
		return true

	# Current scene not in network? Block transition
	if not current_id in SCENE_NETWORK:
		return false

	var current_scene = SCENE_NETWORK[current_id]
	var connections = current_scene.get("connections", [])

	# Must be in connections list
	return scene_id in connections

# Convert scene path to ID
func _path_to_id(path: String) -> String:
	for scene_id in SCENE_NETWORK:
		if SCENE_NETWORK[scene_id].path == path:
			return scene_id
	return ""

# Convert scene ID to path
func get_scene_path(scene_id: String) -> String:
	if scene_id in SCENE_NETWORK:
		return SCENE_NETWORK[scene_id].path
	return ""

# Get scenes connected from current scene
func get_available_destinations() -> Array:
	var current_id = _path_to_id(Global.get_current_scene_path())
	if current_id.is_empty() or not current_id in SCENE_NETWORK:
		return []

	var current_scene = SCENE_NETWORK[current_id]
	return current_scene.get("connections", [])

# System scenes that bypass network validation (UI/utility scenes)
const SYSTEM_SCENES = [
	"res://settings.tscn",
	"res://scenes/main_menu.tscn",
]

# Validator function
func _validate_scene_network(scene_path: String) -> bool:
	# Allow system scenes (settings, main menu, etc.)
	if scene_path in SYSTEM_SCENES:
		return true

	var scene_id = _path_to_id(scene_path)

	# Not in network? Block it
	if scene_id.is_empty():
		push_warning("Attempted to load scene not in network: " + scene_path)
		return false

	# Check if can navigate
	if not can_navigate_to(scene_id):
		var scene = SCENE_NETWORK[scene_id]
		var scene_name = scene.get("name", scene_id)
		if Global and Global.has_method("show_notification"):
			Global.show_notification("You can't reach " + scene_name + " from here")
		return false

	return true
