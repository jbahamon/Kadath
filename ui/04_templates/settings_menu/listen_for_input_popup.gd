extends PopupPanel

signal key_pressed(action, event)

var action: String

@onready var label = $PressKeyLabel

func _ready():
	self.set_process_unhandled_input(false)

func on_about_to_popup():
	self.set_process_unhandled_input(true)
	
func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		self.key_pressed.emit(action, event)
		self.get_viewport().set_input_as_handled()
		self.set_process_unhandled_input(false)
		self.hide()
		
		
func update_action(new_action, new_action_label):
	action = new_action
	label.text = "Press key for \"%s\"..." % new_action_label

func _on_focus_exited() -> void:
	if self.visible and self.is_processing_unhandled_input():
		await get_tree().process_frame
		self.grab_focus()
		self.label.grab_click_focus()
