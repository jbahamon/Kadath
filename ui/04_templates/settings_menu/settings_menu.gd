extends ScrollContainer

signal exit

# Order is important here
const labels = {
	"ui_up": "Up",
	"ui_accept": "Accept/Interact",
	"ui_down": "Down",
	"ui_cancel": "Cancel",
	"ui_left": "Left",
	"ui_menu": "Open Menu",
	"ui_right": "Right",
	"action_run": "Walk/run (hold)"
}

var buttons: Dictionary
var focus_in_tree = false

@onready var grid: GridContainer = $CenterContainer/Settings/InputVBox/InputControls
@onready var input_popup: Popup = $Popups/ListenForInputPopup
@onready var text_speed_slider = $CenterContainer/Settings/Sliders/TextSpeedSlider

func _init():
	self.set_process_unhandled_input(false)

func _ready():
	input_popup.popup_window = false
	buttons = {}
	for action in labels.keys():
		var label_text = labels[action]
		add_input_option(action, label_text)
		link_buttons()
	
	self.on_grab_focus()
	

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
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
			button.focus_neighbor_top = button.get_path_to(text_speed_slider)
			
		if (i + 1) < len(keys):
			if i % 2 == 0:
				button.focus_neighbor_right = button.get_path_to(buttons[keys[i + 1]])
			else:
				button.focus_neighbor_right = button.get_path_to(button)
		
		if (i + 2) < len(keys):
			button.focus_neighbor_bottom = button.get_path_to(buttons[keys[i + 2]])
		else:
			button.focus_neighbor_bottom = button.get_path_to(button)
	
	
func _button_pressed(action: String):
	buttons[action].release_focus()
	input_popup.update_action(action, labels[action])
	input_popup.popup_centered()


func _on_ListenForInputPopup_key_pressed(action: String, event: InputEventKey):
	
	var events = InputMap.action_get_events(action)
	
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	
	SettingsService.update_config()
	
	for old_event in events:
		if not old_event is InputEventKey: 
			InputMap.action_add_event(action, event)
	buttons[action].grab_focus()
	buttons[action].grab_click_focus()
	buttons[action].text = "<%s>" % OS.get_keycode_string(event.keycode)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		self.emit_signal("exit")
		self.get_viewport().set_input_as_handled()
		self.set_process_unhandled_input(false)
		
		
func on_grab_focus():
	var first_element = $CenterContainer/Settings/Sliders/MusicVolumeSlider

	first_element.grab_focus()
	first_element.grab_click_focus()
	self.set_process_unhandled_input(true)
