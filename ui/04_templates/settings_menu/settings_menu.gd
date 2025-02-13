extends ScrollContainer

signal exit

# Order is important here
const labels = {
	&"ui_up": "Up",
	&"ui_accept": "Accept/Interact",
	&"ui_down": "Down",
	&"ui_cancel": "Cancel",
	&"ui_left": "Left",
	&"ui_menu": "Open Menu",
	&"ui_right": "Right",
	&"action_run": "Run"
}

var buttons: Dictionary
var focus_in_tree = false

@onready var music_volume: Slider = $CenterContainer/Settings/VolumeSliders/MusicVolumeSlider
@onready var sfx_volume: Slider = $CenterContainer/Settings/VolumeSliders/SFXVolumeSlider
@onready var ui_volume: Slider = $CenterContainer/Settings/VolumeSliders/UIVolumeSlider

@onready var grid: GridContainer = $CenterContainer/Settings/InputVBox/InputControls
@onready var block_mouse_popup: Popup = $Popups/BlockClicksPopup
@onready var input_popup: Popup = $Popups/ListenForInputPopup
@onready var text_speed: Slider = $CenterContainer/Settings/UISliders/TextSpeedSlider

@onready var enable_shake_checkbox: CheckBox = $CenterContainer/Settings/EnableShake
@onready var enable_flash_checkbox: CheckBox = $CenterContainer/Settings/EnableFlash

@onready var hold_run_checkbox: CheckBox = $CenterContainer/Settings/RunBehaviorContainer/Hold
@onready var toggle_run_checkbox: CheckBox = $CenterContainer/Settings/RunBehaviorContainer/Toggle

@onready var sample_player: AudioStreamPlayer = $AudioStreamPlayer
@export var sfx_sample: AudioStream
@export var ui_sample: AudioStream

func _init():
	self.set_process_unhandled_input(false)

func _ready():
	input_popup.popup_window = false
	
	self.music_volume.set_value_no_signal(SettingsService.volume[&"BGM"])
	self.sfx_volume.set_value_no_signal(SettingsService.volume[&"SFX"])
	self.ui_volume.set_value_no_signal(SettingsService.volume[&"UI"])
	
	self.music_volume.focus_entered.connect(UIService.on_button_focused)
	self.sfx_volume.focus_entered.connect(UIService.on_button_focused)
	self.ui_volume.focus_entered.connect(UIService.on_button_focused)
	
	buttons = {}
	for action in labels.keys():
		var label_text = labels[action]
		add_input_option(action, label_text)
		link_buttons()
	
	self.enable_shake_checkbox.set_pressed_no_signal(SettingsService.enable_screen_shake)
	self.enable_flash_checkbox.set_pressed_no_signal(SettingsService.enable_flashing)
	
	var group = ButtonGroup.new()
	self.hold_run_checkbox.button_group = group
	self.toggle_run_checkbox.button_group = group
	
	self.toggle_run_checkbox.set_pressed_no_signal(SettingsService.toggle_run)
	self.hold_run_checkbox.set_pressed_no_signal(not SettingsService.toggle_run)
	
	self.text_speed.set_value_no_signal(SettingsService.text_speed)
	
	# FIXME is this needed for the main menu
	# self.on_grab_focus()
	

func add_input_option(action: String, label_text: String):
	add_label(label_text)
	add_button(action)

func add_label(label_text: String):
	var label = Label.new()
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	grid.add_child(label)
	
func add_button(action: String):
	var button = Button.new()
	var actions = InputMap.action_get_events(action)
	if actions.is_empty():
		button.text = "---"
	else:
		var keycode = InputMap.action_get_events(action)[0].keycode
		button.text = "<%s>" % OS.get_keycode_string(keycode)
	
	button.pressed.connect(self._button_pressed.bind(action))
	grid.add_child(button)
	
	buttons[action] = button

# Seems that using the grid confuses the automatic focus behavior.
# So we explicitly set the neighbors
func link_buttons():
	var keys = buttons.keys()
	for i in range(len(keys)):
		var button: Button = buttons[keys[i]]
		if i % 2 != 0:
			button.focus_neighbor_left = button.get_path_to(buttons[keys[i - 1]])
		else:
			button.focus_neighbor_left = button.get_path_to(button)
		
		if i > 1:
			button.focus_neighbor_top = button.get_path_to(buttons[keys[i - 2]])
		else:
			button.focus_neighbor_top = button.get_path_to(text_speed)
			
		if (i + 1) < len(keys):
			if i % 2 == 0:
				button.focus_neighbor_right = button.get_path_to(buttons[keys[i + 1]])
			else:
				button.focus_neighbor_right = button.get_path_to(button)
		
		if (i + 2) < len(keys):
			button.focus_neighbor_bottom = button.get_path_to(buttons[keys[i + 2]])
		else:
			button.focus_neighbor_bottom = button.get_path_to(hold_run_checkbox)
			
			if i % 2 == 0:
				hold_run_checkbox.focus_neighbor_top = hold_run_checkbox.get_path_to(button)
				toggle_run_checkbox.focus_neighbor_top = toggle_run_checkbox.get_path_to(button)
	
	
func _button_pressed(action: String):
	buttons[action].release_focus()
	input_popup.update_action(action, labels[action])
	
	for button_action in buttons:
		buttons[button_action].mouse_filter = Control.MOUSE_FILTER_IGNORE
	input_popup.popup_centered()

func _on_ListenForInputPopup_key_pressed(action: String, event: InputEventKey):
	
	var events = InputMap.action_get_events(action)
	
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	
	SettingsService.update_inputs()
	
	for old_event in events:
		if not old_event is InputEventKey: 
			InputMap.action_add_event(action, event)
	
	for button_action in buttons:
		buttons[button_action].mouse_filter = Control.MOUSE_FILTER_STOP
	buttons[action].grab_focus()
	buttons[action].grab_click_focus()
	buttons[action].text = "<%s>" % OS.get_keycode_string(event.keycode)

func _unhandled_input(event):
	if event.is_action_pressed(&"ui_cancel") and self.get_parent().visible:
		self.exit.emit()
		self.get_viewport().set_input_as_handled()
		self.set_process_unhandled_input(false)
		
		
func on_grab_focus():
	var first_element = $CenterContainer/Settings/VolumeSliders/MusicVolumeSlider

	first_element.grab_focus()
	first_element.grab_click_focus()
	self.set_process_unhandled_input(true)

func update_sfx_volume(value):
	SettingsService.update_volume(&"SFX", self.sfx_volume.value)

func update_music_volume(value):
	SettingsService.update_volume(&"BGM", self.music_volume.value)

func update_ui_volume(value):
	SettingsService.update_volume(&"UI", self.ui_volume.value)
	
func update_run_behavior(value):
	SettingsService.update_run_behavior(value)

func update_enable_shake(toggled_on: bool) -> void:
	SettingsService.update_enable_screen_shake(toggled_on)

func update_enable_flash(toggled_on: bool) -> void:
	SettingsService.update_enable_flashing(toggled_on)

func _on_sfx_volume_slider_focus_entered() -> void:
	self.sample_player.stream = self.sfx_sample
	self.sample_player.set_bus(&"SFX")
	self.sample_player.play()

func _on_ui_volume_slider_focus_entered() -> void:
	self.sample_player.stream = self.ui_sample
	self.sample_player.set_bus(&"UI")
	self.sample_player.play()

func _on_volume_slider_focus_exited() -> void:
	self.sample_player.stop()
