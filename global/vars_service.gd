extends Node

const VERSION = "0.1.0"
const CREDITS_FILE = "res://CREDITS.json"
const VERTICAL_ORIENTATION_BIAS = 1.1

var starting_location_name = "000_prologue_kadath"
var starting_room_name = "01_entrance"

var strings: Dictionary = {}
var current_flags: Dictionary = {}

var scan_level: int = 1
var scanned_enemies: Dictionary = {}

var alignment = 0

func _init():
	self.add_to_group("save")

func load_game_data(save_data: SaveData) -> void:
	current_flags = save_data.data["flags"]
	strings = strings.merged(save_data.data["strings"], true)
	scan_level = save_data.data["scan_level"]
	scanned_enemies = save_data.data["scanned_enemies"]
	alignment = save_data.data["alignment"]

func save_game_data(save_data: SaveData) -> void:
	save_data.data["flags"] = current_flags
	
	var filtered_strings = {}
	
	for k in strings.keys():
		if k not in SettingsService.INPUT_ACTIONS:
			filtered_strings[k] = strings[k]
	
	save_data.data["strings"] = filtered_strings
	save_data.data["scan_level"] = scan_level
	save_data.data["scanned_enemies"] = scanned_enemies
	save_data.data["alignment"] = alignment

		
func on_action_updated(action: String, event: InputEvent) -> void:
	if event is InputEventKey:
		var keycode = event.get_keycode_with_modifiers()
		strings[action] = OS.get_keycode_string(keycode)

func set_string(string_name: String, value: String) -> void:
	strings[string_name] = value

func set_flag(flag_name: String, value: bool) -> void:
	current_flags[flag_name] = value

func get_flag(flag_name: String) -> bool:
	return current_flags.get(flag_name, false)

func round_orientation_with_bias(orientation: Vector2):
	if abs(orientation.x) > abs(orientation.y * VarsService.VERTICAL_ORIENTATION_BIAS):
		return Vector2.RIGHT if orientation.x > 0 else Vector2.LEFT
		
	else:
		return Vector2.DOWN if orientation.y > 0 else Vector2.UP
	
func scan_enemy(enemy_id: String):
	self.scanned_enemies[enemy_id] = true
