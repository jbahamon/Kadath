extends Node

enum Flags {
	MENU_TUTORIAL_COMPLETED,
	BATTLE_TUTORIAL_COMPLETED,
	SAVE_TUTORIAL_COMPLETED,	
	EQUIPMENT_TUTORIAL_COMPLETED,
	TUTORIAL_STARTED,
	TUTORIAL_FINISHED
}

var player_scene = preload("res://Characters/Arden/Arden.tscn")

var player: Player
var inventory: Inventory
var location_name = "CavernOfFlame"	
var strings: Dictionary = {}
var current_flags: Dictionary = {}

func load_save_data(save_data: SaveData):
	if player != null:
		player.queue_free()
		
	player = player_scene.instance()
	player.position = save_data.player_position
	location_name = save_data.location_name

	inventory = Inventory.new()
	inventory.load_save_data(save_data)

	current_flags = {}
	
	for key in save_data.current_flags:
		current_flags[key] = save_data.current_flags[key]
		
	strings = {}
	
	for action in UserSettings.UI_ACTIONS:
		var events = InputMap.get_action_list(action)
		for event in events:
			PlayerVars.on_action_updated(action, event)
	

func on_action_updated(action: String, event: InputEvent):
	if event is InputEventKey:
		strings[action] = OS.get_scancode_string(
			event.get_scancode_with_modifiers()
		)

func set_flag(flag_name: int, value: bool):
	current_flags[flag_name] = value

func get_flag(flag_name: int):
	return current_flags.get(flag_name, false)
