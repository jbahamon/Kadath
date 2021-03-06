extends Node

const CONFIG_FILE_NAME = "user://settings.cfg"

const UI_ACTIONS = [
	"ui_down",
	"ui_left",
	"ui_right",
	"ui_accept",
	"ui_cancel",
	"ui_menu",
	"run"
]

var text_speed = 1 

func _init():
	var file = File.new()
	if file.file_exists(CONFIG_FILE_NAME):
		load_config()
	else:
		update_config()

func load_config():
	var config_file = ConfigFile.new()
	config_file.load(CONFIG_FILE_NAME)
	for action in UI_ACTIONS:
		InputMap.action_erase_events(action)
		for event in config_file.get_value("input", action, []):
			InputMap.action_add_event(action, event)
	
	text_speed = config_file.get_value("ui", "text_speed", 2)
	
func update_config():
	
	var config_file = ConfigFile.new()
	config_file.load(CONFIG_FILE_NAME)
	
	for action in UI_ACTIONS:
		var events = InputMap.get_action_list(action)
		config_file.set_value("input", action, events)
		
	config_file.set_value("ui", "text_speed", text_speed)
	config_file.save(CONFIG_FILE_NAME)
