extends Node

const CONFIG_FILE_NAME = "user://settings.cfg"

const INPUT_ACTIONS = [
	&"ui_up",
	&"ui_down",
	&"ui_left",
	&"ui_right",
	&"ui_accept",
	&"ui_cancel",
	&"ui_menu",
	&"action_run"
]	

var music_volume: float = 0.5
var sfx_volume: float = 0.5
var ui_volume: float = 0.5

var text_speed = 2
var toggle_run = false

var config_file: ConfigFile
var timer: Timer

func _init():
	if not load_config():
		create_config()

func _ready() -> void:
	self.timer = Timer.new()
	self.timer.timeout.connect(self.trigger_save)
	self.add_child(self.timer)

func load_config() -> bool:
	self.config_file = ConfigFile.new()
	var err = config_file.load(CONFIG_FILE_NAME)
	if err == ERR_FILE_CANT_OPEN:
		return false
	
	for action in INPUT_ACTIONS:
		InputMap.action_erase_events(action)
		for event in config_file.get_value("input", action, []):
			InputMap.action_add_event(action, event)
			VarsService.on_action_updated(action, event)
	
	for volume_setting in ["ui_volume", "music_volume", "sfx_volume"]:
		# TODO actually use these
		config_file.get_value("sound", volume_setting, 5)
		
	text_speed = config_file.get_value("ui", "text_speed", 2)
	return true
	
func create_config():
	self.config_file = ConfigFile.new()
	config_file.load(CONFIG_FILE_NAME)
	
	for action in INPUT_ACTIONS:
		var events = InputMap.action_get_events(action)
		config_file.set_value("input", action, events)
		for event in events:
			VarsService.on_action_updated(action, event)
	
	for volume_setting in ["ui_volume", "music_volume", "sfx_volume"]:
		# TODO actually use these
		config_file.set_value("sound", volume_setting, 5)
		
	config_file.set_value("ui", "text_speed", text_speed)
	config_file.save(CONFIG_FILE_NAME)

func update_inputs():
	for action in INPUT_ACTIONS:
		var events = InputMap.action_get_events(action)
		config_file.set_value("input", action, events)
		for event in events:
			VarsService.on_action_updated(action, event)
			
	self.save_file()

func update_run_behavior(should_toggle_run):
	self.toggle_run = should_toggle_run
	config_file.set_value("input", "toggle_run", self.toggle_run)
	self.save_file()
	
func update_text_speed(new_text_speed):
	self.text_speed = new_text_speed
	config_file.set_value("ui", "text_speed", self.text_speed)
	DialogueService.set_text_speed(new_text_speed)
	self.save_file()

func update_volume(volume_setting, volume_value):
	config_file.set_value("sound", volume_setting, volume_value)
	config_file.save(CONFIG_FILE_NAME)
	self.save_file()
	
func save_file():
	self.timer.start(1.0)
	
func trigger_save():
	config_file.save(CONFIG_FILE_NAME)
