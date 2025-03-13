extends Popup

signal skip_chosen(was_skip_chosen)

@onready var resume_button = $PanelContainer/VBoxContainer/HBoxContainer/Resume
@onready var skip_button = $PanelContainer/VBoxContainer/HBoxContainer/Skip

func _init():
	self.popup_window = false
	
func _on_about_to_popup():
	resume_button.grab_focus()
	resume_button.grab_click_focus()
	resume_button.disabled = false


func _on_resume_pressed():
	self.skip_chosen.emit(false)
	self.hide()


func _on_skip_pressed():
	self.skip_chosen.emit(true)
	self.hide()

func _on_popup_hide():
	self.resume_button.disabled = true
	self.resume_button.disabled = true
	
