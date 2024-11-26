extends PopupPanel

signal confirmed

func _unhandled_input(event):
	if visible:
		if event.is_action_pressed("ui_cancel"):
			self.hide()
		self.get_viewport().set_input_as_handled()
	
func _on_No_pressed():
	self.hide()

func _on_Yes_pressed():
	self.hide()
	self.confirmed.emit()
