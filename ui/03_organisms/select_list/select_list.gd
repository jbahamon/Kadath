extends PanelContainer

var SimpleListElement = preload("res://ui/01_atoms/simple_list_element/simple_list_element.tscn")

signal cancel
signal element_focused(element)
signal element_selected(element)

@onready var container = $ScrollContainer/VBoxContainer 

func _ready():
	self.set_process_unhandled_input(false)
	
func initialize(elements: Array):
	self.clear_elements()
	
	var buttons = []
	for element in elements:
		var control = self.get_ui_control(element)
		container.add_child(control)
	
		var button = control.get_button()
		button.connect("pressed",Callable(self,"on_element_selected").bind(element))
		button.connect("focus_entered",Callable(self,"on_element_focused").bind(element))

		button.disabled = control.disabled
		buttons.append(button)
	
	for i in range(len(buttons)):
		var button = buttons[i]
		button.focus_neighbor_left = button.get_path_to(button)
		button.focus_neighbor_right = button.get_path_to(button)
		button.focus_neighbor_top = button.get_path_to(buttons[posmod((i - 1), len(buttons))])
		button.focus_neighbor_bottom = button.get_path_to(buttons[posmod((i + 1), len(buttons))])

func get_first_clickable_item():
	if container.get_child_count() == 0:
		return null
	return container.get_child(0).get_button()
	
func get_ui_control(element):
	if element.has_method("instance_ui_control"):
		return element.instance_ui_control()
	else:
		var control = SimpleListElement.instantiate()
		control.text = element.display_name if "display_name" in element else element.name
		return control
	
func on_element_focused(element):
	emit_signal("element_focused", element)
		
func on_element_selected(element):
	emit_signal("element_selected", element)

func on_grab_focus():
	for control in container.get_children():
		var button = control.get_button()
		if not button.disabled and (button.pressed or not self.toggle):
			button.button_pressed = false
			button.grab_focus()
			button.grab_click_focus()
			return

func element_has_focus() -> bool:
	for control in container.get_children():
		var button: Button = control.get_button()
		if button.has_focus():
			return true
	return false

func clear_elements():
	for control in container.get_children():
		var button = control.get_button()
		button.disconnect("pressed",Callable(self,"on_element_selected"))
		button.disconnect("focus_entered",Callable(self,"on_element_focused"))
		container.remove_child(control)
		control.queue_free()

func _on_SelectPanel_visibility_changed():
	self.set_process_unhandled_input(self.visible)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and self.element_has_focus():
		emit_signal("cancel")
		get_viewport().set_input_as_handled()
