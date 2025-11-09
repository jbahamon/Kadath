extends PopupPanel

func _on_about_to_popup() -> void:
	UIService.help_bar = $MarginContainer/VBoxContainer/HelpBar

func on_saving_done():
	hide()

func set_spot_name(save_spot_name):
	$MarginContainer/VBoxContainer/SavesMenu.set_spot_name(save_spot_name)
