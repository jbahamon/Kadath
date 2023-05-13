extends PopupPanel

func _ready():
	self.set_process_unhandled_input(false)
	
func on_about_to_popup():
	self.set_process_unhandled_input(true)
	$SettingsMenu.on_grab_focus()
	

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		self.set_process_unhandled_input(false)
		hide()
