extends PanelContainer

var SimpleListElement = preload("res://ui/01_atoms/simple_list_element/simple_list_element.gd")

signal element_focused(element)
signal element_selected(element)
signal cancel
signal done

@onready var container = $ScrollContainer/VBoxContainer 
@export var bind_ui_elements = false
@export var toggle: bool = false
@export var args_for_null_element: Dictionary = {}
@export var focused_if_visible = false

var button_group: ButtonGroup = null

func _ready():
	self.set_process_unhandled_input(false)
	
func initialize(elements: Array, other_params: Dictionary = {}):
	self.clear_elements()
	
	var class_or_scene = other_params.get("class_or_scene", SimpleListElement)
	var disable_func = other_params.get("disable_func", null)
	
	var buttons = []
	for element in elements:
		var control
		
		if "instantiate" in class_or_scene:
			control = class_or_scene.instantiate()
		else:
			control = class_or_scene.new()
		
		if element != null:
			control.assign_element(element)
		else:
			control.assign_null(self.args_for_null_element)
		
		if disable_func != null:
			control.set_as_disabled(disable_func.call(element))
			
		container.add_child(control)
	
		var button: Button = control.get_button()
		
		var bound_object = control if bind_ui_elements else element
		button.pressed.connect(self.on_element_selected.bind(bound_object))
		button.focus_entered.connect(self.on_element_focused.bind(bound_object))

		buttons.append(button)
	
	for i in range(len(buttons)):
		var button = buttons[i]
		button.focus_neighbor_left = button.get_path_to(button)
		button.focus_neighbor_right = button.get_path_to(button)
		button.focus_neighbor_top = button.get_path_to(buttons[posmod((i - 1), len(buttons))])
		button.focus_neighbor_bottom = button.get_path_to(buttons[posmod((i + 1), len(buttons))])


	if self.toggle:
		button_group = ButtonGroup.new()
		for button in buttons:
			button.set_button_group(button_group)
			button.toggle_mode = true
	
func on_element_focused(element):
	emit_signal("element_focused", element)
		
func on_element_selected(element):
	emit_signal("element_selected", element)

func on_grab_focus():
	if toggle:
		var button = self.button_group.get_pressed_button()
		if button != null:
			button.button_pressed = false
			button.grab_focus()
			button.grab_click_focus()
			return

	for control in container.get_children():
		var button = control.get_button()
		button.button_pressed = false
		button.grab_focus()
		button.grab_click_focus()
		return
	
func element_has_focus() -> bool:
	return container.get_children().any(
		func (control): 
			return control.get_button().has_focus()
	)

func clear_elements():
	for control in container.get_children():
		var button = control.get_button()
		button.pressed.disconnect(self.on_element_selected)
		button.focus_entered.disconnect(self.on_element_focused)
		button.button_group = null
		container.remove_child(control)
		control.queue_free()
	
	self.button_group = null
		

func _on_SelectPanel_visibility_changed():
	self.set_process_unhandled_input(self.visible)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and (self.element_has_focus() or (self.visible and self.focused_if_visible)):
		self.emit_signal("cancel")
		self.get_viewport().set_input_as_handled()

func _on_cancel():
	self.emit_signal("done")

func _on_element_selected(_element):
	self.emit_signal("done")
	
func size():
	return container.get_child_count()
	
func deselect():
	for control in container.get_children():
		var button: Button = control.get_button()
		button.set_pressed_no_signal(false)
