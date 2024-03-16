extends PopupPanel

signal key_pressed(action, event)

var action: String

@onready var label = $PressKeyLabel


func _ready():
	set_process_unhandled_input(false)

func on_about_to_popup():
	set_process_unhandled_input(true)
	
func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		emit_signal("key_pressed", action, event)
		get_viewport().set_input_as_handled()
		self.hide()
		
		
func update_action(new_action, new_action_label):
	action = new_action
	label.text = "Press key for \"%s\"..." % new_action_label
