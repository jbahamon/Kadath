extends PopupPanel

signal confirmed(ok)

@onready var no_button = $VBoxContainer/HBoxContainer/No
func _unhandled_input(event):
	if visible:
		if event.is_action_pressed("ui_cancel"):
			self.hide()
			self.confirmed.emit(false)
		self.get_viewport().set_input_as_handled()

func _on_about_to_popup():
	no_button.grab_focus()
	no_button.grab_click_focus()
	
func _on_No_pressed():
	self.hide()
	self.confirmed.emit(false)

func _on_Yes_pressed():
	self.hide()
	self.confirmed.emit(true)
