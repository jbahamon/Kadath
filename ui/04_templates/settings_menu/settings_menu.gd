extends ScrollContainer

# Order is important here
const labels = {
	"ui_up": "Up",
	"ui_accept": "Accept/Interact",
	"ui_down": "Down",
	"ui_cancel": "Cancel",
	"ui_left": "Left",
	"ui_menu": "Open Menu",
	"ui_right": "Right",
	"run": "Run"
}

var buttons: Dictionary

onready var grid: GridContainer = $CenterContainer/Settings/InputVBox/InputControls
onready var input_popup: Popup = $Popups/ListenForInputPopup
onready var text_speed_slider = $CenterContainer/Settings/Sliders/TextSpeedSlider


func _ready():
	buttons = {}
	for action in labels.keys():
		var label_text = labels[action]
		add_input_option(action, label_text)
		link_buttons()
	self.grab_focus()

func add_input_option(action: String, label_text: String):
	add_label(label_text)
	add_button(action)

func add_label(label_text: String):
	var label = Label.new()
	label.text = label_text
	label.align = Label.ALIGN_RIGHT
	grid.add_child(label)
	
func add_button(action: String):
	var button = Button.new()
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var actions = InputMap.get_action_list(action)
	if actions.empty():
		button.text = "---"
	else:
		var scancode = InputMap.get_action_list(action)[0].scancode	
		button.text = "<%s>" % OS.get_scancode_string(scancode)
	
	button.connect(
		"pressed", 
		self, 
		"_button_pressed", 
		[action])
	grid.add_child(button)
	
	buttons[action] = button

# Seems that using the grid confuses the automatic focus behavior.
# So we explicitly set the neighbors
func link_buttons():
	var keys = buttons.keys()
	for i in range(len(keys)):
		var button: Button = buttons[keys[i]]
		if i % 2 != 0:
			button.focus_neighbour_left = button.get_path_to(buttons[keys[i - 1]])
		else:
			button.focus_neighbour_left = button.get_path_to(button)
		
		if i > 1:
			button.focus_neighbour_top = button.get_path_to(buttons[keys[i - 2]])
		else:
			button.focus_neighbour_top = button.get_path_to(text_speed_slider)
			
		if (i + 1) < len(keys):
			if i % 2 == 0:
				button.focus_neighbour_right = button.get_path_to(buttons[keys[i + 1]])
			else:
				button.focus_neighbour_right = button.get_path_to(button)
		
		if (i + 2) < len(keys):
			button.focus_neighbour_bottom = button.get_path_to(buttons[keys[i + 2]])
		else:
			button.focus_neighbour_bottom = button.get_path_to(button)
	
	
func _button_pressed(action: String):
	buttons[action].release_focus()
	input_popup.update_action(action, labels[action])
	input_popup.popup_centered()


func _on_ListenForInputPopup_key_pressed(action: String, event: InputEventKey):
	
	var events = InputMap.get_action_list(action)
	
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	
	UserSettings.update_config()
	
	for old_event in events:
		if not old_event is InputEventKey: 
			InputMap.action_add_event(action, event)
	buttons[action].grab_focus()
	buttons[action].grab_click_focus()
	buttons[action].text = "<%s>" % OS.get_scancode_string(event.scancode)

func grab_focus():
	var first_element = $CenterContainer/Settings/Sliders/MusicVolumeSlider

	first_element.grab_focus()
	first_element.grab_click_focus()
	
	return true

func release_focus():
	return
