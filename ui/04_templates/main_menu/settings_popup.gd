extends PopupPanel

func _ready():
	self.set_process_unhandled_input(false)
	
func on_about_to_popup():
	self.set_process_unhandled_input(true)
	$SettingsMenu.on_grab_focus()
