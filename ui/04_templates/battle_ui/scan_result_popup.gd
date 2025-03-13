extends Popup

func _init():
	self.popup_window = false
	self.set_process_unhandled_input(false)
	
func _on_about_to_popup():
	self.set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept") or event.is_action_pressed(&"ui_cancel"):
		self.set_process_unhandled_input(false)
		self.hide()

func update(actor):
	$EnemyInfo.update(actor)
