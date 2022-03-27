extends MarginContainer

signal element_focused(element)
signal element_selected(element)

export var toggle: bool = true

export var normal_button: StyleBox
export var pressed_button: StyleBox
export var disabled_button: StyleBox
export var hover_button: StyleBox
export var focused_button: StyleBox

onready var container = $ScrollContainer/VBoxContainer 

func _ready():
	self.set_process_unhandled_input(false)
	
func initialize(elements: Array):
	for element in elements:
		var control = element.instance_ui_control()
		container.add_child(control)
		yield(get_tree(), "idle_frame")
		
		var button = control.get_button()
		button.connect("pressed", self, "on_element_selected", [element])
		button.connect("focus_entered", self, "on_element_focused", [element])
		
		button.focus_neighbour_left = button.get_path_to(button)
		button.focus_neighbour_right = button.get_path_to(button)
	
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
			
		button.set_toggle_mode(self.toggle)
		
	var first_button: Button = container.get_child(0).get_button()
	var last_button: Button = container.get_child(container.get_child_count() - 1).get_button()
	
	first_button.focus_neighbour_top = first_button.get_path_to(last_button)
	last_button.focus_neighbour_bottom = last_button.get_path_to(first_button)
	
	first_button.grab_click_focus()
	first_button.grab_focus()

func get_first_clickable_item():
	return container.get_child(0).get_button()
	
func on_element_focused(element):
	emit_signal("element_focused", element)
		
func on_element_selected(element):
	emit_signal("element_selected", element)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("element_selected", null)
		get_tree().set_input_as_handled()

func regain_focus():
	if self.toggle:
		for control in container.get_children():
			var button = control.get_button()
			if button.pressed:
				button.grab_focus()
				button.grab_click_focus()
				return
	else:
		var button = container.get_children(0).get_button()
		button.grab_focus()
		button.grab_click_focus()
		
		
func clear_elements():
	for control in container.get_children():
		var button = control.get_button()
		button.disconnect("pressed", self)
		button.disconnect("focus_entered", self)
		container.remove_child(control)
		control.queue_free()

func _on_SelectPanel_visibility_changed():
	self.set_process_unhandled_input(self.visible)
