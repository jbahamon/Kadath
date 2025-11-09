extends Control

signal done
signal input_request(action, label)

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

@onready var grid: GridContainer = $InputControls
@onready var hold_run_checkbox: CheckBox = $RunBehaviorContainer/Hold
@onready var toggle_run_checkbox: CheckBox = $RunBehaviorContainer/Toggle

@onready var settings_menu = get_node("../../..")

func _ready() -> void:
	self.set_process_unhandled_input(false)
	
	self.hold_run_checkbox.focus_entered.connect(self.on_toggle_focused.bind("Hold [{action_run}] to run.".format(VarsService.strings)))
	self.toggle_run_checkbox.focus_entered.connect(self.on_toggle_focused.bind("Press [{action_run}] to toggle walking/running.".format(VarsService.strings)))
	
	buttons = {}
	for action in labels.keys():
		var label_text = labels[action]
		add_input_option(action, label_text)
		link_buttons()
	
	var group = ButtonGroup.new()
	self.hold_run_checkbox.button_group = group
	self.toggle_run_checkbox.button_group = group
	
	self.toggle_run_checkbox.set_pressed_no_signal(SettingsService.toggle_run)
	self.hold_run_checkbox.set_pressed_no_signal(not SettingsService.toggle_run)
	
	self.hold_run_checkbox.pressed.connect(UIService.play_interaction_sound)
	self.toggle_run_checkbox.pressed.connect(UIService.play_interaction_sound)
	
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
	
	button.focus_entered.connect(self.on_binding_focused)
	button.pressed.connect(UIService.play_focus_sound)
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
			button.focus_neighbor_top = button.get_path_to(hold_run_checkbox if i == 0 else toggle_run_checkbox) 
			
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
	
	for button_action in buttons:
		buttons[button_action].mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	self.input_request.emit(action, labels[action])

func _on_listen_for_input_popup_key_pressed(action: String, event: InputEventKey) -> void:
	var events = InputMap.action_get_events(action)
	
	SettingsService.update_input(action, event)
	
	for old_event in events:
		if not old_event is InputEventKey: 
			InputMap.action_add_event(action, event)
	
	for button_action in buttons:
		buttons[button_action].mouse_filter = Control.MOUSE_FILTER_STOP
		buttons[button_action].text = "<%s>" % VarsService.strings[button_action]
		
	buttons[action].grab_focus()
	buttons[action].grab_click_focus()
	UIService.play_interaction_sound()

func on_toggle_focused(help_text):
	self.settings_menu.on_toggle_focused(help_text)

func on_binding_focused():
	UIService.set_menu_help(
		"Change a specific control binding.",
		"[{ui_up}]/[{ui_down}]/[{ui_left}]/[{ui_right}]: Select [{ui_cancel}]: Return [{ui_accept}]: Change"
	)

func on_grab_focus():
	var first = grid.get_child(1)
	first.grab_focus()
	self.set_process_unhandled_input(true)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		self.done.emit()
		self.get_viewport().set_input_as_handled()
		self.set_process_unhandled_input(false)


func _on_reset_pressed() -> void:
	UIService.play_interaction_sound()
	
	SettingsService.reset_inputs()
	
	for button_action in buttons:
		buttons[button_action].text = "<%s>" % VarsService.strings[button_action]

	self.toggle_run_checkbox.set_pressed_no_signal(SettingsService.toggle_run)
	self.hold_run_checkbox.set_pressed_no_signal(not SettingsService.toggle_run)

func on_run_hold_toggled(toggled_on: bool) -> void:
	SettingsService.update_run_behavior(not toggled_on)
