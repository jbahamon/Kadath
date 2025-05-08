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

var volume = {
	&"SFX": 0.5,
	&"UI": 0.5,
	&"BGM": 0.5
	
}

var text_speed = 60.0
var toggle_run = false

var config_file: ConfigFile
var timer: Timer

var enable_screen_shake = true
var enable_flashing = true

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

	if err == ERR_FILE_NOT_FOUND or err == ERR_FILE_CANT_OPEN:
		return false
	
	for action in INPUT_ACTIONS:
		InputMap.action_erase_events(action)
		for event in config_file.get_value("input", action, []):
			InputMap.action_add_event(action, event)
			VarsService.on_action_updated(action, event)
	
	for bus_name in [&"BGM", &"SFX", &"UI"]:
		var linear_volume = config_file.get_value("sound", bus_name, 0.5)
		self.volume[bus_name] = linear_volume
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index(bus_name), 
			linear_to_db(linear_volume)
		)

	self.text_speed = config_file.get_value("ui", "text_speed", 60)
	return true
	
func create_config():
	self.config_file = ConfigFile.new()
	config_file.load(CONFIG_FILE_NAME)
	
	for action in INPUT_ACTIONS:
		var events = InputMap.action_get_events(action)
		config_file.set_value("input", action, events)
		for event in events:
			VarsService.on_action_updated(action, event)
	
	for bus_name in [&"BGM", &"SFX", &"UI"]:
		self.volume[bus_name] = 0.5
		config_file.set_value("sound", bus_name, 0.5)
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index(bus_name), 
			linear_to_db(0.5)
		)
		
	config_file.set_value("ui", "text_speed", self.text_speed)
	config_file.save(CONFIG_FILE_NAME)

func update_input(action: String, event: InputEventKey):
	var current_event_action = null
	for existing_action in INPUT_ACTIONS:
		if InputMap.action_has_event(existing_action, event):
			current_event_action = existing_action
			break
	
	if current_event_action != null:
		var old_event = InputMap.action_get_events(action)[0]
		InputMap.action_erase_events(current_event_action)
		InputMap.action_add_event(current_event_action, old_event)
		
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	
	for existing_action in INPUT_ACTIONS:
		var events = InputMap.action_get_events(existing_action)
		config_file.set_value("input", existing_action, events)
		for existing_event in events:
			VarsService.on_action_updated(existing_action, existing_event)
		
	self.save_file()

func reset_inputs():
	InputMap.load_from_project_settings()
	
func update_run_behavior(should_toggle_run):
	self.toggle_run = should_toggle_run
	config_file.set_value("input", "toggle_run", self.toggle_run)
	self.save_file()
	
func update_text_speed(new_text_speed):
	self.text_speed = new_text_speed
	config_file.set_value("ui", "text_speed", self.text_speed)
	self.save_file()

func update_volume(bus_name, volume_value):
	config_file.set_value("sound", bus_name, volume_value)
	config_file.save(CONFIG_FILE_NAME)
	self.volume[bus_name] = volume_value
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index(bus_name), 
		linear_to_db(volume_value)
	)
	self.save_file()

func update_enable_screen_shake(value):
	self.enable_screen_shake = value
	self.save_file()
	
func update_enable_flashing(value):
	self.enable_flashing = value
	self.save_file()
	
func save_file():
	self.timer.start(1.0)
	
func trigger_save():
	config_file.save(CONFIG_FILE_NAME)
