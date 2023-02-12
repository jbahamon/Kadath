extends Node

var loaded_slot = -1
var starting_location_name = "000_prologue_kadath"
var starting_room_name = "left"
var strings: Dictionary = {}
var current_flags: Dictionary = {}

func _init():
	self.add_to_group("save")

func load(save_data: SaveData) -> void:
	current_flags = save_data.data["flags"]
	strings = save_data.data["strings"]

func save(save_data: SaveData) -> void:
	save_data.data["flags"] = current_flags
	save_data.data["strings"] = strings
	
func on_action_updated(action: String, event: InputEvent) -> void:
	if event is InputEventKey:
		strings[action] = OS.get_scancode_string(
			event.get_scancode_with_modifiers()
		)

func set_string(string_name: String, value: String) -> void:
	strings[string_name] = value

func set_flag(flag_name: String, value: bool) -> void:
	current_flags[flag_name] = value

func get_flag(flag_name: String) -> bool:
	return current_flags.get(flag_name, false)
