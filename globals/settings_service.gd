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
	update_config()

func load_config():
	var config_file = ConfigFile.new()
	config_file.load(CONFIG_FILE_NAME)
	
	for action in UI_ACTIONS:
		InputMap.action_erase_events(action)
		for event in config_file.get_value("input", action, []):
			InputMap.action_add_event(action, event)
			VarsService.on_action_updated(action, event)
			
	text_speed = config_file.get_value("ui", "text_speed", 2)
	
func update_config():
	var config_file = ConfigFile.new()
	config_file.load(CONFIG_FILE_NAME)
	
	for action in UI_ACTIONS:
		var events = InputMap.action_get_events(action)
		config_file.set_value("input", action, events)
		for event in events:
			VarsService.on_action_updated(action, event)
		
	config_file.set_value("ui", "text_speed", text_speed)
	config_file.save(CONFIG_FILE_NAME)
