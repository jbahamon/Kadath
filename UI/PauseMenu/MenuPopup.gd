extends PopupPanel


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		hide()
	
	if visible:
		get_tree().set_input_as_handled()
