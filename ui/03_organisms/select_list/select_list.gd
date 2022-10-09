extends MarginContainer

var SimpleListElement = preload("res://ui/01_atoms/simple_list_element/simple_list_element.tscn")

signal cancel
signal element_focused(element)
signal element_selected(element)

export var include_cancel_button: bool = false
export var toggle: bool = true
export var handle_cancel: bool = true
export var flat: bool = false

export var normal_button: StyleBox
export var pressed_button: StyleBox
export var disabled_button: StyleBox
export var hover_button: StyleBox
export var focused_button: StyleBox

onready var container = $ScrollContainer/VBoxContainer 
onready var cancel_button = $ScrollContainer/VBoxContainer/CancelButton

func _ready():
	self.set_process_unhandled_input(false)
	
	cancel_button.flat = self.flat
	
	if normal_button != null:
		cancel_button.add_stylebox_override("normal", normal_button)
	if pressed_button != null:
		cancel_button.add_stylebox_override("pressed", pressed_button)
	if disabled_button != null:
		cancel_button.add_stylebox_override("disabled", disabled_button)
	if hover_button != null:
		cancel_button.add_stylebox_override("hover", hover_button)
	if focused_button != null:
		cancel_button.add_stylebox_override("focus", focused_button)
		
	cancel_button.visible = self.include_cancel_button
	
func initialize(elements: Array):
	self.clear_elements()
	container.remove_child(cancel_button)
	
	var buttons = []
	for element in elements:
		var control = self.get_ui_control(element)
		container.add_child(control)
	
		var button = control.get_button()
		button.connect("pressed", self, "on_element_selected", [element])
		button.connect("focus_entered", self, "on_element_focused", [element])
	
		if normal_button != null:
			button.add_stylebox_override("normal", normal_button)
		if pressed_button != null:
			button.add_stylebox_override("pressed", pressed_button)
		if disabled_button != null:
			button.add_stylebox_override("disabled", disabled_button)
		if hover_button != null:
			button.add_stylebox_override("hover", hover_button)
		if focused_button != null:
			button.add_stylebox_override("focus", focused_button)
		
		button.disabled = control.disabled
		button.flat = self.flat
		button.set_toggle_mode(self.toggle)
		buttons.append(button)
	
	container.add_child(cancel_button)
	cancel_button.visible = self.include_cancel_button
	if cancel_button.visible:
		buttons.append(cancel_button)
		
	for i in range(len(buttons)):
		var button = buttons[i]
		button.focus_neighbour_left = button.get_path_to(button)
		button.focus_neighbour_right = button.get_path_to(button)
		button.focus_neighbour_top = button.get_path_to(buttons[posmod((i - 1), len(buttons))])
		button.focus_neighbour_bottom = button.get_path_to(buttons[posmod((i + 1), len(buttons))])

func get_first_clickable_item():
	if container.get_child_count() == 1 and not include_cancel_button:
		return null
	return container.get_child(0).get_button()
	
func get_ui_control(element):
	if element.has_method("instance_ui_control"):
		return element.instance_ui_control()
	else:
		var control = SimpleListElement.instance()
		control.text = element.display_name if "display_name" in element else element.name
		return control
	
func on_element_focused(element):
	emit_signal("element_focused", element)
		
func on_element_selected(element):
	emit_signal("element_selected", element)

func grab_focus():
	for control in container.get_children():
		var button = control.get_button()
		if not button.disabled and (button.pressed or not self.toggle):
			button.pressed = false
			button.grab_focus()
			button.grab_click_focus()
			return

func has_focus() -> bool:
	for control in container.get_children():
		var button: Button = control.get_button()
		if button.has_focus():
			return true
	return false

func clear_elements():
	for control in container.get_children():
		if control != self.cancel_button:
			var button = control.get_button()
			button.disconnect("pressed", self, "on_element_selected")
			button.disconnect("focus_entered", self, "on_element_focused")
			container.remove_child(control)
			control.queue_free()

func _on_SelectPanel_visibility_changed():
	self.set_process_unhandled_input(self.visible and self.handle_cancel)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and self.has_focus():
		emit_signal("cancel")
		get_tree().set_input_as_handled()

func on_cancel():
	emit_signal("cancel")
