extends VBoxContainer

@onready var new_game_button = $"HBoxContainer/Menu Options/New Game"
@onready var continue_button = $"HBoxContainer/Menu Options/Continue Game"
@onready var quit_button = $"HBoxContainer/Menu Options/Quit"
func show_menu():
	var button: Button = new_game_button if not SavesService.has_file_with_data() else continue_button
	
	button.focus_neighbor_top = button.get_path_to(quit_button)
	quit_button.focus_neighbor_bottom = quit_button.get_path_to(button)
	
	if button != continue_button:
		continue_button.hide()
	else:
		new_game_button.focus_neighbor_top = new_game_button.get_path_to(continue_button)
	self.show()
	
	if button.focus_entered.is_connected(UIService.play_focus_sound):
		button.focus_entered.disconnect(UIService.play_focus_sound)
	button.grab_focus()
	button.grab_click_focus()
	button.focus_entered.connect(UIService.play_focus_sound)
	
func hide_menu():
	self.visible = false

func update_menu():
	pass
	
func disable_buttons():
	for button in get_node("HBoxContainer/Menu Options").get_children():
		if button.has_focus():
			button.release_focus()
